class CreateAmzWidgetsContents < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_widgets_contents do |t|
      t.belongs_to :widget
      t.references :resource, polymorphic: true 
      t.integer    :position,                   default: 0, null: false
    end
    add_index :amz_widgets_contents, [:widget_id, :resource_type, :resource_id ], name: 'index_widgets_contents_by_resource_and_wid_id', unique: true, using: :btree
  end
end
