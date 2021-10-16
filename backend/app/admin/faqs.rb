ActiveAdmin.register Amz::Faq, as: "Faq" do
    init_controller
    belongs_to :store, optional: true 
    permit_params  :store_id,  :store_review_id , :name, :description , :published_at
    menu priority: 30   
    actions :all, except: [ :new , :show]  

    active_admin_paranoia 

    scope :draft
    scope :published

    controller do
        def create 
            create! do |format|
                options = { notice: t('active_admin.successfully_create', name: resource.name )} 
                format.html { redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options))   }
            end  
        end 
    end


    index do
        selectable_column
        id_column   
        column :store    
        column :store_review    
        column :name    
        column :published_at
        actions
    end

    form do |f|
        f.inputs I18n.t("active_admin.cms.form" , default: "Cms")  do   
            f.input :name    
            f.input :description , as: :ckeditor , input_html: { ckeditor: { height: 500} }  
            f.input :published_at, as: :date_time_picker  
        end
        f.actions
    end 

    filter :store 
    filter :id 
    filter :name   
    filter :description    
    filter :published_at    

    sidebar :store_review, only: :edit do
        store_review = resource.store_review 
        div do
            # review_name = store_review.name 
            # review_name = store_review.review.name if review_name.blank? 
            # review_name
            auto_link store_review
        end
    end 

    sidebar :faqs, only: :edit do 
        faqs = resource.store_review.faqs
        if faqs.any? 
            table_for faqs do
                column :id
                column :auestion do   |faq|
                    auto_link faq 
                end 
            end
        end
    end
end