module Amz
    module Core
        module ControllerHelpers
            module Auth
                extend ActiveSupport::Concern
                include Amz::Core::TokenGenerator
                included do
                    before_action :set_token
                    helper_method :try_amz_current_user 
                    helper_method :current_ability 
        
                    rescue_from CanCan::AccessDenied do |_exception|
                        redirect_unauthorized_access
                    end
                end

                def current_ability
                    @current_ability ||= Amz::Dependencies.ability_class.constantize.new(try_amz_current_user)
                end

                def redirect_back_or_default(default)
                    redirect_to(session['amz_user_return_to'] || request.env['HTTP_REFERER'] || default)
                    session['amz_user_return_to'] = nil
                end

                def set_token
                    cookies.permanent.signed[:token] ||= cookies.signed[:guest_token]
                    cookies.permanent.signed[:token] ||= {
                      value: generate_token,
                      httponly: true
                    }
                    cookies.permanent.signed[:guest_token] ||= cookies.permanent.signed[:token]
                end  

                def store_location
                    # disallow return to login, logout, signup pages
                    authentication_routes = [:amz_signup_path, :amz_login_path, :amz_logout_path]
                    disallowed_urls = []
                    authentication_routes.each do |route|
                      disallowed_urls << send(route) if respond_to?(route)
                    end
          
                    disallowed_urls.map! { |url| url[/\/\w+$/] }
                    unless disallowed_urls.include?(request.fullpath)
                      session['amz_user_return_to'] = request.fullpath.gsub('//', '/')
                    end
                end

                def try_amz_current_user
                    # This one will be defined by apps looking to hook into Amz
                    # As per authentication_helpers.rb
                    if respond_to?(:current_amz_user)
                        current_amz_user
                    # This one will be defined by Devise
                    elsif respond_to?(:amz_current_user)
                        amz_current_user
                    end
                end

                def redirect_unauthorized_access
                    if try_amz_current_user
                      flash[:error] = I18n.t('amz.authorization_failure', default: 'Authorization Failure')
                      redirect_to amz.forbidden_path
                    else
                      store_location
                      if respond_to?(:amz_login_path)
                        redirect_to amz_login_path
                      elsif amz.respond_to?(:root_path)
                        redirect_to amz.root_path
                      else
                        redirect_to main_app.respond_to?(:root_path) ? main_app.root_path : '/'
                      end
                    end
                end 
          

            end
        end
    end
end
