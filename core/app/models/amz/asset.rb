module Amz
  class Asset < Amz::Base
    belongs_to :viewable, polymorphic: true, touch: true , autosave: true
  end
end
