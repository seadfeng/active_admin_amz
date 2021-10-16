require 'stringex'
module Amz
  class Taxon <  Amz::Base
    extend FriendlyId
    friendly_id :permalink, slug_column: :permalink, use: [:history, :scoped ], scope: :store 
    before_validation :set_permalink, on: :create, if: :name
    before_validation :update_permalink, on: :update, if: :seo_changed? 
    before_validation :out_of_max_depth 
    
    before_validation :set_taxonomy
    acts_as_nested_set dependent: :destroy

    belongs_to :taxonomy, class_name: 'Amz::Taxonomy', inverse_of: :taxons
    belongs_to :store, class_name: 'Amz::Store', inverse_of: :taxons
    has_many :classifications, -> { order(:position) }, class_name: 'Amz::Classification', dependent: :delete_all, inverse_of: :taxon
    has_many :store_reviews, through: :classifications
    has_many :store_review_products, through: :store_reviews  
    has_many :reviews, through: :store_reviews  
    has_many :products, through: :store_review_products  
    has_one :image, as: :viewable, dependent: :destroy, class_name: 'Image', autosave: true 

    validates :name, presence: true

    #validates_uniqueness
    validates_uniqueness_of :permalink, case_sensitive: false ,  scope: [:parent, :taxonomy, :store]   
    validates_uniqueness_of :name, case_sensitive: false , allow_blank: true,  scope: [:parent, :taxonomy, :store] 

    validate :check_for_root, on: :create

    with_options length: { maximum: 255 }, allow_blank: true do 
      validates :meta_description
      validates :meta_title
    end

    delegate :taxons, to: :taxonomy

    before_validation :clear_cache 

    # accepts_nested_attributes_for :stores_taxons, allow_destroy: true
    accepts_nested_attributes_for :image, allow_destroy: true
    attr_accessor :attachment


    after_save :touch_ancestors_and_taxonomy
    after_touch :touch_ancestors_and_taxonomy  

    scope :show_in_menu,  ->{ where(show_in_menu: true) }

    def find_or_build_image
      image || build_image 
    end  

    def attachment=(_attachment)  
      image = find_or_build_image
      image.attachment.attach( _attachment )
    end
    
    def out_of_max_depth
      if !self.parent.blank?
        unless max_depth > self.parent.depth 
          errors.add(:depth, :max_depth_in_categories)
          throw(:abort)
        end
      end
    end

    def max_depth?
      self.depth == max_depth
    end 

    def max_depth
      Amz::Config.max_depth_in_categories
    end

    # Return meta_title if set otherwise generates from root name and/or taxon name
    def seo_title
      if meta_title.blank?
        root? ? name : "#{root.name} - #{name}"
      else
        meta_title
      end
    end

    # Creates permalink base for friendly_id
    def set_permalink 
      if parent.present?
        self.permalink = [parent.permalink, name.to_url ].join('/')
      else
        self.permalink = name.to_url  
      end
    end 

    def update_permalink 
      self.permalink = permalink.to_url if permalink.blank?  
      set_permalink if parent_id_changed?
      update_children_permalink if children.any?
    end

    def update_children_permalink 
      children.each do |chrld| 
        chrld.set_permalink
        chrld.save
      end
    end

    def set_taxonomy
      self.taxonomy_id = parent.taxonomy_id unless parent.blank?
    end

    def active_reviews
      reviews.active
    end

    def pretty_name
      ancestor_chain = ancestors.inject('') do |name, ancestor|
        name += "#{ancestor.name} -> "
      end
      ancestor_chain + name.to_s
    end

    # awesome_nested_set sorts by :lft and :rgt. This call re-inserts the child
    # node so that its resulting position matches the observable 0-indexed position.
    # ** Note ** no :position column needed - a_n_s doesn't handle the reordering if
    #  you bring your own :order_column.
    #
    #  See #3390 for background.
    def child_index=(idx)
      move_to_child_with_index(parent, idx.to_i) unless new_record?
    end

    def display_name
      pretty_name
    end

    def jstree 
      node = { id: self.id, text: self.name, state: "closed", children: self.children.any?, url: helpers.jstree_admin_store_taxon_path(self.store,self)  } 
      node
    end   

    def self.exists_by_friendly_id?(*options)
      options = options.first || {}  
      return nil if options[:store_id].blank? || options[:permalink].blank?
      Rails.cache.fetch("cms_key_friendly_id_#{options[:store_id]}_#{options[:permalink]}") do
        where(store_id: options[:store_id] ).friendly.exists_by_friendly_id?(options[:permalink])
      end
    end

    def self.cache_by_store_id_and_friendly_id(*options)
      options = options.first || {}  
      return nil if options[:store_id].blank? || options[:friendly_id].blank?

      find_obj = Rails.cache.fetch("taxon_key_#{options[:store_id]}_#{options[:friendly_id]}") do
        if where(store_id: options[:store_id] ).friendly.exists_by_friendly_id?( options[:friendly_id] ) 
           where(store_id: options[:store_id] ).friendly.find( options[:friendly_id] ) 
        else  
          nil
        end
      end  
      if find_obj.blank? 
        return nil
      else
        return find_obj
      end
    end
    private

    def seo_changed?
      permalink_changed? || parent_id_changed?
    end

    def touch_ancestors_and_taxonomy
      # Touches all ancestors at once to avoid recursive taxonomy touch, and reduce queries.
      ancestors.update_all(updated_at: Time.current)
      # Have taxonomy touch happen in #touch_ancestors_and_taxonomy rather than association option in order for imports to override.
      taxonomy.try!(:touch)
    end

    def check_for_root
      if taxonomy.try(:root).present? && parent_id.nil?
        errors.add(:root_conflict, 'this taxonomy already has a root taxon')
      end
    end 

    def helpers
      ActiveAdmin::Helpers::Routes
    end

    def clear_cache
      Rails.cache.delete( "taxon_key_#{self.store_id}_#{self.permalink}" ) 
      Rails.cache.delete( "taxon_key_friendly_id_#{self.store_id}_#{self.permalink}" )  
    end

  end
end
