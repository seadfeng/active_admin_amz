class AddBestValueToStoreReviewProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_store_review_products, :best_value, :boolean , default: false  
  end
end
