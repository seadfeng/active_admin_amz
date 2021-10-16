module Amz
    module Backend 
        class Engine < ::Rails::Engine  

            initializer "active_admin.load_app_path" do 
                app_admin = File.expand_path("../../../app/admin", __dir__)
                ActiveAdmin.application.load_paths += Dir[app_admin] 
            end 

            initializer "active_admin.load_ckeditor_path" do |app| 
                app.config.autoload_paths += %w(#{config.root}/app/models/ckeditor)
            end 

            # initializer "amz.application", before: :load_config_initializers do |app| 
            #     app.config.i18n.fallbacks[:en]
            # end

            initializer 'amz.assets.precompile', group: :all do |app|
              app.config.assets.precompile += %w[ ckeditor/config.js ]
              app.config.assets.precompile += %w[ ckeditor/application.css ]
              app.config.assets.precompile += %w[ ckeditor/application.js ]
            end

            initializer "active_admin.memu" do 
                ActiveAdmin.setup do |config|
                    config.namespace :admin do |admin|
                        admin.build_menu :default do |menu|
                            menu.add label: "Sidekiq", url: "/sidekiq", html_options: { target: :blank }  
                        end
                    end
                    config.default_per_page = [20, 50, 100] 
                end
            end 
            
            def self.activate
                Dir.glob(File.join(File.dirname(__FILE__), '../../../app/**/*_decorator*.rb')).each do |c|
                    Rails.configuration.cache_classes ? require(c) : load(c)
                end
            end
        
            config.to_prepare(&method(:activate).to_proc)
        end 
    end
end