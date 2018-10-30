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
    <meta name="x5-page-mode" content="app">
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

        body {
            background-color: #000;
        }

        .wrap-page {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .page {
            padding: 0;
            height: 100%;
        }

        .container {
            position: relative;
            height: 100%;
        }

        .backimg {
            width: 10rem;
            height: 100%;
            display: block;
        }

        .container .content {
            padding: 0.135rem;
            width: 100%;
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            font-size: 0;
            white-space: nowrap;
            color: #fff;
        }

        .content .left {
            display: inline-block;
            width: 3.9rem;
            overflow: hidden;
            height: 100%;
        }

        .content .right {
            display: inline-block;
            font-size: 0.112rem;
            width: 5.641rem;
            margin-left: 0.167rem;
            position: relative;
            height: 100%;
            vertical-align: top;
        }

        .left .title {
            width: 100%;
            height: 13.7%;
            text-align: center;
            position: relative;
        }

        .title .ranktitle {
            height: 100%;
        }

        .title .rankswitch {
            width: 1.042rem;
            position: absolute;
            right: 0.08rem;
            bottom: 0.09rem;
        }

        .rank_title {
            width: 100%;
            height: 0.45rem;
        }

            .rank_title ul li.selected {
                color: #eec302;
            }

        .rank_list {
            display: none;
        }

            .rank_list li {
                padding: 0.08rem;
                position: relative;
                overflow: hidden;
                height: 0.749rem;
                border-bottom: 0.015rem solid #0e314b;
            }

                .rank_list li .headimg, .right .top .headimg {
                    width: 0.525rem;
                    min-width: 0.525rem;
                    height: 0.525rem;
                    border-radius: 0.03rem;
                    background-color: #00536e;
                    background-position: center center;
                    background-size: cover;
                    background-repeat: no-repeat;
                    border: 0.03rem solid #93a2af;
                    position: absolute;
                    top: 0.112rem;
                    left: 0.112rem;
                }

                .rank_list li .infos {
                    font-size: 0.16rem;
                    padding-left: 0.64rem;
                    line-height: 1;
                    display: -webkit-flex;
                    display: flex;
                    flex-direction: column;
                    justify-content: space-around;
                    height: 100%;
                    overflow: hidden;
                }

        .infos .name > span:first-child {
            font-size: 0.22rem;
            color: #eec302;
        }

        .infos .game img, .daninfo img {
            width: 0.2rem;
        }

        .rank .rank_list {
            height: 89.5%;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .rank_title li {
            width: 33.33%;
            text-align: center;
            float: left;
            font-size: 0.21rem;
            line-height: 0.45rem;
            font-weight: bold;
        }

        .right .btn_group {
            text-align: center;
            position: absolute;
            left: 0;
            bottom: 0;
            width: 100%;
            margin-bottom: 0.25rem;
        }

            .right .btn_group .btn {
                display: inline-block;
                width: 1.17rem;
            }

                .right .btn_group .btn:not(:last-child) {
                    margin-right: 0.2rem;
                }

        .btn_group .btn > img {
            width: 100%;         
        }

        .right .top {
            height: 14.96%;
            display: -webkit-flex;
            display: flex;
            align-items: center;
            background-image:url(../../res/img/ryfight/p1_right_top.png);
            background-size:100% 100%;
            margin-left:0.01rem;
        }

            .right .top .headimg {
                display: inline-block;
                vertical-align: top;
                position: initial;
                margin-left: 0.15rem;
            }

        .right {
            display: flex;
            flex-direction: column;
        }
            .right .mid {
                padding-left:0.02rem;
            }
        .right .mid > img {
            width:100%;
            display:block;
            position:relative;
            z-index:200;
        }

        .mid .mbot {
            margin-top:-0.48rem;
            z-index:199 !important;
        }

        .right .myinfos {
            height: 100%;
            line-height: 1;
            display: inline-block;
            font-size: 0.16rem;
            padding-left: 0.2rem;
            height: 0.528rem;
        }

        .myinfos > p {
            line-height: 0.262rem;
        }

        .infos .rank_icon {
            height: 100%;
            position: absolute;
            right: 0.1rem;
            top: 0;
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
            color: #fff;
            display:none;
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

            .container {
                width: 100%;
                height: auto;
                position: absolute;
                top: 50%;
                left: 50%;
                -webkit-transform: translate(-50%,-50%);
                transform: translate(-50%,-50%);
            }
        }
    </style>
    <style type="text/css">
        #myLoading {
            display: none;
        }

        .load_toast_mask, .load_toast_container, .leetip_wrap {
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

        .leetip_wrap {
            z-index: 1999;
            background-color: rgba(0,0,0,.6);
            display: flex;
            justify-content: center;
            align-items: center;
            color: #fff;
            display: none;
        }

            .leetip_wrap .leetip {
                width: 5.08rem;
                height: 3.1rem;
                background-repeat: no-repeat;
                background-size: cover;
                background-position: center center;
                display: flex;
                flex-direction: column;
                align-content: space-between;
            }

        .tiptext {
            flex: 1;
            margin-top: 0.64rem;
            font-size: 0.22rem;
            font-weight: bold;
            padding: 0.14rem 0.36rem;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .tipbtn {
            display: flex;
            justify-content: space-around;
        }

        .tip_btn {
            width: 1.2rem;
            display: inline-block;
            margin-bottom: 0.12rem;
            display: none;
        }

            .tip_btn > img {
                width: 100%;
            }

        .tipbtn.yes .confirm {
            display: inline-block;
        }

        .tipbtn.no .cancle {
            display: inline-block;
        }
    </style>
</head>
<body>
    <div class="mask">
        <img src="../../res/img/ryfight/mobile_icon.png" />
        <p>为了更好的体验，请使用横屏浏览！</p>
    </div>
    <div class="wrap-page">
        <div class="page" id="main">
            <div class="container">
                <img class="backimg" src="../../res/img/ryfight/p1_0.jpg" />
                <div class="content">
                    <div class="left">
                        <div class="title">
                            <img class="ranktitle" src="../../res/img/ryfight/p1_title.png" />
                            <img class="rankswitch" src="../../res/img/ryfight/btn_switch.png" />
                        </div>
                        <div class="rank" style="height: 86.71%;">
                            <div class="rank_title">
                                <ul class="floatfix">
                                    <li data-type="mdid" class="selected">店铺</li>
                                    <li data-type="khid">贸易公司</li>
                                </ul>
                            </div>
                            <ul class="rank_list" data-type="mdid"></ul>
                            <ul class="rank_list" data-type="khid"></ul>
                        </div>
                    </div>
                    <div class="right">
                        <div class="top">
                            <div class="headimg"></div>
                            <!--玩家用户数据-->
                            <div class="myinfos"></div>
                        </div>
                        <div class="mid" data-url="">
                            <img class="mtop" src="../../res/img/ryfight/p1_right_mid.jpg" />
                            <img class="mbot" src="../../res/img/ryfight/p1_right_mbot.png" />
                        </div>
                        <div class="bot">
                            <div class="btn_group">
                                <a class="btn" href="javascript:;" data-type="single">
                                    <img src="../../res/img/ryfight/btn_single.png" />
                                </a>
                                <a class="btn" href="javascript:;" data-type="multi">
                                    <img src="../../res/img/ryfight/btn_two.png" />
                                </a>
                            </div>
                        </div>

                        <!--显示当前用户的状态-->
                        <!--<p id="userStatus">当前状态：<span>--</span> <a href="">-点击进入-</a></p>-->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--加载提示-->
    <div class="load_toast" id="myLoading">
        <div class="load_toast_mask"></div>
        <div class="load_toast_container">
            <div class="lee_toast">
                <div class="load_img">
                    <img src="../../res/img/my_loading.gif" />
                </div>
                <div class="load_text">加载中...</div>
            </div>
        </div>
    </div>

    <!--系统提示框-->
    <div class="leetip_wrap">
        <div class="leetip" style="background-image: url(../../res/img/ryfight/tipbg.jpg)">
            <div class="tiptext">
                --                
            </div>
            <div class="tipbtn" style="text-align: center;">
                <a href="javascript:;" class="tip_btn confirm">
                    <img src="../../res/img/ryfight/tip_confirm.jpg" /></a>
                <a href="javascript:;" class="tip_btn cancle">
                    <img src="../../res/img/ryfight/tip_cancle.jpg" /></a>
            </div>
        </div>
    </div>
    <!--背景音乐-->
    <div id="bgsound_wrap" style="display: none;"></div>

    <script type="text/html" id="tpl_userinfo">
        <p>
            <span style="font-size: 0.22rem;">{{cname}} <span style="font-size: 0.16rem;">({{mdmc}})</span></span>
            <span class="daninfo" style="color: rgb(70,157,204); padding: 0 0.2rem;"><strong>段位：</strong><img src="../../res/img/ryfight/class{{icon}}.png" />
                {{danname}} (<img src="../../res/img/ryfight/star1.png" />x{{stars}})&nbsp;&nbsp;</span>
        </p>
        <p class="daninfo">
            <span>比赛场次：{{matchesNum}}</span>
            <span>胜场：{{winNum}}</span>
            <span>胜率：{{winRate}}</span>
        </p>
    </script>
    <script type="text/html" id="tpl_rankItem">
        <li>
            <div class="headimg" style="background-image: url({{avatar}})"></div>
            <div class="infos">
                <p class="name"><span>{{cname}}</span><span>（{{mdmc}}）</span></p>
                <p class="game"><span>场次：{{gameTimes}} 胜场：{{winTimes}} &nbsp;段位：<img src="../../res/img/ryfight/class{{icon}}.png" />{{danname1}} (<img src="../../res/img/ryfight/star1.png" />x{{stars}})</span></p>
                {{if rankOrder != ""}}
                <img class="rank_icon" src="../../res/img/ryfight/rank-{{rankOrder}}.png" />
                {{/if}}
            </div>
        </li>
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/fastclick.min.js'></script>
    <script type='text/javascript' src='../../res/js/LeeJSUtils.min.js'></script>
    <script type='text/javascript' src='../../res/js/template.js'></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        $(function () {
            var uid = "<%=CustomerID%>";
            var userInfo = null;
            var gameStatus = { sign_0: "组队中", sign_1: "匹配队友中", battle_0: "战斗准备中", battle_1: "战斗中", battle_2: "战斗结算中", battle_3: "战斗结束" };
            function checkUserInfo() {
                showLoading("检查用户状态..");
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        timeout: 10 * 1000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { cid: uid },
                        url: "supremeglory.ashx?ctrl=inituser"
                    }).done(function (msg) {
                        console.log(msg);
                        var res = JSON.parse(msg);
                        if (res.code == "200") {
                            userInfo = res.info;
                            window.userinfo = userInfo;
                            init();//初始化相关
                            //首页不判断用户状态
                            if (userinfo.status != "") {
                                $(".right .btn_group").hide();                                
                                var _url = "";
                                if (userinfo.status == "sign_0") {
                                    //组队中                                    
                                    if (userinfo.stype == "1")
                                        _url = "matching1.aspx";
                                    else if (userinfo.stype == "2")
                                        _url = "matching5.aspx";
                                    $(".right .mid .mtop").attr("src", "../../res/img/ryfight/teaming.gif");
                                } else if (userinfo.status == "sign_1") {
                                    //匹配中
                                    _url = "matching1.aspx";
                                    $(".right .mid .mtop").attr("src", "../../res/img/ryfight/matching.gif");
                                }                                    
                                else if (userinfo.status == "battle_0" || userinfo.status == "battle_1") {
                                    //战斗中
                                    _url = "fighting.aspx";
                                    $(".right .mid .mtop").attr("src", "../../res/img/ryfight/fighting.gif");
                                }

                                $(".right .mid").attr("data-url", _url);
                            }

                            $("#myLoading").hide();
                        } else
                            showLoading("加载用户信息失败！" + res.msg);
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        showLoading("【loadUserInfo】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    });
                }, 50);
            }

            function showUserInfo() {
                if (userInfo === null)
                    return;
                userInfo.winRate = "--%";
                if (parseInt(userInfo.matchesNum) > 0)
                    userInfo.winRate = (userInfo.winNum * 100 / userInfo.matchesNum).toFixed(2) + '%';
                var html = template("tpl_userinfo", userInfo);
                $(".right .top .headimg").css("background-image", "url(" + userInfo.headimg + ")");
                $(".top .myinfos").html(html);
            }

            function showLoading(text) {
                $(".load_toast .load_text").text(text);
                $("#myLoading").show();
            }
            window.showLoading = showLoading;

            function bindEvents() {
                $(".btn_group").on("click", ".btn", function () {
                    var type = $(this).attr("data-type");
                    if (type == "single") {
                        window.location.replace("matching1.aspx");
                    } else if (type == "multi") {
                        window.location.replace("matching5.aspx");
                    }
                });

                //排行榜切换
                $(".rank").on("click", ".rank_title li", function () {
                    var rtype = $(this).attr("data-type");
                    $(this).parent().find("li").removeClass("selected");
                    $(this).addClass("selected");
                    getRankList(rtype);
                });

                $(".right .top .headimg").click(function () {
                    window.location.href = "battlerecord.aspx?cid=" + userInfo.cid;
                });

                $(".right .mid").click(function () {
                    var url = $(this).attr("data-url");
                    if (url && url != "")
                        window.location.href = url;
                })
            };

            //加载排行榜
            function getRankList(rtype) {
                var isload = $(".rank .rank_list[data-type='" + rtype + "']").attr("data-isload");
                if (isload == "1") {
                    $(".rank .rank_list").hide();
                    $(".rank .rank_list[data-type='" + rtype + "']").show();
                }
                else {
                    $.ajax({
                        type: "POST",
                        timeout: 10 * 1000,
                        async: false,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { cid: uid, rtype: rtype },
                        url: "supremeglory.ashx?ctrl=rankinglist"
                    }).done(function (msg) {
                        console.log(msg);
                        var res = JSON.parse(msg);
                        if (res.code == "200") {
                            var html = "";
                            for (var i = 0; i < res.info.length; i++) {
                                if (i == 0 || i == 1 || i == 2)
                                    res.info[i].rankOrder = i + 1;
                                else
                                    res.info[i].rankOrder = "";
                                html += template("tpl_rankItem", res.info[i]);
                            }//end for                                
                            $(".rank .rank_list[data-type='" + rtype + "']").empty().html(html);
                            $(".rank .rank_list[data-type='" + rtype + "']").attr("data-isload", "1").show();
                            if (userInfo.status == "")
                                $("#myLoading").hide();
                        } else
                            showLoading("加载排行榜失败！" + res.msg);
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        showLoading("【getRankList】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    });
                }
            }

            function loadMusic() {
                var ele = document.createElement("audio");
                ele.id = "bgmusic";
                ele.loop = "true";
                ele.src = "../../res/sounds/ryfight/43.mp3";
                document.getElementById("bgsound_wrap").appendChild(ele);
                ele.onload = function () {
                    var music = document.getElementById("bgmusic");
                    music.play();
                }
            }

            function init() {
                showUserInfo();//显示在界面上
                bindEvents();
                getRankList("mdid");
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

            function LeeAlert(text, yescb, nocb) {
                $(".leetip .tiptext").text(text);
                var btns = $(".leetip .tipbtn");
                btns.removeClass("yes no");
                if (typeof (yescb) === 'function') {
                    btns.addClass("yes");
                    $(".tip_btn.confirm").unbind("click").click(yescb);
                }

                if (typeof (nocb) === 'function') {
                    btns.addClass("no");
                    $(".tip_btn.cancle").unbind("click").click(nocb);
                }

                $(".leetip_wrap").css("display", "flex");
            }
            window.LeeAlert = LeeAlert;

            GetWXJSApi();
            if (uid == "") {
                showLoading("没有cid！");
            } else {
                loadMusic();
                LeeAlert("欢迎来到利郎-至尊荣耀！", function () {
                    $(".leetip_wrap").hide();
                    checkUserInfo();
                });
            }
        });

        window.onload = function () {
            var ua = navigator.userAgent.toLowerCase();
            if (ua.match(/MicroMessenger/i) == "micromessenger") {
                document.addEventListener("WeixinJSBridgeReady", function () {
                    document.getElementById("bgmusic").play();
                }, false);
            } else {
                $(window).on("touchstart", function () {
                    $("#bgmusic").trigger("load").trigger("play");
                    $(this).off("touchstart");
                });
            }

            LeeJSUtils.stopOutOfPage(".left .rank_list", true);
        }
    </script>
</body>
</html>
