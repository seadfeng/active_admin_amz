class CreateAmzBlocks < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_blocks do |t|
      t.belongs_to :store
      t.string :identity, null: false, default: ''
      t.string :name,     null: false, default: '' 
      t.text   :description 
      t.datetime   :published_at
      t.datetime   :deleted_at
      t.timestamps
    end 
    add_index :amz_blocks, [:store_id, :identity], name: 'index_blocks_by_store_id_and_identity', unique: true, using: :btree
  end
end
