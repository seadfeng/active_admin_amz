$(function(){ 
    var authenticity_token = $("meta[name='csrf-token']").attr("content",authenticity_token);
    var ellipsis = '<div class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>'; 
    var $action_item = $(".index_as_jstree .action_items #taxon-delete");
    var $taxonForm = $(".taxon-form");
    var jstree_create = function( node ){  
        var taxon_url =  node.original.url.replace(/jstree/,"new_form")   
        $taxonForm.html(ellipsis)
        $.get({
            type: "POST",
            url: taxon_url , 
            data: {
                authenticity_token: $("meta[name='csrf-token']").attr("content"),
            },
            success: function(res){
                console.log("jstree_create")
                $taxonForm.html(res);
                // $taxonForm.find("input[name:'authenticity_token']").val(authenticity_token)
            },
            error: function(res) {
                $taxonForm.html("Errors"); 
            }
        })
    }
    var jstree_move = function(e, data){  
        var url = data.node.original.url.replace(/\/jstree/,"")   
        $.get({
            type: "PUT",
            url: url , 
            data: {
                "authenticity_token": $("meta[name='csrf-token']").attr("content"), 
                'taxon[parent_id]' : data.parent, 
                'taxon[child_index]' : data.position
            },
            success: function(res){
                // console.log(res) 
                data.instance.refresh();  
            },
            error: function(res) {
                data.instance.refresh();
            }
        })
    } 
    var jstree_changed = function(e, data){ 
        if(data && data.selected && data.selected.length && data.node.original.url) { 
            var taxon_url = data.node.original.url.replace(/jstree/,"form")   
            $taxonForm.html(ellipsis)
            $.get({
                type: "POST",
                url: taxon_url , 
                data: {
                    authenticity_token: $("meta[name='csrf-token']").attr("content"),
                },
                success: function(res){
                    $taxonForm.html(res);  
                    if(data.node.parent != "#"){
                        //Init Delete Data
                        $action_item.html('Delete')
                        $action_item.show().attr("data-taxon-id",data.node.id) 
                        $action_item.show().attr("data-taxon-url",data.node.original.url) 
                        $action_item.show().attr("data-parent",data.node.parent) 
                    }else{
                        $action_item.html('').hide()
                    }
                },
                error: function(res) {
                    $taxonForm.html("Errors"); 
                }
            }) 
        } else {
            // $('#data .content').hide();
            // $('#data .default').text('Select a file from the tree.').show();
        }
    }
    $action_item.click(function(){
        var rand = Math.ceil(Math.random()*10)
        var inputText = prompt("Please enter nomber "+rand,"")
        if( parseInt(inputText) == rand){ 
            var taxon_url = $(this).data("taxon-url").replace(/\/jstree/,"")
            var parent = $(this).data("parent") 
            var taxon = $(this).data("taxon-id") 
            $taxonForm.html(ellipsis)
            $.get({
                type: "DELETE",
                url: taxon_url , 
                data: {
                    authenticity_token: $("meta[name='csrf-token']").attr("content"),
                },
                success: function(res){
                    console.log("jstree_delete")
                    var ref = $('.taxonomy-tree').jstree(true)
                    // var selected = ref.select_node(parent); 
                    // if(selected && !selected.length) { return false; } 
                    // ref.select_node(parent)
                    ref.refresh_node(parent);  
                    ref.select_node(parent); 
                },
                error: function(res) {
                    $taxonForm.html("Errors"); 
                }
            })
        }else{
            return false
        }
    })
    $('#node-create-child').click(function(){
        var ref = $('.taxonomy-tree').jstree(true),
        selected = ref.get_selected(); 
        if(!selected.length) { return false; }
        var sel = selected[0];
        sel = ref.create_node(sel); 
        if(sel) { 
            jstree_create(ref.get_node(selected));
            ref.deselect_node(selected);
            ref.select_node(sel);
        } 
    }) 
    $(".taxonomy-tree").jstree({
        'core' : {
            'data' : {
                'url' : function (node) {  
                    return node.id === '#' ? this.element[0].dataset.taxonomy : node.original.url   ;
                },  
                'check_callback' : true,
            },
            "multiple" : false,
            'force_text' : true,
            'check_callback' : true,
            'themes' : {
                'responsive' : false
            }
        },
        "types": {
            "#" :{
                "max_depth" : 2
            }
        },
        'force_text' : true,
        'plugins' : ['state','dnd','default']
    })
    .on('changed.jstree', jstree_changed)
    .on('move_node.jstree',jstree_move)
    // .on('create_node.jstree', jstree_create)
})