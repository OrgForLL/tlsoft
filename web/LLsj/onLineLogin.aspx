<%@ Page Language="C#" Debug="true"%>
<%@ Import Namespace=" nrWebClass" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script  runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
         string gourl = "http://sj.lilang.com:186/mhome/mShowTZ.aspx";
         string _type = "";
         if (Request.Params["type"] != null)
         {
             //20151119跨域时必须要传参sid=sessionID；才能保留session值；
             _type = Request.Params["type"].ToString();
             if (_type.ToLower() == "oa")
             {
                 gourl = "http://oa.lilang.com:8100/LoginRedirest.aspx?sid=sessionID";
             }
             else if (_type.ToLower() == "kaoqindaiban")
             {
                 gourl = "http://sj.lilang.com:186/llsj/approvalList.aspx";
             }
             else if (_type.ToLower() == "menu")
             {
                 gourl = "http://sj.lilang.com:186/llsj/menu.aspx";
             }
             else if (_type.ToLower() == "approvepage")
             {
                 gourl = "http://sj.lilang.com:186/llsj/approve/approvePage.aspx";
             }
         }
        
        if (Session["userid"] == "" || Session["userid"] == null)
        {
            String gotoOauth = "https://open.weixin.qq.com/connect/oauth2/authorize?appid={0}&redirect_uri={1}&response_type=code&scope=snsapi_base&state=0#wechat_redirect";
            String urlOauth = string.Concat("http://sj.lilang.com:186/LLsj/WXoauth.aspx?gourl=", HttpUtility.UrlEncode(gourl));
            urlOauth = HttpUtility.UrlEncode(urlOauth);
            gotoOauth = String.Format(gotoOauth, clsConfig.GetConfigValue("OAappID"), urlOauth);//"wxe46359cef7410a06"
            Response.Redirect(gotoOauth);
        }
        else
        {
            gourl = gourl.Replace("sid=sessionID", "sid=" + Session.SessionID.ToString());
            Response.Redirect(gourl);
        }
    }
    
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>登录</title>

</head>
<body>

</body>
</html>
