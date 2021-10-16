module Amz
    module Api
        class ReviewController < Amz::Api::BaseController
            before_action :load_data, only: :show
            before_action :check_store 

            def index  
                store_reviews = Amz::StoreReview.where( store_id: params[:store_id] )
                limit = 50
                if store_reviews.blank?
                    @reviews = Amz::Review.order('RAND()').limit(limit)
                else
                    @reviews = Amz::Review.where("id not in(?)", store_reviews.pluck(:review_id) ).order('RAND()').limit(limit) 
                end

                render  json: @reviews.map{|x| {id: x.id, name: x.name, has_review: false }}  
            end

            def show  
                store_review = Amz::StoreReview.find_by(store_id: params[:store_id], review_id: params[:id] )
                render  json: {id: @review.id, name: @review.name, has_review: !store_review.blank? }
            end

            def create
                # Not Use
                return render_403 if params[:review_id].blank?  

                @review = Amz::Review.find(params[:review_id]) 
                return render_403 if @review.blank?  

                @store_review = Amz::StoreReview.find_or_create_by(store_id: params[:store_id], review_id: params[:review_id] )  
                return render_403 if @store_review.blank?

                render  json: { id: @review.id, name: @review.name, has_review: true }
            end

            private

            def check_store
                if params[:store_id].blank? 
                    return render_403
                end
            end

            def load_data
                @review = Amz::Review.find(params[:id])
                return render_403 if @review.blank? 
            end

        end
    end
end