# Maintain your gem's version:
require "./core/lib/amz/core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "amz"
  spec.version     = Amz::VERSION
  spec.authors     = [""]
  spec.email       = ["seadfeng@gmail.com"]
  spec.homepage    = "https://gitlab.seadapp.com/amz/amz"
  spec.summary     = "Amazon Assoc"
  spec.description = "Amazon"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.require_path = 'lib'
  spec.requirements << 'none'

  spec.add_dependency "amz_core", spec.version  
  spec.add_dependency "amz_backend", spec.version  
  spec.add_dependency "amz_frontend", spec.version  
  spec.add_dependency "react-rails" 

end
