ActiveAdmin.register Amz::Widget, as: "Widget" do
    init_controller
    belongs_to :store, optional: true   
    permit_params :store_id, :title, :description, :disabled_at, 
                  :resource_type, :component_type, :article_id, :cms_id, :block_id, :frontend_controller_id, :taxon_id
    menu priority: 30
    batch_action :destroy, false 
    
    begin
        Amz::FrontendController.all.each do |ctl|
            batch_action ctl.presentation do |ids| 
                i = 0
                batch_action_collection.find(ids).each do |source|   
                    i += 1  if ctl.widgets_controllers.create(widget_id: source.id  )
                end  
                options = { notice: I18n.t('active_admin.batch_action.succesfully_updated', count: i, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
                redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
            end
        end 
    rescue => exception 
        nil
    end
    

    active_admin_paranoia 
    
    scope :disabled
    scope :visible


    controller do 
        def update  
            update! do |format| 
                options = { notice: I18n.t('active_admin.successfully_updated', name: resource.name )} 
                format.html { redirect_to admin_widget_path(resource), options  }
            end 
        end   
    end 


    index do 
        selectable_column
        id_column   
        column :store   
        column :title  
        column :component_type
        column :resource_type 
        column :controllers
        tag_column :visible?
        actions
    end

    filter :title
    filter :store

    show do
        render 'admin/widgets/show'
    end  

    form do |f| 
        f.inputs I18n.t("active_admin.widgets.form" , default: "Widget")  do     
            f.input :store    
            f.input :title    
            f.input :description 
            f.input :component_type, as: :select,  collection: Amz::Widget::COMPONENT, input_html: { disabled: f.object.contents.any? , readonly:  f.object.contents.any? }  
            f.input :resource_type, as: :select,  collection: f.object.source_type , input_html: { disabled: f.object.contents.any? , readonly:  f.object.contents.any? } if !f.object.new_record?
            f.input :show_title 
            f.input :disabled_at , as: :date_time_picker   
        end
        f.actions
    end

end