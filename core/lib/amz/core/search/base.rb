module Amz
  module Core
    module Search
      class Base
        attr_accessor :properties
        attr_accessor :current_store  

        def initialize(params) 
          @properties = {} 
          prepare(params) 
        end

        def retrieve_store_reviews
          @store_reviews = extended_base_scope.published
          curr_page = page || 1  
          @store_reviews = @store_reviews.page(curr_page).per(per_page)
        end 

        # def reviews_active
        #   extended_base_scope
        # end

        def method_missing(name)
          if @properties.key? name
            @properties[name]
          else
            super
          end
        end

        protected

        def extended_base_scope 
          base_scope = Amz::StoreReview.amz_base_scopes 
          base_scope = get_reviews_conditions_for(base_scope, keywords)  
           
          base_scope = Amz::StoreReviews::Find.new(
            scope: base_scope,
            params: {
              filter: {  
                taxons: taxon&.id
              },
              sort_by: sort_by
            },
            stores:  current_store.id
          ).execute
          base_scope = add_search_scopes(base_scope)
          base_scope = add_eagerload_scopes(base_scope)
          base_scope
        end

        def add_eagerload_scopes(scope)
          # TL;DR Switch from `preload` to `includes` as soon as Rails starts honoring
          # `order` clauses on `has_many` associations when a `where` constraint
          # affecting a joined table is present (see
          # https://github.com/rails/rails/issues/6769).
          #
          # Ideally this would use `includes` instead of `preload` calls, leaving it
          # up to Rails whether associated objects should be fetched in one big join
          # or multiple independent queries. However as of Rails 4.1.8 any `order`
          # defined on `has_many` associations are ignored when Rails builds a join
          # query.
          #
          # Would we use `includes` in this particular case, Rails would do
          # separate queries most of the time but opt for a join as soon as any
          # `where` constraints affecting joined tables are added to the search;
          # which is the case as soon as a taxon is added to the base scope.
          # scope = scope.preload(:product_taxon)
          # scope = scope.preload(master: :prices)
          # scope = scope.preload(master: :images) if include_images
          scope
        end

        def add_search_scopes(base_scope)
          if search.is_a?(ActionController::Parameters)
            search.each do |name, scope_attribute|
              scope_name = name.to_sym
              base_scope = if base_scope.respond_to?(:search_scopes) && base_scope.search_scopes.include?(scope_name.to_sym)
                             base_scope.send(scope_name, *scope_attribute)
                           else
                             base_scope.merge(Amz::StoreReview.ransack(scope_name => scope_attribute).result)
                           end
            end
          end
          base_scope
        end

        # method should return new scope based on base_scope
        def get_reviews_conditions_for(base_scope, query)
          unless query.blank?
            base_scope = base_scope.like_any([:name ], [query])
          end
          base_scope
        end

        def prepare(params)  
          @properties[:taxon] = params[:taxon].blank? ? nil : Amz::Taxon.find(params[:taxon])
          @properties[:keywords] = params[:keywords]
          @properties[:search] = params[:search] 
          @properties[:sort_by] = params[:sort_by] || 'default' 
          store =  params[:store_id].blank? ? nil : Amz::Store.find(params[:store_id].to_i)
          per_page = params[:per_page].to_i
          @properties[:per_page] = per_page > 0 ? per_page : (store.nil?? Amz::Config[:reviews_per_page] : store.preferred_reviews_per_page)
          @properties[:page] = if params[:page].respond_to?(:to_i)
                                 params[:page].to_i <= 0 ? 1 : params[:page].to_i
                               else
                                 1
                               end
        end
      end
    end
  end
end
