
module Amz
    module Backend
        module Views
            class IndexAsUpload < ActiveAdmin::Views::IndexAsTable
        
                def build(page_presenter, collection)
                    table_options = {
                        id: "index_table_#{active_admin_config.resource_name.plural}",
                        "data-collection-path": collection_path , 
                        sortable: true,
                        class: "index_table index index_table_upload",
                        i18n: active_admin_config.resource_class,
                        paginator: page_presenter[:paginator] != false,
                        row_class: page_presenter[:row_class]
                    }
            
                    table_for collection, table_options do |t|
                        table_config_block = page_presenter.block || default_table
                        instance_exec(t, &table_config_block)
                    end
                end
        
                def self.index_name
                "table_upload"
                end
            end
        end
    end
end