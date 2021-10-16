class CreateAmzReviewProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_review_products do |t|
      t.belongs_to :review
      t.belongs_to :product 
    end
  end
end
