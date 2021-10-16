module Amz
  class Block < Amz::Base
    acts_as_paranoid
    belongs_to :store, inverse_of: :blocks, touch: true
 
    scope :by_ge_published_at, lambda { |published_at| where( 'published_at is not null and published_at <= ?' , published_at) unless published_at.blank? } 
    scope :published, ->{ by_ge_published_at(Time.current) }
    scope :draft, -> { where( 'published_at is null')  }

    with_options presence: true do  
      validates :name, :identity, :store, :description
    end 

    # has_one :image, as: :viewable, dependent: :destroy, class_name: 'Image', autosave: true

    before_validation :normalize_identity 

    before_validation :clear_cache

    def visible?
      self.published_at && !deleted?  && self.published_at <= Time.current
    end 

    def self.cache_by_store_id_and_identity(*options)
      options = options.first || {}  
      return nil if options[:store_id].blank? || options[:identity].blank?

      find_block = Rails.cache.fetch("block_key_#{options[:store_id]}_#{options[:identity]}") do
        Amz::Block.published.find_by(store_id: options[:store_id], identity: options[:identity] )
      end  
    end

    private

    def normalize_identity
      self.identity = identity.lstrip.rstrip.downcase.gsub(/\s/,'_')
    end

    def clear_cache
      Rails.cache.delete( "block_key_#{self.store_id}_#{self.identity}" ) 
    end

  end
end
