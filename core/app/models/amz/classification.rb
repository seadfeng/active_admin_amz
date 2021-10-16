module Amz
    class Classification < Amz::Base
      self.table_name = 'amz_store_reviews_taxons'
      acts_as_list scope: :taxon
  
      with_options inverse_of: :classifications, touch: true do
        belongs_to :store_review, class_name: 'Amz::StoreReview'
        belongs_to :taxon, class_name: 'Amz::Taxon'
      end
  
      validates :taxon, :store_review, presence: true
      # For #3494
      validates :taxon_id, uniqueness: { scope: :store_review_id, message: :already_linked, allow_blank: true }
      before_validation :set_position

      def set_position
        self.position = store_review.scanned
      end
    end
end