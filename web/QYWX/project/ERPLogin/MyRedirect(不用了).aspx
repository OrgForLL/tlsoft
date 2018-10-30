<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="WebBLL.Core" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server"> 
    protected void Page_Load(object sender, EventArgs e)
    {
        string uuid = Convert.ToString(Request.Params["uuid"]);
        string usertoken = Convert.ToString(Request.Params["ut"]);
        string gotoURL = "https://open.weixin.qq.com/connect/oauth2/authorize?appid={0}&redirect_uri={1}&response_type=code&scope=snsapi_base&state=0#wechat_redirect";
        string goalurl = string.Concat(clsConfig.GetConfigValue("OAOauthBackURL"), "/project/ERPLogin/mbLoginCheck.aspx?uuid=", uuid, "&usertoken=", usertoken);
        goalurl = System.Web.HttpUtility.UrlEncode(goalurl);
        if (uuid != "" && usertoken != "")
        {
            gotoURL = string.Format(gotoURL, clsConfig.GetConfigValue("OAappID"), goalurl);

            //更新条码刷的状态
            string strInfo = "";
            strInfo = Scan2WCode(uuid);
            if (strInfo == "")
            {
                Response.Redirect(gotoURL);
            }
            else
            {
                clsSharedHelper.WriteErrorInfo(strInfo);
            }
        }
        else
        {
            clsSharedHelper.WriteErrorInfo(clsSharedHelper.Error_UltraViresAccess);
        } 
    }
    /// <summary>
    /// 扫描二维码时间(该方法在手机端运行)
    /// </summary>
    /// <param name="uuid">二维码UUID</param>
    /// <returns></returns>
    public string Scan2WCode(string uuid)
    {
        string errInfo = "";
        string exeSQL = "UPDATE wx_t_2WCodeState SET IsScan=1 WHERE uuid=@uuid ";

        List<SqlParameter> listSqlParameter = new List<SqlParameter>();

        listSqlParameter.Add(new SqlParameter("@uuid", uuid));

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
        {
            errInfo = dal.ExecuteNonQuerySecurity(exeSQL, listSqlParameter);

            if (errInfo == "")
            {
                errInfo = "";
            }
            else
            {
                errInfo = "扫描二维码失败！错误：" + errInfo;
            }
        }

        return errInfo;
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
