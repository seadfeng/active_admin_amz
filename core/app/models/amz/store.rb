module Amz
  class Store < Amz::Base
    include Amz::Store::Preference
    include Amz::Store::Mail   
    include Validates

    belongs_to :locale
    belongs_to :currency
    has_one  :favicon, as: :viewable, dependent: :destroy, class_name: 'Image', autosave: true
    has_one  :logo, as: :viewable, dependent: :destroy, class_name: 'Logo', autosave: true
    has_many :products, autosave: true
    has_many :redirects, autosave: true, class_name: 'Amz::Redirect' 
    has_many :store_reviews, autosave: true 
    has_many :reviews, through: :store_reviews  
    has_many :searches
    has_many :synonyms
    has_many :faqs, class_name: 'Amz::Faq' 
    has_many :users, class_name: 'Amz::User', autosave: true  
    has_many :subscriptions, class_name: 'Amz::Subscription', autosave: true  


    has_many :taxons, class_name: 'Amz::Taxon' 
    has_many :cms, ->{ order('published_at desc') }, class_name: 'Amz::Cms' , autosave: true 
    has_many :blocks, class_name: 'Amz::Block' , autosave: true 
    has_many :review_taxons, ->{ where(depth: Amz::Config.max_depth_in_categories) }, class_name: 'Amz::Taxon'
    has_many :taxonomies 

    accepts_nested_attributes_for :favicon, allow_destroy: true
    accepts_nested_attributes_for :logo, allow_destroy: true

    attr_accessor :attachment
    attr_accessor :attachment_logo

    
    with_options presence: true do 
      validates_uniqueness_of :code, case_sensitive: true, allow_blank: true   
      validates :name, :code
      validates :url , url: true
      validates :domain , domain: true
    end  

    scope :by_url, ->(url) { where('url like ?', "%#{url}%") }
    scope :by_domain, ->(domain) { where('domain like ?', "%#{domain}%") }
    scope :by_code, ->(code) { where('code like ?', "%#{code}%") }

    scope :by_locales, lambda { |locales| joins(:locale).where( 'amz_locales.code': locales) unless locales.blank? }  

    before_save :ensure_default_exists_and_is_unique
    before_destroy :validate_not_default

    delegate :native_shopping_ad?, to: :locale

    # after_create :touch_store_reviews
    after_commit :clear_cache 

    def find_or_build_favicon
      favicon || build_favicon 
    end  

    def attachment=(_attachment)  
      unless _attachment.blank?
        image = find_or_build_favicon 
        image.attachment.attach( _attachment )
      end
    end

    def find_or_build_logo
      logo || build_logo
    end  

    def attachment_logo=(_attachment)  
      unless _attachment.blank?
        logo = find_or_build_logo
        logo.attachment.attach( _attachment )
      end
    end


    def articles 
      Amz::Article.where(store_review_id: store_reviews.ids)
    end

    def market_place 
      cache_locale.code.gsub(/.*?-/,"")
    end

    def region
      if !self.amz_region.blank?
        self.amz_region
      else 
        market_place
      end
    end

    def self.current(domain = nil) 
      if domain == "localhost"
        Store.default
      else
        Rails.cache.fetch("store_key_#{domain}") do
          current_store = domain ? Store.find_by_domain(domain) : nil
          current_store || Store.default
        end  
      end 
    end 

    def self.default
      where(default: true).first_or_initialize 
    end 

    def cache_locale
      Rails.cache.fetch("store_locale_key_#{self.id}") do
        locale
      end
    end

    def google_gtm_id
      preferred_google_gtm_id
    end

    def google_gtag_redirect_id
      preferred_google_gtag_redirect.gsub(/(.*)\/.*/,'\1')
    end

    def google_gtag
      if preferred_google_gtag_id.blank? 
        google_gtag_redirect_id
      else
        preferred_google_gtag_id
      end
    end

    def amp? 
      preferred_amp
    end

    def display_name
      "#{self.name} (#{market_place})"
    end 

    def clear
      clear_cache
    end 

    private 

    def touch_store_reviews
      Review.confirmed.each do |review|
        store_reviews.find_or_create_by(review: review)
      end
    end

    def ensure_default_exists_and_is_unique
      if default
        Store.where.not(id: id).update_all(default: false)
      elsif Store.where(default: true).count.zero?
        self.default = true
      end
    end

    def validate_not_default
      if default
        errors.add(:default, :cannot_destroy_default_store)
        throw(:abort)
      end
    end

    def clear_cache
      Rails.cache.delete( "store_key_#{self.domain}" ) 
      Rails.cache.delete( "store_locale_key_#{self.id}")
    end

    def clear_varnish
      # Todo
      # ActiveAdmin::Helpers::
      # rest_client()
    end

  end
end
