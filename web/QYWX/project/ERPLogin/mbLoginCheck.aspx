<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="WebBLL.Core" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server"> 
    public string outputjs = "";
    string DBconStr = clsConfig.GetConfigValue("OAConnStr");
    private const string ConfigKeyValue = "1";
    string QYAccessToken = clsWXHelper.GetAT(ConfigKeyValue);
    protected void Page_Load(object sender, EventArgs e)
    {

        string uuid = Request.Params["uuid"];
        string ut = Request.Params["ut"];

        string customerID = "", OpenId = "";

        if (uuid == null || uuid=="")
        {
            clsSharedHelper.WriteErrorInfo("非法访问");
            return;
        }

        if (clsWXHelper.CheckQYUserAuth(false))
        {
            customerID = Convert.ToString(Session["qy_customersid"]);
            OpenId = Convert.ToString(Session["qy_OpenId"]);
        }

        string mySql, errInfo = "";

       errInfo= Scan2WCode(uuid);//扫描结果
       if (errInfo != "")
       {
           clsSharedHelper.WriteInfo(errInfo);
           return;
       }

        List<SqlParameter> para = new List<SqlParameter>();
        DataTable dt;
        if (customerID == "" && OpenId == "")
        {
            clsSharedHelper.WriteErrorInfo("出错了，请重新扫码");
            return;
        }
        else if (OpenId != "")//未关注人员，openid不为空
        {
            mySql =@"select a.name,a.cname,a.mobile,a.status,a.id,a.status,isnull(b.userid,0) authID 
                    from wx_t_customers a 
                    left join wx_t_AppAuthorized b on a.id=b.userid and b.systemid=1 where a.wxopenid=@wxopenid";
            para.Add(new SqlParameter("@wxopenid", OpenId));
            using(LiLanzDALForXLM dal= new LiLanzDALForXLM(DBconStr)){
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
                para.Clear();
            }

            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo("出错了，请重新扫码");
                clsLocalLoger.WriteInfo(errInfo);
                return;
            }
            else if (dt.Rows.Count < 1)//此openid不存在，说明此人不存在企业通讯录
            {
                //Session["qy_status"] = "0";
                //Session["qy_OpenId"] = OpenId;
                Response.Redirect("../BandToSystem/SystemBand.aspx?systemid=1&ClosePag=1");
            }
            else
            {

                //Session["qy_customersid"] = Convert.ToString(dt.Rows[0]["id"]);
                //Session["qy_name"] = Convert.ToString(dt.Rows[0]["name"]).Trim();
                //Session["qy_cname"] = Convert.ToString(dt.Rows[0]["cname"]);
                //Session["qy_mobile"] = Convert.ToString(dt.Rows[0]["mobile"]);
                //Session["qy_status"] = Convert.ToString(dt.Rows[0]["status"]);
                if (dt.Rows[0]["authID"] == "0")//系统未授权，去绑定
                {
                    Response.Redirect("../BandToSystem/SystemBand.aspx?systemid=1&ClosePag=1");
                }
                else //去关注
                {
                    Response.Redirect("../BandToSystem/QY2code.aspx");
                }
            }
        }
        else //已关注成功
        {
            
            string strInfo = CheckQrCodeLogin(uuid, Convert.ToString(Session["qy_name"]));
            if (strInfo.IndexOf("Type4|") == 0)
            {
                outputjs = GetAlertString("您尚未绑定协同系统", "操作提示");
                Response.Redirect("../BandToSystem/SystemBand.aspx?systemid=1&ClosePag=1");
            }
            outputjs = GetAlertString(strInfo, "操作提示");
        }
    }
    /// <summary>
    /// 验证二维码(该方法在手机端运行)
    /// </summary>
    /// <param name="userid">ERP的userid</param>
    /// <param name="wxopenid">微信OPENID</param>
    /// <param name="uuid">二维码识别ID</param>
    /// <returns></returns>
    public string CheckQrCodeLogin(string uuid, string wxopenid)
    {
        string errInfo = "";
        string exeSQL = @"DECLARE @userid INT;
                            SELECT @userid = 0

                            SELECT TOP 1 @userid=b.systemkey from  wx_t_customers a 
                            INNER JOIN wx_t_AppAuthorized b ON a.id=b.userid AND b.systemid=1 AND a.name=@wxOpenid
                            IF (@userid = 0)	SELECT '0' AS Cstate,'Type4|该微信号还未绑定ERP账号，无法登录！' AS msgInfo
                            ELSE
                            BEGIN
	                            IF NOT EXISTS (SELECT TOP 1 ID FROM wx_t_2WCodeState WHERE uuid=@uuid) SELECT '-1' AS Cstate,'二维码信息不存在！' AS msgInfo
	                            ELSE
	                            BEGIN
		                            UPDATE wx_t_2WCodeState SET userid = @userid,IsConfirm=1,wxOpenid=@wxOpenid WHERE uuid=@uuid
		                            SELECT '1' AS Cstate,'验证成功！' AS msgInfo
	                            END
                            END";
        List<SqlParameter> listSqlParameter = new List<SqlParameter>();

        listSqlParameter.Add(new SqlParameter("@wxOpenid", wxopenid));
        listSqlParameter.Add(new SqlParameter("@uuid", uuid));

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBconStr))
        {
            DataTable dt;
            errInfo = dal.ExecuteQuerySecurity(exeSQL, listSqlParameter, out dt);

            if (errInfo == "" && dt.Rows.Count > 0)
            {
                errInfo = dt.Rows[0]["msgInfo"].ToString();
            }
            else
            {
                errInfo = "登录失败！错误：" + errInfo;
            }
        }

        return errInfo;
    }
    /// <summary>
    /// 输出JS消息框到前台，以便显示提示信息
    /// </summary>
    /// <param name="ShowContent">内容</param>
    /// <param name="ShowTitle">标题</param>
    /// <returns></returns>
    public string GetAlertString(string ShowContent, string ShowTitle)
    {
        StringBuilder jsOutput = new StringBuilder(@"<script>");
        jsOutput.Append(@"sAlert('" + ShowTitle + "','" + ShowContent + "');");
        jsOutput.Append("</scr" + "ipt>");

        return jsOutput.ToString();
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
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>登录验证</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link href="../../res/css/erplogin/vip.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../res/js/erplogin/sAlert.js"></script> 

    <%--设置页面不缓存--%>
    <meta http-equiv="pragma" content="no-cache">
    <meta http-equiv="cache-control" content="no-cache">
    <meta http-equiv="expires" content="0">   
</head>
<body style=" padding:0px; margin:0px;">
    <form id="form1" runat="server">
    <asp:HiddenField ID="HiddenFielduuid" runat="server" />

    <div>
    
    <div style=" position:relative; width:100%; height:60px; background-color:#302921; text-align:center; ">
        <img alt="" src="../../res/img/erplogin/poslogo.png" style=" position:relative; margin:auto;top:15px;">
    </div>
    
    <div class="mod_color_weak qb_fs_s qb_gap qb_pt10">
		微信验证登录
	</div>

    <div style=" position:relative; height:150px; width:100%; text-align:center;">    
        <img alt="" src="../../res/img/erplogin/pc1.png" style=" position:relative; margin:auto; top:10px">
    </div>

    <div class="qb_fs_s qb_gap qb_pt10">
        提示：您将要使用微信验证登录到ERP！
        <%--<asp:Label ID="lblInfo" runat="server" Text="" ForeColor="Red"></asp:Label>--%>
    </div>

        

     <div class="submitDiv">
        <a id="submitBtn" class="mod_btn" href="javascript:void(0)" onclick="javascript:form1.submit();" >点击进行登录验证</a>
    </div>
    
       <div id="bottom">
    	    <h1>利郎信息技术部提供技术支持</h1>
        </div>
    </div>
    </form>
    <%= outputjs %> 
</body>
</html>

