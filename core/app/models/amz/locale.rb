module Amz
  class Locale < Amz::Base
    has_many :stores
    has_many :mailer_templates
    
    def native_shopping_ad?
      case self.code
      when 'en-US', 'en-CA', 'en-UK' , 'es-US'
        true
      else
        false
      end
    end
    
  end
end
