 
ActiveAdmin.register Amz::MailerTemplate,  as: "MailerTemplate" do
    init_controller 
    active_admin_paranoia 
    belongs_to :locale, optional: true
    actions :all, except: [:show ] 
    menu priority: 50, parent: "Mailers" 
    
    permit_params :subject, :locale_id, :body, :style, :identity

    controller do 
      def update 
          update! do |format|
              options = { notice: I18n.t('active_admin.successfully_updated', name: "#{resource.subject} ##{resource.id}" )} 
              format.html { redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options))   }
          end 
      end

    end

    index do
      selectable_column
      id_column
      column :locale
      column :subject   
      column :created_at
      column :updated_at
      actions
    end

    filter :subject
    filter :locale 
    filter :created_at
    filter :updated_at 

    form do |f|
        f.inputs I18n.t("active_admin.mailer.form" , default: "Mailer")  do  
          f.input :locale  
          f.input :subject 
          f.input :identity 
          f.input :body, as: :ckeditor , input_html: { ckeditor: { height: 600} }
          f.input :style, as: :text 
        end
        f.actions
    end 

end 
    
