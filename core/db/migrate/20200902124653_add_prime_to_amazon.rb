class AddPrimeToAmazon < ActiveRecord::Migration[6.0]
  def up
    add_column :amz_amazons, :prime, :boolean, :default => false 
    add_column :amz_amazons, :free_shipping, :boolean, :default => false  
  end

  def down
    remove_column :amz_amazons, :prime 
    remove_column :amz_amazons, :free_shipping 
  end
end
