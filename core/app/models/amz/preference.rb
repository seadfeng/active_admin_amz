module Amz
  class Preference < Amz::Base
    serialize :value 
    # validates :key, presence: true 
    validates_uniqueness_of :key, case_sensitive: true, allow_blank: true , presence: true 
  end
end
