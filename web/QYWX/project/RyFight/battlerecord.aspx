<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<!DOCTYPE html>
<script runat="server">
    public string AppSystemKey = "", CustomerID = "";
    private List<string> wxConfig;//微信JS-SDK  
    protected void Page_Load(object sender, EventArgs e)
    {
        string[] empstrs = { "", "", "", "" };
        wxConfig = new List<string>(empstrs);
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(3));
            CustomerID = Convert.ToString(Session["qy_customersid"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您需要开通全渠道系统！您可以前往【微信】-【利郎企业平台】-【用户中心】自助开通！");
            else
                wxConfig = clsWXHelper.GetJsApiConfig("1");
        }
    }
</script>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <script type="text/javascript" src="../../res/js/remSuitable.min.js"></script>
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
            box-sizing: border-box;
        }

        ul {
            list-style: none;
        }

        a {
            text-decoration: none;
        }

        input {
            -webkit-appearance: none;
        }

        html {
            height: 100%;
        }

        body {
            height: 100%;
            color: #fff;
            background-color: #000;
            -webkit-tap-highlight-color: transparent;
            font-size: 0.112rem;
            font-family: -apple-system-font,Helvetica Neue,Helvetica,sans-serif;
        }

        .wrap-page, .page, .container {
            width: 100%;
            height: 100%;
        }

        .container {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 0.1rem;
        }

        .page .bg {
            width: 100%;
            height: 100%;
            display: block;
            position: relative;
            z-index: 200;
        }

        .floatfix {
            content: '';
            display: table;
            clear: both;
        }

        .container .content {
            width: 7.8rem;
            z-index: 201;
            background-image: url(../../res/img/ryfight/p6_bg2.png);
            flex: 1;
            background-size: 100% 100%;
            display: flex;
            padding: 0.1rem;
        }

        .backimg {
            background-repeat: no-repeat;
            background-position: center center;
            background-size: cover;
        }

        .container .top {
            height: 0.85rem;
            z-index: 201;
        }

        .btn_close {
            width: 0.38rem;
            position: absolute;
            top: 0.2rem;
            right: 0.28rem;
            z-index: 400;
        }

            .btn_close > img {
                width: 100%;
            }

        .content div {
            z-index: 202;
        }

        .content .left {
            width: 25%;
            background-image: url(../../res/img/ryfight/p6_bg_left.png);
            background-size: 100% 100%;
            padding-right: 0.1rem;
        }

        .left .topbg {
            width: 100%;
            height: 0.6rem;
            background-image: url(../../res/img/ryfight/p6_left_top.png);
            font-weight: bold;
            font-size: 0.28rem;
            text-align: center;
            line-height: 0.6rem;
            background-size: 100% 100%;
        }

        .left .menu li {
            text-align: center;
            padding: 0.14rem 0;
            font-size: 0.2rem;
            border-bottom: 1px solid #0e2a3e;
        }

            .left .menu li.active {
                color: #33b6f4;
                text-shadow: 0 0 10px #51a5bb;
            }

        .content .right {
            flex: 1;
        }

        .right {
            padding: 0 0.16rem;
            display: flex;
            flex-direction: column;
        }

            .right .head {
                display: flex;
                justify-content: space-between;
                color: #b5b9ba;
                font-size: 0.18rem;
                padding: 0.18rem 0.02rem;
                font-weight: bold;
            }

            .right .body {
                flex: 1;
                overflow-y: auto;
                -webkit-overflow-scrolling: touch;
                position: relative;
            }

            .right .no-record {
                text-align: center;
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%,-50%);
                -webkit-transform: translate(-50%,-50%);
                display: none;
            }

            .right .battle_list li {
                width: 100%;
                height: 0.75rem;
                background-image: url(../../res/img/ryfight/p6_list_bg.png);
                background-size: 100% 100%;
                margin-bottom: 0.2rem;
                display: flex;
                align-items: center;
                justify-content: space-around;
                font-size: 0.2rem;
            }

        .battle_list li .headimg {
            width: 0.525rem;
            height: 0.525rem;
            min-width: 0.525rem;
            background-color: #00536e;
            border: 1px solid #c6cdd9;
            border-radius: 0.04rem;
        }

        .battle_list .result.success {
            color: #d61535;
        }

        .battle_list .result {
            font-weight: bold;
            color: #898989;
        }

        .mask {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0,0,0,.8);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 2000;
            flex-direction: column;
            display: none;
        }

            .mask > img {
                width: 1.4rem;
                margin-bottom: 0.4rem;
                animation: ani-screenTips-icon 1.6s ease-in-out 0.2s infinite forwards;
            }

        @-webkit-keyframes ani-screenTips-icon {
            0% {
                transform: rotate(0deg);
                -webkit-transform: rotate(0deg);
            }

            40%, 60% {
                transform: rotate(90deg);
                -webkit-transform: rotate(90deg);
            }

            100% {
                transform: rotate(0deg);
                -webkit-transform: rotate(0deg);
            }
        }

        @keyframes ani-screenTips-icon {
            0% {
                transform: rotate(0deg);
                -webkit-transform: rotate(0deg);
            }

            40%, 60% {
                transform: rotate(90deg);
                -webkit-transform: rotate(90deg);
            }

            100% {
                transform: rotate(0deg);
                -webkit-transform: rotate(0deg);
            }
        }

        .mask > p {
            font-size: 0.34rem;
            font-weight: bold;
        }

        @media (orientation: portrait) {
            .mask {
                display: flex;
            }

            .page {
                width: 100%;
                height: 30vh;
                position: absolute;
                top: 50%;
                left: 50%;
                -webkit-transform: translate(-50%,-50%);
                transform: translate(-50%,-50%);
            }

            .container {
                height: 100%;
            }
        }
    </style>
    <style type="text/css">
        #myLoading {
            display: none;
        }

            #myLoading img {
                position: relative;
            }

        .load_toast_mask, .load_toast_container {
            position: fixed;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            z-index: 9999;
        }

        .load_toast_mask {
            z-index: 9998;
            background-color: rgba(37,38,45,.4);
        }

        .load_toast_container {
            -webkit-transform: translate(100%,100%);
            transform: translate(100%,100%);
        }

        .lee_toast {
            position: absolute;
            top: -50%;
            left: -50%;
            width: auto;
            display: -webkit-box;
            display: flex;
            -webkit-box-align: center;
            align-items: center;
            padding: 13px 16px;
            color: #ccc;
            background-color: rgba(37,38,45,.9);
            border-radius: 4px;
            -webkit-transform: translate(-50%,-50%);
            transform: translate(-50%,-50%);
        }

        .load_img img {
            width: 24px;
            height: 24px;
            display: block;
            margin-right: 10px;
        }

        .load_text {
            max-width: 40vw;
            max-height: 200px;
            overflow: hidden;
            font-size: 0.2rem;
        }
    </style>
