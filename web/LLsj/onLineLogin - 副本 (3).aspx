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
             //20151119����ʱ����Ҫ����sid=sessionID�����ܱ���sessionֵ��
             _type = Request.Params["type"].ToString();
             if (_type.ToLower() == "oa")
             {
                 gourl = "http://oa.lilang.com:8100/LoginRedirest.aspx?sid=sessionID";
             }
             else if (_type.ToLower() == "kaoqindaiban")
             {
                 gourl = "http://sj.lilang.com:186/llsj/approvalList.aspx";
             }
         }
         //��ҵ����Ȩ
         //if (clsWXHelper.CheckQYUserAuth(true))
         //{
         //    int SystemID = 1;   //��ʾЭͬϵͳ
         //    string t_userid = clsWXHelper.GetAuthorizedKey(SystemID);
         //    gourl = gourl.Replace("sid=sessionID", "sid=" + t_userid);
         //    Session["userid"] = t_userid;
         //    Response.Redirect(gourl);
         //}        
    }
    
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>��¼</title>

</head>
<body>

</body>
</html>
