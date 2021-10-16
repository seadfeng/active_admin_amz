module Amz
    class TagController < Amz::StoreController
        def show
            return render_404 if params[:keywords].blank?
            params[:keywords] = params[:keywords].downcase
            keywords = params[:keywords]  

            search_keywords = keywords
            
            current_store.synonyms.each do |synonym| 
                synonym_name = synonym.name 
                search_keywords = search_keywords.gsub(/#{synonym_name}/i,synonym.renew)  
            end 
            
            @searcher = build_searcher(params.merge(store_id: current_store.id, keywords:  search_keywords  )) 
            @store_reviews = @searcher.retrieve_store_reviews  
             

            begin 
                @excerpter = ThinkingSphinx::Excerpter.new 'amz_store_review_core', search_keywords 
            rescue => exception 
                @excerpter = nil
            end   
            @taxon = nil  
            
            respond_to do |format|
                format.html { render render_show  } 
            end 
        end 

        private

        def render_show
            if is_amp?
                'amp/tag/show'
            else
                'amz/tag/show'
            end
        end

        def accurate_title  
            meta_title = t('amz.tag.meta_title', keywords: params[:keywords].split("+").map(&:capitalize).join(" "), default: "%{keywords} Archives" ) 
            meta_title = "#{meta_title} #{t('amz.views.page', default: "Page")}(#{params[:page].to_i})" if params[:page] && params[:page].to_i != 1
            meta_title
        end

    end
end