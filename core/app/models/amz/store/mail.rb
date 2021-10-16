module Amz
    class Store < Amz::Base
        module Mail
            extend ActiveSupport::Concern
            included do
                MAIL_AUTH = %w(None plain login cram_md5).freeze
                SECURE_CONNECTION_TYPES = %w(None SSL TLS).freeze  
                preference :domian_smtp, :string, default: 'smtp.mandrillapp.com' 
                preference :service_smtp, :string, default: 'smtp.mandrillapp.com' 
                preference :smtp_port, :string, default: '587' 
                preference :smtp_auth_type, :string, default: 'login'  
                preference :secure_connection_type, :string, default: 'TLS'  
                preference :smtp_username, :string, default: '' 
                preference :smtp_password, :string, default: ''
                preference :mail_bcc, :string, default: ''
                preference :enable_mailer , :boolean, default: true  
                preference :send_per_queue, :integer, default: 20

                def has_smtp_settings? 
                    preferred_enable_mailer
                end

                def has_mail_bcc? 
                    !preferred_mail_bcc.blank?
                end
              
                def mail_server_settings
                    settings = if need_authentication?
                                  basic_settings.merge(user_credentials)
                                else
                                  basic_settings
                                end
                    if secure_connection?
                      settings[:enable_starttls_auto] = true
                      settings[:tls] = true 
                    end

                    settings
                end
                private 

                def user_credentials
                  {
                    user_name: preferred_smtp_username,
                    password: preferred_smtp_password
                  }
                end
            
                def basic_settings
                  {
                    address: preferred_service_smtp,
                    port: preferred_smtp_port,
                    domain: preferred_domian_smtp, 
                    authentication: preferred_smtp_auth_type
                  }
                end
            
                def need_authentication?
                  preferred_smtp_auth_type != 'None'
                end
            
                def secure_connection?
                  preferred_secure_connection_type == 'TLS'
                end 
                
            end
        end
    end
end
