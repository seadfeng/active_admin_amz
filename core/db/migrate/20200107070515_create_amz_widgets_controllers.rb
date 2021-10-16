class CreateAmzWidgetsControllers < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_widgets_controllers do |t|
      t.belongs_to :widget
      t.belongs_to :controller 
      t.integer    :position,   default: 0, null: false
    end
    add_index :amz_widgets_controllers, [:widget_id, :controller_id ], name: 'index_widget_controller_by_wid_id_and_ctr_id', unique: true, using: :btree
  end
end
