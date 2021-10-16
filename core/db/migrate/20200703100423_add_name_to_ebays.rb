class AddNameToEbays < ActiveRecord::Migration[6.0]
  def up
    add_column :amz_ebays, :name, :string, :limit => 355 
  end

  def down
    remove_column :amz_ebays, :name 
  end
end
