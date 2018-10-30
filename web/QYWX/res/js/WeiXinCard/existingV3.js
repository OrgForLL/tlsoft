(function(window, undefined) {
    var storeList = [];
    var cardList = {};
    var tshtml = {
        kh: "",
        md: ""
    };
    var url = "WechatCardCore.aspx";
    
    var existing = {
        init: function() {
            bindEvent();
            FastClick.attach(document.body);
            getCardList();
        }
    };
    
    function bindEvent() {
        $(".navbar").click(function() {
            var on =  $(this).hasClass("navbar-on");
            var index = $(this).index();
            if(!on) {
                $(this).addClass("navbar-on").siblings().removeClass("navbar-on");
                if(index == 1) {
                    $(".coupon").find(".card_examed").hide();
                    $(".coupon").find(".card_exam").show();
                }else if(index == 2) {
                    $(".coupon").find(".card_exam").hide();
                    $(".coupon").find(".card_examed").show();
                }else {
                    $(".coupon").find(".card").show();
                }
            }
        });
        
        $(".coupon").on("click",".card", function() {
            var id = $(this).attr("id");
            getDetail(id);
            if(roleName == "dz") {
                $(".detail").find("#submit").text("返回");
                $(".detail").find(".entry-check").hide();
                $(".detail").find(".entry-check").prev().hide();
            }
            $(".detail").show();
            //$(".detail").removeClass("entry-fadeOut").addClass("entry-fadeIn");
        });
        
        $(".detail").on("click",".goback",function() {
            //$(".detail").removeClass("entry-fadeIn").addClass("entry-fadeOut");
            $(".detail").hide();
        });
        
        $(".detail").on("click","#submit",function() {
            var id = $(this).attr("data-id");
            
            if(cardList[id].shbs > 0 || roleName == "dz" ) {
                $(".goback").click();
            }else {
                alert('手机卡券审核功能正在调整，请在ERP中审核!');
                /* if(storeList.length > 0) {
                    addSuitStord(id);
                }else {
                    cardAudit(id);
                } */
            }
        });
        
        $(".detail").on("click",".entry-link",function() {
            var length = $(".store .entry-check-company").children().length;
            length = length + $(".store .entry-check-store").children().length;
            if(length == 0) {
                getStoreList();
            }
            isSelectStore();
            $(".store").show();
        });
        
        $(".store").on("click",".goback",function() {
            var html = template("optionList",{storeList: storeList});
            $(".detail .entry-check").empty().append(html);
            $(".store").hide();
        });
        
        $(".store .entry-check").on("click",".entry-list",function() {
            var check = $(this).find(".check-icon");
            var khid = $(this).find(".entry-bd").attr("id");
            var khmc = $(this).find("p").text();
            var atype = $(this).find(".entry-bd").attr("data-atype");
            var data = {
                khid: khid,
                khmc: khmc,
                atype: atype
            }
            var isSelect = check.hasClass("icon-xuanze1");
            if(isSelect) {
                check.removeClass("icon-xuanze1").addClass("icon-xuanze");
                storeList.push(data);
            }else {
                check.removeClass("icon-xuanze").addClass("icon-xuanze1");
                delStore(khid);
            }
            console.log(storeList);
        });
        
        $(".detail").on("click",".entry-close",function() {
            var khid = $(this).parent().parent().find("p").attr("data-khid");
            delStore(khid);
            $(this).parent().parent().remove();
        });
        
        $("#ensure").click(function() {
            $(".store .goback").click();
        });
        
        $(".store .select").change(function() {
            var khid = $(this).val();
            var khmc = $(this).find("option:selected").text();
            var kh = {
                khid: khid,
                khmc: khmc,
                atype: "kh"
            };
            
            if(khid) {
                getXJMDList(khid, kh);
            }else {
                $(".store .entry-check-company").empty().append(tshtml.kh);
                $(".store .entry-check-store").empty().append(tshtml.md);
                isSelectStore();
            }
        });
        
        $("#searchSubmit").click(function() {
            var filter = $("#searchInput").val();
            if(filter == "") {
                $(".store").find("label").show();
            }else {
                $(".store .entry-check-store").find("label").hide();
                $(".store .entry-check-store").find(".entry-list p:contains(" + filter + ")").parent().parent().show()
            }
        });
        
        $(".entry-allSelect").click(function() {
            $(".store .entry-check-store").find(".icon-xuanze1").parent().parent().click();
        });
        
        $(".entry-allDelect").click(function() {
            $(".store .entry-check-store").find(".icon-xuanze").parent().parent().click();
        });
        
        $(".entry-check-company").on("click",".entry-list",function() {
            if($(".store .select").val()) {
                var list = $(".entry-check-store").find(".icon-xuanze");
                for(var i = 0; i < list.length; i++) {
                    var khid = $(list[i]).parent().next().attr("id");
                    delStore(khid);
                }
                $(".entry-check-store").find(".icon-xuanze").removeClass("icon-xuanze").addClass("icon-xuanze1");
            }
        });
        
        $(".entry-check-store").on("click",".entry-list",function() {
            if($(".store .select").val()) {
                $(".entry-check-company").find(".icon-xuanze").removeClass("icon-xuanze").addClass("icon-xuanze1");
                var khid = $(".store .select").val();
                delStore(khid);
            }
        });
    };
    
    /* 获取卡券列表 */
    function getCardList() {
        var data = {
            "action": "getCardList",
            "parameter": []
        };
        getData(JSON.stringify(data)).then(function(result) {
            if(result.code == "200") {
                var list = result.data;
                var html = "";
                
                for(var i = 0; i < list.length; i++) {
                    list[i].localtype = list[i].localtype == "LILANZ_DISCOUNT" ? "折扣券" : "抵用券";
                    cardList[list[i].id] = list[i];
                    html = html + template("card",list[i]);
                }

                $(".coupon .page").append(html);
                $(".coupon").find(".navbar:eq(1)").click();
                setTimeout(function() {
                    $("#myLoading").hide();
                },500);
            }else {
                onLoading("获取卡券列表失败",true);
                setTimeout(function() {
                    $("#myLoading").hide();
                },1000);
            }
        }).catch(function(err) {
            onLoading("网络异常");
            setTimeout(function() {
                $("#myLoading").hide();
            },2000);
        });
    }
    
    /* 生成卡券详情 */
    function getDetail(id) {
        var html = "";
        html = html + template("detail",cardList[id]);
        $(".detail").empty().append(html);
    }
    
    /* 卡券审核 */
    function cardAudit(id) {
        var data = {
            "action": "cardAudit",
            "parameter": [
                id.toString()
            ]
        };
        
        getData(JSON.stringify(data),"正在发起审核").then(function(result) {
            if(result.code == "200") {
                cardList[id].shbs = 1;
                $("#" + id).removeClass("card_exam").addClass("card_examed");
                $("#" + id).find(".card_state").text("已审核");
                $("#" + id).hide();
                setTimeout(function() {
                    onLoading("审核完成",true);
                    setTimeout(function() {
                        $(".goback").click();
                        $("#myLoading").hide();
                    },1000);
                },2000);
            }else {
                onLoading(result.message);
                setTimeout(function() {
                    $("#myLoading").hide();
                },2000);
            }
        }).catch(function(err) {
            onLoading("网络异常");
            setTimeout(function() {
                $("#myLoading").hide();
            },2000);
        });
    }
    
     /* 获取门店列表信息 */
    function getStoreList() {
        var data = {"action":"authKH","parameter":[]};
        getData(JSON.stringify(data),"加载列表中").then(function(result) {
            if(result.code == "200") {
                var list = result.data;
                var options = "";
                var khhtml = "";
                var sq = {
                    khid: "",
                    khmc: "已授权门店",
                    atype: "kh"
                };
                
                options = template("selectOption",sq);
                
                for(var i = 0; i < list.length; i++) {
                    if(list[i].atype == "md") {
                        tshtml.md = tshtml.md + template("storeList",list[i]);
                    }else if(list[i].atype == "kh") {
                        options = options + template("selectOption",list[i]);
                        tshtml.kh = tshtml.kh + template("storeList",list[i]);
                        if(khhtml == "") {
                            khhtml = template("storeList",list[i]);
                        }
                    }
                }

                $(".entry-select .select").append(options);
                $(".store .entry-check-company").empty().append(tshtml.kh);
                $(".store .entry-check-store").empty().append(tshtml.md);
                setTimeout(function() {
                    $("#myLoading").hide();
                },500);
            }else {
                onLoading(result.message);
                setTimeout(function() {
                    $("#myLoading").hide();
                },2000);
            }
        }).catch(function(err) {
            onLoading("网络异常");
            setTimeout(function() {
                $("#myLoading").hide();
            },2000);
        });
    };
    
    /* 获取下级门店列表信息 */
    function getXJMDList(khid,kh) {
        var data = {
            "action": "xjmd",
            "parameter": [
                khid.toString()
            ]
        }
        getData(JSON.stringify(data),"加载下级门店列表").then(function(result) {
            if(result.code == "200") {
                var list = result.data;
                var html = "";
                var khhtml = template("storeList",kh);
                
                for(var i = 0; i < list.length; i++) {
                    html = html + template("xjmdList",list[i]);
                }

                $(".store .entry-check-company").empty().append(khhtml);
                $(".store .entry-check-store").empty().append(html);
                isSelectStore();
                setTimeout(function() {
                    $("#myLoading").hide();
                },1000);
            }else {
                onLoading(result.message);
                setTimeout(function() {
                    $("#myLoading").hide();
                },2000);
            }
        }).catch(function(err) {
            onLoading("网络异常");
            setTimeout(function() {
                $("#myLoading").hide();
            },2000);
        });
    }
    
    /* 添加适用门店 */
    function addSuitStord(id) {
        var store = [];
        
        for(var i = 0; i < storeList.length; i++) {
            var item = {
                "khid": storeList[i].khid,
                "type": storeList[i].atype
            };
            
            store.push(item);
        }

        var data = {
            "action": "AddSuitStord",
            "parameter": [
                id,
                JSON.stringify(store)
            ]
        };

        getData(JSON.stringify(data),"正在发起审核").then(function(result) {
            if(result.code == "200") {
                cardAudit(id);
            }else {
                onLoading("审核失败");
                setTimeout(function() {
                    $("#myLoading").hide();
                },2000);
            }
        }).catch(function(err) {
            onLoading("网络异常");
            setTimeout(function() {
                $("#myLoading").hide();
            },2000);
        });
    };
    
    /* ajax */
    function getData(data,msg) {
        var message = msg? msg : "加载中...";
        onLoading(message);
        return new Promise(function(resolve, reject) {
            $.ajax({
                url: url,
                type: 'POST',
                data: data,
                dataType: 'JSON'
            }).then(function(data) {
                resolve(data);
            }).fail(function(err) {
                reject(err);
            });
        });
    };
    
    /* 删除列表中的门店 */
    function delStore(khid) {
        for(var i = 0; i < storeList.length; i++) {
            if(storeList[i].khid == khid) {
                storeList.splice(i,1);
                break;
            }
        }
    };
    
    /* 已选中门店 */
    function isSelectStore() {
        $(".store .entry-check").find(".icon-xuanze").removeClass("icon-xuanze").addClass("icon-xuanze1");
        for(var i = 0; i < storeList.length; i++) {
            $(".store .entry-check").find("#" + storeList[i].khid + "[data-atype=" + storeList[i].atype + "]").parent().find(".check-icon").removeClass("icon-xuanze1").addClass("icon-xuanze");
        }
    }
    
    /* 获取URL GET参数 */
    function GetQueryParams(name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
        var r = window.location.search.substr(1).match(reg);
        if (r != null)
            return unescape(r[2])
        else
            return "";
    };
    
    /* 显示加载状态 */
    function onLoading(msg,trun){
        $(".load_text").text(msg || '加载中...');
        if(trun) {
            $(".load_img").hide();
        }else {
            $(".load_img").show();
        }
        $("#myLoading").show();
    };
    
    window.existing = existing;
})(window)