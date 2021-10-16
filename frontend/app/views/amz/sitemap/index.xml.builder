xml.instruct!(:xml, :encoding => "UTF-8")
xml.sitemapindex( :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9') do   
    updated_at = Time.now
    if @taxons   
        for i in 0...@taxons.total_pages.to_i  
            xml.sitemap { |b| b.loc((i > 0 ?  sitemap_xml_taxons_url(page: i+1) : sitemap_xml_taxons_url)); b.lastmod(updated_at.strftime("%Y-%m-%d"));  }   
        end
    end
    if @store_reviews
        for i in 0...@store_reviews.total_pages.to_i  
            xml.sitemap { |b| b.loc((i > 0 ?  sitemap_xml_reviews_url(page: i+1) : sitemap_xml_reviews_url)); b.lastmod(updated_at.strftime("%Y-%m-%d"));  }   
        end
    end
    if @cms 
        for i in 0...@cms.total_pages 
            xml.sitemap { |b| b.loc((i > 0 ?  sitemap_xml_cms_url(page: i+1) : sitemap_xml_cms_url)); b.lastmod(updated_at.strftime("%Y-%m-%d"));  }  
        end
    end 

end
