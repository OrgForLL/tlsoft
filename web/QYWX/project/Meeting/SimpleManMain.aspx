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
    <title>简约男人</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <style type="text/css">
        .page {
            padding: 0;
            overflow: hidden;
            background-color: #000;
        }

        .album_item {
            width: 100%;
            /*height: 16.66vh;*/
            height: 100%;
            background-repeat: no-repeat;
            background-size: cover;
            background-position: left top;
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

        .subtitle {
            font-size: 12px;
            text-align: right;            
            color: #212121;
            margin-bottom:5px;
        }


            .subtitle > span {
                background-color: #fff;
                padding: 3px 8px;                
                font-weight:bold;
                font-style:italic;
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
            <div class="album_item animated" data-ani="fadeInLeft" style="background-image: url(img/simple/thumb.jpg);" onclick="javascript:window.location.href='simplemandetail.aspx?theme=simple'">
                <div class="txts left animated fadeInUp" style="animation-delay: 1s;">
                    <p class="subtitle"><span>2017-AUTUMN</span></p>
                    <h1 class="title">利郎 简约男人</h1>
                    <p class="en">LESS IS MORE</p>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            LeeJSUtils.stopOutOfPage("#index", false);
        });

        window.onload = function () {
            var items = $(".album_item");
            for (var i = 0; i < items.length; i++) {
                $(items[i]).addClass($(items[i]).attr("data-ani"));
            }
        }
    </script>
</body>
</html>
