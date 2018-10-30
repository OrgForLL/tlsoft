<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>

<!DOCTYPE html>
<script runat="server">
    private List<string> wxConfig;//微信JS-SDK
    protected void Page_Load(object sender, EventArgs e)
    {
        string[] empstrs = { "", "", "", "" };
        wxConfig = new List<string>(empstrs);
        wxConfig = clsWXHelper.GetJsApiConfig("1");
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
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <style type="text/css">
        .page {
            padding: 0;
            background-color: #000;
            height: auto;
        }

        #main {
            text-align: center;
        }

            #main > p {
                color: #fff;
            }

        img {
            position: absolute;
            z-index: 10;
        }

        .right_hand {
            width: 4.07rem;
            right: 0;
            margin-top: 1.564rem;
        }

        .left_hand {
            width: 4.102rem;
            margin-top: 1.21rem;
            left: 0;
        }

        .center_brand {
            width: 4.97rem;
            position: relative;
            z-index: 20;
        }

        #main {
            width: 100%;
            height: 100%;
            overflow: hidden;
        }

        .container {
            width: 100%;
            visibility: hidden;
            position: relative;
        }

        .btn_wrap {
            position: absolute;
            left: 0;
            width: 100%;
            bottom: 0;
            text-align: center;
            margin-bottom: 0.2rem;
            display: none;
        }

        .btn {
            display: inline-block;
            width: 1.65rem;
            height: 0.5rem;
            line-height: 0.42rem;
            background-repeat: no-repeat;
            background-position: center center;
            background-size: cover;
            font-size: 0.24rem;
            font-weight: bold;
            color: #990000;
            background-image: url(../../res/img/ryfight/p2_btn.png);
        }

        .animated {
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

        @-webkit-keyframes bounceInRight {
            0%,100%,60%,75%,90% {
                -webkit-animation-timing-function: cubic-bezier(0.215,.61,.355,1);
                animation-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: translate3d(3000px,0,0);
                transform: translate3d(3000px,0,0);
            }

            60% {
                opacity: 1;
                -webkit-transform: translate3d(-25px,0,0);
                transform: translate3d(-25px,0,0);
            }

            75% {
                -webkit-transform: translate3d(10px,0,0);
                transform: translate3d(10px,0,0);
            }

            90% {
                -webkit-transform: translate3d(-5px,0,0);
                transform: translate3d(-5px,0,0);
            }

            100% {
                -webkit-transform: none;
                transform: none;
            }
        }

        @keyframes bounceInRight {
            0%,100%,60%,75%,90% {
                -webkit-animation-timing-function: cubic-bezier(0.215,.61,.355,1);
                animation-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: translate3d(3000px,0,0);
                transform: translate3d(3000px,0,0);
            }

            60% {
                opacity: 1;
                -webkit-transform: translate3d(-25px,0,0);
                transform: translate3d(-25px,0,0);
            }

            75% {
                -webkit-transform: translate3d(10px,0,0);
                transform: translate3d(10px,0,0);
            }

            90% {
                -webkit-transform: translate3d(-5px,0,0);
                transform: translate3d(-5px,0,0);
            }

            100% {
                -webkit-transform: none;
                transform: none;
            }
        }

        .bounceInRight {
            -webkit-animation-name: bounceInRight;
            animation-name: bounceInRight;
        }

        @-webkit-keyframes bounceInLeft {
            0%,100%,60%,75%,90% {
                -webkit-animation-timing-function: cubic-bezier(0.215,.61,.355,1);
                animation-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: translate3d(-3000px,0,0);
                transform: translate3d(-3000px,0,0);
            }

            60% {
                opacity: 1;
                -webkit-transform: translate3d(25px,0,0);
                transform: translate3d(25px,0,0);
            }

            75% {
                -webkit-transform: translate3d(-10px,0,0);
                transform: translate3d(-10px,0,0);
            }

            90% {
                -webkit-transform: translate3d(5px,0,0);
                transform: translate3d(5px,0,0);
            }

            100% {
                -webkit-transform: none;
                transform: none;
            }
        }

        @keyframes bounceInLeft {
            0%,100%,60%,75%,90% {
                -webkit-animation-timing-function: cubic-bezier(0.215,.61,.355,1);
                animation-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: translate3d(-3000px,0,0);
                transform: translate3d(-3000px,0,0);
            }

            60% {
                opacity: 1;
                -webkit-transform: translate3d(25px,0,0);
                transform: translate3d(25px,0,0);
            }

            75% {
                -webkit-transform: translate3d(-10px,0,0);
                transform: translate3d(-10px,0,0);
            }

            90% {
                -webkit-transform: translate3d(5px,0,0);
                transform: translate3d(5px,0,0);
            }

            100% {
                -webkit-transform: none;
                transform: none;
            }
        }

        .bounceInLeft {
            -webkit-animation-name: bounceInLeft;
            animation-name: bounceInLeft;
        }

        @-webkit-keyframes pulse {
            0% {
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }

            50% {
                -webkit-transform: scale3d(1.1,1.1,1.1);
                transform: scale3d(1.1,1.1,1.1);
            }

            100% {
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        @keyframes pulse {
            0% {
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }

            50% {
                -webkit-transform: scale3d(1.1,1.1,1.1);
                transform: scale3d(1.1,1.1,1.1);
            }

            100% {
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        .pulse {
            -webkit-animation-name: pulse;
            animation-name: pulse;
        }

        .mask {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0,0,0,.8);
            align-items: center;
            justify-content: center;
            z-index: 2000;
            flex-direction: column;
            color: #fff;
            display: none;
        }

            .mask > img {
                width: 1.4rem;
                margin-bottom: 0.4rem;
                animation: ani-screenTips-icon 1.6s ease-in-out 0.2s infinite forwards;
                position: relative;
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
                <div class="load_text">正在加载游戏资源（<span id="res_current"></span> / <span id="res_total"></span>）</div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        var loader = new resLoader({
            resources: ["../../res/img/ryfight/btn_five.png",
            "../../res/img/ryfight/btn_single.png", "../../res/img/ryfight/btn_switch.png",
            "../../res/img/ryfight/btn_two.png", "../../res/img/ryfight/class1.png",
            "../../res/img/ryfight/class2.png", "../../res/img/ryfight/class3.png",
            "../../res/img/ryfight/class4.png", "../../res/img/ryfight/class5.png",
            "../../res/img/ryfight/class6.png", "../../res/img/ryfight/number.png",
            "../../res/img/ryfight/p0_0.jpg", "../../res/img/ryfight/p0_1.jpg",
            "../../res/img/ryfight/p0_4.png", "../../res/img/ryfight/p1_0.jpg",
            "../../res/img/ryfight/p1_title.png", "../../res/img/ryfight/p2_bg.jpg",
            "../../res/img/ryfight/p2_btn.png", "../../res/img/ryfight/p2_center_bg.png",
            "../../res/img/ryfight/p2_left_angle.png", "../../res/img/ryfight/p2_right_angle.png",
            "../../res/img/ryfight/p2_topbanner.png", "../../res/img/ryfight/p2_wrap.png",
            "../../res/img/ryfight/p3_bg.jpg", "../../res/img/ryfight/p3_lc_m.png",
            "../../res/img/ryfight/p3_title.png", "../../res/img/ryfight/p4_bg.jpg",
            "../../res/img/ryfight/p4_bg1.png", "../../res/img/ryfight/p4_progress_bg.png",
            "../../res/img/ryfight/p5_bg.png"],
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
        <div class="page" id="main">
            <div class="container center-translate">
                <img class="left_hand animated" src="../../res/img/ryfight/p0_0.jpg" />
                <img class="center_brand animated" src="../../res/img/ryfight/p0_4.png" />
                <img class="right_hand animated" src="../../res/img/ryfight/p0_1.jpg" />
            </div>
            <div class="btn_wrap">
                <a href="main.aspx" class="btn">进入游戏</a>
            </div>
        </div>
    </div>
    <!--背景音乐-->
    <div id="bgsound_wrap" style="display:none;"><audio src="../../res/sounds/ryfight/10.mp3" id="bgmusic" autoplay="true" loop="true"></audio></div>
    
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/fastclick.min.js'></script>
    <script type='text/javascript' src='../../res/js/LeeJSUtils.min.js'></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <script type="text/ecmascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        var isFirst = true;
        var mql = window.matchMedia('(orientation: portrait)');
        function handleOrientationChange(mql) {
            setTimeout(function () {
                $(".left_hand").addClass("bounceInLeft");
                $(".right_hand").addClass("bounceInRight");
            }, 500);

            if (mql.matches) {
                console.log('portrait');  // 竖屏
            } else {
                console.log('landscape'); // 横屏
                $(".btn_wrap").show();                
            }
        }
        // 输出当前屏幕模式
        handleOrientationChange(mql);
        // 监听屏幕模式变化
        mql.addListener(handleOrientationChange);

        $(document).ready(GetWXJSApi);

        window.onload = function () {
            $(".container").css("visibility", "visible");

            $(".left_hand").on("webkitAnimationEnd", function () {
                $(".center_brand").css("visibility", "visible").addClass("pulse");
                $(this).removeClass("bounceInLeft");
            });

            $(".right_hand").on("webkitAnimationEnd", function () {
                $(this).removeClass("bounceInRight");
            });

            $(".center_brand").on("webkitAnimationEnd", function () {
                $(this).removeClass("pulse");
            });

            LeeJSUtils.stopOutOfPage("#main", false);
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
        }

        function showLoading(text) {
            $(".load_toast .load_text").text(text);
            $("#myLoading").show();
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
    </script>
</body>
</html>

