class AddNameToAmazon < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_amazons, :name, :string   
  end
end
