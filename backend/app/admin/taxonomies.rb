ActiveAdmin.register Amz::Taxonomy, as: "Taxonomy" do 
    init_controller
    belongs_to :store 
    permit_params :name ,:store_id 
    batch_action :destroy, false
    actions :all, except: [:destroy]   
    # menu priority: 1 , parent: "Stores"  

    # index as: Amz::Backend::Views::IndexAsJstree do  
    #     render 'admin/taxonomies/index_block' 
    # end

    collection_action :jstree, method: :get do  
      data = collection.all.map { |resource|  resource.jstree  } 
      render json: data
    end 
 
    index do 
		    selectable_column
        id_column    
        column :name   
        column :store 
        actions
    end 
  
    filter :name    
    filter :store    

    form do |f|
        f.inputs I18n.t("active_admin.taxonomies.form" , default: "taxonomy")  do   
          f.input :name    
        end
        f.actions
    end 

end