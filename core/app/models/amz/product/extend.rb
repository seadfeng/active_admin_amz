module Amz
    class Product < Amz::Base
        module Extend
            extend ActiveSupport::Concern
            included do
                acts_as_paranoid
                extend Enumerize
                enumerize :state, in: [:draft, :published, :closed, :trash, :error, :import], default: :import  
            end
        end
    end
end