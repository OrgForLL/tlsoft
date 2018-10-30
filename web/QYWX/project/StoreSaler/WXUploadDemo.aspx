<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>

<!DOCTYPE html>
<script runat="server">
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数
    protected void Page_Load(object sender, EventArgs e)
    {
        wxConfig = clsWXHelper.GetJsApiConfig("1");
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>    
    <style type="text/css">
        p {
            width:100%;
            word-break:break-all;
        }
    </style>
</head>
<body>
    <p id="progress">进度：<span id="current"></span> / <span id="total"></span></p>
    <div class="detail"></div>
    <a href="javascript:chooseImageByWX();">选择图片</a>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        $(document).ready(function () {
            wxConfig();
        });

        //微信JSAPI
        function wxConfig() {//微信js 注入
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ["chooseImage", "uploadImage"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                //alert("注入成功");
            });
            wx.error(function (res) {
                //alert("JS注入失败！");
            });
        }        

        var localIds = [];
        function chooseImageByWX() {
            wx.chooseImage({
                count: 9, // 默认9
                sizeType: ['original', 'compressed'], // 可以指定是原图还是压缩图，默认二者都有
                sourceType: ['album', 'camera'], // 可以指定来源是相册还是相机，默认二者都有
                success: function (res) {
                    localIds = res.localIds; // 返回选定照片的本地ID列表，localId可以作为img标签的src属性显示图片
                    $("#total").text(localIds.length);
                    if (localIds.length > 0) 
                        uploadImgByWX(0);
                }
            });
        }

        function uploadImgByWX(xh) {            
            wx.uploadImage({
                localId: localIds[xh], // 需要上传的图片的本地ID，由chooseImage接口获得
                isShowProgressTips: 0, // 默认为1，显示进度提示
                success: function (res) {
                    $("#current").text(xh + 1);
                    var serverId = res.serverId; // 返回图片的服务器端ID
                    $(".detail").append("<p>" + (xh + 1) + "." + localIds[xh] + "<br/>" + serverId + "</p>");
                    if (!(xh == localIds.length - 1)) {
                        uploadImgByWX(xh + 1);
                    }
                }
            });
        }
    </script>
</body>
</html>
