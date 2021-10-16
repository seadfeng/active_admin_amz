class AddImageUrlToAmazon < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_amazons, :asin_image, :string 
  end
end
