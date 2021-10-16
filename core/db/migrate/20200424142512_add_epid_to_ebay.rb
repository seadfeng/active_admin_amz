class AddEpidToEbay < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_ebays, :epid, :string   
    add_column :amz_ebays, :epid_image, :string   
    add_index  :amz_ebays, :epid, name: "ebay_on_epid"
    add_index  :amz_ebays, [:epid, :product_id], name: 'product_by_pid_and_epid', unique: true, using: :btree   
  end
end
