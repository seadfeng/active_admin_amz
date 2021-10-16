$(function() { 
    $("#product_description").each(function(){ 
       var _this = $(this) 
       var val = _this.val()
       var hints = '<ul style="list-style: inherit; list-style-type: decimal; margin-left: 1em;"><li>'
       if(val){
            hints = hints + val.split(/[\n]/).join('</li><li>') 
            hints = hints + "</li>"  
            _this.parent().find('.inline-hints').html(hints)
       } 
    })
})