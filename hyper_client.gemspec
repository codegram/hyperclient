# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hyper_client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Oriol Gual"]
  gem.email         = ["oriol.gual@gmail.com"]
  gem.description   = %q{HyperClient is a Ruby Hypermedia API client.}
  gem.summary       = %q{}
  gem.homepage      = "http://codegram.github.com/hyper_client/"
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "hyper_client"
  gem.require_paths = ["lib"]
  gem.version       = HyperClient::VERSION

  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'turn'
  gem.add_development_dependency 'webmock'
end
