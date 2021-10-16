class CreateAmzReleases < ActiveRecord::Migration[6.0]
  def up
    create_table :amz_releases do |t|
      t.references :logable, polymorphic: true 
      t.decimal    :value, precision: 5, scale: 3, default: 0.001
      t.string     :name,  default: '', null: false
      t.string     :image 
      t.string     :price 
      t.timestamps
    end
  end

  def down
    drop_table :amz_releases
  end
end
