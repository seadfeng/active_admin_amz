module Amz
  module Frontend
    class Engine < ::Rails::Engine 

      # Prevent XSS but allow text formatting
      config.action_view.sanitized_allowed_tags = %w(a b del em i ins mark p span small strong sub sup h2 h3 h4 h5 img br hr div iframe ul ol li video source nav section amp-img amp-youtube amp-video amp-accordion input noscript amp-ad)
      config.action_view.sanitized_allowed_attributes = %w(href id src class style width height alt rel title type controls data-turbolinks allow allowfullscreen frameborder on hidden layout data-videoid fallback data-amzn_assoc_ad_mode data-divid data-recomtype data-adinstanceid data-aax_size data-aax_pubname data-aax_src data-cid data-publisher data-mode data-placement data-article)

      # initializer "amz.add_middleware" do |app|
      #   app.middleware.use Amz::Frontend::Middleware::SeoAssist
      # end
 
      initializer 'amz.frontend.environment', before: :load_config_initializers do |_app|
        Amz::Frontend::Config = Amz::FrontendConfiguration.new
      end 

      initializer "amz.auth.environment", before: :load_config_initializers do |_app| 
        Amz::Auth::Config = Amz::AuthConfiguration.new 
      end 

      initializer "amz_auth_devise.set_user_class", after: :load_config_initializers do
        Amz.user_class = "Amz::User"
      end 


      initializer "Amz_auth_devise.check_secret_token" do
        if Amz::Auth.default_secret_key == Devise.secret_key
          puts "[WARNING] You are not setting Devise.secret_key within your application!"
          puts "You must set this in config/initializers/devise.rb. Here's an example:"
          puts " "
          puts %{Devise.secret_key = "#{SecureRandom.hex(50)}"}
        end
      end 

    end
  end
end
