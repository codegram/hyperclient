# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hyperclient/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Oriol Gual']
  gem.email         = ['oriol.gual@gmail.com']
  gem.description   = 'HyperClient is a Ruby Hypermedia API client.'
  gem.summary       = ''
  gem.homepage      = 'http://codegram.github.com/hyperclient/'
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'hyperclient'
  gem.require_paths = ['lib']
  gem.version       = Hyperclient::VERSION

  gem.add_dependency 'faraday'
  gem.add_dependency 'futuroscope'
  gem.add_dependency 'faraday_middleware'
  gem.add_dependency 'faraday_hal_middleware'
  gem.add_dependency 'uri_template'
  gem.add_dependency 'net-http-digest_auth'
  gem.add_dependency 'faraday-digestauth'
end
