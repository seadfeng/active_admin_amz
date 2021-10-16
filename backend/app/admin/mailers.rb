 
ActiveAdmin.register Amz::Mailer,  as: "Mailer" do
    init_controller  
    belongs_to :store, optional: true
    menu priority: 100  
    permit_params :subject, :store_id, :body, :style, :available_on , :mailer_template_id
    # actions :all, except: [:show ] 
  
  
    controller do
      def create  
        create! do |format|
          options = { notice: I18n.t('active_admin.successfully_created', name: resource.subject )} 
          format.html { redirect_to edit_resource_path  }
        end 
      end
  
      def update 
        update! do |format|
            options = { notice: I18n.t('active_admin.successfully_updated', name: "#{resource.subject} ##{resource.id}" )} 
            format.html { redirect_to edit_resource_path   }
        end 
      end
  
      def show
        render "admin/mailers/show", layout: nil
      end
    end
  
  
    index do
      selectable_column
      id_column
      column :store
      column :subject 
      column :available_on
      column :completed_at
      column :created_at
      column :updated_at
      actions
    end
  
    filter :subject
    filter :store 
    filter :created_at
    filter :updated_at 
  
    form do |f|
      f.inputs I18n.t("active_admin.mailer.form" , default: "Mailer")  do  
        if f.object.new_record?
          f.input :store 
        end   
        f.input :subject 
        f.input :only_user
        f.input :body, as: :ckeditor , input_html: { ckeditor: { height: 600} }  
        f.input :style, as: :text 
        f.input :available_on, as: :date_time_picker 
      end
      f.actions
    end 
  
    sidebar :templates, only: :edit do 
      active_admin_form_for [:admin, resource ] do |f|     
        f.input :mailer_template_id,  as: :select,   collection:  MailerTemplate.where(locale_id: resource.store.locale.id ).map {|x| [x.subject, x.id]}  
                    # url:  admin_locale_mailer_templates_path(resource.store.locale), 
                    # fields: [:name, :code ],  
                    # minimum_input_length: 2    
        button t( 'active_admin.mailer.clone_template' , default: "Clone Template") , type: :submit   
      end 
    end
  
    sidebar :review_mailer, only: :edit do 
      h2 do
        link_to "Review (Must be saved)", admin_mailer_path(resource), target: "_blank"
      end
    end
  
  end 
      
  