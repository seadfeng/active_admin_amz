class CreateAmzFrontendControllers < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_frontend_controllers do |t|
      t.string :name, null: false, default: ''
      t.string :presentation 
      t.timestamps
    end
  end
end
