var tagShow = false;
var tagsArr = new Array();
var currentUser = "0";
var tagIsLoad = false, pageLoaded = false, isFilter = false;
var lastxh = "0", interval;
var radarChart, lbChart, xlChart, ysChart;
var CurrentSite = "vip-list";//用于标示当前用户所处的页面位置

$(function () {    
    GetVIPList();
    $("#loadmore_btn").click(function () {
        if ($("#loadmore_btn").text() == "无更多数据...") return;
        GetVIPList();        
    });

    if (RoleID == "1") {
        $(".filterbtn[filter]").hide();
    }
});

//加载用户标签模板数据
function LoadTagTemplate() {
    showLoader("loading", "正在加载标签模板...");
    $.ajax({
        url: "../../WebBLL/VIPListCore.aspx?ctrl=GetTagTemplate",
        type: "POST",
        dataType: "text",
        //cache: false,//不使用缓存
        timeout: 10000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {            
            showLoader("error","您的网络好像出了点问题,请稍后重试...");
        },
        success: function (result) {
            if (result.indexOf("Error") > -1) {                
                showLoader("error", "System Error:" + result);
            } else {
                var obj = JSON.parse(result);
                var data = {
                    list: obj.rows
                };
                var render = _.template($("#tagtemplate").html());
                var html = render(data);
                $("#subtags").before(html);

                $(".tagitemul li").click(function (e) {
                    var obj = $(e.target);                    
                    if (obj.hasClass("tagselected")) {
                        obj.removeClass("tagselected");
                    }
                    else {                        
                        obj.parent().children().removeClass("tagselected");
                        obj.addClass("tagselected");
                    }                    
                });
                tagIsLoad = true;
                showLoader("successed", "获取成功!");
            }
        }
    });
}

//读取VIP用户列表数据        
function GetVIPList() {
    var vipliModule = $("#userlist").html();
    showLoader("loading", "正在拉取数据...");
    $.ajax({
        url: "VIPListCore.aspx?ctrl=GetVipList",
        type: "POST",
        dataType: "text",
        data: { mdid: mdid, lastxh: lastxh, salerid: AppSystemKey, role:RoleID },
        timeout: 10000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {            
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
        },
        success: function (result) {
            if (result.indexOf("Error:") > -1) {                
                showLoader("error", result);
            } else if (result=="") {
                showLoader("successed", "获取成功！");
                $("#loadmore_btn").text("无更多数据...");                
            } else {
                var obj = JSON.parse(result.replace("Successed",""));
                var data = {
                    list: obj.rows
                };
                if (lastxh == "0" && obj.rows.length > 0)
                    $("#vipall").text(obj.rows[0].sl);
                var render = _.template($("#userlist").html());
                var html = render(data);
                $(".vipul").append(html);
                lastxh = $(".vipul li:last-child").attr("vipxh");
                $("#vipcurr").parent().hide();
                if (!tagIsLoad)
                    LoadTagTemplate();
                else
                    showLoader("successed", "获取成功！");
            }
        }
    });
}

//加载最近消费记录
function LatestConsume() {
    if ($(".consumebtn i").hasClass("fa-pulse"))
        return;
    else
        $(".consumebtn").html("<i class='fa fa-rotate-right fa-pulse'></i>");        
    $.ajax({
        url: "../../WebBLL/VIPListCore.aspx?ctrl=LatestConsume",
        type: "POST",
        dataType: "text",
        data: { ukh: $("#vipdiv li[vipid="+currentUser+"]").attr("vipkh")},
        //cache: false,//不使用缓存
        timeout: 10000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {            
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
            $(".consumebtn").html("<i class='fa fa-rotate-right'></i>");
        },
        success: function (result) {            
            if (result.indexOf("Error") > -1) {                
                showLoader("error", "System Error:" + result);
                $(".consumebtn").html("<i class='fa fa-rotate-right'></i>");
            } else if (result=="") {                
                $("#noconsume").show();
                $(".consumebtn").html("<i class='fa fa-rotate-right'></i>");
            } else {                
                var obj = JSON.parse(result);
                var data = {
                    list: obj.rows
                };

                var render = _.template($("#latestcontemp").html());
                var html = render(data);
                $("#latestconsumeul").children().remove();
                $("#latestconsumeul").append(html);
                showLoader("successed", "加载成功!");
                $(".consumebtn").html("<i class='fa fa-rotate-right'></i>");
            }
        }
    });
}

