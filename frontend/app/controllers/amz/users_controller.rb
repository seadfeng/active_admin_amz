class Amz::UsersController < Amz::StoreController 
    prepend_before_action :load_object, only: [:show, :edit, :update, :profile ]
    prepend_before_action :authorize_actions, only: :new
   

    def show
        widgets = helpers.controller_widgets
        @controller_widgets = []
        unless widgets.blank?
          @controller_widgets = widgets.map {|val| [title: val.title, 
                                                    description: description(val), 
                                                    resources:  widget_resource(val)  , 
                                                    show_title: val.show_title, 
                                                    grid: val.preferred_grid , 
                                                    component_type: val.component_type , 
                                                    resource_type: val.resource_type]}
        end
    end

    def profile
        @user
    end
    
    def create
        @user = Amz.user_class.new(user_params)
        if @user.save  
            redirect_back_or_default(root_url)
        else
            render :new
        end
    end
    

    def update
        if params[:amz_user][:send_verification_email].present?
            messages = I18n.t('devise.confirmations.send_instructions')
            @user.send_confirmation_instructions
            respond_to do |format| 
                format.html { 
                  flash[:success] = messages
                  redirect_to amz.profile_url
                }
                format.js {
                  render json: { user: amz_current_user, messages: messages  }.to_json
                }
            end
        else
            if @user.update_with_password(user_params)
                if params[:amz_user][:password].present?
                    # this logic needed b/c devise wants to log us out after password changes
                    # if params[:amz_user][:reset_password_token].present?
                    #     Amz.user_class.reset_password_by_token(params[:amz_user]) 
                    # else
                    #     unless @user.reset_password(params[:amz_user][:password],params[:amz_user][:password_confirmation])
                    #         flash[:alert] = I18n.t('errors.messages.not_saved', resource: 'password' )
                    #     end
                    # end
                    if Amz::Auth::Config[:signout_after_password_change]
                        flash[:success] = I18n.t('devise.amz_user_registrations.updated_but_not_signed_in')
                        sign_in(@user, event: :authentication)
                    else
                        bypass_sign_in(@user)
                    end
                end
                redirect_to amz.profile_url
            elsif params[:amz_user][:subscription].present? 
                @user.update(user_params) 
                redirect_to amz.profile_url
            else
                flash[:error] = I18n.t('devise.errors.messages.current_password_is_incorrect')
                redirect_to amz.profile_url
            end 
        end

        
        
    end

    private

    def user_params 
        params[:amz_user][:store_id] = current_store.id
        params[:amz_user][:subscription] ||= false
        params.require(:amz_user).permit(Amz::PermittedAttributes.user_attributes)
    end

    def load_object
        @user ||= amz_current_user
        authorize! params[:action].to_sym, @user
    end

    def authorize_actions
        authorize! params[:action].to_sym, Amz.user_class.new
    end

    def accurate_title
        I18n.t('amz.my_account', default: 'My Account')
    end
end
