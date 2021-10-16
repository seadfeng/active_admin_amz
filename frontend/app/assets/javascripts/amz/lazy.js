
var lazyLoad = function(){
    var lazyImages = [].slice.call(document.querySelectorAll("img.lazy"));
    lazyImages.forEach(function(lazyImage) { 
        let src = lazyImage.src;
        lazyImage.src = lazyImage.getAttribute('data-placeholder-src');
        lazyImage.setAttribute('data-src', src); 
    });
    var lazyCmsImages = [].slice.call(document.querySelectorAll(".cms img"));
    lazyCmsImages.forEach(function(lazyImage) { 
        let src = lazyImage.src; 
        // lazyImage.src = "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==";  
        lazyImage.src = "data:image/svg+xml;base64,CjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB3aWR0aD0iNzgiIGhlaWdodD0iNzgiIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaWRZTWlkIiBzdHlsZT0iYmFja2dyb3VuZDowIDAiIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj48Y2lyY2xlIGN4PSI1MCIgY3k9IjUwIiByPSIyMCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDAxMTNkIiBzdHJva2UtZGFzaGFycmF5PSI5NC4yNDc3Nzk2MDc2OTM3OSAzMy40MTU5MjY1MzU4OTc5MyIgc3Ryb2tlLXdpZHRoPSIzIiB0cmFuc2Zvcm09InJvdGF0ZSgxMTkuODM3IDUwIDUwKSI+PGFuaW1hdGVUcmFuc2Zvcm0gYXR0cmlidXRlTmFtZT0idHJhbnNmb3JtIiBiZWdpbj0iMHMiIGNhbGNNb2RlPSJsaW5lYXIiIGR1cj0iMS4zcyIga2V5VGltZXM9IjA7MSIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiIHR5cGU9InJvdGF0ZSIgdmFsdWVzPSIwIDUwIDUwOzM2MCA1MCA1MCIvPjwvY2lyY2xlPjwvc3ZnPg=="
        lazyImage.setAttribute('data-src', src); 
    });
    if ("IntersectionObserver" in window) {
        let lazyImageObserver = new IntersectionObserver(function(entries, observer) {
            entries.forEach(function(entry) {
            if (entry.isIntersecting) {
                let lazyImage = entry.target;
                let src = lazyImage.dataset.src;
                lazyImage.src = src;
                // lazyImage.srcset = lazyImage.dataset.srcset;
                let sl = src.match(/_SL(\d*)/);
                let imageId = src.match(/.*\/I\/([^\.]*)\./);
                if(sl && sl.length > 1 && imageId && imageId.length > 1){
                    let width = sl[1];
                    imageId = imageId[1]; 
                    if(width > 768){
                        lazyImage.setAttribute("srcset", "https://m.media-amazon.com/images/I/" + imageId
                                                        +"._SL240.jpg 240w,\r\n https://m.media-amazon.com/images/I/" + imageId
                                                        +"._SL480.jpg 480w,\r\n https://m.media-amazon.com/images/I/" + imageId
                                                        +"._SL640.jpg 640w,\r\n https://m.media-amazon.com/images/I/" + imageId  
                                                        +"._SL720.jpg 720w,\r\n "+src+" "+width+"w");
                    }else if(width > 640){
                        lazyImage.setAttribute("srcset", "https://m.media-amazon.com/images/I/" + imageId
                        +"._SL240.jpg 240w,\r\n https://m.media-amazon.com/images/I/" + imageId
                        +"._SL480.jpg 480w,\r\n https://m.media-amazon.com/images/I/" + imageId 
                        +"._SL640.jpg 640w,\r\n "+src+" "+width+"w");
                    }else if(width > 480){
                        lazyImage.setAttribute("srcset", "https://m.media-amazon.com/images/I/" + imageId
                                            +"._SL240.jpg 240w,\r\n https://m.media-amazon.com/images/I/" + imageId 
                                            +"._SL480.jpg 480w,\r\n "+src+" "+width+"w");
                    } 
                }
                lazyImage.classList.remove("lazy"); 
                lazyImageObserver.unobserve(lazyImage);
            }
            });
        });
    
        lazyImages.forEach(function(lazyImage) {
            lazyImageObserver.observe(lazyImage);
        });
        lazyCmsImages.forEach(function(lazyImage) {
            lazyImageObserver.observe(lazyImage);
        });
    } else {
        // Possibly fall back to event handlers here
    }  
}
var cleanImgs = function(){
    var images = [].slice.call(document.querySelectorAll(".cms img"));
    images.forEach(function(image) { 
        image.setAttribute("style", '') //`aspect-ratio: auto ${image.getAttribute("width")} / ${image.getAttribute("height")}`
    });
}
var youtube = function(){
     var iframes = [].slice.call(document.querySelectorAll(".cms iframe")); 
     iframes.forEach(function(iframe) { 
        var div = document.createElement('div');  
        var new_iframe = document.createElement('iframe');  
        new_iframe.setAttribute("src", iframe.src );
        new_iframe.setAttribute("allowfullscreen", true );
        new_iframe.setAttribute("frameborder", 0 );
        new_iframe.setAttribute("allow", "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" );
        div.appendChild(new_iframe);
        div.setAttribute("class", "videoWrapper"); 
        iframe.parentNode.insertBefore(div,iframe);
        iframe.parentNode.removeChild(iframe);
    });
}
document.addEventListener("turbolinks:load", function() {  
    lazyLoad();
    cleanImgs();
    youtube();
    if (typeof(ga) === "function"){  
        ga('send', 'pageview', (location.pathname + location.search));
    }
}); 