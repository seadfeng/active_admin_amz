require 'paapi'
module Amz
    class AmazonPaapi5Job < ApplicationJob
      queue_as :paapi
      sidekiq_options retry: 0
      attr_reader :asins

      # asins: ["B07ZY8SSZ3","B07V4L249J"]
      def perform(*options) 
        options = options.first || {}
        asins = options[:asins]   
        store = options[:store]   
        raise "asins can not blank" if asins.blank? 
        raise "store can not blank" if store.blank?
        logger = Logger.new(log_file) 
        begin 
            logger.info("//============= Paapi::Client.new")
            # store.cache_locale.code.gsub("-",'_')
            client = Paapi::Client.new( 
                                        access_key: store.amz_access, 
                                        secret_key: store.amz_secret, 
                                        market: :"#{store.market_place.downcase}", 
                                        languages_of_preference: store.cache_locale.code.gsub("-",'_'),
                                        partner_tag: store.amz_tag_id,
                                        resources: resources
                                    )
            gi = client.get_items( item_ids: asins )
            logger.info("Get Items: #{asins}")
            items_size = gi.items.size
            gi.items.each do |item|
              retries = 0
              begin
                features = item.get(%w{ItemInfo Features DisplayValues})&.sort&.join("\r\n")
                title = item.title 
                brand = item.brand
                asin_image = item&.image_url&.gsub(/.*\/images\/I\/(.*?)\..*/,'\1')
                amazon = Amz::Amazon.joins(:product).where("amz_products.store_id": store.id ).find_by_asin(item.asin)
                if amazon
                  logger.info("Amazon Id: #{amazon&.id}") 
                  product = amazon.product
                  if !product.locked
                    product.update_attributes( description: features ) if features
                    product.update_attributes( name: title  ) if title 
                    if brand
                      product.brand_name =  brand
                      product.save  
                    end
                    if features.blank?
                      logger.info("Features Blank!") 
                      logger.info("#{item.hash}") 
                    end
                    product.publish if product&.draft?
                  else
                    if amazon.name != title 
                      ActiveAdmin::Comment.create( 
                        resource_type: "Amz::Product", 
                        resource_id: product.id,
                        author_type: "AdminUser",
                        author_id: AdminUser.where(role: "admin")&.first&.id,
                        body: "Amazon产品标题变更,注意检查数据变动: \r\n 原:#{amazon.name} \r\n 新:#{title}",
                        namespace: "admin"
                     )
                    end
                    if amazon.asin_image != asin_image 
                      ActiveAdmin::Comment.create( 
                        resource_type: "Amz::Product", 
                        resource_id: product.id,
                        author_type: "AdminUser",
                        author_id: AdminUser.where(role: "admin")&.first&.id,
                        body: "Amazon图片变更,注意检查数据变动: \r\n #{amazon.asin_image} => #{asin_image}",
                        namespace: "admin"
                      )
                    end
                  end
                  amazon.name = title
                  amazon.asin_image = asin_image if asin_image
                  if amazon && item.listings 
                    prime = item.listings.select{ |list| list.prime_eligible? }.size > 0 
                    free_shipping = item.listings.select{ |list| list.free_shipping_eligible? }.size > 0    
                    amazon.prime = prime
                    amazon.free_shipping = free_shipping   
                  elsif amazon 
                    #Todo 
                    logger.info("Listing Blank!")
                    logger.info("#: #{amazon.id} -- Todo!")
                  end  
                  amazon.save  
                  logger.info("#: #{amazon.id} -- Save!") 
                  

                  if items_size != asins.size
                    asins = asins - [item.asin]
                  end
                end
              rescue  ActiveRecord::StatementInvalid => e
                if e.message =~ /Deadlock found when trying to get lock/
                  retries += 1   
                  if retries > 3  ## max 3 retries 
                    logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
                    logger.error(e.backtrace.join("\n"))
                  end
                    sleep 5
                  retry
                else
                  logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
                  logger.error(e.backtrace.join("\n"))
                end
              end

            end 

            if items_size != asins.size
              puts "discontinue_on #{asins}"
              # amazons = Amz::Amazon.where(asin: asins).update_attributes(discontinue_on: Time.current + 10.days ) 
            end
            logger.info("=============//")
        rescue Exception, ActiveJob::DeserializationError => e 
            puts "Error: #{e.message}" 
            logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
            logger.error(e.backtrace.join("\n"))
        end 
      end

      private 

      def resources
        [ 
            'Images.Primary.Large',
            'ItemInfo.Classifications', 
            'ItemInfo.ByLineInfo', 
            'ItemInfo.ContentInfo',
            'ItemInfo.ExternalIds',
            'ItemInfo.Features',
            'ItemInfo.ManufactureInfo',
            'ItemInfo.ProductInfo',
            'ItemInfo.TechnicalInfo', # Includes format when Kindle
            'ItemInfo.Title',
            'ItemInfo.TradeInInfo',
            'Offers.Listings.Availability.Message',
            'Offers.Listings.Condition',
            'Offers.Listings.Condition.SubCondition',
            'Offers.Listings.DeliveryInfo.IsAmazonFulfilled',
            'Offers.Listings.DeliveryInfo.IsFreeShippingEligible',
            'Offers.Listings.DeliveryInfo.IsPrimeEligible',
            'Offers.Listings.IsBuyBoxWinner',
            'Offers.Listings.LoyaltyPoints.Points',
            'Offers.Listings.Promotions',
            'Offers.Listings.MerchantInfo',
            'Offers.Listings.Price',
            'Offers.Listings.SavingBasis',
            'Offers.Summaries.HighestPrice',
            'Offers.Summaries.LowestPrice',
            'Offers.Summaries.OfferCount',
            'ParentASIN'
        ]
      end

      def log_file 
        File.open('log/amazon_paapi5_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end

    end
end