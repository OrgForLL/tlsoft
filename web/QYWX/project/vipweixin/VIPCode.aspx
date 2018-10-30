﻿<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private String ConfigKeyValue = clsConfig.GetConfigValue("CurrentConfigKey"); //取配置BLL.config
    public string mdmc = "", vipno = "", headimg = "",vipname="";
    private string DBConStr = clsConfig.GetConfigValue("OAConnStr");
                       
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "vipid")) {
            string _VID = Convert.ToString(Session["vipid"]);
            if (_VID == "" || _VID == "0" || _VID == null)
            {
                Response.Redirect("JoinUS.aspx");
                return;
            }
            else
            {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
                {
                    string _objectid = ConfigKeyValue == "5" ? "1" : "4";
                    string _sql = @"declare @headimg varchar(400);
                            select top 1 @headimg=a.wxheadimgurl from wx_t_vipbinging a where a.vipid='{0}' and a.objectid='{1}';
                            select top 1 isnull(md.khmc,'')+'|'+a.kh+'|'+isnull(@headimg,'')+'|'+a.xm
                            from yx_t_vipkh a 
                            left join yx_t_khb md on a.khid=md.khid
                            where a.id='{0}'";
                    _sql = string.Format(_sql, _VID, _objectid);
                    object scalar;
                    string errinfo = dal.ExecuteQueryFast(_sql,out scalar);
                    if (errinfo == "")
                    {
                        string str = Convert.ToString(scalar);
                        if (str != "") {
                            mdmc = str.Split('|')[0];
                            mdmc = mdmc == "" ? "--" : mdmc;
                            vipno = str.Split('|')[1];
                            headimg = str.Split('|')[2].Replace("\\", "");
                            vipname = str.Split('|')[3];
                            if (clsWXHelper.IsWxFaceImg(headimg))
                                //是微信头像
                                headimg = clsWXHelper.GetMiniFace(headimg);
                            else
                                headimg = clsConfig.GetConfigValue("VIP_WebPath") + headimg;

                            headimg = headimg == "" ? "../img/lilanzlogo.jpg" : headimg;
                        }
                    }
                    else
                        clsSharedHelper.WriteErrorInfo(errinfo);
                }//end using
            }        
        }        
    }
