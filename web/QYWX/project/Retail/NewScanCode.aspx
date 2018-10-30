<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server"> 
    public string ryid = "0";
    public string AppSystemKey = "";
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    private const string ConfigKeyValue = "1";	//微信配置信息索引值
    private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
    private string DBConstr = clsConfig.GetConfigValue("OAConnStr");
    //个人信息
    public string dzxm = "", mdid = "", mdmc = "--";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string SystemID = "3";
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            ryid = AppSystemKey;
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            else
            {
                clsWXHelper.CheckQQDMenuAuth(15);    //检查菜单权限

                mdid = Session["mdid"].ToString();
                if (string.IsNullOrEmpty(mdid)) {
                    clsWXHelper.ShowError("对不起，找不到不您的门店信息！");
                    return;
                }
                                    
                string RoleName = Convert.ToString(Session["RoleName"]);
                if (Session["RoleID"].ToString() != "2" && Session["RoleID"].ToString() != "99")
                    clsWXHelper.ShowError("对不起，您无权限使用此功能！");
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
                {
                    string sql = "select top 1 relateID,nickname from wx_t_OmniChannelUser where id='" + AppSystemKey + "'";
                    DataTable dt = null;
                    string errinfo = dal.ExecuteQuery(sql, out dt);
                    if (dt.Rows.Count == 0)
                        clsWXHelper.ShowError("");
                    else if (dt.Rows[0][0].ToString() == "0") {
                        //clsWXHelper.ShowError("对不起，找不到您对应的人资资料！");
                        if (RoleName == "my" || RoleName == "zb" || RoleName == "kf") {
                            ryid = "";
                            dzxm = Convert.ToString(Session["cname"]);
                            mdmc = "管理角色";
                        }                                                    
                    }
                    else
                    {
                        ryid = dt.Rows[0][0].ToString();
                        dzxm = dt.Rows[0][1].ToString();
                        using (LiLanzDALForXLM dal2 = new LiLanzDALForXLM(DBConstr))
                        {
                            sql = "select top 1 mdmc from t_mdb where mdid=" + mdid;
                            errinfo = dal2.ExecuteQuery(sql, out dt);
                            if (errinfo == "" && dt.Rows.Count > 0)
                                mdmc = dt.Rows[0][0].ToString();
                        }
                    }
                }//end using
            }
        }
        else
        {
            clsWXHelper.ShowError("鉴权失败！");
        }

        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
    }
