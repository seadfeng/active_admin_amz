ActiveAdmin.register Amz::Locale,  as: "Locale" do
    init_controller    
    actions :all, except: [:destroy] 
    batch_action :destroy, false
    menu priority: 60, parent: "Stores" 
    permit_params  :name, :code, :position

    index do
        selectable_column
        id_column
        column :name
        column :code 
        column :position 
        column :created_at
        column :updated_at
        actions
    end

    filter :name 
    filter :code 
    filter :created_at
    filter :updated_at 

end 
    
