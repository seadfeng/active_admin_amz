class AddIndexToReview < ActiveRecord::Migration[6.0]
  def change
    add_index :amz_reviews, :name, unique: true, using: :btree 
    add_index :amz_reviews, :slug, unique: true, using: :btree  
  end
end
