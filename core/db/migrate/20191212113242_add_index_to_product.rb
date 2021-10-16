class AddIndexToProduct < ActiveRecord::Migration[6.0]
  def change
    add_index :amz_products, [:name, :store_id], name: 'product_by_name_id_and_store_id', unique: true, using: :btree 
  end
end
