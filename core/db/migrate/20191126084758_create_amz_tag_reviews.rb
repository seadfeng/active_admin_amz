class CreateAmzTagReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_tag_reviews do |t|
      t.belongs_to :tag
      t.belongs_to :review 
    end
  end
end
