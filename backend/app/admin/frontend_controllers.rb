ActiveAdmin.register Amz::FrontendController, as: "FrontendController" do
    init_controller
    belongs_to :store, optional: true  
    permit_params :name, :presentation 
    menu priority: 40, parent: "Widgets"  
    actions :all, except: [:new] 

    # form do |f| 
    # end


    # Bof Reload
    collection_action :reload, method: :get do  
        Amz::Core::Engine.routes.routes.map do |route|
            Amz::FrontendController.create(name: route.defaults[:controller], presentation: route.name) 
        end
        options = { notice: I18n.t('active_admin.reloaded', default: "Reloaded")}
        redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
    end 

    action_item :reload, only: :index, if: proc{  authorized?(ActiveAdmin::Auth::UPDATE, active_admin_config.resource_class) }  do
          link_to(
            I18n.t('active_admin.reload' , default: "Reload" ), action: :reload
          ) 
    end

    # Eof Reload
end