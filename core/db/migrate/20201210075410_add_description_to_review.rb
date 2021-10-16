class AddDescriptionToReview < ActiveRecord::Migration[6.0]
  def up
    add_column :amz_reviews, :description, :text 
  end

  def down
    remove_column :amz_reviews, :description  
  end
end
