class AddAmzPaiToStore < ActiveRecord::Migration[6.0]
  def change 
    add_column :amz_stores, :amz_pai_enabled, :boolean, default: false 
    add_column :amz_stores, :amz_host, :string, defalut: 'webservices.amazon.com'
    add_column :amz_stores, :amz_region, :string, defalut: 'us-east-1'
    add_column :amz_stores, :amz_tag_id, :string
    add_column :amz_stores, :amz_access, :string
    add_column :amz_stores, :amz_secret, :string  
  end
end
