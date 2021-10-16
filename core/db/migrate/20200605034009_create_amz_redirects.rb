class CreateAmzRedirects < ActiveRecord::Migration[6.0]
  def up
    create_table :amz_redirects do |t|
      t.belongs_to :store
      t.references :resource, polymorphic: true 
      t.integer :viewed , default: 0
      t.timestamps
    end 
  end

  def down
    drop_table :amz_redirects
  end
end
