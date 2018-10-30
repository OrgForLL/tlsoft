<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public string StoreID = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        string orgid = Request.Params["orgid"];
        if (!string.IsNullOrEmpty(orgid))   //如果有传入参数，以参数为准
        {
            StoreID = orgid;
            return;
        }

        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string AppSystemKey = clsWXHelper.GetAuthorizedKey(3);//全渠道系统
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限,请联系IT解决！");
            else
            {
                StoreID = Convert.ToString(Session["tzid"]);
                if (string.IsNullOrEmpty(StoreID) || StoreID == "0")
                    clsWXHelper.ShowError("对不起，本功能仅限门店使用！");

            }//全渠道鉴权通过            
        }
    }
</script>



<html>

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link rel="stylesheet" href="../../res/css/StoreSaler/StoreVipCardRegister.css"/>
    <title>卡包会员注册</title>
    <script type="text/javascript">
       // 移动端
       if (/Android|webOS|iPhone|iPod|BlackBerry/i.test(navigator.userAgent)) {

       } else {
           var doc = document;
           var link = doc.createElement("link");
           link.setAttribute("rel", "stylesheet");
           link.setAttribute("type", "text/css");
           link.setAttribute("href", "../../res/css/StoreSaler/StoreVipCardRegisterPC.css");

           var heads = doc.getElementsByTagName("head");
           heads[0].appendChild(link)

       }

</script>
    
</head>

<body>
    <div class="page">
        <div class="title-wrap">
            <img class="logo" src="../../res/img/StoreSaler/cardMemberLogo.png" alt="logo" />
            <p class="welcome">Welcome to</p>
            <p class="shop-name">--</p>
            <p class="title-tip">店铺专属微信会员卡领取</p>
        </div>
        <div class="QR-code-wrap">
            <div class="corner-wrap">
                <div class="top-left"></div>
                <div class="top-right"></div>
                <div class="bot-left"></div>
                <div class="bot-right"></div>
            </div>
            <img class="qrcode" src="" alt="QRCode" />
            <div class="QR-tip">扫一扫二维码</div>
        </div>
        <div class="gradient"></div>
        <div class="description">
            <p class="desc-title">说明</p>
            <p class="desc-tips">让顾客扫描上图二维码，领取利郎微信会员卡。</p>
        </div>
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/json2.js"></script>
    <script type="text/javascript">

        $(function () {

            /* 禁用右键菜单*/
            /*$('.QR-tip').bind('contextmenu', function (e) {
            e.preventDefault();
            })*/

            function loadQRCode() {
                $.ajax({
                    url: "GetStoreVipCardQrcode.ashx?ctrl=get&storeid=" + "<%=StoreID%>",
                    type: "post",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: {},
                    cache: false,
                    timeout: 15000,
                    error: function (e) {
                        alert("网络异常,请稍后重试！");
                    },
                    success: function (res) {
                        var msg = JSON.parse(res);

                        if (msg.errcode == "0") {
                            $(".shop-name").text(msg.storename);
                            $(".qrcode").attr("src", msg.imgurl);

                        } else
                            alert(msg.errmsg);
                    }
                });
            }

            loadQRCode();
        });

    </script>
</body>

</html>