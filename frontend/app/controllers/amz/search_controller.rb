module Amz
    class SearchController < Amz::StoreController
        # before_action :search_popular 
        def processing
           return render_404 if params[:keywords].blank?
           keywords = params[:keywords]
           search = current_store.searches.find_or_create_by(name: keywords)
           search.count!
           if search.redirect_url.blank?
                redirect_to results_path(keywords: keywords ), status: 302
           else 
                redirect_to search.redirect_url, status: 302 
           end
        end

        def popular 
            return render_404 if params[:keywords].nil?
            # if request.xhr?
                search_keywords = params[:keywords]
                
                current_store.synonyms.each do |synonym| 
                    synonym_name = synonym.name 
                    search_keywords = search_keywords.gsub(/#{synonym_name}/i,synonym.renew)  
                end 
                begin 
                    @excerpter = ThinkingSphinx::Excerpter.new 'amz_store_review_core', search_keywords
                rescue => exception 
                    @excerpter = nil
                end 
                begin 
                    top_number = current_store.preferred_top_number
                    @searcher = Amz::StoreReview.search( search_keywords , limit: 6, populate: true, :with => {:store_id =>  current_store.id })  
                    @searcher = @searcher.map{   |store_review|
                        name = store_review.name.blank? ? store_review.review.name : store_review.name
                        {
                            id: store_review.id,
                            name: (@excerpter.nil? ? name : (@excerpter.excerpt! name )),
                            alt: name,
                            url: helpers.seo_url(store_review.review),
                            image: product_url_image(store_review.products.first),
                            reviews: t('amz.search.reviews', count:  store_review.scanned  , default: "%{count} reviews" ),
                            title: t('amz.search.sub_title', name:  name , number: top_number,  default: "See the Top %{number} %{name}" )
                        } 
                    }
                rescue => exception 
                    @searcher = []
                end   
            
                response.headers['AMP-Redirect-To'] = results_url(keywords: params[:keywords] )
                response.headers['Access-Control-Expose-Headers'] = "AMP-Redirect-To"
                
                respond_to do |format|
                    format.html { redirect_to results_path(keywords: params[:keywords] ), status: 302   } 
                    format.json { render json:  { items: @searcher } } 
                end  
            # else
            #     processing
            # end
        end

        def show
            return render_404 if params[:keywords].blank?
            keywords = params[:keywords] 
            if !params[:on_title].blank? && params[:on_title].to_i = 1
                @title = t("views.search.results.title", keywords: keywords , default: current_store.preferred_search_title)
            else
                @title = keywords
            end   

            search_keywords = keywords
            
            current_store.synonyms.each do |synonym| 
                synonym_name = synonym.name 
                search_keywords = search_keywords.gsub(/#{synonym_name}/i,synonym.renew)  
            end 
            
            @searcher = build_searcher(params.merge(store_id: current_store.id, keywords:  search_keywords  )) 
            @store_reviews = @searcher.retrieve_store_reviews  
            
            search = current_store.searches.find_by(name: keywords)
            if search
                search.update_attribute(:results, @searcher.total_found) 
            end

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
                'amp/search/show'
            else
                'amz/search/show'
            end
        end

    end
end
