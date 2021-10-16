class AddLockToProduct < ActiveRecord::Migration[6.0]
  def up
    add_column :amz_products, :locked, :boolean, :default => false  
  end

  def down
    remove_column :amz_products, :locked  
  end
end
