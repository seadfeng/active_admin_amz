# Maintain your gem's version:
require_relative '../core/lib/amz/core/version'

Gem::Specification.new do |spec|
  spec.name          = "amz_backend"
  spec.version       = Amz::VERSION
  spec.authors     = ["Sead Feng"]
  spec.email       = ["seadfeng@gmail.com"]
  spec.homepage    = "https://gitlab.seadapp.com/amz/amz"
  spec.summary     = "Amazon Assoc"
  spec.description = "Amazon"
  spec.license     = "MIT"

  
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.require_path = 'lib'
  spec.requirements << 'none'

  spec.add_dependency "amz_core", spec.version 
  spec.add_dependency "activeadmin"
  spec.add_dependency "activeadmin_addons" 

  spec.add_dependency 'activerecord-import', '~> 0.27'
  # spec.add_dependency 'activerecord-import' 
  spec.add_dependency "rchardet"
  
  spec.add_dependency "active_admin_role"
  spec.add_dependency "devise"  
  spec.add_dependency "draper" 
  spec.add_dependency "pundit"  
  spec.add_dependency "ckeditor"
  spec.add_dependency "chartkick"
  spec.add_dependency "groupdate" 

  spec.add_dependency "enumerize", '~> 2.3.1'   
end
