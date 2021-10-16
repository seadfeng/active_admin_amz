module Amz
  class Brand < Amz::Base
    has_many :products
    with_options presence: true do  
      validates :name 
    end 
    validates_uniqueness_of :name, case_sensitive: true, allow_blank: false 

    before_validation :trim

    private

    def trim
      self.name = name.lstrip.rstrip if name
    end
    
  end
end
