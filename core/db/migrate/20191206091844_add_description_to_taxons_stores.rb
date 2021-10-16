class AddDescriptionToTaxonsStores < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_stores_taxons, :description, :text    
  end
end
