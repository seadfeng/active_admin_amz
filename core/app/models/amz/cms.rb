module Amz
  class Cms < Amz::Base
    self.table_name = 'amz_cms' 
    acts_as_paranoid
    extend FriendlyId
    friendly_id :slug_candidates, use: [:history, :scoped ], scope: :store 
    belongs_to :store, inverse_of: :cms, touch: true

    with_options presence: true do  
      validates :slug, :name 
    end 
    validates_uniqueness_of :slug, case_sensitive: false, allow_blank: false, scope: :store  
    validates_uniqueness_of :name, case_sensitive: true, allow_blank: false, scope: :store  
 
    scope :by_ge_published_at, lambda { |published_at| where( 'published_at is not null and published_at <= ?' , published_at) unless published_at.blank? } 
    scope :published, ->{ by_ge_published_at(Time.current) }
    scope :draft, -> { where( 'published_at is null')  } 

    before_validation :clear_cache

    def visible?
      self.published_at && !deleted?  && self.published_at <= Time.current
    end 

    def self.exists_by_friendly_id?(*options)
      options = options.first || {}  
      return nil if (options.instance_of? String ) || (options[:store_id].blank? || options[:slug].blank?)
      Rails.cache.fetch("cms_key_friendly_id_#{options[:slug]}") do
        published.where(store_id: options[:store_id] ).friendly.exists_by_friendly_id?(options[:slug])
      end
    end

    def self.cache_by_store_id_and_slug(*options)
      options = options.first || {}  
      return nil if options[:store_id].blank? || options[:slug].blank?

      find_block = Rails.cache.fetch("cms_key_#{options[:store_id]}_#{options[:slug]}") do
        if Amz::Cms.published.where(store_id: options[:store_id] ).friendly.exists_by_friendly_id?( options[:slug] ) 
          Amz::Cms.published.where(store_id: options[:store_id] ).friendly.find( options[:slug] ) 
        else  
          nil
        end
      end  
      if find_block.blank? 
        return nil
      else
        return find_block
      end
    end

    private

    def slug_candidates
      [
        :name, 
      ]
    end 

    def clear_cache
      Rails.cache.delete( "cms_key_#{self.store_id}_#{self.slug}" ) 
      Rails.cache.delete( "cms_key_friendly_id_#{self.store_id}_#{self.slug}" )  
    end

  end
end
