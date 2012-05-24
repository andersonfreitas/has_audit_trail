# -*- encoding: utf-8 -*-
require File.expand_path('../lib/has_audit_trail/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Anderson Freitas"]
  gem.email         = ["gems@andersonfreitas.com"]
  gem.description   = %q{Simple audit trail for Rails models}
  gem.summary       = gem.description
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "has_audit_trail"
  gem.require_paths = ["lib"]
  gem.version       = HasAuditTrail::VERSION

  gem.add_development_dependency 'activerecord', '~> 3.0'
  gem.add_development_dependency 'rails', '~> 3.0'
  gem.add_development_dependency 'rspec-rails', '~> 2.0'
  gem.add_development_dependency 'sqlite3', '~> 1.0' 

  gem.add_dependency('activemodel', '~> 3.0')
  gem.add_dependency('actionpack', '~> 3.0')
end
