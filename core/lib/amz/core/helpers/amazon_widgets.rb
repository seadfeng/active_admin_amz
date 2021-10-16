require 'rest-client'
module Amz
    module Core
      module Helpers
        class AmazonWidgets
            attr_reader :amazon, :amzn_assoc_host, :client, :response, :store

            def initialize(amazon, amzn_assoc_host = "z-na.amazon-adsystem.com")
                @amazon = amazon
                @store = amazon.product.store
                @amzn_assoc_host = amzn_assoc_host 
            end

            def getad 
                @client = rest_client(getad_url) 
                processing_getad
            end

            def get_widget 
                @client = rest_client(widgets_url)
                processing_widget
            end

            def get_image
                @client = rest_client(image_url)
                processing_image
            end

            private

            def processing_widget 
                if client && client.code == 200
                    body = client.body 
                    # match_info = body.scan(/<img[\s]*src="(.*?)"[\s]*id="prod-image"\/>[\S\s]*?encodehtml\("(.*?)"\)[\S\s]*<span class="price".*?>(.*?)<\/span>/)
                    match_info = body.scan(/<img[\s]*src="(.*?)"[\s]*id="prod-image"\/>[\S\s]*?<a rel="nofollow" id="titlehref".*?>([\s\S]*?)<\/a>[\S\s]*<span class="price".*?>(.*?)<\/span>/)
                    if !match_info[0].nil?
                        image,name,price = match_info[0]
                        image = image.first.gsub(/.*images\/I\/([^\.]*?)\..*/,"\\1") if image.first
                        price = price.first.gsub(/[^\d\.]/,"") if price.first
                        name = name.first  if name.first
                        @response = {name: name, asin_image: image, new_price: price}
                    else
                        @response = nil
                    end
                else
                    @response = nil
                end
            end

            def processing_image
                if client && client.code == 200 && client.headers[:edge_cache_tag]
                    edge_cache_tag = client.headers[:edge_cache_tag]
                    asin_image = edge_cache_tag.gsub(/.*\/([^\\]*)$/,"\\1")  
                    @response = { asin_image: asin_image }
                else
                    @response = nil
                end
            end

            def processing_getad
                if client && client.code == 200 
                    body = client.body 
                    name =  body.scan(/.*\%22title\%22\%3A\%22(.*?)\%22.*/)&.first 
                    brand_name =  body.scan(/.*22brand%22\%3A\%22(.*?)\%22.*/)&.first 
                    asin_image =  body.scan(/.*images\%2FI\%2F(.*?)\..*/)&.first 
                    num_reviews = body.scan(/.*22numReviews\%22\%3A(\d*)\%.*/)&.first  
                    price_amount = body.scan(/.*22priceAmount\%22\%3A\%7B\%22value\%22\%3A([\d\.]*)\%.*/)&.first  
                    list_price_amount = body.scan(/.*22listPriceAmount\%22\%3A\%7B\%22value\%22\%3A(.*?)\%.*/)&.first  
                    
                    return @response = nil if name.nil? 

                    if name.first
                        name = URI::decode(name.first.gsub(/\+/," ")) 
                    else
                        name = nil
                    end

                    if brand_name.first
                        brand_name = URI::decode(brand_name.first.gsub(/\+/," ")) 
                    else
                        brand_name = nil
                    end

                    # asin_image = asin_image.first.gsub(/\%252/,"\%2") if asin_image&.first
                    if asin_image&.first
                        asin_image = URI::decode(asin_image.first) 
                    else
                        asin_image = nil
                    end

                    if num_reviews&.first 
                        num_reviews = num_reviews.first 
                    else
                        num_reviews = 0
                    end
                    if price_amount&.first
                        price_amount = price_amount.first 
                    else
                        price_amount = nil
                    end
                    if list_price_amount&.first
                        list_price_amount = list_price_amount.first 
                    else
                        list_price_amount = nil
                    end
                    @response =  { num_reviews: num_reviews, asin_image: asin_image, name: name, brand_name: brand_name, price_amount: price_amount, list_price_amount: list_price_amount }
                else
                    @response = nil
                end
            end

            def rest_client(request_url) 
                begin
                  RestClient.get request_url
                rescue RestClient::ExceptionWithResponse  => e
                    case err.http_code 
                    when 301, 302, 307 
                      err.response.follow_redirection
                    else 
                      raise
                    end
                end
            end

            def apiVersion
                "2.0"
            end

            def service_version
                "20070822"
            end 

            def amzn_getad_assoc_host
                "aax-us-east.amazon-adsystem.com"
            end

            def market_place
                amazon.market_place
            end

            def asin
                amazon.asin
            end

            def region
                amazon.region
            end

            def image_url
                url = "https://#{amzn_assoc_host}/widgets/q?_encoding=UTF8"
                url += "&Format=_SL10_"
                url += "&WS=1&ID=AsinImage"
                url += "&ServiceVersion=#{service_version}" 
                url += "&ASIN=#{asin}"
                url += "&MarketPlace=#{market_place}" 
            end

            def widgets_url
                url = "https://#{amzn_assoc_host}/widgets/q?"
                url += "ServiceVersion=#{service_version}"
                url += "&OneJS=1"
                url += "&Operation=GetAdHtml"
                url += "&source=ss"
                url += "&ref=as_ss_li_til" 
                url += "&ad_type=product_link"  
                url += "&tracking_id="  
                url += "&marketplace=amazon"   
                url += "&placement=#{asin}"   
                url += "&asins=#{asin}"    
                url += "&region=#{region}"    
                url += "&MarketPlace=#{market_place}"
            end
            
            def getad_url
                language = @store.cache_locale.code.gsub("-",'_')
                #http://aax-us-east.amazon-adsystem.com/x/getad?src=330&c=100&sz=1x1&apiVersion=2.0&pj=%7B%22placement%22%3A%22adunit%22%2C%22tracking_id%22%3A%22%22%2C%22ad_mode%22%3A%22manual%22%2C%22ad_type%22%3A%22smart%22%2C%22marketplace%22%3A%22amazon%22%2C%22region%22%3A%22US%22%2C%22linkid%22%3A%22B07FMPVBQR%22%2C%22design%22%3A%22enhanced_links%22%2C%22asins%22%3A%22B07FMPVBQR%22%2C%22viewerCountry%22%3A%22CN%22%2C%22textlinks%22%3A%22%22%2C%22debug%22%3A%22false%22%2C%22acap_publisherId%22%3A%22%22%2C%22slotNum%22%3A0%2C%22ead%22%3A1%7D&u=http%3A%2F%2Flocalhost%3A3000%2Fadmin%2Fproducts%2F2&jscb=amzn_assoc_jsonp_callback_adunit_0
                url = "https://#{amzn_getad_assoc_host}/x/getad?src=330&c=100&sz=1x1"
                url += "&apiVersion=#{apiVersion}"
                url += "&pj=%7B" 
                url += "%22placement%22%3A%22adunit%22%2C" #adunit0, adunit
                url += "%22linkid%22%3A%22#{asin}%22%2C" 
                url += "%22tracking_id%22%3A%22%22%2C" 
                url += "%22language%22%3A%22#{language}%22%2C"  #language
                url += "%22ad_mode%22%3A%22manual%22%2C" 
                url += "%22ad_type%22%3A%22smart%22%2C" 
                url += "%22marketplace%22%3A%22amazon%22%2C" 
                url += "%22region%22%3A%22#{market_place}%22%2C" 
                url += "%22design%22%3A%22enhanced_links%22%2C"  
                url += "%22asins%22%3A%22#{asin}%22%2C"  
                url += "%22viewerCountry%22%3A%22CN%22%2C"  
                url += "%22textlinks%22%3A%22%22%2C"  
                url += "%22debug%22%3A%22false%22%2C"  
                url += "%22acap_publisherId%22%3A%22%22%2C"  
                url += "%22slotNum%22%3A0%2C"  
                url += "%22ead%22%3A1"   
                url += "%7D"
                # url += "&u=http%3A%2F%2Flocalhost%3A3000" 
                url += "&jscb=amzn_assoc_jsonp_callback_adunit_0" 
            end

        end
      end
    end
end
