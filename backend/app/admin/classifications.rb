ActiveAdmin.register Amz::Classification, as: "Classification"  do   
    init_controller
    permit_params  :name ,:position 
    batch_action :destroy, false   
    actions :all, except: [:new, :edit ] 
    menu priority: 300, parent: "Reviews" 
    # index as: :block do |taxon| 
    #     render 'admin/stores_taxons/index_block' , taxon: taxon
    # end

    # index do 
    #     render 'admin/taxons/index_block' 
	# 	selectable_column
    #     id_column    
    #     column :name do |source|
    #         source.name || source.taxon.name
    #     end 
    #     column :meta_title    
    #     actions
    # end 
    
    filter :taxon    

end