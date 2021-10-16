class CreateAmzCurrencies < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_currencies do |t|
      t.string :name, null: false, default: ''
      t.string :code, null: false, default: ''               
      t.string :unit   
      t.string :separator   
      t.string :delimiter   
      t.string :format   
      t.integer :precision   
      t.timestamps 
    end
    unless currency = Amz::Currency.first
      currency = Amz::Currency.new
      currency.name = "United States Dollar"
      currency.code = "USD"
      currency.unit = "$"
      currency.separator = ","
      currency.delimiter = "."
      currency.precision = 2 
      currency.save!
      currency = Amz::Currency.new
      currency.name = "EURO"
      currency.code = "EURO"
      currency.unit = "€"
      currency.separator = ","
      currency.delimiter = "."
      currency.precision = 2 
      currency.save!
    end
  end
end
