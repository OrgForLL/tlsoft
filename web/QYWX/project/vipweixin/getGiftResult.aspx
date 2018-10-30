<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private string ConfigKeyValue = "5";//利郎男装
    private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private string DBConstr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string TestDBConstr = "server=192.168.35.23;uid=lllogin;pwd=rw1894tla;database=tlsoft";

    Dictionary<string, object> TokenInfos = new Dictionary<string, object>();
    public List<string> wxConfig;//微信OPEN_JS 动态生成的调用参数

    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            string openid = Convert.ToString(Session["openid"]);
            //传入参数wx_t_ActiveTokenPrize.id[pid]
            string pid = Convert.ToString(Request.Params["pid"]);
            if (pid == "" || pid == "0" || pid == null)
                clsWXHelper.ShowError("请检查传入的参数！");
            else
            {
                using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConstr))
                {
                    string str_sql = "select top 1 id from wx_t_vipbinging where wxopenid=@openid and objectid=1";
                    List<SqlParameter> paras = new List<SqlParameter>();
                    paras.Add(new SqlParameter("@openid", openid));
                    object scalar;
                    string errinfo = dal10.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                    if (errinfo == ""){
                        TokenInfos.Add("wxid", Convert.ToString(scalar));
                        TokenInfos.Add("openid", openid);
                    }                        
                    else
                        clsWXHelper.ShowError(errinfo);
                }//end using 10

                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);                
            }
        }
    }
