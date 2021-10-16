module Amz
    class CmsController < Amz::StoreController
        
        before_action :load_data

        def show  
            render render_show  
        end

        private

        def render_show
            if is_amp?
                'amp/cms/show'
            else
                'amz/cms/show'
            end
        end

        def load_data
            @cms = Amz::Cms.cache_by_store_id_and_slug(store_id: current_store.id, slug: params[:cms_id])  
            if @cms.slug != params[:cms_id]
                redirect_to "/#{@cms.slug}", :status => 301
            else
                @cm = @cms
            end
        end

        def accurate_title  
            meta_title = @cm.try(:meta_title) 
            meta_title = @cm.try(:name) if meta_title.blank?
            meta_title 
        end 
    end
end