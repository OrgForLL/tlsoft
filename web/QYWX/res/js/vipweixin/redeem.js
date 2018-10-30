var currentSite = "index", nodata = false, pageno = 1;

$(document).ready(function () {
    LeeJSUtils.stopOutOfPage("#index", true);
    LeeJSUtils.stopOutOfPage("#store", true);
    LeeJSUtils.stopOutOfPage("#description", true);
    // LeeJSUtils.stopOutOfPage("#gooddetails", true);
    LeeJSUtils.stopOutOfPage(".footer", false);    
    LeeJSUtils.LoadMaskInit();

    loadGoodlist();
    bindEvents();
});

// 初始化
function initLazyload(){

    // 初始化lazyload
    $("img.lazy").lazyload({
        effect: "fadeIn",
        threshold: 10,
        container: $(".img-wrap")
    }); 
}

// 加载商品列表
function loadGoodlist(){
    setTimeout(function () {
        $.ajax({
            type: "POST",
            cache: false,
            timeout: 5 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "/lspx/jf.do?act=GoodsList",
            success: function (msg) {
                var data = JSON.parse(msg);
                if (data.code == 200) {
                    $(".currentpoint").text(data.points);
                    if(data.list.length!=0){
                        $(".goodlist").html(template("goodlist-temp", data));

                    }else{
                        $(".nogood").show();
                    }
                    
                    //这个方法一直提示错误，因此暂时不调用它。 By:xlm 20170711
                    //offmessage();
                    //setInterval(offmessage,10000);

                    $(".loading-modal").fadeOut(200);
                } else if(data.code == 202){

                window.location.href = "http://tm.lilanz.com/lspx/jf.do?act=redirectL&url=http://tm.lilanz.com/qywx/project/vipweixin/redeem.html";

                }else
                    LeeJSUtils.showMessage("error", data.msg);                           
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "您的网络出问题啦[list]..");
            }
        });
    }, 50);
}

// 是否有离线消息
function offmessage(){
    setTimeout(function () {
        $.ajax({
            type: "POST",
            cache: false,
            timeout: 5 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "/lspx/jf.do?act=OffMsg",
            success: function (msg) {
                var jsonStr = JSON.parse(msg);
                if (jsonStr.code == 200) {
                    if(jsonStr.data == 1){
                        $(".tip").show();
                    }else
                        $(".tip").hide();
                } 

                else
                    LeeJSUtils.showMessage("error", jsonStr.msg);                           
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "您的网络出问题啦[message]..");
            }
        });
    }, 50);
}

// 加载商品详情
function loadGoodDetail(id){
    $(".nodetail").hide();
    $.ajax({
        type: "POST",
        cache: false,
        timeout: 5 * 1000,
        contentType: "application/x-www-form-urlencoded; charset=utf-8",
        url: "/lspx/jf.do?act=GoodsDetail&id=" + id,
    }).done(function(msg){
        var data = JSON.parse(msg);
        if(data.code == 200){
            if(data.content != ""){
                $(".img-wrap").html(data.content);
                initLazyload();
            }else{
                $(".nodetail").show();
            }
            
            //console.log(data.content);
        }else
            LeeJSUtils.showMessage("error", data.msg);    

    }).fail(function(XMLHttpRequest, textStatus, errorThrown){
        LeeJSUtils.showMessage("error", "您的网络出问题啦[details]..");
    });
}

