class CreateAmzSynonyms < ActiveRecord::Migration[6.0]
  def up
    create_table :amz_synonyms do |t| 
      t.belongs_to :store
      t.string     :name, null: false, default: '' 
      t.string     :renew, null: false, default: '' 
      t.timestamps
    end
  end

  def down
    drop_table :amz_synonyms
  end
end
