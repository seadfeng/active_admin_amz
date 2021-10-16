module Amz
  module ReviewsHelper
    # helper_method :build_searcher
    def featured 
      featured_limit = current_store.featured_limit
      review = @store_review.review
      review_id = review.id
      review_name = review.name
      tags = @store_review.tags
      review_ids = tags.map {|tag| tag.reviews.ids }.join(',')
      # begin
        search_keywords = "(#{review_name})" 
        search_keywords += " | " + tags.map{|tag| "(#{tag.name})" }.join(" | ")  if tags.any?
        
        # searcher =  build_searcher({store_id: current_store.id, page: 1, per_page: featured_limit, keywords: search_keywords, :without => { :review_id => review_id }})
        searcher =  Amz::StoreReview.search( search_keywords , limit: featured_limit, populate: true, :with => {:store_id =>  current_store.id }, :without => { :review_id => review_id })  
        
    end 

    private

    def field_weights
      { 
          :name => 10,
          :review_name => 10, 
          :review_meta_title => 9,
          :meta_title => 9,
          :product_brands => 8,
          :product_names => 5,
          :scanned => 7
      }
    end

  end
end
