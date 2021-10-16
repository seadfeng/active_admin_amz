class CreateAmzStoreRedirects < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_store_redirects do |t|
      t.belongs_to :store
      t.references :resource, polymorphic: true 
      t.integer :viewed 
      t.timestamps
    end
  end
end
