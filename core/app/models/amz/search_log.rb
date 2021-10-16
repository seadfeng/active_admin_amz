module Amz
  class SearchLog < Amz::Base
    belongs_to :search

    scope :by_ge_created_at, lambda { |created_at| where( 'created_at >= ?' , created_at) unless created_at.blank? } 
    scope :last_week, -> { by_ge_created_at(1.week.ago) } 
    scope :last_month, ->{ by_ge_created_at(1.month.ago) }
    scope :last_90days, -> { by_ge_created_at(3.months.ago) }

  end
end
