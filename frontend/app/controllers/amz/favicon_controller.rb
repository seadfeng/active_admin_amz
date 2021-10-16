module Amz
    class FaviconController < Amz::StoreController

        def manifest
            @json = {
              name: current_store.name, 
              icons:  manifest_icons(current_store.favicon),
              background_color: current_store.preferred_tile_color,
              theme_color: current_store.preferred_tile_color
            } 
            render :json => @json
        end

        def browserconfig
            @favicon = current_store.favicon  
        end

        private

        def manifest_icons(favicon)
            return nil if favicon.blank? 
            return [ 
                manifest_icon(favicon,36, "0.75"), 
                manifest_icon(favicon,48, "1"),
                manifest_icon(favicon,72, "1.5"),
                manifest_icon(favicon,96, "2"),
                manifest_icon(favicon,144, "3.0"),
                manifest_icon(favicon,192, "4.0"),   
                manifest_icon(favicon,512, "5.0"),   
             ]
        end

        def manifest_icon(favicon, size, density)
            {
                src:  image_resize(favicon, sizes: size ) ,
                sizes: "#{size}x#{size}",
                type: favicon.attachment.content_type,
                density: density
            }
        end
 
    end
end 
