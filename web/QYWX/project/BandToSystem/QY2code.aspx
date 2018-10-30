<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server"> 
    public string[] wxConfig;       //微信OPEN_JS 动态生成的调用参数
    public string imgFullUrl = "";
    protected void Page_Load(object sender, EventArgs e)
    {
    //获取微信JS_API config相关配置
            using (WxHelper wh = new WxHelper())
            {
                wxConfig = wh.GetWXQYJsApiConfig(clsConfig.GetConfigValue("OAappID"), clsConfig.GetConfigValue("OAappSecret"));
            }
            imgFullUrl = string.Concat(clsConfig.GetConfigValue("OAOauthBackURL") + "/res/img/touchLilanz.jpg");
    }
</script>
<html>
<head id="Head1" runat="server">
    <title>关注利郎企业号</title>
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />   
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
	<script type="text/javascript" src="../../res/js/jweixin-1.0.0.js"></script>  
    
    <script type="text/javascript"> 
        
        //以下是微信开发的JS
        wx.config({
            debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
            appId: '<%= wxConfig[0] %>', // 必填，公众号的唯一标识
            timestamp: <%= wxConfig[1] %> , // 必填，生成签名的时间戳
            nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
            signature: '<%= wxConfig[3] %>',// 必填，签名，见附录1
            jsApiList: [  
        'hideOptionMenu',
        'showOptionMenu',
        'previewImage'
            ] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
        });

        wx.ready(function () { 
            wx.hideOptionMenu();     
        });

    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>        
        <img alt="长按指纹进行关注" src="../../res/img/touchLilanz.jpg" width="100%" onclick="previewImage(1,'<%= imgFullUrl %>');" />
    </div>
    </form>
</body>
</html>

