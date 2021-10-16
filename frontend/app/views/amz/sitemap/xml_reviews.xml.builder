xml.instruct!(:xml, :encoding => "UTF-8")
xml.urlset( :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9') do 
    @store_reviews.each do |reviews|
        xml.url { |b| b.loc(seo_url(reviews)); b.lastmod(reviews.updated_at.strftime("%Y-%m-%d")); b.changefreq(current_store.preferred_sitemap_review_changefreq); b.priority(current_store.preferred_sitemap_review_priority)  }
    end
end
