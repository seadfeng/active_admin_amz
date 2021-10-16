class RemovePositionForWidgetsController < ActiveRecord::Migration[6.0]
  def change
    remove_column :amz_widgets, :position
  end
end
