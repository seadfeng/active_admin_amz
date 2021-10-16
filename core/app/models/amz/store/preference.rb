module Amz
    class Store < Amz::Base
        module Preference
            extend ActiveSupport::Concern
            included do
                preference :reviews_per_page, :integer, default: 12
                preference :featured_limit, :integer, default: 4

                preference :esi, :boolean, default: false 
                preference :amp, :boolean, default: false 
                preference :varnish_host, :string, default: '127.0.0.1'   
                preference :time_zone, :string, default: 'Europe/Andorra' 
                preference :tile_color, :string, default: '#FFFFFF' 
                preference :google_ga, :string, default: '' 
                preference :google_gtm_id, :string, default: ''  
                preference :google_gtag_redirect, :string, default: ''   
                preference :google_gtag_id, :string, default: ''   
                preference :facebook_pixel, :string, default: '' 
                preference :facebook_app_id, :string, default: '' 
                preference :sitemap_taxon_changefreq, :string, default: 'daily' 
                preference :sitemap_taxon_priority, :string, default: '0.8' 
                preference :sitemap_cms_changefreq, :string, default: 'weekly' 
                preference :sitemap_cms_priority, :string, default: '0.8' 
                preference :sitemap_review_changefreq, :string, default: 'daily' 
                preference :sitemap_review_priority, :string, default: '0.8' 
                preference :search_title, :string, default: 'Shop %{keywords} Online' 
                preference :review_title, :string, default: 'Top %{number} %{keywords} of %{year}' 
                preference :search_meta_description, :string, default: ''  
                preference :review_meta_description, :string, default: '%{store_name} analyzes and compares all %{keywords} of %{year}. You can easily compare and choose from the %{number} best %{keywords} for you.'  
                preference :head_code, :string, default: ''  
                preference :foot_code, :string, default: ''  
                preference :amz_image_crop, :boolean, default: true
                preference :top_number, :integer, default: 9


                def method_missing(method_name, *args, &block) 
                    action =  "preferred_#{method_name}".to_sym   
                    if respond_to?(action)
                        send(action, *args) 
                    else
                        super
                    end 
                end   
            end
        end
    end
end
