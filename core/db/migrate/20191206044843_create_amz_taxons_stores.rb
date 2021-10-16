class CreateAmzTaxonsStores < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_taxons_stores do |t|
      t.belongs_to :taxon
      t.belongs_to :store 
      t.string     :name
      t.string     :meta_title
      t.string     :meta_description 
    end
    add_index :amz_taxons_stores, [:taxon_id, :store_id], name: 'taxon_store_by_store_id_and_taxon_id', unique: true, using: :btree 
  end
end
