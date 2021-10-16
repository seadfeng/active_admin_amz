ActiveAdmin.register Amz::Redirect, as: "Redirect"  do 
    init_controller
    belongs_to :store, optional: true
    batch_action :destroy, false
    actions :all, except: [ :new , :destroy, :update, :show, :edit]  
    menu priority: 40, parent: "Stores"   

    index do
        selectable_column
        id_column   
        column :store 
        column :image do |source|
            mini_image source.resource.product  if source.resource&.product
        end
        column :product do |source|
            auto_link source.resource.product if source.resource&.product
        end 
        column :resource_type 
        column :viewed  
        column :created_at
        column :updated_at 
        actions
    end
end
