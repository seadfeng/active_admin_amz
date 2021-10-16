class AddResultToSearch < ActiveRecord::Migration[6.0]
  def up 
    add_column :amz_searches, :results, :integer, default: 0
  end
  def down
    remove_column :amz_searches
  end
end
