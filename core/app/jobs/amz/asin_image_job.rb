module Amz
  class AsinImageJob < AmazonPaiJob   

    def perform(amazon, amzn_assoc_host) 
      @amazon = amazon
      @market_place = amazon.market_place
      @amzn_assoc_host = amzn_assoc_host
      @client = rest_client 
      if client && client.code == 200 && client.headers[:edge_cache_tag]
        edge_cache_tag = client.headers[:edge_cache_tag]
        asin_image = edge_cache_tag.gsub(/.*\/([^\\]*)$/,"\\1") 
        amazon.asin_image = asin_image 
        amazon.save!
      end
    end

    private

    def request_url
      url = "https://#{amzn_assoc_host}/widgets/q?_encoding=UTF8"
      url += "&Format=_SL10_"
      url += "&WS=1&ID=AsinImage"
      url += "&ServiceVersion=#{service_version}" 
      url += "&ASIN=#{amazon.asin}"
      url += "&MarketPlace=#{market_place}" 
    end

  end
end
