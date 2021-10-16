ActiveAdmin.register Amz::Release, as: "Release" do
    init_controller  
    menu priority: 30   
    actions :all, except: [ :new , :update, :edit]   

    index do
        selectable_column
        id_column   
        column :logable_type    
        column :logable    
        column :name    
        column :image do |source|  
            img src: "https://m.media-amazon.com/images/I/#{source.image}._SL240_.jpg" if source.logable_type == "Amz::Amazon"
        end   
        column :created_at
        actions
    end

    filter :logable_type 
    filter :name
end