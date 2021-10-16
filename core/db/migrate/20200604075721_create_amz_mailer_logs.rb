class CreateAmzMailerLogs < ActiveRecord::Migration[6.0]
  def up
    create_table :amz_mailer_logs do |t|
      t.belongs_to :mailer 
      t.belongs_to :subscription
      t.string     :state 
      t.datetime   :queued_at
      t.datetime   :sended_at
      t.timestamps
    end
    add_index :amz_mailer_logs, [:mailer_id, :subscription_id], name: 'amz_mailer_logs_subscription_id_and_mailer_id', unique: true, using: :btree

  end

  def down
    drop_table :amz_mailer_logs
  end
end
