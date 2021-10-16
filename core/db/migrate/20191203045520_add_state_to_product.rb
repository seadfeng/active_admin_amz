class AddStateToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_products, :state, :string   
  end
end
