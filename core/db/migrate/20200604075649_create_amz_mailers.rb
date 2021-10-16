class CreateAmzMailers < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_mailers do |t|
      t.belongs_to :store 
      t.boolean    :only_user, default: false
      t.string     :subject, null: false, default: "" 
      t.text       :body 
      t.text       :style 
      t.datetime   :available_on
      t.datetime   :completed_at
      t.timestamps
    end
  end
end
