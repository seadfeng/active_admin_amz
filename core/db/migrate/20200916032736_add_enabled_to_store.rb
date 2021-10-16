class AddEnabledToStore < ActiveRecord::Migration[6.0]
  def up
    add_column :amz_stores, :enabled, :boolean, :default => true  
  end

  def down
    remove_column :amz_stores, :enabled  
  end
end
