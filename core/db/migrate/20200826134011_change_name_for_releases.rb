class ChangeNameForReleases < ActiveRecord::Migration[6.0]
  def up
    change_column :amz_releases, :name, :string, :limit => 355 
  end

  def down
    change_column :amz_releases, :name, :string, :limit => 255 
  end 
end
