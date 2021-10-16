module Amz
    module Backend
        module Tab
            module DSL
                def tabs( name,  models = {} ) 
                    options = Array(models[:models])
                    sidebar name, except: [:index, :new, :edit ]  do
                        ul do
                            li do
                                link_to I18n.t('active_admin.details', model: resource_class.to_s.titleize), resource_path(resource), class:  (action_name == "show") ? "active member_link item_show" : "member_link item_show"
                            end
                            options.each do |model|
                                source = model.to_s.camelize.singularize.constantize
                                if defined?(source)
                                    li do
                                        link_to source.model_name, "#{resource_path(resource)}/#{model}" , class:  (action_name == model.to_s) ? "active member_link item_#{model}" : "member_link item-#{model}"    
                                    end
                                end
                            end
                        end
                    end
                    models[:models].each do |model|
                        source = model.to_s.camelize.singularize.constantize
                        if defined?(source)
                            controller do
                                resource_class.to_s.camelize.singularize.constantize.class_eval do
                                    def tab(m)
                                        eval(m.to_s.pluralize)
                                    end
                                end
                            end
                            member_action model, method: :get, if: proc{ authorized?(ActiveAdmin::Auth::READ, resource_class) }  do 
                                 @source = resource.tab(model)
                                 @collection_data = @source.page(params[:page]) 
                                 @collection_count = @source.count
                                 begin
                                    render "admin/#{resource_class.to_s.downcase.pluralize}/#{model}"
                                 rescue
                                    render "admin/tabs/index" , collection_data: @collection_data , collection_count: @collection_count
                                 end  
                            end 

                            action_name = "new_#{model.to_s.downcase.singularize}"
                            member_action action_name, method: :get, model_name: model, if: proc{ authorized?(ActiveAdmin::Auth::CREATE, resource_class) }  do
                                @source = model.to_s.camelize.singularize.constantize.new  
                                @id = "#{resource_class.to_s.downcase.singularize}_id"
                                eval("@source.#{@id} = resource.id") 
                                begin 
                                    render "admin/#{resource_class.to_s.downcase.pluralize}/#{action_name}"
                                 rescue
                                    render "admin/tabs/new"  
                                 end  
                            end

                            action_item action_name, only: model, if: proc{ authorized?(ActiveAdmin::Auth::CREATE, resource_class) } do
                                link_to(I18n.t('active_admin.new_model', model: model.to_s.downcase.titleize), "#{resource_path(resource)}/#{action_name}", method: :get) if authorized?(ActiveAdmin::Auth::CREATE, resource)  
                            end
                    
                        end
                    end 
                end
            end
        end
    end
end
::ActiveAdmin::DSL.send(:include, Amz::Backend::Tab::DSL)