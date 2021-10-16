module Amz
  class Price < Amz::Base 
    belongs_to :resource , polymorphic: true 
  end
end
