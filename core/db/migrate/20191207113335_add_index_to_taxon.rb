class AddIndexToTaxon < ActiveRecord::Migration[6.0]
  def change
    add_index  :amz_taxons, :rgt, name: "taxon_on_rgt" 
    add_index  :amz_taxons, :lft, name: "taxon_on_lft"  
    add_index  :amz_taxons, :depth, name: "taxon_on_depth" 
  end
end
