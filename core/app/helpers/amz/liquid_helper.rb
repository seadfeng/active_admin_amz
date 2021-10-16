module Amz
    module LiquidHelper  

        def liquid_render( identity , *options ) 
            options = options.first || {}  
            variable = options[:variable] || {} 
            mailer = options[:mailer] || {} 
            if identity == "market_instructions"
                mail_template = mailer 
            else
                mail_template = Amz::MailerTemplate.find_by(identity: identity, locale: current_store.cache_locale) 
            end
            return nil if mail_template.blank? 
            
            body =  Liquid::Template.parse(mail_template.body)  
            subject =  Liquid::Template.parse(mail_template.subject)  
            data =  { subject: subject.render(variable),  body: body.render(variable) }
            data
        end 

        def store_variable  
            store = current_store
            store_name = store.name
            store_email = store.mail_from_address 
            store_url = Rails.application.config.force_ssl ? "https://#{store.domain}" : "http://#{store.domain}" 
            logo_url = product_url_image(store.logo)
            variable = {
              'store_name' => store_name,
              'store_email' => store_email,
              'store_url' => store_url,
              'logo_url' => logo_url,
              'login_url' => login_url,
              'account_url' => account_url
            }
            variable 
        end
     
        def user_variable(user) 
            variable = {
                'user' => user,
                'email' => user.email
            }
            store_variable.merge(variable)
        end
    
        def subscription_variable(subscription)
            variable = {
                'unsubscribion_url' => unsubscribion_url(subscription.unsubscribe_token)
            }
            store_variable.merge(variable)
        end 

        def confirmation_variable 
            variable = {
                'confirmation_url' => @confirmation_url
            } 
            store_variable.merge(variable)
        end  

        def reset_password_variable 
            variable = {
                'edit_password_reset_url' => @edit_password_reset_url
            }
            store_variable.merge(variable)
        end 
    end
end
