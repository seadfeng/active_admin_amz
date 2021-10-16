ActiveAdmin.register Amz::Brand, as: "Brand" do
    init_controller
    config.sort_order = 'id_desc'  
    permit_params  :name 
    batch_action :destroy, false
    actions :all, except: [:destroy, :show, :new]   
    menu priority: 30, parent: "Reviews" 


    index do 
		selectable_column
        id_column   
        column :name   
        actions
    end

    filter :id 
    filter :name         

end
