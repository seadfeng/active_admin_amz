module Amz
  class StoreReview < Amz::Base
    include Amz::StoreReviewScopes
    include Amz::StoreReview::SphinxScope  
    acts_as_paranoid 
    belongs_to :store, touch: true
    belongs_to :review, touch: true
    has_many :store_review_products, ->{ order("#{StoreReviewProduct.quoted_table_name}.score desc") } , inverse_of: :store_review, autosave: true
    has_many :products, through: :store_review_products, autosave: true   
    has_many :classifications, -> { order(:position) }, dependent: :delete_all, inverse_of: :store_review
    has_many :taxons, through: :classifications, before_remove: :remove_taxon 
    has_many :articles, class_name: 'Amz::Article', autosave: true 
    has_many :faqs, class_name: 'Amz::Faq', autosave: true
    has_one  :master_article, -> { where("#{Article.quoted_table_name}.published_at is not null and #{Article.quoted_table_name}.published_at < ?", Time.current).order(:published_at) }, class_name: 'Amz::Article' 
    
    delegate :market_place, to: :store
    delegate :tags, to: :review

    # before_validation :touch_scanned, on: :update
    after_touch :touch_taxons
    after_touch :touch_scanned

    accepts_nested_attributes_for :store_review_products  

    scope :has_articles, ->{ joins(:articles).distinct }
    scope :has_faqs, ->{ joins(:faqs).distinct }
    scope :non_faqs, ->{  where("#{StoreReview.quoted_table_name}.id not in (?)", self.has_faqs.ids ) }
    scope :published, ->{ where("#{StoreReview.quoted_table_name}.published_at is not null and #{StoreReview.quoted_table_name}.published_at < ?", Time.current) }    
    scope :draft, ->{ where("#{StoreReview.quoted_table_name}.published_at is null or #{StoreReview.quoted_table_name}.published_at >= ?", Time.current) }    
    scope :by_states ,lambda {  |states| joins(:products).where("#{Product.quoted_table_name}.state": states ) unless states.blank? } 
    scope :products_published, ->{ by_states("published")} 

    def master_product
      products.first.master if products.first
    end

    def self.like_any(fields, values)
      conditions = fields.product(values).map do |(field, value)|
        arel_table[field].matches("%#{value}%")
      end
      where conditions.inject(:or)
    end

    def display_name
      if self.name.blank?
        "#{review.name} - #{store.display_name}" if review
      else
        "#{name} - #{store.display_name}"
      end
    end

    def seo_name
      if self.name.blank?
        review.name if review
      else
        self.name
      end
    end

    def seo_meta_title
      if self.meta_title.blank?
        review.meta_title if review
      else
        self.meta_title
      end
    end

    def seo_meta_description
      if self.meta_description.blank?
        review.meta_description if review
      else
        self.meta_description
      end
    end

    def seo_description
      if self.description.blank?
        review.description if review
      else
        self.description
      end
    end

    def touch_scanned
      scanned = products.sum("scanned")
      update_attribute(:scanned, scanned) 
      set_classification_position
    end 

    def published?
      !!published_at
    end

    def deleted?
      !!deleted_at
    end

    def published! 
      if can_published?
        update_attribute(:published_at, Time.current)
      else
        errors.add(:published_at, :cannot_published_if_not_enough_ten_available)
        throw(:abort)
      end
    end

    def can_published?
      has_enough_available
    end 

    def uncache_asins
      objects = products.published.joins(:amazon).limit(store.preferred_top_number)
      asins = objects.pluck("amz_amazons.asin") 

      objects.each do |prd|
        if prd.cache_paapi5
          asins = asins - [prd.asin]
        end
      end 
      asins
    end 

    def touch_cache_amazons
      
      asins = uncache_asins
      if asins.size > 0
        begin
          client = Paapi::Client.new( 
              access_key: store.amz_access, 
              secret_key: store.amz_secret, 
              market: :"#{store.market_place.downcase}", 
              languages_of_preference: store.cache_locale.code.gsub("-",'_'),
              partner_tag: store.amz_tag_id,
              resources: resources
          )
          gi = client.get_items( item_ids: asins ) 
          gi.items.each do |item|
            prd = Product.joins(:amazon).where("amz_products.store_id": store.id, "amz_amazons.asin": item.asin )
            prd.last.cache_paapi5 = item unless prd.blank?
          end
        rescue Exception => e 
          logger = Logger.new(log_file)
          logger.error(I18n.t('active_admin.paapi', message: e.message, default: "Paapi: #{e.message}"))
          logger.error(e.backtrace.join("\n"))
        end 
      end
    end
 

    private

    def set_classification_position
      classifications.update(position: self.scanned) if classifications.any?
    end

    def has_enough_available
      if products.published.count >= store.preferred_top_number && !published?
        true
      else
        false
      end 
    end  

    def taxon_and_ancestors
      taxons.map(&:self_and_ancestors).flatten.uniq
    end

    # Get the taxonomy ids of all taxons assigned to this product and their ancestors.
    def taxonomy_ids
      taxon_and_ancestors.map(&:taxonomy_id).flatten.uniq
    end

    # Iterate through this products taxons and taxonomies and touch their timestamps in a batch
    def touch_taxons
      Amz::Taxon.where(id: taxon_and_ancestors.map(&:id)).update_all(updated_at: Time.current)
      Amz::Taxonomy.where(id: taxonomy_ids).update_all(updated_at: Time.current)
    end

    def remove_taxon(taxon)
      removed_classifications = classifications.where(taxon: taxon)
      removed_classifications.each &:remove_from_list
    end  

    def log_file 
      File.open('log/amazon_paapi5_review.log', File::WRONLY | File::APPEND | File::CREAT)
    end

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

  end
end
