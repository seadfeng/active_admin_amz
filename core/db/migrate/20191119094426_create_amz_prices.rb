class CreateAmzPrices < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_prices do |t|
      t.references :resource, polymorphic: true
      t.decimal :value, precision: 8, scale: 2, null: false
      t.string :type, default: 'new'
      t.boolean :enabled, default: true
      t.timestamps
    end
  end
end
