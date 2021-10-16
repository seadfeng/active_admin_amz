class AddLocaleToStore < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_stores, :locale_id, :integer
    add_index :amz_stores, :locale_id

    Amz::Store.all.each do |store|
      store.locale_id = Amz::Locale.first
      store.save!
    end
  end
end
