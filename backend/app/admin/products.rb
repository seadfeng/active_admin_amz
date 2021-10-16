require 'amz/core/helpers/taxon'
ActiveAdmin.register Amz::Product, as: "Product" do
    init_controller
    config.sort_order = 'id_desc'  
    permit_params  :name,  :score, :brand_id, :store_id ,:store_review_id, :brand_name, 
                    :asin, :amazon_reviews_scanned , :asin_image, :locked,
                    :ebay_epid, :ebay_epid_image, :ebay_reviews_scanned, 
                    :discontinue_on, :available_on, :state , :sku,
                    :description, amazon_attributes: [:id, :reviews_scanned, :barcode ]
    batch_action :destroy, false
    actions :all, except: [:destroy, :new]   
    menu priority: 1 , parent: "Reviews"  
 
    state_action :move_to_draft
    state_action :publish
    state_action :close
    
    scope :all, default: true
    scope :imports 
    scope :draft 
    scope :visible 
    scope :closed
    scope :trash
    scope :error
    scope :non_description
    scope :will_available, group: :will
    scope :will_discontinue, group: :will
    scope :locked, group: :locked
    scope :unlocked, group: :locked
    
    active_admin_paranoia   

    active_admin_import validate: true,  
                        # on_duplicate_key_update: [:name] ,
                        template_object: ActiveAdminImport::Model.new(
                            hint: I18n.t("active_admin_import.product.import.hint" , default: "CSV Header: \"Review Name\",\"Asin\",\"Name\",\"Brand Name\",\"Store\",\"Taxon\",\"Description\""),
                        ), 
                        headers_rewrites: { :'Review Name'=> :review_name , 
                                            :'Description' => :description, 
                                            :'Asin' => :asin, 
                                            :'ASIN' => :asin, 
                                            :'ePID' => :epid, 
                                            :'Epid' => :epid, 
                                            :'EPID' => :epid, 
                                            :'ePID Image' => :epid_image,  
                                            :'Epid Image' => :epid_image, 
                                            :'Brand Name'=> :brand_id, 
                                            :'Store' => :store_id, 
                                            :'Name' => :name, 
                                            :"State" => :state, 
                                            :"Taxon" => :taxon,
                                            :"Sku" => :sku, 
                                            :"SKU" => :sku, 
                                            :"Type" => :type
                                        },
                        before_batch_import: ->(importer) {   

                            brand_names = importer.values_at(:brand_id) 
                            brand_names.each_with_index do |value,index|
                                Brand.find_or_create_by(name: value)
                            end  
                            unless brand_names.first.blank?   
                                brand   = Brand.where(name: brand_names).map{|obj| [obj.name.downcase, obj.id]}
                                brand_options = Hash[*brand.flatten]
                                importer.batch_replace(:brand_id, brand_options)
                            end
                            

                            store_codes = importer.values_at(:store_id)
                            unless store_codes.first.blank?     
                                store   = Store.where(code: store_codes).map{|obj| [obj.code.downcase, obj.id]}  
                                store_options = Hash[*store.flatten]
                                importer.batch_replace(:store_id, store_options)
                            end  
                            importer.batch_slice_columns(Product.column_names)  

                        }, 
                        after_batch_import: ->(importer) {   
                            history = true
                            asin_names = importer.values_at(:asin, history)
                            epids = importer.values_at(:epid, history)
                            epid_images = importer.values_at(:epid_image, history)
                            names = importer.values_at(:name, history)
                            skus = importer.values_at(:sku, history)
                            store_ids = importer.values_at(:store_id, history)  
                            review_names = importer.values_at(:review_name, history)
                            taxon_names = importer.values_at(:taxon, history)
                            types = importer.values_at(:type, history)
                            
                            skus.each_with_index do |value,index|
                                product   = Product.find_by(sku: value, store_id: store_ids[index])  
                                return nil if product.blank? 
                                store_id = store_ids[index]
                                type = types[index]
                                asin = asin_names[index]
                                epid = epids[index]
                                epid_image = epid_images[index]
                                if taxon_names[index] 
                                    taxon =  Amz::Core::Helpers::Taxon.new( taxon_names[index],store_id )  
                                    taxon = taxon.take
                                end
                                review_name = review_names[index] 
                                if store_id && review_name 
                                    store   = Store.find_by(id: store_id)    
                                    review   = Review.find_or_create_by(name: review_name)  
                                    unless store.blank? & review.blank?
                                        store_review = StoreReview.find_or_create_by(review_id: review.id , store_id: store.id )  
                                        store_review_product  = store_review.store_review_products.find_by(product_id: product.id)
                                        if store_review_product.blank?
                                            store_review_product = store_review.store_review_products.new
                                            store_review_product.product_id = product.id
                                            store_review_product.create_init
                                            store_review_product.check_default_best_value
                                            store_review.save!
                                        end
                                        if taxon_names[index] && taxon
                                            classification = taxon.classifications.find_or_create_by(store_review_id: store_review.id) 
                                        end
                                    end  
                                end 

                                if asin 
                                    product.asin =   asin  
                                end

                                if epid
                                    ebay = product.find_or_build_ebay
                                    ebay.epid = epid  
                                    ebay.epid_image = epid_image
                                end

                                product.save 
                            end 

                        }  
    # EOF active_admin_import


    controller do
        def create 
            # if create!
            #     options = { notice: I18n.t('active_admin.successfully_created', name: resource.name )} 
            # else
            #     options = { alert: I18n.t('active_admin.create_failure',  name: name)  } 
            # end
            # return redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
            if params[:product][:store_review_id] 
                name = params[:product][:name]
                store_id = params[:product][:store_id]
                store_review_id = params[:product][:store_review_id]
                asin = params[:product][:asin]
                sku = params[:product][:sku].lstrip.rstrip
                ebay_epid = params[:product][:ebay_epid]
                ebay_epid_image = params[:product][:ebay_epid_image]
                begin 
                    product = Product.where(store_id: store_id).find_by_sku(sku)
                    if product.blank?
                        product = Product.new  
                        product.name = name
                        product.store_id = store_id
                        product.store_review_id = store_review_id
                        product.asin = asin unless asin.blank?
                        product.sku = sku
                        product.ebay_epid = ebay_epid unless ebay_epid.blank?
                        product.ebay_epid_image = ebay_epid_image unless ebay_epid_image.blank?
                        product.save!
                    else
                        product.store_review_products.find_or_create_by( store_review_id: store_review_id)   
                    end
                    
                    options = { notice: I18n.t('active_admin.successfully_created', name: product.name )}
                    redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
                rescue 
                    options = { alert: I18n.t('active_admin.create_failure',  name: name)  }
                    redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
                end
            else
                super  
            end
            # super
        end 
    end
    # EOF controller

    show do
        render 'admin/products/show'
    end 

    form partial: 'form'

    # BOF index
    index do 
		selectable_column
        id_column   
        column :store 
        column :image do |product| 
            mini_image(product)
        end  
        column :sku
        column :brand 
        column :name  
        column :store_reviews do |review|
            ol do
              review.store_reviews.each do |store_review|
                li do
                  auto_link(store_review)
                end
              end
            end
        end
        tag_column :state, machine: :state   
        column :locked
        column :created_at
        column :updated_at
        column :discontinue_on if  params[:scope] == 'trash' ||  params[:scope] == 'closed' 
        actions 
    end
    # EOF index

    filter :id 
    filter :name 
    filter :amazon_asin, as: :string, label: "ASIN"  
    filter :state, as: :select,  collection: proc { Product.new.class.state.values  } 

    # BOF batch_action
    batch_action :publish, if: proc{ params[:scope] == 'draft'  }  do |ids|
        batch_action_collection.find(ids).each do |source|  
          source.publish
        end
        options = { notice: t('active_admin.batch_actions.succesfully_updated', count: ids.count, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end

    batch_action :rsync, if: proc{ params[:scope] != 'archived'  }  do |ids|
        batch_action_collection.find(ids).each do |source|  
            source.scan_amazon
        end
        options = { notice: t('active_admin.batch_actions.succesfully_updated', count: ids.count, model: resource_class.to_s.camelize.constantize.model_name, plural_model: resource_class.to_s.downcase.pluralize) }
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end

    # EOF batch_action

    action_item :index_rebuild, only: :index  do
        if authorized?(ActiveAdmin::Auth::UPDATE, active_admin_config.resource_class) 
          link_to(
            I18n.t('active_admin.product.rebuild_index', default: "Rebuild Index"),
            index_rebuild_admin_products_path,
            method: :put
          ) 
        end
    end 

    collection_action :index_rebuild, method: :put do   
        if authorized?(ActiveAdmin::Auth::UPDATE, active_admin_config.resource_class)  
            if system("cd #{Rails.root} && rake ts:rebuild")
                options = { notice: I18n.t('active_admin.success', default: "Success")} 
            else
                options = { alert: I18n.t('active_admin.failure', default: "Failure")} 
            end
            redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options))
        end
    end


    # BOF sidebar
    # sidebar :releases, :only => :show do  
    #     releases = product.releases.limit(20)
    #     if  releases.any?
    #         table_for releases do  
    #             column :name do |obj|
    #                 obj.name
    #             end
    #             column :release do |obj|
    #                 obj.value 
    #             end
    #         end
    #     end
    # end 

    # sidebar :amazon_releases, :only => :show do  
    #     releases = product.amazon.releases.limit(20)
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

    # BOF member_action
    member_action :rsync, method: :get , if: proc{ authorized?(ActiveAdmin::Auth::UPDATE, resource_class) } do  
        resource.scan_amazon
        options = { notice: I18n.t('active_admin.send_job', name: resource.name, id: resource.id )}
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options))    
    end 

    # EOF member_action

end
