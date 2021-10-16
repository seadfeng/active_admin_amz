class CreateAmzTaxonomies < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_taxonomies do |t|  
      t.string     :name,  null: false
      t.string     :permalink 
      t.integer    :position,          default: 0
      t.timestamps
    end
  end
end
