class CreateAmzProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_products do |t|
      t.belongs_to :brand
      t.string :name
      t.string :score
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
