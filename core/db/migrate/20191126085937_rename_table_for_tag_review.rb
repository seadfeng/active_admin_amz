class RenameTableForTagReview < ActiveRecord::Migration[6.0]
  def change
    rename_table :amz_tag_reviews, :amz_reviews_tags
  end
end
