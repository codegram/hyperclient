require File.expand_path('lib/hyperclient/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors       = ['Oriol Gual']
  gem.email         = ['oriol.gual@gmail.com']
  gem.description   = 'Hyperclient is a Ruby Hypermedia API client.'
  gem.summary       = ''
  gem.homepage      = 'https://github.com/codegram/hyperclient/'
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'hyperclient'
  gem.require_paths = ['lib']
  gem.version       = Hyperclient::VERSION

  gem.add_runtime_dependency "sorbet-runtime"

  gem.add_dependency 'addressable'
  gem.add_dependency 'faraday', '>= 0.9.0'
  gem.add_dependency 'faraday-digestauth'
  gem.add_dependency 'faraday_hal_middleware'
  gem.add_dependency 'faraday_middleware'
  gem.add_dependency 'net-http-digest_auth'
end
