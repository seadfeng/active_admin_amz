class RenameTaxonsStores < ActiveRecord::Migration[6.0]
  def change
    rename_table :amz_taxons_stores, :amz_stores_taxons
  end
end
