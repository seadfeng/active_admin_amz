module Amz
  class Search < Amz::Base
    include Amz::Search::SphinxScope
    include Validates 
    belongs_to :store 
    has_many :search_logs, class_name: 'Amz::SearchLog'   
    before_validation :strip_name
    after_create :get_results!

    
    with_options presence: true do  
      validates :name, :store  
    end 
    validates :redirect_url, redirect_url: true , allow_blank: true   
    validates_uniqueness_of :name, case_sensitive: true , allow_blank: false,  scope: [:store] 

    scope :landing_pages, ->{ joins(:landing_page) }
    scope :not_landing_pages, ->{ where("id not in (?)", self.landing_pages.ids) }
    scope :has_results, ->{ where("results > 0") }
    scope :no_results,  ->{ where("results = 0") }
    scope :disabled,  ->{ where(disabled: true) }
    scope :enabled,  ->{ where(disabled: false) }

    def count! 
      update_attribute(:used, self.used + 1)   
      search_logs.create
    end  

    def get_results!
      search_keywords = self.name
      store.synonyms.each do |synonym|
        synonym_name = synonym.name 
        search_keywords = search_keywords.gsub(/#{synonym_name}/i,synonym.renew)
      end
      begin 
        search_count = Amz::StoreReview.search(search_keywords, :with => {:store_id => store.id} ).total_count 
        update_attribute(:results, search_count)  
      rescue => exception 
        errors.add(:results, :cannot_update)
        # throw(:abort)
      end  
    end

    def strip_name
      self.name = self.name.lstrip.rstrip if self.name
    end

    def search_log_ids
      search_logs.collect(&:id).join(' ')
    end

    def search_log_last_month_count
      search_logs.last_month.count
    end

    def search_log_last_90days_count
      search_logs.last_90days.count
    end
 

  end
end
