class CreateAmzStoreReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_store_reviews do |t|
      t.belongs_to :store
      t.belongs_to :review 
      t.string :meta_title
      t.string :meta_description 
      t.integer :scanned,          default: 0
      t.datetime :published_at 
      t.datetime :deleted_at
      t.timestamps
    end 
    add_index :amz_store_reviews, [:store_id, :review_id], name: 'store_review_by_store_id_and_review_id', unique: true, using: :btree 
  end
end
