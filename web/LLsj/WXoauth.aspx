<%@ Page Language="C#" Debug="true"%>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace=" nrWebClass" %>
<%@ Import Namespace=" WebBLL.Core" %>
<%@ Import Namespace=" System.Collections.Generic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script  runat="server">
    string goUrl = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        string access_token = "";
        string userCode = "";        
        try
        {
             goUrl = Request.Params["goUrl"];
             goUrl = goUrl.Replace("sid=sessionID", "sid=" + Session.SessionID.ToString());
             userCode = Convert.ToString(Request.Params["code"]);
        }
        catch
        {
            clsSharedHelper.WriteErrorInfo("获取code失败！");
        }
        if (userCode == null || userCode == "")
        {
            clsSharedHelper.WriteErrorInfo("获取code失败！");
        }
        string OAappID = clsConfig.GetConfigValue("OAappID"); // "wxe46359cef7410a06";// 
        string OAappSecret = clsConfig.GetConfigValue("OAappSecret"); // "w0IiKV3RGY6lzcx1QjdzMdWfhVMJEFOmnl_6HpYzfCgyNpORbyj6wlBnvmv2bw7x";// 
        string OAagentID = clsConfig.GetConfigValue("OAagentid"); //  "1"; // 
        access_token = GetAccessToken("https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid={0}&corpsecret={1}", "QY", OAappID, OAappSecret);
        string s_userid = getUserBaseInfoByLoginId(access_token, userCode, OAagentID);
        if (s_userid == "")
        {
            Response.Redirect("http://sj.lilang.com:186/LLsj/elogin.html");
          //  clsSharedHelper.WriteErrorInfo("未找到用户信息，请确认是否已加入公司公众号！");
        }
        else
        {            
            //20161208 ke 改成客户端跳转
            Response.Redirect(goUrl);  

        } 
    }
    public string getUserBaseInfoByLoginId(string token, string code, string agentid)
    {
        String url = "https://qyapi.weixin.qq.com/cgi-bin/user/getuserinfo?access_token={0}&code={1}&agentid={2}";
        url = string.Format(url, token, code, agentid);
        String reStr = clsNetExecute.HttpRequest(url);
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(reStr);
        String UID = jh.GetJsonValue("UserId");
        String userid = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            DataTable dt = null;
            // String sql = "select top 1 isnull(qx,0) qx,id as userid,name as username,cname,unid from t_user where name='" + UID + "'";
			//更新查询代码以便支持后期用户。 By:xlm 20160727
			String sql = @"SELECT TOP 1 isnull(C.qx,0) qx,C.id as userid,C.name as username,C.cname,C.unid from wx_t_customers A
							INNER JOIN wx_t_AppAuthorized B ON A.ID = B.UserID AND B.SystemID = 1
							INNER JOIN t_user C ON B.SystemKey = C.id
						   WHERE A.name='" + UID + "'";
            //clsLocalLoger.Log(UID);
            //clsLocalLoger.Log(sql);
            //clsLocalLoger.Log(dal.ConnectionString);
            String err = dal.ExecuteQuery(sql, out dt);
            if (err == "")
            {
                if (dt.Rows.Count > 0)
                {
                   Session["qx"] = dt.Rows[0]["qx"].ToString().Trim();
                   Session["userid"] = dt.Rows[0]["userid"].ToString();
                   Session["username"] = dt.Rows[0]["cname"].ToString();
                   Session["unid"] = dt.Rows[0]["unid"].ToString();
                   Session["user"] = dt.Rows[0]["cname"].ToString();
                   Session["zbid"] = 1;
                   // clsSharedHelper.WriteInfo(Session["qx"] + "|" + Session["userid"] + "|" + Session["username"] + "|" + Session["user"] + "|"+Session["zbid"]);
                    userid =dt.Rows[0]["userid"].ToString() ;
                }
                else
                {
                    //用户不存在
                    userid = "";
                }
            }
            return userid;
        }
    }
    private string GetAccessToken(string posturl, string QY, string appid, string secret)
    {
        string content = "";
        clsJsonHelper json;

        if (HttpContext.Current.Application[QY + "AT_Value" + appid] == null
        || Convert.ToDateTime(HttpContext.Current.Application[QY + "AT_Time" + appid]).Subtract(DateTime.Now).TotalSeconds < 1)      //没有获取Access_Token或再过一分钟就超时，则重新获取它
        {
            posturl = String.Format(posturl, appid, secret);
            content = clsNetExecute.HttpRequest(posturl);
            json = clsJsonHelper.CreateJsonHelper(content);

            if (json.GetJsonValue("access_token") != "")
            {
                HttpContext.Current.Application[QY + "AT_Value" + appid] = json.GetJsonValue("access_token");
                HttpContext.Current.Application[QY + "AT_Time" + appid] = DateTime.Now.AddSeconds(7100);       //增加约2个小时的有效时间，以便接下来重新获取
            }
            else  //获取不到，则返回空！                
            {
                HttpContext.Current.Application[QY + "AT_Value" + appid] = "";
                HttpContext.Current.Application[QY + "AT_Time" + appid] = DateTime.Now;
            }
        }
        return HttpContext.Current.Application[QY + "AT_Value" + appid].ToString();
    }
    ///获取成员信息 企业号               
    public string getCustomer(string access_token, string userid)
    {
        String myURL = "https://qyapi.weixin.qq.com/cgi-bin/user/get?access_token={0}&userid={1}";
        myURL = String.Format(myURL, access_token, userid);
        return clsNetExecute.HttpRequest(myURL);
    }
</script>
<script language="javascript">window.location=<%=goUrl %></script>
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
