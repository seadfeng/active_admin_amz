ActiveAdmin.register Amz::WidgetsController, as: "WidgetsController" do
    init_controller
    belongs_to :widget, optional: true  
    permit_params :widget_id, :controller_id ,:position
    menu priority: 30 , parent: "Widgets"
    actions :all, except: [ :new, :show,  ]  

    controller do 
        def destroy
            destroy!  do |format| 
                options = { notice: I18n.t('active_admin.successfully_deleted', default: 'Destroy')} 
                format.html { redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options))   }
            end 
        end
    end 
    form do |f|
        f.inputs display_name( f.object) do
            f.input :position 
        end
        f.actions
    end
end