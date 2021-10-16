require 'amz/core/helpers/amazon_widgets'
require 'amz/core/helpers/amazon_eu_widgets'
module Amz
    class AmazonPaiJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 5
      attr_reader :amazon 

      def perform(amazon) 
        begin
            puts "Product Id: #{amazon.product.id}"
            puts "Locale Code: #{amazon.product.store.cache_locale.code}"
            case amazon.product.store.cache_locale.code
            when 'es-ES'
              pai = Amz::Core::Helpers::AmazonEuWidgets.new(amazon)
              pai.get_widget
              response = pai.response  
            when 'en-US', 'en-CA', 'en-UK' , 'es-US'
              pai = Amz::Core::Helpers::AmazonWidgets.new(amazon)
              pai.getad
              response = pai.response 
            else
              response = nil
            end  
            if response  
              if response[:name]
                if response[:brand_name]
                    product = amazon.product
                    if product.brand.blank?
                        product.brand_name = response[:brand_name] 
                        product.save
                    end
                end
                amazon.name = response[:name].truncate(250) if response[:name]
                amazon.asin_image = response[:asin_image] if response[:asin_image]
                amazon.reviews_scanned = response[:num_reviews] if response[:num_reviews] 
                if amazon.product.discontinue_on.nil?
                   if amazon.name && amazon.asin_image 
                    amazon.product.move_to_draft 
                   end
                else
                  amazon.product.discontinue_on = nil 
                end
                amazon.save
                puts "amazon.save"
              else
                puts "response[:name] = nil"
                 if amazon.product.published?
                  amazon.product.discontinue_on = Time.current + 5.days
                  amazon.save!
                 else
                  amazon.product.move_to_error
                 end
              end
            else
              puts "response = nil => amazon.product.move_to_error"
              amazon.product.move_to_error 
            end
        rescue Exception, ActiveJob::DeserializationError => e
            amazon.product.move_to_error
            puts "Error: #{e.message}"
            logger = Logger.new(log_file)
            logger.error("ASIN:#{amazon.asin} ================")
            logger.error(I18n.t('active_admin.active_job', message: e.message, default: "ActiveJob: #{e.message}"))
            logger.error(e.backtrace.join("\n"))
        end 
      end 

      private 

      def log_file
        # To create new (and to remove old) logfile, add File::CREAT like;
        #   file = open('foo.log', File::WRONLY | File::APPEND | File::CREAT)
        File.open('log/active_job.log', File::WRONLY | File::APPEND | File::CREAT)
      end
    end
end
