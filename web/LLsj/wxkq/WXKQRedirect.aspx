<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server"> 
    protected void Page_Load(object sender, EventArgs e)
    {
        clsLocalLoger.logDirectory = Server.MapPath("../../Logs"); 
        string appid = clsConfig.GetConfigValue("OAappID");
        string goalPage = Request.Params["goalPage"].ToString();
        string myurl = "https://open.weixin.qq.com/connect/oauth2/authorize?appid={0}&redirect_uri={1}&response_type=code&scope=SCOPE&state=1#wechat_redirect";
        string goalurl = clsConfig.GetConfigValue("WXKQ_OauthBackURL") + "WXKQAuth.aspx?goalurl=";
        goalurl += goalPage;
        goalurl = System.Web.HttpUtility.UrlEncode(goalurl);
        myurl = string.Format(myurl, appid, goalurl);
        //string content=  clsNetExecute.HttpRequest(myurl);
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
    <div>加载1..
    </div>
    </form>
</body>
</html>
