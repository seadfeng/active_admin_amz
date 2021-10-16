class Amz::UserRegistrationsController < Devise::RegistrationsController
    helper 'amz/base'
  
    include Amz::Core::ControllerHelpers::Auth
    include Amz::Core::ControllerHelpers::Common 
    include Amz::Core::ControllerHelpers::Store 
    include Amz::Core::ControllerHelpers::AuthenticationHelpers
    include Amz::Core::ControllerHelpers::CurrentUserHelpers

    before_action :check_permissions, only: [:edit, :update]
    skip_before_action :require_no_authentication

    # GET /resource/sign_up
    def new
        if amz_user_signed_in?
            redirect_to amz_account_path 
        else
            super
            @user = resource
        end
    end

    # POST /resource/sign_up
    def create
        @user = build_resource(amz_user_params)
        resource_saved = resource.save
        yield resource if block_given?
        if resource_saved
            # Amz::UserMailer.with(user: @user).welcome_email.deliver_later
            # @user.send_confirmation_instructions
            if resource.active_for_authentication?
                set_flash_message :notice, :signed_up
                sign_up(resource_name, resource)
                session[:amz_user_signup] = true
                redirect_to_account_path(resource)
            else
                set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
                expire_data_after_sign_in!
                respond_with resource, location: after_inactive_sign_up_path_for(resource)
            end
        else
            clean_up_passwords(resource)
            render :new
        end
    end

    # GET /resource/edit
    def edit
        super
    end

    # PUT /resource
    def update
        super
    end

    # DELETE /resource
    def destroy
        super
    end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    def cancel
        super
    end   

    protected

    def check_permissions
        authorize!(:create, resource)
    end

    def translation_scope
        'devise.user_registrations'
    end

    def after_sign_up_path_for(resource)
        after_sign_in_redirect(resource) if is_navigational_format?
    end

    def after_inactive_sign_up_path_for(resource)
        scope = Devise::Mapping.find_scope!(resource)
        router_name = Devise.mappings[scope].router_name
        context = router_name ? send(router_name) : self
        context.respond_to?(:login_path) ? context.login_path : "/login"
    end

    private

    def amz_user_params
        params[:amz_user][:store_id] = current_store.id
        params.require(:amz_user).permit(Amz::PermittedAttributes.user_attributes)
    end

    def after_sign_in_redirect(resource_or_scope)
        stored_location_for(resource_or_scope) || account_path
    end

    def redirect_to_account_path(resource)
        resource_path = after_sign_up_path_for(resource) 
        respond_with resource, location: amz.account_path
    end
end
