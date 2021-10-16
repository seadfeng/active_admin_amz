$(function() { 
    $.fn.extend({
        imageUpload :function(){
            if($(this).length == 0) return false;
            if(!$(this).has(".col-image")) return false;
            var collection_path = $(this).data('collection-path');
            var self = $(this);
            console.log("ImageUpload Start");
            console.log(collection_path); 

            ignoreDrag = function(e){
                e.originalEvent.stopPropagation();
                e.originalEvent.preventDefault();
            } 
            // 获得拖拽文件的回调函数
            getDropFileCallBack = function (dropFiles) {
                console.log(dropFiles, dropFiles.length);
            }

            dragenter = function(e) {
                ignoreDrag(e);
                $(this).addClass("selected")
            }

            dragover = function(e) {
                ignoreDrag(e)
            }

            dragleave =  function(e) {
                ignoreDrag(e);
                $(this).removeClass("selected")
            }

            drop = function(e) {
                ignoreDrag(e);
                var df = e.originalEvent.dataTransfer;
                var dropFiles = []; // 拖拽的文件，会放到这里
                var dealFileCnt = 0; // 读取文件是个异步的过程，需要记录处理了多少个文件了
                var allFileLen = df.files.length; // 所有的文件的数量
                // 检测是否已经把所有的文件都遍历过了
                function checkDropFinish() {
                    if (dealFileCnt === allFileLen - 1) {
                        getDropFileCallBack(dropFiles);
                    }
                    dealFileCnt++;
                }
        
                if (df.items !== undefined) {
                    // Chrome拖拽文件逻辑
                    for (var i = 0; i < df.items.length; i++) {
                        var item = df.items[i];
                        if (item.kind === "file" && item.webkitGetAsEntry().isFile) {
                            var file = item.getAsFile();
                            dropFiles.push(file);
                        }
                    }
                } else {
                    // 非Chrome拖拽文件逻辑
                    for (var i = 0; i < allFileLen; i++) {
                        var dropFile = df.files[i];
                        if (dropFile.type) {
                            dropFiles.push(dropFile);
                            checkDropFinish();
                        } else {
                            try {
                                var fileReader = new FileReader();
                                fileReader.readAsDataURL(dropFile.slice(0, 3));
        
                                fileReader.addEventListener('load', function (e) {
                                    console.log(e, 'load');
                                    dropFiles.push(dropFile);
                                    checkDropFinish();
                                }, false);
        
                                fileReader.addEventListener('error', function (e) {
                                    console.log(e, 'error，不可以上传文件夹');
                                    checkDropFinish();
                                }, false);
        
                            } catch (e) {
                                console.log(e, 'catch error，不可以上传文件夹');
                                checkDropFinish();
                            }
                        }
                    }
                }
        
                //提交
                var id = $(this).attr("id").replace(/[^0-9]/ig, "");
                $(this).find(".col-image").prepend('<div class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>')
                $(this).find(".col-image img").addClass('hide')
                
                submitImg(dropFiles, id, $(this))
            }
            // EOF drag

            submitImg = function(file, id, target) { 
                var authenticity_token=$("meta:last").attr('content');
                var formFile = new FormData();
                formFile.append("id", id);
                formFile.append("file", file[0]);
                formFile.append("authenticity_token", authenticity_token);
                if (Object.keys(file).length === 0) {
                    flashes();
                    return
                }
                $.ajax({
                    type: "POST",
                    url: collection_path + "/" + id + "/upload_image",
                    data:formFile,
                    async: false,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function (data) {
                        if(data.code){
                            self.find(".lds-ellipsis").remove();
                            self.find(".col-image img").removeClass('hide')
                            console.log("SUCCESS UPLOAD!");
                            changeImg(data.url, target)
                        }else{
                            flashes()
                        }
                    }
                })
            }
            // EOF submitImg

            changeImg = function(url,target){
                var img = target.find(".col-image img");
                img.attr("src", url);
                img.attr("style",'width:48px;height:48px;')
            }

            flashes = function() {
                $('#title_bar').after('<div class="flashes">'+'<div class="flash flash_notice">'+'The uploaded image is corrupt and cannot be processed. Please try a different image.'+'</div>'+'</div>');
                setTimeout(function () {
                    window.location.reload()
                },2000)
            }
            // Start Bind
            self.find('tbody tr')
            .bind('dragenter', dragenter)
            .bind('dragover', dragover)
            .bind('dragleave', dragleave)
            .bind('drop', drop)
        }
        // EOF imageUpload
    
    }) 

    $('.index_table_upload').imageUpload()
})
