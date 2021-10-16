ActiveAdmin.register Amz::Currency, as: "Currency"  do
    init_controller
    config.sort_order = 'id_desc'  
    permit_params  :code, :name, :unit, :precision, :separator, :delimiter
    batch_action :destroy, false
    actions :all, except: [:destroy]   
    menu priority: 50, parent: "Stores" 

    index do 
		selectable_column
        id_column   
        column :name 
        column :code
        column :unit
        actions
    end

    filter :id 
    filter :name   
    filter :code      


    form do |f|
        f.inputs I18n.t("active_admin.currency.form" , default: "Currency")  do   
          f.input :name  
          f.input :code    
          f.input :unit  
          f.input :precision   
          f.input :separator    
          f.input :delimiter     
        end
        f.actions
    end 

end
