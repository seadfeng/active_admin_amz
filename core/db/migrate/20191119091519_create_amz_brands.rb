class CreateAmzBrands < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_brands do |t|
      t.string :name, null: false, default: ''
      t.timestamps
    end
  end
end
