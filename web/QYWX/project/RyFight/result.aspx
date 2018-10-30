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
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <script type="text/javascript" src="../../res/js/remSuitable.min.js"></script>
    <script type="text/javascript" src="../../res/js/resLoader.js"></script>
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
            padding: 0.16rem 0.162rem 0.18rem 0.162rem;
        }

        .page .bg {
            width: 100%;
            height: 100%;
            display: block;
            position: relative;
            z-index: 200;
        }

        .container > div {
            z-index: 500;
        }

        .container .top {
            text-align: center;
            font-size: 0.44rem;
            line-height: 1;
            font-weight: bold;
            color: #ffce0b;
            text-shadow: 0.02rem 0.03rem 0.06rem #020d13;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .container .mid {
            flex: 1;
            display: flex;
            align-items: stretch;
            padding-top: 0.2rem;
        }

        .mid .part {
            width: 49%;
            display: flex;
            flex-direction: column;
            align-items: stretch;
        }

        .part .static {
            height: 0.429rem;
            width: 100%;
            margin-bottom: 0.08rem;
            background-repeat: no-repeat;
            background-size: 100% 100%;
            background-position: top left;
            display: flex;
            align-items: center;
            justify-content: space-around;
            flex-wrap: nowrap;
        }

        .static > span {
            align-self: flex-end;
            font-size: 0.15rem;
            padding-bottom: 0.04rem;
            white-space: nowrap;
        }

        .part .team {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .team .member {
            width: 100%;
            flex: 1;
            background-repeat: no-repeat;
            background-size: 100% 100%;
            background-position: top left;
            background-image: url(../../res/img/ryfight/p5_mem_bg.png);
            padding: 0 0.156rem;
            display: flex;
            align-items: center;
            position: relative;
        }

        .member .headimg {
            width: 0.46rem;
            min-width: 0.46rem;
            height: 0.46rem;
            border: 0.015rem solid #c6cdd9;
            background-repeat: no-repeat;
            background-position: center center;
            background-color: #00536e;
            border-radius: 0.06rem;
            margin-right: 0.1rem;
            background-size: cover;
        }

        .member .name {
            font-size: 0.16rem;
        }

        .static .name {
            font-size: 0.26rem;
            font-weight: bold;
            align-self: center;
            padding-bottom: 0;
        }

        .static.red .name {
            color: #f92635;
        }

        .static.blue .name {
            color: #33b6f4;
        }

        .member .infos {
            font-size: 0.16rem;
        }

        .infos .m_name {
            padding-bottom: 0.04rem;
        }

            .infos .m_name > span:first-child {
                font-size: 0.22rem;
                padding-right: 0.1rem;
                line-height: 1;
            }

        .infos .m_counts > span {
            padding: 0 0.07rem;
        }

        .team.red .infos .m_name > span:first-child {
            color: #f92635;
        }

        .team.blue .infos .m_name > span:first-child {
            color: #33b6f4;
        }

        .infos .rank {
            position: absolute;
            top: 0;
            right: 0.1rem;
            height: 100%;
        }

        .container .bot {
            text-align: center;
            padding: 0.06rem 0 0 0;
            font-size: 0.18rem;
            position: relative;
        }

        .bot .time {
            position: absolute;
            right: 0.2rem;
            bottom: 0;
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

        .dan_change_mask {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0,0,0,.4);
            z-index: 2002;
            display: flex;
            align-items: center;
            justify-content: center;
            display:none;
        }

        .dan_wrap .btn_close {
            position: absolute;
            top: 0.1rem;
            right: 0.1rem;
            width: 0.28rem;
            z-index: 2000;
        }

        .dan_wrap {
            width: 66%;
            height: 80%;
            display: flex;
            border-radius: 0.08rem;
            border: 1px solid rgba(255,255,255,.3);
            background-color: rgba(0,0,0,.6);
            position: relative;
        }

            .dan_wrap > div {
                width: 50%;
                height: 100%;
                padding: 0.08rem;
                text-align: center;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
            }

                .dan_wrap > div:first-child {
                    border-right: 1px solid rgba(255,255,255,.3);
                }

        .big_dan {
            height: 40%;
        }

        .dan_wrap .title {
            text-align: center;
            font-size: 0.20rem;
            font-weight: bold;
        }

        .icon_change {
            width: auto !important;
            height: 0.6rem !important;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%,-50%);
            -webkit-transform: translate(-50%,-50%);
        }

        .star_wrap {
            margin: 0.16rem 0;
        }

            .star_wrap > img {
                width: 0.32rem;
            }

        .dan_icon {
            position: absolute;
            top: 0.22rem;
            right: 0.18rem;
            width: 0.54rem;
            z-index: 2000;
        }

            .dan_icon > img {
                width: 100%;
            }

        .dan_name {
            color: #ffce0b;
            font-weight: bold;
            padding-top: 0.12rem;
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
                <div class="load_text">正在加载资源（<span id="res_current"></span> / <span id="res_total"></span>）</div>
            </div>
        </div>
    </div>
    <script type="text/javascript">
        var loader = new resLoader({
            resources: ["../../res/img/ryfight/p5_bg.png", "../../res/img/ryfight/p5_red_ribbon.png",
                "../../res/img/ryfight/p5_blue_ribbon.png", "../../res/img/ryfight/rank-1.png",
            "../../res/img/ryfight/rank-2.png", "../../res/img/ryfight/rank-3.png"],
            onStart: function (total) {
                document.getElementById("myLoading").style.display = "block";
                document.getElementById("res_total").textContent = total;
            },
            onProgress: function (current, total) {
                document.getElementById("res_current").textContent = current;
            },
            onComplete: function (total) {
                document.getElementById("myLoading").style.display = "none";
            }
        });

        loader.start();
    </script>
    <div class="wrap-page">
        <div class="page" id="result">
            <img class="bg" src="../../res/img/ryfight/p5_bg.png" />
            <div class="container">
                <div class="top">--</div>
                <div class="mid">
                    <div class="part">
                        <div class="static red" style="background-image: url(../../res/img/ryfight/p5_red_ribbon.png)">
                            <span class="name">红队</span>
                            <span class="a_mount">总金额:<span>--</span></span>
                            <span class="a_numbers">总件数:<span>--</span></span>
                            <span class="a_price">总客单价:<span>--</span></span>
                        </div>
                        <div class="team red"></div>
                    </div>
                    <div class="part" style="margin-left: 2%;">
                        <div class="static blue" style="background-image: url(../../res/img/ryfight/p5_blue_ribbon.png)">
                            <span class="a_mount">总金额:<span>--</span></span>
                            <span class="a_numbers">总件数:<span>--</span></span>
                            <span class="a_price">总客单价:<span>--</span></span>
                            <span class="name">蓝队</span>
                        </div>
                        <div class="team blue"></div>
                    </div>
                </div>
                <div class="bot">
                    <span class="share">赶快截图分享到朋友圈吧！</span>
                    <span class="time">对战时间：--</span>
                </div>
            </div>

            <!--段位变化-->
            <div class="dan_change_mask">
                <div class="dan_wrap">
                    <div class="before"></div>
                    <div class="after"></div>
                    <img class="icon_change" src="../../res/img/ryfight/icon_change2.png" />
                    <a href="javascript:;" class="btn_close">
                        <img style="width: 100%;" src="../../res/img/ryfight/btn_close.png" /></a>
                </div>
            </div>
            <div class="dan_icon">
                <img src="../../res/img/ryfight/dan_icon.png" />
            </div>
        </div>
    </div>
    <!--背景音乐-->
    <!--<div id="bgsound_wrap" style="display: none;"><audio id="bgmusic" src="../../res/sounds/ryfight/27.mp3" loop="true" autoplay="true"></audio></div>-->

    <script type="text/html" id="tpl_memItem">
        <div class="member" data-cid="{{cid}}">
            <div class="headimg" style="background-image: url({{avatar}})"></div>
            <div class="infos">
                <p class="m_name">
                    <span>{{cname}}</span>
                    <span>({{mdmc}})</span>
                </p>
                <p class="m_counts">
                    <span>金额：{{amount}}</span>
                    <span>件数：{{salecount}}</span>
                    <span>客单价：{{avgje}}</span>
                </p>
            </div>
        </div>
    </script>

    <script type="text/html" id="tpl_danchangeBefore">
        <p class="title">- 赛 前 -</p>
        <div class="star_wrap">    
            {{each starArr1}}
            <img src="../../res/img/ryfight/star1.png" />
            {{/each}}
            {{each starArr0}}
            <img src="../../res/img/ryfight/star0.png" />
            {{/each}}            
        </div>
        <img class="big_dan" src="../../res/img/ryfight/class{{origninalIcon}}.png" />
        <p class="dan_name">{{originalDanName}}</p>
        <p class="dan_points">{{originalPoints}}/{{originalLetUpPoints}}</p>
    </script>

    <script type="text/html" id="tpl_danchangeAfter">
        <p class="title">- 赛 后 -</p>
        <div class="star_wrap">    
            {{each starArr1}}
            <img src="../../res/img/ryfight/star1.png" />
            {{/each}}
            {{each starArr0}}
            <img src="../../res/img/ryfight/star0.png" />
            {{/each}}            
        </div>
        <img class="big_dan" src="../../res/img/ryfight/class{{newIcon}}.png" />
        <p class="dan_name">{{newDanName}}</p>
        <p class="dan_points">{{NewPoints}}/{{newLetUpPoints}}</p>
    </script>
    
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/fastclick.min.js'></script>
    <script type='text/javascript' src='../../res/js/LeeJSUtils.min.js'></script>
    <script type='text/javascript' src='../../res/js/template.js'></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        var bid = LeeJSUtils.GetQueryParams("bid");
        var cid = "<%=CustomerID%>";

        function loadBattleDatas() {            
            if (bid == "")
                showLoading("缺少参数【bid】！");
            else {
                showLoading("正在加载数据，请稍候..");
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        timeout: 5 * 1000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { bid: bid, cid: cid },
                        url: "supremeglory.ashx?ctrl=resultlist"
                    }).done(function (msg) {
                        console.log(msg);
                        var res = JSON.parse(msg);
                        if (res.code == "200") {
                            if (res.info.persons.length < 10) {
                                showLoading("无效数据！");
                                return;
                            }
                            var redTeam = "", blueTeam = "";
                            for (var i = 0; i < res.info.persons.length; i++) {
                                var row = res.info.persons[i];

                                if (row.fightingparty == "r") {
                                    redTeam += template("tpl_memItem", row);
                                } else if (row.fightingparty == "b") {
                                    blueTeam += template("tpl_memItem", row);
                                }
                            }//end for

                            $(".team.red").empty().html(redTeam);
                            $(".team.blue").empty().html(blueTeam);

                            var tr = $(".team.red"), tb = $(".team.blue");
                            tr.find(".member:nth-child(1) .infos").append("<img class='rank c1' src='../../res/img/ryfight/rank-1.png' />");
                            tr.find(".member:nth-child(2) .infos").append("<img class='rank c1' src='../../res/img/ryfight/rank-2.png' />");
                            tr.find(".member:nth-child(3) .infos").append("<img class='rank c1' src='../../res/img/ryfight/rank-3.png' />");

                            tb.find(".member:nth-child(1) .infos").append("<img class='rank c1' src='../../res/img/ryfight/rank-1.png' />");
                            tb.find(".member:nth-child(2) .infos").append("<img class='rank c1' src='../../res/img/ryfight/rank-2.png' />");
                            tb.find(".member:nth-child(3) .infos").append("<img class='rank c1' src='../../res/img/ryfight/rank-3.png' />");
                            $(".member[data-cid='" + cid + "']").css("background-image", "url(../../res/img/ryfight/p5_mem_bg1.png)");

                            $(".static.red .a_mount>span").text(parseInt(res.info.rje));
                            $(".static.red .a_price>span").text(parseInt(res.info.ravgje));
                            $(".static.red .a_numbers>span").text(parseInt(res.info.rsl));
                            $(".static.blue .a_mount>span").text(parseInt(res.info.bje));
                            $(".static.blue .a_price>span").text(parseInt(res.info.bavgje));
                            $(".static.blue .a_numbers>span").text(parseInt(res.info.bsl));

                            if (res.info.resultType == "lose") {
                                $(".container .top").text("失 败");
                                $(".container .top").css("color", "#f92635");
                                $(".bot .share").text("-");
                            }
                            else
                                $(".container .top").text("胜 利");

                            $(".bot .time").text("对战时间：" + res.info.bdate);
                            $("#myLoading").hide();
                        } else {
                            showLoading("加载游戏战报失败！【" + bid + "】" + res.msg);
                            setTimeout(function () {
                                window.location.href = "main.aspx";
                            }, 2000);
                        }
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        showLoading("【loadBattleDatas】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    });
                }, 80);
            }
        }

        function showLoading(text) {
            $(".load_toast .load_text").text(text);
            $("#myLoading").show();
        }

        function BindEvents() {
            $(".dan_wrap .btn_close").click(function () {
                $(".dan_change_mask").fadeOut(200);
            });

            $(".dan_icon").click(function () {
                if ($(".dan_change_mask").attr("data-load") == "1")
                    $(".dan_change_mask").css("display", "flex");
                else {
                    loadDanChange();
                }
            });
        }

        //加载段位变化
        function loadDanChange() {
            $.ajax({
                type: "POST",
                timeout: 5 * 1000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                data: { bid: bid, cid: cid },
                url: "supremeglory.ashx?ctrl=getchangereport"
            }).done(function (msg) {
                console.log(msg);
                var res = JSON.parse(msg);
                if (res.code == "200") {
                    //赛前
                    var bAll = res.info[0].originalDanStars;
                    var bCur = res.info[0].originalStars;
                    var starArr1 = [], starArr0 = [];
                    for (var i = 0; i < bCur; i++) {
                        starArr1.push("1");
                    }
                    for (var i = 0; i < bAll - bCur; i++) {
                        starArr0.push("0");
                    }

                    res.info[0].starArr1 = starArr1;
                    res.info[0].starArr0 = starArr0;                                        
                    var html = template("tpl_danchangeBefore", res.info[0]);
                    $(".dan_wrap .before").empty().html(html);

                    //赛后 
                    bAll = res.info[0].newDanStars;
                    bCur = res.info[0].NewStars;
                    starArr1 = []; starArr0 = [];
                    for (var i = 0; i < bCur; i++) {
                        starArr1.push("1");
                    }
                    for (var i = 0; i < bAll - bCur; i++) {
                        starArr0.push("0");
                    }

                    res.info[0].starArr1 = starArr1;
                    res.info[0].starArr0 = starArr0;
                    html = template("tpl_danchangeAfter", res.info[0])
                    $(".dan_wrap .after").empty().html(html);

                    $(".dan_change_mask").attr("data-load", "1");
                    $(".dan_change_mask").css("display", "flex");
                } else {
                    showLoading("加载段位变化失败！【" + bid + "】" + res.msg);
                    setTimeout(function () {
                        $("#myLoading").hide();
                    }, 2000);
                }
            }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                showLoading("【loadDanChange】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
            });
        }

        window.onload = function () {
            LeeJSUtils.stopOutOfPage("#result", false);
            loadBattleDatas();
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

            BindEvents();
        }

        $(document).ready(GetWXJSApi);

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
    </script>
</body>
</html>

