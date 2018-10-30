﻿<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private const string ConfigKeyValue = "7";	//微信配置信息索引值
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
    <title>利郎轻商务</title>
    <link type="text/css" rel="stylesheet" href="../../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../../res/css/meeting/swiper-3.3.1.min.css" />
    <style type="text/css">
        .page {
            padding: 0;
        }

        .swiper-container {
            width: 100%;
            height: 100%;
        }
        .swiper-slide {
            background-color:#000;
        }
            .swiper-container img {
                width:100%;
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
                font-size:18px;
            }
        .swiper-pagination-bullet {
            background-color:#fff;
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
                    <!--<div class="swiper-slide"></div>-->
                </div>
                <!-- 如果需要分页器 -->
                <div class="swiper-pagination"></div>                
            </div>
            <p class="tips"><i class="fa fa-angle-up"></i> 上下滑动 <i class="fa fa-angle-down"></i></p>
        </div>
    </div>
    <script type="text/javascript" src="../../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../../res/js/meeting/swiper-3.3.1.jquery.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>    

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
            var imgHead = "http://tm.lilanz.com/qywx/project/easybusiness/20170313/res/img/";
            for (var i = 1; i <= 15; i++) {
                html += "<div class='swiper-slide'><img class='center-translate swiper-lazy' data-src='res/img/P" + i + ".jpg' /></div>";
                picArr.push(imgHead + "P" + i + ".jpg");
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

            $(".swiper-slide>img").click(function () {                
                //alert($(this).attr("src"));
                wx.previewImage({
                    current: imgHead + $(this).attr("src"), // 当前显示图片的http链接
                    urls: picArr // 需要预览的图片http链接列表
                });
            });
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
                jsApiList: ['previewImage', 'onMenuShareTimeline', 'onMenuShareQQ', 'onMenuShareAppMessage', 'onMenuShareQZone'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                shareLink();
            });
            wx.error(function (res) {
                alert("JS注入失败！");
            });
        }

        function shareLink() {
            var sharelink = window.location.href;
            var imgurl = "http://tm.lilanz.com/qywx/project/easybusiness/20170313/res/img/logo.jpg";
            var title = "利郎轻商务 | 一物一衣，“简”但不凡";
            var desc = "简时尚，不是轻易说说 我们拒绝繁杂的世界 一物一衣，“简”但不凡。";
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
    </script>
</body>
</html>