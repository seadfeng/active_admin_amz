class CreateAmzArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_articles do |t|
      t.belongs_to :store_review
      t.belongs_to :user
      t.string :name,     null: false, default: ''
      t.string :title,    null: false, default: ''
      t.text   :description
      t.datetime :published_at
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :amz_articles, [:store_review_id, :title], name: 'product_by_store_review_id_and_title', unique: true, using: :btree 
  end
end
