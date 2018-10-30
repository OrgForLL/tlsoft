﻿<%@ Page Language="C#" %>

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
    <title>利郎订货会</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
        }

        .back-image {
            background-repeat: no-repeat;
            background-size: contain;
            background-position: left bottom;
        }

        .page {
            padding: 0;
            background-color: #000;
        }

        #index {
            overflow: hidden;
        }

        .theme-container {
            position: absolute;
            top: 0;
            width: 200px;
            right: 10px;
            z-index: 200;
            height: 100%;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .index-bg {
            width: 120%;
            height: 120%;
            background-position: 20% 50%;
            background-size: cover;
            position: absolute;
            top: -20px;
            left: -20px;
            z-index: 100;
        }

        .theme {
            width: 200px;
            height: 250px;
            margin: 10px 0;
            border-radius: 4px;
            position: relative;
        }

            .theme .title {
                background-color: rgba(0,0,0,.8);
                color: #fff;
                padding: 5px;
                font-weight: bold;
                position: absolute;
                left: 0;
                width: 100%;
                bottom: 0;
                border-radius: 0 0 4px 4px;
            }

        .theme-name img {
            position: absolute;
            z-index: 200;
            width: 140px;
            left: 0;
            bottom: 5px;
        }
        .videos {
            height:40px;
            line-height:40px;
            background-color:#333;
            border-radius:4px;
            text-align:center;
            padding:0 8px;
            color:#fff;
            margin-top:10px;
        }
            .videos > i {
                padding-right:10px;
            }
        @media screen and (min-width: 600px) {
            .theme {
                width: 320px;
                height: 240px;
            }

            .theme-container {
                width: 320px;
            }

            .back-image {
                background-repeat: no-repeat;
                background-size: cover;
                background-position: left bottom;
            }

            .theme-name img {
                width: 200px;
            }
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page back-image" id="index">
            <div class="theme-name">
                <img src="../../res/img/meeting/zhiyin/theme-title.png" />                
            </div>            
            <div class="index-bg back-image" style="background-image: url(../../res/img/meeting/zhiyin/bg1.jpg)"></div>
            <div class="theme-container">
                <div class="videos" onclick="javascript:window.location.href='http://univ.lilanz.com/lspx/html/CourseDetail.html?CourseID=16'"><i class="fa fa-play"></i>观看主题视频</div>
                <div class="back-image theme" style="background-image: url(../../res/img/meeting/zhiyin/clmj01.jpg)" onclick="javascript:window.location.href='ThemeDesc.aspx?theme=clmj'">
                    <p class="title">1.丛林秘境</p>
                </div>
                <div class="back-image theme" style="background-image: url(../../res/img/meeting/zhiyin/gaj01.jpg)" onclick="javascript:window.location.href='ThemeDesc.aspx?theme=gaj'">
                    <p class="title">2.古埃及</p>
                </div>
                <div class="back-image theme" style="background-image: url(../../res/img/meeting/zhiyin/gd01.jpg)" onclick="javascript:window.location.href='ThemeDesc.aspx?theme=gd'">
                    <p class="title">3.希腊神话</p>
                </div>
                <div class="back-image theme" style="background-image: url(../../res/img/meeting/zhiyin/kjgy01.jpg)" onclick="javascript:window.location.href='ThemeDesc.aspx?theme=kjgy'">
                    <p class="title">4.光影科技</p>
                </div>
                <div class="back-image theme" style="background-image: url(../../res/img/meeting/zhiyin/osjz01.jpg)" onclick="javascript:window.location.href='ThemeDesc.aspx?theme=osjz'">
                    <p class="title">5.欧式建筑</p>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        $(document).ready(function () {
            LeeJSUtils.stopOutOfPage(".theme-container", true);
            LeeJSUtils.stopOutOfPage(".index-bg", false);
            jsConfig();
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
                alert("JS注入失败！");
            });
        }
    </script>
</body>
</html>
