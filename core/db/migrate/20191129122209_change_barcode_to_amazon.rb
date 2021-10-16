class ChangeBarcodeToAmazon < ActiveRecord::Migration[6.0]
  def change
    rename_column :amz_amazons, :barcode, :asin  
  end
end
