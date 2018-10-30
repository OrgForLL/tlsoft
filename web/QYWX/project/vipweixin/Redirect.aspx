<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server"> 
    protected void Page_Load(object sender, EventArgs e)
    {
        string goalurl = Convert.ToString(Request.Params["goalurl"]);
        if (goalurl == "")
        {
            clsSharedHelper.WriteInfo("传入参数有误");
            return;
        }
        string appid = clsConfig.GetConfigValue("OAappID");

        string myurl = "https://open.weixin.qq.com/connect/oauth2/authorize?appid={0}&redirect_uri={1}&response_type=code&scope=snsapi_userinfo&state=1#wechat_redirect";
        
        goalurl = System.Web.HttpUtility.UrlEncode(goalurl);
        myurl = string.Format(myurl, "wx821a4ec0781c00ca", goalurl);
        Response.Redirect(myurl);
    }
</script>
<html>
<head id="Head1" runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>加载中..
    </div>
    </form>
</body>
</html>
