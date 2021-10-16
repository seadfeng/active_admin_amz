class CreateAmzStoreReviewsTaxons < ActiveRecord::Migration[6.0]
  def change
    create_table :amz_store_reviews_taxons do |t|
      t.belongs_to :store_review
      t.belongs_to :taxon
      t.integer    :position,          default: 0
      t.timestamps
    end
    add_index :amz_store_reviews_taxons, [:store_review_id, :taxon_id], name: 'store_review_taxon_by_str_id_and_tx_id', unique: true, using: :btree 
  end
end
