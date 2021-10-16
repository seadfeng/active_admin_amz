module Amz::RansackableAttributes
    extend ActiveSupport::Concern
    included do 
      class_attribute :default_ransackable_attributes
      self.default_ransackable_attributes = %w[id name updated_at created_at]
  
      def self.ransackable_associations(*_args)
         []
      end
  
      def self.ransackable_attributes(*_args)
        default_ransackable_attributes 
      end
  
      def self.ransackable_scopes(*_args)
         []
      end
    end
  end