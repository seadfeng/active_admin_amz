ActiveAdmin.register Amz::Amazon, as: "Amazon" do
    init_controller
    menu priority: 100, parent: "Reviews"  
    batch_action :destroy, false  
    actions :all, except: [:destroy, :new, :edit] 

    # BOF index
    index do 
        selectable_column
        id_column   
        column :asin 
        column :image do |source| 
            mini_image(source)
        end  
        column :name   
        column :product  
        column :discontinue_on  
        column :created_at  
        column :updated_at  
        actions 
    end
    # EOF index

    show do
        panel t('active_admin.details', model: resource_class.to_s.titleize) do
            attributes_table_for resource do
                row :product   
                row :name      
                row :asin  
                row :image do |amz|
                    product_image(amz)
                end 
                row :reviews_scanned   
                row :discontinue_on 
                row :created_at 
                row :updated_at 
            end
        end 
        amazon_releases = amazon.releases.limit(20)
        if  amazon_releases.any?
            panel t('active_admin.amazonz_releases') do
                table_for amazon_releases do  
                    column :name do |obj|
                        obj.name
                    end
                    column :image do |obj|
                        img src: "https://m.media-amazon.com/images/I/#{obj.image}._SL48_.jpg"
                    end
                    column :release do |obj|
                        obj.value 
                    end
                end
            end
        end
        
    end

    # BOF sidebar
    # sidebar :releases, :only => :show do  
    #     releases = amazon.releases.limit(20)
    #     if  releases.any?
    #         table_for releases do  
    #             column :name do |obj|
    #                 obj.name
    #             end
    #             column :image do |obj|
    #                 img src: "https://m.media-amazon.com/images/I/#{obj.image}._SL48_.jpg"
    #             end
    #             column :release do |obj|
    #                 obj.value 
    #             end
    #         end
    #     end
    # end 
    # EOF sidebar

    batch_action :rsync, if: proc{ params[:scope] != 'archived'  }  do |ids|
        batch_action_collection.find(ids).each do |source|  
            source.scan_amazon
        end
        options = { notice: t('active_admin.batch_actions.succesfully_updated', count: ids.count, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end
end