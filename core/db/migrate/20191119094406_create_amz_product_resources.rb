class CreateAmzProductResources < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_product_resources do |t|
      t.belongs_to :product
      t.references :resource, polymorphic: true 
    end
  end
end
