class Amz::UserSessionsController < Devise::SessionsController
    helper 'amz/base'
  
    include Amz::Core::ControllerHelpers::Auth
    include Amz::Core::ControllerHelpers::Common 
    include Amz::Core::ControllerHelpers::Store 
    include Amz::Core::ControllerHelpers::AuthenticationHelpers
    include Amz::Core::ControllerHelpers::CurrentUserHelpers 

    def create  
        params[:amz_user][:store_id] = current_store.id 
        
        authenticate_amz_user!
        
        if amz_user_signed_in?
          respond_to do |format|
            format.html {
              flash[:success] = I18n.t('amz.logged_in_succesfully', default: 'Logged In Succesfully')
              redirect_back_or_default(after_sign_in_redirect(amz_current_user))
            }
            format.js {
              render json: { user: amz_current_user }.to_json
            }
          end
        else 
          respond_to do |format|
            format.html {
              flash[:error] = I18n.t('devise.failure.invalid')
              render :new
            }
            format.js {
              render json: { error: I18n.t('devise.failure.invalid') }, status: :unprocessable_entity
            }
          end
        end
    end

    protected

    def translation_scope
        'devise.user_sessions'
    end 
    
    private

    def accurate_title
        I18n.t('amz.login', default: 'Login')
    end

    def redirect_back_or_default(default)
        redirect_to(session["amz_user_return_to"] || default)
        session["amz_user_return_to"] = nil
    end

    def after_sign_in_redirect(resource_or_scope)
        stored_location_for(resource_or_scope) || account_path
    end

    def respond_to_on_destroy
        # We actually need to hardcode this as Rails default responder doesn't
        # support returning empty response on GET request
        respond_to do |format|
        format.all { head :no_content }
        format.any(*navigational_formats) { redirect_to after_sign_out_redirect(resource_name) }
        end
    end

    def after_sign_out_redirect(resource_or_scope)
        scope = Devise::Mapping.find_scope!(resource_or_scope)
        router_name = Devise.mappings[scope].router_name
        context = router_name ? send(router_name) : self
        context.respond_to?(:login_path) ? context.login_path : "/"
    end
end