</script>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../css/font-awesome.min.css" />
    <style type="text/css">
        body {
            line-height: 1;
            color: #fff;
        }

        .page {
            background-color: #282828;
        }

        .footer {
            height: 50px;
            background-color: #282828;
            line-height: 50px;
            font-size: 16px;
            font-weight: bold;
        }

        .page-not-footer {
            bottom: 50px;
            padding: 15px 10px;
        }

            .footer i {
                font-size: 18px;
                margin-right: 20px;
            }

        .card {
            width: 100%;
            max-width: 500px;
            margin: 0 auto;
            display: none;
        }

        .card_top {
            height: 90px;
            background-color: #aba198;
            border-top-left-radius: 4px;
            border-top-right-radius: 4px;
            box-shadow: 0px -5px 10px #989189 inset;
            position: relative;
        }

        .card_bot {
            background-color: #fff;
            text-align: center;
            border-bottom-left-radius: 4px;
            border-bottom-right-radius: 4px;
        }

        #tmcode {
            width: 88%;
            margin: 15px 0;
        }

        #qrcode {
            width: 54%;
            margin: 15px 0;
            background-color: #fff;
            padding: 10px;
        }

        .qr_container {
            border-bottom-left-radius: 4px;
            border-bottom-right-radius: 4px;
            background-color: #f6f6f8;
        }

        .tips {
            color: #999;
            padding-bottom: 10px;
        }

        .back-image {
            background-repeat: no-repeat;
            background-size: cover;
            background-position: 50% 50%;
        }

        .headimg-out {
            width: 74px;
            height: 74px;
            border: 2px solid #958880;
            border-radius: 50%;
            position: absolute;
            top: 8px;
            left: 10px;
        }

        .headimg-inner {
            width: 62px;
            height: 62px;
            border-radius: 50%;
            position: absolute;
            top: 14px;
            left: 16px;
        }

        .user-info {
            position: absolute;
            top: 50%;
            left: 94px;
            right:12px;
            transform: translate(0,-50%);
            overflow: hidden;
        }

            .user-info #username {
                font-size: 20px;
                font-weight: bold;
                color: #fff;
                margin-bottom: 10px;
            }

            .user-info p {
                color: #f0f0f0;
                white-space:nowrap;
                overflow:hidden;
                text-overflow:ellipsis;
            }

        #store {
            margin-bottom: 5px;
        }

        /*animation*/
        @-webkit-keyframes flipInY {
            0% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,90deg);
                transform: perspective(400px) rotate3d(0,1,0,90deg);
                -webkit-transition-timing-function: ease-in;
                transition-timing-function: ease-in;
                opacity: 0;
            }

            40% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,-20deg);
                transform: perspective(400px) rotate3d(0,1,0,-20deg);
                -webkit-transition-timing-function: ease-in;
                transition-timing-function: ease-in;
            }

            60% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,10deg);
                transform: perspective(400px) rotate3d(0,1,0,10deg);
                opacity: 1;
            }

            80% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,-5deg);
                transform: perspective(400px) rotate3d(0,1,0,-5deg);
            }

            100% {
                -webkit-transform: perspective(400px);
                transform: perspective(400px);
            }
        }

        @keyframes flipInY {
            0% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,90deg);
                -ms-transform: perspective(400px) rotate3d(0,1,0,90deg);
                transform: perspective(400px) rotate3d(0,1,0,90deg);
                -webkit-transition-timing-function: ease-in;
                transition-timing-function: ease-in;
                opacity: 0;
            }

            40% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,-20deg);
                -ms-transform: perspective(400px) rotate3d(0,1,0,-20deg);
                transform: perspective(400px) rotate3d(0,1,0,-20deg);
                -webkit-transition-timing-function: ease-in;
                transition-timing-function: ease-in;
            }

            60% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,10deg);
                -ms-transform: perspective(400px) rotate3d(0,1,0,10deg);
                transform: perspective(400px) rotate3d(0,1,0,10deg);
                opacity: 1;
            }

            80% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,-5deg);
                -ms-transform: perspective(400px) rotate3d(0,1,0,-5deg);
                transform: perspective(400px) rotate3d(0,1,0,-5deg);
            }

            100% {
                -webkit-transform: perspective(400px);
                -ms-transform: perspective(400px);
                transform: perspective(400px);
            }
        }

        .flipInY {
            -webkit-backface-visibility: visible!important;
            -ms-backface-visibility: visible!important;
            backface-visibility: visible!important;
            -webkit-animation-name: flipInY;
            animation-name: flipInY;
        }

        .animated {
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page page-not-footer" id="main">
            <div class="card animated">
                <div class="card_top">
                    <div class="back-image headimg-out"></div>
                    <div class="back-image headimg-inner" style="background-image: url(<%=headimg%>)"></div>
                    <div class="user-info">
                        <p id="username"><%=vipname %></p>
                        <p id="store"><strong>所属门店：</strong><span><%=mdmc %></span></p>
                        <p id="cardno"><strong>会员卡号：</strong><span><%=vipno %></span></p>
                    </div>
                </div>
                <div class="card_bot">
                    <div class="qr_container">
                        <p class="tips">尊敬的会员，使用时请向服务员出示</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="footer">
        <i class="fa fa-arrow-left"></i>返回
    </div>
    <script type="text/javascript" src="../js/jquery.js"></script>
    <script type="text/javascript" src="../js/LeeJSUtils.min.js"></script>
    <script type="text/ecmascript">
        var code = "<%=vipno%>";
        $(".footer").on("touchend", function () {
            window.history.go(-1);
        });

        $(document).ready(function () {
            LeeJSUtils.LoadMaskInit();
            LeeJSUtils.stopOutOfPage("#main", true);            
            LeeJSUtils.stopOutOfPage(".footer", false);
            //LeeJSUtils.showMessage("loading","正在加载...");
            InitPage();
        });

        function InitPage() {
            LeeJSUtils.showMessage("loading", "开始加载条码信息...");
            setTimeout(function () {                
                var tmimg = new Image();
                //加载条形码
                tmimg.src = "http://tm.lilanz.com/oa/project/StoreSaler/GetBarCode.aspx?code=" + code;
                tmimg.id = "tmcode";
                tmimg.onload = function () {
                    $(".card_bot").prepend(tmimg);
                    tmimg = null;
                    LoadQrCode();
                }

                tmimg.onerror = function () {
                    LeeJSUtils.showMessage("error", "网络太不给力了，请重试...");
                    LoadQrCode();
                }
            }, 200);
        }

        function LoadQrCode() {
            LeeJSUtils.showMessage("loading", "正在加载条码信息...");
            setTimeout(function () {
                //加载二维码                
                var qrimg = new Image();
                qrimg.src = "http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" + code;
                qrimg.id = "qrcode";
                qrimg.onload = function () {
                    $(".qr_container").prepend(qrimg);
                    qrimg = null;
                    ReCardSite();
                    $("#leemask").hide();
                    $(".card").show().addClass("flipInY");
                }

                qrimg.onerror = function () {
                    $("#leemask").hide();
                    $(".card").show().addClass("flipInY");
                    LeeJSUtils.showMessage("error", "网络太不给力了，请重试...");
                }
            }, 200);
        }

        function ReCardSite() {
            var ph = parseInt($("#main").css("height").replace("px", ""));
            var ch = parseInt($(".card").css("height").replace("px", ""));
            if (ph > ch) {
                var nh = parseInt(ph / 2 - ch / 2);
                $(".card").css("margin-top", nh + "px");
            }
        }
    </script>
</body>
</html>