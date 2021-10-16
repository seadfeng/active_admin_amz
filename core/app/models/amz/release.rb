module Amz
  class Release < Amz::Base
    belongs_to :logable, polymorphic: true  
  end
end
