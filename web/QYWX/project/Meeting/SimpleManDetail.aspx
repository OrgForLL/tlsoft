<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
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
    <link type="text/css" rel="stylesheet" href="../../res/css/meeting/swiper-3.3.1.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
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
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/meeting/swiper-3.3.1.jquery.min.js"></script>

    <script type="text/javascript">
        var picArr = [];

        $(document).ready(function () {
            llApp.init();
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
                case "simple":
                    for (var i = 1; i <= 11; i++) {
                        html += "<div class='swiper-slide'><img class='center-translate swiper-lazy' data-src='img/simple/p" + i + ".jpg' /></div>";
                        picArr.push(imgHead + "img/simple/p" + i + ".jpg");
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
        });

        window.onload = function () {
            if (isInApp) {
                var path = window.location.href;
                path = path.substring(0, path.lastIndexOf("/") + 1);
                $(".swiper-slide>img").click(function () {
                    var csrc = $(".swiper-slide.swiper-slide-active > img").attr("src");                    
                    llApp.previewImage({
                        current: path + csrc,
                        urls: picArr
                    });
                });
            }
        }
    </script>
</body>
</html>
