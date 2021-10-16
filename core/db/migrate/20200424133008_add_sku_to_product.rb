class AddSkuToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_products, :sku, :string  
    add_index  :amz_products, :sku, name: "product_on_sku"  
    add_index  :amz_products, [:sku, :store_id], name: 'product_by_sku_and_store_id', unique: true, using: :btree  
  end
end
