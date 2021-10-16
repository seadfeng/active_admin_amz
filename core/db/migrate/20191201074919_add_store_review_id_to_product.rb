class AddStoreReviewIdToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_products, :store_review_id, :integer   
    add_index :amz_products, ["store_review_id"], name: "product_on_store_review_id" 
    remove_column :amz_products, :store_id
  end
end
