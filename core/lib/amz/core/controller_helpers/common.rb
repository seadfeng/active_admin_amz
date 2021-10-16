module Amz
    module Core
      module ControllerHelpers
        module Common
          extend ActiveSupport::Concern
          included do
            helper_method :title
            helper_method :short_time
            helper_method :long_time
            helper_method :meta_time
            helper_method :is_amp?
            helper_method :title=
            helper_method :accurate_title
  
            layout :get_layout
  
            before_action :set_user_language
  
            protected
  
            # can be used in views as well as controllers.
            # e.g. <% self.title = 'This is a custom title for this view' %>
            attr_writer :title
  
            def title
              title_string = @title.present? ? @title : accurate_title
              if title_string.present?
                if Amz::Config[:always_put_site_name_in_title]
                  [title_string, default_title].join(" #{Amz::Config[:title_site_name_separator]} ")
                else
                  title_string
                end
              else
                default_title
              end
            end
  
            def default_title
              current_store.name
            end
  
            # this is a hook for subclasses to provide title
            def accurate_title
              current_store.meta_title
            end

            def description(object)
              object.try(:description) 
            end 
            
            def long_time(time)
              I18n.l(time, format: :long, locale: :"#{current_store.cache_locale.code}")
             end
          
            def short_time(time)
              I18n.l(time, format: :short, locale: :"#{current_store.cache_locale.code}")
            end

            def meta_time(time)
              time.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
            end

            def browser
              detect_browser
            end

            def is_amp?
              # browser.mobile? || browser.tablet?
              current_store.amp?
            end
  
            private
  
            def set_user_language
              locale = session[:locale]
              locale = store_locale if respond_to?(:store_locale, true) && locale.blank?
              locale = config_locale if respond_to?(:config_locale, true) && locale.blank?
              locale = Rails.application.config.i18n.default_locale if locale.blank?
              locale = I18n.default_locale unless I18n.available_locales.map(&:to_s).include?(locale.to_s) 
              I18n.locale = locale
            end

            def detect_browser 
              Browser::Base.include(Browser::Aliases)
              browser = Browser.new(request.headers["HTTP_USER_AGENT"])
            end
  
            # Returns which layout to render.
            #
            # You can set the layout you want to render inside your Amz configuration with the +:layout+ option.
            #
            # Default layout is: +app/views/amz/layouts/amz_application+
            #
            def get_layout
              layout ||= Amz::Config[:layout] 
              layout = Amz::Config[:amp_layout] 
              # layout = Amz::Config[:mobile_layout] if  browser.mobile?
              # layout = Amz::Config[:tablet_layout] if  browser.tablet?
              layout
            end
 
          end
        end
      end
    end
  end