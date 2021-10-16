module Amz
  class Widget < Amz::Base
    acts_as_paranoid
    belongs_to :store, class_name: 'Amz::Store' 
    has_many :contents, ->{ order('position asc, id desc')}, class_name: 'Amz::WidgetsContent', dependent: :delete_all, inverse_of: :widget, autosave: true 
    has_many :widgets_controllers, ->{ order('position asc, id desc')}, class_name: 'Amz::WidgetsController', dependent: :delete_all, inverse_of: :widget, autosave: true 
    has_many :controllers, through: :widgets_controllers
    
 
    COMPONENT = %W( ArticleCard BannerCard Tabs PopularCategories Html )

    with_options presence: true do  
      validates :store, :title, :component_type 
    end 
    validates_uniqueness_of :title, case_sensitive: false , allow_blank: false,  scope: [:store] 

    before_validation :set_resource_type, only: :update 
    
    scope :not_deleted, ->{ where('deleted_at is null')}
    scope :by_resource_types ,lambda {  |resource_types| where("resource_type": resource_types ) unless resource_types.blank? } 
    scope :articles, ->{ by_resource_types('Article') }
    scope :blocks, ->{ by_resource_types('Block') }
    scope :cms, ->{ by_resource_types('Cms') }
    scope :disabled, ->{ where('disabled_at is not null and disabled_at <= ?', Time.current) }
    scope :visible, ->{ where('disabled_at is null or disabled_at is not null and disabled_at >= ?', Time.current) }

    accepts_nested_attributes_for :contents 
    
    attr_accessor :name, :article_id, :block_id, :cms_id, :frontend_controller_id, :taxon_id

    def name
      self.title
    end

    def name=(data)
      self.title = data
    end

    def article_id
      nil
    end

    def article_id=(data)
      if data.present?
        content = contents.build
        content.resource_id = data
        content.resource_type = "Amz::Article"
      end
    end 

    def taxon_id
      nil
    end

    def taxon_id=(data)
      if data.present?
        content = contents.build
        content.resource_id = data
        content.resource_type = "Amz::Taxon"
      end
    end 

    def frontend_controller_id
      nil
    end
    def frontend_controller_id=(data)
      if data.present?
        controller = widgets_controllers.build
        controller.controller_id = data 
      end
    end

    def block_id
      nil
    end

    def block_id=(data)
      if data.present?
        content = contents.build
        content.resource_id = data
        content.resource_type = "Amz::Block"
      end
    end 

    def cms_id
      nil
    end

    def cms_id=(data)
      if data.present?
        content = contents.build
        content.resource_id = data
        content.resource_type = "Amz::Cms"
      end
    end 
     
    def source_type 
      case self.component_type 
      when 'ArticleCard', 'BannerCard'
        %w( Article )
      when 'Tabs'
        %w( Block Cms )
      when 'PopularCategories'
        %w( Taxon )
      when 'Html'
        %w( Block ) 
      else
        %w( Cms Block StoreReview Taxon Article )
      end
    end 

    def display_name
      "#{self.title} - #{self.component_type}"
    end

    def disabled? 
       self.disabled_at && self.disabled_at <= Time.current  
    end

    def visible? 
      !disabled? && !deleted?
    end

    private 

    def set_resource_type
      if self.component_type_changed? && !contents.any?
        self.resource_type = nil 
      elsif self.component_type_changed? && contents.any?
        errors.add(:component_type, :widget_has_contents)
        throw(:abort)
      end
    end
  end
end
