Amz::Core::Engine.add_routes do
    if defined? authenticate
        require 'sidekiq/web'  
        authenticate :admin_user, lambda { |u| u.admin? } do
            mount Sidekiq::Web => '/sidekiq'
            mount Ckeditor::Engine => '/ckeditor'
        end
    end
end
Amz::Core::Engine.draw_routes