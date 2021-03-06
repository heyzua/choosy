# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'choosy/version'
require 'rake'

Gem::Specification.new do |gem|
  gem.name           = 'choosy'
  gem.version        = Choosy::Version.load_from_lib.to_s
  gem.platform       = Gem::Platform::RUBY
  gem.summary        = 'Yet another option parsing library.'
  gem.description    = 'This is a DSL for creating more complicated command line tools.'
  gem.email          = ['madeonamac@gmail.com']
  gem.authors        = ['Gabe McArthur']
  gem.homepage       = 'http://github.com/gabemc/choosy'
  gem.files          = FileList["[A-Z]*", "{bin,lib,spec}/**/*"]
    
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'autotest'
  gem.add_development_dependency 'autotest-notification'
  gem.add_development_dependency 'ZenTest'
  gem.add_development_dependency 'cucumber'

  gem.required_rubygems_version = ">= 1.3.6"
  gem.require_path = 'lib'
end
