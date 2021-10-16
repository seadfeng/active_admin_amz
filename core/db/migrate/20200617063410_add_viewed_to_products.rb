class AddViewedToProducts < ActiveRecord::Migration[6.0]
  def up
    add_column :amz_products, :viewed, :integer , default: 0
  end

  def down
    remove_column :amz_products, :viewed
  end
end
