<%@ Page Language="C#" %>
<%@ Import Namespace="LILANZMSGSender" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        string msgtype = "yd", mark = "";
        MSGSender s = new MSGSender(msgtype, mark);
        string phone = QueryString.Q("RPhone"), 
            content = QueryString.Q("PostInfo");

        clsLocalLoger.logDirectory = Server.MapPath("/") + @"logs\";
        Response.Write(clsLocalLoger.logDirectory);
        clsLocalLoger.Log("短信请求url信息：" + Request.Url.Query);      

        if (phone != "" && content != "")
        {
            MSGResult r = s.Send("1", "1", "wifi认证", phone, content, "", "");
            Response.Write(r.body);
        }
        else
            Response.Write("发送失败");
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
