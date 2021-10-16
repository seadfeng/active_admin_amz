module Amz
    class SitemapController < Amz::StoreController 

        def index   
            xml_taxons  
            xml_cms
            xml_reviews
            render layout: false
        end

        def taxons 
            load_taxons 
            @title = I18n.t("amz.taxon.sitemap_title", default: "Sitemap For Categories")
            @taxons = @taxons.page(params[:page]).per(per_page) 
            @maps = @taxons.map{ |taxon| 
                [ 
                    name: taxon.name, 
                    url:  helpers.seo_url(taxon),
                ]} 
        end  

        def reviews  
            load_store_reviews 
            @title = I18n.t("amz.review.sitemap_title", default: "Sitemap For Reviews")
            @store_reviews  = @store_reviews .page(params[:page]).per(per_page) 
            @maps = @store_reviews .map{ |reviews| 
                [ 
                    name: taxon.name, 
                    url:  helpers.seo_url(reviews),
                ]} 
        end  


        def xml_taxons
            load_taxons 
            @taxons = @taxons.page(params[:page]).per(1000)
        end

        def xml_reviews
            load_store_reviews 
            @store_reviews = @store_reviews.page(params[:page]).per(1000)
        end

        def xml_cms
            load_cms 
            @cms = @cms.page(params[:page]).per(1000)
        end

        private

        def per_page
            per_page = params[:per_page].to_i
            per_page > 0 ? per_page : (current_store.nil?? Amz::Config[:reviews_per_page] : current_store.preferred_reviews_per_page)
        end

        def load_taxons
            @taxons = current_store.taxons
        end 

        def load_cms
            @cms = current_store.cms.published
        end

        def load_store_reviews
            @store_reviews = current_store.store_reviews.published
        end
    end
end
