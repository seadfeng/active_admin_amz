ActiveAdmin.register Amz::Article, as: "Article" do
    init_controller
    belongs_to :store_review, optional: true
    config.sort_order = 'id_desc'  
    permit_params  :store_review_id,:user_id, :name , :title, :description, :published_at, :attachment, :table_of_contents
    batch_action :destroy, false  
    menu priority: 30, parent: "Reviews"  
    actions :all, except: [ :show]   

    active_admin_paranoia 

    begin
        Amz::Widget.articles.each do |widget|
            batch_action widget.name, if: proc{ params[:scope] == 'visible'  } do |ids| 
                i = 0
                batch_action_collection.find(ids).each do |source|   
                    i += 1  if widget.contents.create(resource_id: source.id, resource_type: 'Amz::Article' )
                end  
                options = { notice: I18n.t('active_admin.batch_action.succesfully_updated', count: i, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
                redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
            end
        end
    rescue => exception 
        nil
    end
    
  
    scope :visible  
    scope :will_visible  

    controller do
        def action_methods     
            if collection_path.include?(controller_path)
                new_actions = super -   [ 'new' ]  
            else 
                super
            end  
        end   
        def create 
            params[:article][:user_id] = current_admin_user.id 
            create! do |format| 
                options = { notice: I18n.t('active_admin.successfully_created', name: resource.name )} 
                format.html { redirect_to admin_store_review_articles_path(resource.store_review), options   }
            end 
        end   
        def scoped_collection
            if (current_admin_user.admin? || current_admin_user.manager?)
                super
            else
                end_of_association_chain.where(user_id: current_admin_user.id) 
            end
        end
    end 

    index as: Amz::Backend::Views::IndexAsUpload do 
		selectable_column
        id_column   
        column :image do |article| 
            link_to mini_image(article.image), large_url_image(article.image), target: "_blank"
        end
        column :name 
        column :title 
        column :store do |article|
            auto_link(article.store) if article.store_review
        end  
        column :store_review 
        column :user 
        column :published_at 
        actions
        # actions defaults: false do |article|
        #     item t('active_admin.view' ),  admin_store_review_article_path(article.store_review, article), class: "member_link", method: :get if authorized?(ActiveAdmin::Auth::CREATE , article) 
        #     item t("active_admin.edit" ),  edit_admin_store_review_article_path(article.store_review, article ), class: "member_link" if authorized?(ActiveAdmin::Auth::UPDATE , article) 
        #     item t("active_admin.delete" ),  edit_admin_store_review_article_path(article.store_review, article ), class: "member_link" if authorized?(ActiveAdmin::Auth::UPDATE , article) 
        # end
    end  

    form do |f|
        store_review = f.object.store_review 
        
        f.inputs I18n.t("active_admin.articles.form" , default: "Article")  do
            li do 
                link_to(" Preview: #{store_review.seo_name}",  seo_url(store_review), target: '_blank') 
            end
            f.input :user if current_admin_user.admin?
            f.input :name   
            f.input :title  
            f.input :table_of_contents   
            f.input :description, as: :ckeditor , input_html: { ckeditor: { height: 500 } }, :hint =>  "图片样式类名称: product"
            f.input :published_at , as: :date_time_picker  
            f.input :attachment, as: :file, :hint => mini_image(f.object.image) 
        end
        f.actions
    end

    show do
        render 'admin/articles/show'
    end  

    filter :user, if: proc { current_admin_user.admin? || current_admin_user.manager? }
    filter :title
    filter :store_review_review_name, as: :string, label: I18n.t('active_admin.filter.store_review_review_name', default: "Review Name" )
    filter :store_review_store_id, as: :select, label: I18n.t('active_admin.filter.store_review_store', default: "Store" ), collection: Store.all
    

    # BOF member_action
    member_action :upload_image, method: :post , if: proc{ authorized?(ActiveAdmin::Auth::UPDATE, resource_class) } do 
        file = params[:file]
        if !file.blank? && ['.jpg','.png','.jpeg'].include?(File.extname(file.path)) 
            image = resource.build_image 
            image.attachment.attach( file )
            resource.save!
            render json:{code: true, id: resource.id, url: Rails.application.routes.url_helpers.rails_blob_path(resource.image.attachment, only_path: true)}
        else
            render json:{code:false}
        end
    end 

    # EOF member_action
end