class AddNameToStoreReview < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_store_reviews, :name, :string   
  end
end
