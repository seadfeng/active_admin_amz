ThinkingSphinx::Index.define 'amz/search', :with => :active_record do
    indexes name, :sortable => true   
    indexes results, :sortable => :true  
    indexes used, :sortable => :true 

    has store_id, :type => :integer
    has created_at, :type => :timestamp 
    has updated_at, :type => :timestamp 
    where sanitize_sql("#{Amz::Search.quoted_table_name}.results > 0 and disabled = 0")  
end
