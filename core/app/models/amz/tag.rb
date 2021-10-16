module Amz
  class Tag < Amz::Base
    has_and_belongs_to_many :reviews
    has_many :reviews_tags, dependent: :destroy
      
    validates  :name, presence: true 
 

  end
end