//加载单据详情
function getConsumeDetail(djobj) {
    showLoader("loading", "正在查询...");
    $.ajax({
        url: "../../WebBLL/VIPListCore.aspx?ctrl=ConsumeDetail",
        type: "POST",
        dataType: "text",
        data: { djid:$(djobj).attr("djid") },        
        timeout: 10000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
        },
        success: function (result) {
            if (result.indexOf("Error") > -1) {
                showLoader("error", "System Error:" + result);
            } else if (result == "") {
                showLoader("warn", "此单据无记录!");
            } else {
                var obj = JSON.parse(result);
                var data = {
                    list: obj.rows
                };

                var render = _.template($("#cdetailtemp").html());
                var html = render(data);
                $("#cdetaillist").children().remove();
                $("#cdetaillist").append(html);
                $("#cd_djh").text($(djobj).attr("djh"));
                $("#cd_djsj").text($(djobj).find(".djsj").text());
                showLoader("successed", "加载成功!");
                $(".tags").hide();                
                $("#consumedetail").removeClass("page-right");
                CurrentSite = "consume-detail";
            }
        }
    });
}

//打标签提交
$("#subtags").click(function () {
    var obj = $(".tagselected");
    var data = new Object();
    var remark = encodeURI($("#tagdefine").val());
    if (obj.length == 0 && remark == "") {
        data = { uid: currentUser, data: "", remark: "", type: "delete" };
    } else {
        if (obj.length != 0) {
            tagsArr = [];
            for (var i = 0; i < obj.length; i++) {
                tagsArr.push(obj.eq(i).attr("tid"));
            }//end for
            data = { uid: currentUser, data: tagsArr, remark: remark, type: "update" };
        }else
            data = { uid: currentUser, data: "", remark: remark, type: "update" };
    }

    showLoader("loading", "正在提交数据...");    
    $.ajax({
        url: "../../WebBLL/VIPListCore.aspx?ctrl=UpUserTags",
        type: "POST",
        dataType: "text",
        data: { tags: JSON.stringify(data) },
        timeout: 10000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {            
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
        },
        success: function (result) {
            if (result.indexOf("Error:") > -1) {                
                showLoader("error", "System Error:" + result);
                return;
            } else {
                showLoader("successed", "提交成功!");
                $("#tags-page").addClass("page-top");
                $(".tags").text("打标签");
                tagShow = false;
                putTags();
            }
        }
    });
});

//读取用户详细信息
function userinfo(uobj) {
    var usertype = $(uobj).attr("vtype");    
    if (usertype == "WX") {
        var render = _.template($("#guideTemp").html());        
        $("#NewGuide").html(render());
        $("#NewGuide .userinfo .headimg").css("background-image", $(".userimg", uobj).css("background-image"));
        $("#NewGuide .userinfo .username").text($("h3", uobj).text());
        $("#NewGuide").attr("bid", $(uobj).attr("bid"));
        //绑定事件
        $("#NewGuide .confirm-btn").click(function (e) {
            var str = $(e.target).attr("val");
            if (str == "bind") {
                var render = _.template($("#bindTemp").html());
                $("#bindWX").html(render());                
                $("#NewGuide").addClass("page-left");
                $("#bindWX").removeClass("page-right");
                CurrentSite = "bind-vip";
            } else if (str == "register") {
                var render = _.template($("#regTemp").html());
                $("#registerVIP").html(render());
                $("#NewGuide").addClass("page-left");
                $("#registerVIP").removeClass("page-right");
                CurrentSite = "register-vip";
            }
        });

        $("#NewGuide").removeClass("page-right");
        CurrentSite = "new-guide";
        $(".sorts").hide();
    } else if (usertype == "VIP-WX" || usertype == "VIP") {
        showLoader("loading", "正在读取用户信息...");
        currentUser = $(uobj).attr("vipid");
        $.ajax({
            url: "../../WebBLL/VIPListCore.aspx?ctrl=GetUserInfo",
            type: "POST",
            dataType: "text",
            data: { uid: $(uobj).attr("vipid"), ukh: $(uobj).attr("vipkh") },
            //cache: false,//不使用缓存
            timeout: 10000,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                showLoader("error", "您的网络好像出了点问题,请稍后重试...");
            },
            success: function (result) {
                if (result.indexOf("Error") > -1) {
                    showLoader("error", result);
                } else {
                    var obj = JSON.parse(result);
                    var data = {
                        data: obj
                    };
                    var render = _.template($("#userview").html());
                    $("#info-page").html(render(data));
                    $(".mask").hide();
                    $("#to-top").hide();
                    $(".filterbtn[filter]").hide();
                    $("#page-main").addClass("page-left");
                    $("#info-page").removeClass("page-right");
                    $(".backbtn").fadeIn(200);
                    $(".sorts").fadeOut(200);
                    $(".tags").fadeIn(200);
                    $(".userinfo .headimg").css("background-image", $(uobj).children().eq(0).css("background-image"));
                    pageLoaded = false;
                    CurrentSite = "vip-detail";
                    $(".morebtn").click(function () {
                        if ($(".moreinfo").css("height") == "0px") {
                            $(".moreinfo").css("height", "260px");
                            $(".morebtn i").addClass("iconup");
                        } else {
                            $(".moreinfo").css("height", "0px");
                            $(".morebtn i").removeClass("iconup");
                        }
                    });
                    GetUserTags();
                }
            }
        });
    }
}

