class Amz::UserConfirmationsController < Devise::ConfirmationsController
    helper 'amz/base'
  
    include Amz::Core::ControllerHelpers::Auth
    include Amz::Core::ControllerHelpers::Common 
    include Amz::Core::ControllerHelpers::Store 
    include Amz::Core::ControllerHelpers::AuthenticationHelpers
    include Amz::Core::ControllerHelpers::CurrentUserHelpers

    rescue_from ActiveRecord::RecordNotUnique, with: :not_unique 
  
    # GET /resource/confirmation?confirmation_token=abcdef
    def show
       
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?
  
      if resource.errors.empty?
        set_flash_message!(:notice, :confirmed)
        respond_with_navigational(resource) do
          redirect_to after_confirmation_path_for(resource_name, resource)
        end
      elsif resource.confirmed?
        set_flash_message(:error, :already_confirmed)
        respond_with_navigational(resource) do
          redirect_to after_confirmation_path_for(resource_name, resource)
        end
      else
        respond_with_navigational(resource.errors, status: :unprocessable_entity) do
          render :new
        end
      end
    end 
  
    protected
  
    def after_confirmation_path_for(resource_name, resource)
      signed_in?(resource_name) ? signed_in_root_path(resource) : amz.login_path
    end
  
    def translation_scope
      'devise.confirmations'
    end

    private 

    def not_unique
      flash[:error] = I18n.t('devise.failure.email_already_exists', default: "Email already exists")
      redirect_to amz.profile_url 
    end

  end
