<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    /// <summary>
    /// 该文件用于2015福利会小游戏 刮刮卡的管理接口调用 放于231 interface下
    /// </summary>
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            //按指定日期生成游戏券池数据
            case "GenaratePrizePool":
                string GTime = Convert.ToString(Request.Params["gtime"]);
                if (GTime == "" || GTime == null)
                    clsSharedHelper.WriteErrorInfo("GTime is null!");
                else
                {
                    try
                    {
                        Convert.ToDateTime(GTime);
                    }
                    catch (Exception ex)
                    {
                        clsSharedHelper.WriteErrorInfo("请输入合法的日期！例：2015-1-1");
                        return;
                    }

                    GenaretePrizePool(GTime);
                }
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无效的控制参数！ctrl:" + ctrl);
                break;
        }
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
