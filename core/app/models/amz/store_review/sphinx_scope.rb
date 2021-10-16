module Amz
    class StoreReview < Amz::Base
        module SphinxScope
            extend ActiveSupport::Concern
            included do
                include ThinkingSphinx::Scopes
 
                sphinx_scope(:popular) { 
                    {
                        :select => "*, weight() as w",
                        :order => 'w DESC',
                        :field_weights => { 
                            :name => 10,
                            :review_name => 10, 
                            :review_meta_title => 9,
                            :meta_title => 9,
                            :product_brands => 8,
                            :product_names => 5,
                            :scanned => 7
                        }
                    } 
                }
                
                sphinx_scope(:by_name) { |name|
                    {:conditions => {:name => name}}
                }
                
                sphinx_scope(:by_store) { |store_id|
                    {:with => {:store_id => store_id} }
                }

                default_sphinx_scope :popular
            end
        end
    end
end