//排序、筛选功能
function FilterData(fs, bs) {
    var RID = bs == "0" ? RoleID : bs;
    var vipliModule = $("#userlist").html();
    showLoader("loading", "正在进行查询...");
    $.ajax({
        url: "../../WebBLL/VIPListCore.aspx?ctrl=FilterData",
        type: "POST",
        dataType: "text",
        data: { mdid: mdid, type: fs, salerid: AppSystemKey, role: RID },        
        timeout: 15000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {            
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
        },
        success: function (result) {
            if (result=="" || result.indexOf("Error:")>-1) {
                showLoader("warn", "操作失败,请稍后重试!" + result);
            } else {
                var obj = JSON.parse(result);
                var data = {
                    list: obj.rows
                };
                var render = _.template($("#userlist").html());
                var html = render(data);
                $("#vipdiv").children().remove();
                if (fs == "lessm1" || fs == "lessm3" || fs == "lessy1" || fs == "morey1" || fs=="dzfilter") {
                    $("#vipcurr").text(obj.rows.length);
                    $("#vipcurr").parent().show();
                } else {
                    $("#vipcurr").text("--");
                    $("#vipcurr").parent().hide();
                }
                $("#vipdiv").append(html);                
                $(".mysort").attr("isshow", "0");
                $(".mysort").addClass("page-top");
                $("#mask2").hide();
                showLoader("successed", "查询成功!");
                isFilter = true;
                loadMoreIsShow();
            }
        }
    });
}

function loadMoreIsShow() {
    if(isFilter)
        $(".lmdiv").hide();
    else
        $(".lmdiv").show();
}

//读取用户标签数据
function GetUserTags() {    
    //showLoader("loading", "正在读取用户标签数据...");
    if (pageLoaded) return;
    $.ajax({
        url: "../../WebBLL/VIPListCore.aspx?ctrl=GetUserTags",
        type: "POST",
        dataType: "text",
        data: { uid: currentUser },
        timeout: 10000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {            
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
        },
        success: function (result) {
            if (result.indexOf("Error") > -1) {                
                showLoader("error", "System Error:" + result);
            } else {
                tagsArr = result.split('||')[0].split(',');
                $(".tagselected").removeClass("tagselected");
                for (var i = 0; i < tagsArr.length-1; i++) {
                    $(".tagitemul li[tid='" + tagsArr[i] + "']").addClass("tagselected");
                }
                var remark = result.split('||')[1];
                $("#tagdefine").val(decodeURI(remark));
                putTags();
                UserConsume();                
            }
        }
    });
}

