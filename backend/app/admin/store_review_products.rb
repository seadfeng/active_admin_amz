ActiveAdmin.register Amz::StoreReviewProduct, as: "StoreReviewProduct"  do 
    init_controller
    belongs_to :store_review,  optional: true
    config.sort_order = 'score_desc' 
    permit_params  :score,  :best_value 
    # batch_action :destroy, false
    actions :all, except: [ :new, :edit]   
    menu priority: 5, parent: "Reviews" 

    controller do
        def destroy
            destroy!  do |format| 
                options = { notice: I18n.t('active_admin.successfully_deleted', default: 'Destroy')} 
                format.html { redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options))   }
            end 
        end
    end

    # BOF Index
    index do 
		selectable_column
        id_column     
        column :store 
        column :store_review 
        column :asin  
        column :product  
        column :score    
        tag_column :state    
        column :best_value  
        actions
    end
   
    filter :product_amazon_asin, as: :string , label: I18n.t("active_admin.filters.asin", default:"ASIN")      
    filter :product_store_id, as: :select , label: I18n.t("active_admin.filters.store", default:"Store"), collection: proc { Store.all }  

    # EOF Index

    form do |f|
        f.inputs I18n.t("active_admin.store_review_products.form" , default: "Store Review Product")  do   
          f.input :score  
          f.input :best_value  
        end
        f.actions
    end 

    # BOF member_action
    member_action :best_value, method: :get , if: proc{ authorized?(ActiveAdmin::Auth::UPDATE, resource_class) } do 
        resource.default_best_value
        options = { notice: I18n.t('active_admin.successfully_updated', name: resource.name ) }
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end  
    # EOF member_action
end