</script>
<html lang="zh">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="default" />

    <title>新扫码分析</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/meeting/swiper-3.3.1.min.css" />
    <style type="text/css">
        .squart_bg {
            background: url(../../res/img/retail/squart-bg.png);
        }

        .big_bg {
            padding: 0;
        }

            .big_bg .swiper-container {
                width: 100%;
                height: 100%;
            }

            .big_bg .swiper-slide {
                background-position: 50% 50%;
                background-size: cover;
                -webkit-animation: zoom 10s ease-in-out infinite;
                animation: zoom 10s ease-in-out infinite;
            }

        .color_bg {
            background-color: rgba(0,0,0,.4);
        }

        @-webkit-keyframes zoom {
            0%,100% {
                -webkit-transform: scale(1);
                transform: scale(1);
            }

            50% {
                -webkit-transform: scale(1.1);
                transform: scale(1.1);
            }
        }

        @keyframes zoom {
            0%,100% {
                -webkit-transform: scale(1);
                transform: scale(1);
            }

            50% {
                -webkit-transform: scale(1.1);
                transform: scale(1.1);
            }
        }

        #data_page {
            background-color: transparent;
            color: #fff;
        }

        .data_container {
            background-color: rgba(255,255,255,0.4);
            border-radius: 4px;
            height: 260px;
        }

        .icon_container {
            position: absolute;
            top: 10px;
            right: 10px;
        }

            .icon_container .ip {
                width: 40px;
                height: 40px;
                background-color: rgba(0,0,0,.7);
                border-radius: 50%;
                margin-bottom: 10px;
                background-size: cover;
                background-repeat: no-repeat;
                background-image: url(../../res/img/retail/icon-spirit.png);
            }

        .basic_infos {
            position: absolute;
            left: 10px;
            width: 100%;
            bottom: 10px;
            -webkit-transform: translate3d(0, 0, 0);
            transform: translate3d(0, 0, 0);
            -webkit-transition: -webkit-transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            transition: transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
        }

        #sphh {
            font-family: "Helvetica Neue", sans-serif;
            font-size: 20px;
            font-weight: 400;
        }

        #spjg {
            font-family: "Helvetica Neue", sans-serif;
            font-size: 16px;
            font-weight: bold;
            letter-spacing: 1px;
        }

        #spgg {
            background-color: #fff;
            color: #222;
            display: inline-block;
            padding: 0 4px;
            text-align: center;
            border-radius: 2px;
            margin: 4px 0;
        }

        .clothes_datas {
            position: absolute;
            left: 0;
            bottom: 0;
            padding: 10px;
            width: 100%;
            transition: all 0.2s;
        }

        .data_ul {
            white-space: nowrap;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }

            .data_ul::-webkit-scrollbar {
                display: none;
            }

        .data_item {
            width: 120px;
            height: 140px;
            background-color: rgba(255,255,255,.7);
            display: inline-block;
            margin-right: 5px;
            border-radius: 4px;
            vertical-align: top;
            position: relative;
        }

            .data_item.same-lb {
                background-color: rgba(0,0,0,.7);
            }

            .data_item .nums.same-lb {
                color: #fff;
            }

            .data_item .nums {
                font-family: "Helvetica Neue", "微软雅黑";
                font-weight: 200;
                font-size: 60px;
                color: #333;
                text-align: center;
                line-height: 116px;
                position: relative;
                height: 116px;
            }

        .loading {
            width: 28px;
            height: 28px;
        }

        .data_item .name.same-lb {
            background-color: #222;
            color: #f0f0f0;
        }

        .data_item .name {
            position: absolute;
            left: 0;
            bottom: 0;
            width: 100%;
            text-align: center;
            color: #333;
            background-color: #f0f0f0;
            border-radius: 0 0 4px 4px;
            height: 24px;
            line-height: 24px;
        }

        .data_item .nums.fs3 {
            font-size: 50px;
        }

        .data_item .nums.fs4 {
            font-size: 40px;
        }

        .data_item .nums.fs5, .data_item .nums.fs6 {
            font-size: 34px;
            font-weight: 400;
        }

        .user_infos {
            position: absolute;
            top: 0;
            right: 55px;
            color: #fff;
            border-radius: 4px;
            background-color: rgba(0,0,0,.7);
            display: none;
        }

            .user_infos:after {
                content: '';
                position: absolute;
                width: 0;
                height: 0;
                border: 10px solid;
                border-color: transparent;
            }

        .angle-right:after {
            border-left-color: rgba(0,0,0,.7);
            left: 100%;
            top: 50%;
            margin-top: -20px;
        }

        .user_infos > p {
            padding: 5px 10px;
            white-space: nowrap;
        }

        .input_search {
            position: absolute;
            top: 50px;
            right: 0;
            -webkit-appearance: none;
            border-radius: 20px;
            height: 40px;
            border: none;
            background-color: rgba(0,0,0,.7);
            font-size: 14px;
            color: #fff;
            z-index: 100;
            width: 0;
            transition: ease-out 0.2s;
        }

        .open {
            width: 200px;
            padding: 0 50px 0 10px;
        }

        #same_ul {
            display: none;
        }

            #same_ul .nums {
                width: 100%;
                height: 100%;
                background-size: contain;
                background-repeat: no-repeat;
                background-position: center center;
                border-radius: 4px;
            }

            #same_ul .name {
                background-color: rgba(255,255,255,.8);
                text-align: center;
                height: 20px;
                line-height: 20px;
                font-size: 12px;
            }

        @-webkit-keyframes fadeInRight {
            0% {
                opacity: 0;
                -webkit-transform: translate3d(100%,0,0);
                transform: translate3d(100%,0,0);
            }

            100% {
                opacity: 1;
                -webkit-transform: none;
                transform: none;
            }
        }

        @keyframes fadeInRight {
            0% {
                opacity: 0;
                -webkit-transform: translate3d(100%,0,0);
                -ms-transform: translate3d(100%,0,0);
                transform: translate3d(100%,0,0);
            }

            100% {
                opacity: 1;
                -webkit-transform: none;
                -ms-transform: none;
                transform: none;
            }
        }

        .fadeInRight {
            -webkit-animation-name: fadeInRight;
            animation-name: fadeInRight;
        }

        .animated {
            -webkit-animation-duration: 0.8s;
            animation-duration: 0.8s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

        .moveUp150 {
            -webkit-transition: -webkit-transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            transition: transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            transform: translate(0,-150px);
            -webkit-transform: translate(0,-150px);
        }

        .moveUp295 {
            -webkit-transition: -webkit-transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            transition: transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            -webkit-transform: translate3d(0, -295px, 0);
            transform: translate3d(0, -295px, 0);
        }

        .loader {
            padding: 10px 15px 8px 15px !important;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page big_bg">
            <div class="swiper-container">
                <div class="swiper-wrapper">
                    <!--                    <div class="swiper-slide" style="background-image: url(photo3.jpg);"></div>
                    <div class="swiper-slide" style="background-image: url(photo1.jpg);"></div>
                    <div class="swiper-slide" style="background-image: url(photo2.jpg);"></div> -->
                </div>
            </div>
        </div>
        <div class="page squart_bg"></div>
        <div class="page color_bg"></div>
        <div class="page" id="data_page">
            <div class="icon_container">
                <div class="ip infomation" style="background-position: 0 0;"></div>
                <div class="ip search" style="background-position: 0 -40px; position: relative; z-index: 200;"></div>
                <div class="ip scan" style="background-position: 0 -80px;"></div>
                <input id="input_search" class="input_search" type="text" placeholder="搜索商品货号" />
                <div class="user_infos angle-right">
                    <p style="border-bottom: 1px solid #333;"><%=dzxm %></p>
                    <p><%=mdmc %></p>
                </div>
            </div>
            <div class="basic_infos">
                <p id="sphh">--</p>
                <p id="spmc">--</p>
                <p id="spgg">-</p>
                <p id="spjg">￥ -</p>
            </div>

            <!--统计数据-->
            <div class="clothes_datas" id="statics">
                <ul class="data_ul">
                    <!--同款-->
                    <li class="data_item same-lb" onclick="showSameStyle()" id="viewSameStyle">
                        <div class="center-translate" style="color: #fff; font-size: 30px; text-align: center;" id="have">
                            <p>浏览</p>
                            <p>同款</p>
                            <p style="font-size: 20px;"><i class="fa fa-angle-down"></i></p>
                        </div>
                        <div class="center-translate" style="color: #fff; font-size: 30px; text-align: center;display:none;" id="nothave">
                            <p>暂无</p>
                            <p>同款</p>                            
                        </div>
                    </li>
                    <li class="data_item">
                        <p class="nums" id="hhdysl">
                            <img class="loading center-translate" src="../../res/img/retail/loading_gif1.gif" /></p>
                        <p class="name">本月销量</p>
                    </li>
                    <li class="data_item">
                        <p class="nums" id="hhxssl">
                            <img class="loading center-translate" src="../../res/img/retail/loading_gif1.gif" /></p>
                        <p class="name">总销售量</p>
                    </li>
                    <li class="data_item">
                        <p class="nums" id="hhcgsl">
                            <img class="loading center-translate" src="../../res/img/retail/loading_gif1.gif" /></p>
                        <p class="name">总采购量</p>
                    </li>
                    <li class="data_item">
                        <p class="nums" id="hhsql">
                            <img class="loading center-translate" src="../../res/img/retail/loading_gif1.gif" /></p>
                        <p class="name">售罄率</p>
                    </li>
                    <li class="data_item">
                        <p class="nums" id="kcsl">
                            <img class="loading center-translate" src="../../res/img/retail/loading_gif1.gif" /></p>
                        <p class="name">当前库存</p>
                    </li>
                    <!--同品类数据-->
                    <li class="data_item same-lb">
                        <p class="nums same-lb" id="pldysl">
                            <img class="loading center-translate" src="../../res/img/retail/loading_gif1.gif" /></p>
                        <p class="name same-lb">同品类本月销量</p>
                    </li>
                    <li class="data_item same-lb">
                        <p class="nums same-lb" id="plxssl">
                            <img class="loading center-translate" src="../../res/img/retail/loading_gif1.gif" /></p>
                        <p class="name same-lb">同品类总销售量</p>
                    </li>
                    <li class="data_item same-lb">
                        <p class="nums same-lb" id="plcgsl">
                            <img class="loading center-translate" src="../../res/img/retail/loading_gif1.gif" /></p>
                        <p class="name same-lb">同品类总采购量</p>
                    </li>
                    <li class="data_item same-lb">
                        <p class="nums same-lb" id="plsql">
                            <img class="loading center-translate" src="../../res/img/retail/loading_gif1.gif" /></p>
                        <p class="name same-lb">同品类售罄率</p>
                    </li>
                    <li class="data_item" style="background: linear-gradient(to bottom,#ef8778,#d9534f);">
                        <p class="nums" style="color: #fff;" id="hhzb">
                            <img class="loading center-translate" src="../../res/img/retail/loading_gif1.gif" /></p>
                        <p class="name" style="background-color: transparent; color: #fff;">在同品类中占比</p>
                    </li>
                </ul>
            </div>

            <!--同款列表-->
            <div class="clothes_datas" id="same_clos" status="off">
                <ul class="data_ul animated" style="margin-top: 10px;" id="same_ul">
                    <!--<li class="data_item">
                        <p class="nums" style="background-image: url(http://webt.lilang.com:9001/MyUpload/201606QJ/6QXF051SA/6QXF051SA-01.jpg)"></p>
                        <p class="name">6QXC0051Y</p>
                    </li>-->
                </ul>
            </div>
        </div>
    </div>

    <!--同款列表模板-->
    <script type="text/html" id="sameStyel_temp">
        <li class="data_item">
            <p class="nums" style="background-image: url(http://webt.lilang.com:9001/{{picurl}})"></p>
            <p class="name">{{sphh}}</p>
        </li>
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="../../res/js/meeting/swiper-3.3.1.jquery.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript">
        var loadingData = true, isFirst = true, mySwiper;
        var mdid = "<%=mdid%>";
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        $(document).ready(function () {
            LeeJSUtils.LoadMaskInit();
            llApp.init();
            jsConfig();
        });

        window.onload = function () {
            scanQRCode();
        }

        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['hideMenuItems', 'scanQRCode'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                wx.hideMenuItems({
                    menuList: ['menuItem:share:qq', 'menuItem:share:timeline', 'menuItem:share:weiboApp', 'menuItem:share:QZone', 'menuItem:openWithSafari', 'menuItem:openWithQQBrowser', 'menuItem:share:email', 'menuItem:copyUrl'] //menuItem:share:appMessage 要隐藏的菜单项，只能隐藏“传播类”和“保护类”按钮，所有menu项见附录3
                });
                scanQRCode();
            });

            wx.error(function (res) {
                alert("JS注入失败！");
            });
        }

        //扫码入口
        function scanQRCode() {
            if (isInApp) {
                llApp.scanQRCode(function (result) {
                    var tmid = getQueryString(result, "id");
                    if (tmid == undefined || tmid == null || result.indexOf("tm.aspx") == -1) {
                        LeeJSUtils.showMessage("error", "请扫描衣服吊牌上的二维码！");                        
                    } else
                        initData(tmid);
                });
            } else {
                wx.scanQRCode({
                    needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                    scanType: ["qrCode"], // 可以指定扫二维码还是一维码，默认二者都有
                    success: function (res) {
                        var result = res.resultStr; // 当needResult 为 1 时，扫码返回的结果                    
                        var tmid = getQueryString(result, "id");
                        if (tmid == undefined || tmid == null || result.indexOf("tm.aspx") == -1) {
                            LeeJSUtils.showMessage("error", "请扫描衣服吊牌上的二维码！");
                            //scanQRCode();
                        } else
                            initData(tmid);
                    }
                });
            }
        }

        function getQueryString(url, name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            var r = url.substr(url.indexOf("?") + 1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }

        //重置上一次数据
        function resetData() {
            $("#input_search").val("");
            $("#same_ul").hide();
            $(".basic_infos").removeClass("moveUp295");
            $("#statics").removeClass("moveUp150");

            $("#viewSameStyle").children().hide();
            $("#have").show();
            $("#same_ul").empty();
            if (mySwiper != undefined)
                mySwiper.destroy();
            $("#hhdysl").html("<img class='loading center-translate' src='../../res/img/retail/loading_gif1.gif' /></p>");
            $("#hhxssl").html("<img class='loading center-translate' src='../../res/img/retail/loading_gif1.gif' /></p>");
            $("#hhcgsl").html("<img class='loading center-translate' src='../../res/img/retail/loading_gif1.gif' /></p>");
            $("#hhsql").html("<img class='loading center-translate' src='../../res/img/retail/loading_gif1.gif' /></p>");
            $("#kcsl").html("<img class='loading center-translate' src='../../res/img/retail/loading_gif1.gif' /></p>");

            $("#pldysl").html("<img class='loading center-translate' src='../../res/img/retail/loading_gif1.gif' /></p>");
            $("#plxssl").html("<img class='loading center-translate' src='../../res/img/retail/loading_gif1.gif' /></p>");
            $("#plcgsl").html("<img class='loading center-translate' src='../../res/img/retail/loading_gif1.gif' /></p>");
            $("#plsql").html("<img class='loading center-translate' src='../../res/img/retail/loading_gif1.gif' /></p>");
            $("#hhzb").html("<img class='loading center-translate' src='../../res/img/retail/loading_gif1.gif' /></p>");
        }

        //加载数据
        function initData(tm) {
            LeeJSUtils.showMessage("loading", "玩命加载中..");
            if (!isFirst)
                resetData();
            setTimeout(function () {
                loadingData = true;
                $.ajax({
                    type: "POST",
                    timeout: 15000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "ScanCodeCore.aspx",
                    data: { tm: tm, mdid: mdid, ctrl: "loadBasicInfo" },
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {                            
                            var jo = JSON.parse(msg);
                            $("#sphh").text(jo.sphh);
                            $("#spmc").text(jo.spmc);
                            $("#spgg").text(jo.cm);
                            $("#spjg").text("￥" + jo.lsdj);
                            $(".basic_infos").addClass("moveUp150");
                            //填充背景大图
                            var pics = jo.pics;
                            if (pics.length != 0) {
                                var html = "";
                                for (var i = 0; i < pics.length; i++) {
                                    html += "<div class='swiper-slide' style='background-image: url(http://webt.lilang.com:9001/" + pics[i].url.replace("../", "") + ");'></div>";
                                }//end for
                                $(".big_bg .swiper-wrapper").html(html);
                                mySwiper = new Swiper('.big_bg .swiper-container', {
                                    direction: 'horizontal',
                                    loop: true,
                                    noSwiping: true,
                                    spaceBetween: 50,
                                    autoplay: 10000
                                });                                
                            }
                            $("#leemask").hide();
                            $("#input_search").removeClass("open").val("");
                            isFirst = false;
                            staticData(jo.sphh);
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "您的网络真不给力啊..");
                    }
                });
            }, 0);
        }

        function staticData(sphh) {            
            $.ajax({
                type: "POST",
                timeout: 10000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "ScanCodeCore.aspx",
                data: { sphh: sphh, mdid:mdid, ctrl: "staticData" },
                success: function (msg) {
                    if (msg.indexOf("Error:") > -1)
                        LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                    else {
                        var jo = JSON.parse(msg);
                        //填充货号统计数据
                        $("#hhdysl").empty().addClass("fs" + jo.hhdysl.toString().length).text(jo.hhdysl);
                        $("#hhxssl").empty().addClass("fs" + jo.hhxssl.toString().length).text(jo.hhxssl);
                        $("#hhcgsl").empty().addClass("fs" + jo.hhcgsl.toString().length).text(jo.hhcgsl);

                        var kcsl = parseInt(jo.hhcgsl) + parseInt(jo.hhdbsl);
                        if (kcsl != 0) {
                            var sql = (parseInt(jo.hhxssl) * 100 / kcsl).toFixed(1) + "%";
                            $("#hhsql").empty().addClass("fs" + sql.toString().length).text(sql);
                        } else {
                            $("#hhsql").empty().text("--");
                        }
                        $("#kcsl").empty().addClass("fs" + jo.kcsl.toString().length).text(jo.kcsl);

                        //同品类统计数据                        
                        $("#pldysl").empty().addClass("fs" + jo.pldysl.toString().length).text(jo.pldysl);
                        $("#plxssl").empty().addClass("fs" + jo.plxssl.toString().length).text(jo.plxssl);
                        $("#plcgsl").empty().addClass("fs" + jo.plcgsl.toString().length).text(jo.plcgsl);

                        kcsl = parseInt(jo.plcgsl) + parseInt(jo.pldbsl);
                        if (kcsl != 0) {
                            var sql = (parseInt(jo.plxssl) * 100 / kcsl).toFixed(1) + "%";
                            $("#plsql").empty().addClass("fs" + sql.toString().length).text(sql);
                        } else {
                            $("#plsql").empty().text("--");
                        }

                        if (jo.plxssl != 0 && jo.hhxssl != 0) {
                            var hhzb = (parseInt(jo.hhxssl) * 100 / parseInt(jo.plxssl)).toFixed(2) + "%";
                            $("#hhzb").empty().addClass("fs" + hhzb.toString().length).text(hhzb);
                        } else
                            $("#hhzb").empty().text("--");

                        //处理同款数据
                        var st = jo.sameStyle;
                        if (st.length != 0) {
                            var html = "";
                            for (var i = 0; i < st.length; i++) {
                                st[i].picurl = st[i].picurl.replace("../", "");
                                html += template("sameStyel_temp", st[i]);
                            }//end for

                            $("#same_ul").empty().html(html);
                        }

                        loadingData = false;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "您的网络真不给力啊..[staticData]");
                }
            });
        }

        $(".icon_container").on("touchend", ".search", function () {
            var $this = $("#input_search");
            var val = $this.val();
            if ($this.hasClass("open")) {
                if (val == "")
                    $this.removeClass("open");
                else
                    initData(val);
            }
            else {
                $(".user_infos").fadeOut(200);
                $this.addClass("open");
            }
        });

        $(".icon_container").on("touchend", ".infomation", function () {
            $("#input_search").val("").removeClass("open");
            $(".user_infos").fadeToggle(200);
        });

        $(".icon_container").on("touchend", ".scan", function () {
            scanQRCode();
        });

        $("#same_ul").on("click", ".data_item", function () {
            var sphh = $(".name", this).text();
            var url = "http://tm.lilanz.com/oa/project/StoreSaler/goodsListV5.aspx?showType=1&sphh=" + sphh;
            window.location.href = url;
        });

        //显示同款
        function showSameStyle() {
            var status = $("#same_clos").attr("status");
            if (loadingData) {
                LeeJSUtils.showMessage("warn","统计数据中，请稍候..");
                return;
            }

            if ($("#same_ul").children().length == 0) {
                //无同款
                $("#viewSameStyle").children().hide();
                $("#nothave").show();
                return;
            }

            if (status == "off") {
                $(".basic_infos").addClass("moveUp295");
                $("#statics").addClass("moveUp150");
            } else {
                $("#same_ul").hide();
                $(".basic_infos").removeClass("moveUp295");
                $("#statics").removeClass("moveUp150");
            }
        }

        $("#statics").on("webkitTransitionEnd", function () {
            var status = $("#same_clos").attr("status");
            if (status == "off") {
                $("#same_ul").show().addClass("fadeInRight");
                $("#same_clos").attr("status", "on");
            } else {
                $("#same_clos").attr("status", "off");
            }
        });

        $("#same_clos").on("webkitAnimationEnd", function () {
            $("#same_ul").removeClass("fadeInRight");
        });
    </script>
</body>
</html>