function BarCharts(type) {
    if (pageLoaded) return;
    showLoadingText("#l2title", " 正在统计，请稍候");
    $.ajax({
        url: "../../WebBLL/VIPListCore.aspx?ctrl=GetChartDatas",
        type: "POST",
        dataType: "text",
        data: { uid: currentUser,type:type,ukh:$("#vipdiv li[vipid="+currentUser+"]").attr("vipkh") },
        //cache: false,//不使用缓存
        timeout: 10000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            //alert("AJAX执行失败！");
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
        },
        success: function (result) {
            if (result.indexOf("Error") > -1) {
                //alert(result);
                showLoader("error", "System Error:" + result);
            } else if (result.indexOf("Warn:") > -1) {                
                showLoader("successed", result.replace("Warn:", ""));
                hideLoading();
            }else if(result=="") {
                //alert("none");
                showLoader("error", "System Error:" + result);
            }else {
                var obj = JSON.parse(result);
                if (obj.rows.length > 0) {
                    var labelArr = new Array();
                    var dataArr = new Array();
                    for (var i = 0; i < obj.rows.length; i++) {
                        var row = obj.rows[i];
                        labelArr.push(row.label);
                        dataArr.push(row.sl);
                    }//end for
                    var data;
                    $("#" + type).before("<div style='margin:10px auto 0 auto;width:300px;'><canvas id=chart-" + type + "></canvas></div>");
                    switch (type) {
                        case "lb":
                            if (lbChart != undefined)
                                lbChart.destroy();
                            data = {
                                labels: labelArr,
                                datasets: [
                                    {
                                        fillColor: "#e1987b",
                                        strokeColor: "rgba(220,220,220,1)",
                                        data: dataArr
                                    }
                                ]
                            }//end data
                            lbChart = new Chart(document.getElementById("chart-" + type).getContext("2d")).Bar(data);
                            BarCharts("ys");
                            return;
                            break;
                        case "ys":
                            if (ysChart != undefined)
                                ysChart.destroy();
                            data = {
                                labels: labelArr,
                                datasets: [
                                    {
                                        fillColor: "#ee5257",
                                        strokeColor: "rgba(220,220,220,1)",
                                        data: dataArr
                                    }
                                ]
                            }//end data
                            ysChart = new Chart(document.getElementById("chart-" + type).getContext("2d")).Bar(data);
                            hideLoading();
                            pageLoaded = true;
                            //BarCharts("xl");                            
                            break;
                        case "xl":
                            if (xlChart != undefined)
                                xlChart.destroy();
                            data = {
                                labels: labelArr,
                                datasets: [
                                    {
                                        fillColor: "#785f62",
                                        strokeColor: "rgba(220,220,220,1)",
                                        data: dataArr
                                    }
                                ]
                            }//end data
                            xlChart = new Chart(document.getElementById("chart-" + type).getContext("2d")).Bar(data);                           
                            return;
                            break;
                    }                    
                }
            }
        }
    });
}

function drawCharts(data, opi) {
    if (pageLoaded) return;
    if (radarChart != undefined)
        radarChart.destroy();
    radarChart = new Chart(document.getElementById("radar-chart").getContext("2d")).Radar(data, opi);    
    BarCharts("lb");            
}

