class AddStoreToTaxon < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_taxons, :store_id, :integer     
    add_index  :amz_taxons, :store_id, name: "taxon_on_store_id"  
  end
end
