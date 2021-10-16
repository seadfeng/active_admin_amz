class Amz::UserPasswordsController < Devise::PasswordsController
    helper 'amz/base'
  
    include Amz::Core::ControllerHelpers::Auth
    include Amz::Core::ControllerHelpers::Common 
    include Amz::Core::ControllerHelpers::Store 
    include Amz::Core::ControllerHelpers::AuthenticationHelpers
    include Amz::Core::ControllerHelpers::CurrentUserHelpers

    
    def create
      params[:amz_user][:store_id] = current_store.id
      self.resource = resource_class.send_reset_password_instructions(resource_params) 
      if resource.errors.empty?
        set_flash_message(:notice, :send_instructions) if is_navigational_format?
        respond_with resource, location: amz.login_path
      else
        respond_with_navigational(resource) { render :new }
      end
    end

    # Devise::PasswordsController allows for blank passwords.
    # Silly Devise::PasswordsController! 
    def update
      if params[:amz_user][:password].blank?
        self.resource = resource_class.new
        resource.reset_password_token = params[:amz_user][:reset_password_token]
        set_flash_message(:error, :cannot_be_blank)
        render :edit
      else
        super
      end
    end

    protected

    def translation_scope
        'devise.user_passwords'
    end

    def new_session_path(resource_name)
        amz.send("new_#{resource_name}_session_path")
    end

end
