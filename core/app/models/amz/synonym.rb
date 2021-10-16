module Amz
  class Synonym < Amz::Base
    belongs_to :store

    with_options presence: true do 
      validates :name 
    end

    validates_uniqueness_of :name, case_sensitive: false, allow_blank: false , scope: :store     


  end
end
