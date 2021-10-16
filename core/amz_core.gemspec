# encoding: UTF-8
require_relative 'lib/amz/core/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "amz_core"
  spec.version     = Amz::VERSION
  spec.authors     = [""]
  spec.email       = ["seadfeng@gmail.com"]
  spec.homepage    = "https://gitlab.seadapp.com/amz/amz"
  spec.summary     = "Amazon Assoc"
  spec.description = "Amazon"
  spec.license     = "MIT"
 
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.require_path = 'lib'

  spec.add_dependency "rails", "~> 6.0.1" 
  spec.add_dependency "ransack"
  spec.add_dependency "kaminari" 
  spec.add_dependency "paranoia" 
  spec.add_dependency "devise-encryptable" 
  
  spec.add_dependency "mini_magick"  
  spec.add_dependency "state_machine"
  spec.add_dependency "acts_as_list" 
  spec.add_dependency 'awesome_nested_set', '>= 3.1.4', '< 3.3.0'
  spec.add_dependency "friendly_id", '~> 5.2.4'
  spec.add_dependency "stringex"  
  spec.add_dependency "ckeditor"
  spec.add_dependency "thinking-sphinx", '~> 4.4'
  spec.add_dependency 'cancancan' 
  spec.add_dependency 'liquid' 
  spec.add_dependency 'mail'  
  spec.add_dependency 'paapi'  

  
  spec.add_dependency "rest-client"
  spec.add_dependency "sidekiq", "~> 6.0.3" 
  spec.add_dependency "rack", ">= 2.0.6" , '<= 2.0.8'
  # spec.add_dependency "rack", ">= 2.0.8"

  spec.add_development_dependency "sqlite3"
end
