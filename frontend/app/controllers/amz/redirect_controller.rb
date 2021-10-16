module Amz
    class RedirectController < Amz::StoreController
        # before_action :load_taxon
        def index
            if params[:pid].present? && params[:type].present?  
                product = Product.find(params[:pid])  
                @product = product
                keywords = ""
                category = "None"
                if params[:rid].present? && @store_review  = StoreReview.find(params[:rid])   
                    keywords = @store_review.seo_name 
                    keywords = keywords.gsub(/\s+/,"+") 
                    category = @store_review.seo_name
                end
                @title = product.name
                if params[:type] == 'ebay'
                    redirect = current_store.redirects.find_or_create_by(store_id: current_store.id, resource: product.ebay)
                    redirect.viewed!
                    # redirect_to ebay_link(product) 
                    @redirect = ebay_link(product)
                    render layout: "amz/layouts/empty", locals: { referer: request.referer, product: product, action: "Link To Ebay", category: category  }
                else
                    redirect = current_store.redirects.find_or_create_by(store_id: current_store.id, resource: product.amazon)
                    redirect.viewed!
                    # redirect_to amazon_link(product)
                    @redirect = amazon_link(product,keywords)
                    render layout: "amz/layouts/empty", locals: { referer: request.referer, product: product, action: "Link To Amazon", category: category}
                end 
            else
                render inline: "404 Not Found", status: 404
            end 
        end

        private

        def load_taxon
            @taxon = nil
            @taxon = current_store.taxons.find(params[:tid]) if params[:tid].present? 
        end

        def amazon_link(product,keywords = '')
            "#{product.amazon_product_url}?tag=#{current_store.amz_tag_id}&keywords=#{keywords}"
        end

        def ebay_link(product)
            #Todo
        end
    end
end
