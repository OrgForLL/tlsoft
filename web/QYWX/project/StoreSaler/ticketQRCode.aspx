<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private string ConfigKeyValue = "5";//利郎男装    
    public List<string> wxConfig;//微信OPEN_JS 动态生成的调用参数
    public string AppSystemKey = "", CustomerID = "", CustomerName = "", mdid = "", tzid = "";
    public int SystemID = 3;
    private string DBConstr = clsConfig.GetConfigValue("OAConnStr");
        
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            AppSystemKey = clsWXHelper.GetAuthorizedKey(SystemID);
            mdid = Convert.ToString(Session["mdid"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            else if (mdid == "" || mdid == "0")
            {
                clsWXHelper.ShowError("对不起，您无门店信息，无法使用此功能！");
            }
            else
            {
                CustomerID = Convert.ToString(Session["qy_customersid"]);
                CustomerName = Convert.ToString(Session["qy_cname"]);
                //传入参数wx_t_ActiveToken.id[tid]
                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);        
            }
        } 
    }
</script>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            line-height: 1;
            color: #363c44;
        }

        .page {
            background-color: #f2f2f2;
        }

        #index {
            padding-top: 15px;
            bottom: 40px;
        }

        .activename {
            color: #fff;
            height: 44px;
            line-height: 45px;
            padding: 0 10px;
            font-size: 16px;
            background-color: #63b359;
            border-top-left-radius: 4px;
            border-top-right-radius: 4px;
            position: relative;
        }

            .activename:before, .activetitle:before, .ticket_qrcode:before {
                content: '';
                width: 16px;
                height: 16px;
                background-color: #f2f2f2;
                position: absolute;
                bottom: -8px;
                left: -8px;
                border-radius: 50%;
            }

            .activename:after, .activetitle:after, .ticket_qrcode:after {
                content: '';
                width: 16px;
                height: 16px;
                background-color: #f4f4f4;
                position: absolute;
                bottom: -8px;
                right: -8px;
                border-radius: 50%;
            }

        .activetitle {
            padding: 10px;
            position: relative;
            border-bottom: 1px dashed #ccc;
        }

            .activetitle > h1 {
                text-align: center;
                padding:5px 10px 10px 10px;
            }

            .activetitle .time {
                text-align: center;
                font-size: 12px;
                color: #888;
            }

        .ticket_qrcode {
            text-align: center;
            padding: 0 10px 15px 10px;
            border-bottom: 1px dashed #ddd;
            position: relative;
        }

            .ticket_qrcode .title {
                padding: 7px 0 5px 0;
                font-weight: bold;
                text-align: center;
                color: #cc463d;
                line-height: 1.4;
            }

        .img_qrcode {
            width: 44vw;
            padding: 8px;
            border: 1px solid #eee;
            margin-bottom: 10px;
        }

        .ticket_detail {
            padding: 10px;
            border-bottom-left-radius: 4px;
            border-bottom-right-radius: 4px;
        }

            .ticket_detail .title {
                font-weight: bold;
                padding-bottom: 10px;
                border-bottom: 1px solid #f0f0f0;
            }

        .info_item {
            padding-top: 10px;
            display: -webkit-box;
            display: -webkit-flex;
            display: flex;
        }

            .info_item .label {
                width: 120px;
            }

            .info_item .infos {
                -webkit-box-flex: 1;
                -webkit-flex: 1;
                flex: 1;
                line-height: 1.2;
            }

        .remark > span {
            background-color: #63b359;
            color: #fff;
            padding: 4px 10px;
            border-radius: 4px;
            font-weight: 600;
        }

        .footer {
            height: 40px;
            line-height: 41px;
            background-color: #fff;
            font-weight: 600;
            font-size: 16px;
            border-top:1px solid #eee;
        }

            .footer > i {
                font-size: 20px;
            }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page page-not-footer" id="index">
            <div class="ticket_wrap" style="background-color: #fff; border-radius: 4px;">
                <div class="activename">--</div>
                <div class="activetitle">
                    <h1>--</h1>
                    <p class="time">有效期：<span>--</span></p>
                </div>
                <div class="ticket_qrcode">
                    <p class="title">请客人使用微信“扫一扫”<br />
                        扫描下方二维码</p>
                    <img src="" class="img_qrcode" />
                    <p class="remark">
                        <span>--</span>
                    </p>
                </div>
                <div class="ticket_detail">
                    <p class="title">礼券详情</p>
                    <div class="info_item" data-col="createtime">
                        <div class="label">创建时间：</div>
                        <div class="infos">--</div>
                    </div>
                    <div class="info_item" data-col="maxreceive">
                        <div class="label">限定领取人数：</div>
                        <div class="infos">--</div>
                    </div>
                    <div class="info_item" data-col="validtime">
                        <div class="label">有效期：</div>
                        <div class="infos">--</div>
                    </div>
                    <div class="info_item" data-col="getcounts" style="font-weight:bold;color:#63b359; border-top:1px dashed #ddd;margin-top:10px;">
                        <div class="label">已领取人数：</div>
                        <div class="infos">--</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="footer">
        <i class="fa fa-angle-left"></i>
        返 回
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>    
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
//        var mdid = "<%=mdid%>";

        $(document).ready(function () {
            jsConfig();
            LeeJSUtils.LoadMaskInit();
            BindEvents();
            init();
        });

        //微信JS-SDK
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
                    menuList: ['menuItem:share:appMessage', 'menuItem:share:qq', 'menuItem:share:timeline', 'menuItem:share:weiboApp', 'menuItem:share:QZone', 'menuItem:openWithSafari', 'menuItem:openWithQQBrowser', 'menuItem:share:email', 'menuItem:copyUrl'] //menuItem:share:appMessage 要隐藏的菜单项，只能隐藏“传播类”和“保护类”按钮，所有menu项见附录3
                });
            });

            wx.error(function (res) {
                console.log("微信JS-SDK注册失败！");
            });
        }

        function init() {
            var tid = LeeJSUtils.GetQueryParams("tid");
            if (tid == "" || tid == "0")
                LeeJSUtils.showMessage("error", "请检查传入的参数!");
            else {
                LeeJSUtils.showMessage("loading", "正在加载..");
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        cache: false,
                        timeout: 10 * 1000,
                        data: { id:tid, mdid:mdid },
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=LoadTokenInfo",
                        success: function (msg) {
                            console.log(msg);
                            if (msg.indexOf("Error:") > -1)
                                LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                            else {
                                var data = JSON.parse(msg);
                                if (data.list.length == 0)
                                    LeeJSUtils.showMessage("warn", "请检查参数! tid");
                                else {
                                    var row = data.list[0];
                                    $(".activename").text(row.ActiveName);
                                    $(".activetitle>h1").text(row.TokenName);
                                    $(".time>span").text(row.ValidTimeBegin + " 至 " + row.ValidTimeEnd);
                                    $(".remark>span").text(row.Remark);
                                    if (row.MaxReceiveCount == "0")
                                        $(".info_item[data-col='maxreceive'] .infos").text("不限");
                                    else
                                        $(".info_item[data-col='maxreceive'] .infos").text(row.MaxReceiveCount);

                                    $(".info_item[data-col='validtime'] .infos").text(row.ValidTimeBegin + " 至 " + row.ValidTimeEnd);
                                    $(".info_item[data-col='getcounts'] .infos").text(row.GetTokenCount);
                                    $(".info_item[data-col='createtime'] .infos").text(row.CreateTime);

                                    //生成二维码
                                    var codeURL = "http://tm.lilanz.com/project/vipweixin/getTicketResult.aspx?tid=" + tid;
                                    codeURL = encodeURIComponent(codeURL);
                                    $(".img_qrcode").attr("src", "http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" + codeURL);
                                    
                                    $("#leemask").hide();
                                }
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {                            
                            LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                        }
                    });
                }, 50);
            }
            
            //var codeURL = "http://tm.lilanz.com/project/vipweixin/getGiftResult.aspx?pid=1";
        }

        function BindEvents() {
            $(".footer").click(function () {
                window.history.go(-1);
            });
        }
    </script>
</body>
</html>
