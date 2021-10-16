require 'rest-client'
module Amz
    module Core
        module Helpers
            class AmazonEuWidgets
                attr_reader :amazon, :amzn_assoc_host, :client, :response

                def initialize(amazon, amzn_assoc_host = "ws-eu.assoc-amazon.com")
                    @amazon = amazon
                    @amzn_assoc_host = amzn_assoc_host 
                end 

                def get_widget  
                    @client = rest_client(widgets_url)
                    processing_widget
                end

                private

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

                def widgets_url
                    url = "https://#{amzn_assoc_host}/widgets/cm?"
                    url += "lt1=_blank&bc1=000000"
                    url += "&IS2=1&bg1=FFFFFF&fc1=000000&lc1=0000FF"
                    url += "&t="
                    url += "&language=es_ES"
                    url += "&o=30&p=8&l=as4&m=amazon&f=ifr&ref=as_ss_li_til"
                    url += "&ref=as_ss_li_til&asins=#{asin}"
                end

                def processing_widget 
                    if client && client.code == 200
                        body = client.body 
                        match_info = body.scan(/<img[\s]*src="(.*?)"[\s]*id="prod-image"\/>[\S\s]*?<a rel="nofollow" id="titlehref".*?>([\s\S]*?)<\/a>[\S\s]*<span class="price".*?>(.*?)<\/span>/)
                        image,name,price = match_info[0]
                        asin_image = image.gsub!(/.*images\/I\/([^\.]*?)\..*/,"\\1") if image
                        price = price.gsub(/[^\d\.,]/,"").gsub(/(.*),(\d?\d?)/,"\\1.\\2").gsub(/,/,"") if price 
                        @response =  { num_reviews: nil, asin_image: asin_image, name: name, brand_name: nil, price_amount: price , list_price_amount: nil }
                    else
                        @response = nil
                    end
                end
                def asin
                    amazon.asin
                end

            end 
        end
    end
end