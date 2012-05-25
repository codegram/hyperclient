module Hyperclient
  class Response
    def initialize(response)
      @response = response
    end

    def resources
      unless defined?(@resources)
        @resources = extract_resources_from('_links').merge(extract_resources_from('_embedded'))
      end
      @resources
    end

    def data
      @response.delete_if {|key, value| key =~ /^_/}
    end

    def url
      @response['_links']['self']['href']
    end

    private
    # Bonus points for refactoring this
    def extract_resources_from(selector)
      return {} if !@response || !@response.include?(selector)

      @response[selector].inject({}) do |resources, (name, response)|

        unless name == 'self'
          resource = if response.is_a?(Array)
                       response.map do |element|

                         if element.include?('href')
                           element = build_self_link_response(element['href'])
                         end

                         Resource.new(element)
                       end
                     else
                       if response.include?('href')
                         response = build_self_link_response(response['href'])
                       end
                       Resource.new(response)
                     end

          resources.update(name => resource)
        end
      resources
      end
    end

    def build_self_link_response(link)
      {'_links' => {'self' => {'href' => link}} }
    end
  end
end
