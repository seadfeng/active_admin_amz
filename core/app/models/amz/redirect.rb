module Amz
  class Redirect < Amz::Base
    belongs_to :store
    belongs_to :resource, polymorphic: true 

    before_save :set_viewed 
    validates_uniqueness_of :store, case_sensitive: false, allow_blank: false , scope: :resource     

    def set_viewed
      product = resource.product 
      product.viewed += 1 
      product.save
    end 

    def viewed!
      self.viewed += 1
      self.save
    end

  end
end
