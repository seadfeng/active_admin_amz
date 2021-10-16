ActiveAdmin.register Amz::Search, as: "Search"  do 
    init_controller
    belongs_to :store, optional: true 
    permit_params  :name , :redirect_url, :store_id   
    menu priority: 10  

    scope :all   
    scope :has_results, default: true
    scope :no_results

    filter :id 
    filter :store   
    filter :name   
    filter :disabled   
    filter :results   
    filter :redirect_url 

    active_admin_import validate: true,   
                        template_object: ActiveAdminImport::Model.new(
                            hint: I18n.t("active_admin_import.search.import.hint" , default: "CSV Header: \"Store\",\"Name\",\"Redirect Url\"<br>Store查询商店Code设置, Redirect Url(选填) 是搜索关键词跳转链接"),
                        ),
                        headers_rewrites: {  
                            :'Store' => :store_id, 
                            :'Name' => :name,  
                            :'Redirect Url' => :redirect_url,
                        },
                        before_batch_import: ->(importer) {
                            store_codes = importer.values_at(:store_id)
                            unless store_codes.first.blank?     
                                store   = Store.where(code: store_codes).pluck(:code, :id)  
                                store_options = Hash[*store.flatten]
                                importer.batch_replace(:store_id, store_options)
                            end  
                            importer.batch_slice_columns(Amz::Search.column_names) 
                        },
                        after_batch_import: ->(importer) {   
                            history = true 
                            store_ids = importer.values_at(:store_id, history) 
                            redirect_urls = importer.values_at(:redirect_url, history)  
                            names = importer.values_at(:name, history)   
                            redirect_urls.each_with_index do |value,index|
                                store_id = store_ids[index]  
                                name = names[index]  
                                store   = Store.find_by(id: store_id) 
                                return nil if store.blank?
                                search = store.searches.find_by(name: name ) 
                                search.redirect_url = value if value && !search.blank?
                                search.save
                            end
                        }

    index do 
		selectable_column
        id_column   
        column :store 
        column :name 
        column :results 
        column :used  
        column :redirect_url 
        column :disabled
        actions
    end

    form do |f|
        f.inputs I18n.t("active_admin.cms.form" , default: "Cms")  do  
            f.input :store
            f.input :name , input_html: { disabled: (f.object.new_record? ? false : true) }
            f.input :redirect_url  
        end
        f.actions
    end 
 
    # # BOF batch_action
    batch_action :get_results  do |ids|
        batch_action_collection.find(ids).each do |source|  
        source.get_results!
        end
        options = { notice: t('active_admin.batch_actions.succesfully_updated', count: ids.count, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end

    batch_action :disabled  do |ids|
        batch_action_collection.find(ids).each do |source|  
            source.disabled = 1
            source.save
        end
        options = { notice: t('active_admin.batch_actions.succesfully_updated', count: ids.count, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end

    batch_action :enabled  do |ids|
        batch_action_collection.find(ids).each do |source|  
            source.disabled = 0
            source.save
        end
        options = { notice: t('active_admin.batch_actions.succesfully_updated', count: ids.count, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end

end
