class AddPositionToReviewProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_review_products, :position, :integer, default: 0
  end
end
