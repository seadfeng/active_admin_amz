class CreateAmzApiTokens < ActiveRecord::Migration[6.0]
  def up
    create_table :amz_api_tokens do |t|
      t.string 	   :name,                  null: false, default: ""
      t.string 	   :key,                   null: false, default: ""
      t.datetime   :deleted_at
      t.timestamps
    end
  end

  def down
    drop_table :amz_api_tokens
  end
end
