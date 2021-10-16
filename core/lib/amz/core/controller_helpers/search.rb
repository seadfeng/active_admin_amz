module Amz
    module Core
      module ControllerHelpers
        module Search
          def build_searcher(params)
            Amz::Config.searcher_class.new(params).tap do |searcher|
              searcher.current_store = current_store 
            end
          end
        end
      end
    end
  end
