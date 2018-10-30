<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    //利郎轻商务公众号
    private string AppID = "wx60aada4e94aa0b73";
    private string AppSecret = "5baaa8061418367e557f2591b03162e5";
    private string WXDBConStr = "server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456";
    private string ConnStr = clsConfig.GetConfigValue("OAConnStr");//正式库
    private const string ConfigKey = "7";//利郎轻商务
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string msg = "";
        List<string> apiConfig = new List<string>();
        apiConfig = clsWXHelper.GetJsApiConfig(ConfigKey);
        for (int i = 0; i < apiConfig.Count; i++) {
            msg += apiConfig[i] + "|";
        }
        clsSharedHelper.WriteInfo(msg);
    }   
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
