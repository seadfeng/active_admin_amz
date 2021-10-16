module Amz
    class TaxonController < Amz::StoreController

        before_action :load_data

        def show  
                if @taxon.depth < 2 
                    respond_to do |format|
                        format.html { render render_children } 
                    end 
                else
                    respond_to do |format|
                        format.html { render render_show  } 
                    end 
                end   
        end

        private

        def render_children
            if is_amp?
                'amp/taxon/children'
            else
                'amz/taxon/children'
            end
        end

        def render_show
            if is_amp?
                'amp/taxon/show'
            else
                'amz/taxon/show'
            end
        end

        def load_data
            @taxon = current_store.taxons.friendly.find_by_friendly_id(params[:taxon_id])
            # @taxon = Amz::Taxon.cache_by_store_id_and_friendly_id(store_id: current_store.id, friendly_id: params[:taxon_id] )
            if @taxon.permalink != params[:taxon_id]
                redirect_to "/#{@taxon.permalink}", :status => 301
            else
                @searcher = build_searcher(params.merge(store_id: current_store.id, taxon:  @taxon.id  ))   
                if @taxon.depth >= 2 
                    @store_reviews = @searcher.retrieve_store_reviews     
                end
            end 
        end

        def accurate_title  
            meta_title = @taxon.try(:meta_title) 
            meta_title = @taxon.try(:name) if meta_title.blank? 
            meta_title = "#{meta_title} #{t('amz.views.page', default: "Page")}(#{params[:page].to_i})" if params[:page] && params[:page].to_i != 1
            meta_title
        end
    end
end