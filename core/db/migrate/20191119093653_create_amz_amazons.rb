class CreateAmzAmazons < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_amazons do |t|
      t.belongs_to :product
      t.string :barcode
      t.string :short_url
      t.integer :reviews_scanned,          default: 0
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
