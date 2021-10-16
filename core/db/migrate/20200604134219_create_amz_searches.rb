class CreateAmzSearches < ActiveRecord::Migration[6.0]
  def up
    create_table :amz_searches do |t| 
      t.belongs_to :store
      t.string     :name, null: false, default: ''
      t.integer    :used , default: 0
      t.string     :redirect_url  
      t.boolean    :disabled, default: false
      t.timestamps
    end
  end

  def down
    drop_table :amz_searches
  end
end
