module Amz
  class Ebay < Amz::Base
    belongs_to :product
    has_many  :prices, as: :resource, autosave: true
    
    has_many  :releases, as: :logable, autosave: true

    before_validation :strip_epid
    before_save :truncate_name  

    delegate :market_place, :region, :store, to: :product


    def truncate_name
      self.name = name.truncate(350) if name
    end

    def scan
      if self.epid  
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

    def strip_epid
      self.epid_image = self.epid_image.lstrip.rstrip if self.epid_image
      self.epid = self.epid.lstrip.rstrip if self.epid
    end

    def send_job 
      Amz::EbayJob.perform_later(self) 
    end 

  end
end