function UserConsume() {
    //showLoader("loading", "正在计算消费行为...");
    if (pageLoaded) return;
    showLoadingText("#contitle"," 正在统计，请稍候");
    $.ajax({
        url: "../../WebBLL/VIPListCore.aspx?ctrl=GetVIPBehavior",
        type: "POST",
        dataType: "text",
        data: { uid: currentUser, ukh:$("#vipdiv li[vipid="+currentUser+"]").attr("vipkh") },        
        timeout: 10000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {            
            showLoader("error", "您的网络好像出了点问题,请重试...");
            hideLoading();
        },
        success: function (result) {
            if (result.indexOf("Error") > -1) {
                //alert(result);
                showLoader("error", "System Error:" + result);
            } else if (result.indexOf("Warn:") > -1) {
                showLoader("successed", result.replace("Warn:", ""));
                $(".chart-title").hide();
                hideLoading();
            }else {
                var obj = result.split('|');
                var data = {
                    gmcs: obj[0],
                    pjdj: parseFloat(obj[1]).toFixed(2),
                    pjdl: parseFloat(obj[2]).toFixed(2),
                    pjzks: parseFloat(obj[3]).toFixed(1),
                    pl: obj[4],
                    fg: obj[5],
                    ys: obj[6],
                    xfje: obj[7],
                    lastje: obj[8],
                    lastsj: obj[9],
                    dists:obj[10]+'天'
                };
                var render = _.template($("#userconsume").html());
                $("#info-page .usernav .title").eq(0).after(render(data));

                //准备雷达图数据
                //消费金额：10000-50000 平均单价：300-1000 客单量：1-5 平均折扣：1-10
                var kdj = parseInt(obj[7]) / parseInt(obj[0]);
                if (kdj <= 599) kdj = 5;
                else if (kdj >= 5999) kdj = 95
                else {
                    kdj = parseInt((kdj - 599) * 9 / 540) + 5;
                }

                var pjdj = parseInt(obj[1]);
                if (pjdj <= 199) pjdj = 5;
                else if (pjdj >= 1999) pjdj = 95;
                else
                    pjdj = parseInt((pjdj - 199) * 9 / 180) + 5;

                var kdl = parseInt(obj[2]);
                if (kdl <= 1) kdl = 5;
                else if (kdl >= 5) kdl = 95;
                else
                    kdl = parseInt((kdl - 1) * 90 / 4) + 5;

                var pjzk = parseFloat(obj[3]).toFixed(1);
                if (pjzk <= 5.9) pjzk = 5;
                else if (pjzk >= 10) pjzk = 95;
                else
                    pjzk = parseInt((pjzk - 5.9) * 90 / 4) + 5;

                var dists = parseInt(obj[10]);
                if (dists <= 30) dists = 95;
                else if (dists >= 120) dists = 5
                else {
                    dists = parseInt(95 - (dists - 30));
                }

                var radardata = {
                    labels: ["客单价 " + parseInt(obj[7]) / parseInt(obj[0]) + "元", "平均单价 " + parseInt(obj[1]) + "元", "客单量 " + parseInt(obj[2]) + "件", "平均折扣 " + parseFloat(obj[3]).toFixed(1) + "折", "最后消费 " + obj[10] + "天"],
                    datasets: [
                        {
                            fillColor: "rgba(217,83,79,0.6)",
                            strokeColor: "rgba(220,220,220,1)",
                            pointColor: "rgba(153,153,153,1)",
                            pointStrokeColor: "#fff",
                            data: [kdj,pjdj,kdl,pjzk,dists]
                       }
                    ]
                };
                //showLoader("successed", "查询成功!");   
                var chartOpi = new Object();
                chartOpi.pointDot = false;
                drawCharts(radardata,chartOpi);
            }
        }
    });
}

//提示层
function showLoader(type, txt) {
    switch (type) {
        case "loading":
            $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
            $("#loadtext").text(txt);
            $(".mask").show();
            break;
        case "successed":
            $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
            $("#loadtext").text(txt);
            $(".mask").show();
            setTimeout(function () {
                $(".mask").fadeOut(200);
            }, 1000);
            break;
        case "error":
            $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
            $("#loadtext").text(txt);
            $(".mask").show();
            setTimeout(function () {
                $(".mask").fadeOut(400);
            }, 1500);
            break;
        case "warn":
            $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
            $("#loadtext").text(txt);
            $(".mask").show();
            setTimeout(function () {
                $(".mask").fadeOut(400);
            }, 800);
            break;
    }
}

var showMesssage = {
    "loading": function (txt) {
        $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
        $("#loadtext").text(txt);
        $(".mask").show();        
    },
    "successed": function (txt) {
        $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
        $("#loadtext").text(txt);
        $(".mask").show();
        setTimeout(function (txt) {
            $(".mask").fadeOut(200);
        }, 500);
    },
    "error": function (txt) {
        $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
        $("#loadtext").text(txt);
        $(".mask").show();
        setTimeout(function (txt) {
            $(".mask").fadeOut(400);
        }, 2000);
    },
    "warn": function (txt) {
        $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
        $("#loadtext").text(txt);
        $(".mask").show();
        setTimeout(function (txt) {
            $(".mask").fadeOut(400);
        }, 800);
    }
};

function backFunc() {
    switch (CurrentSite) {
        case "consume-detail":
            $("#consumedetail").addClass("page-right");
            $(".tags").show();
            CurrentSite = "vip-detail";
            break;
        case "vip-detail":
            pageLoaded = true;
            $("#info-page").addClass("page-right");
            $("#page-main").removeClass("page-left");
            $(".tags").hide();
            $(".tags").text("打标签");
            tagShow = false;
            $(".sorts").show();
            $("#to-top").show();
            $(".filterbtn[filter]").show();
            CurrentSite = "vip-list";
            break;
        case "new-guide":
            $("#NewGuide").addClass("page-right");
            $("#NewGuide").attr("bid", "");
            $(".sorts").show();
            CurrentSite = "vip-list";
            break;
        case "bind-vip":
            $("#bindWX").addClass("page-right");
            $("#NewGuide").removeClass("page-left");
            CurrentSite = "new-guide";
            break;
        case "register-vip":
            $("#registerVIP").addClass("page-right");
            $("#NewGuide").removeClass("page-left");
            CurrentSite = "new-guide";
            break;
        case "vip-list":
            window.history.go(-1);
            break;
    }

    $("#tags-page").addClass("page-top");
}

