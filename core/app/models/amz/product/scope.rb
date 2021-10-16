module Amz
    class Product < Amz::Base
        module Scope
            extend ActiveSupport::Concern
            included do
                scope :by_states ,lambda {  |states| where("state": states ) unless states.blank? } 
                scope :by_ge_available_on, lambda { |available_on| where(  "#{Product.quoted_table_name}.available_on is not null and #{Product.quoted_table_name}.available_on <= ? " , available_on) unless available_on.blank? } 
                scope :by_lt_available_on, lambda { |available_on| where(  "#{Product.quoted_table_name}.available_on is not null and #{Product.quoted_table_name}.available_on > ? " , available_on) unless available_on.blank? } 
                scope :by_lt_discontinue_on_or_null, lambda { |discontinue_on| where( "#{Product.quoted_table_name}.discontinue_on is null or #{Product.quoted_table_name}.discontinue_on > ?" , discontinue_on) unless discontinue_on.blank? } 
                scope :by_ge_discontinue_on, lambda { |discontinue_on| where( "#{Product.quoted_table_name}.discontinue_on <= ?" , discontinue_on) unless discontinue_on.blank? } 
                scope :by_lt_discontinue_on, lambda { |discontinue_on| where( "#{Product.quoted_table_name}.discontinue_on > ?" , discontinue_on) unless discontinue_on.blank? } 

                # scope :deleted, ->{ where("deleted_at is not null")}
                scope :not_deleted, ->{ where("#{Product.quoted_table_name}.deleted_at is null")}
                scope :discontinue_on_not_null, ->{ where("#{Product.quoted_table_name}.discontinue_on is not null")}
                scope :locked, ->{ where("#{Product.quoted_table_name}.locked = true")}
                scope :unlocked, ->{ where("#{Product.quoted_table_name}.locked = false")}

                scope :non_description, ->{ where("#{Product.quoted_table_name}.description is null or #{Product.quoted_table_name}.description = '' ")} 

                scope :available, ->{ by_ge_available_on(Time.current).by_lt_discontinue_on_or_null(Time.current).not_deleted }
                scope :will_available, ->{ by_lt_available_on(Time.current).where("#{Product.quoted_table_name}.discontinue_on > #{Product.quoted_table_name}.available_on").discontinue_on_not_null.not_deleted }
                scope :discontinue, ->{ by_ge_discontinue_on(Time.current).not_deleted}
                scope :will_discontinue, ->{ by_lt_discontinue_on(Time.current).not_deleted} 

                scope :published, ->{ by_states("published") }  
                scope :closed, ->{ by_states("closed") }   
                scope :draft, ->{ by_states("draft")  }   
                scope :trash, ->{ by_states("trash")  } 
                scope :error, ->{ by_states("error")  } 
                scope :imports, ->{ by_states("import")  } 

                scope :visible, ->{ published.available }   
                scope :discontinued, ->{ discontinue }
            end
        end
    end
end