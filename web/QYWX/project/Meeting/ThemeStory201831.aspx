<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private const string ConfigKeyValue = "1";	//微信配置信息索引值
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数

    protected void Page_Load(object sender, EventArgs e)
    {
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
    }
</script>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>利郎18秋季订货主题</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <!--<link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />-->
    <style type="text/css">
        .page {
            padding: 0;
            overflow: hidden;
            background-color: #000;
        }

        .album_item {
            width: 100%;
            height: 25vh;
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center center;
            position: relative;
            color: #fff;
        }

            .album_item .mask {
                background: linear-gradient(rgba(0,0,0,0),rgba(0,0,0,0.9));
                background: -webkit-linear-gradient(rgba(0,0,0,0),rgba(0,0,0,0.9));
                position: absolute;
                height: 60%;
                width: 100%;
                right: 0;
                bottom: 0;
            }

        .txts {
            position: absolute;
            bottom: 5px;
            z-index: 100;
            text-align: center;
        }

            .txts .title {
                line-height: 1.2;
            }

            .txts.left {
                left: 10px;
            }

            .txts.right {
                right: 10px;
            }

            .txts .en {
                text-align: center;
                font-style: italic;
                font-weight: bold;
            }

        @media screen and (min-width: 600px) {
        }

        /*animate style*/
        .animated {
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
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


        @-webkit-keyframes fadeInLeft {
            0% {
                opacity: 0;
                -webkit-transform: translate3d(-100%,0,0);
                transform: translate3d(-100%,0,0);
            }

            100% {
                opacity: 1;
                -webkit-transform: none;
                transform: none;
            }
        }

        @keyframes fadeInLeft {
            0% {
                opacity: 0;
                -webkit-transform: translate3d(-100%,0,0);
                transform: translate3d(-100%,0,0);
            }

            100% {
                opacity: 1;
                -webkit-transform: none;
                transform: none;
            }
        }

        .fadeInLeft {
            -webkit-animation-name: fadeInLeft;
            animation-name: fadeInLeft;
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
                transform: translate3d(100%,0,0);
            }

            100% {
                opacity: 1;
                -webkit-transform: none;
                transform: none;
            }
        }

        .fadeInRight {
            -webkit-animation-name: fadeInRight;
            animation-name: fadeInRight;
        }

        @-webkit-keyframes fadeInRightBig {
            0% {
                opacity: 0;
                -webkit-transform: translate3d(2000px,0,0);
                transform: translate3d(2000px,0,0);
            }

            100% {
                opacity: 1;
                -webkit-transform: none;
                transform: none;
            }
        }

        @-webkit-keyframes fadeInUp {
            0% {
                opacity: 0;
                -webkit-transform: translate3d(0,100%,0);
                transform: translate3d(0,100%,0);
            }

            100% {
                opacity: 1;
                -webkit-transform: none;
                transform: none;
            }
        }

        @keyframes fadeInUp {
            0% {
                opacity: 0;
                -webkit-transform: translate3d(0,100%,0);
                transform: translate3d(0,100%,0);
            }

            100% {
                opacity: 1;
                -webkit-transform: none;
                transform: none;
            }
        }

        .fadeInUp {
            -webkit-animation-name: fadeInUp;
            animation-name: fadeInUp;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page" id="index">
            <div class="album_item animated" data-ani="fadeInRight" style="background-image: url(img/201831/thumb_dcyd.jpg); animation-delay: 0.3s;" onclick="javascript:window.location.href='ThemeDesc201831.aspx?theme=dcyd'">
                <div class="txts left animated fadeInUp" style="animation-delay: 2s;">
                    <h1 class="title">多彩动</h1>
                    <p class="en">COLORFUL SPORTS</p>
                </div>
                <div class="mask"></div>
            </div>
            <div class="album_item animated" data-ani="fadeInLeft" style="background-image: url(img/201831/thumb_jg.jpg); animation-delay: 0.6s;" onclick="javascript:window.location.href='ThemeDesc201831.aspx?theme=jg'">
                <div class="txts right animated fadeInUp" style="animation-delay: 2s;">
                    <h1 class="title">军工崛起</h1>
                    <p class="en">WAR INDUSTRY</p>
                </div>
                <div class="mask"></div>
            </div>

            <div class="album_item animated" data-ani="fadeInRight" style="background-image: url(img/201831/thumb_zgy.jpg); animation-delay: 0.9s;" onclick="javascript:window.location.href='ThemeDesc201831.aspx?theme=zgy'">
                <div class="txts left animated fadeInUp" style="animation-delay: 2s;">
                    <h1 class="title">重工艺</h1>
                    <p class="en">HEAVY CRAFT</p>
                </div>
                <div class="mask"></div>
            </div>
            <div class="album_item animated" data-ani="fadeInLeft" style="background-image: url(img/201831/thumb_gd.jpg); animation-delay: 1.5s;" onclick="javascript:window.location.href='ThemeDesc201831.aspx?theme=gd'">
                <div class="txts right animated fadeInUp" style="animation-delay: 2s;">
                    <h1 class="title">高端</h1>
                    <p class="en">HIGH END</p>
                </div>
                <div class="mask"></div>
            </div>
            <!--<div class="album_item animated" data-ani="fadeInRight" style="background-image: url(img/201811/thumb_ztsp.jpg); animation-delay: 1.8s;" onclick="javascript:lookVideos();">
                <div class="txts left animated fadeInUp" style="animation-delay:2s;">
                    <h1 class="title">主题视频</h1>
                    <p class="en">THEME VIDEOS</p>
                </div>
                <div class="mask"></div>
            </div>-->
        </div>
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="http://tm.lilanz.com/oa/api/lilanzAppWVJBridge-0.1.5.min.js?ver=07"></script>
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        $(document).ready(function () {
            LeeJSUtils.stopOutOfPage("#index", false);
            jsConfig();
            llApp.init();
        });

        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['hideMenuItems'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                wx.hideMenuItems({
                    menuList: ['menuItem:favorite', 'menuItem:share:appMessage', 'menuItem:share:qq', 'menuItem:share:timeline', 'menuItem:share:weiboApp', 'menuItem:share:QZone', 'menuItem:openWithSafari', 'menuItem:openWithQQBrowser', 'menuItem:share:email', 'menuItem:copyUrl'] // 要隐藏的菜单项，只能隐藏“传播类”和“保护类”按钮，所有menu项见附录3
                });
            });
            wx.error(function (res) {
                console.log("JS注入失败！");
            });
        }

        window.onload = function () {
            var items = $(".album_item");
            for (var i = 0; i < items.length; i++) {
                $(items[i]).addClass($(items[i]).attr("data-ani"));
            }
        }

        function lookVideos() {
            alert("敬请期待..");
            return;
            var ua = navigator.userAgent.toLowerCase();
            if (ua.match(/MicroMessenger/i) == "micromessenger") {
                window.location.href = "http://univ.lilanz.com/lspx/html/CourseDetail.html?CourseID=144";
            } else {
                if (llApp.isInApp) {
                    llApp.getAppToken(function (msg) {
                        window.location.href = "http://univ.lilanz.com/lspx/video.do?act=AppRedirect&apptoken=" + msg;
                    });
                } else {
                    alert("请在利郎微信企业号或利郎IM APP中打开！");
                }
            }
        }
    </script>
</body>
</html>
