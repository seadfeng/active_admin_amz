module Amz
    class WithMailer < Amz::BaseMailer 
        default template_path: 'amz/user_mailer'
        
        def reset_password_instructions(user, token, *_args)  
            @edit_password_reset_url = amz.edit_amz_user_password_url(reset_password_token: token, host: current_store.domain)  
            mailer_render = liquid_render('reset_password', variable: reset_password_variable ) 
            if mailer_render 
                subject = mailer_render[:subject] 
                @body =  mailer_render[:body]
            else
                subject = current_store.name + ' ' + I18n.t(:subject, scope: [:devise, :mailer, :reset_password_instructions])
            end
            mail to: user.email, subject: subject 
        end
    
        def confirmation_instructions(user, token, _opts = {})  
            @confirmation_url = amz.amz_user_confirmation_url(confirmation_token: token, host: current_store.domain)
            @email ||= user.unconfirmed_email || user.email  
            user_variable = user_variable(user).merge(confirmation_variable).merge( { "email" => @email  })
            mailer_render = liquid_render('confirmation_instructions', variable: user_variable ) 
            
            if mailer_render 
                subject = mailer_render[:subject] 
                @body =  mailer_render[:body]
            else
                subject = current_store.name + ' ' + I18n.t(:subject, scope: [:devise, :mailer, :confirmation_instructions])
            end
            mail to: @email, subject: subject 
        end  
    end
end
