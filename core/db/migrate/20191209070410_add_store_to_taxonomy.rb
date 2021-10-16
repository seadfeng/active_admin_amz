class AddStoreToTaxonomy < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_taxonomies, :store_id, :integer     
    add_index  :amz_taxonomies, :store_id, name: "amz_taxonomy_on_store_id"  
  end
end
