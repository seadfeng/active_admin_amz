module Amz
    class ReviewController < Amz::StoreController
        before_action :load_data, only: :show 
        skip_before_action :set_token, only: :media 

        def show
            @seo_title = seo_title  
            if stale?(@store_review) 
                respond_to do |format|
                    if is_amp?
                        format.html { render  template: 'amp/review/show', locals: render_locals }  
                    else
                        format.html { render  locals: render_locals }
                    end  
                end 
            end
        end

        def media
            style = params[:style] 
            @review = current_store.reviews.friendly.find_by_friendly_id(params[:review_id])
            return send_data "", status: 404 if (@review.nil? ||  @review.slug != params[:review_id]  )
            return send_data "", status: 404 if !Amz::Image.styles.map{ |x,idx| x.to_s }.include?(style)
             
            @store_review = current_store.store_reviews.published.find_by(review_id: @review.id )
            return send_data "", status: 404  if @store_review.nil?

            @article = @store_review.master_article
            if @article && @article.image 
                img = MiniMagick::Image::read(@article.image.attachment.download)    
                img.resize Amz::Image.styles.with_indifferent_access[style] 
                img.quality 80 if params[:style] == "large" 
                # if scales.map{ |x,idx| x.to_s }.include?(params[:scale])
                if params[:scale] 
                    if params[:scale].match(/^\d*x\d*$/)
                         img = crop(img) 
                    else
                        return send_data "", status: 404 
                    end
                end
                expires_in 1.year, public: true  
                send_data img.to_blob, type: "image/jpeg" || DEFAULT_SEND_FILE_TYPE, disposition: 'inline' # , disposition: "attachment" 
            else
                send_data "", status: 404  if @store_review.nil?
            end 
        end

        private

        def crop(img) 
            w_original , h_original = [img[:width].to_f, img[:height].to_f]
            o_scale = w_original  /  h_original 
 
            s_width, s_height = params[:scale].split("x").map{ |x| x.to_f }  
            x_scale = s_width / s_height 
            if (o_scale == x_scale)
                img 
            elsif o_scale > x_scale #宽大，截宽 
                nex_width = h_original * x_scale
                nex_height = h_original
                crop_x = (w_original - nex_width) / 2
                crop_y = 0 
                img.crop("#{nex_width}x#{nex_height}+#{crop_x}+#{crop_y}")  
            else o_scale < x_scale #宽小，截高 
                nex_width = w_original 
                nex_height = w_original / x_scale
                crop_y = (h_original - nex_height) / 2
                crop_x = 0 
                img.crop("#{nex_width}x#{nex_height}+#{crop_x}+#{crop_y}") 
            end 
            if x_scale == 1 && params[:style] == "wide"
                img.resize("1200x1200<")
            end
            img
        end 

        def load_data
            @top_number = current_store.preferred_top_number
            @review = current_store.reviews.friendly.find_by_friendly_id(params[:review_id])

            if @review.slug != params[:review_id]
                redirect_to "/#{@review.slug}", :status => 301
            else 
                @store_review = current_store.store_reviews.published.find_by(review_id: @review.id ) 
                if @store_review.nil?
                    record_not_found 
                else
                    @taxon = @store_review.taxons.order('depth desc')&.first
                    @article = @store_review.master_article
                    @store_review_products = @store_review.store_review_products.limit(@top_number)  
                    @faqs = @store_review.faqs.published  
                    @recent_articles = Amz::Article.visible.joins(:store_review).where("#{StoreReview.table_name}.store_id": current_store.id).order("#{Article.table_name}.published_at desc").limit(8)
                    unless @article.nil?
                        @author = { name: @article.user.full_name, image: mini_url_image(@article.user.image), url: amz.author_path(@article.user) }
                    end
                end
            end
        end

        def seo_title 
            review_name = @store_review.try(:name) 
            review_name = @review.try(:name) if review_name.blank? 
            t("amz.review.title", number: @top_number, keywords: review_name , year: Time.now.year , default:  current_store.review_title )
        end

        def blog_posting_description
            description =  "#{seo_title}<br/>"
            size = @store_review_products.size
            @store_review_products.each_with_index do |item,index|
                description += "#{index+1}. #{item.name}" 
                description += "<br/>" if index + 1 != size
            end
            description
        end

        def description_marker_subtitle
            @article.description.gsub(/<[hH][34].*?>[\S\s]*?<\/[hH][34]>/){ |char| char.gsub(/id=['"].*?['"]/,'').gsub(/<([hH].*?)>/,"<\\1 id=\"#{char.to_url}\">")  }
        end

        def table_of_contents(description) 
            contents = '<section id="ez-toc-container">'
            contents += "<p class=\"table-of-contents\">#{I18n.t('amz.views.table_of_contents', default: "Table of contents")}</p>" #"Tabla de contenidos"
            contents += "<input aria-label=\"#{I18n.t('amz.views.table_of_contents', default: "Table of contents")}\" data-vars-label=\"Table of Contents Cms Trigger\" class=\"nav-trigger\" type=\"checkbox\">"
            contents += "<nav id=\"table-of-contents\" class=\"nav\"><ul>"
            ctag = ""
            description.scan(/<([hH][234].*?)>([\S\s]*?)<\/[hH][234]>/).each do |obj| 
                if obj[0].match(/h3/)
                    if ctag.blank? 
                        contents += "<li class=\"level1\">"
                    elsif(ctag == "h3" || ctag == "h3-h4") 
                        contents += "</ul>" if ctag == "h3-h4"
                        contents +=  "</li><li class=\"level1\">"
                    end
                    ctag = "h3" 
                    contents +=  "<a href=\"##{obj[1].to_url}\">" + obj[1].gsub(/<.*?>/,'') + "</a>"
                end 
                if obj[0].match(/h4/) 
                    if ctag == "h3"    
                        ctag = "h3-h4"
                        contents +=  "<ul>"
                    elsif ctag == "h3-h4" 
                    end 
                    contents +=   "<li  class=\"level2\"><a href=\"##{obj[1].to_url}\">#{obj[1].gsub(/<.*?>/,'').gsub(/[:].*/,'')}</a></li>"
                end
            end
            contents +=  "</li></ul></nav><i><span class=\"bar1\"></span><span class=\"bar2\"></span><span class=\"bar3\"></span></i></section>"
        end

        def description_table_of_contents
            unless @article.nil? 
                description = description_marker_subtitle
                description = description.gsub(/(href=\"\#.*?\")/,'data-turbolinks="false" \1') unless is_amp?
                  
                if @article.table_of_contents
                    tables = table_of_contents(description) 
                    description = description.sub(/(<[hH]\d.*?>)/,"#{tables}\\1")
                end 
                description
            end
        end

        def accurate_title  
            meta_title = @store_review.seo_meta_title 
            
            if meta_title.blank?
                meta_title = seo_title || super 
            else
                I18n.t('amz.review.meta_title', meta_title: meta_title , year: Time.now.year , default: "%{meta_title} of %{year}")
            end
        end 

        def render_locals
            time = Time.new
            
            reviews_scanned = nil
            reviews_scanned = I18n.t('amz.review.scanned', scanned: @review.scanned, default: '%{scanned} Reviews Scanned') if  @review.scanned > 0
            share_text = I18n.t('amz.views.share', default: 'Share') 
            best_10_text = I18n.t("amz.views.best_top_x", number: @top_number, default: "%{number} Best")
            page_title = I18n.t('amz.review.page_title', keywords: @store_review.seo_name , datatime: I18n.l(Time.current, format: :month, locale: :"#{current_store.cache_locale.code}") , default: '<b>%{keywords}</b> of %{datatime}')
            nav_title =  I18n.t('amz.review.nav_title', number: @top_number , keywords: @store_review.seo_name , datatime: time.strftime('%Y'), default: 'Top %{number} <b>%{keywords}</b> of %{datatime}' )
            # nav_title =  "#{best_10_text} <b>#{@store_review.seo_name}</b> #{time.strftime('%Y')}" 

            view_deal = I18n.t('amz.views.view_deal', default: 'View Deal') 
            more_info = I18n.t('amz.views.more_info', default: 'More Info') 
            show_more = I18n.t('amz.views.show_more', default: 'Show More') 
            show_less = I18n.t('amz.views.show_less', default: 'Show Less') 
            close = I18n.t('amz.views.close', default: 'Close') 
            product_highlights = I18n.t('amz.views.product_highlights' , default: 'Product Highlights')
            best_value_text = I18n.t('amz.views.most_savings' , default: 'Most Savings')
            top_choice = I18n.t('amz.views.top_choice' , default: 'Top Choice')

            reviews = I18n.t('amz.views.reviews' , default: 'Reviews')
            popularity = I18n.t('amz.views.popularity' , default: 'Popularity')
            features_quality = I18n.t('amz.views.features_quality' , default: 'Features Quality')
            brand_reputation = I18n.t('amz.views.brand_reputation' , default: 'Brand Reputation')
            how_we_score = I18n.t('amz.views.how_we_score' , default: 'How we Score')
            learn_more = I18n.t('amz.views.learn_more' , default: 'Learn More')

            block = {
                reviews: reviews,
                popularity: popularity,
                brand_reputation: brand_reputation,
                features_quality: features_quality,
                how_we_score: how_we_score,
                learn_more: learn_more
            }
            

            locals = {
                block: block,
                title: page_title,
                reviews_scanned: reviews_scanned,
                best_10_text: best_10_text,
                share_text: share_text,
                nav_title: nav_title,
                store_review_products: @store_review_products,

                view_deal: view_deal,
                more_info: more_info,
                show_more: show_more,
                show_less: show_less,
                close: close,
                product_highlights: product_highlights,
                best_value_text: best_value_text,
                top_choice: top_choice,

                reviews: reviews,
                popularity: popularity,
                features_quality: features_quality,
                brand_reputation: brand_reputation,
                how_we_score: how_we_score, 
                blog_posting_description: blog_posting_description,
                description_table_of_contents: description_table_of_contents 
            }
        end

    end
end