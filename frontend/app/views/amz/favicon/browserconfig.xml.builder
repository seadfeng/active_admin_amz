xml.instruct!(:xml, :encoding => "UTF-8", :version => "1.0" )
if @favicon
    xml.browserconfig do
        xml.msapplication do
            xml.tile do
                xml.square70x70logo( :src =>  main_app.url_for(@favicon.attachment.variant(resize: 70)) ) 
                xml.square150x150logo( :src =>  main_app.url_for(@favicon.attachment.variant(resize: 150)) ) 
                xml.square310x310logo( :src =>  main_app.url_for(@favicon.attachment.variant(resize: 310)) ) 
                xml.TileColor(current_store.preferred_tile_color)
            end
        end
    end
end
