ThinkingSphinx::Index.define 'amz/store_review', :with => :active_record do
    indexes name, :sortable => true    
    indexes meta_title   
    indexes scanned, :sortable => true  
    indexes review.name, :as => :review_name , :sortable => true   
    indexes review.meta_title, :as => :review_meta_title 
    indexes review.scanned, :as => :review_scanned, :sortable => true 

    indexes review.tags.name, :as => :tag_names 
    indexes classifications.position, :as => :positions, :sortable => true 
    indexes store_review_products.product.name, :as => :product_names
    indexes store_review_products.product.brand.name, :as => :product_brands
    indexes taxons.name, :as => :taxon 
    indexes taxons.meta_title, :as => :taxon_meta_title 
 
    has taxons(:id), :as => :taxon_ids, type: :integer, :facet => true  
    has store_id,  :type => :integer 
    has review_id,  :type => :integer 
    has published_at, :type => :timestamp 
    has created_at, :type => :timestamp
    has updated_at, :type => :timestamp

    # is_active_sql = "amz_products.deleted_at IS NULL AND (amz_products.discontinue_on IS NULL or amz_products.discontinue_on >= NOW()) AND (amz_products.available_on <= NOW()) AND amz_products.state ='published' "

    Amz::Taxon.find_each do |taxon|
        if taxon.children.size > 0
          has taxons(:id), :as => "#{taxon.id}_taxon_ids"
        end
    end
 
    where sanitize_sql("#{Amz::StoreReview.quoted_table_name}.deleted_at IS NULL AND (#{Amz::StoreReview.quoted_table_name}.published_at IS NOT NULL or #{Amz::StoreReview.quoted_table_name}.published_at <= NOW())") 
    
    # has is_active_sql, :as => :is_active, :type => :boolean
end
