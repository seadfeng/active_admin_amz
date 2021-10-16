module Amz
  class Faq < Amz::Base
    acts_as_paranoid
    belongs_to :store
    belongs_to :store_review, touch: true

    with_options presence: true do  
      validates :name 
    end 

    validates_uniqueness_of :name, case_sensitive: true, allow_blank: false , scope: :store 

    scope :draft, ->{ where("#{Faq.quoted_table_name}.published_at is null or #{Faq.quoted_table_name}.published_at >= ?", Time.current) }    
    scope :published, -> { where("#{Faq.quoted_table_name}.published_at is not null and #{Faq.quoted_table_name}.published_at < ? ", Time.current)}

    def published?
      self.published_at && !deleted?  && self.published_at <= Time.current
    end    
  end
end
