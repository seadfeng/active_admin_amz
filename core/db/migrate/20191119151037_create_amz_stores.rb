class CreateAmzStores < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_stores do |t|
      t.string :name
      t.string :domain
      t.string :url
      t.text :meta_description 
      t.string :meta_title
      t.string :mail_from_address
      t.belongs_to :currency
      t.string :code
      t.text :preferences
      t.boolean :default, default: false, null: false

      t.timestamps
    end
  end
end
