module Amz
    module StoreReviews
      class Find
        def initialize(scope:, params:, stores:)
          @scope = scope
          @stores = stores 
          @ids              = String(params.dig(:filter, :ids)).split(',') 
          @taxons           = String(params.dig(:filter, :taxons)).split(',') 
          @name             = params.dig(:filter, :name) 
          @sort_by          = params.dig(:sort_by)
          @deleted          = params.dig(:filter, :show_deleted) 
        end
  
        def execute
          reviews = by_ids(scope) 
          reviews = by_stores(reviews) 
          reviews = by_taxons(reviews)
          reviews = by_name(reviews)  
          reviews = include_deleted(reviews)  
          reviews
        end
  
        private
  
        attr_reader :ids, :stores,  :taxons, :name,  :scope, :sort_by, :deleted 
  
        def ids?
          ids.present?
        end
   

        def stores?
           stores.present?
        end 
  
        def taxons?
          taxons.present?
        end
  
        def name?
          name.present?
        end 
  
        def sort_by?
          sort_by.present?
        end
  
        def name_matcher
          Amz::Review.arel_table[:name].matches("%#{name}%")
        end
  
        def by_ids(reviews)
          return reviews unless ids?
  
          reviews.where(id: ids)
        end
   
        def by_stores(reviews)
            return reviews unless stores?
    
            reviews.joins(:store).distinct.where(amz_stores: { id: stores })
        end 
        
        def by_taxons(reviews)
          return reviews unless taxons?
  
          reviews.joins(:taxons).distinct.where(amz_taxons: { id: taxons })
        end
  
        def by_name(reviews)
          return reviews unless name?
  
          reviews.where(name_matcher)
        end   

        def include_deleted(reviews)
          deleted ? reviews.with_deleted : reviews.not_deleted
        end 
      end
    end
end
