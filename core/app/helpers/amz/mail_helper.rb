module Amz
    module MailHelper
      include BaseHelper
      include ImageHelper 
      
      def name_for(user)
        user.full_name || I18n.t('amz.customer', default: 'Customer')
      end

    end
end
