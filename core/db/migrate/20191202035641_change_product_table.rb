class ChangeProductTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :amz_products, :store_review_id 
    add_column :amz_products, :description, :text  
    add_column :amz_products, :store_id, :integer 
    add_index  :amz_products, ["store_id"], name: "product_on_store_id"
  end
end
