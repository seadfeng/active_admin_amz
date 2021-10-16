class CreateAmzFaqs < ActiveRecord::Migration[6.0]
  def up
    create_table :amz_faqs do |t|
      t.belongs_to :store
      t.belongs_to :store_review
      t.string     :name, null: false, default: ''
      t.text       :description
      t.datetime   :published_at
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :amz_faqs, [:store_id, :name], name: 'amz_faqs_store_id_and_name', unique: true, using: :btree
  end

  def down
    drop_table :amz_faqs
  end
end
