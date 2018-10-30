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
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/meeting/swiper-3.3.1.min.css" />
    <style type="text/css">
        .page {
            padding: 0;
        }

        .swiper-container {
            width: 100%;
            height: 100%;
        }

        .swiper-slide {
            background-color: #000;
        }

        .swiper-container img {
            width: 100%;
        }

        #index .tips {
            color: #fff;
            position: absolute;
            bottom: 10px;
            left: 0;
            width: 100%;
            text-align: center;
            z-index: 100;
            font-weight: bold;
            -webkit-animation-timing-function: ease-in-out; /*动画时间曲线*/
            -webkit-animation-name: breathe; /*动画名称，与@keyframes搭配使用*/
            -webkit-animation-duration: 800ms; /*动画持续时间*/
            -webkit-animation-iteration-count: infinite; /*动画要重复次数*/
            -webkit-animation-direction: alternate; /*动画执行方向，alternate 表示反复*/
        }

            #index .tips i {
                font-size: 18px;
            }

        .swiper-pagination-bullet {
            background-color: #fff;
        }

        @-webkit-keyframes breathe {
            0% {
                opacity: .1;
            }

            100% {
                opacity: 1;
            }
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page" id="index">
            <div class="swiper-container">
                <div class="swiper-wrapper">
                </div>
                <!-- 如果需要分页器 -->
                <div class="swiper-pagination"></div>
            </div>
            <p class="tips"><i class="fa fa-angle-up"></i>上下滑动 <i class="fa fa-angle-down"></i></p>
        </div>

        <!--背景音乐-->
        <div id="bgsound_wrap" style="display:none;"></div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/meeting/swiper-3.3.1.jquery.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="http://tm.lilanz.com/oa/api/lilanzAppWVJBridge-0.1.5.min.js?ver=07"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            window.onorientationchange = function () {
                if (window.orientation == 0) {
                    $(".swiper-container img").css("width", "100%").css("height", "auto");
                } else {
                    $(".swiper-container img").css("width", "auto").css("height", "100%");
                }
            }
            var html = "", theme = LeeJSUtils.GetQueryParams("theme");
            var imgHead = "http://tm.lilanz.com/oa/project/meeting/";
            switch (theme) {
                case "dcyd":
                    for (var i = 1; i <= 32; i++) {
                        html += "<div class='swiper-slide'><img class='center-translate swiper-lazy' data-src='img/201831/dcyd/p" + i + ".jpg' /></div>";
                        picArr.push(imgHead + "img/201831/dcyd/p" + i + ".jpg");
                    }                    
                    break;
                case "jg":
                    for (var i = 1; i <= 32; i++) {
                        html += "<div class='swiper-slide'><img class='center-translate swiper-lazy' data-src='img/201831/jg/p" + i + ".jpg' /></div>";
                        picArr.push(imgHead + "img/201831/jg/p" + i + ".jpg");
                    }                    
                    break;
                case "gd":
                    for (var i = 1; i <= 21; i++) {
                        html += "<div class='swiper-slide'><img class='center-translate swiper-lazy' data-src='img/201831/gd/p" + i + ".jpg' /></div>";
                        picArr.push(imgHead + "img/201831/gd/p" + i + ".jpg");
                    }
                    break;
                case "zgy":
                    for (var i = 1; i <= 30; i++) {
                        html += "<div class='swiper-slide'><img class='center-translate swiper-lazy' data-src='img/201831/zgy/p" + i + ".jpg' /></div>";
                        picArr.push(imgHead + "img/201831/zgy/p" + i + ".jpg");
                    }                    
                    break;
            }

            if (html != "") {
                $(".swiper-wrapper").append(html);
                var mySwiper = new Swiper('.swiper-container', {
                    lazyLoading: true,
                    direction: 'vertical',
                    loop: true,
                    // 如果需要分页器
                    pagination: '.swiper-pagination'
                });
            }

            jsConfig();
            llApp.init();
            loadMusic(theme);
        });
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var picArr = [];
        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['hideMenuItems', 'previewImage'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
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
            var ua = navigator.userAgent.toLowerCase();
            var imgHead = "http://tm.lilanz.com/oa/project/meeting/";
            $(".swiper-slide>img").click(function () {
                if (llApp.isInApp) {
                    llApp.previewImage({
                        current: imgHead + $(this).attr("src"),
                        urls: picArr
                    });
                } else {
                    wx.previewImage({
                        current: imgHead + $(this).attr("src"), // 当前显示图片的http链接
                        urls: picArr // 需要预览的图片http链接列表
                    });
                }
            });

            //如果是在APP或微信中直接进入浏览模式
            if (llApp && llApp.isInApp) {
                //$(".swiper-slide>img")[0].click();
            } else if (ua.match(/MicroMessenger/i) == "micromessenger") {
                document.addEventListener("WeixinJSBridgeReady", function () {
                    $(".swiper-slide>img")[0].click();
                }, false);
            }
            
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

        window.onbeforeunload = function () {
            $("#bgmusic").trigger("pause");
        }

        function loadMusic(theme) {
            var ele = document.createElement("audio");
            ele.id = "bgmusic";
            ele.loop = "true";
            ele.autoplay = "true";
            ele.src = "./bgsound/201831/bg_" + theme + ".mp3";            
            document.getElementById("bgsound_wrap").appendChild(ele);
            ele.onload = function () {
                var music = document.getElementById("bgmusic");
                music.play();                
            }
        }
    </script>
</body>
</html>
