require 'amz/core/search/base'
require 'amz/core/search/thinking_sphinx'
module Amz
    class AppConfiguration < Preferences::Configuration
        preference :reviews_per_page, :integer, default: 12
        preference :title_site_name_separator, :string, default: '-'
        preference :always_put_site_name_in_title, :boolean, default: true
        preference :layout, :string, default: 'amz/layouts/amz_application'
        preference :amp_layout, :string, default: 'amp/layouts/amp_application'
        preference :mobile_layout, :string, default: 'amz/layouts/amz_mobile_application' 
        preference :tablet_layout, :string, default: 'amz/layouts/amz_tablet_application'  
        preference :logo, :string, default: 'logo/amz.svg'
        preference :amzn_assoc_host, :string, default: 'ws-na.amazon-adsystem.com'
        preference :max_level_in_categories_menu, :integer, default: 2 # maximum nesting level in categories menu
        preference :max_depth_in_categories, :integer, default: 2 # maximum nesting level in categories
        preference :max_size_in_related_reviews, :integer, default: 4  #
        preference :max_article_description_in_widgets, :integer, default: 460 

        def searcher_class
            # @searcher_class ||= Amz::Core::Search::Base
            @searcher_class ||= Amz::Core::Search::ThinkingSphinx 
        end
        attr_writer :searcher_class
    end
end