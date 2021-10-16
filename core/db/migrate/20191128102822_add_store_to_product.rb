class AddStoreToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_products, :store_id, :integer 
    add_index :amz_products, ["store_id"], name: "index_products_on_store_id"
  end
end
