xml.instruct!(:xml, :encoding => "UTF-8")
xml.urlset( :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9') do 
    @taxons.each do |taxon|
        xml.url { |b| b.loc(seo_url(taxon)); b.lastmod(taxon.updated_at.strftime("%Y-%m-%d")); b.changefreq(current_store.preferred_sitemap_taxon_changefreq); b.priority(current_store.preferred_sitemap_taxon_priority)  }
    end
end
