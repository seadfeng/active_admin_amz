module Amz
  class ReviewsTag < Amz::Base
    belongs_to :review
    belongs_to :tag
  end
end
