module Amz
  class Review < Amz::Base
    extend FriendlyId
    
    friendly_id :slug_candidates, use: :history,  sequence_separator: "_" 

    acts_as_paranoid 

    has_many :related_reviews, -> { order(:position) }, inverse_of: :review, autosave: true 
    has_many :reviews_tags, dependent: :destroy
    has_many :store_reviews, autosave: true 
    has_many :products, through: :store_reviews, autosave: true   
    has_and_belongs_to_many :tags 

    scope :confirmed, ->{ where("confirmed_at is not null") }
    scope :unconfirmed, ->{ where("confirmed_at is null") }

    # before_destroy :ensure_no_store_reviews

    after_destroy :punch_slug
    after_restore :update_slug_history
    after_touch :touch_scanned

    after_commit :clear_cache 

    before_validation :normalize_slug, on: :update  

    # before_validation :update_scanned 

    with_options presence: true do  
      validates :slug, :name 
    end 
    validates_uniqueness_of :slug, case_sensitive: false, allow_blank: true 
    validates_uniqueness_of :name, case_sensitive: true, allow_blank: false 

    attr_accessor :tag_names

    def stores
      Rails.cache.fetch("review_stores_key_#{self.id}") do
        Store.joins(:store_reviews).where("#{StoreReview.table_name}.review_id": self.id).distinct
      end 
    end

    def store_review(store_id)
      store_reviews.find_by(store_id: store_id)
    end

    def tag_names
      tags.pluck(:name).join(',')
    end

    def tag_names=(data)  
      if data.present?
        data = data.split(",") 
        data.each do |t|
          tag = Tag.find_or_create_by(name: t)
          reviews_tags.find_or_create_by( tag_id: tag.id)
        end
        self.tags.where( "amz_tags.name not in (?)", data ).each do |tag|
          reviews_tags.find_by_tag_id(tag.id).destroy
        end
      end
    end  

    def confirmed? 
      !!confirmed_at
    end

    def confirm!
      update_attribute(:confirmed_at, Time.current) 
    end

    def unconfirm! 
      if store_reviews.any?
        errors.add(:confirmed_at, :cannot_unconfirm_if_attached_to_store_reviews)
        throw(:abort)
      end
      update_attribute(:confirmed_at, nil)
    end

    def deleted?
      !!deleted_at
    end

    def touch_scanned
      scanned = store_reviews.sum("scanned")
      update_attribute(:scanned, scanned) 
    end 

    def touch_stores
      Store.all.each do |store|
        store_reviews.find_or_create_by(store: store)
      end
    end

    def self.exists_by_friendly_id?(slug)
      Rails.cache.fetch("review_key_friendly_id_#{slug}") do
        friendly.exists_by_friendly_id?(slug)
      end
    end

    # def normalize_friendly_id(value)
    #   param = value.to_s.split('/').map {|o| o.parameterize}
    #   value = param.join('/')
    #   value = value[0...friendly_id_config.slug_limit] if friendly_id_config.slug_limit
    #   value
    # end 

    private

    # def ensure_no_store_reviews
    #   if store_reviews.any?
    #     errors.add(:review, :cannot_destroy_if_attached_to_store_reviews)
    #     throw(:abort)
    #   end
    # end

    # def update_scanned
    #     self.products.each do |product|
    #       self.scanned +=  product.amazon_reviews_scanned.to_f if product.amazon 
    #     end
    # end  

    def normalize_slug
      self.slug = normalize_friendly_id(slug)
    end

    def punch_slug
      # punch slug with date prefix to allow reuse of original
      update_column :slug, "#{Time.current.to_i}_#{slug}"[0..254] unless frozen?
    end

    def update_slug_history
      save!
    end

    # Try building a slug based on the following fields in increasing order of specificity.
    def slug_candidates
      [
        :name, 
      ]
    end   

    def clear_cache
      Rails.cache.delete( "review_key_friendly_id_#{self.slug}" ) 
      Rails.cache.delete( "review_stores_key_#{self.slug}" ) 
    end
    

  end
end
