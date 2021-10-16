module Amz
    module Core
      module ControllerHelpers
        module Store
          extend ActiveSupport::Concern
  
          included do
            helper_method :current_currency
            helper_method :current_store
            helper_method :current_price_options 
          end
  
          def current_currency
            current_store.currency
          end

          def current_locale
            current_store.cache_locale || config_locale
          end
  
          def current_store
            @current_store ||= Amz::Store.current(request.env['SERVER_NAME'])
          end   
        end
      end
    end
  end