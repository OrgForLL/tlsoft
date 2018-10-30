﻿var tagShow = false;
var tagsArr = new Array();
var currentUser = "0";
var wxid = '';
var tagIsLoad = false, pageLoaded = false, isFilter = false;
var lastxh = "0", interval;
var radarChart, lbChart, xlChart, ysChart;
var CurrentSite = "vip-list";//用于标示当前用户所处的页面位置
//分页相关变量
var pageSize = 200, pageNo = 1, allPageNo = 0;
var filterObj = { mons: "", bdays: "", splb: "", cname: "", lable: "", lableid: [] };//筛选相关条件，每次进行比对，发生变化则重置pageNo=1;
$(function () {
    GetVIPList();

    //用处不大，暂时先隐藏
    if (RoleID == "1") {
        $(".filterbtn[filter]").hide();
    }
});

//20170316 liqf增加按标签搜索的功能
$(".search_tag_title").click(function () {
    var so = $("#searchTagPage");
    if (so.hasClass("page-top"))
        so.removeClass("page-top");
    else
        so.addClass("page-top");
    return;
    if ($(this).hasClass("active")) {
        $(this).removeClass("active");
        $("#searchtxt").attr("placeholder", "搜索VIP名字..");
    } else {
        $(this).addClass("active");
        $("#searchtxt").attr("placeholder", "搜索VIP标签..");
        $("#searchTagPage").removeClass("page-top");
    }
});

//搜索、筛选事件
function SearchFunc() {
    //关闭筛选页
    if ($(".mysort").attr("isshow") == "1") {
        $(".mysort").attr("isshow", "0");
        $(".mysort").addClass("page-top");
        $("#mask2").hide();
    }

    var par = $("#filter-page");
    var mons = par.find(".sortul[data-type='consume'] li.checked").attr("data-dm");
    mons = mons === undefined ? "" : mons;
    var bdays = par.find(".sortul[data-type='birthday'] li.checked").attr("data-dm");
    bdays = bdays === undefined ? "" : bdays;
    var splb = par.find(".sortul[data-type='goodClass'] li.checked").attr("data-dm");
    splb = splb === undefined ? "" : splb;
    var bindvip = par.find(".sortul[data-type='VIPcard'] li.checked").attr("data-dm");
    bindvip = bindvip === undefined ? "" : bindvip;

    var cname = "", lable = "";
    cname = encodeURIComponent($("#searchtxt").val().trim());
    //if ($(".search_tag_title").hasClass("active")) {
    //    lable = encodeURIComponent($("#searchtxt").val().trim());
    //} else {
    //    cname = encodeURIComponent($("#searchtxt").val().trim());
    //}

    var tagsArr = [];
    var obj = $("#searchTagPage .tagselected");
    for (var i = 0; i < obj.length; i++) {
        tagsArr.push(obj.eq(i).attr("tid"));
    }//end for    
    if (tagsArr.length > 0)
        $(".search_tag_title").addClass("active");
    else
        $(".search_tag_title").removeClass("active");

    var _obj = { mons: mons, bdays: bdays, splb: splb, cname: cname, lable: lable, lableid: tagsArr, bindvip: bindvip };
    console.log("上一次搜索条件：" + JSON.stringify(filterObj));//上一次
    console.log("目前搜索条件" + JSON.stringify(_obj));//此次
    if (JSON.stringify(_obj) != JSON.stringify(filterObj)) {
        //先释放上一次的数据
        filterObj.lableid = null;

        filterObj.mons = mons;
        filterObj.bdays = bdays;
        filterObj.splb = splb;
        filterObj.cname = cname;
        filterObj.lable = lable;
        filterObj.lableid = tagsArr;
        filterObj.bindvip = bindvip;
        pageNo = 1;
        allPageNo = 0;
        GetVIPList();
    } else
        showLoader("warn", "搜索条件无变化..");
}

//搜索标签
$("#btn_searchTag").click(function () {
    SearchFunc();
    backFunc();
});

//加载用户标签模板数据
function LoadTagTemplate() {
    showLoader("loading", "正在加载标签模板...");
    $.ajax({
        url: "VIPListCore.aspx?ctrl=GetTagTemplate",
        type: "POST",
        dataType: "text",
        //cache: false,//不使用缓存
        timeout: 30*1000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
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

                var copytags = $("#tags-page .tagcontent").clone();
                copytags.find(".tagitem:last-child").remove();
                $("#btn_searchTag").before(copytags);//复制一份


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
                loadGoodClass();//加载筛选条件--品类
            }
        }
    });
}

