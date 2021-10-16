require 'rails/generators'

# require 'amz/core'

module Amz
    module Generators
        class InstallGenerator < Rails::Generators::Base 
            source_root File.expand_path("../templates", __dir__)

            def add_stylesheets
                file_path = 'app/assets/stylesheets/active_admin' 
                begin
                  append_file("#{file_path}.scss", css_assets)
                rescue
                  append_file("#{file_path}.css.scss", css_assets)
                end
            end

            def add_javascripts
                file_path = 'app/assets/javascripts/active_admin'
                append_file("#{file_path}.js", js_assets)
            end 
            
            def copy_initializer_file
                template "initializer.tt", "config/initializers/amz.rb"
                template "sidekiq.tt", "config/initializers/sidekiq.rb"
                template "sidekiq.yml", "config/sidekiq.yml"
                template "thinking_sphinx.yml", "config/thinking_sphinx.yml" 
            end 

            def install_active_admin_role 
                run 'rails g active_admin_role:install' 
            end  

            def add_friendly_id
                run 'bundle exec rails g friendly_id' 
            end

            def install_activeadmin_addons
                run 'rails active_storage:install' 
                run 'rails g activeadmin_addons:install' 
            end 

            def install_ckeditor
                run 'rails generate ckeditor:install'
                run 'rails action_text:install'
            end 

            def add_migrations
                run 'bundle exec rake railties:install:migrations FROM=amz' 
            end  

            # def install_action_text
            #     run 'rails action_text:install'
            # end   

            def notify_about_routes
                insert_into_file(File.join('config', 'routes.rb'),
                                 after: "Rails.application.routes.draw do\n") do
                  <<-ROUTES.strip_heredoc.indent!(2)
                    # This line mounts Am z's routes at the root of your application.
                    # This means, any requests to URLs such as /products, will go to
                    # Amz::ProductsController.
                    # If you would like to change where this engine is mounted, simply change the
                    # :at option to something different.
                    #
                    # We ask that you don't use the :as option here, as Amz relies on it being
                    # the default of "spree".
                    mount Amz::Core::Engine, at: '/'
                  ROUTES
                end
          
                unless options[:quiet]
                  puts '*' * 50
                  puts "We added the following line to your application's config/routes.rb file:"
                  puts ' '
                  puts "    mount Amz::Core::Engine, at: '/'"
                end
            end 

            def copy_views
                directory 'models/ckeditor', './app/models/ckeditor'
            end

            def ck_js
                insert_into_file(File.join('config/initializers', 'active_admin.rb'), after: "ActiveAdmin.setup do |config|\n") do
                    <<-EOF
                        config.register_javascript '//cdn.ckeditor.com/4.11.3/standard/ckeditor.js'
                        config.register_javascript 'chartkick'
                        config.register_javascript 'Chart.bundle'
                        config.favicon = 'amz/favicon.ico'
                        config.site_title_image = 'amz/logo.png'
                    EOF
                end  
            end 
            
            def install_js_packages
                packages = "jstree @babel/core @babel/preset-env"
                packages += " daemonite-material" 
                packages += " chartkick"
                packages += " chart.js" 
                packages += " pickadate"     
                run "yarn add #{packages}" 
            end 

            def webpaker_init
                path = File.expand_path("../templates", __dir__)
                insert_into_file(File.join('config', 'webpacker.yml'), after: "resolved_paths: [") do
                    <<-EOF
                    '#{path}/../../../../app/javascript',
                    EOF
                end
            end
            

            private

            def js_assets  
                to_add = "//= require active_admin/amz\n"    
            end

            def coffee_assets
                to_add = "#= require active_admin/amz\n"  
            end

            def css_assets 
                "@import 'active_admin/amz';\n" 
            end
            
        end
    end 
end