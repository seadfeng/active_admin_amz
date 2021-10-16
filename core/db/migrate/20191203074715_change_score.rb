class ChangeScore < ActiveRecord::Migration[6.0]
    def change
      change_column :amz_store_review_products, :score, :decimal, precision: 2, scale: 1, default: 9.9
    end
end
  