(function(window, undefined){
    var history = [];
    var isPop = false;
    
    /* 库存警告 */
    var inventoryAlert = {
        init: function(){
            inventory.ready();
            this.bindEvent();
        },
        
        bindEvent: function(){
            $(".num").on('click','li',function(){
                $(this).addClass('onchoose').siblings().removeClass('onchoose');
            });

            $(".local").on('click','li',function(){
                $(this).addClass('onchoose').siblings().removeClass('onchoose');
            });
            
            $("#methods").click(function(){
                $("#type").fadeToggle();
            });

            $("#type").on("click","li",function(){
                $("#type").fadeOut();
            })
            
            $("#alert").on('click','.stock',function() {
                var goodsNum = $("#goodsNum");
                var alert = $("#alert .detail");
                alert.unbind('scroll');
                goodsNum.find("table").removeAttr('style');
                goodsNum.css("animation","pagein 500ms forwards");
                history.push({
                    node: goodsNum,
                    detail: alert
                });
            });
            
            $("#category .detail").on('click','a',function(){
                var goodsNo = $("#goodsNo");
                var detail = $("#category .detail");
                goodsNo.css("animation","pagein 500ms forwards");
                detail.unbind('scroll');
                history.push({
                    node: goodsNo,
                    detail: detail
                });
            });
        },
        
        getData: function() {
            $.ajax({
                url: 'http://tm.lilanz.com/qywx/project/StoreSaler/LSZHFX_SaleClerkCore.ashx?ctrl=salecomparison',
                type: 'POST',
                datatype: 'json'
            }).done(function(data){
                var data = validation(data);
                var html = '';
                var obj = {};
                
                if(!data) {
                    console.log('未查找到库存数据');
                    return;
                }

                for(var i = 0; i < data.length; i++) {
                    var faultcode = '';
                    var record = {};

                    if(obj[data[i].sphh]) {
                        record = obj[data[i].sphh];
                        for(var item in data[i]) {
                            if(item.substring(0,2) == 'cm') {
                                record.size.push(item);
                                if(data[i].lx == 'kc') {
                                    record.curinv.push(data[0][item]);
                                }else {
                                    record.inway.push(data[0][item]);
                                }
                                inv = inv + data[0][item];
                            }
                        }
                        obj[data[i].sphh] = record;
                    }else {
                        if(data[i].isfaultcode){
                            faultcode = '否';
                        }else {
                            faultcode = '是';
                        }
                        
                        record = {
                            "sphh": data[i].sphh,
                            "khmc": data[i].khmc,
                            "mc": data[i].mc,
                            "tml": data[i].tml,
                            "isfaultcode": faultcode,
                            "inv": 0,
                            "size": [],
                            "curinv": [],
                            "inway": []
                        };
                        
                        for(var item in data[i]) {
                            if(item.substring(0,2) == 'cm') {
                                record.size.push(item);
                                if(data[i].lx == 'kc') {
                                    record.curinv.push(data[i][item]);
                                }else {
                                    record.inway.push(data[i][item]);
                                }
                                record.inv = record.inv + data[i][item];
                            }
                        }
                        obj[data[i].sphh] = record;
                    }
                }

                for(var item in obj) {
                    html = html + template('invAlter',obj);
                }
                
                $("#alert .detail tbody").append(html);
            }).fail(function(){
                console.log("数据查询超时！")
            });
        }
    };
    
    /* 客户提货销售对照表 */
    var salesComparison = {
        init: function(){
            inventory.ready();
            this.bindEvent();
            $("#date").click();
        },
        
        bindEvent: function(){
            $(".num").on('click','li',function(){
                $(this).addClass('onchoose').siblings().removeClass('onchoose');
            });
            
            $("#date").click(function(){
                var range = $(".range");
                var local = $(".local");
                range.find("input").removeAttr("readonly");
                range.find("input").css("color","#000");
                local.unbind();
                local.find(".onchoose").removeClass('onchoose');
                local.find("li").css("color","#9e9e9f");
            });
            
            $("#developNo").click(function(){
                var range = $(".range");
                var local = $(".local");
                range.find("input").attr("readonly","readonly");
                range.find("input").css("color","#9e9e9f");
                local.on('click','li',function(){
                    $(this).addClass('onchoose').siblings().removeClass('onchoose');
                });
                local.find("li:first-child").addClass('onchoose');
                local.find("li").css("color","#000");
            });
            
            $("#users .detail").on('click','a',function(){
                var category = $("#category");
                var detail = $("#users .detail");
                category.css("animation","pagein 500ms forwards");
                detail.unbind('scroll');
                history.push({
                    node: category,
                    detail: detail
                });
            });

            $("#category .detail").on('click','a',function(){
                var goodsNo = $("#goodsNo");
                var detail = $("#category .detail");
                goodsNo.css("animation","pagein 500ms forwards");
                detail.unbind('scroll');
                history.push({
                    node: goodsNo,
                    detail: detail
                });
            });
            
            $(".classified").on('click','li', function(){
                $(".classified").find("li").removeClass("onchoose");
                $(this).addClass('onchoose');
            });
            
             $("#reset").click(function(){
                        
            });
        }
    };
    
    var inventory = {
        ready: function(){
            FastClick.attach(window.document.body);
            this.bindEvent();
        },
        
        bindEvent: function(){
            $(".layer").click(function(){
                $(".criteria").css("animation","fideout 400ms");
                isPop = true;
            });

            $(".criteria").click(function(e) {
                e.stopPropagation();
            });

            $("#filter").click(function(){
                $(".layer").show();
                $(".criteria").css("animation","fidein 400ms");
                isPop = false;
            });

            $(".criteria")[0].addEventListener("webkitAnimationEnd", function(){
                $(".criteria").css("animation","none");
                if(isPop ) {
                    $(".layer").hide();
                }
            });

            $("#goback").click(function(){
                if(history.length > 0) {
                    var dom = history.pop();
                    dom.node.css("animation","pageout 500ms forwards");
                    dom.detail.scroll(throttle(bindscroll, 20, 10));
                }
            });

            $(".detail").scroll(throttle(bindscroll, 20, 10));
        }
    };
    
    var validation = function(data) {
        try{
            var data = JSON.parse(data);
            return data;
        }catch(e){
            console.log(e);
        }
    }
    
    var bindscroll = function(){
        var left = this.scrollLeft * -1;
        $(".shade table").css("left",left);
        $(".total table").css("left",left);
    };
    
    var throttle = function(func, wait, mustRun){
        var timeout,
            startTime = new Date();

        return function() {
            var context = this,
                args = arguments,
                curTime = new Date();

            clearTimeout(timeout);
            if(curTime - startTime >= mustRun) {
                func.apply(context,args);
                startTime = curTime;
            }else {
                timeout = setTimeout(func, wait);
            }
        };
    }
    
    window.salesComparison = salesComparison;
    window.inventoryAlert = inventoryAlert;
})(window)