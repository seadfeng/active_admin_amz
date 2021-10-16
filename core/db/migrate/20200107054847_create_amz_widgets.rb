class CreateAmzWidgets < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_widgets do |t|
      t.belongs_to :store 
      t.string     :title, null: false, default: ''
      t.boolean    :show_title, default: true, null: false
      t.string     :description
      t.string     :component_type  
      t.string     :resource_type  
      t.integer    :position,                   default: 0, null: false  
      t.datetime   :disabled_at
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :amz_widgets, [:store_id, :title ], name: 'index_widgets_by_store_id_and_title', unique: true, using: :btree
  end
end
