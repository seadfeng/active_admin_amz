class CreateAmzCms < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_cms do |t|
      t.belongs_to :store
      t.string     :name, null: false, default: ''
      t.string     :slug, null: false, default: ''
      t.string     :meta_title
      t.string     :meta_description 
      t.text       :description 
      t.datetime   :published_at
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :amz_cms, [:store_id, :name], name: 'cms_by_store_id_and_name', unique: true, using: :btree
  end
end
