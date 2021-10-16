class AddDeletedAtToFriendlyId < ActiveRecord::Migration[6.0]
  def change
    add_column :friendly_id_slugs, :deleted_at, :datetime
  end
end
