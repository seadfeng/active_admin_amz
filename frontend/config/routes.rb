
class UrlConstraint 
    def matches?(request) 

      unless request.params[:cms_id].blank?
        if check_path(request.params[:cms_id]) 
          current_store = amz_current_store(request) 
          found = Amz::Cms.exists_by_friendly_id?(store_id: current_store.id, slug: request.params[:cms_id] ) 
        end
      end
      unless request.params[:taxon_id].blank?
        if check_path(request.params[:taxon_id])
          current_store = amz_current_store(request)
          # taxons = current_store.taxons 
          # found = taxons.friendly.exists_by_friendly_id?(request.params[:taxon_id]) 
          found = Amz::Taxon.exists_by_friendly_id?(store_id: current_store.id , permalink: request.params[:taxon_id] )
        end
      end  
      unless request.params[:review_id].blank? 
        if check_path(request.params[:review_id])
          # current_store = amz_current_store(request)
          # reviews = current_store.reviews 
          # found = reviews.friendly.exists_by_friendly_id?(request.params[:review_id])  
          found = Amz::Review.exists_by_friendly_id?(request.params[:review_id])  
        end 
      end  
      unless request.params[:unmatched_route].blank? 
        found = check_path(request.params[:unmatched_route])
      end

      found   
    end

    def amz_current_store(request) 
      Amz::Store.current(request.env['SERVER_NAME']) 
    end

    def check_path(path)
      if (path.include?('active_storage')|| path.match(/^\/?admin/) || path.include?('admin/')  || path.include?('sidekiq') || path.include?('ckeditor') )  
        found = false 
      else 
        found = true
      end 
      found
    end
end
Amz::Core::Engine.add_routes do
    # devise_for :amz_user,
    #             class_name: Amz.user_class.to_s,
    #             controllers: { sessions: 'amz/user_sessions',
    #                               registrations: 'amz/user_registrations',
    #                               passwords: 'amz/user_passwords',
    #                               confirmations: 'amz/user_confirmations' },
    #             skip: [:unlocks, :omniauth_callbacks],
    #             path_names: { sign_out: 'logout' },
    #             path_prefix: :user
    # devise_scope :amz_user do
    #   get '/login' => 'user_sessions#new', :as => :login
    #   post '/login' => 'user_sessions#create', :as => :create_new_session
    #   get '/logout' => 'user_sessions#destroy', :as => :logout
    #   get '/signup' => 'user_registrations#new', :as => :signup
    #   post '/signup' => 'user_registrations#create', :as => :registration
    #   get '/password/recover' => 'user_passwords#new', :as => :recover_password
    #   post '/password/recover' => 'user_passwords#create', :as => :reset_password
    #   get '/password/change' => 'user_passwords#edit', :as => :edit_password
    #   post '/password/change' => 'user_passwords#update', :as => :update_password
    #   get '/confirm' => 'user_confirmations#show', :as => :confirmation if Amz::Auth::Config[:confirmable]
    # end
    # resources :users, only: [:update] 
    # resource :account, controller: 'users'
    # resource :profile, controller: 'users', action: :profile
    resources :author, only: [:show]

    
    get '/subscription' => 'subscriptions#new', :as => :subscription 
    get '/unsubscribion/*token' => 'subscriptions#cancel', :as => :unsubscribion

    root to: 'home#index'
    get '/csrf_meta_tags.html', to: 'store#csrf_meta_tags', as: :csrf_meta_tags
    get '/manifest.json', to: 'favicon#manifest', as: :manifest
    get '/browserconfig.xml', to: 'favicon#browserconfig', as: :browserconfig
    get '/cms_sitemap.xml', to: 'sitemap#xml_cms', as: :sitemap_xml_cms
    get '/taxons_sitemap.xml', to: 'sitemap#xml_taxons', as: :sitemap_xml_taxons 
    get '/reviews_sitemap.xml', to: 'sitemap#xml_reviews', as: :sitemap_xml_reviews 
    get '/sitemap.xml', to: 'sitemap#index', as: :sitemap

    get '/redirect', to: 'redirect#index', as: :redirects
    put '/search', to: 'search#processing', as: :searches
    get '/search', to: 'search#popular', as: :popular
    get '/results', to: 'search#show', as: :results 
    get '/tag/*keywords', to: 'tag#show', as: :tag 
    get '/media/*style/*review_id.jpg', to: 'review#media', as: :review_media , constraints: UrlConstraint.new
    get '/media/*style/*scale/*review_id.jpg', to: 'review#media', as: :review_media_crop , constraints: UrlConstraint.new

    get '/api/v1/store', to: 'api/store#index', as: :api_stores 
    get '/api/v1/store/*id', to: 'api/store#show', as: :api_store

    post '/api/v1/product', to: 'api/product#index', as: :api_products 
    post '/api/v1/product/*id', to: 'api/product#show', as: :api_product

    get '/api/v1/review', to: 'api/review#index', as: :api_reviews 
    get '/api/v1/review/*id', to: 'api/review#show', as: :api_review

    get '*cms_id', to: 'cms#show', as: :cms, constraints: UrlConstraint.new
    get '*taxon_id', to: 'taxon#show', as: :taxons, constraints: UrlConstraint.new
    get '*review_id', to: 'review#show', as: :reviews, constraints: UrlConstraint.new 
    get '*unmatched_route', to: 'store#route_not_found', constraints: UrlConstraint.new 
    

end