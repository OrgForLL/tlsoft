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
        if (!string.IsNullOrEmpty(orgid))   //����д���������Բ���Ϊ׼
        {
            StoreID = orgid;
            return;
        }

        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string AppSystemKey = clsWXHelper.GetAuthorizedKey(3);//ȫ����ϵͳ
            if (AppSystemKey == "")
                clsWXHelper.ShowError("�Բ�������δ��ͨȫ����ϵͳȨ��,����ϵIT�����");
            else
            {
                StoreID = Convert.ToString(Session["tzid"]);
                if (string.IsNullOrEmpty(StoreID) || StoreID == "0")
                    clsWXHelper.ShowError("�Բ��𣬱����ܽ����ŵ�ʹ�ã�");

            }//ȫ������Ȩͨ��            
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
    <title>������Աע��</title>
    <script type="text/javascript">
       // �ƶ���
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
            <p class="title-tip">����ר��΢�Ż�Ա����ȡ</p>
        </div>
        <div class="QR-code-wrap">
            <div class="corner-wrap">
                <div class="top-left"></div>
                <div class="top-right"></div>
                <div class="bot-left"></div>
                <div class="bot-right"></div>
            </div>
            <img class="qrcode" src="" alt="QRCode" />
            <div class="QR-tip">ɨһɨ��ά��</div>
        </div>
        <div class="gradient"></div>
        <div class="description">
            <p class="desc-title">˵��</p>
            <p class="desc-tips">�ù˿�ɨ����ͼ��ά�룬��ȡ����΢�Ż�Ա����</p>
        </div>
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/json2.js"></script>
    <script type="text/javascript">

        $(function () {

            /* �����Ҽ��˵�*/
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
                        alert("�����쳣,���Ժ����ԣ�");
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