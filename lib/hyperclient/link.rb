# typed: strict
require 'addressable'

module Hyperclient
  # Internal: The Link is used to let a Resource interact with the API.
  #
  class Link
    extend T::Sig

    # Public: Initializes a new Link.
    #
    # key           - The key or name of the link.
    # link          - The String with the URI of the link.
    # entry_point   - The EntryPoint object to inject the configuration.
    # uri_variables - The optional Hash with the variables to expand the link
    #                 if it is templated.
    sig do
      params(
        key: String,
        link: T::Hash[String, String],
        entry_point: Hyperclient::EntryPoint,
        uri_variables: T.nilable(T::Hash[Symbol, T.untyped])
      ).void
    end
    def initialize(key, link, entry_point, uri_variables = nil)
      @key           = T.let(key, T.nilable(String))
      @link          = T.let(link, T::Hash[String, String])
      @entry_point   = T.let(entry_point, Hyperclient::EntryPoint)
      @uri_variables = T.let(uri_variables, T.nilable(T::Hash[Symbol, T.untyped]))
      @resource      = T.let(nil, T.nilable(Hyperclient::Resource))
      @url           = T.let(nil, T.nilable(String))
      @delegate      = T.let(nil, T.untyped)
      @uri_template  = T.let(
        nil,
        T.nilable(Addressable::Template)
      )
    end

    # Public: Indicates if the link is an URITemplate or a regular URI.
    #
    # Returns true if it is templated.
    # Returns false if it not templated.
    sig { returns(T::Boolean) }
    def _templated?
      !!@link['templated']
    end

    # Public: Expands the Link when is templated with the given variables.
    #
    # uri_variables - The Hash with the variables to expand the URITemplate.
    #
    # Returns a new Link with the expanded variables.
    sig { params(uri_variables: T::Hash[Symbol, T.untyped]).returns(Hyperclient::Link) }
    def _expand(uri_variables = {})
      self.class.new(T.must(@key), @link, @entry_point, uri_variables)
    end

    # Public: Returns the url of the Link.
    sig { returns(T.nilable(String)) }
    def _url
      return @link['href'] unless _templated?

      @url ||= _uri_template.expand(@uri_variables || {}).to_s
    end

    # Public: Returns an array of variables from the URITemplate.
    #
    # Returns an empty array for regular URIs.
    sig { returns(T::Array[String]) }
    def _variables
      _uri_template.variables
    end

    # Public: Returns the type property of the Link
    sig { returns(T.nilable(String)) }
    def _type
      @link['type']
    end

    # Public: Returns the name property of the Link
    sig { returns(T.nilable(String)) }
    def _name
      @link['name']
    end

    # Public: Returns the deprecation property of the Link
    sig { returns(T.nilable(String)) }
    def _deprecation
      @link['deprecation']
    end

    # Public: Returns the profile property of the Link
    sig { returns(T.nilable(String)) }
    def _profile
      @link['profile']
    end

    # Public: Returns the title property of the Link
    sig { returns(T.nilable(String)) }
    def _title
      @link['title']
    end

    # Public: Returns the hreflang property of the Link
    sig { returns(T.nilable(String)) }
    def _hreflang
      @link['hreflang']
    end

    sig { returns(Hyperclient::Resource) }
    def _resource
      @resource || _get
    end

    # Public: Returns the Resource which the Link is pointing to.
    sig { returns(Hyperclient::Resource) }
    def _get
      http_method(:get)
    end

    sig { returns(Hyperclient::Resource) }
    def _options
      http_method(:options)
    end

    sig { returns(Hyperclient::Resource) }
    def _head
      http_method(:head)
    end

    sig { returns(Hyperclient::Resource) }
    def _delete
      http_method(:delete)
    end

    sig { params(params: Hash).returns(Hyperclient::Resource) }
    def _post(params = {})
      http_method(:post, params)
    end

    sig { params(params: Hash).returns(Hyperclient::Resource) }
    def _put(params = {})
      http_method(:put, params)
    end

    sig { params(params: Hash).returns(Hyperclient::Resource) }
    def _patch(params = {})
      http_method(:patch, params)
    end

    sig { returns(String) }
    def inspect
      "#<#{self.class.name}(#{@key}) #{@link}>"
    end

    sig { returns(T.nilable(String)) }
    def to_s
      _url
    end

    private

    # Internal: Delegate the method further down the API if the resource cannot serve it.
    sig do
      params(
        method: T.any(String, Symbol),
        args: T.untyped
      ).returns(T.untyped)
    end
    def method_missing(method, *args, &block)
      if _resource.respond_to?(method.to_s)
        result = T.unsafe(_resource).send(method, *args, &block)
        result.nil? ? T.unsafe(self).delegate_method(method, *args, &block) : result
      else
        super
      end
    end

    # Internal: Delegate the method to the API if the resource cannot serve it.
    #
    # This allows `api.posts` instead of `api._links.posts.embedded.posts`
    sig do
      params(
        method: T.any(String, Symbol),
        args: T.untyped
      ).returns(T.untyped)
    end
    def delegate_method(method, *args, &block)
      return unless @key && _resource.respond_to?(@key)

      @delegate ||= _resource.send(@key)
      return unless @delegate&.respond_to?(method.to_s)

      @delegate.send(method, *args, &block)
    end

    # Internal: Accessory method to allow the link respond to the
    # methods that will hit method_missing.
    sig { params(method: T.untyped, _include_private: T::Boolean).returns(T::Boolean) }
    def respond_to_missing?(method, _include_private = false)
      if @key && _resource.respond_to?(@key) && (delegate = _resource.send(@key)) && delegate.respond_to?(method.to_s)
        true
      else
        _resource.respond_to?(method.to_s)
      end
    end

    # Internal: avoid delegating to resource
    #
    # #to_ary is called for implicit array coercion (such as parallel assignment
    # or Array#flatten). Returning nil tells Ruby that this record is not Array-like.
    sig { returns(NilClass) }
    def to_ary
      nil
    end

    # Internal: Memoization for a URITemplate instance
    sig { returns(Addressable::Template) }
    def _uri_template
      @uri_template ||= Addressable::Template.new(@link['href'])
    end

    sig { params(method: Symbol, body: T.nilable(Hash)).returns(Hyperclient::Resource) }
    def http_method(method, body = nil)
      @resource = begin
        response = @entry_point.connection.run_request(method, _url, body, nil)
        Resource.new(response.body, @entry_point, response)
      end
    end
  end
end
