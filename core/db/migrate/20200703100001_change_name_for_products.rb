class ChangeNameForProducts < ActiveRecord::Migration[6.0]
  def up
    change_column :amz_products, :name, :string, :limit => 355
    change_column :amz_amazons, :name, :string, :limit => 355 
  end

  def down
    change_column :amz_products, :name, :string, :limit => 255
    change_column :amz_amazons, :name, :string, :limit => 255 
  end

  #https://github.com/go-gitea/gitea/issues/2979
end
