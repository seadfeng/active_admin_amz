class CreateAmzWorkers < ActiveRecord::Migration[6.0]
  def up
    create_table :amz_workers do |t|
      t.references :resource, polymorphic: true 
      t.string     :state
      t.string     :action
      t.datetime   :queued_at
      t.datetime   :completed_at
      t.timestamps
    end
  end

  def down
    drop_table :amz_workers
  end
end
