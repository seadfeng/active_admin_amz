class CreateAmzPreferences < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_preferences do |t|
      t.string     :name, limit: 100
      t.references :owner, polymorphic: true
      t.text       :value
      t.string     :key
      t.string     :value_type 
      t.timestamps
    end
    add_index :amz_preferences, [:key], name: 'index_amz_preferences_on_key', unique: true
  end
end
