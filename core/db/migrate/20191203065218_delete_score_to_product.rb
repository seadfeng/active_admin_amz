class DeleteScoreToProduct < ActiveRecord::Migration[6.0]
  def change
    remove_column :amz_products, :score
  end
end