</head>
<body>
    <div class="mask">
        <img src="../../res/img/ryfight/mobile_icon.png" />
        <p>为了更好的体验，请使用横屏浏览！</p>
    </div>
    <!--加载提示-->
    <div class="load_toast" id="myLoading">
        <div class="load_toast_mask"></div>
        <div class="load_toast_container">
            <div class="lee_toast">
                <div class="load_img">
                    <img src="../../res/img/my_loading.gif" />
                </div>
                <div class="load_text">正在加载..</div>
            </div>
        </div>
    </div>
    <div class="wrap-page">
        <div class="page" id="fighting">
            <img class="bg" src="../../res/img/ryfight/p6_bg.jpg" />
            <div class="container">
                <a href="javascript:WeixinJSBridge.call('closeWindow');" class="btn_close">
                    <img src="../../res/img/ryfight/btn_close.png" /></a>
                <img class="top" src="../../res/img/ryfight/p6_top.png" />
                <div class="content backimg">
                    <div class="left">
                        <div class="topbg">
                            <span>资 料</span>
                        </div>
                        <ul class="menu">
                            <!--<li>基本资料</li>
                            <li>对战资料</li>-->
                            <li class="active">历史战绩</li>
                        </ul>
                    </div>
                    <div class="right">
                        <div class="head">
                            <span>头像</span>
                            <span>结果</span>
                            <span>个人业绩</span>
                            <span>客单量</span>
                            <span>客单价</span>
                            <span>成交笔数</span>
                            <span>对战时间</span>
                        </div>

                        <div class="body">
                            <ul class="battle_list"></ul>
                            <p class="no-record">暂时无对战记录..</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/html" id="tpl_recordItem">
        <li data-bid="{{bid}}">
            <div class="headimg backimg" style="background-image:url({{avatar}})"></div>
            <span class="result {{if result == '胜利'}}success{{/if}}">{{result}}</span>
            <span class="gryj">{{amount}}</span>
            <span class="kdl">{{avgsl}}</span>
            <span class="kdj">{{avgje}}</span>
            <span class="cjbs">{{djs}}</span>
            <span class="time">{{bdate}}</span>
        </li>
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/fastclick.min.js'></script>
    <script type='text/javascript' src='../../res/js/template.js'></script>
    <script type='text/javascript' src='../../res/js/LeeJSUtils.min.js'></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript">
        (function (win, $) {
            var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
            var uid = LeeJSUtils.GetQueryParams("cid");
            uid = uid == "" ? "<%=CustomerID%>" : uid;            
            var userinfo = null;
            function showLoading(text) {
                $(".load_toast .load_text").text(text);
                $("#myLoading").show();
            }

            function checkUserStatus() {
                showLoading("正在检查用户状态..")
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        timeout: 5 * 1000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { cid: uid },
                        url: "supremeglory.ashx?ctrl=inituser"
                    }).done(function (msg) {
                        console.log(msg);
                        var res = JSON.parse(msg);
                        if (res.code == "200") {
                            userinfo = res.info;
                            loadBattleRecords();                            
                        } else
                            showLoading("加载用户游戏状态失败！" + res.msg);
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        showLoading("【checkUserStatus】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    });
                }, 50);
            }

            function loadBattleRecords() {
                showLoading("正在加载对战记录..")
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        timeout: 5 * 1000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { cid: uid },
                        url: "supremeglory.ashx?ctrl=battlerecord"
                    }).done(function (msg) {                        
                        var res = JSON.parse(msg);
                        
                        if (res.code == "200") {   
                            var rows = res.info.rows;
                            if (rows.length == 0) {
                                $(".body .no-record").show();
                            } else {
                                var html = "";
                                for (var i = 0; i < rows.length; i++) {
                                    rows[i].avatar = userinfo.headimg;
                                    rows[i].amount = rows[i].amount == 0 ? "----" : rows[i].amount;
                                    rows[i].avgje = rows[i].avgje == 0 ? "----" : rows[i].avgje;
                                    html += template("tpl_recordItem",rows[i]);
                                }//end for
                                $(".body .battle_list").empty().html(html);
                            }

                            $("#myLoading").hide();
                        } else
                            showLoading("加载对战记录失败！" + res.msg);
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        showLoading("【loadBattleRecords】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    });
                }, 100);
            }

            function bindEvents() {
                $(".body .battle_list").on("click", "li", function () {
                    var bid = $(this).attr("data-bid");
                    if (parseInt(bid) > 0) {
                        window.location.href = "result.aspx?bid=" + bid;
                    }
                })
            }

            //微信JS-SDK
            function GetWXJSApi() {
                wx.config({
                    debug: false,
                    appId: appIdVal, // 必填，公众号的唯一标识
                    timestamp: timestampVal, // 必填，生成签名的时间戳
                    nonceStr: nonceStrVal, // 必填，生成签名的随机串
                    signature: signatureVal, // 必填，签名，见附录1
                    jsApiList: ['onMenuShareTimeline', 'onMenuShareAppMessage'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
                });
                wx.ready(function () {
                    var sharelink = window.location.href.indexOf("/qywx/") > -1 ? "http://tm.lilanz.com/qywx/project/ryfight/advertise.aspx" : "http://tm.lilanz.com/oa/project/ryfight/advertise.aspx";
                    var imgurl = "http://tm.lilanz.com/qywx/res/img/ryfight/thumb.jpg";
                    var title = "利郎至尊荣耀";
                    var desc = "利郎员工福利来啦，至尊荣耀等你来玩！";
                    //分享到朋友圈
                    wx.onMenuShareTimeline({
                        title: desc, // 分享标题                    
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
                });
                wx.error(function (res) { });
            }

            $(document).ready(function () {
                checkUserStatus();
                bindEvents();
                GetWXJSApi();
            });
        }(window, jQuery))
    </script>
</body>
</html>
