<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            font-size: 14px;
            background-color: #f0f0f0;
            line-height: 1;
            color: #363c44;
            -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
        }

        .page {
            background-color: #f4f4f4;
        }

        .page-not-header-footer {
            bottom: 28px;
        }

        .header {
            line-height: 50px;
            font-size: 16px;
            z-index: 4000;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
        }

            .header .fa-angle-left {
                font-size: 24px;
                position: absolute;
                top: 0;
                left: 0;
                padding: 0 20px;
                border-right: 1px solid #f0f0f0;
                line-height: 50px;
            }

        .card {
            background-color: #fff;
            height: 170px;
            border-radius: 4px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
        }

            .card:not(:last-child) {
                margin-bottom: 10px;
            }

            .card .card_top {
                height: 130px;
                background-color: #63b359;
                border-top-left-radius: 4px;
                border-top-right-radius: 4px;
                color: #fff;
                padding: 10px;
                position: relative;
                overflow: hidden;
            }

        .card_top .store_name {
            font-size: 14px;
            line-height: 15px;
            vertical-align: top;
        }

        .card_top .card_title {
            font-size: 24px;
            font-weight: bold;
            line-height: 47px;
        }

        .card_top .card_subtitle {
            max-height: 48px;
            line-height: 17px;
            overflow: hidden;
        }

        .card_top .fa-angle-right {
            display: block;
            position: absolute;
            top: 0;
            right: 0;
            padding: 0 10px;
            font-size: 24px;
            line-height: 130px;
            border-left: 1px dashed #fff;
        }

        .card_bot {
            line-height: 40px;
            padding: 0 10px;
            position: relative;
        }

            .card_bot .counts {
                position: absolute;
                top: 0;
                right: 10px;
            }

        .card_top .card_icon {
            width: 100px;
            height: 100px;
            position: absolute;
            top: -20px;
            right: -20px;
            opacity: 0.2;
            transform: rotate(-30deg);
        }

        .back-image {
            background-repeat: no-repeat;
            background-position: 50% 50%;
            background-size: cover;
        }

        /*卡券详情*/
        .card_content {
            background-color: #fff;
            border-bottom-left-radius: 4px;
            border-bottom-right-radius: 4px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
        }

        .detail_top {
            color: #fff;
            height: 44px;
            line-height: 44px;
            padding: 0 10px;
            font-size: 16px;
            background-color: #63b359;
            border-top-left-radius: 4px;
            border-top-right-radius: 4px;
            position: relative;
        }

            .detail_top:before, .detail_title:before, .detail_qrcode:before, .detail_useinfo:before {
                content: '';
                width: 16px;
                height: 16px;
                background-color: #f4f4f4;
                position: absolute;
                bottom: -8px;
                left: -8px;
                border-radius: 50%;
            }

            .detail_top:after, .detail_title:after, .detail_qrcode:after, .detail_useinfo:after {
                content: '';
                width: 16px;
                height: 16px;
                background-color: #f4f4f4;
                position: absolute;
                bottom: -8px;
                right: -8px;
                border-radius: 50%;
            }

        .detail_title, .detail_useinfo, .detail_qrcode {
            padding: 10px;
            position: relative;
            border-bottom: 1px dashed #ccc;
        }

            .detail_title > h1 {
                text-align: center;
                padding: 10px;
            }

            .detail_title .sub_title {
                text-align: center;
                font-size: 16px;
                color: #888;
            }

            .detail_title .time {
                text-align: center;
                font-size: 14px;
                color: #888;
                padding: 10px 0;
            }

            .detail_useinfo .useinfo-item {
                padding-top: 10px;
                display: -webkit-box;
                display: -webkit-flex;
                display: flex;
            }

        .useinfo-item .left {
            width: 75px;
        }

        .useinfo-item .right {
            -webkit-box-flex: 1;
            -webkit-flex: 1;
            -ms-flex: 1;
            flex: 1;
            line-height: 1.2;
        }

        .detail_bot {
            height: 40px;
            line-height: 40px;
        }

            .detail_bot > div {
                float: left;
                width: 50%;
                text-align: center;
                font-weight: bold;
            }

                .detail_bot > div:not(:last-child) {
                    border-right: 1px solid #f0f0f0;
                }

                .detail_bot > div i {
                    padding-left: 5px;
                    font-size: 16px;
                    color: #cecece;
                }

                .detail_bot > div .check {
                    color: #63b359;
                }

        .footer {
            height: 28px;
            line-height: 28px;
            text-align: center;
            color: #888;
            font-size: 12px;
            background-color: #f4f4f4;
        }

        .detail_qrcode {
            text-align: center;
            font-weight: bold;
            color: #cc463d;
        }

            .detail_qrcode > p {
                line-height: 20px;
            }

        #qrcode {
            width: 52%;
            max-width: 560px;
            border: 1px solid #f0f0f0;
            margin-top: 10px;
            padding: 8px;
        }

        .card_btns {
            width: 94%;
            margin: 0 auto;
        }

            .card_btns .btn-item {
                display: block;
                color: #fff;
                background-color: #63b359;
                margin: 10px auto;
                height: 40px;
                line-height: 40px;
                font-size: 15px;
                font-weight: bold;
                text-align: center;
                border-radius: 4px;
            }

        .no-cards {
            text-align: center;
            color: #999;
            min-width: 100%;
            display: none;
        }

        .disabled {
            pointer-events: none !important;
            background-color: #ccc !important;
        }
        /*viplist style*/
        .user_list {
            line-height: 1;
            width: 100%;
        }

            .user_list li {
                color: #222;
                position: relative;
                background-color: #fff;
                margin-bottom: 5px;
            }

                .user_list li .info_top {
                    display: flex;
                    display: -webkit-flex;
                    align-items: center;
                    padding: 10px;
                }

                .user_list li .info_bot {
                    padding: 3px 10px;
                    color: #fff;
                    font-weight: bold;
                    font-style: italic;
                    line-height: 1.4;
                    transition: all 0.2s;
                    display: none;
                }

            .user_list .fa-check-circle {
                font-size: 24px;
                color: #ccc;
            }

                .user_list .fa-check-circle.check {
                    color: #63b359;
                }

            .user_list .head_img {
                width: 54px;
                min-width: 54px;
                height: 54px;
                border-radius: 50%;
                background-position: center center;
                background-size: cover;
                background-repeat: no-repeat;
                margin: 0 10px;
                border: 2px solid #f0f0f0;
            }

        .user_infos .name {
            font-size: 15px;
            font-weight: bold;
            line-height: 1.2;
        }

        .user_infos .kh {
            padding-top: 8px;
            color: #666;
        }

            .user_infos .kh.wx {
                color: #63b359;
                font-weight: bold;
            }

        .user_infos .last_send {
            font-size: 12px;
            padding-top: 6px;
            color: #666;
        }

        .info_bot.success {
            display: block !important;
            background-color: #63b359;
        }

        .info_bot.fail {
            display: block !important;
            background-color: #cc463d;
        }

        .info_bot.sending {
            display: block !important;
            background-color: #ccc;
        }
        /*viplist end*/
        #vip-list .title {
            height: 40px;
            line-height: 40px;
            background-color: #63b359;
            font-size: 16px;
            color: #fff;
            text-align: center;
            border-top-left-radius: 4px;
            border-top-right-radius: 4px;
        }

        #searchVIP {
            -webkit-appearance: none;
            border: none;
            padding: 0 10px;
            border-bottom: 1px solid #eceef1;
            border-radius: 2px;
            width: 100%;
            margin: 0 auto;
            height: 40px;
            line-height: 40px;
            font-size: 14px;
            outline: none;
        }

        #vip-list .v_top {
            position:absolute;
            top:0;
            left:0;            
            width:100%;
            bottom:40px;
            padding:10px;            
            overflow-x:hidden;
            overflow-y:scroll;
            -webkit-overflow-scrolling:touch;            
        }

        #vip-list .v_btn {
            position:absolute;
            left:0;
            bottom:0;
            width:100%;
            height:40px;          
            font-size:0;
        }

        .mass_btn {
            display:inline-block;
            width:50%;
            background-color:#ccc;
            color:#fff;
            font-weight:bold;
            font-size:14px;
            line-height:40px;
            text-align:center;
        }
            .mass_btn.confirm {
                background-color:#63b359;
            }
        .card_type {
            position: absolute;
            top: 0;
            right: 40px;
            padding: 5px 8px;
            background-color: rgba(0,0,0,.4);
            color: #fff;
            font-size: 12px;
            font-weight: bold;
        }

        .customer {
            background-color: #63b359;
            color: #fff;
            position: absolute;
            top: 50%;
            right: 10px;
            padding: 4px 6px;
            transform: translate(0,-50%);
            -webkit-transform: translate(0,-50%);
            border-radius: 2px;
            font-size: 12px;
        }

        .configname {
            margin-right: 10px;
        }

        .fa-weixin {
            margin-right: 5px;
        }

        .detail_userCard {
            text-align: center;
            font-weight: bold;
            color: #333;
        } 

        .detail_userCard > p {
            padding-top: 10px;
        }

        .detail_userCard > span {
            display: block;
            padding: 20px 0;
            font-size: 40px;
            color: #cc463d;
        }

        /* 使用门店列表标签样式 */
        .storeLists {
            display: none;
            background-color: #FFF;
            z-index: 1000;
        }

        .storeLists .page {
            background-color: #f8f8f8;
            font-family: "Helvetica Neue", "Microsoft Yahei","微软雅黑",sans-serif;
            font-weight: 400;
            bottom: 30px;
            padding: 0;
        }

        .storeLists .footer {
            height: 30px;
            line-height: 30px;
            background-color: #f8f8f8;
            color: #888;
            font-size: 12px;
        }
        .storeLists .header
        {
            line-height: 50px;
        }
        
        .storeLists .item {
            background-color: #fff;
            padding: 10px;
            margin-top: 4px;
            position:relative;
        }
            .storeLists .item .right {
                position:absolute;
                top:50%;
                right:0;
                width:60px;
                transform:translate(0,-50%);
                border-left:1px solid #ccc;
                height:50px;
                line-height:50px;                
                text-align:center;
            }
        .storeLists .name {
            font-size:16px;
            color:#323232;
            font-weight:600;
        }
        .storeLists .address {
            margin-top: 5px;
            color: #909090;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            padding-right: 60px;
        }

        .storeLists .phone {
            margin-top: 5px;
        }

        .storeLists .phone>a {
            color:#63b359;            
        }
        .storeLists .location_icon {
            width:30px;
            margin-top:10px;            
        }
        .storeLists .msg
        {
            display:none;
            margin-top:15px;
            font-size:18px;
            margin-left:8px;
        }
        .storeLists .msg p
        {
            margin-top:2px;
        }

        .StoreSearch {
            display: flex;
            text-align: center;
            padding: 10px;
        }

        .StoreSearch input {
            flex: 1;
            border: none;
            border-radius: 4px;
            padding: 6px 10px;
            border: 1px solid #F0F0F0;
            outline: none;
            font-size: 14px;
        }

        .search-btn {
            display: block;
            padding: 10px;
            padding-right: 0;
            color:#63b359;
        }

        /*------------------animation-------------------*/
        .map-fadeIn {
            animation: fadeIn 300ms;
        }

        .map-fadeOut {
            animation: fadeOut 300ms forwards;
        }

        @keyframes fadeIn {
            0% {
                transform: translate(100%,0);
            }
            
            100% {
                transform: translate(0,0);
            }
        }

        @keyframes fadeOut {
            0% {
                transform: translate(0,0);
            }
            
            100% {
                transform: translate(100%,0);
            }
        }
    </style>
