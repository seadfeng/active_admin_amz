class RemoveDeletedAtForAmazon < ActiveRecord::Migration[6.0]
  def change
    remove_column :amz_amazons, :deleted_at
    remove_column :amz_ebays, :deleted_at
  end
end
