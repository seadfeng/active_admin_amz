ActiveAdmin.register Amz::StoreReview, as: "StoreReview" do
    init_controller
    belongs_to :store,  optional: true
    config.sort_order = 'id_desc'  
    permit_params  :name,  :meta_title, :meta_description, :store_id, :review_id, :description,
                   taxon_ids: [],  
                   store_review_products_attributes: [:id, :score, :name ] 
    batch_action :destroy, false
    actions :all, except: [:destroy, :new ]   
    menu priority: 2, parent: "Reviews" 

    active_admin_paranoia   
    # tabs :info, models: [:products, :related_reviews]
 
    scope :non_faqs
    scope :has_faqs
    scope :draft
    scope :published  

    controller do
      def update 
        if params[:amz_store_review].present? 
          if params[:store_review].present? 
            params[:store_review][:taxon_ids] = params[:amz_store_review][:taxon_ids] 
          else
            params[:store_review] = params[:amz_store_review] 
          end
        end
        super
      end 
    end

    show do
        render 'admin/store_reviews/show' 
        render 'admin/store_reviews/faqs'
        render 'admin/store_reviews/new_faq'
    end 

    index do 
		  selectable_column
        id_column  
        column :store do |source|
          source.store.domain
        end
        column :name do |store_review|
          
          if store_review.review && store_review.published?
            link_to(store_review.seo_name,  seo_url(store_review), target: '_blank')
          else
              store_review.seo_name
          end
        end
        column :meta_title do |source| 
          meta_title = source.seo_meta_title 
          if meta_title.blank? 
            meta_title = t("amz.review.title", number: source.store.top_number, keywords: source.seo_name , year: Time.now.year , default:  source.store.review_title )
          else
            meta_title = t('amz.review.meta_title', meta_title: meta_title , year: Time.now.year , default: "%{meta_title} of %{year}")
          end
          link_to meta_title, admin_review_path(source.review) if source.review
        end 
        column :scanned 
        column :faqs do |store_review|
          ol do
            store_review.faqs.each do |faq| 
                 li do
                    auto_link faq
                 end
            end 
          end
        end
        column :articles do |store_review|
          ul do
            store_review.articles.each do |article| 
                 li do
                    auto_link article
                 end
            end 
        end
        end
        # column :taxons do |store_review|
        #   ul do
        #       store_review.taxons.each do |taxon| 
        #            li do
        #               link_to(taxon.pretty_name,  seo_url(taxon), target: '_blank') 
        #            end
        #       end 
        #   end
        # end 
        column :published_at 
        column :updated_at 
        actions defaults: false do |store_review|
          item t('active_admin.articles.name', default: "Articles" ),  admin_store_review_articles_path(store_review), class: "member_link", method: :get if authorized?(ActiveAdmin::Auth::READ , store_review) 
          item t('active_admin.view' ),  admin_store_review_path(store_review), class: "member_link", method: :get if authorized?(ActiveAdmin::Auth::CREATE , store_review) 
          item t("active_admin.edit" ),  edit_admin_store_review_path(store_review), class: "member_link" if authorized?(ActiveAdmin::Auth::UPDATE , store_review) 
      end
    end

    filter :id 
    filter :review_name, as: :string
    filter :name    
    filter :store        


    form do |f|
        f.inputs I18n.t("active_admin.store_reviews.form" , default: "Store Review")  do    
          f.input :name,  :hint => f.object.review.name, input_html: { placeholder: f.object.review.name } 
          f.input :meta_title,  :hint => f.object.review.meta_title ,input_html: { placeholder: f.object.review.meta_title}  
          f.input :meta_description, as: :text,  :hint => f.object.review.meta_description, input_html: { rows: 3, placeholder: f.object.review.meta_description} 
          f.input :description, as: :ckeditor , input_html: { ckeditor: { height: 300 } }, :hint => f.object.review.description

          f.inputs do
            f.has_many :store_review_products, heading: 'Products', allow_destroy: false, new_record: false do |i|
                # i.input :name, :hint => i.object.product.amazon.name
                i.input :score, :hint => mini_image(i.object.product) , label: i.object.name 
            end 
          end
          
        end
        f.actions
    end 

    sidebar :review_info, only: :show do 
        render "admin/store_reviews/view_sidebar"
    end
    sidebar :taxon, only: :show do  
        render "admin/store_reviews/taxon" 
    end
    # sidebar :new_product, only: :show do  
    #     render "admin/store_reviews/new_product" 
    # end  

    # BOF Publish Action
    action_item :publish, only: :show, if: proc{  authorized?(ActiveAdmin::Auth::PUBLISH, active_admin_config.resource_class) && resource.can_published? } do 
        link_to(
          t('active_admin.publish', default: "Publish"),
          action: :publish
        ) 
    end

    action_item :reviews, only: :index do
      if authorized?(ActiveAdmin::Auth::READ, "Amz::Review")
        link_to(
          I18n.t('active_admin.review', default: "Reviews"), 
          admin_reviews_path
        ) 
      end
    end

    action_item :preview, only: :show do
      if resource.published?
        link_to t("amz.preview") , helpers.seo_url(resource), target: "_blank" 
      end
    end

    batch_action :publish, if: proc{ params[:scope] == 'draft'  }  do |ids|
      batch_action_collection.find(ids).each do |source|  
        source.published!
      end
      options = { notice: t('active_admin.batch_actions.succesfully_updated', count: ids.count, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
      redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end

    member_action :publish, method: :get, if: proc{ authorized?(ActiveAdmin::Auth::PUBLISH, active_admin_config.resource_class) } do
      authorize!(ActiveAdmin::Auth::PUBLISH, active_admin_config.resource_class)  
      resource.published!
      options = { notice: I18n.t('active_admin.published', default: "published")}
      redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end 

end
