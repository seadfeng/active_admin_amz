module Amz
  class Article < ActiveRecord::Base
    acts_as_paranoid
    belongs_to :store_review, class_name: "Amz::StoreReview", touch: true 
    belongs_to :user, class_name: "AdminUser", touch: true   
    has_many :widgets_contents, -> { order("#{Release.quoted_table_name}.value desc") }, as: :resource, autosave: true
    has_one :image, as: :viewable, dependent: :destroy, class_name: "Image", autosave: true

    delegate :store, :review, to: :store_review  

    accepts_nested_attributes_for :image, allow_destroy: true

    with_options presence: true do  
      validates :name, :title 
    end   

    scope :not_deleted, ->{ where("#{Article.quoted_table_name}.deleted_at is null" )}
    scope :by_ge_published_at, lambda { |published_at| where( "#{Article.quoted_table_name}.published_at is not null and #{Article.quoted_table_name}.published_at <= ?" , published_at) unless published_at.blank? } 
    scope :by_lt_published_at, lambda { |published_at| where( "#{Article.quoted_table_name}.published_at is not null and #{Article.quoted_table_name}.published_at > ?" , published_at) unless published_at.blank? } 
    scope :visible, ->{ by_ge_published_at(Time.current).joins(:store_review).where("#{StoreReview.quoted_table_name}.published_at is not null and #{StoreReview.quoted_table_name}.published_at < ?", Time.current)}
    scope :will_visible, ->{ by_lt_published_at(Time.current) }
    scope :draft, -> { where( "#{Article.quoted_table_name}.published_at is null")  }

    attr_accessor :attachment

    def find_or_build_image
      image || build_image 
    end  

    def attachment=(_attachment)  
      image = find_or_build_image
      image.attachment.attach( _attachment )
    end

    def published
      !!self.published_at
    end

    def visible?
      self.published_at && !deleted?  && self.published_at <= Time.current
    end
       
  end
end
