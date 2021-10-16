module Amz
    module Core
      module ControllerHelpers
        module Image  
          
          private
          
          def media_amazon
            "https://m.media-amazon.com"
            #Todo https://images-eu.ssl-images-amazon.com
          end

          def media_ebay
            "https://i.ebayimg.com" 
          end

          def media_format(size, crop = true)
            if crop
              "_AC_SL#{size.to_i}_" #SL,UL  AC = Cut
            else
              "UL#{size.to_i}_"
            end
          end  

          def ebay_media_format(size)
            "s-l#{size.to_i}"
          end
      
          def asin_image(asin_image,sizes, crop = true)
            size = sizes.gsub(/x.*/,"")
            "#{media_amazon}/images/I/#{asin_image}.#{media_format(size, crop)}.jpg"
          end

          def ebay_epid_image(epid_image,sizes)
            size = sizes.gsub(/x.*/,"")
            "#{media_ebay}/images/g/#{epid_image}/#{ebay_media_format(size)}.jpg"
          end 
      
          def create_product_image_tag( object, options, style ) 
            options[:alt] ||= object.try(:name) || object.try(:alt)  
            crop = options[:crop]  
            options[:amp] ||= options[:amp].nil? ? true : options[:amp]
            options[:layout] ||= options[:layout].nil? ? "responsive" : options[:layout]
            options[:media] ||= options[:media].nil? ? nil : options[:media]
            
            box = Amz::Image.styles[:"#{style}"].sub(/>/,'').split('x').map{ |x| x.to_i } 
            options[:width] = box[0]
            options[:height] = box[1]
            if defined?(is_amp?) && is_amp?  && options[:amp]
              # srcset = { medium: '430x430>', large:   '600x600>', wide:   '1280x1280>' }.map{ |sty, val|  product_image_url(object.master, style: sty, crop: crop) + " #{val.sub(/x.*/,'')}w" }.join(",\r\n")
              content_tag(:"amp-img", "", media: options[:media], src: product_image_url(object.master, style: style, crop: crop), width: options[:width], height: options[:height], layout: options[:layout] , alt: options[:alt], class: "layout-#{options[:layout]} #{options[:class]}" )
            else
              image_tag product_image_url(object.master, style: style, crop: crop), options&.except(:amp)&.except(:crop)&.except(:layout) 
            end
          end

          def create_amz_image_tag( object, options, style ) 
            options[:alt] ||= object.try(:name) || object.try(:alt)  
            crop = options[:crop] 
            image_tag product_image_url(object, style: style, crop:  crop), options&.except(:amp)&.except(:crop)&.except(:layout)
          end

          def product_image_url(object, *options)
            options = options.first || {}
            style = options[:style] || {}
            sizes = options[:sizes] || Amz::Image.styles[:"#{style}"] || {}
            crop = options[:crop]  
            if object.is_a?(Amazon) 
              if object.asin_image
                url = asin_image(object.asin_image, sizes, crop)
              else 
                url = "amz/noimage/#{style}.png"
              end
            else
              url =  ebay_epid_image(object.epid_image, sizes)
            end
            main_app.url_for(url)
          end

          def image_resize(object, *options) 
            options = options.first || {}
            sizes = options[:sizes]
            url = ''
            # options[:alt] ||= object.try(:name)
            if object && (object.is_a?(Product) || object.is_a?(Amz::Product)) && !object.asin_image.blank?  
              # url = main_app.url_for(amazon_asin_image( object.asin_image, sizes  ))
              url = product_image_url(object.master, sizes: sizes )
            elsif object && (object.is_a?(StoreReview) || object.is_a?(Amz::StoreReview))  
              url = product_image_url(object.products.published&.first&.master, sizes: sizes )
            elsif object && (object.is_a?(Amazon) || object.is_a?(Amz::Amazon)) 
              url = product_image_url(object, sizes: sizes )
            elsif object && (object.is_a?(Image) || object.is_a?(Amz::Image) || object.is_a?(Logo) || object.is_a?(Amz::Logo)) && object.attachment.attached?
              if object.attachment.content_type == "image/svg+xml" 
                url = main_app.rails_blob_path(object.attachment, only_path: true)
              else 
                url = main_app.url_for(object.resize(sizes)) 
              end
            else
              url = ActionController::Base.helpers.asset_path("amz/noimage/mini.png") 
            end 
            
            if options[:tag]
              image_tag url 
            else
              url
            end
          end    
      
          def define_image_method(style)
            self.class.send :define_method, "#{style}_image" do |object, *options| 
              options = options.first || {}
              options[:alt] ||= object.try(:name)
              options[:crop] ||=  defined?(current_store) ? current_store.preferred_amz_image_crop  : true
              options[:amp] ||= options[:amp].nil? ? true : options[:amp]
              options[:layout] ||= options[:layout].nil? ? "responsive" : options[:layout]
              options[:media] ||= options[:media].nil? ? nil : options[:media]

              if object && (object.is_a?(Product) || object.is_a?(Amz::Product)) && !object.asin_image.blank?  
                create_product_image_tag(object, options, style) 
              elsif object && (object.is_a?(StoreReview) || object.is_a?(Amz::StoreReview))  
                create_product_image_tag(object.products.published&.first, style: style )
              elsif object && (object.is_a?(Amazon) || object.is_a?(Amz::Amazon)) 
                create_amz_image_tag(object, options, style) 
              elsif object && (object.is_a?(Image) || object.is_a?(Amz::Image) || object.is_a?(Logo) || object.is_a?(Amz::Logo)  ) && object.attachment.attached? 
                if object.analyzed?
                  box = object.box(style)
                  options[:width] = box[:width]
                  options[:height] = box[:height]
                end
                if defined?(is_amp?) && is_amp? && options[:amp] 
                  if style.to_s == "wide"
                    srcset = { medium: '430x430>', large:   '600x600>', wide:   '1280x1280>' }.map{ |sty, val|  url_for(object.url(sty)) + " #{val.sub(/x.*/,'')}w" }.join(",\r\n")
                    content_tag(:"amp-img", "", media: options[:media], srcset: srcset,src: url_for(object.url(style)), width: options[:width], height: options[:height], alt: options[:alt], class: "layout-#{options[:layout]} #{options[:class]}"  , layout: options[:layout] )
                  else
                    content_tag(:"amp-img", "", media: options[:media], src: url_for(object.url(style)), width: options[:width], height: options[:height], alt: options[:alt], class: "layout-#{options[:layout]} #{options[:class]}"  , layout: options[:layout] )
                  end
                else
                  image_tag url_for(object.url(style)), options&.except(:amp)&.except(:crop)&.except(:layout)
                end
              else
                if defined?(is_amp?) && is_amp? && options[:amp] 
                  content_tag(:"amp-img", "", media: options[:media], src: ActionController::Base.helpers.asset_path( "amz/noimage/#{style}.png" ), width: options[:width], height: options[:height], alt: options[:alt], class: "layout-#{options[:layout]} #{options[:class]}" , layout: options[:layout]    )
                else
                  image_tag "amz/noimage/#{style}.png", options&.except(:amp)&.except(:crop)&.except(:layout)
                end
              end
            end
            self.class.send :define_method, "#{style}_url_image" do |object, *options|
              options = options.first || {} 
              options[:crop] ||=  defined?(options[:crop]) ? options[:crop] : (defined?(current_store) ? current_store.preferred_amz_image_crop  : true)

              if object && (object.is_a?(Product) || object.is_a?(Amz::Product)) && !object.asin_image.blank?  
                # main_app.url_for(amazon_asin_image(object.asin_image, Amz::Image.styles[:"#{style}"], options[:crop]))
                product_image_url(object.master, style: style, crop: options[:crop] )
              elsif object && (object.is_a?(Amazon) || object.is_a?(Amz::Amazon)) 
                product_image_url(object, style: style, crop: options[:crop]  )
              elsif object && (object.is_a?(StoreReview) || object.is_a?(Amz::StoreReview))  
                product_image_url(object.products.published&.first&.master, style: style, crop: options[:crop]  )
              elsif object && (object.is_a?(Image) || object.is_a?(Amz::Image) || object.is_a?(Logo) || object.is_a?(Amz::Logo)) && object.attachment.attached?
                main_app.url_for(object.url(style)) 
              else
                ActionController::Base.helpers.asset_path("amz/noimage/#{style}.png") 
              end
            end
          end 

          def define_image_resize_method(sizes)
            self.class.send :define_method, "image_resize_#{sizes}" do |object, *options| 
              options = options.first || {}
              options[:sizes] = sizes
              image_resize(object, options )
            end
          end 

      
          def method_missing(method_name, *args, &block)
            if image_style = image_style_from_method_name(method_name) 
              define_image_method(image_style) 
              send(method_name, *args)
            elsif image_sizes = image_resize_from_method_name(method_name) 
              define_image_resize_method(image_sizes) 
              send(method_name, *args)
            else
              super
            end
          end 
      
          def image_style_from_method_name(method_name)
            if method_name.to_s.match(/_url_image$/) && style = method_name.to_s.sub(/_url_image$/, '')
              style if style.in? Amz::Image.styles.with_indifferent_access
            elsif method_name.to_s.match(/_image$/) && style = method_name.to_s.sub(/_image$/, '')
              style if style.in? Amz::Image.styles.with_indifferent_access
            end
          end 

          def image_resize_from_method_name(method_name)
            if method_name.to_s.match(/^image_resize_/) && sizes = method_name.to_s.sub(/^image_resize_/, '')
              sizes
            end
          end


        end 
       end
    end
end