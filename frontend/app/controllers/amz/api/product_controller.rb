module Amz
    module Api
        class ProductController < Amz::Api::BaseController
            before_action :load_data, only: :show
            before_action :check_store_review , only: :index

            def index  
                products = params["products"]
                store_id =  params[:store_id]
                review_id =  params[:review_id]
 
                products.each do |item| 
                    unless item["brand"].blank?
                        @brand = Amz::Brand.find_or_create_by(name: item["brand"])
                    end
                    unless item["asin"].blank? || item["name"].blank?
                        product = Amz::Product.find_by(store_id: store_id, sku: item["asin"] )
                        if product.blank? 
                            product = Amz::Product.create(store_id: store_id, name: item["name"], sku: item["asin"], brand_id: @brand&.id )
                        end
                        if product.asin.blank?
                            product.asin = item["asin"]
                            product.save
                        end
                        unless product.blank? 
                            store_review = Amz::StoreReview.find_or_create_by( store_id: store_id, review_id: review_id  ) 
                            store_review_product = store_review.store_review_products.find_or_create_by( product_id: product.id) 
                        end 
                    end  
                end
                render  json: { counts: products.size , status: "Ok"} 
            end

            def show   
                render json: { id: @product.id, name: @product.name, asin: @product.asin  }
            end

            private

            def check_store_review
                if params[:store_id].blank?  || params[:review_id].blank? 
                    return render_403
                end
            end

            def load_data
                @product = Amz::Product.find(params[:id])
                return render_403 if @product.blank? 
            end

        end
    end
end