function bindEvents(){
    // 数量+1
    $(".goodlist").on("click", ".addBtn", function(){
        var num_add = parseInt($(this).siblings(".number").val())+1;
        if($(".number").val()==""){
            num_add = 1;
        }
        else{
            $(this).siblings(".redBtn").css("color","#888");
            $(this).siblings(".number").val(num_add);
            $(this).parent(".num-wrap").parent(".info-wrap").parent("li").addClass("selborder");
        } 
        count();              
    });
        
    // 数量-1
    $(".goodlist").on("click", ".redBtn", function(){

        var num_dec = parseInt($(this).siblings(".number").val())-1;
        if(num_dec >= 0){
            if(num_dec == 0){
                $(this).parent(".num-wrap").parent(".info-wrap").parent("li").removeClass("selborder");
            }
            $(this).siblings(".number").val(num_dec);
            $(this).css("color","#888");
        }
        count();
    });

    // 操作输入框改变兑换商品的数量
    $(".goodlist").on("change", ".number", function(){
        var liborder = $(this).parent(".num-wrap").parent(".info-wrap").parent("li");
        if($(this).val() > 0){ 
            liborder.addClass("selborder");                  
        }else{
            liborder.removeClass("selborder");         
        }
        count();
    });

    // 图片点击进入详情
    $(".goodlist").on("click", ".goodimg-wrap", function(){
        $(".img-wrap").animate({ scrollTop: 0 }, 0);
        isScroll('#img-wrap');
        $("#gooddetails").removeClass("page-right");
        currentSite = "gooddetails";
        var good_id = $(this). parent("li").attr("data-id");
        loadGoodDetail(good_id);
    });

    // 适用门店按钮
    $(".storeBtn").click(function(){
        $("#store").removeClass("page-right");
        $(".header").show();
        currentSite = "store";
        loadStorelist(1);
    });

    // 积分说明按钮
    $(".explainBtn").click(function(){
        $("#description").removeClass("page-right");
        currentSite = "description";
    });


    // 积分说明页关闭按钮
    $(".closeBtn").click(backFunc);

    // 返回按钮
    $(".backBtn").click(backFunc);



    // 返回页面顶部
    $(".scroll-top").on("click", function () {
        if(currentSite == "index"){
            $("#index").animate({ scrollTop: 0 }, 200);
        }else if(currentSite == "store"){
            $("#store").animate({ scrollTop: 0 }, 200);
        }else{
            $(".img-wrap").animate({ scrollTop: 0 }, 200);
        }               
    });

    // 判断页面是否下拉
    $("#index").scroll(function () {
        isScroll('#index');
    });

    $("#store").scroll(function () {
        isScroll('#store');
    });

    $("#img-wrap").scroll(function () {
        isScroll('#img-wrap');
    });

    // 立即兑换按钮
    $(".exchangeBtn").click(function(){
        var list = [];    //兑换商品数组
        for (var i = 0; i < $(".selborder").length; i++){
            goodid = parseInt($(".selborder").eq(i).attr("data-id"));
            goodnum = parseInt($(".selborder").eq(i).find(".number").val());
            list.push({ id: goodid, number: goodnum});
        }
        if ($(".selborder").length > 0) {
            //先判断积分是否够
            var points_all = $(".redtxt").text();
            var userpoints = $(".currentpoint").text();
            if (parseInt(points_all) > parseInt(userpoints)) {
                LeeJSUtils.showMessage("warn", "对不起，您的积分不足！");                
            } else
                window.location.href = "NewConfirmOrder.html?data=" + encodeURIComponent(JSON.stringify(list));
        }else{
            LeeJSUtils.showMessage("warn", "您尚未选择任何商品");
        }
        
    });

    // 搜索按钮
    $(".iconwrap").click(function(){
        loadStorelist(1);
    });

    // 兑换记录按钮
    $(".orderBtn").click(function(){
        window.location.href = "NewMyOrder.html";
    });

    // 离线消息按钮
    $(".newmessage").click(function(){
        window.location.href = "chat.html";
    });

}

// 页面滚动函数
function isScroll(obj){
    if ($(obj).scrollTop() > 0) {
        $(".scroll-top").fadeIn(100);
    } else
        $(".scroll-top").fadeOut(100);
}

// 计算底部的兑换总积分和商品
function count(){
    var num = 0;
    var point = 0;
    $(".goodlist .selborder").each(function(){
        num += parseInt($(this).find(".number").val());
        point += parseInt($(this).find(".number").val()) * parseInt($(this).find(".itempoint").text());
    });
    $(".redtxt").text(point);
    $(".goodnum").text(num);
}

//滚动加载
var dataLoading = false;
$("#store").scroll(function () {
    if (dataLoading || nodata)
        return;
    checkload();
});

function checkload() {
    dataLoading = true;
    var scrollT = $("#store").scrollTop();
    var contenH = $(".storelist").height();
    var wrapH = $("#store").height();
    if (scrollT + wrapH >= contenH - 10) {
        $(".loading-modal").show();
        setTimeout(loadStorelist, 50);
    } else
        dataLoading = false;
}

// 分页加载数据
function loadStorelist(isReload){
    $(".loading-modal").show();
    var searchword = $("#search").val().trim();
    if (isReload == 1) {
        pageno = 1;
        nodata = false;
        $(".noresult").hide();
        $(".storelist").empty();

    } else
        pageno++;
    setTimeout(function () {
        $.ajax({
            type: "POST",
            cache: false,
            timeout: 5 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "/lspx/jf.do?act=PointsShop&filter=" + encodeURI(searchword) + "&page=" + pageno,
            success: function (msg) {
                var data = JSON.parse(msg);
                if (data.code == 200) {
                    if (data.info.length > 0) {
                        var html = [];
                        for (var i = 0; i < data.info.length; i++) {
                            var row = data.info[i];
                            html += template("storelist-temp", row);                                
                        }//end for

                        if (isReload == 1) {
                            $(".storelist").html(html);
                        } else {
                            $(".storelist").append(html);
                        }
                        
                    } else {
                        $(".noresult").show();
                        nodata = true;
                    }
                    
                    $(".loading-modal").fadeOut(200);
                } else
                    LeeJSUtils.showMessage("error", data.msg);
                    

                setTimeout(function () {
                    dataLoading = false; 
                }, 50);
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                dataLoading = false;
                LeeJSUtils.showMessage("error", "您的网络出问题啦..");
            }
        });
    }, 50);
}


// 返回函数
function backFunc(){

    switch (currentSite) {
        case "index":
            window.history.go(-1);
            break;
        case "store":
            $("#store").addClass("page-right");
            $(".header").hide();
            $(".scroll-top").hide();
            currentSite = "index";                   
            break;
        case "description":
            $("#description").addClass("page-right");
            currentSite = "index";
        case "gooddetails":
            $("#gooddetails").addClass("page-right");
            currentSite = "index";
            isScroll('#index');
            break;
        default:
            break;
    }
}