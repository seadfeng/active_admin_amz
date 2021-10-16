xml.instruct!(:xml, :encoding => "UTF-8")
xml.urlset( :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9') do 
    @cms.each do |cms|
        xml.url { |b| b.loc(seo_url(cms)); b.lastmod(cms.updated_at.strftime("%Y-%m-%d")); b.changefreq(current_store.preferred_sitemap_cms_changefreq); b.priority(current_store.preferred_sitemap_cms_priority)  }
    end
end
