class AddEnabledToProduct < ActiveRecord::Migration[6.0]
  def change 
    add_column :amz_products, :available_on, :datetime  
    add_column :amz_products, :discontinue_on, :datetime  
  end
end
