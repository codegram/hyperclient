require 'addressable'

module Hyperclient
  # Public: Exception that is raised when iterating a link whose resource
  # links back to itself under the same name, which would otherwise recurse
  # forever.
  class SelfReferencingLinkError < StandardError
    def initialize(key, url)
      super("The #{key} link at #{url} links back to itself, use _embedded to iterate over embedded items.")
    end
  end

  # Public: Exception that is raised before sending a request with a method
  # that the most recent response for the same Link excluded from its Allow
  # header.
  class MethodNotAllowedError < StandardError
    # Public: Returns the upper-case String HTTP method that was refused.
    attr_reader :http_method

    # Public: Returns the String url of the Link.
    attr_reader :url

    # Public: Returns the Array of upper-case String methods that the server
    # allows.
    attr_reader :allowed

    def initialize(http_method, url, allowed)
      @http_method = http_method
      @url = url
      @allowed = allowed
      allows = allowed.empty? ? 'no methods' : "only #{allowed.join(', ')}"
      super("#{http_method} is not allowed on #{url}, the server allows #{allows}.")
    end
  end

  # Internal: The Link is used to let a Resource interact with the API.
  #
  class Link
    include Enumerable

    # Public: Initializes a new Link.
    #
    # key           - The key or name of the link.
    # link          - The String with the URI of the link.
    # entry_point   - The EntryPoint object to inject the configuration.
    # uri_variables - The optional Hash with the variables to expand the link
    #                 if it is templated.
    # query_params  - The optional Hash with query parameters to add to the
    #                 link's URL.
    def initialize(key, link, entry_point, uri_variables = nil, query_params = nil)
      @key           = key
      @link          = link
      @entry_point   = entry_point
      @uri_variables = uri_variables
      @query_params  = query_params
      @resource      = nil
      @allow         = nil
    end

    # Internal: Parses the Allow header from response headers.
    #
    # headers - The Hash-like response headers, or nil.
    #
    # Returns nil when there is no Allow header, otherwise an Array of
    # upper-case String methods, which is empty when the header is empty.
    def self.parse_allow(headers)
      value = headers && (headers['Allow'] || headers['allow'])
      return if value.nil?

      Array(value).join(',').split(',').map { |m| m.strip.upcase }.reject(&:empty?).uniq
    end

    # Public: Each implementation to allow the class to use the Enumerable
    # benefits for paginated, embedded items.
    #
    # Returns an Enumerator.
    def each(&block)
      if block_given?
        current = self
        while current
          coll = current.respond_to?(@key) ? current.send(@key) : _resource
          raise SelfReferencingLinkError.new(@key, current._url) if current.self_referencing?(coll)

          coll.each(&block)
          break unless current._links[:next]

          current = current._links.next
        end
      else
        to_enum(:each)
      end
    end

    # Public: Indicates if the link is an URITemplate or a regular URI.
    #
    # Returns true if it is templated.
    # Returns false if it not templated.
    def _templated?
      !!@link['templated']
    end

    # Public: Expands the Link when is templated with the given variables.
    #
    # uri_variables - The Hash with the variables to expand the URITemplate.
    #
    # Returns a new Link with the expanded variables.
    def _expand(uri_variables = {})
      self.class.new(@key, @link, @entry_point, uri_variables, @query_params)
    end

    # Public: Adds query parameters to the Link's URL, whether or not the link
    # is templated or declares them. Parameters with nil values are dropped.
    #
    # query_params - The Hash with the query parameters to add.
    #
    # Returns a new Link with the query parameters.
    def _query(query_params = {})
      self.class.new(@key, @link, @entry_point, @uri_variables, (@query_params || {}).merge(query_params))
    end

    # Public: Returns the url of the Link.
    def _url
      @url ||= _add_query_params(_templated? ? _uri_template.expand(@uri_variables || {}).to_s : @link['href'])
    end

    # Public: Returns an array of variables from the URITemplate.
    #
    # Returns an empty array for regular URIs.
    def _variables
      _uri_template.variables
    end

    # Public: Returns the type property of the Link
    def _type
      @link['type']
    end

    # Public: Returns the name property of the Link
    def _name
      @link['name']
    end

    # Public: Returns the deprecation property of the Link
    def _deprecation
      @link['deprecation']
    end

    # Public: Returns the profile property of the Link
    def _profile
      @link['profile']
    end

    # Public: Returns the title property of the Link
    def _title
      @link['title']
    end

    # Public: Returns the hreflang property of the Link
    def _hreflang
      @link['hreflang']
    end

    # Public: Returns the methods listed in the Allow header of the most
    # recent response for this Link, as upper-case Strings.
    #
    # Returns nil if no response has been received yet or the most recent
    # response did not carry an Allow header.
    def _allow
      @allow&.dup
    end

    # Public: Indicates if the server allows the given method on this Link,
    # according to the Allow header of the most recent response.
    #
    # method - A Symbol or String HTTP method, case-insensitive.
    #
    # Returns true if the method is allowed or no Allow header was received.
    def _allow?(method)
      @allow.nil? || @allow.include?(method.to_s.upcase)
    end

    def _resource
      @resource || _get
    end

    # Public: Returns the Resource which the Link is pointing to.
    def _get
      http_method(:get)
    end

    def _options
      http_method(:options)
    end

    def _head
      http_method(:head)
    end

    def _delete
      http_method(:delete)
    end

    def _post(params = {})
      http_method(:post, params)
    end

    def _put(params = {})
      http_method(:put, params)
    end

    def _patch(params = {})
      http_method(:patch, params)
    end

    def inspect
      "#<#{self.class.name}(#{@key}) #{@link}>"
    end

    def to_s
      _url
    end

    private

    # Internal: Delegate the method further down the API if the resource cannot serve it.
    def method_missing(method, *args, &block)
      if _resource.respond_to?(method.to_s)
        result = _resource.send(method, *args, &block)
        result.nil? ? delegate_method(method, *args, &block) : result
      else
        super
      end
    end

    # Internal: Delegate the method to the API if the resource cannot serve it.
    #
    # This allows `api.posts` instead of `api._links.posts.embedded.posts`
    def delegate_method(method, *args, &block)
      return unless @key && _resource.respond_to?(@key)

      @delegate ||= _resource.send(@key)
      return if self_referencing?(@delegate)
      return unless @delegate&.respond_to?(method.to_s)

      @delegate.send(method, *args, &block)
    end

    # Internal: Accessory method to allow the link respond to the
    # methods that will hit method_missing.
    def respond_to_missing?(method, _include_private = false)
      if @key && _resource.respond_to?(@key) && (delegate = _resource.send(@key)) &&
         !self_referencing?(delegate) && delegate.respond_to?(method.to_s)
        true
      else
        _resource.respond_to?(method.to_s)
      end
    end

    # Internal: Indicates if the given object is a Link to this same URL,
    # following which would recurse forever.
    def self_referencing?(other)
      other.is_a?(Link) && other._url == _url
    end
    protected :self_referencing?

    # Internal: avoid delegating to resource
    #
    # #to_ary is called for implicit array coercion (such as parallel assignment
    # or Array#flatten). Returning nil tells Ruby that this record is not Array-like.
    def to_ary
      nil
    end

    # Internal: Memoization for a URITemplate instance
    def _uri_template
      @uri_template ||= Addressable::Template.new(@link['href'])
    end

    # Internal: Appends the query parameters to the URL, keeping its existing
    # query string and fragment.
    def _add_query_params(url)
      params = (@query_params || {}).compact
      return url if params.empty?

      uri = Addressable::URI.parse(url)
      uri.query = [uri.query, Addressable::URI.form_encode(params)].compact.reject(&:empty?).join('&')
      uri.to_s
    end

    # Internal: Raises MethodNotAllowedError if the most recent response for
    # this Link excluded the method from its Allow header. OPTIONS is always
    # sent, so that callers can rediscover the allowed methods.
    def ensure_allowed!(method)
      return if method == :options || _allow?(method) || !@entry_point.enforce_allowed_methods?

      raise MethodNotAllowedError.new(method.to_s.upcase, _url, @allow.dup)
    end

    def http_method(method, body = nil)
      ensure_allowed!(method)

      begin
        response = @entry_point.connection.run_request(method, _url, body, nil)
      rescue Faraday::Error => e
        @allow = Link.parse_allow(e.response_headers) if e.response
        raise
      end

      @allow = Link.parse_allow(response.headers)
      resource = Resource.new(response.body, @entry_point, response)

      # Only cache GET responses. Caching the response of a mutating
      # request (POST/PUT/PATCH/DELETE) as `@resource` would make
      # subsequent delegated calls (e.g. `#each`, `method_missing`) see
      # the stale mutation response instead of fetching a fresh
      # resource, requiring users to create a new client between a
      # `_post` and a `_get`. See #107.
      @resource = resource if method == :get
      @delegate = nil

      resource
    end
  end
end