</script>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>利郎男装</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            line-height: 1;
            color: #363c44;
        }

        .page {
            background-color: #f0f0f0;
        }

        .content {
            background-color: #fff;
            padding: 20px 15px;
            width: 90%;
            box-shadow: 0 0 1px #ccc;
        }

        .icon {
            width: 80px;
            height: 80px;
            line-height: 81px;
            position: absolute;
            top: -40px;
            right: 10px;
            border-radius: 50%;
            background-color: #ccc;
            text-align: center;
            color: #fff;
        }

            .icon i {
                vertical-align: middle;
            }

        .giftname {
            padding-bottom: 10px;
        }

        .remark {
            color: #ccc;
            margin-bottom: 15px;
            line-height: 1.4;
        }

        .exchange {
            border-top: 1px dashed #ddd;
            margin-top: 20px;
            padding-top: 10px;
            display:none;
        }

        .text {
            font-weight: 600;
            padding-bottom: 10px;
        }

        .btn_exchange {
            height: 28px;
            line-height: 29px;
            padding: 0 10px;
            background-color: #63b359;
            color: #fff;
            border-radius: 2px;
            display: inline-block;
        }

        .result {
            border-top: 1px dashed #ddd;
            padding-top: 15px;            
        }

        .succ_tip {
            text-align: center;
            color: #63b359;
            font-weight: bold;
            font-size: 28px;
        }

            .succ_tip.fail {
                color: #cc463d;
            }

        .sub {
            color: #cc463d;
            text-align: center;
            padding-top: 15px;
            padding-bottom: 20px;
            display: none;
            line-height:1.4;
        }

        .time {
            text-align: center;
            color: #888;
            padding-top: 10px;
        }

        .logo {
            height: 14px;
            position: absolute;
            top: -22px;
            left: 5px;
        }

            .logo > img {
                height: 100%;
            }

        #records {
            display: block;
            background-color: #fff;
            box-shadow: 0 0 1px #ccc;
            color: #363c44;
            font-weight: 600;
            padding: 12px 0;
            margin-top: 10px;
            text-align: center;
            position: absolute;
            bottom: -44px;
            left: 0;
            width: 100%;            
            color:#63b359;
            font-weight:bold;
        }

        .icon[data-status='error'] {
            background-color: #cc463d;
        }

        .icon[data-status='success'] {
            background-color: #63b359;
        }

        .icon[data-status='process'] {
            background-color: #ccc;
        }

        .icon[data-status='ask'] {
            background-color: #ef8824;
        }

        .succ_tip[data-status='error'] {
            color: #cc463d;
        }

        .succ_tip[data-status='success'] {
            color: #63b359;
        }

        .succ_tip[data-status='process'] {
            color: #ccc;
        }

        .transition {
            transition: all 0.5s ease-in-out;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page" id="index" style="margin-top:-40px;">
            <div class="content center-translate">
                <div class="logo">
                    <img src="../../res/img/vipweixin/lllogo.png" />
                </div>
                <div class="icon transition" data-status="process">
                    <i id="iask" class="fa fa-4x fa-question" style="display: none;"></i>
                    <i id="iprocess" class="fa fa-4x fa-spinner fa-spin"></i>
                    <i id="isuccess" class="fa fa-4x fa-check" style="display: none;"></i>
                    <i id="ierror" class="fa fa-4x fa-times" style="display: none;"></i>
                </div>
                <div class="infos">
                    <h1 class="giftname">--</h1>
                    <p class="remark">--</p>
                </div>
                <div class="exchange">
                    <p class="text">确认立即兑换请点击下方按钮</p>
                    <div style="text-align: right; margin-top: 10px; height: 28px;">
                        <a href="javascript:exchangeGift();" class="btn_exchange">立即兑换</a>
                    </div>
                </div>
                <div class="result">
                    <p class="succ_tip" data-status="process">正在处理..</p>
                    <p class="sub">--</p>                    
                    <p class="time">--</p>
                </div>

                <!--查看兑换记录按钮-->
                <div class="btns">
                    <a href="javascript:;" id="records">查看兑换记录</a>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript">
        var openid = "<%=TokenInfos["openid"]%>", wxid = "<%=TokenInfos["wxid"]%>";
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var ActiveTokenID = "";

        //显示当前时间
        function nowTime() {
            var nowDate = new Date();
            var year = nowDate.getFullYear();
            var month = nowDate.getMonth() + 1;
            month = month > 9 ? month : "0" + month;
            var date = nowDate.getDate();
            date = date > 9 ? date : "0" + date;
            var hour = nowDate.getHours();
            hour = hour > 9 ? hour : "0" + hour;
            var miunte = nowDate.getMinutes();
            miunte = miunte > 9 ? miunte : "0" + miunte;
            var second = nowDate.getSeconds();
            second = second > 9 ? second : "0" + second;

            $(".time").text(year + "-" + month + "-" + date + "-" + hour + ":" + miunte + ":" + second);
        }

        $(document).ready(function () {
            LeeJSUtils.LoadMaskInit();
            FastClick.attach(document.body);
            jsConfig();
            nowTime();
            setInterval("nowTime()", 1000);
        });

        window.onload = function () {
            exchangeCheck();
        }

        $("#records").click(function () {            
            window.location.href = "tokenPayed.aspx?tid=" + ActiveTokenID;
        });

        //兑换前的验证
        function exchangeCheck() {
            var pid = LeeJSUtils.GetQueryParams("pid");
            $.ajax({
                type: "POST",
                cache: false,
                timeout: 10 * 1000,
                data: { PrizeID: pid, wxID: wxid },
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=BuyPrizeReady",
                success: function (msg) {
                    if (msg.indexOf("Error:") > -1)
                        LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                    else {
                        var data = JSON.parse(msg);                        
                        $(".giftname").text(data.PrizeName);
                        $(".remark").text(data.Remark);
                        ActiveTokenID = data.ActiveTokenID;
                        if (data.BuyStatus == "0") {
                            //不可以兑换
                            $(".icon>i").hide();
                            $("#ierror").show();
                            $(".icon").attr("data-status", "error");
                            $(".succ_tip").attr("data-status", "error");
                            $(".succ_tip").text("无法领取!");
                            $(".sub").text(data.BuyErrorRemark);
                            $(".sub").slideDown();
                        } else {
                            //可以兑换
                            $(".icon>i").hide();
                            $("#iask").show();
                            $(".icon").attr("data-status", "ask");
                            $(".result").hide();
                            $(".exchange").slideDown();
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {                    
                    LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                }
            });
        }

        //兑换礼物操作
        //请将本画面出示给工作人员，不要立即关闭！
        var isProcess = false;
        function exchangeGift() {
            if (isProcess)
                return;
            isProcess = true;
            var pid = LeeJSUtils.GetQueryParams("pid");
            $(".exchange").slideUp();
            $(".result").fadeIn(500);
            $(".icon>i").hide();
            $("#iprocess").show();
            $(".icon").attr("data-status", "process");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    cache: false,
                    timeout: 10 * 1000,
                    data: { PrizeID: pid, wxID: wxid },
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=BuyPrizePay",
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1) {
                            //兑换失败
                            $(".icon>i").hide();
                            $("#ierror").show();
                            $(".icon").attr("data-status", "error");
                            $(".succ_tip").attr("data-status", "error");
                            $(".succ_tip").text("领取失败!");
                            $(".sub").text(msg.replace("Error:", ""));
                            $(".sub").slideDown();
                        } else {
                            //兑换成功
                            $(".icon>i").hide();
                            $("#isuccess").show();
                            $(".icon").attr("data-status", "success");
                            $(".succ_tip").attr("data-status", "success");
                            $(".succ_tip").text("领取成功!");
                            $(".sub").text("请将本画面出示给工作人员，不要立即关闭！");
                            $(".sub").slideDown();
                        }

                        isProcess = true;
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        isProcess = true;
                        LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                    }
                });
            }, 1000);
        }

        //微信JS-SDK
        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['hideMenuItems', 'scanQRCode'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                wx.hideMenuItems({
                    menuList: ['menuItem:share:appMessage', 'menuItem:share:qq', 'menuItem:share:timeline', 'menuItem:share:weiboApp', 'menuItem:share:QZone', 'menuItem:openWithSafari', 'menuItem:openWithQQBrowser', 'menuItem:share:email', 'menuItem:copyUrl'] //menuItem:share:appMessage 要隐藏的菜单项，只能隐藏“传播类”和“保护类”按钮，所有menu项见附录3
                });
            });

            wx.error(function (res) {
                alert("JS注入失败！");
            });
        }
    </script>
</body>
</html>
