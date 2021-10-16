ActiveAdmin.register Amz::Tag, as: "Tag"  do 
    init_controller  
    permit_params  :name 
    menu priority: 10 , parent: "Reviews"   

    filter :id 
    filter :name 
 
end
