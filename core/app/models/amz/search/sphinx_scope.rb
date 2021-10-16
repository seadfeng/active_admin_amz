module Amz
    class Search < Amz::Base
        module SphinxScope
            extend ActiveSupport::Concern
            included do
                include ThinkingSphinx::Scopes

                sphinx_scope(:latest_created_at) { 
                    {
                        :select => '*, weight() as w',
                        :order => 'created_at DESC, w DESC'
                    }
                }

                sphinx_scope(:popular) { 
                    {
                        :select => "*, weight() as w",
                        :order => 'w DESC, used DESC, results DESC'
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
