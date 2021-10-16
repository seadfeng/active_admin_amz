module Amz
  module BaseHelper 

   def display_price(product)
   end

   def link_to_amazon(product,options = {})
    link_to product.amazon.name, product.amazon_product_url, options
   end

   def meta_data
    c_name = controller_name.singularize 
    object = instance_variable_get('@' + c_name)
    meta = {}

    meta[:"og:locale"] = current_store.cache_locale.code
    meta[:"og:title"] = title
    meta[:"og:site_name"] = current_store.name 

    if c_name == "redirect"
      meta[:"og:url"] =  request.url  
      meta[:"og:image"] = large_url_image(@store_review)
      meta[:"og:image:alt"] = title 
      meta[:"og:image:height"] = "600"
      meta[:"og:image:width"] =  "600"
      meta[:description] =  strip_tags(@product.description )if @product.description.present?
    else
      meta[:"og:url"] = request.url.gsub(/\?.*/,'')
    end
    
    if object.is_a? ApplicationRecord
      meta[:keywords] = object.meta_keywords if object[:meta_keywords].present?
      meta[:description] = object.meta_description if object[:meta_description].present?
    end

    if object.is_a?(Amz::Taxon) && (object.image || object.products.published.any?)
      if object.image
        meta[:"og:image"] = large_url_image(object.image)
      elsif object.products.published.any?
        meta[:"og:image"] = large_url_image(object.products.published.first)
      end
      meta[:"og:image:alt"] = title 
      meta[:"og:image:width"] =  "600"
      meta[:"og:image:height"] = "600" 
      meta[:"twitter:card"] = "summary_large_image"
    end

    if object.is_a?(Amz::Review)
      meta[:"og:type"] = "article"
      meta[:"article:published_time"] = meta_time( @store_review.published_at )
      meta[:"article:modified_time"] = meta_time( @store_review.updated_at )
      meta[:"og:updated_time"] =  meta_time( @store_review.updated_at ) 

      if @article 
        meta[:"og:image"] = review_media_url(style: "wide", review_id: @review.slug ) 
        box = @article.image.box("wide")
        meta[:"og:image:width"] =  box[:width]
        meta[:"og:image:height"] = box[:height] 
      else
        meta[:"og:image"] = wide_url_image(@store_review)
        meta[:"og:image:width"] =  "1280"
        meta[:"og:image:height"] = "1280" 
      end
      meta[:"og:image:alt"] = title  
      meta[:"twitter:card"] = "summary_large_image" 
      # store_review = current_store.store_reviews.find_by(review_id: object.id )
      meta_description = @store_review.meta_description if @store_review.present?
      meta_description = object.meta_description if meta_description.blank?
      meta_description = t("amz.review.meta_description", store_name: current_store.name, number: current_store.top_number, keywords: @store_review.seo_name , year: Time.now.year , default:  current_store.review_meta_description ) if meta_description.blank?
      meta[:description] = truncate(strip_tags( meta_description ), length: 160, separator: ' ') 
    end

    if meta[:description].blank?
      meta.reverse_merge!(description: "#{title} - #{current_store.meta_description}")
    end
    meta[:"og:description"] = meta[:description]
    meta
   end

   def meta_data_tags
    object = instance_variable_get('@' + controller_name.singularize ) 
    tags = meta_data.map do |name, content|
      tag('meta', name: name, content: content) unless name.nil? || content.nil?
    end.join("\n")
    if object.is_a?(Amz::Review) 
      tags = tags + "\r\n" + @store_review.tags.map do |tg| 
        tag('meta', name: "article:tag", content: tg.name)  
      end.join("\n")
    end
    tags
   end  

   def hreflangs
    object = instance_variable_get('@' + controller_name.singularize ) 
    tags = ""
    if object.is_a?(Amz::Review)
      stores = object.stores
      if stores.size > 1 
        tags = stores.map do |store|
          tag('link', rel: "alternate", href: "#{protocol}#{store.domain}#{request.path}", hreflang: store.cache_locale.code.downcase ) 
        end.join("\n")
      end
    elsif controller_name == 'home'
      stores = Amz::Store.all
      if stores.size > 1 
        tags = stores.map do |store|
          tag('link', rel: "alternate", href: "#{protocol}#{store.domain}/", hreflang: store.cache_locale.code.downcase ) 
        end.join("\n")
      end
    end
    tags
   end
   
   def origin(store = nil) 
      if store && server_name != "localhost"
        "#{protocol}#{store.domain}#{server_port}"
      else
        "#{protocol}#{server_name}#{server_port}"
      end
   end

   def protocol
      request.protocol
   end

   def server_name   
      request.env['SERVER_NAME']  
   end

   def server_port
      port = request.port 
      if port == 80 || port == 443
        port = '' 
      else
        port = ":#{port}"
      end
       
   end

   def seo_url(source, options = nil, store = nil)
      
     if source.is_a?(Taxon) 
      path = amz.taxons_path(source.permalink, options)
     elsif source.is_a?(StoreReview)
      store = source.store
      path = amz.reviews_path(source.review.slug, options)
     elsif source.is_a?(Review)
      path = amz.reviews_path(source.slug, options)
     elsif source.is_a?(Cms)
      path = amz.cms_path(source.slug, options)
    elsif source.is_a?(AdminUser)
      path = amz.author_path(source, options)
     end
     "#{origin(store)}#{path}"
   end 

    def redirect(product, *options)
      options = options.first || {}
      type = options[:type] ||  {}
      rid = options[:rid] || {}
      if product.amazon && type.blank?
        type = 'amzn'
      elsif product.ebay && type.blank?
        type = 'ebay'
      end
      path = amz.redirects_path( pid: product.id, type: type, rid:  rid)
      "#{origin}#{path}"
    end 

    def frontend_available?
      Amz::Core::Engine.frontend_available?
    end

    private
  end
end
