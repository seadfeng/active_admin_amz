module Amz
  class Amazon < Amz::Base
    belongs_to :product, autosave: true, touch: true
    has_many  :prices, as: :resource, autosave: true
    has_many  :product_resources, as: :resource, autosave: true
    has_many  :releases, as: :logable, autosave: true

    before_validation :strip_asin  
    before_save :truncate_name  
    after_update :check_asin  

    # after_update :touch_product_scanned  
    after_create :scan_amazon 
 
    before_update :check_release
    after_create :touch_release
    
    # validates_uniqueness_of :asin, case_sensitive: true, allow_blank: true  

    delegate :market_place, :region, :store, to: :product  

    def truncate_name
      self.name = name.truncate(350) if name
    end

    def check_release
      touch_release if name_changed? || asin_image_changed?
    end

    def touch_release
      if releases.any?
        last = releases.last
        value = last.value + 0.001 
      else
        value = 0.001 
      end
      releases.create(name: name, value: value, image: self.asin_image  )  unless name.blank? 
    end

    def touch_product_scanned
      product.touch_scanned
    end

    def build_asin_image 
       if self.asin 
          send_job unless self.asin_image  
       end
    end   
 
    def scan_amazon
      if self.asin  
        send_job
      end
    end

    def discontinue!
      update_attribute(:discontinue_on, Time.current)
      product.discontinue!
    end

    def discontinued?
      discontinued_boole = !!discontinue_on && discontinue_on <= Time.current 
      discontinued_boole
    end  

    private

    def check_asin
      send_job if self.asin_changed? || self.asin_image.nil? 
    end 

    def strip_asin
        self.asin = self.asin.lstrip.rstrip if self.asin
    end

    def send_job 
      Amz::AmazonPaiJob.set(wait: 1 ).perform_later(self)
      # amzn_assoc_host = Amz::Config.amzn_assoc_host
      # Amz::AsinImageJob.perform_later(self, amzn_assoc_host)
    end 
 
  end
end
