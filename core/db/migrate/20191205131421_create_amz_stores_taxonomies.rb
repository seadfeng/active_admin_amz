class CreateAmzStoresTaxonomies < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_stores_taxonomies do |t|
      t.belongs_to :store 
      t.belongs_to :taxonomy
      t.integer    :position,          default: 0
      t.timestamps
    end
    add_index :amz_stores_taxonomies, [:store_id, :taxonomy_id], name: 'stores_taxonomy_by_store_id_and_taxonomy_id', unique: true, using: :btree 
  end
end
