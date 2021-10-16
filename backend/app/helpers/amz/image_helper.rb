 
module Amz
  module ImageHelper  
    
      def self.included(base)
        # base.send(:include, Rails.application.routes.url_helpers)
        base.send(:include, Amz::Core::ControllerHelpers::Image )
        base.send(:include, InstanceMethods )
      end 

      module InstanceMethods   
        Amz::Image.styles.each do |style, v| 
            define_method "#{style.to_s}_image" do |object, *options|
              options = options.first || {}
              options[:alt] ||= object.try(:name) || object.try(:alt)
              options[:crop] ||=  defined?(current_store) ? current_store.preferred_amz_image_crop :  true
              options[:amp] ||= options[:amp].nil? ? true : options[:amp]
              options[:layout] ||= options[:layout].nil? ? "responsive" : options[:layout]
              options[:media] ||= options[:media].nil? ? nil : options[:media]

              if object && (object.is_a?(Product) || object.is_a?(Amz::Product)) && !object.asin_image.blank?  
                create_product_image_tag(object, options, style) 
              elsif object && (object.is_a?(StoreReview) || object.is_a?(Amz::StoreReview))  
                create_product_image_tag(object.products.published&.first, options, style)
              elsif object && (object.is_a?(Amazon) || object.is_a?(Amz::Amazon)) 
                create_amz_image_tag(object, options, style) 
              elsif object && (object.is_a?(Image) || object.is_a?(Amz::Image) || object.is_a?(Logo) || object.is_a?(Amz::Logo) ) && object.attachment.attached? 
                if object.analyzed?
                  box = object.box(style)
                  options[:width] = box[:width]
                  options[:height] = box[:height]
                end
                if defined?(is_amp?) && is_amp? && options[:amp]
                  if style.to_s == "wide"
                    srcset = { medium: '430x430>', large:   '600x600>', wide:   '1280x1280>' }.map{ |sty, val|  main_app.url_for(object.url(sty)) + " #{val.sub(/x.*/,'')}w" }.join(",\r\n")
                    content_tag(:"amp-img", "", media: options[:media], srcset: srcset, src: main_app.url_for(object.url(style)), width: options[:width], height: options[:height], alt: options[:alt], class: "layout-#{options[:layout]} #{options[:class]}" , layout: options[:layout]  )
                  else
                    content_tag(:"amp-img", "", media: options[:media], src: main_app.url_for(object.url(style)), width: options[:width], height: options[:height], alt: options[:alt], class: "layout-#{options[:layout]} #{options[:class]}" , layout: options[:layout]  )
                  end
                else
                  image_tag main_app.url_for(object.url(style)), options&.except(:amp)&.except(:crop)&.except(:layout)
                end
              else
                if defined?(is_amp?) && is_amp? && options[:amp]
                  content_tag(:"amp-img", "", media: options[:media], src: ActionController::Base.helpers.asset_path( "amz/noimage/#{style}.png" ), width: options[:width], height: options[:height], alt: options[:alt], class: "layout-#{options[:layout]} #{options[:class]}" , layout: options[:layout]   )
                else 
                  image_tag "amz/noimage/#{style}.png", options&.except(:amp)&.except(:crop)&.except(:layout)
                end
              end
            end
            define_method "#{style.to_s}_url_image" do |object, *options|
              options = options.first || {}
              options[:alt] ||= object.try(:name) || object.try(:alt)
              options[:crop] ||=  defined?(options[:crop]) ? options[:crop] : (defined?(current_store) ? current_store.preferred_amz_image_crop  : true) 
              if object && (object.is_a?(Product) || object.is_a?(Amz::Product)) && !object.asin_image.blank?  
                # main_app.url_for(amazon_asin_image(object.asin_image,v, options[:crop]) )  
                product_image_url(object.master, style: style, crop: options[:crop] )
              elsif object && (object.is_a?(StoreReview) || object.is_a?(Amz::StoreReview))  
                product_image_url(object.products.published&.first&.master, style: style , crop: options[:crop])
              elsif object && (object.is_a?(Amazon) || object.is_a?(Amz::Amazon)) 
                product_image_url(object, style: style , crop: options[:crop])
              elsif object && (object.is_a?(Image) || object.is_a?(Amz::Image) || object.is_a?(Logo) || object.is_a?(Amz::Logo) ) && object.attachment.attached? 
                main_app.url_for(object.url(style)) 
              else
                asset_path( "amz/noimage/#{style}.png" )
              end
            end
        end 
      end
      
  end
end