$(".backbtn").click(backFunc);

function switchTags() {
    if (tagShow) {
        $("#tags-page").addClass("page-top");
        $(".tags").text("打标签");
        tagShow = false;
    } else {
        $("#tags-page").removeClass("page-top");
        $(".tags").text("关闭");
        tagShow = true;
    }
}

function switchSF(flat, obj) {
    $("#filter-btn a").removeClass("fchecked");
    if (flat == "sort") {
        $(".filter-item").hide();
        $(".sort-item").show();        
        $(obj).addClass("fchecked");
    } else if (flat == "filter") {
        $(".sort-item").hide();
        $(".filter-item").show();
        $(obj).addClass("fchecked");
    }
}

function switchMenu(order) {
    switch (order) {
        case 0:
            window.location.href = "chatlist.aspx";            
            break;
        case 1:
            window.location.href = "#";
            break;
        case 3:
            window.location.href = "usercenter.aspx";
            break;
        default:
            showLoader("warn", "即将推出,敬请期待!");
            break;
    }
}

$.expr[":"].Contains = function (a, i, m) {
    return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
};

function searchFunc() {
    var obj = $("#vipdiv li h3");
    if (obj.length > 0) {                
        var filter = $("#searchtxt").val();
        if (filter) {            
            $matches = $("#vipdiv li").find("h3:Contains(" + filter + ")").parent();                        
            $("li", $("#vipdiv")).not($matches).hide();
            $matches.show();
            $("#vipcurr").text($matches.length);
            $("#vipcurr").parent().show();
            $(".lmdiv").hide();
        } else {
            $("#vipdiv").find("li").show();            
            $("#vipcurr").text("--");
            $("#vipcurr").parent().hide();
            if (isFilter)
                loadMoreIsShow();
            else
                $(".lmdiv").show();
        }        
    }
}

//打开排序
function mysort() {
    if ($(".mysort").attr("isshow") == "0") {
        $(".mysort").attr("isshow", "1");
        $(".mysort").removeClass("page-top");
        $("#mask2").show();
    }
    else {
        $(".mysort").attr("isshow", "0");
        $(".mysort").addClass("page-top");
        $("#mask2").hide();
    }
}

$.fn.fadeInWithDelay = function () {
    var delay = 0;
    return this.each(function () {
        $(this).delay(delay).animate({ opacity: 1 }, 200);
        delay += 100;
    });
};

//回到顶部 
$("#to-top").click(function () {
    $("#page-main").animate({ scrollTop: 0 }, 400);
});

$("#mask2").click(function () {
    $(".mysort").attr("isshow", "0");
    $(".mysort").addClass("page-top");
    $("#mask2").hide();
});

//去除数组中重复的元素
function unique(arr) {
    var result = [], hash = {};
    for (var i = 0, elem; (elem = arr[i]) != null; i++) {
        if (!hash[elem]) {
            result.push(elem);
            hash[elem] = true;
        }
    }
    return result;    
}

//贴标签
function putTags() {    
    $(".usertags").children().remove();
    var tagObj = $(".tagselected");    
    if (tagObj.length > 0) {
        var len = tagObj.length > 10 ? 10 : tagObj.length;
        for (var i = 0; i < len; i++) {
            if (i % 2 == 0)
                $("#tag-left").append("<p>" + tagObj.eq(i).text() + "</p>");
            else
                $("#tag-right").append("<p>" + tagObj.eq(i).text() + "</p>");
        }
        if (tagObj.length > 10)
            $("#tag-right").append("<p>…</p>");
    }

    var obj = $(".usertags p");
    obj.fadeInWithDelay();
}


function showLoadingText(id, str) {        
    if (interval != null && interval != undefined) {
        clearInterval(interval);        
        $("#loadingtext").remove();
    }
    //var loadtextHtml = "<div id='loadingtext' style='font-weight:bold;font-size:1.1em;text-align:center;color:#c9302c;margin-top:5px;'>" + str + "</div>";
    var loadtextHtml = "<span id='loadingtext'>" + str + "</span>";
    $(id).append(loadtextHtml);
    interval = window.setInterval(function () {
        var loadobj = $("#loadingtext");
        var text = loadobj.text();
        if (text.length < str.length + 8) {
            loadobj.text(text + ' . ');
        } else {
            loadobj.text(str);
        }
    }, 400);
}

