require 'json'

module OxfordExample
  # A read-only HAL demo, independent of Oxford's retired API.
  class App
    def initialize
      @places = JSON.parse(File.read(File.join(__dir__, 'places.json')))
    end

    def call(env)
      return response(405, { 'error' => 'Read-only example' }) unless %w[GET HEAD].include?(env['REQUEST_METHOD'])

      status, body = representation(env['PATH_INFO'])
      result = response(status, body)
      result[2] = [] if env['REQUEST_METHOD'] == 'HEAD'
      result
    end

    private

    def representation(path)
      case path
      when '/'
        [200, {
          '_links' => {
            'self' => { 'href' => '/' },
            'places' => { 'href' => '/places/' },
            'place' => { 'href' => '/places/{id}', 'templated' => true },
            'curies' => [{ 'name' => 'oxford', 'href' => '/docs/{rel}', 'templated' => true }],
            'oxford:places' => { 'href' => '/places/' }
          }
        }]
      when '/places/'
        [200, { '_links' => { 'self' => { 'href' => '/places/' } },
                '_embedded' => { 'places' => @places } }]
      when '/docs/places'
        [200, { 'description' => 'Archived Oxford place facts in a local HAL collection.' }]
      else
        place = @places.find { |item| item['_links']['self']['href'] == path }
        place ? [200, place] : [404, { 'error' => 'Not included in this example' }]
      end
    end

    def response(status, body)
      [status, { 'content-type' => 'application/hal+json' }, [JSON.generate(body)]]
    end
  end
end
