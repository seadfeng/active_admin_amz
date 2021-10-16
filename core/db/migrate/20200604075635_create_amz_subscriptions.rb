class CreateAmzSubscriptions < ActiveRecord::Migration[6.0]
  def up
    create_table :amz_subscriptions do |t|
      t.belongs_to :user
      t.belongs_to :store
      t.string   :email, null: false, default: ""
      t.string   :unsubscribe_token
      t.datetime :unsubscribe_at
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :amz_subscriptions, [:store_id, :email], name: 'amz_subscriptions_email_and_store_id', unique: true, using: :btree
    add_index :amz_subscriptions, :email  
    add_index :amz_subscriptions, :unsubscribe_token, unique: true 
  end

  def down
    drop_table :amz_subscriptions
  end
end