</head>
<body>
    <div class="header"><span class="header-title">可用卡券列表</span><i class="fa fa-angle-left"></i></div>
    <div class="wrap-page">
        <!--卡券主列表-->
        <div class="page page-not-header-footer" id="main-page">
            <div id="card-list">
                <p class="no-cards center-translate">您目前还没有可用的卡券...</p>
            </div>
        </div>

        <!--卡券详情页-->
        <div class="page page-not-header-footer page-top" id="card-detail" cardid="0" configkey="" isload="0"></div>
    </div>
    <div class="wrap-page storeLists">
        <div class="page page-not-header-footer" id="storeMap">
        </div>
    </div>
    <div class="footer">&copy;2017 利郎信息技术部提供技术支持</div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <!--模板区-->
    <script id="card_temp" type="text/html">
        <div class="card" id="{{cid}}">
            <div class="card_top" style="background-color: {{color}};" onclick="GetCardDetail({{cid}});">
                <div class="store_name"><i class="fa fa-weixin"></i><span class="configname" data-key="1">利郎男装</span></div>
                <div class="card_title">{{Title}}</div>
                <div class="card_subtitle">{{SubTitle}}</div>
                <div class="back-image card_icon" style="background-image: url(../../img/card-icon.png);"></div>
                <i class="fa fa-angle-right"></i>
                <div class="card_type">{{CardType}}</div>
            </div>
            <div class="card_bot">
                <p class="time">有效期: {{BeginTimestamp}} 至 {{EndTimestamp}}</p>
            </div>
        </div>
    </script>

    <!--卡券详情模板-->
    <script id="carddetail_temp" type="text/html">
        <div class="card_content">
            <div class="detail_top">
                <i class="fa fa-weixin" style="padding-right: 5px;"></i><span>利郎男装</span>
            </div>
            <div class="detail_title">
                <h1>{{Title}}</h1>
                <p class="sub_title">{{SubTitle}}</p>
                <p class="time">有效期：{{BeginTimestamp}} 至 {{EndTimestamp}}</p>
            </div>
            <div class="detail_useinfo">
                <p style="padding: 3px 0 10px 0; border-bottom: 1px solid #f0f0f0; font-weight: bold;">{{CardType}}详情</p>
                <!--折扣券参数-->
                {{if localdiscount > 0}}
                <div class="useinfo-item discount">
                    <div class="left" style="font-weight: bold;">折扣数：</div>
                    <div class="right" style="font-weight: bold;">{{localdiscount}} 折</div>
                </div>
                {{/if}}
                <!--抵用券参数-->
                {{if reducecost > 0}}
                <div class="useinfo-item cash">
                    <div class="left" style="font-weight: bold;">使用门槛：</div>
                    <div class="right" style="font-weight: bold;">{{leastcost}} 元</div>
                </div>
                <div class="useinfo-item cash">
                    <div class="left" style="font-weight: bold;">抵用金额：</div>
                    <div class="right" style="font-weight: bold;">{{reducecost}} 元</div>
                </div>
                {{/if}}
                <div class="useinfo-item">
                    <div class="left">优惠详情：</div>
                    <div class="right">{{DefaultDetail}}</div>
                </div>
                <!--<div class="useinfo-item">
                    <div class="left">每人限领：</div>
                    <div class="right">{{getlimit}}张</div>
                </div>-->
                <!--<div class="useinfo-item">
                    <div class="left">使用提醒：</div>
                    <div class="right">{{notice}}</div>
                </div>-->
                <div class="useinfo-item">
                    <div class="left">使用说明：</div>
                    <div class="right">{{DESCRIPTION}}</div>
                </div>
                <!--<div class="useinfo-item">
                    <div class="left">客服电话：</div>
                    <div class="right">{{servicephone}}</div>
                </div>-->
            </div>
            <div class="detail_qrcode" style="display: none">
                <p>请将下面二维码让客人扫：</p>
            </div>
            <div class="detail_userCard">
                <p>请将下方优惠码交由店员使用：</p>
                <span>{{CardCode}}</span>
            </div>
        </div>
        <div class="card_btns">
            <a class="btn-item" id="send-btn" href="javascript:" onclick="GetCardSotre({{cid}})" >查看适用门店</a>
        </div>
    </script>

    <!--模板-->
    <script id="storeinfo" type="text/html">
        <div class="StoreSearch">
            <input id="storeSeacrh" type="text" placeholder="请输入门店名称" />
            <a class="search-btn" id="searchStore-btn" href="javascript:void(0)" >搜索</a>
        </div>
    {{each data as value i}}
        <div id="{{value.ID}}" class="item" {{if value.mdid > 0 && value.mdid != ""}}onclick="goMap({{value.ID}})" {{/if}}>
            <div class="left">
                <p class="name">{{value.mdmc}}</p>
                <p class="address">{{value.addressInfo}}</p>
                <p class="phone"><a href="tel:{{value.lxdh}}">{{value.lxdh}}</a></p>
            </div>
            <div class="right">
                <img class="location_icon" {{if value.mdid > 0 && value.mdid != ""}}src="../../res/img/vipweixin/location_icon.png"{{else}}src="../../res/img/vipweixin/location_no_icon.png"{{/if}} />
            </div>
        </div> 
    {{/each}}
    </script>

    <script type="text/javascript">
       var apiUrl = "../../webbll/FWHUserCenterCore.aspx";
       var cardList = {};
        $(function () {
            FastClick.attach(document.body);
            LeeJSUtils.stopOutOfPage("#main-page", true);
            LeeJSUtils.stopOutOfPage("#card-detail", true);            
            LeeJSUtils.stopOutOfPage(".header", false);
            LeeJSUtils.stopOutOfPage(".footer", false);
            LeeJSUtils.LoadMaskInit();
        });

        window.onload = function () {
            LoadCardList();
            BindEvents();
        };

        //返回操作
        $(".header .fa-angle-left").click(function () {
            ClickBack();
        });

        function BindEvents() {
            $("#vip-list .user_list").on("click", "li", function () {
                var ele = $(this).find(".fa-check-circle");                
                if (ele.hasClass("check")) {
                    ele.removeClass("check");
                    $(this).removeClass("check");
                    $("#selectAlls").text(--sendUsers);
                }
            });

            $(".mass_btn.cancle").click(function () {
                ClickBack();
            });

            $("#storeMap").on("click","#searchStore-btn",function() {
                var store = $("#storeSeacrh").val();
                console.log(store);
                if(store != "") {
                    $(".item").hide();
                    $(".item").find(".name:contains(" + store + ")").parent().parent().show();
                }else {
                    $(".item").show();
                }
                
            });
        }

        //加载卡券列表
        function LoadCardList() {
            LeeJSUtils.showMessage("loading", "正在加载微信卡券列表...");
            $.ajax({
                type: "GET",
                timeout: 5000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: apiUrl,
                data: { ctrl: "wechatCard"},
                dataType: "JSON"
            }).then(function(data) {
                if(data.code == "200") {
                    if(data.data.length == 0) {
                        $(".no-cards").show();
                    }else {
                        var list = data.data;
                        var html = "";
                        for(var i = 0; i < list.length; i++) {
                            if(list[i].LocalCardType == "LILANZ_DISCOUNT") {
                                list[i].CardType = "折扣券";
                            }else if(list[i].LocalCardType == "LILANZ_CASH") {
                                list[i].CardType = "抵用券";
                            }

                            list[i].color = ColorSwitch(list[i].color);
                            
                            html = html + template("card_temp",list[i]);
                            cardList[list[i].cid] = list[i];
                        }
                        $("#card-list").append(html);
                    }
                    $("#leemask").hide();
                }else {
                    LeeJSUtils.showMessage("error", "加载微信卡券失败！");
                    setTimeout(function() {
                        $("#leemask").hide();
                    },2000);
                }
            }).fail(function(err) {
                LeeJSUtils.showMessage("error", "网络异常！");
                setTimeout(function() {
                    $("#leemask").hide();
                },2000);
            });//end AJAX
        }

        //加载卡券详情
        function GetCardDetail(cid) {
            var str_html = template("carddetail_temp", cardList[cid]);
            $("#card-detail").empty().append(str_html);
            $("#main-page").addClass("page-bot");
            $("#card-detail").removeClass("page-top");
            CurrentSite = "card-detail";
        }

        //加载适用门店列表
        function GetCardSotre(cid) {
            LeeJSUtils.showMessage("loading", "正在加载适用门店列表...");
            $.ajax({
                type: "GET",
                timeout: 5000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: apiUrl,
                data: { ctrl: "cardsuitstore", cid: cid },
                dataType: "JSON"
            }).then(function(result) {
                if(result.code == "200") {
                    var html = "";
                    html = template("storeinfo",result);
                    if(html) {
                        $("#storeMap").empty().append(html);
                    }else {
                        $("#storeMap").empty().append('<div id="card-list"><p class="center-translate">该卡券适用所有利郎门店</p></div>');
                    }
                    
                    $(".storeLists").show();
                    $(".storeLists").removeClass("map-fadeOut").addClass("map-fadeIn");
                    CurrentSite = "store-list";
                    $(".header-title").text("适用门店列表");
                    setTimeout(function() {
                        $("#leemask").hide();
                    },500);
                }else {
                    LeeJSUtils.showMessage("error", "加载适用门店失败！");
                    setTimeout(function() {
                        $("#leemask").hide();
                    },2000);
                }
            }).fail(function() {
                LeeJSUtils.showMessage("error", "网络异常！");
                setTimeout(function() {
                    $("#leemask").hide();
                },2000);
            });//end AJAX
        }

        //创建给用户扫描的卡券二维码
        function CreateTicket() {
            var cardid = $("#card-detail").attr("cardid");
            if (cardid == "" || cardid == "0" || cardid == undefined)
                LeeJSUtils.showMessage("error", "CARDID有误！");
            else {
                LeeJSUtils.showMessage("loading", "正在生成，请稍候...");
                $.ajax({
                    type: "POST",
                    timeout: 5000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: apiUrl,
                    async: false,
                    data: { ctrl: "CreateQRcode", id: cardid, userid: userid, mdid: mdid },
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {
                            //生成成功接下来构造用户访问的URL并生成二维码 tm.lilanz.com/project/easybusiness/
                            var TGUID = msg.replace("Successed", "").replace("Warn:", "");
                            //var redirect_url = "http%3a%2f%2ftm.lilanz.com%2fqywx%2ftest%2fweixincard%2fUserGetTicket.aspx?ticket=" + TGUID + "&configkey=" + ConfigKey;                                
                            var redirect_url = "http%3a%2f%2ftm.lilanz.com%2fproject%2feasybusiness%2fUserGetTicket.aspx?ticket=" + TGUID + "&configkey=" + ConfigKey;
                            redirect_url = escape(redirect_url);
                            var img = new Image();
                            img.src = "http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" + redirect_url;
                            img.id = "qrcode";
                            img.onload = function () {
                                //$("#create-btn").addClass("disabled");
                                //用户领取时页面的数量才会-1
                                //$(".counts>span", "div [id=" + cardid + "]").text(parseInt($(".counts>span", "div [id=" + cardid + "]").text()) - 1);
                                //LeeJSUtils.showMessage("successed", "生成成功,请将下方对应的二维让客人扫！");
                                $("#leemask").hide();
                                $(".detail_qrcode img").remove();
                                $(".detail_qrcode").append(img);
                                $(".detail_qrcode").show();
                                Slide2Bottom("card-detail");
                                //alert("图像加载守毕！");
                            }
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                    }
                });//end AJAX
            }//end else
        }

        /* 生成卡券编码 */
        function CreateCardCode() {
            var cardid = $("#card-detail").attr("cardid");
            if (cardid == "" || cardid == "0" || cardid == undefined){
                LeeJSUtils.showMessage("error", "CARDID有误！");
                return;
            }

            $.ajax({
                url: apiUrl,
                type: "POST",
                data: {},
                dataType: "JSON",
                timeout: 5000
            }).then(function(data) {
                if(data.code == "200") {

                }else {
                    LeeJSUtils.showMessage("error", "生成卡券编码失败");
                    setTimeout(function() {
                        $("#leemask").hide();
                    },2000);
                }
            });
        }

        function ColorSwitch(dm) {
            var color = "";
            switch (dm) {
                case "Color010":
                    color = "#63b359";
                    break;
                case "Color020":
                    color = "#2c9f67";
                    break;
                case "Color030":
                    color = "#509fc9";
                    break;
                case "Color040":
                    color = "#5885cf";
                    break;
                case "Color050":
                    color = "#9062c0";
                    break;
                case "Color060":
                    color = "#d09a45";
                    break;
                case "Color070":
                    color = "#e4b138";
                    break;
                case "Color080":
                    color = "#ee903c";
                    break;
                case "Color081":
                    color = "#f08500";
                    break;
                case "Color082":
                    color = "#a9d92d";
                    break;
                case "Color090":
                    color = "#dd6549";
                    break;
                case "Color100":
                    color = "#cc463d";
                    break;
                case "Color101":
                    color = "#cf3e36";
                    break;
                case "Color102":
                    color = "#5E6671";
                    break;
                default:
                    color = "#63b359";
                    break;
            }

            return color;
        }

        //滚动到底部
        function Slide2Bottom(id) {
            var obj = document.getElementById(id);
            $("#" + id).animate({ scrollTop: (obj.scrollHeight - obj.clientHeight) + 'px' }, 500);
        }

        //返回函数
        function ClickBack() {
            switch (CurrentSite) {
                case "card-detail":
                    $("#main-page").removeClass("page-bot");
                    $("#card-detail").addClass("page-top");
                    $("#card-detail").attr("cardid", "0");
                    $(".detail_qrcode img").remove();
                    $(".detail_qrcode").hide();
                    ConfigKey = "";
                    CurrentSite = "index";
                    break;
                case "store-list":
                    $(".storeLists").removeClass("map-fadeIn").addClass("map-fadeOut");
                    setTimeout(function() {
                        $(".storeLists").hide();
                    },200);
                    CurrentSite = "card-detail";
                    $(".header-title").text("可用卡券列表");
                    break;
            }
        }

        //本地搜索功能
        $.expr[":"].Contains = function (a, i, m) {
            return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
        };

        function searchFunc() {
            var obj = $("#vip-list .user_infos .name");
            if (obj.length > 0) {
                var filter = $("#searchVIP").val().trim();
                if (filter) {
                    $matches = $(".user_infos").find(".name:Contains(" + filter + ")").parent().parent().parent();
                    $(".user_list li").not($matches).hide();
                    $matches.show();
                } else {
                    $(".user_list li").show();
                }
            }
        }

        function goMap(StoreIndex) {
            var url = "http://tm.lilanz.com/project/vipweixin/StoreMap.aspx?id=" + StoreIndex;
            window.location.href = url;
        }

        //分享功能
        function shareLink() {
            var sharelink = "", imgurl = "", title = "", desc = "";
            //分享到朋友圈
            wx.onMenuShareTimeline({
                title: title, // 分享标题
                link: sharelink, // 分享链接                        
                imgUrl: imgurl, // 分享图标
                success: function () {
                },
                cancel: function () {
                }
            });

            //分享给QQ好友
            wx.onMenuShareQQ({
                title: title, // 分享标题   
                desc: desc,
                link: sharelink, // 分享链接
                imgUrl: imgurl, // 分享图标
                success: function () {
                },
                cancel: function () {
                }
            });

            //分享给朋友
            wx.onMenuShareAppMessage({
                title: title, // 分享标题   
                desc: desc,
                link: sharelink, // 分享链接
                imgUrl: imgurl, // 分享图标
                type: 'link', // 分享类型,music、video或link，不填默认为link
                dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                success: function () {
                },
                cancel: function () {
                }
            });
            //分享到QQ空间
            wx.onMenuShareQZone({
                title: title, // 分享标题   
                desc: desc,
                link: sharelink, // 分享链接
                imgUrl: imgurl, // 分享图标
                success: function () {
                },
                cancel: function () {
                }
            });
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
    </script>
</body>
</html>
