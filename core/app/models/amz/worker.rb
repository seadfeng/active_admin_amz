module Amz
  class Worker <  Amz::Base
    belongs_to :resource, polymorphic: true 
    
  end
end
