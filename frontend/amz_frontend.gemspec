

# Maintain your gem's version:
require_relative '../core/lib/amz/core/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "amz_frontend"
  spec.version     = Amz::VERSION
  spec.authors     = ["Sead Feng"]
  spec.email       = ["seadfeng@gmail.com"]
  spec.homepage    = "https://gitlab.seadapp.com/amz/amz"
  spec.summary     = "Amazon Assoc"
  spec.description = "Amazon"
  spec.license     = "MIT"

  
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.require_path = 'lib'
  spec.requirements << 'none'

  # spec.add_dependency "amz_core", spec.version 
  spec.add_dependency "rails", "~> 6.0.1" 
  spec.add_dependency "react-rails"
  spec.add_dependency "webpacker"
  spec.add_dependency "canonical-rails" 
  spec.add_dependency "browser" 
  spec.add_dependency "flag-icons-rails"    
  
end
