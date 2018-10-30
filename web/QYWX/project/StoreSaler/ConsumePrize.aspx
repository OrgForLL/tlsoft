<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>

<!DOCTYPE html>
<script runat="server"> 
    public string CustomerID = "", CustomerName = "";    
    private string DBConstr = clsConfig.GetConfigValue("OAConnStr");
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数
    private string ConfigKeyValue = "1";//利郎企业号
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true)) {
            CustomerID = Convert.ToString(Session["qy_customersid"]);
            CustomerName = Convert.ToString(Session["qy_cname"]);
            wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
        }        
    }    
</script>
<html>
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta content="yes" name="apple-mobile-web-app-capable">
    <meta content="yes" name="apple-touch-fullscreen">
    <meta content="telephone=no,email=no" name="format-detection">
    <title>活动奖品发放</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <style type="text/css">
        .footer {
            background-color: #d53c3e;
        }

        #index {
            background-color: #d53c3e;
        }

        .block {
            background-color: #fff;
            border-radius: 4px;
            padding: 0 10px;
            line-height: 1;
            position: relative;
        }

        .prize_list {
            margin-top: 10px;
        }

        .user_info {
            background-color: transparent;
            position: relative;
        }

        .back-image {
            background-position: center center;
            background-repeat: no-repeat;
            background-size: cover;
        }

        .headimg {
            width: 50px;
            height: 50px;
            position: absolute;
            top: 5px;
            left: 10px;
            border-radius: 50%;
            border: 2px solid #fff;
        }

        .username {
            font-size: 18px;
            line-height: 60px;
            font-weight: 600;
            width: 100%;
            padding-left: 60px;
            color: #fff;
        }

        .prize_item {
            border-bottom: 1px solid #f0f0f0;
            padding: 10px 0;
            position: relative;
        }

        .activename {
            margin-bottom: 10px;
            color: #d53c3e;
            font-style: italic;
        }

        .prizename {
            font-size: 20px;
            font-weight: bold;
            line-height: 30px;
            letter-spacing: 1px;
        }

        .prizetime {
            font-size: 12px;
            margin-top: 10px;
        }

        .gettime {
            font-size: 12px;
            margin-top: 5px;
            color: #ec6941;
        }

        .footer {
            font-size: 0;
            padding: 10px;
            font-weight: 600;
        }

        .btn {
            display: inline-block;
            width: 100%;
            height: 40px;
            line-height: 40px;
            font-size: 15px;
            border-radius: 4px;
            background-color: #159846;
            color:#fff;
            letter-spacing:1px;
            display:none;
        }

        .btn_exchange {
            position: absolute;
            top: 16px;
            right: 0;
            bottom: 16px;
            width: 60px;
            background-color: #ec6941;
            color: #fff;
            display: flex;
            text-align: center;
            border-radius: 4px;
            flex-direction: column;
            justify-content: space-around;
        }

        .hasget {
            margin-top: 25px;
        }

            .hasget .btn_exchange {
                background-color: #ccc;
            }

        .btn_scan {
            display: inline-block;
            background-color: #fff;
            padding: 0 15px;
            border-radius: 4px;
            position: absolute;
            top: 0;
            right: 0;
            height: 30px;
            line-height: 30px;
            color: #159846;
            margin-top: 15px;
        }

            .btn_scan > img {
                width: 20px;
                height: 20px;
                vertical-align: middle;
            }

        .no_result {
            color: #fff;
            white-space: nowrap;
            display: none;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page page-not-footer" id="index">
            <div class="block user_info">
                <div class="headimg back-image" style="background-image: url(../../res/img/headImg.jpg)"></div>
                <p class="username">--</p>
                <a href="javascript:scanQRCode();" class="btn_scan">
                    <img src="../../res/img/storesaler/scan.png" />
                    <span>立即扫描</span>
                </a>
            </div>
            <!--未领取列表-->
            <div class="block prize_list noget">
            </div>

            <!--已经领取列表-->
            <div class="block prize_list hasget">
            </div>
            <p class="no_result center-translate">对不起，该顾客尚未有任何奖品..</p>
        </div>
    </div>
    <div class="footer">
        <a href="javascript:payPrizeAll();" class="btn btn_get">全部发放</a>
    </div>

    <script type="text/html" id="tmp_prize_item0">
        <div class="prize_item" data-token="{{GameToken}}">
            <p class="activename">{{GameName}}</p>
            <p class="prizename">{{PrizeName}}</p>
            <p class="prizetime">中奖时间：{{CreateTime}}</p>
            <a href="javascript:payPrizeOne('{{GameToken}}')" class="btn_exchange">
                <span>马 上</span>
                <span>发 放</span>
            </a>
        </div>
    </script>

    <script type="text/html" id="tmp_prize_item1">
        <div class="prize_item" data-token="{{GameToken}}">
            <p class="activename">{{GameName}}</p>
            <p class="prizename">{{PrizeName}}</p>
            <p class="prizetime">中奖时间：{{CreateTime}}0</p>
            <p class="gettime">领取时间：{{GetTime}}</p>
            <a href="javascript:" class="btn_exchange">
                <span>已 经</span>
                <span>领 取</span>
            </a>
        </div>
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        //userinfos
        var wxid = "", wxopenid = "", usertoken = "";

        $(document).ready(function () {
            FastClick.attach(document.body);
            LeeJSUtils.LoadMaskInit();
            wxConfig();
        });

        //发放单个奖品
        function payPrizeOne(gametoken) {
            if (isProcessing)
                return;
            if (confirm("确认发放该奖品，该动作无法撤消！")) {
                isProcessing = true;
                LeeJSUtils.showMessage("loading", "正在处理，请稍候..");
                setTimeout(function () {
                    $.ajax({
                        url: "wxGetPrizeCore.ashx?ctrl=payPrizeOne",
                        type: "POST",
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { wxId:wxid, GameToken:gametoken },
                        dataType: "text",
                        timeout: 10 * 1000,
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                            isProcessing = false;
                        },
                        success: function (msg) {
                            if (msg.indexOf("Error:") > -1) {
                                LeeJSUtils.showMessage("error", msg.replace("Error:", ""));                                
                            } else {                                
                                loadPrizeList(usertoken, 1);
                            }

                            isProcessing = false;
                        }
                    });
                }, 50);
            }
        }

        //批量发放所有奖品
        function payPrizeAll() {
            if (isProcessing)
                return;
            else if (wxid == "" || wxopenid == "") {
                LeeJSUtils.showMessage("warn", "请先点击右上角的扫描按钮进行扫描！");
                return;
            }
            if (confirm("确认发放当前顾客所有奖品，该动作无法撤消！")) {
                isProcessing = true;
                LeeJSUtils.showMessage("loading", "正在处理，请稍候..");
                setTimeout(function () {
                    $.ajax({
                        url: "wxGetPrizeCore.ashx?ctrl=payPrizeAll",
                        type: "POST",
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { wxId: wxid, wxOpenid: wxopenid },
                        dataType: "text",
                        timeout: 10 * 1000,
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                            isProcessing = false;
                        },
                        success: function (msg) {
                            if (msg.indexOf("Error:") > -1) {
                                LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                            } else {                                
                                loadPrizeList(usertoken, 1);
                            }

                            isProcessing = false;
                        }
                    });
                }, 50);
            }
        }

        function loadPrizeList(token,bs) {
            LeeJSUtils.showMessage("loading", "正在加载，请稍候..");
            setTimeout(function () {
                $.ajax({
                    url: "wxGetPrizeCore.ashx?ctrl=getPrizeList",
                    type: "POST",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { usertoken:token },
                    dataType: "text",
                    timeout: 10 * 1000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                        isProcessing = false;
                    },
                    success: function (msg) {
                        console.log(msg);
                        if (msg.indexOf("Error:") > -1) {
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                            resetPage();
                        } else {
                            var data = JSON.parse(msg);
                            wxid = data.wxId;
                            wxopenid = data.wxOpenid;
                            $(".headimg").css("background-image", "url(" + data.wxHeadimgurl + ")");
                            $(".username").text(data.wxNick);

                            if (data.list.length == 0) {
                                $(".no_result").show();
                            } else {
                                var rows = data.list, get_html = "", noget_html = "";
                                for (var i = 0; i < rows.length; i++) {
                                    if (rows[i].IsGet == "False")
                                        noget_html += template("tmp_prize_item0", rows[i]);
                                    else
                                        get_html += template("tmp_prize_item1", rows[i]);
                                }//end for

                                $(".prize_list.noget").empty().html(noget_html);
                                $(".prize_list.hasget").empty().html(get_html);

                                if (bs == 1)
                                    LeeJSUtils.showMessage("successed", "操作成功！");
                                else
                                    LeeJSUtils.showMessage("successed", "成功加载该顾客奖品列表！");
                            }
                        }

                        if ($(".prize_list.noget .prize_item").length == 0)
                            $(".footer .btn_get").hide();
                        else
                            $(".footer .btn_get").css("display", "inline-block");
                        isProcessing = false;
                    }
                });
            }, 50);
        }

        function resetPage() {
            wxid = ""; wxopenid = "", usertoken = "";
            $(".headimg").css("background-image", "url(../../res/img/headImg.jpg)");
            $(".username").text("--");
            $(".prize_list.noget").empty();
            $(".prize_list.hasget").empty();
        }

        function wxConfig() {//微信js 注入
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ["scanQRCode"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                // alert("注入成功");
                scanQRCode();
            });
            wx.error(function (res) {
                // alert("JS注入失败！");
            });
        }

        var isProcessing = false;
        function scanQRCode() {
            wx.scanQRCode({
                needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                scanType: ["barCode", "qrCode"], // 可以指定扫二维码还是一维码，默认二者都有 //, "qrCode"
                success: function (res) {
                    var result = res.resultStr; // 当needResult 为 1 时，扫码返回的结果

                    if (result != "") {
                        usertoken = result;
                        loadPrizeList(result, 0);
                    }
                }
            });
        }
    </script>
</body>
</html>
