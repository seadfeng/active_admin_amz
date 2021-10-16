ActiveAdmin.register Amz::Synonym, as: "Synonym"  do 
    init_controller
    belongs_to :store, optional: true  
    permit_params  :name ,:renew, :store_id 
    menu priority: 10 , parent: "Searches"   
 
end
