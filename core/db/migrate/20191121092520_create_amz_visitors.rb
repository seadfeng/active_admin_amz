class CreateAmzVisitors < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_visitors do |t| 
      t.belongs_to :store
      t.string :accept_language
      t.string :user_agent
      t.string :ip_address
      t.string :cf_country
      t.string :token
      t.timestamps
    end
  end
end
