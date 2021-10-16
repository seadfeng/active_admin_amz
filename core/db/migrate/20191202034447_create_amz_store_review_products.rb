class CreateAmzStoreReviewProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_store_review_products do |t|
      t.belongs_to :store_review 
      t.belongs_to :product 
      t.string :score
      t.timestamps
    end 
    add_index :amz_store_review_products, [:store_review_id, :product_id], name: 'store_review_product_by_store_review_id_and_pro_id', unique: true, using: :btree 
  end
end
