<%@ Page Language="C#" Debug="true" %> 
<%@ Import Namespace="nrWebClass" %>  
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    public string AppSystemKey = "";
    protected void Page_Load(object sender, EventArgs e)
    {

        if (clsWXHelper.CheckQYUserAuth(true))
        {
            AppSystemKey = clsWXHelper.GetAuthorizedKey(6);
            if (AppSystemKey == "" || AppSystemKey == "0")
            {
                clsWXHelper.ShowError("对不起，您还未开通订货会系统！");
                return;
            }
            else
            {
                clsSharedHelper.WriteInfo("成功");
            }
        }else
            clsWXHelper.ShowError("对不起，鉴权失败！");

    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>订货会报名</title>


</head>


     

       
</body>
</html>