//读取VIP用户列表数据        
function GetVIPList() {
    showLoader("loading", "正在拉取数据...");
    $.ajax({
        //url: "../../WebBLL/VIPListCore.aspx?ctrl=GetVipList",
        url: "VIPListCore.aspx?ctrl=getVipList",
        type: "POST",
        dataType: "text",
        data: { mdid: mdid, salerid: AppSystemKey, role: RoleID, pageSize: pageSize, pageNo: pageNo, mons: filterObj.mons, bdays: filterObj.bdays, cname: filterObj.cname, lable: filterObj.lable, splb: filterObj.splb, lableid: filterObj.lableid.join(','), bindvip: filterObj.bindvip },
        timeout: 30 * 1000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
        },
        success: function (result) {
            if (result.indexOf("Error:") > -1) {
                showLoader("error", result);
            } else if (result == "") {
                showLoader("successed", "获取成功！");
                $("#loadmore_btn").text("无更多数据...");
            } else {
                var datas = result.replace("Successed", "");
                var obj = JSON.parse(datas);

                var data = {
                    list: obj.rows
                };
                $("#vipall").text(obj.totalRows);
                var render = _.template($("#userlist").html());
                var html = render(data);
                $(".vipul").empty().html(html);
                $("#vip_wrap").scrollTop(0);//列表定位到顶部

                //用户头像延迟加载
                $("#vip_wrap").unbind("scroll");
                $("#vipdiv .userimg.lazy").lazyload({
                    threshold: 10,
                    container: $("#vip_wrap")
                });

                if (!tagIsLoad)
                    LoadTagTemplate();
                else
                    showLoader("successed", "获取成功！");

                if (pageNo == "1") {
                    if (obj.totalRows % pageSize > 0)
                        allPageNo = parseInt(obj.totalRows / pageSize) + 1;
                    else
                        allPageNo = obj.totalRows / pageSize;
                    $("#allPageNo").text(allPageNo);
                    $("#currentPageNo").text(pageNo);
                }

                //重置全选状态
                selectedUsers = 0;
                $("#select_count").text(selectedUsers);
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
        url: "VIPListCore.aspx?ctrl=LatestConsume",
        type: "POST",
        dataType: "text",
        data: { ukh: $("#vipdiv li[vipid=" + currentUser + "]").attr("vipkh") },
        //cache: false,//不使用缓存
        timeout: 30*1000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
            $(".consumebtn").html("<i class='fa fa-rotate-right'></i>");
        },
        success: function (result) {
            if (result.indexOf("Error") > -1) {
                showLoader("error", "System Error:" + result);
                $(".consumebtn").html("<i class='fa fa-rotate-right'></i>");
            } else if (result == "") {
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
        url: "VIPListCore.aspx?ctrl=ConsumeDetail",
        type: "POST",
        dataType: "text",
        data: { djid: $(djobj).attr("djid") },
        timeout: 30*1000,
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
    var obj = $("#tags-page .tagselected");
    var data = new Object();
    var tagsArr = [];
    var remark = encodeURI($("#tagdefine").val());
    if (obj.length == 0 && remark == "") {
        data = { wxid: wxid, data: "", remark: "", type: "delete" };
    } else {
        if (obj.length != 0) {
            for (var i = 0; i < obj.length; i++) {
                tagsArr.push(obj.eq(i).attr("tid"));
            }//end for
            data = { wxid: wxid, data: tagsArr, remark: remark, type: "update" };
        } else
            data = { wxid: wxid, data: "", remark: remark, type: "update" };
    }

    showLoader("loading", "正在提交数据...");
    $.ajax({
        url: "VIPListCore.aspx?ctrl=UpUserTags",
        type: "POST",
        dataType: "text",
        data: { tags: JSON.stringify(data) },
        timeout: 30*1000,
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

$("#vipdiv").on("click", "li", function (e) {
    //console.log(e.target);
    userinfo(this);
});

//读取用户详细信息
function userinfo(uobj) {
    var usertype = $(uobj).attr("vtype");
    if (usertype == "WX") {
        /* var render = _.template($("#guideTemp").html());
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
        CurrentSite = "new-guide"; */
        alert("请指导客户申请或绑定会员");
        // showMesssage.warn("请指导客户申请或绑定会员");
        $(".sorts").hide();
    } else if (usertype == "VIP-WX" || usertype == "VIP") {
        showLoader("loading", "正在读取用户信息...");
        currentUser = $(uobj).attr("vipid");
        wxid =  $(uobj).attr("wxid");
        $.ajax({
            url: "VIPListCore.aspx?ctrl=GetUserInfo",
            type: "POST",
            dataType: "text",
            data: { wxid: $(uobj).attr("wxid"), wxopenid: $(uobj).attr("wxopenid") }, // uid: $(uobj).attr("vipid"), ukh: $(uobj).attr("vipkh")
            //cache: false,//不使用缓存
            timeout: 30*1000,
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
                    $(".userinfo .headimg").css("background-image", $(uobj).find(".userimg").css("background-image"));
                    pageLoaded = false;
                    CurrentSite = "vip-detail";
                    $(".morebtn").unbind("click").click(function () {
                        if ($(".moreinfo").css("display") == "none") {
                            $(".moreinfo").show();
                            $(".morebtn i").addClass("iconup");
                        } else {
                            $(".moreinfo").hide();
                            $(".morebtn i").removeClass("iconup");
                        }
                    });
                    GetUserTags();
                }
            }
        });
    }
}

//读取用户标签数据
function GetUserTags() {
    //showLoader("loading", "正在读取用户标签数据...");
    if (pageLoaded) return;
    $.ajax({
        url: "VIPListCore.aspx?ctrl=GetUserTags",
        type: "POST",
        dataType: "text",
        data: { wxid: wxid }, // wxid
        timeout: 30*1000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
        },
        success: function (result) {
            if (result.indexOf("Error") > -1) {
                showLoader("error", "System Error:" + result);
            } else {
                tagsArr = result.split('||')[0].split(',');
                $("#tags-page .tagselected").removeClass("tagselected");
                for (var i = 0; i < tagsArr.length - 1; i++) {
                    $("#tags-page .tagitemul li[tid='" + tagsArr[i] + "']").addClass("tagselected");
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
        url: "VIPListCore.aspx?ctrl=GetChartDatas",
        type: "POST",
        dataType: "text",
        data: { uid: currentUser, type: type, ukh: $("#vipdiv li[vipid=" + currentUser + "]").attr("vipkh") },
        //cache: false,//不使用缓存
        timeout: 30*1000,
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
            } else if (result == "") {
                //alert("none");
                showLoader("error", "System Error:" + result);
            } else {
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
                            };//end data
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
                            };//end data
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
                            };//end data
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
    showLoadingText("#contitle", " 正在统计，请稍候");
    $.ajax({
        url: "VIPListCore.aspx?ctrl=GetVIPBehavior",
        type: "POST",
        dataType: "text",
        data: { uid: currentUser, ukh: $("#vipdiv li[vipid=" + currentUser + "]").attr("vipkh") },
        timeout: 30*1000,
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
            } else {
                var obj = result.split('|');
                var data = {
                    gmcs: obj[0],//购买次数
                    pjdj: parseFloat(obj[1]).toFixed(2),//平均单价
                    pjdl: parseFloat(obj[2]).toFixed(2),//客单量
                    pjzks: parseFloat(obj[3]).toFixed(1),//平均折扣数
                    pl: obj[4],//购买品类
                    fg: obj[5],//风格
                    ys: obj[6],//颜色
                    xfje: obj[7],//消费金额
                    lastje: obj[8],//最后一次消费金额
                    lastsj: obj[9],//最近消费时间
                    dists: obj[10] + '天'//最近消费时间距现多少天
                };
                var render = _.template($("#userconsume").html());
                $("#info-page .usernav .title").eq(0).after(render(data));

                //准备雷达图数据
                //消费金额：10000-50000 平均单价：300-1000 客单量：1-5 平均折扣：1-10
                var kdj = parseInt(obj[7]) / parseInt(obj[0]);
                if (kdj <= 599) kdj = 5;
                else if (kdj >= 5999) kdj = 95;
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
                else if (dists >= 120) dists = 5;
                else {
                    dists = parseInt(95 - (dists - 30));
                }

                var radardata = {
                    labels: ["客单价 " + parseInt(parseInt(obj[7]) / parseInt(obj[0])) + "元", "平均单价 " + parseInt(obj[1]) + "元", "客单量 " + parseInt(obj[2]) + "件", "平均折扣 " + parseFloat(obj[3]).toFixed(1) + "折", "最后消费 " + obj[10] + "天"],
                    datasets: [
                        {
                            fillColor: "rgba(217,83,79,0.6)",
                            strokeColor: "rgba(220,220,220,1)",
                            pointColor: "rgba(153,153,153,1)",
                            pointStrokeColor: "#fff",
                            data: [kdj, pjdj, kdl, pjzk, dists]
                        }
                    ]
                };
                //showLoader("successed", "查询成功!");   
                var chartOpi = new Object();
                chartOpi.pointDot = false;
                chartOpi.scaleOverride = true;
                chartOpi.scaleSteps = 10;
                chartOpi.scaleStepWidth = 10;
                chartOpi.scaleStartValue = 1;
                drawCharts(radardata, chartOpi);
            }
        }
    });
}

//提示层
function showLoader(type, txt) {
    switch (type) {
        case "loading":
            $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
            $("#loadtext").html(txt);
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
            $(".attract_tools").removeClass("show");
            $(".tags").text("打标签");
            tagShow = false;
            $(".sorts").show();
            $("#to-top").show();
            //$(".filterbtn[filter]").show();
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
            if ($(".mysort").attr("isshow") == "0" && $("#searchTagPage").hasClass("page-top")) {
                if (llApp && llApp.isInApp) {
                    llApp.closeWKView();
                }else
                    window.history.go(-1);
            } else if (!$("#searchTagPage").hasClass("page-top")) {
                $("#searchTagPage").addClass("page-top")
            }
            break;
        case "weixincard":
            if ($(".attract_tools").hasClass("show")) {
                $(".attract_tools").removeClass("show");
            }
            $("#weixincard").addClass("page-right");
            CurrentSite = "vip-list";
            break;
        case "goodlink":
            if ($(".attract_tools").hasClass("show")) {
                $(".attract_tools").removeClass("show");
            }
            $("#goodlink").addClass("page-right");
            CurrentSite = "vip-list";
            break;
    }

    if ($(".mysort").attr("isshow") == "1") {
        $(".mysort").attr("isshow", "0");
        $(".mysort").addClass("page-top");
        $("#mask2").hide();
    }
    $("#tags-page").addClass("page-top");
}

$(".backbtn").click(backFunc);

//打开标签页
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

function localSearch() {
    if ($(".search_tag_title").hasClass("active"))
        return;
    var obj = $("#vipdiv li h3");
    if (obj.length > 0) {
        var filter = $("#searchtxt").val();
        if (filter) {
            $matches = $("#vipdiv li").find("h3:Contains(" + filter + ")").parent();
            $("li", $("#vipdiv")).not($matches).hide();
            $matches.show();
        } else {
            $("#vipdiv").find("li").show();
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
    $("#vip_wrap").animate({ scrollTop: 0 }, 400);
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
    var tagObj = $("#tags-page .tagselected");
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
            url: "VIPListCore.aspx?ctrl=BindVIP",
            type: "POST",
            dataType: "text",
            data: { jsonStr: JSON.stringify(jsonStr) },
            timeout: 30*1000,
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
                } else
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
        var jsonStr = { "khid": khid, "mdid": mdid, "salerid": AppSystemKey, "bid": bid, "vipkh": tel, name: username, xb: xb, birthday: birthday, tel: tel };
        $.ajax({
            url: "VIPListCore.aspx?ctrl=RegisterVIP",
            type: "POST",
            dataType: "text",
            data: { jsonStr: JSON.stringify(jsonStr) },
            timeout: 30 * 1000,
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

//=========================================20170421==========================================
//加载微信卡券
function loadWXCards() {
    showLoader("loading", "正在加载卡券列表..");
    setTimeout(function () {
        $.ajax({
            url: "VIPListCore.aspx?ctrl=getCardsList",
            type: "POST",
            dataType: "text",
            data: { mdid: mdid },
            timeout: 30 * 1000,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                showLoader("error", "您的网络好像出了点问题,请稍后重试...");
            },
            success: function (result) {
                if (result.indexOf("Error") > -1) {
                    showLoader("error", "获取卡券失败:" + result.replace("Error:", ""));
                } else {
                    var rows = JSON.parse(result).rows;
                    var html = "";
                    for (var i = 0; i < rows.length; i++) {
                        html += template("tpl_wxcard", rows[i]);
                    }//end for

                    $("#weixincard .card_wrap").empty().html(html);
                    if (html == "")
                        $("#weixincard .noresult").show();

                    $(".mask").hide();
                }
            }
        });
    }, 100);
}

function SearchGoods() {
    var sphh = $(".goodslink_search").val().trim();
    if (sphh == "")
        showLoader("warn", "请输入完整的商品货号！");
    else {
        showLoader("loading", "正在搜索..");
        setTimeout(function () {
            $.ajax({
                url: "VIPListCore.aspx?ctrl=getSphhInfo",
                type: "POST",
                dataType: "text",
                data: { sphh: sphh },
                timeout: 30 * 1000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "您的网络好像出了点问题,请稍后重试...");
                },
                success: function (result) {
                    console.log(result);
                    if (result.indexOf("Error:") > -1) {
                        showLoader("error", result.replace("Error:", ""));
                        $("#goodlink .good_wrap").empty();
                        $("#goodlink .noresult").show();
                    } else {
                        var rows = JSON.parse(result).rows;
                        var html = "";
                        for (var i = 0; i < rows.length; i++) {
                            rows[i].picUrl = rows[i].picUrl == "" ? "../../res/img/storesaler/lilanzlogo.jpg" : rows[i].picUrl;
                            html += template("tpl_gooditem", rows[i]);
                        }//end for

                        $("#goodlink .good_wrap").empty().html(html);
                        if (html == "")
                            $("#goodlink .noresult").show();

                        $(".mask").hide();
                    }
                }
            });
        }, 100);
    }
}

$("#goodlink .good_wrap").on("click", ".good_item", function () {
    var spmc = $(this).find(".good_spmc").text();
    var sphh = $(this).find(".good_sphh").text();
    if (sphh == "")
        return;
    if (confirm("确认将【" + spmc + "|" + sphh + "】发送给【" + selectedUsers + "】用户？？")) {
        backFunc();
        massSendLink(sphh, 0);
    }
});
//发送商品链接通知 36496
function massSendLink(sphh, order) {
    var items = $("#vipdiv .checked");
    if (items.length <= 0)
        return;
    showLoader("loading", "<p>正在发送商品链接中..</p><p>" + (order + 1) + " / " + items.length) + "</p>";
    var info_bot = items.eq(order).parent().find(".send_result");
    info_bot.attr("class", "send_result").text("正在发送商品链接..");
    var bid = items.eq(order).parent().attr("bid");

    setTimeout(function () {
        $.ajax({
            type: "POST",
            timeout: 30 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "VIPListCore.aspx?ctrl=sendSphhInfo",
            data: { sphh: sphh, bid: bid, mdid: mdid, cid: customerID },
            success: function (msg) {
                if (msg.indexOf("Successed") > -1) {
                    var now = new Date(Date.now()).Format("yyyy-MM-dd HH:mm:ss");
                    info_bot.attr("class", "send_result success").text("发送商品链接成功！" + now);
                } else {
                    info_bot.attr("class", "send_result fail").text("发送商品链接失败！" + msg.replace("Error:", ""));
                }

                if (order < $("#vipdiv .checked").length - 1)
                    massSendLink(sphh, order + 1);
                else {
                    $("#vipdiv .checkbox.checked").removeClass("checked");
                    selectedUsers = 0;
                    $("#select_count").text("0");
                    showLoader("successed", "全部发送完毕，发送结果请在页面上查看。");
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                info_bot.attr("class", "send_result fail").text("网络出错！" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);

                if (order < $("#vipdiv .checked").length - 1)
                    massSendLink(sphh, order + 1);
                else {
                    $("#vipdiv .checkbox.checked").removeClass("checked");
                    selectedUsers = 0;
                    $("#select_count").text("0");
                    showLoader("successed", "全部发送完毕，发送结果请在页面上查看。");
                }
            }
        });//end AJAX
    }, 50);
}

$("#weixincard .card_wrap").on("click", ".card_item", function () {
    var cardName = $(this).find(".card_name").text();
    var cardID = $(this).attr("data-id");
    if (cardID == "" || cardID == "0" || cardID === undefined)
        return;
    if (confirm("确认将【" + cardName + "】发送给【" + selectedUsers + "】用户？？")) {
        backFunc();
        massSendCard(cardID, 0);
    }
});
//发送领取微信卡券通知 36496
function massSendCard(cardid, order) {
    var items = $("#vipdiv .checked");
    if (items.length <= 0)
        return;
    showLoader("loading", "<p>正在发送微信卡券中..</p><p>" + (order + 1) + " / " + items.length) + "</p>";
    var info_bot = items.eq(order).parent().find(".send_result");
    info_bot.attr("class", "send_result").text("正在发送微信卡券..");
    var bid = items.eq(order).parent().attr("bid");
    setTimeout(function () {
        $.ajax({
            type: "POST",
            timeout: 30 * 1000,
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            url: "VIPListCore.aspx?ctrl=senCardToVIP",
            data: { bid: bid, cardid: cardid },
            success: function (msg) {
                if (msg.indexOf("Successed") > -1) {
                    var now = new Date(Date.now()).Format("yyyy-MM-dd HH:mm:ss");
                    info_bot.attr("class", "send_result success").text("发送卡券成功！" + now);
                } else {
                    info_bot.attr("class", "send_result fail").text("发送卡券失败！" + msg.replace("Error:", ""));
                }

                //还有下一个
                if (order < $("#vipdiv .checked").length - 1)
                    massSendCard(cardid, order + 1);
                else {
                    $("#vipdiv .checkbox.checked").removeClass("checked");
                    selectedUsers = 0;
                    $("#select_count").text("0");
                    showLoader("successed", "全部发送完毕，发送结果请在页面上查看。");
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                info_bot.attr("class", "send_result fail").text("网络出错！" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);

                if (order < $("#vipdiv .checked").length - 1)
                    massSendCard(cardid, order + 1);
                else {
                    $("#vipdiv .checkbox.checked").removeClass("checked");
                    selectedUsers = 0;
                    $("#select_count").text("0");
                    showLoader("successed", "全部发送完毕，发送结果请在页面上查看。");
                }
            }
        });//end AJAX
    }, 50);
}

Date.prototype.Format = function (fmt) {
    var o = {
        "M+": this.getMonth() + 1,
        "d+": this.getDate(),
        "H+": this.getHours(),
        "m+": this.getMinutes(),
        "s+": this.getSeconds(),
        "q+": Math.floor((this.getMonth() + 3) / 3),
        "S": this.getMilliseconds()
    };
    var year = this.getFullYear();
    var yearstr = year + '';
    yearstr = yearstr.length >= 4 ? yearstr : '0000'.substr(0, 4 - yearstr.length) + yearstr;

    if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (yearstr + "").substr(4 - RegExp.$1.length));
    for (var k in o)
        if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
    return fmt;
}

//按页加载
function getPageData(direction) {
    if (direction == "prev") {
        if (pageNo > 1) {
            $("#currentPageNo").text(--pageNo);
            GetVIPList();
        }
    } else if (direction == "next") {
        if (pageNo < allPageNo) {
            $("#currentPageNo").text(++pageNo);
            GetVIPList();
        }
    }
}

//全选功能
$(".attract_tools .select_all").click(function () {
    if ($(this).hasClass("checked")) {
        //取消全选
        $("#vipdiv li .checkbox.checked").removeClass("checked");
        selectedUsers = 0;
        $("#select_count").text("0");
        $(this).removeClass("checked");
    } else {
        //全选
        if ($("#vipdiv li").length > 100)
            showLoader("warn", "为了防止对顾客造成骚扰，请先将列表筛选到100名以下！");
        else {
            $("#vipdiv li .checkbox").addClass("checked");
            selectedUsers = $("#vipdiv li").length
            $("#select_count").text(selectedUsers);
            $(this).addClass("checked");
        }
    }
});

//加载筛选页中的商品品类
function loadGoodClass() {
    $.ajax({
        url: "VIPListCore.aspx?ctrl=getsplb",
        type: "POST",
        dataType: "text",
        timeout: 30*1000,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            showLoader("error", "您的网络好像出了点问题,请稍后重试...");
        },
        success: function (msg) {
            if (msg.indexOf("Error:") > -1) {
                showLoader("error", "加载品类出错！" + msg.replace("Error:", ""));
            } else {
                var html = "";
                var rows = JSON.parse(msg).rows;
                for (var i = 0; i < rows.length; i++) {
                    html += template("tpl_classitem", rows[i]);
                }//end for
                $("#filter-page .sortul[data-type='goodClass']").empty().html(html);
            }
        }
    });
}