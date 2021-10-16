module Amz
    class UserMailer < Amz::BaseMailer  
        default to: ->{ to_address } 

        def welcome_email
            return nil  unless current_user  
            mailer_render = liquid_render('welcome_email', variable: user_variable(current_user) ) 
            subject = ''
            if mailer_render
                subject = mailer_render[:subject] 
                @body = mailer_render[:body] 
            else
                subject = I18n.t('amz.welcome_email', store_name: current_store.name , default: "Welcome to %{store_name}")
            end 
            mail  subject: subject 
        end 

        def reset_password_instructions(user, token, *_args)  
            Amz::WithMailer.with(user: user).reset_password_instructions(user, token, _args).deliver_now
        end 
        
        def confirmation_instructions(user, token, _opts = {}) 
            Amz::WithMailer.with(user: user).confirmation_instructions(user, token, _opts).deliver_now
        end   
 
        private  

        def to_address
            current_user.email
        end

        def current_user
            params[:user]
        end

    end
end
