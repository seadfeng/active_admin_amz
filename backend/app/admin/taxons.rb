ActiveAdmin.register Amz::Taxon, as: "Taxon"  do 
    init_controller
    belongs_to :store  
    permit_params  :name ,:meta_title, :meta_description,  :description, :authenticity_token, 
                   :child_index, :parent_id, :permalink, :attachment, :show_in_menu
    batch_action :destroy, false
    actions :all, except: [ :new ]   
    # menu priority: 1 , parent: "Stores"    

    controller do
        def find_resource 
            source = scoped_collection
            source.where(permalink: params[:id]).first!
        end 

        def create 
            create! do |format|
                options = { notice: I18n.t('active_admin.successfully_created', name: resource.name )} 
                format.html { redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options))   }
            end 
        end

        def update 
            update! do |format|
                options = { notice: I18n.t('active_admin.successfully_updated', name: resource.name )} 
                format.html { redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options))   }
            end 
        end

        def index 
            index! { |format| format.json { render json: collection.as_json(methods: :display_name) } }
        end

        
    end  

    member_action :form, method: :post do  
        render "admin/taxons/jstree_form", layout: nil
    end

    member_action :new_form, method: :post do   
        @new_resource = resource.store.taxons.build  
        @new_resource.parent = resource 
        render "admin/taxons/jstree_new_form", layout: nil 
    end

    member_action :jstree, method: :get do    
        data = resource.children.map{|z| z.jstree   }
        render json: data
    end

    index as: Amz::Backend::Views::IndexAsJstree do  
        render 'admin/taxons/index_block' 
    end

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

    filter :id   
    # filter :taxon    
 

    # form do |f|
    #     f.inputs I18n.t("active_admin.taxons.form" , default: "Taxon")  do   
    #       f.input :name    
    #       f.input :meta_title    
    #       f.input :permalink, input_html: { disabled: true , readonly: true } unless f.object.new_record?
    #       f.input :meta_description 
    #       f.input :description  
    #     end
    #     f.actions
    # end  

end