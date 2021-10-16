if defined?(ActiveAdmin) && defined?(AdminUser)
  ActiveAdmin.register AdminUser do
    init_controller
    begin
      role_changeable
    rescue => exception
        nil
    end
    
    permit_params :email, :password, :password_confirmation, :first_name, :last_name, :time_zone, :attachment, :content

    controller do
      def update  
        if params[:admin_user][:password].blank?
          params[:admin_user][:password] = resource.password
          params[:admin_user][:password_confirmation] = resource.password
        end
        update! do |format|
          options = { notice: I18n.t('active_admin.successfully_updated', name: resource.full_name )} 
          format.html { redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options))   }
        end  
      end
    end
  
    index do
      selectable_column
      id_column
      column :full_name
      column :email
      column :current_sign_in_at
      column :sign_in_count
      column :created_at
      actions
    end
  
    filter :email
    filter :current_sign_in_at
    filter :sign_in_count
    filter :created_at
  
    form do |f|
      f.inputs do
        f.input :email
        f.input :first_name
        f.input :last_name 
        f.input :content, as: :ckeditor , input_html: { ckeditor: { height: 300} }  
        f.input :attachment, as: :file, :hint => mini_image(f.object.image ) 
        f.input :time_zone , label: I18n.t('amz.time_zone', default: "Time Zone") , as: :select, collection: TZInfo::Timezone.all_country_zone_identifiers
        f.input :password
        f.input :password_confirmation 
      end
      f.actions
    end
  
  end
end
  
