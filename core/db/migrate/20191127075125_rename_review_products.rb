class RenameReviewProducts < ActiveRecord::Migration[6.0]
  def change
    rename_table :amz_review_products, :amz_products_reviews
  end
end 