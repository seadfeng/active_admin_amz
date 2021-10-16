module Amz
    class Product < Amz::Base
        module EbaySupport
            extend ActiveSupport::Concern
            included do 
                has_one  :ebay, autosave: true 

                accepts_nested_attributes_for :ebay  

                attr_accessor :ebay_reviews_scanned, :ebay_barcode, :ebay_epid_image, :ebay_epid 

                def find_or_build_ebay
                    ebay || build_ebay
                end

                def ebay_product_url
                    "#{store.preferred_ebay_origin}/itm/#{ebay.epid}" if ebay
                end

                def ebay_barcode
                    ebay.barcode if ebay
                end

                def ebay_epid
                    ebay.epid if ebay
                end

                def ebay_epid=(data) 
                    return nil unless data.present?
                    find_or_build_ebay
                    ebay.epid = data
                end

                def ebay_epid_image
                    ebay.epid_image if ebay
                end
                
                def ebay_epid_image=(data) 
                    return nil unless data.present?
                    find_or_build_ebay
                    ebay.epid_image = data
                end

                def ebay_barcode=(data) 
                    return nil unless data.present?
                    find_or_build_ebay
                    ebay.barcode = data
                end

                def ebay_reviews_scanned
                    ebay.reviews_scanned if ebay
                end

                def ebay_reviews_scanned=(data) 
                    return nil unless data.present?
                    find_or_build_ebay
                    ebay.reviews_scanned = data
                end
            end
        end
    end
end