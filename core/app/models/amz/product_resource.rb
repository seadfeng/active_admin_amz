module Amz
  class ProductResource < Amz::Base
    belongs_to :product
    belongs_to :resource, polymorphic: true 
  end
end
