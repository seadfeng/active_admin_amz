class RemoveReviewProduct < ActiveRecord::Migration[6.0]
  def change
    drop_table :amz_products_reviews 
  end
end
