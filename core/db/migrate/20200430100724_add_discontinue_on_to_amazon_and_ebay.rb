class AddDiscontinueOnToAmazonAndEbay < ActiveRecord::Migration[6.0]
  def change
    add_column :amz_amazons, :discontinue_on, :datetime
    add_column :amz_ebays,   :discontinue_on, :datetime
  end
end
