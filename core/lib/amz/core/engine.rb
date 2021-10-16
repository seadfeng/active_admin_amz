module Amz
  module Core
    class Engine < ::Rails::Engine
      Environment = Struct.new(
        :preferences,
        :dependencies
      )
      isolate_namespace Amz 
      engine_name 'amz'
 
      initializer 'amz.environment', before: :load_config_initializers do |app|
        app.config.amz = Environment.new( Amz::AppConfiguration.new, Amz::AppDependencies.new)
        Amz::Config = app.config.amz.preferences
        Amz::Dependencies = app.config.amz.dependencies
      end

      initializer "amz.active_storage" do |app|         
        app.config.active_storage.content_types_to_serve_as_binary.delete('image/svg+xml')
        app.config.active_storage.web_image_content_types = %w( image/png image/jpeg image/jpg image/gif image/webp)
        app.config.active_storage.variable_content_types = %w(
          image/png
          image/gif
          image/jpg
          image/jpeg
          image/pjpeg
          image/tiff
          image/bmp
          image/vnd.adobe.photoshop
          image/vnd.microsoft.icon
          image/webp
        )
    
    
      end    
      
      initializer "amz.active_job" do |app|     
        app.config.active_job.queue_adapter = :sidekiq
      end   


    end
  end
end
require 'amz/core/routes'
require 'amz/core/components'