function hideLoading() {
    if (interval != null && interval != undefined) {
        clearInterval(interval);
        $("#loadingtext").fadeOut(800);
    }
}

//性别选择函数
function sexSelect(obj) {
    $(".sex-group i").attr("class", "fa fa-square-o");
    $("i", obj).attr("class", "fa fa-check-square-o");
}

//绑定会员
function BindVIP() {
    //showLoader("loading","正在处理,请稍候...");
    var vipkh = $("#bind-vipkh").val();
    var bid = $("#NewGuide").attr("bid");
    if (bid == "0" || bid == "" || bid == undefined) 
        showLoader("warn", "BID参数丢失,请尝试重新打开!");
    else if (vipkh == "")
        showLoader("warn", "VIP卡号不能为空!");
    else {
        showLoader("loaing", "正在处理,请稍候...");
        var jsonStr = { "mdid": mdid, "salerid": AppSystemKey, "bid": bid, "vipkh": vipkh };        
        $.ajax({
            url: "../../WebBLL/VIPListCore.aspx?ctrl=BindVIP",
            type: "POST",
            dataType: "text",
            data: { jsonStr: JSON.stringify(jsonStr) },
            timeout: 10000,
            error: function (XMLHttpRequest, textStatus, errorThrown) {                
                showLoader("error", "您的网络好像出了点问题,请稍后重试...");
            },
            success: function (rs) {
                if (rs.indexOf("Successed") > -1) {
                    var data = rs.replace("Successed", "").split("|");
                    var obj = $(".vipul li[bid=" + bid + "]");
                    obj.attr("vipid", data[0]);
                    obj.attr("vipkh", data[1]);
                    obj.attr("vtype", "VIP-WX");
                    $($(".icon-group img", obj)[1]).attr("src", "../../res/img/storesaler/icon-vip-1.png");
                    showLoader("successed", "恭喜,绑定成功!");
                    setTimeout(function () {
                        backFunc();
                        backFunc();
                    }, 500);
                }else
                    showLoader("error", rs.replace("Error:", ""));                                
            }
        });       
    }    
}

//申请会员
function RegisterVIP() {
    var username = $("#reg-username").val();
    var birthday = $("#reg-birthday").val();
    var tel = $("#reg-phone").val();
    var xb = $(".sex-item .fa.fa-check-square-o").parent().attr("xb");//0-男 1-女
    if (username == "") {
        showLoader("error", "姓名不能为空!");
        return;
    } else if (xb != "0" && xb != "1") {
        showLoader("error", "性别有误!");
        return;
    } else if (birthday == "") {
        showLoader("error", "生日不能为空!");
        return;
    } else if (tel == "") {
        showLoader("error", "手机号码不能为空!");
        return;
    } else {
        showLoader("loading", "正在处理,请稍候...");
        var bid = $("#NewGuide").attr("bid");
        var jsonStr = { "mdid": mdid, "salerid": AppSystemKey, "bid": bid, "vipkh": tel, name: username, xb: xb, birthday: birthday, tel: tel };
        $.ajax({
            url: "../../WebBLL/VIPListCore.aspx?ctrl=RegisterVIP",
            type: "POST",
            dataType: "text",
            data: { jsonStr: JSON.stringify(jsonStr) },
            timeout: 15 * 1000,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                showLoader("error", "您的网络好像出了点问题,请稍后重试...");
            },
            success: function (rs) {
                if (rs.indexOf("Successed") > -1) {
                    var data = rs.replace("Successed", "").split("|");
                    var obj = $(".vipul li[bid=" + bid + "]");
                    obj.attr("vipid", data[0]);
                    obj.attr("vipkh", data[1]);
                    obj.attr("vtype", "VIP-WX");
                    $($(".icon-group img", obj)[1]).attr("src", "../../res/img/storesaler/icon-vip-1.png");
                    showLoader("successed", "恭喜,注册成功!");
                    setTimeout(function () {
                        backFunc();
                        backFunc();
                    }, 500);
                } else
                    showLoader("error", rs.replace("Error:", ""));
            }
        });
    }
}