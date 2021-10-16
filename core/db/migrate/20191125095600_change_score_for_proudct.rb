class ChangeScoreForProudct < ActiveRecord::Migration[6.0]
  def change
    change_column :amz_products, :score, :decimal, precision: 3, scale: 1, default: 9.9
  end
end
