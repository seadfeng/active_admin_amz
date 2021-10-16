class CreateAmzReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_reviews do |t|
      t.string :name, null: false, default: ''
      t.string :slug
      t.string :meta_title
      t.string :meta_description 
      t.integer :scanned,          default: 0
      t.datetime :deleted_at
      t.boolean :enabled, default: false
      t.timestamps
    end
  end
end
