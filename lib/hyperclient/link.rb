require 'hyperclient/resource'
require 'uri_template'

module Hyperclient
  # Internal: The Link is  used to let a Resource interact with the API.
  #
  class Link
    # Public: Initializes a new Link.
    #
    # link          - The String with the URI of the link.
    # entry_point   - The EntryPoint object to inject the cofnigutation.
    # uri_variables - The optional Hash with the variables to expand the link
    #                 if it is templated.
    def initialize(link, entry_point, uri_variables = nil)
      @link          = link
      @entry_point   = entry_point
      @uri_variables = uri_variables
    end

    # Public: Indicates if the link is an URITemplate or a regular URI.
    #
    # Returns true if it is templated.
    # Returns false if it not templated.
    def templated?
      !!@link['templated']
    end

    # Public: Expands the Link when is templated with the given variables.
    #
    # uri_variables - The Hash with the variables to expand the URITemplate.
    #
    # Returns a new Link with the expanded variables.
    def expand(uri_variables)
      self.class.new(@link, @entry_point, uri_variables)
    end

    # Public: Returns the url of the Link.
    #
    # Raises MissingURITemplateVariables if the Link is templated but there are
    # no uri variables to expand it.
    def url
      return @link['href'] unless templated?
      raise MissingURITemplateVariablesException if @uri_variables == nil

      @url ||= uri_template.expand(@uri_variables)
    end

    # Public: Returns an array of variables from the URITemplate.
    #
    # Returns an empty array for regular URIs.
    def variables
      uri_template.variables
    end

    # Public: Returns the type property of the Link
    def type
      @link['type']
    end

    # Public: Returns the name property of the Link
    def name
      @link['name']
    end

    # Public: Returns the deprecation property of the Link
    def deprecation
      @link['deprecation']
    end

    # Public: Returns the profile property of the Link
    def profile
      @link['profile']
    end

    # Public: Returns the title property of the Link
    def title
      @link['title']
    end

    # Public: Returns the hreflang property of the Link
    def hreflang
      @link['hreflang']
    end

    # Public: Returns the Resource which the Link is pointing to.
    def resource
      @resource ||= begin
        response = get

        if response.success?
          Resource.new(response.body, @entry_point, response)
        else
          Resource.new(nil, @entry_point, response)
        end
      end
    end

    def connection
      @entry_point.connection
    end

    def get
      connection.get(url)
    end

    def options
      connection.run_request(:options, url, nil, nil)
    end

    def head
      connection.head(url)
    end

    def delete
      connection.delete(url)
    end

    def post(params = {})
      connection.post(url, params)
    end

    def put(params = {})
      connection.put(url, params)
    end

    def patch(params = {})
      connection.patch(url, params)
    end

    def inspect
      "#<#{self.class.name} #{@link}>"
    end

    private
    # Internal: Delegate the method to the API if it exists.
    #
    # This allows `api.links.posts.embedded` instead of
    # `api.links.posts.resource.embedded`
    def method_missing(method, *args, &block)
      if resource.respond_to?(method)
        resource.send(method, *args, &block)
      else
        super
      end
    end

    # Internal: Accessory method to allow the link respond to the
    # methods that will hit method_missing.
    def respond_to_missing?(method, include_private = false)
      resource.respond_to?(method.to_s)
    end

    # Internal: avoid delegating to resource
    #
    # #to_ary is called for implicit array coersion (such as parallel assignment
    # or Array#flatten). Returning nil tells Ruby that this record is not Array-like.
    def to_ary
      nil
    end

    # Internal: Memoization for a URITemplate instance
    def uri_template
      @uri_template ||= URITemplate.new(@link['href'])
    end
  end

  # Public: Exception that is raised when building a templated Link without uri
  # variables.
  class MissingURITemplateVariablesException < StandardError

    # Public: Returns a String with the exception message.
    def message
      "The URL to this links is templated, but no variables where given."
    end
  end
end
