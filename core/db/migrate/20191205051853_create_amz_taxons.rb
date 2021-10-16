class CreateAmzTaxons < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_taxons do |t|
      t.belongs_to :taxonomy
      t.references :parent
      t.integer    :position,          default: 0
      t.string     :name,              null: false
      t.string     :meta_title
      t.string     :meta_description 
      t.string     :permalink 
      t.integer    :lft
      t.integer    :rgt 
      t.integer    :depth
      t.text       :description
      t.timestamps  
    end
  end
end
