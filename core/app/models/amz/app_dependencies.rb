require 'amz/dependencies_helper'
module Amz
    class AppDependencies
      include Amz::DependenciesHelper
      
      INJECTION_POINTS = [
        :paginator,
        :review_finder
        # :reviews_sorter, 
        # :locale_finder, :review_finder, :category_finder, :product_finder
      ].freeze
      attr_accessor *INJECTION_POINTS

      def initialize
        set_default_services
        set_default_finders
      end
      
      private

      def set_default_ability
        @ability_class = 'Amz::Ability'
      end 

      def set_default_services
        # @reviews_sorter = 'Amz::Review::Sort'
        @paginator = 'Amz::Shared::Paginate'
      end

      def set_default_finders
        # @locale_finder = 'Amz::Locales::Find'
        @review_finder = 'Amz::Reviews::Find'
        # @category_finder = 'Amz::Categories::Find' 
        # @product_finder = 'Amz::Products::Find'
      end
    end 
end