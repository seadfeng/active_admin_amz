class AddConfirmedAtToReview < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_reviews, :confirmed_at, :datetime   
    remove_column :amz_reviews, :enabled
  end
end
