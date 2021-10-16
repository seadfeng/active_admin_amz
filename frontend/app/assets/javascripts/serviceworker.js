importScripts('https://cdn.ampproject.org/sw/amp-sw.js');
AMP_SW.init({
  assetCachingOptions: [
    {
      regexp: /\.(png|jpg|woff2|woff|css|js|svg)/,
      cachingStrategy: 'CACHE_FIRST',
    },
  ],
  offlinePageOptions: {
    url: '/offline.html',
    assets: [],
  },
});
 