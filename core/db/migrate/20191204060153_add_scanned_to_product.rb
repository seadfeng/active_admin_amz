class AddScannedToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_products, :scanned, :integer    
  end
end
