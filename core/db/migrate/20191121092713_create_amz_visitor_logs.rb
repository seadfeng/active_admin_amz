class CreateAmzVisitorLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_visitor_logs do |t|
      t.belongs_to :visitor
      t.string :url
      t.string :referer
      t.datetime :created_at
    end
  end
end
