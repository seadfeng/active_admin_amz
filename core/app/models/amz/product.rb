module Amz
    class Product < Amz::Base
        include Amz::Product::Extend
        include Amz::Product::Scope
        include Amz::Product::StateMachine  
        include Amz::Product::EbaySupport
        include Amz::Product::AmznSupport

        belongs_to :brand , optional: true
        belongs_to :store 
        has_many :store_review_products, -> { order("#{StoreReviewProduct.quoted_table_name}.score desc") }, inverse_of: :product, autosave: true
        has_many :store_reviews, through: :store_review_products, autosave: true
        has_many :reviews , through: :store_reviews, autosave: true  
        has_many :product_resources   
        has_many :releases, -> { order("#{Release.quoted_table_name}.value desc") }, as: :logable, autosave: true

        before_update :touch_release, if: :name_changed?
        before_save :truncate_name
        after_create :touch_release
        
        after_touch :touch_scanned 
        after_update :touch_store_review_products
        

        with_options presence: true do  
            validates :name, :sku 
        end 
        # validates_uniqueness_of :name, case_sensitive: false, allow_blank: false , scope: :store_id     
        validates_uniqueness_of :sku, case_sensitive: false, allow_blank: false , scope: :store_id     
         
        delegate :market_place, :region, :native_shopping_ad?, to: :store    

        attr_accessor :brand_name , :store_review_id , :cache_paapi5  

        def touch_store_review_products 
            store_review_products.each{ |x| x.touch }
        end

        def truncate_name
            self.name = name.truncate(350) if name
        end

        def touch_release 
            if releases.any? 
                value = releases.last.value + 0.001 
            else
                value = 0.001
            end
            releases.create(name: name, value: value  )
        end

        def master
            if amazon
                amazon unless amazon.discontinued?
            elsif ebay 
                ebay unless ebay.discontinued?
            end 
        end 

        def add_cart
            if amazon 
                amazon_add_cart
            end
        end

        def link_to_product 
            amazon_product_url || ebay_product_url
        end

        def store_reviews_touch_scanned
            store_reviews.each do |store_review|
                store_review.touch_scanned
            end
        end 

        def touch_scanned
            scanned = amazon_reviews_scanned if amazon_reviews_scanned
            scanned += ebay_reviews_scanned if ebay_reviews_scanned
            update_attribute(:scanned, scanned)  
            store_reviews_touch_scanned
        end   

        # def find_or_build_review(name)
        #     Review.find_or_create_by(name: name)  
        # end 

        # def find_or_build_image
        #     image || build_image 
        # end  

        # def attachment=(_attachment) 
        #     image = find_or_build_image
        #     image.attachment.attach( _attachment )
        # end

        def store_review_id
            store_reviews.last.id if store_reviews.any?
        end

        def store_review_id=(data)  
            store_review_product = store_review_products.build 
            store_review_product.store_review_id = data  
        end   

        def brand_name
            self.brand.name unless self.brand.blank?
        end

        def brand_name=(data)
            if data.present?
                brand = Brand.find_or_create_by(name: data)
                self.brand_id = brand.id
            end
        end  

        # use deleted? rather than checking the attribute directly. this
        # allows extensions to override deleted? if they want to provide
        # their own definition.
        def deleted?
            !!deleted_at
        end

        # determine if product is available.
        # deleted products and products with nil or future available_on date
        # are not available
        def available?
            available_boole = !(available_on.nil? || available_on.future?) && !deleted? && !discontinued? 
            publish!  if available_boole && draft?  
            available_boole  
        end

        def discontinue! 
            update_attribute(:discontinue_on, Time.current) unless master
        end

        def discontinued?
            discontinued_boole = !!discontinue_on && discontinue_on <= Time.current
            move_to_trash if discontinued_boole && published? 
            discontinued_boole
        end 

        def cache_paapi5
            Rails.cache.read("prd_amazon_key_#{self.id}_paapi5" ) 
        end
    
        def cache_paapi5=(item)
            Rails.cache.fetch("prd_amazon_key_#{self.id}_paapi5", expires_in: 12.hours) do
                item
            end
        end

        private

        def amazon_add_cart
            "#{store.url}/gp/aws/cart/add.html?AssociateTag=#{store.amz_tag_id}&ASIN.1=#{amazon.asin}&Quantity.1=1"
        end
        # https://www.amazon.com/gp/aws/cart/add.html?AssociateTag=brg_c_4-20&ascsubtag=892730517-2-1964974971.1573871152&ASIN.1=B07MN623T4&Quantity.1=1
        
        # https://ws-na.amazon-adsystem.com/widgets/q?ServiceVersion=20070822&OneJS=1&Operation=GetAdHtml&MarketPlace=US&source=ss&ref=as_ss_li_til&ad_type=product_link&tracking_id=bestcoffeemakerreviewsinfo-20&language=en_US&marketplace=amazon&region=US&placement=B07DB2NQ3N&asins=B07DB2NQ3N
    end
  end
  