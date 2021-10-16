module Amz
    module FrontendHelper
      def body_class
        @body_class ||= content_for?(:sidebar) ? 'two-col' : 'one-col'
        @body_class
      end
  
      def amz_breadcrumbs(taxon, separator = '')
        return '' if current_page?('/') || taxon.nil?
  
        separator = raw(separator)
        index = 1
        crumbs = [content_tag(:li, content_tag(:span, link_to( content_tag(:span, current_store.name, itemprop: "name"), amz.root_url, itemprop: 'item' ) + separator ) + tag('meta', itemprop: "position", content: index = index ) ,  itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement', class: 'breadcrumb-item', itemscope: '')]
        if taxon && !taxon.blank? 
          crumbs << taxon.ancestors.collect { |ancestor| content_tag(:li, content_tag(:span, link_to(content_tag(:span, ancestor.name, itemprop: 'name'), seo_url(ancestor), itemprop: 'item' ) + separator  ) + tag('meta', itemprop: "position", content: index = index + 1 ),  itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement', class: 'breadcrumb-item', itemscope: '') } unless taxon.ancestors.empty?
          crumbs << content_tag(:li, content_tag(:span, link_to(content_tag(:span, taxon.name, itemprop: 'name'), seo_url(taxon), itemprop: 'item' ) )+ tag('meta', itemprop: "position", content: index = index + 1 ), class: 'active breadcrumb-item', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement', itemscope: '')
        end
        if @store_review 
          crumbs << content_tag(:li, content_tag(:span, link_to(content_tag(:span, @store_review.seo_name, itemprop: 'name'), seo_url(@store_review), itemprop: 'item' )  ) + tag('meta', itemprop: "position", content: index = index + 1 ), class: 'active breadcrumb-item', itemtype: 'https://schema.org/ListItem', itemprop: 'itemListElement', itemscope: '')
        end
        crumb_list = content_tag(:ol, raw(crumbs.flatten.map(&:mb_chars).join), class: 'breadcrumb')
        content_tag(:nav, crumb_list, id: 'breadcrumbs', itemscope: '', itemtype: 'https://schema.org/BreadcrumbList',  aria: { label: 'breadcrumb' })
      end 

      def amz_breadcrumbs_component(taxon, separator = '/') 
        separator = raw(separator)
        taxon = '' if current_page?('/') || taxon.nil?  
        if taxon && !taxon.blank?
          ancestors = taxon.ancestors.collect { |ancestor| { name: ancestor.name, url: seo_url(ancestor) } } 
          taxon = { name: taxon.name, url: seo_url(taxon) }
        else
          ancestors = [] 
        end
        if @store_review 
          review_name = @store_review.name 
          review_name = @store_review.review.name  if review_name.blank?
        else
          review_name = nil
        end
        { taxon: taxon, separator: separator, ancestors: ancestors, home: { name: I18n.t('home', default: "Home"), url: origin} , review_name: review_name  }
      end 

      def root_taxons
        current_store.taxons.where(parent_id: nil).show_in_menu
      end
  
      def redirect_url(product)
         #Todo
      end
  
      def taxons_tree(root_taxon, current_taxon, max_level = 1)
        return '' if max_level < 1 || root_taxon.leaf?
  
        content_tag :div, class: 'list-group' do
          taxons = root_taxon.children.map do |taxon|
            css_class = current_taxon&.self_and_ancestors&.include?(taxon) ? 'list-group-item list-group-item-action active' : 'list-group-item list-group-item-action'
            link_to(taxon.name, seo_url(taxon), class: css_class) + taxons_tree(taxon, current_taxon, max_level - 1)
          end
          safe_join(taxons, "\n")
        end
      end    

      def box_scale(box,scale) 
          w_original , h_original = [box[:width].to_f, box[:height].to_f]
          o_scale = w_original  /  h_original 
          n_box = {}
          if (o_scale == scale) 
              n_box = box
          elsif o_scale > scale  
            n_box[:width] = h_original * scale
            n_box[:height]  = h_original
          else o_scale < scale 
            n_box[:width] = w_original 
            n_box[:height] = w_original / scale
          end 
          n_box[:width] = n_box[:width].to_i 
          n_box[:height] = n_box[:height].to_i 
          n_box
      end

      def controller_widgets
            frontend_controller = Amz::FrontendController.find_by_name(controller_path)
            unless frontend_controller.blank?
                frontend_controller.widgets.where(store_id: current_store.id) if frontend_controller.widgets.any?
            end
      end 

      def drawer
        drawer =  Amz::Block.cache_by_store_id_and_identity(store_id: current_store.id,identity:  'app_drawer' )   
        drawer.description if drawer.present? 
      end

      def footer_policy
        footer_policy =  Amz::Block.cache_by_store_id_and_identity(store_id: current_store.id,identity:  'footer_policy' )   
        footer_policy.description if footer_policy.present? 
      end

      def header_links
        header_links = Amz::Block.cache_by_store_id_and_identity(store_id: current_store.id,identity:  'header_links' )
        header_links.description if header_links.present?
      end

      def footer_links
        footer = Amz::Block.cache_by_store_id_and_identity(store_id: current_store.id,identity:  'footer_links' )
        footer.description if footer.present? 
      end

      def review_sidebar_box
        sidebar_box = Amz::Block.cache_by_store_id_and_identity(store_id: current_store.id,identity:  'sidebar_box' )
        sidebar_box.description if sidebar_box.present? 
      end

      def home_ad_block
        home_ad_block = Amz::Block.cache_by_store_id_and_identity(store_id: current_store.id,identity:  'home_ad_block' )
        home_ad_block.description if home_ad_block.present? 
      end

      def amp_description(description)
        description = description_img_init(description)  
        description = description.gsub(/<img[^>]*?class="(.*?)"[^>]*?\/?>/){ |m| m.gsub($1,"\\& layout-responsive")  }  
        description = description.gsub(/<a[^>]*?(href=".*?\/redirect.*?")[^>]*?>/){ |m| m.gsub($1,"\\& rel=\"nofollow noopener noreferrer\"")  }  
        description = description.gsub(/<img([^>]*)?\/?>/,"<amp-img\\1 layout='responsive'></amp-img><noscript><img\\1></noscript>")
        description = description.gsub(/<amp-img([^>]*?img-fixed[^>]*?) layout='responsive'>/,"<amp-img\\1 layout='fixed'>")  
        description = description.gsub(/<video[^>]*?>(<source[^>]*?>)[\S\s]*?<\/video>/,'<amp-video controls width="640" height="360" layout="responsive">\1</amp-video>')
        description = description.gsub(/<iframe[^>]*?\/embed\/(.*?)\"[\S\s]*?<\/iframe>/,'<amp-youtube data-videoid="\1" width="640" height="360" layout="responsive"></amp-youtube>')
      end

      def description_img_init(description) 
        description = description.gsub(/<img([^>]*?)\/?>/, '<img\1 width="400" height="300">' )
        description.gsub(/<img.*?style=\".*?width:\s?(\d*)px;.*?\"/, "\\& width=\"\\1\"" ).gsub(/<img.*?style=\".*?height:\s?(\d*)px;.*?\"/, "\\& height=\"\\1\"" ).gsub(/(width:\s*?\d*px;|height:\s*?\d*px;)/,'')
        # .gsub(/<img.*?style=\".*?width:\s?(\d*)px;.*?\"/, "\\& width=\"\\1\"" ).gsub(/<img.*?style=\".*?height:\s?(\d*)px;.*?\"/, "\\& height=\"\\1\"" )
      end

      def flags
        
         
        if @store_review && @review  
          @review_stores = @review.stores 
        end

        stores = Amz::Store.where("id not in (?)", current_store.id) 
        
        flags  = '<div class="flags dropup">'
        flags += '<input aria-label="Locales" data-vars-label="Flags Trigger" class="dropdown-trigger" type="checkbox">'
        flags += '<span class="dropdown-toggle">'
        flags += "#{current_store.cache_locale.name}"
        flags += '</span>'
        if stores.size > 0 
          # "#{protocol}#{store.domain}/" 
          flags += '<div class="dropdown-menu">'
          stores.each do |store|
            market_place = store.market_place.downcase 
            flags += "<a data-vars-label=\"#{store.cache_locale.name}\" href=\"#{@review_stores && @review_stores.ids.include?(store.id) ? seo_url(@review, nil, store) : origin(store)}\" class=\"dropdown-item market-place-#{market_place}\">#{store.cache_locale.name}</a>"  
          end
          flags += '</div></div>'
        else
          flags = ''
        end
        flags
      end


      
      def link_data_tags
        # link_data =  tag('link', rel: "apple-touch-icon", content: content).join("\n")
        link_data = link_data_tag(rel: "apple-touch-icon", size: 57) + "\n"
        link_data = link_data_tag(rel: "apple-touch-icon", size: 60) + "\n"
        link_data += link_data_tag(rel: "apple-touch-icon", size: 72) + "\n"
        link_data += link_data_tag(rel: "apple-touch-icon", size: 114) + "\n"
        link_data += link_data_tag(rel: "apple-touch-icon", size: 120) + "\n"
        link_data += link_data_tag(rel: "apple-touch-icon", size: 144) + "\n"
        link_data += link_data_tag(rel: "apple-touch-icon", size: 152) + "\n" 
        link_data += link_data_tag(rel: "apple-touch-icon", size: 180) + "\n" 
        link_data += link_data_tag(rel: "icon", size: 512, type: true) + "\n" 
        link_data += link_data_tag(rel: "icon", size: 192, type: true) + "\n" 
        link_data += link_data_tag(rel: "icon", size: 96, type: true) + "\n" 
        link_data += link_data_tag(rel: "icon", size: 32, type: true) + "\n" 
        link_data += link_data_tag(rel: "icon", size: 16, type: true) + "\n" 
        link_data += tag('link', rel: "manifest", href: "/manifest.json" )  + "\n" 
        link_data += tag('meta', name: "theme-color", content: current_store.preferred_tile_color )  + "\n" 
        link_data += tag('meta', name: "msapplication-TileColor", content: current_store.preferred_tile_color )  + "\n"  
        link_data += tag('meta', name: "msapplication-TileImage", content: mini_url_image(current_store.favicon) )  + "\n" 
      end

      def link_data_tag(*options)
        favicon = current_store.favicon
        attachment = favicon.attachment
        options = options.first || {}
        rel = options[:rel]
        size = options[:size]
        type = options[:type] || false
        href =  image_resize(current_store.favicon, sizes:size )
        if type
          tag('link', rel: rel, sizes: "#{size}x#{size}", href: href, type: attachment.content_type )
        else
          tag('link', rel: rel, sizes: "#{size}x#{size}", href: href ) 
        end
      end

      def link_favicon  
        if current_store.favicon
          link_data_tags
        end
      end 

      def svg(icon,*options)
        options = options.first || {}
        icon = icon.to_sym
        width = options[:width] || 24
        height = options[:height] || 24
        class_name =  options[:class] || ""
        fill = options[:fill] || "currentColor"
        svg_options = {
          width: width,
          height: height,
          class: class_name,
          fill: fill,
          viewBox: "0 0 24 24"
        }
        content_tag :svg, svg_options do 
          self.send(icon)
        end
      end

      private

      def search 
        tag_path("M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z")
      end

      def check_circle
        tag_path("M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z")
      end

      def expand_more
        tag_path("M16.59 8.59L12 13.17 7.41 8.59 6 10l6 6 6-6z")
      end

      def share
        tag_path("M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92 1.61 0 2.92-1.31 2.92-2.92s-1.31-2.92-2.92-2.92z")
      end

      def done 
        tag_path("M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z")
      end

      def expand_less 
        tag_path("M12 8l-6 6 1.41 1.41L12 10.83l4.59 4.58L18 14z")
      end

      def shopping_cart
        tag_path("M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z") 
      end

      def nav_menu
        tag_path("M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z")
      end

      def labels
        tag_path("M17.63 5.84C17.27 5.33 16.67 5 16 5L5 5.01C3.9 5.01 3 5.9 3 7v10c0 1.1.9 1.99 2 1.99L16 19c.67 0 1.27-.33 1.63-.84L22 12l-4.37-6.16z")
      end

      def tag_path(svg_path)
        tag(:path, 
          "fill-rule": "evenodd", 
          d: svg_path
        )
      end

    end
  end