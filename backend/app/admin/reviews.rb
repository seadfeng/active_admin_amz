ActiveAdmin.register Amz::Review, as: "Review"  do
    init_controller
    config.sort_order = 'id_desc'  
    permit_params  :name,  :meta_title, :meta_description, :tag_names, :slug, :description
    batch_action :destroy, false
    actions :all, except: [:destroy]   
    menu priority: 3 

    active_admin_paranoia  friendly: true 
    # tabs :info, models: [:products, :related_reviews] 

    active_admin_import validate: true,
                        template_object: ActiveAdminImport::Model.new(
                            hint: I18n.t("active_admin_import.product.import.hint" , default: "CSV Header: \"Name\",\"Slug\",\"Meta Title\",\"Meta Description\""),
                        ),
                        headers_rewrites: {  :'Meta Title' => :meta_title, :'Meta Description'=> :meta_description, :'Name' => :name, :'Slug' => :slug },
                        before_batch_import: ->(importer) {    
                          slug_names = importer.values_at(:slug)
                          unless slug_names.first.blank?     
                              slug   = slug_names.map{|obj| [obj.downcase, obj.to_url]}   
                              slugs = Hash[*slug.flatten] 
                              importer.batch_replace(:slug, slugs)
                          end  
                          importer.batch_slice_columns(Review.column_names)  

                       }, 
                        after_batch_import: ->(importer) {  
                          history = true
                          names = importer.values_at(:name, history)
                          names.each_with_index do |value,index|
                            name = value.lstrip.rstrip
                            review = Review.find_by(name: name )  
                            if review && review.slug.nil?
                              review.slug = name.to_url 
                              review.save
                            end
                          end

                        }


    controller do
      def update 
        if params[:amz_review].present? 
          if params[:review].present?  
            params[:review][:tag_names] = params[:amz_review][:tag_names]  
          else
            params[:review] = params[:amz_review] 
          end
        end
        super
      end 
    end

    index do 
		    selectable_column
        id_column   
        column :name     
        column :store_review do |source|
          ul do
            source.store_reviews.each do |store_review|
              li do 
                auto_link store_review
              end
            end
          end
        end  
        column :meta_title  
        column :tags do |source|
          div do
            tags =  source.tags.map do |tag|
              link_to tag.name, admin_reviews_path(:commit => "Filter",:"q[tags_name_contains]" => tag.name ) 
            end.join(', ')
            raw tags
          end
        end
        actions
    end

    filter :id 
    filter :name   
    filter :tags_name, as: :string   


    form do |f| 
        f.inputs I18n.t("active_admin.review.form" , default: "Review")  do   
          f.input :name   
          f.input :slug if current_admin_user.admin?  && !f.object.new_record? 
          f.input :tag_names, as: :tags 
          f.input :meta_title  
          f.input :meta_description ,as: :text, input_html: { rows: 3 }
          f.input :description, as: :ckeditor , input_html: { ckeditor: { height: 300 } }
          
        end
        f.actions
    end 
    # EOF form 

    action_item :store_reviews, only: :index do
      if authorized?(ActiveAdmin::Auth::READ, "Amz::StoreReview")
        link_to(
          I18n.t('active_admin.store_review', default: "Store Reviews"), 
          admin_store_reviews_path
        ) 
      end
    end

    # BOF batch_action
    batch_action :confirm, if: proc{ params[:scope] == 'unconfirmed' }  do |ids|
        batch_action_collection.find(ids).each do |source|  
          source.confirm!
        end
        options = { notice: t('active_admin.batch_actions.succesfully_updated', count: ids.count, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end
    # EOF batch_action
  
end
