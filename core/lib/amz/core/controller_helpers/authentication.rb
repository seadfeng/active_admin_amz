module Amz
    module Core
        module ControllerHelpers
            module CurrentUserHelpers
                def self.included(receiver)
                    receiver.send :helper_method, :amz_current_user  
                end
            
                def amz_current_user
                    current_amz_user
                end  
            end
  
            module AuthenticationHelpers
                def self.included(receiver)
                    receiver.send :helper_method, :amz_login_path
                    receiver.send :helper_method, :amz_signup_path
                    receiver.send :helper_method, :amz_logout_path
                    receiver.send :helper_method, :amz_recover_password_path
                    receiver.send :helper_method, :amz_edit_password_path
                    receiver.send :helper_method, :amz_account_path  
                end
            
                def amz_login_path
                    amz.login_path
                end
            
                def amz_signup_path
                    amz.signup_path
                end
            
                def amz_logout_path
                    amz.logout_path
                end

                def amz_account_path
                    amz.account_path
                end

                def amz_recover_password_path
                    amz.recover_password_path
                end

                def amz_edit_password_path
                    amz.edit_password_path
                end
            end
        end
    end 
end
  
# ApplicationController.include Amz::Core::ControllerHelpers::AuthenticationHelpers
# ApplicationController.include Amz::Core::ControllerHelpers::CurrentUserHelpers 
