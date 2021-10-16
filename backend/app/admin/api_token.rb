ActiveAdmin.register Amz::ApiToken,  as: "ApiToken" do 
    permit_params  :name, :key   
    active_admin_paranoia
    menu priority: 80, parent: "Settings" 

    index download_links: false do
		selectable_column
		id_column     
		column :name   
		column :key 
		column :created_at
		column :updated_at
		actions
    end
    
    filter :name

    form do |f|
        f.inputs I18n.t("active_admin.api_token.form" , default: "API")  do  
            f.input :name      
        end
        f.actions
    end 
end