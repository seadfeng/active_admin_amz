module Amz
    module AutoLinkHelper
        ActiveAdmin::ViewHelpers::AutoLinkHelper.module_eval do
            # def auto_link(resource, content = display_name(resource))
            #     auto_url = auto_url_for(resource) 
            #     if url = auto_url  
            #         link_to content, url
            #     else
            #         content
            #     end
            # end   
            # def auto_url_for(resource)
            #     config = active_admin_resource_for(resource.class) 
            #     return unless config
        
            #     if config.controller.action_methods.include?("show") &&
            #       authorized?(ActiveAdmin::Auth::READ, resource)
            #       url_for config.route_instance_path resource, url_options
            #     elsif config.controller.action_methods.include?("edit") &&
            #       authorized?(ActiveAdmin::Auth::UPDATE, resource)
            #       url_for config.route_edit_instance_path resource, url_options
            #     end
            # end
            # overwrite
            def active_admin_resource_for(klass)
                if respond_to? :active_admin_namespace 
                  klass = klass.to_s.gsub(/Amz::/,'').constantize.new.class
                  active_admin_namespace.resource_for klass
                end
            end
        end
    end
end