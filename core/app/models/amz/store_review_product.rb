module Amz
  class StoreReviewProduct < Amz::Base
 
    belongs_to :store_review, class_name: 'Amz::StoreReview', inverse_of: :store_review_products, touch: true 
    belongs_to :product , class_name: 'Amz::Product', inverse_of: :store_review_products, touch: true 

    with_options presence: true do   
      validates :score, numericality: { less_than_or_equal_to: 9.9, greater_than_or_equal_to: 7.0} 
    end  
    # validates_uniqueness_of :store_review_id, case_sensitive: true, allow_blank: false , scope: :product_id     

    before_validation :create_init, on: :create 
    before_validation :check_best_value  
    before_validation :check_default_best_value 
    
    delegate :store_review_products, :products, to: :store_review   
    delegate :store, :asin, :state, to: :product  
    
    attr_accessor :name

    def name
      product.name
    end

    def name=(data)
      product.name = data
      product.save
    end

    def create_init 
      self.score = rand_score  
    end

    def check_best_value
      if self.best_value && self.best_value_changed?
        store_review.store_review_products.where("id not in (?)", self.id).update_all(best_value: false)  
      end
    end

    def default_best_value
      store_review.store_review_products.where("id not in (?)", self.id).update_all(best_value: false)
      update_attribute(:best_value, true)
    end

    def products_count
      store_review.products.not_deleted.count
    end

    def check_default_best_value  
      store_review_product = store_review_products.first
      unless store_review_product.blank?
        if store_review_product.best_value
          store_review_product.update_attribute(:best_value, false)
        end 
        if products_count >= 9 && store_review_products.where(best_value: true).blank?
          rand_num = rand(1..3)
          store_review_products.each_with_index do |item,index|
            if index == rand_num
              item.update_attribute(:best_value, true)
            end
          end 
        end
      end
    end

    private
    

    def rand_score  
      count = store_review.store_review_products.count  
      case count 
      when 0
        rand(9.6..9.9)
      when 1
        rand(9.3..9.6)
      when 2
        rand(9.0..9.3)
      when 3
        rand(8.8..9.0)
      when 4
        rand(8.5..8.8)
      when 5
        rand(8.2..8.5)
      when 6
        rand(7.9..8.2)
      when 7
        rand(7.6..7.9)
      when 8
        rand(7.3..7.6)
      else
        rand(7.0..7.3)
      end 
    end

  end
end
