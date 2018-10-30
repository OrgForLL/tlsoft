(function(window, undefined){
    var history = []; //页面跳转历史
    var isPop = false; //弹层是否弹出
    var type = "faultcode";
    
    /* 库存警告 */
    var inventoryAlert = {
        init: function(){
            inventory.ready();
            this.bindEvent();
            $("#filter").click();
        },
        
        bindEvent: function(){
            $(".num").on('click', 'li', function () {
                if ($(this).hasClass("onchoose")) {
                    $(this).removeClass('onchoose');
                } else {
                    $(this).addClass('onchoose').siblings().removeClass('onchoose');
                }
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
            
            //$("#alert").on('click','.stock',function() {
            //    var goodsNum = $("#goodsNum");
            //    var alert = $("#alert .detail");
            //    alert.unbind('scroll');
            //    goodsNum.find("table").removeAttr('style');
            //    goodsNum.css("animation","pagein 500ms forwards");
            //    history.push({
            //        node: goodsNum,
            //        detail: alert
            //    });
            //});
            
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

            $("#reset").click(function () {
                $(".local li:first-child").addClass('onchoose').siblings().removeClass('onchoose');
                $(".num li").removeClass('onchoose');
            });

            $("#complete").click(function () {
                inventoryAlert.getData();
                $(".layer").hide();
            });

            $("#dm").click(function () {
                if (type == "") {
                    type = "faultcode";
                    $(".type").text('断码');
                    $("#alert .detail tbody").empty();
                    var num = $(".num");
                    num.on('click', 'li', function () {
                        if ($(this).hasClass("onchoose")) {
                            $(this).removeClass('onchoose');
                        } else {
                            $(this).addClass('onchoose').siblings().removeClass('onchoose');
                        }
                    });
                    num.find("li").css("color", "#333");
                    $("#filter").click();
                }
            });

            $("#dxl").click(function () {
                if (type == "faultcode") {
                    type = "";
                    $(".type").text('动销率');
                    $("#alert .detail tbody").empty();
                    var num = $(".num");
                    num.unbind();
                    num.find(".onchoose").removeClass('onchoose');
                    num.find("li").css("color", "#9e9e9f");
                    $("#filter").click();
                }
            });

            $("#search button").click(inventoryAlert.getData);
        },
        
        getData: function() {
            onLoading("加载中...");
            var condition = inventoryAlert.getCondition();

            $.ajax({
                url: './LSZHFX_SaleClerkCore.ashx?ctrl=salecomparison',
                type: 'GET',
                data: condition,
                datatype: 'json'
            }).done(function (data) {
                var data = validation(data); //验证JSON格式是否正确
                if (data.code != '200') {
                    onLoading(data.msg);
                    setTimeout(function () {
                        $("#myLoading").hide();
                    }, 3000);
                    return;
                }

                var info = data.info;
                var html = '';
                var obj = {};
                var count = 0; //尺码类型不为0的数量
                var sizeList = inventoryAlert.getSizeList();
                
                if (!info) {
                    onLoading("未查找到库存数据！");
                    setTimeout(function(){
                        $("#myLoading").hide();
                    },3000);
                    return;
                }

                for (var i = 0; i < info.length; i++) {
                    var typedata = '';
                    var size = '';
                    var record = {};

                    if (obj[info[i].sphh]) {   //判断该类别是否已存在当前库存或在途库存
                        record = obj[info[i].sphh];
                        for (var item in info[i]) {
                            if (item.substring(0, 2) == 'cm' && info[i][item]) { //判断该属性是否为 cm  并且数量不为0
                                size = inventoryAlert.sizeConver(sizeList, item, info[i].tml);
                                if (info[i].lx == 'kc') {  //判断该库存为当前库存或在途库存
                                    var index = $.inArray(item,record.size); //判断是否已存在该尺码数据
                                    if(index >=0) {
                                        record.curinv[index] = info[i][item];
                                    }else {
                                        record.size.push(size);
                                        record.curinv.push(info[i][item]);
                                        record.inway.push('-');
                                    }
                                }else {
                                    var index = $.inArray(item,record.size);
                                    if(index >=0) {
                                        record.inway[index] = info[i][item];
                                    }else {
                                        record.size.push(size);
                                        record.inway.push(info[i][item]);
                                        record.curinv.push('-');
                                    }
                                }
                                record.inv = record.inv + info[i][item];
                                if(count < record.size.length) {
                                    count = record.size.length;
                                }
                            }
                        }
                        obj[info[i].sphh] = record;
                    } else {
                        if (type == "faultcode") {
                            typedata = info[i].isfaultcode ? '是' : '否';
                        } else {
                            typedata = info[i].turnoverRatio;
                        }
                        
                        record = {
                            "sphh": info[i].sphh,
                            "khmc": info[i].khmc,
                            "mc": info[i].mc,
                            "tml": info[i].tml,
                            "typedata": typedata,
                            "inv": 0,
                            "size": [],
                            "curinv": [],
                            "inway": []
                        };
                        
                        for (var item in info[i]) {
                            if (item.substring(0, 2) == 'cm' && info[i][item]) {
                                size = inventoryAlert.sizeConver(sizeList, item, info[i].tml);
                                record.size.push(size);
                                if (info[i].lx == 'kc') {
                                    record.curinv.push(info[i][item]);
                                    record.inway.push('-');
                                }else {
                                    record.inway.push(info[i][item]);
                                    record.curinv.push('-');
                                }
                                record.inv = record.inv + info[i][item];
                                if(count < record.size.length) {
                                    count = record.size.length;
                                }
                            }
                        }
                        obj[info[i].sphh] = record;
                    }
                }

                for(var item in obj) {
                    html = html + template('invAlter',obj[item]);
                }
                var width = 80 + 50 * count;
                
                if(width > 420) {
                    width = 420;
                }
                
                $("#alert .detail tbody").empty().append(html);
                $("#alert .shade th:last").css("width", width);
                $("#alert .detail th:last").css("width", width);
                $("#myLoading").hide();
            }).fail(function(){
                onLoading("数据查询超时！");
                setTimeout(function(){
                    $("#myLoading").hide();
                },3000);
            });
        },
        
        getSizeList: function() {
            var result;
            $.ajax({
                url: './LSZHFX_SaleClerkCore.ashx',
                type: 'GET',
                data: {
                    ctrl: 'cmdm'
                },
                async: false,
                datatype: 'JSON'
            }).done(function(data) {
                var data = validation(data);
                if(data.code == '200') {
                    result = data.info;
                }else {
                    onLoading(data.msg);
                }
            }).fail(function(){
                onLoading("数据查询超时！");
            });
            return result;
        },
        
        sizeConver: function(sizeList, size, tml) {
            return sizeList[size]['tml' + tml];
        },

        getCondition: function () {
            var sphh = $(".alert-search").val() || "";
            var curkhid = $("#company").val() || "";
            var kfbh = $("#kfbh").find(".onchoose").attr("dm") || "";
            var faultCode = $("#isfault").find(".onchoose").attr("isfault");
            return {
                lb: type,
                sphh: sphh,
                curkhid: curkhid,
                kfbh: kfbh,
                isFaultCode: faultCode
            };

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
    
    /* 校验返回的JSON数据格式 */
    var validation = function(data) {
        try{
            var data = JSON.parse(data);
            return data;
        }catch(e){
            onLoading("JSON数据格式错误！");
        }
    }
    
    /* 滚动条事件 */
    var bindscroll = function(){
        var left = this.scrollLeft * -1;
        $(".shade table").css("left",left);
        $(".total table").css("left",left);
    };
    
    /* 防抖节流 */
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
    
    /* 显示加载状态 */
    function onLoading(msg){
        $(".load_text").text(msg || '加载中...');
        $("#myLoading").show();
    }

    window.inventoryAlert = inventoryAlert;
})(window)