module Amz
    class Product < Amz::Base
        module AmznSupport
            extend ActiveSupport::Concern
            included do  
                has_one  :amazon , autosave: true

                # before_validation :find_or_build_amazon 
                   
                delegate :asin_image, :scan_amazon, to: :amazon 

                accepts_nested_attributes_for :amazon  

                attr_accessor :asin, :amazon_reviews_scanned, :asin_image  

                def find_or_build_amazon
                    amazon || build_amazon
                end 
                
                def amazon_product_url
                    "#{store.url}/dp/#{amazon.asin}" if amazon
                end

                def amazon_name 
                    amazon.name  if amazon
                end  
                

                def asin
                    amazon.asin if amazon  
                end
        
                def asin=(data)  
                    return nil unless data.present?
                    find_or_build_amazon
                    amazon.asin = data
                end

                def asin_image 
                    amazon.asin_image if amazon  
                end
        
                def asin_image=(data) 
                    return nil unless data.present?  
                    find_or_build_amazon
                    move_to_draft if error?
                    amazon.asin_image = data
                end
        
                def amazon_reviews_scanned
                    amazon.reviews_scanned  if amazon 
                end
        
                def amazon_reviews_scanned=(data) 
                    return nil unless data.present?
                    find_or_build_amazon 
                    amazon.reviews_scanned = data
                end
            end
        end
    end
end