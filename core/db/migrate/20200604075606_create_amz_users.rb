class CreateAmzUsers < ActiveRecord::Migration[6.0]
  def up
    create_table :amz_users do |t|
      ## Database authenticatable
      t.belongs_to :store
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :first_name, null: false, default: "" 
      t.string :last_name,  null: false,  default: "" 

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      t.boolean   :subscription , default: false
      t.string   :login
      t.string   :time_zone
      t.string   :password_salt
      t.datetime :deleted_at

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false
    end

    add_index :amz_users, :email 
    add_index :amz_users, [:store_id, :email], name: 'amz_users_email_and_store_id', unique: true, using: :btree 
    add_index :amz_users, :reset_password_token, unique: true
    add_index :amz_users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end

  def down
    drop_table :amz_users 
  end
end
