class AddTableOfContentsToArticle < ActiveRecord::Migration[6.0]
  def up
    add_column :amz_articles, :table_of_contents, :boolean, :default => false  
  end

  def down
    remove_column :amz_articles, :table_of_contents  
  end
end
