<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="WebBLL.Core" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server"> 

    public string connStr_tlsoft = "";
    public string connStr_att2000 = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        connStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");
        SqlConnection sqlconn = (SqlConnection)Class_BBlink.LILANZ.DatabaseConn.Connection("att2000");
        connStr_att2000 = sqlconn.ConnectionString;
        sqlconn.Dispose();
        string strInfo = "";
        string gogoalurl = Request.Params["goalurl"];
        if (Session["wxkq_wxopenid"] == null || Convert.ToString(Session["wxkq_wxopenid"]) == "")
        {
			string appid = clsConfig.GetConfigValue("OAappID");
			string secret = clsConfig.GetConfigValue("OAappSecret");
			string agentid = clsConfig.GetConfigValue("WXKQ_agentid"); 
			strInfo = GetQYOAuthUserid(appid, secret, agentid);			
        }
        else
        {
            strInfo = Session["wxkq_wxopenid"].ToString();
        }

        if (strInfo.IndexOf(clsSharedHelper.Error_Output) == 0)
        {
            strInfo = strInfo.Remove(0, clsSharedHelper.Error_Output.Length);
        }
        else
        {
            Session["wxkq_wxopenid"] = strInfo;
        }


        if (Session["wxkq_wxopenid"] == null || Convert.ToString(Session["wxkq_wxopenid"]) == "")
        {
            Response.Write("无法获取身份信息！请确定已成功关注利郎企业号！");
            Response.End();
        }
        else
        {

            string t = GetPersonInfo(Convert.ToString(Session["wxkq_wxopenid"]));
            
            if (t.IndexOf("Successed") == 0)
            {            
                Response.Redirect(gogoalurl);
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("获取个人信息出错,请稍后再试:"+t);
            }
        }
    }
	
	#region "企业号鉴权"
	/// <summary>
	/// 使用鉴权的方式获取wxUserid
	/// </summary>
	/// <param name="appid">微信公众号的appid</param>
	/// <param name="secret">微信公众号的secret</param>
	/// <returns></returns>
	public string GetQYOAuthUserid(string appid, string secret, string agentid)
	{            
		string wxcode = HttpContext.Current.Request.QueryString["code"].ToString();
		string accessToken = GetQYWXAccessToken(appid, secret);

		string posturl = "https://qyapi.weixin.qq.com/cgi-bin/user/getuserinfo?access_token={0}&code={1}&agentid={2}";   //企业号            
		posturl = String.Format(posturl, accessToken, wxcode, agentid);

		//clsLocalLoger.WriteInfo("微信accessToken：" + accessToken);
		//clsLocalLoger.WriteInfo("微信wxcode：" + wxcode);
		//clsLocalLoger.WriteInfo("微信agentid：" + agentid);

		string content = clsNetExecute.HttpRequest(posturl);
		clsJsonHelper json = clsJsonHelper.CreateJsonHelper(content);
		clsLocalLoger.WriteInfo("微信jSon：" + json.jSon);     //如果用户没有关注我们的企业微信，则会返回：{"errcode":"46004","errmsg":"user no exist"}

		string errcode = json.GetJsonValue("errcode");
		if (errcode == "46004")
		{
			return clsSharedHelper.Error_Output + errcode;
		}
		else if (errcode != "")
		{
			return clsSharedHelper.Error_Output + json.jSon;
		}
		else
		{
			return json.GetJsonValue("UserId");
		}
	}
	
	/// <summary>
	/// 获取企业微信的Accesstoken
	/// </summary>
	/// <param name="appid"></param>
	/// <param name="secret"></param>
	/// <returns></returns>
	public string GetQYWXAccessToken(string appid, string secret)
	{
		return GetAccessToken("https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid={0}&corpsecret={1}", "QY", appid, secret);
	}


	/// <summary>
	/// 根据参数计算AccessToken，该函数在微信公众号和微信企业号中都适用
	/// </summary>
	/// <param name="posturl">传入对应的调用POSTURL</param>
	/// <param name="QY">如果是企业号，则传入“QY”；否则传入空字符串</param>
	/// <param name="appid"></param>
	/// <param name="secret"></param>
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
				HttpContext.Current.Application[QY + "AT_Time" + appid] = DateTime.Now.AddSeconds(Convert.ToInt32(json.GetJsonValue("expires_in")) - 100);       //增加约2个小时的有效时间，以便接下来重新获取
			}
			else  //获取不到，则返回空！                
			{
				HttpContext.Current.Application[QY + "AT_Value" + appid] = "";
				HttpContext.Current.Application[QY + "AT_Time" + appid] = DateTime.Now;
			}
		}
		return HttpContext.Current.Application[QY + "AT_Value" + appid].ToString();
	} 
	
	#endregion

    /// <summary>
    /// 获取个人信息
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    public string GetPersonInfo(string name)
    {
        string rt = "";
        string mySql = @"select u.id as userid,a.cname as username, c.xm as cname, c.rybh,c.yddh as lxdh,c.id as ryid,c.bmmc
                         from wx_t_customers a 
                         inner join wx_t_AppAuthorized b on a.ID=b.UserID and b.SystemID=2
                         inner join rs_v_oaryzhcx c on b.SystemKey=c.id
                         inner join wx_t_AppAuthorized d on a.id=d.userid and d.systemID=1
                         inner join t_user u on d.SystemKey=u.id
                         where a.name=@name";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@name", name.Trim()));
        DataTable dt = new DataTable();
        string errInfo = "";

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_tlsoft))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            para.Clear() ;
        }

        if (errInfo != "")
        {
            rt = errInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "未找到用户信息";
        }
        else
        {

            Session["wxkq_userid"] = Convert.ToString(dt.Rows[0]["userid"]);
            Session["wxkq_username"] = Convert.ToString(dt.Rows[0]["username"]);
            Session["wxkq_rybh"] = Convert.ToString(dt.Rows[0]["rybh"]);
            Session["wxkq_ryid"] = Convert.ToString(dt.Rows[0]["ryid"]);
            Session["wxkq_bmmc"] = Convert.ToString(dt.Rows[0]["bmmc"]);
            Session["wxkq_lxdh"] = Convert.ToString(dt.Rows[0]["lxdh"]);
            rt = clsNetExecute.Successed;
            dt = null;
            mySql = "select userid from userinfo where badgenumber=@rybh";
            para.Add(new SqlParameter("@rybh", Convert.ToString(Session["wxkq_rybh"])));

            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr_att2000))
            {
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
                para = null;
            }
            if (errInfo == "")
            {
                Session["wxkq_checkuserid"] = Convert.ToString(dt.Rows[0]["userid"]);
            }
            else
            {
                rt = errInfo;
            }
        }

        return rt;
    }
</script>
<html>
<head id="Head1" runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>加载2..
    </div>
    </form>
</body>
</html>