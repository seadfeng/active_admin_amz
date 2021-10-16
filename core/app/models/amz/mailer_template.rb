module Amz
  class MailerTemplate < Amz::Base 
    belongs_to :locale
    acts_as_paranoid

    with_options presence: true do 
      validates :subject, :identity  , :locale
    end
    validates_uniqueness_of :identity, case_sensitive: true, allow_blank: false, scope: [:locale]  
    
    
  end
end
