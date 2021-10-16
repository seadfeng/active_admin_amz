ActiveAdmin.register Amz::Block, as: "Block" do
    init_controller
    belongs_to :store, optional: true
    config.sort_order = 'id_desc'  
    permit_params  :store_id,  :name , :description, :published_at, :identity
    menu priority: 40, parent: "Cms"  
    actions :all, except: [ :show]    

    begin
        Amz::Widget.blocks.each do |widget|
            batch_action widget.name do |ids| 
                i = 0
                batch_action_collection.find(ids).each do |source|   
                    i += 1  if widget.contents.create(resource_id: source.id, resource_type: 'Amz::Block' )
                end  
                options = { notice: I18n.t('active_admin.batch_action.succesfully_updated', count: i, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
                redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
            end
        end  
    rescue => exception
        nil 
    end
    

    active_admin_paranoia 

    scope :published 
    scope :draft 

    index do
        selectable_column
        id_column   
        column :store  
        column :name 
        column :identity    
        column :published_at
        actions
    end

    show do
        panel t('active_admin.details', model: resource_class.to_s.titleize) do
            attributes_table_for resource do 
                row :store
                row :name 
                row :identity 
                tag_row :visible?
                row :description do |source|
                    source.description.html_safe
                end  
                row :published_at  
                row :updated_at 
                row :created_at   
            end
        end
    end

    form do |f|
        f.inputs I18n.t("active_admin.blocks.form" , default: "Block")  do  
            f.input :store
            f.input :name     
            f.input :identity     
            f.input :description , as: :ckeditor , input_html: { ckeditor: { height: 500, startupMode: 'source'  } }    
            f.input :published_at, as: :date_time_picker  
        end
        f.actions
    end 
end