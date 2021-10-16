module Amz
    class SubscriptionMailer < Amz::BaseMailer 
        default to: ->{ to_address }  

        def notification_instructions
            @email = to_address
            @unsubscribion_url = unsubscribion_url( current_subscription.unsubscribe_token)
            subscription_variable = subscription_variable(current_subscription).merge( { "email" => @email , "usesr" => current_user })
            mailer_render = liquid_render('subscription_instructions', variable: subscription_variable ) 
            
            if mailer_render 
                subject = mailer_render[:subject] 
                @body =  mailer_render[:body]
            else
                subject = I18n.t('amz.mailer.subscription_title', defautl: "Thanks for your subscription")
            end
            mail subject: subject 
        end

        def market_instructions
            @email = to_address
            @unsubscribion_url = unsubscribion_url( current_subscription.unsubscribe_token)
            subscription_variable = subscription_variable(current_subscription).merge( { "email" => @email , "usesr" => current_user })
            mailer_render = liquid_render('market_instructions', variable: subscription_variable, mailer: mailer_log.mailer ) 
             
            subject = mailer_render[:subject] 
            @body =  mailer_render[:body] 

            if mail subject: subject 
                mailer_log.sended!
            end
        end

        private  

        def current_store  
            current_subscription.store if current_subscription.present?
        end

        def to_address
            current_subscription.email
        end

        def current_subscription 
            params[:subscription] 
        end

        def mailer_log
            params[:mailer_log]  
        end

        def current_user
            current_subscription.user if current_subscription.present?
        end

    end
end
