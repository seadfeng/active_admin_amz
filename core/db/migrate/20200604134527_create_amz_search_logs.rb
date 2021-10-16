class CreateAmzSearchLogs < ActiveRecord::Migration[6.0]

  def up
    create_table :amz_search_logs do |t|
      t.belongs_to :search
      t.datetime :created_at
    end
  end

  def down 
    drop_table :amz_search_logs 
  end
  
end
