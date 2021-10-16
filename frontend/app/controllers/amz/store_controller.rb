module Amz
  class StoreController < Amz::BaseController
      helper_method :build_searcher
      # helper 'amz/frontend'
      protect_from_forgery with: :exception
      # before_action :set_block, except: [:csrf_meta_tags, :manifest], if: :current_store   
      around_action :set_time_zone, if: :current_store

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActionController::RoutingError, with: :route_not_found 
      
      # rescue_from Exception, with: :render_500
      rescue_from Encoding::CompatibilityError do |exception| 
        render template: "amz/errors/encoding", status: 500
      end 
      rescue_from ThinkingSphinx::ConnectionError, with: :render_500 

      def render_404
        page = current_store.blocks.find_by_identity('page_not_found')

        if page.blank?
          description = "Page Not Found"
        else
          description = page.description
        end
        @title = "404 Page Not Found"
        respond_to do |format|
          format.html { render template: 'amz/errors/error_404', status: 404,  locals:{ page_not_found: description }}
          # format.all  { render nothing: true, status: 404 }
        end
      end

      def render_500
        render inline: '500 Error', status: 500 
      end

      def not_found
        render_404
      end

      def route_not_found
        not_found
      end

      def record_not_found
        render template: 'amz/errors/error_404',  locals:{ page_not_found: I18n.t('views.record_not_found', default: 'Record Not Found') } , status: 200 
      end

      def csrf_meta_tags
        render layout: nil
      end 

      private

      def set_time_zone(&block)
        Time.use_zone(current_store.preferred_time_zone, &block) unless current_store.preferred_time_zone.blank?
      end 
      
      def search_popular 
        begin 
          # Todo store search
          # @search_popular = Amz::Search.search(params[:keywords], limit: 10, populate: true)  
          @search_popular = []

        rescue => exception 
          @search_popular = []
        end  
        if params[:keywords].present? || params[:keyword].present?
          @placeholder = params[:keywords] 
          @placeholder = params[:keyword] if @placeholder.blank?
        else
          @placeholder = nil
        end 
      end 

      def widget_resource(widget) 
        case widget.resource_type 
        when 'Block' 
            limit = 5
            if widget.component_type == 'Tabs'
                widget.contents.limit(limit).map { |val| {content: val.resource.description, name: val.resource.name }}
            end
        when 'Taxon' 
          widget.contents.limit(3).map { |val| 
            {
              name: val.resource.name, 
              url: helpers.seo_url(val.resource),
              image: large_url_image(val.resource.image),  
              children: val.resource.children.limit(3).map{ |taxon| 
                {
                  name: taxon.name,
                  url: helpers.seo_url(taxon),
                } 
              }
            }
          }
        when 'Article' 
          if widget.component_type == 'BannerCard'
            limit = 4
          else
            limit = 10
          end
          max_article_description = Amz::Config[:max_article_description_in_widgets]
          widget.contents.limit(limit).map { |val| { name: val.resource.name,  
                                                     url:  helpers.seo_url(val.resource.review), 
                                                     taxon_url: helpers.seo_url(val.resource.store_review.taxons&.first), 
                                                     description: helpers.sanitize(description(val.resource).truncate(max_article_description)).gsub(/<.*?>/,'') , 
                                                     taxon: val.resource.store_review.taxons.first&.name , 
                                                     published_at: val.resource.visible?? short_time(val.resource.published_at) : '', 
                                                     visible: val.resource.visible?  , 
                                                     author: val.resource.user.first_name, 
                                                     author_url: amz.author_url(val.resource.user), 
                                                     author_img: mini_url_image(val.resource.user.image),  
                                                     image: review_media_crop_url(style: "medium", review_id: val.resource.store_review.review.slug, scale: "4x3" ), 
                                                     large_image: review_media_crop_url(style: "large", review_id: val.resource.store_review.review.slug, scale: "16x9" ), 
                                                     article: val.resource,
                                                     review: val.resource.store_review.review 
                                              } }

          end
        end


      protected

      def config_locale
        Amz::Frontend::Config[:locale]
      end  
      
      def store_locale
        current_store.cache_locale.code
      end  


  end
end
