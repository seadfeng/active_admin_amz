module Amz
    module Backend
        module FriendlyId
            module DSL
                def active_admin_friendly_id
                    controller do
                        def find_resource
                            # source = resource_class.to_s.camelize.constantize
                            source = scoped_collection
                            if defined?(FriendlyId) 
                                source.where(slug: params[:id]).first!
                            else
                                source.where(id: params[:id]).first!
                            end
                        end
                    end 
                end
            end
        end
    end
end
::ActiveAdmin::DSL.send(:include, Amz::Backend::FriendlyId::DSL)