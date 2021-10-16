module Amz
    module Backend
        module Views
            class IndexAsJstree < ActiveAdmin::Component 
                def build(page_presenter, collection) 
                    add_class "index"  
                    instance_exec(collection, &page_presenter.block) 
                end
        
                def self.index_name
                    "block"
                end
            end
        end
    end
end