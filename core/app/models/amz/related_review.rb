module Amz
  class RelatedReview < Amz::Base
    belongs_to :review
    belongs_to :resource, polymorphic: true 
  end
end
