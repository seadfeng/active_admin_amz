module Amz
  class BaseMailer < Devise::Mailer
    add_template_helper(MailHelper)
    include ImageHelper
    include LiquidHelper
    default from:  ->{ from_address }
    default bcc:  ->{ mail_bcc }

    #reply_to

    helper_method :current_store
    helper_method :liquid_render
    helper_method :login_url
    helper_method :account_url 
    helper_method :signup_url  
    helper_method :frontend_available?  
    
    layout 'layouts/amz/base_mailer'

    def frontend_available?
      Amz::Core::Engine.frontend_available?
    end 

    def mail(headers = {}, &block) 
      
      mail_delivery_method 
      ensure_default_action_mailer_url_host 
      super if Amz::Config[:send_core_emails]
    end  

    def current_store    
      if params[:user] 
        params[:user].store 
      elsif params[:store]
        params[:store]
      else
        nil
      end
    end  

    private    

    def from_address   
      if current_store
        current_store.email_address_with_name
      end
    end

    def mail_bcc
      current_store.preferred_mail_bcc if current_store && current_store.has_mail_bcc?
    end

    def mail_delivery_method
      ActionMailer::Base.smtp_settings = current_store.mail_server_settings if current_store.has_smtp_settings?
    end

    def ensure_default_action_mailer_url_host
      ActionMailer::Base.default_url_options ||= {}
      ActionMailer::Base.default_url_options[:host] ||= current_store.domain
    end

    def login_url
      amz.login_url(host: ensure_default_action_mailer_url_host)
    end

    def account_url
      amz.account_url(host: ensure_default_action_mailer_url_host)
    end

    def signup_url
      amz.signup_url(host: ensure_default_action_mailer_url_host)
    end

    def recover_password_url
      amz.recover_password_url(host: ensure_default_action_mailer_url_host)
    end

    def confirm_url
      amz.confirm_url(host: ensure_default_action_mailer_url_host) 
    end 

    def unsubscribion_url(token)
      amz.unsubscribion_url(host: ensure_default_action_mailer_url_host, token: token ) 
    end
     
  end
end
