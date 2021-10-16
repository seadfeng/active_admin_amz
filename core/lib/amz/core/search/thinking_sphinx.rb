module Amz
    module Core
      module Search
        class ThinkingSphinx < Amz::Core::Search::Base

            attr_accessor :total_found 

            def retrieve_store_reviews  
              curr_page = page || 1   
              extended_base_scope
            end
            
            protected

            def extended_base_scope
              begin
                get_reviews_conditions_for(nil, keywords) 
              rescue
                super
              end
            end

            def get_reviews_conditions_for(base_scope,query)
                
                begin   
                  search_options = { :page => page, :per_page => per_page  }  

                  if facets_hash
                    search_options.merge!(:conditions => facets_hash)
                  end  

                  with_opts = { :store_id => current_store.id }   
                  
                  if taxon 
                    with_opts.merge!(:taxon_ids => taxon.id)
                  end
 

                  search_options.merge!(:with => with_opts)  
                  search_options.merge!(:without => without)  
                  facets = Amz::StoreReview.facets(query, search_options)
                  result = facets.for({})
                   
                  @total_found = result.total_entries  
 
                  @properties[:facets] = parse_facets_hash(facets)
                  @properties[:suggest] = nil if @properties[:suggest] == query 

                  result
                   
                  # if taxon  
                    # Amz::StoreReview.joins(:classifications ).select("amz_store_reviews_taxons.position, amz_store_reviews_taxons.taxon_id, amz_store_reviews.*").where("amz_store_reviews_taxons.taxon_id": taxon.id )
                    #                                                     .where("amz_store_reviews.id IN (?)", store_reviews.map(&:id)) 
                    #                                                     .order('amz_store_reviews_taxons.position asc')
                  # else
                    # Amz::StoreReview.where("amz_store_reviews.id IN (?)", store_reviews.map(&:id)).published 
                  # end 
                rescue  
                  @total_found = super.count
                  super 
                end 
                
            end

            def prepare(params)
                store =  params[:store_id].blank? ? nil : Amz::Store.find(params[:store_id].to_i)
                @properties[:facets_hash] = params[:facets] || {}
                @properties[:taxon] = params[:taxon].blank? ? nil : Amz::Taxon.find(params[:taxon])
                @properties[:sort_by] = params[:sort_by] || 'default' 
                @properties[:keywords] = params[:keywords] 
                @properties[:search] = params[:search] 
                @properties[:without] = params[:without] || {}
                per_page = params[:per_page].to_i
                @properties[:per_page] = per_page > 0 ? per_page : (store.nil?? Amz::Config[:reviews_per_page] : store.preferred_reviews_per_page)
                @properties[:page] = if params[:page].respond_to?(:to_i)
                                        params[:page].to_i <= 0 ? 1 : params[:page].to_i
                                    else
                                        1
                                    end
                @properties[:manage_pagination] = true 
            end

            private 
            # method should return new scope based on base_scope
            def parse_facets_hash(facets_hash = {})
                facets = [] 
                facets_hash.each do |name, options|
                    next if options.size <= 1
                    facet = Facet.new(name)
                    options.each do |value, count|
                    next if value.blank?
                    facet.options << FacetOption.new(value, count)
                    end
                    facets << facet
                end
                facets
            end
        end

        class Facet
            attr_accessor :options
            attr_accessor :name
            def initialize(name, options = [])
              self.name = name
              self.options = options
            end
        
            def self.translate?(property)
              return true if property.is_a?(ThinkingSphinx::Field)
        
              case property.type
              when :string
                true
              when :integer, :boolean, :datetime, :float
                false
              when :multi
                false # !property.all_ints?
              end
            end
        end

        class FacetOption
            attr_accessor :name
            attr_accessor :count
            def initialize(name, count)
              self.name = name
              self.count = count
            end
        end


      end
    end
end
