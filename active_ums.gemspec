# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_ums/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_ums'
  spec.version       = ActiveUMS::VERSION
  spec.authors       = ['droptheplot']
  spec.email         = ['novikov359@gmail.com']

  spec.summary       = 'ActiveResource for UMS.'
  spec.homepage      = 'https://github.com/InspireNL/ActiveUMS'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'awesome_print', '~> 1.7'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'webmock', '~> 2.3'
  spec.add_development_dependency 'pry-byebug', '~> 3.4'
  spec.add_development_dependency 'kaminari', '~> 0.17'

  spec.add_dependency 'activemodel', '>= 4.2'
  spec.add_dependency 'activesupport', '>= 4.2'
  spec.add_dependency 'rest-client', '~> 2.0'
end
