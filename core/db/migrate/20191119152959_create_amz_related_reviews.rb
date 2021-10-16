class CreateAmzRelatedReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_related_reviews do |t|
      t.belongs_to :review
      t.references :resource, polymorphic: true
      t.integer    :position,          default: 0
      t.timestamps
    end
  end
end
