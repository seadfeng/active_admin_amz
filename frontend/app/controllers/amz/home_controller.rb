module Amz
  class HomeController < Amz::StoreController
    helper 'amz/reviews'
    respond_to :html 
    before_action :load_data

    def index
      # controller_widgets
      widgets = helpers.controller_widgets
      @controller_widgets = nil 
      unless widgets.blank?
        @controller_widgets = widgets.map {|val| {title: val.title, 
                                                  description: description(val), 
                                                  resources:  widget_resource(val)  , 
                                                  show_title: val.show_title, 
                                                  component_type: val.component_type , 
                                                  resource_type: val.resource_type  }}
      end
      limit = 10
      max_article_description = Amz::Config[:max_article_description_in_widgets]
      @last_published = Amz::Article.visible.joins(:store_review).where("#{StoreReview.table_name}.store_id": current_store.id).order("#{Article.table_name}.published_at desc").limit(limit).map { 
        |obj| { name: obj.name,  
        url:  helpers.seo_url(obj.review), 
        taxon_url: helpers.seo_url(obj.store_review.taxons&.first), 
        description: helpers.sanitize(description(obj).truncate(max_article_description)).gsub(/<.*?>/,'') , 
        taxon: obj.store_review.taxons.first&.name , 
        published_at: obj.visible?? short_time(obj.published_at) : '', 
        visible: obj.visible?  , 
        author: obj.user.first_name, 
        author_url: amz.author_url(obj.user), 
        author_img: mini_url_image(obj.user.image), 
        image: review_media_crop_url(style: "medium", review_id: obj.store_review.review.slug, scale: "4x3" ), 
        large_image: review_media_crop_url(style: "large", review_id: obj.store_review.review.slug, scale: "16x9" ), 
        article: obj,
        review: obj.store_review.review 
      } }

      respond_to do |format|
        if is_amp?
            format.html { render  template: 'amp/home/index'  }  
        else
          format.html 
        end  
      end 
    end

    private 

    def title
      @title = "#{current_store.name} - #{current_store.meta_title}"
    end
    
    def load_data
      block = current_store.blocks.find_by_identity('home_sub_header')
      @home_sub_header = block.description  unless block.blank?
    end
 
  end
end
