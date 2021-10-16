module Amz
  class Currency < Amz::Base
    has_many :stores

    with_options presence: true do 
      validates_uniqueness_of :code, case_sensitive: true, allow_blank: false  
      validates_uniqueness_of :name, case_sensitive: true, allow_blank: false  

      validates :unit, :precision, :name, :code
    end
  end
end
