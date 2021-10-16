ActiveAdmin.register Amz::Store, as: "Store"  do
  init_controller
  config.sort_order = 'id_desc' 
  # config.per_page = [20, 50, 100]
  permit_params  :locale_id, :currency_id, :name , :meta_description ,:meta_title, :code, :url, :domain,
                  :amz_secret, :amz_region, :amz_tag_id, :amz_access, :amz_host, :amz_pai_enabled,
                  :mail_from_address,
                  :attachment,
                  :attachment_logo,
                  :preferred_google_ga, 
                  :preferred_google_gtm_id,
                  :preferred_google_gtag_redirect, 
                  :preferred_google_gtag_id,
                  :preferred_esi, 
                  :preferred_varnish_host, 
                  :preferred_facebook_pixel, 
                  :preferred_reviews_per_page,
                  :preferred_sitemap_taxon_changefreq,
                  :preferred_sitemap_taxon_priority,
                  :preferred_sitemap_cms_changefreq,
                  :preferred_sitemap_cms_priority,
                  :preferred_sitemap_review_changefreq,
                  :preferred_sitemap_review_priority,
                  :preferred_search_title,
                  :preferred_search_meta_description,
                  :preferred_time_zone,
                  :preferred_tile_color,
                  :preferred_domian_smtp,
                  :preferred_service_smtp,
                  :preferred_smtp_port,
                  :preferred_smtp_auth_type,
                  :preferred_smtp_password,
                  :preferred_secure_connection_type,
                  :preferred_smtp_username, 
                  :preferred_enable_mailer,
                  :preferred_mail_bcc,
                  :preferred_send_per_queue,
                  :preferred_head_code,
                  :preferred_foot_code,
                  :preferred_amz_image_crop,
                  :preferred_top_number,
                  :preferred_featured_limit,
                  :preferred_review_title,
                  :preferred_review_meta_description,
                  :preferred_facebook_app_id,
                  :preferred_amp
                  

  batch_action :destroy, false
  actions :all, except: [:destroy]   
  menu priority: 300 

  controller do
    def update  
      if params[:store][:preferred_smtp_password].blank?
        params[:store][:preferred_smtp_password] = resource.preferred_smtp_password
      end
      update! do |format|
        options = { notice: t('active_admin.successfully_updated', name: resource.name )} 
        format.html { redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options))   }
      end 
      # super
    end
  end
  

  index do 
  selectable_column
      id_column   
      column :name 
      column :locale 
      column :currency 
      column :domain 
      column :url 
      column :meta_title  
      column :taxon do |store|
        link_to t('active_admin.taxon', default: "Taxon"),  admin_store_taxons_path(store), class: "member_link", method: :get  
      end 
      column :page do |store|
        link_to t('active_admin.cms', default: "Cms"),  admin_store_cms_path(store), class: "member_link", method: :get 
      end  
      column :smtp do |store|
        link_to t('active_admin.smtp', default: "Smtp"),  mail_method_admin_store_path(store), class: "member_link", method: :get 
      end 
      column :head_and_foot_code do |store|
        link_to t('active_admin.head_and_foot_code', default: "Head & foot code"),  html_code_admin_store_path(store), class: "member_link", method: :get 
      end 
      actions defaults: false do |store|
        item t('active_admin.clear_cache', default: "Clear Cache" ),  clear_admin_store_path( store), class: "member_link", method: :get if authorized?(ActiveAdmin::Auth::CREATE , store) 
        item t('active_admin.view' ),  admin_store_path( store), class: "member_link", method: :get if authorized?(ActiveAdmin::Auth::CREATE , store) 
        item t("active_admin.edit" ),  edit_admin_store_path( store ), class: "member_link" if authorized?(ActiveAdmin::Auth::UPDATE , store) 
      end
  end 

  filter :id 
  filter :name   
  filter :code 
  # filter :locale_id, as: :select,  collection: proc {  Locale.pluck(:"amz_locales.name", :"amz_locales.id") }     


  form do |f|
      palette = [
        "#000000",
        "#333333",
        "#663300",
        "#CC0000",
        "#CC3300",
        "#FFCC00",
        "#009900",
        "#006666",
        "#0066FF",
        "#0000CC",
        "#663399",
        "#CC0099",
        "#FF9999",
        "#FF9966",
        "#FFFF99",
        "#99FF99",
        "#66FFCC",
        "#99FFFF",
        "#66CCFF",
        "#9999FF",
        "#FF99FF",
        "#FFCCCC",
        "#FFCC99",
        "#FFFFFF"
      ]
      palette.concat([f.object.preferred_tile_color]) if f.object.preferred_tile_color 


      f.inputs t("active_admin.store.form" , default: "Store")  do  
        f.input :name 
        f.input :meta_title  
        f.input :meta_description  
        if current_admin_user.admin? 
          f.input :attachment, as: :file, :hint => mini_image(f.object.favicon ), label: t('amz.favicon_png', default: "Favicon PNG(310x310px)") 
          f.input :attachment_logo, as: :file, :hint => mini_image(f.object.logo,   style: "max-width: 200px;"  ), label: t('amz.logo', default: "Logo") 
          f.input :preferred_tile_color, as: :color_picker, palette: palette.uniq, label: t('amz.tile_color', default: "Tile Color") , input_html: { class: 'color-picker' } 
          f.input :locale   
          f.input :currency    
          f.input :domain  
          f.input :url, :hint => 'DEMO: https://www.amazon.com'
          f.input :code   
          f.input :preferred_amz_image_crop , as: :boolean   
          hr
          f.input :amz_host  
          f.input :amz_region  
          f.input :amz_access  
          f.input :amz_secret  
          f.input :amz_tag_id  
          f.input :amz_pai_enabled  
          hr
          f.input :preferred_featured_limit, label: t('amz.featured_limit') 
          f.input :preferred_top_number, label: t('amz.top_number', default: "Best Top Number") 
          f.input :preferred_amp, as: :boolean, label: "AMP"  
          f.input :preferred_esi, as: :boolean, label: t('amz.varnish_esi_enable' ) 
          f.input :preferred_varnish_host, label: t('amz.varnish_host' ) 
          f.input :preferred_time_zone, label: t('amz.time_zone') , as: :select, collection: TZInfo::Timezone.all_country_zone_identifiers
        end  
        f.input :preferred_search_title,:hint => 'Shop %{keywords} Online', label: t('amz.search_title' )
        f.input :preferred_review_title,:hint => 'Top %{number} %{keywords} of %{year}', label: t('amz.review_title' )
        f.input :preferred_search_meta_description,:hint => 'Search Keywords Meta Title + Meta Description', label: t('amz.search_meta_description', default: "Search Meta Description")
        f.input :preferred_review_meta_description, :hint => '%{store_name} analyzes and compares all %{keywords} of %{year}. You can easily compare and choose from the %{number} best %{keywords} for you.', label: t('amz.review_meta_description')
        
        f.input :preferred_google_ga,:hint => 'UA-000000-01', label: t('amz.google_ga', default: "Google GA") 
        
        f.input :preferred_google_gtm_id,:hint => 'GTX-00000000', label: t('amz.google_gtm_id', default: "Google GTM ID") 
        f.input :preferred_google_gtag_redirect,:hint => 'AW-743739249/bolnCJ7b3M8BEPGe0uIC', label: t('amz.google_gtag_redirect', default: "Google Gtag Config For Redirect Page") 
        f.input :preferred_google_gtag_id,:hint => 'G-XXXXXX', label: t('amz.preferred_google_gtag_id', default: "Google Analytics 4") 
        
        f.input :preferred_facebook_pixel, label: t('amz.facebook_pixel', default: "Facebook Pixel")
        f.input :preferred_facebook_app_id, label: t('amz.facebook_app_id', default: "Facebook App Id")
        f.input :preferred_reviews_per_page, :hint => 'Default 12', label: t('amz.reviews_per_page', default: "Reviews Per Page")
        f.input :preferred_sitemap_taxon_changefreq, as: :select, collection:  ["daily","weekly","monthly"] 
        f.input :preferred_sitemap_taxon_priority, as: :select, collection:  [1.0,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1] 
        f.input :preferred_sitemap_cms_changefreq, as: :select, collection:  ["daily","weekly","monthly"] 
        f.input :preferred_sitemap_cms_priority, as: :select, collection:  [1.0,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1]
        f.input :preferred_sitemap_review_changefreq, as: :select, collection:  ["daily","weekly","monthly"] 
        f.input :preferred_sitemap_review_priority, as: :select, collection:  [1.0,0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1]
      end
      f.actions
  end 
  
  show do
    render 'admin/stores/show'
  end 

  sidebar "Store Details", only: [:show, :edit, :mail_method, :html_code] do
    ul do
      li link_to "Taxons",    admin_store_taxons_path(resource)
      li link_to "Taxonomies", admin_store_taxonomies_path(resource) 
      li link_to "Head & foot code", html_code_admin_store_path(resource) 
      li link_to "Mail Method", mail_method_admin_store_path(resource) 
    end
  end

  action_item :edit_smtp, only: :show  do
    if authorized?(ActiveAdmin::Auth::UPDATE, active_admin_config.resource_class) 
      link_to(
        t('active_admin.edit_smtp', default: "Edit Smtp"),
        mail_method_admin_store_path(resource),
        method: :get
      ) 
    end
  end 

  action_item :test_mailer, only: :mail_method  do
    if authorized?(ActiveAdmin::Auth::UPDATE, active_admin_config.resource_class) 
      link_to(
        t('active_admin.test_mailer', default: "Send Test Mail"),
        test_mailer_admin_store_path(resource),
        method: :post
      ) 
    end
  end 

  member_action :mail_method, method: :get, if: proc{ authorized?(ActiveAdmin::Auth::UPDATE, active_admin_config.resource_class) } do
    render 'admin/stores/mail_method'
  end 

  member_action :html_code, method: :get, if: proc{ authorized?(ActiveAdmin::Auth::UPDATE, active_admin_config.resource_class) } do
    render 'admin/stores/html_code'
  end 

  member_action :test_mailer, method: :post, if: proc{ authorized?(ActiveAdmin::Auth::UPDATE, active_admin_config.resource_class) } do
    if Amz::TestMailer.with(store: resource).test_email(resource.mail_from_address).deliver_now
      options = { notice: t('active_admin.sent_successfully', default: "Sent to #{resource.mail_from_address} successfully!")}
    else
      options = { alert: t('active_admin.failed_to_send', default: "Failed to send")} 
    end
    redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 

  end 

  # clear_cache Todo
  member_action :clear, method: :get, if: proc{ authorized?(ActiveAdmin::Auth::CLEAR, active_admin_config.resource_class) } do
    authorize!(ActiveAdmin::Auth::CLEAR, active_admin_config.resource_class)  
    resource.clear
    options = { notice: t('active_admin.cache_cleaned', default: "Cache Cleaned")}
    redirect_back({ fallback_location: ActiveAdmin.application.root_to }.merge(options)) 
  end   
  
end
