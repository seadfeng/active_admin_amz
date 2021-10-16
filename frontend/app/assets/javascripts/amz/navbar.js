 $(document).on('turbolinks:load', function() {
    var token = $( 'meta[name="csrf-token"]' ).attr( 'content' );
    
    var $navbar = $('.header .navbar');
    var $target = $('#navbarToggleExternalContent'); 
    var $main = $('#main-container'); 
    var $mainContainer = $('#main-container .container');  
    var $footer = $('#footer'); 
    var $header= $("#header");
    var $subheader= $("#sub-header");
    var $body = $('body'); 
    var $navbarSearch = $('#navbarSearch'); 
    var $btnSearch = $('#btn-search'); 
    var $logo = $('.navbar .logo');
    var $searchResult = $('#searchResult'); 
    var $sidebar = $("#sidebar"); 
    var $ampSocialShare = $("#amp-social-share");
    var $btnSocialShare = $("#btn-social-share");
    var $sidebarRight = $("#sidebar-right");

    var mainContainerWidth = $mainContainer.width();
    var bodyWidth = $body.width();
    
    console.log("turbolinks:load"); 
    

    var putSearch = function(data) {
        $.ajax({
            type: 'POST',
            url: $(navbarSearch).attr('action'),
            contentType: 'application/json', 
            data: JSON.stringify(data), 
            beforeSend: function ( xhr ) {
                xhr.setRequestHeader( 'X-CSRF-Token', token );
            }
        }).done(function (res) {
            console.log('SUCCESS');
            console.log(res);
            $searchResult.html("");
            str = ""
            res.forEach(obj => {
                // obj.name
                // obj.image
                // obj.reviews
                // obj.title
                // obj.url
                li = "<li class=\"list-group-item\"><a href=\""+obj.url+"\"><span class=\"img\"><img src=\""+obj.image+"\"></span><span><b>"+obj.name+"</b><i>"+obj.title+"</i></span></a></li>";
                str = str + li;
            })  
            $searchResult.html(str);
        }).fail(function (msg) {
            console.log('FAIL');
        }).always(function (msg) {
            console.log('ALWAYS');
        });
    }
    
    $('.product [data-toggle="tooltip"]').tooltip();
    $('.product [data-toggle="tooltip"]').on('shown.bs.tooltip', function () {
        // do something...
        $(".tooltip").css({width: $(this).parent().width()});
    })
    $(".header .navbar .navbar-toggler").click( function () { 
        $target.toggleClass('show');
        $navbar.toggleClass('show'); 
        $main.toggleClass('d-none'); 
        $footer.toggleClass('d-none'); 
        $sidebar.toggleClass('d-none'); 
        $body.toggleClass('bg-dark'); 
        if($subheader) {
            $subheader.toggleClass('d-none'); 
        }
    })
    
    $(".product a[role=button]").click(function(){ 
        $(this.hash.replace('#','.')).toggleClass('d-none');
        $(this.hash).toggleClass('show');
        $(this.hash).each(function(){ 
            let offsetHeigth = 75; 
            let y =  $(this).parent().offset().top - offsetHeigth; 
            $('html, body').animate({ scrollTop: y, }, 100);
        }) 
        
    })

    var hash = window.location.hash;
     
    if(hash){ 
        $(hash).each(function(){ 
            $(this).parent().find('.more a:not(.d-none)').click();
        })
    }

    $(window).click(function(){
        $navbarSearch.collapse('hide'); 
        $btnSearch.show();  
        $searchResult.html("");  
        $ampSocialShare.addClass('d-none'); 
    })

    $btnSocialShare.click(function(){
        $ampSocialShare.toggleClass('d-none'); 
    })

    $btnSocialShare.click(function(event){
        event.stopPropagation(); 
    })
    $navbarSearch.click(function(event){
        event.stopPropagation(); 
    })
    $searchResult.click(function(event){
        event.stopPropagation();
    });

    $navbarSearch.on('shown.bs.collapse', function () { 
        $btnSearch.toggleClass('d-none');   
        $logo.hide();
    })
    $navbarSearch.on('hidden.bs.collapse', function () {
        $logo.show();
        $btnSearch.toggleClass('d-none');  
    })
    
    $navbarSearch.find('.form-control').each(function(){
        $(this).focus(function(){
            $searchResult.css({'width': $(this).outerWidth(),'top': $(this).outerHeight() });
            var keywords = $(this).val();
            var data = { "keywords": $(this).val() } 
            if(keywords != "") putSearch(data);
        })
        $(this).keyup(function(){
            var data = { "keywords": $(this).val() }
            console.log(data)
            putSearch(data);
        })
    })
    $navbarSearch.on("submit",function(event){
        if($navbarSearch.find('.form-control').val() == ""){
            event.preventDefault();
        } 
    })
    $("#sidebar nav li a").click(function(){
        let section = $(this.hash); 
        let offsetHeigth = $header.height();
        let y = section.offset().top - offsetHeigth - 30; 
        $('html, body').animate({ scrollTop: y, },100);
    })
    $(".card-body ul li a").click(function(){
        let section = $(this.hash); 
        let offsetHeigth = $header.height();
        let y = section.offset().top - offsetHeigth - 10; 
        $('html, body').animate({ scrollTop: y, },100);
    }) 

    $("#ez-toc-container").each(function(){  
        $sidebarRight.append('<div id="sidebar-toc"></div>');
        $("#sidebar-toc").html($(this).html());
        $("#sidebar-toc ul li a").click(function(){
            let section = $(this.hash); 
            let offsetHeigth = $header.height();
            let y = section.offset().top - offsetHeigth - 10; 
            $('html, body').animate({ scrollTop: y, },100);
        }) 
    })
    $("#sidebar, #sidebar-right").each(function(){ 
        var sidebarWidth = (bodyWidth - mainContainerWidth ) / 2 - 30;
        if(bodyWidth > 1280){
            $(this).width(sidebarWidth);
        }
    });

    $(window).resize(function(){
        var mainContainerWidth = $mainContainer.width();
        var bodyWidth = $body.width();
        if(bodyWidth > 1280){ 
        
            $("#sidebar, #sidebar-right").each(function(){ 
                var sidebarWidth = (bodyWidth - mainContainerWidth ) / 2 - 30;
                $(this).width(sidebarWidth);
            }); 
        }
    })
   
});
