module Amz
    class AuthorController < Amz::StoreController
        before_action :load_data
        def show 
             render render_show
        end

        private

        def render_show
            if is_amp?
                'amp/author/show'
            else
                'amz/author/show'
            end
        end

        def load_data
            curr_page = params[:page] || 1
            per_page = params[:per_page] || 20
            # @author = AdminUser.joins(articles: :store_review).where("#{Amz::StoreReview.quoted_table_name}.store_id in ?", current_store.id)
            @author = AdminUser.with_rich_text_content.find_by_id(params[:id])
            if @author.nil? || !@author.articles.any?
                route_not_found 
            else
                max_article_description = Amz::Config[:max_article_description_in_widgets]
                @articles = @author.articles.joins(:store_review).where("#{StoreReview.quoted_table_name}.store_id in (?)", current_store.id).visible.page(curr_page).per(per_page)
                @articles_map = @articles.map {|article| {
                            name: article.name, 
                            image: review_media_crop_url(style: "large", review_id: article.store_review.review.slug, scale: "16x9" ), 
                            taxon_url: helpers.seo_url(article.store_review.taxons&.first), 
                            url:  helpers.seo_url(article.store_review),  
                            description:  helpers.sanitize(description(article).truncate(max_article_description)).gsub(/<.*?>/,''), 
                            taxon: article.store_review.taxons&.first&.name , 
                            published_at: article.visible?? short_time(article.published_at) : '',
                            large_image: review_media_crop_url(style: "large", review_id: article.store_review.review.slug, scale: "16x9" ), 
                            article: article,
                            review: article.store_review.review 
                        } 
                    }
                @author_component = { name: @author.full_name, image: product_url_image(@author.image), content: @author.content&.body, url: amz.author_url(@author) } 
            end
        end

        def accurate_title    
            meta_title = I18n.t('amz.author.title', name: @author.full_name, year: Time.now.year ,  default: "Best Reviews and Articles by %{name} of %{year}")
            meta_title = "#{meta_title} #{t('amz.views.page', default: "Page")}(#{params[:page].to_i})" if params[:page] && params[:page].to_i != 1
            meta_title
        end 
    end
end