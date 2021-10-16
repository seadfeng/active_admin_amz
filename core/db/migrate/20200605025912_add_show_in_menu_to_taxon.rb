class AddShowInMenuToTaxon < ActiveRecord::Migration[6.0]
  def up
    add_column :amz_taxons, :show_in_menu, :boolean, default: true 
  end

  def down
    remove_column :amz_taxons
  end
end
