<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<!DOCTYPE html>
<script runat="server">
    //利郎男装公众号
    private string AppID = "wxc368c7744f66a3d7";
    private string AppSecret = "74ebc70df1f964680bd3bdd2f15b4bed";
    public static String connStr = "server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456";
    public string parentUrl = "";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string sessionid = Convert.ToString(Session["TM_WXUserID"]);
        string code = Convert.ToString(Request.Params["code"]);
        string state = Convert.ToString(Request.Params["state"]);//目标页地址
        //防止页面刷新导致CODE失效问题
        if (!(sessionid == "" || sessionid == null))
        {
            Response.Redirect(state);
            return;
        }          
                  
        parentUrl = state;
        if (code == "" || code == null)
        {
            clsSharedHelper.WriteErrorInfo("缺少code参数！");
            return;
        }
        else if (state == "" || state == null) {
            clsSharedHelper.WriteErrorInfo("缺少state参数！");
            return;
        }

        try
        {
            string posturl = @"https://api.weixin.qq.com/sns/oauth2/access_token?appid={0}&secret={1}&code={2}&grant_type=authorization_code";
            posturl = string.Format(posturl, AppID, AppSecret, code);
            string content = HttpRequest(posturl);
            if (!CheckResult(content, ""))
            {
                writeLog("通过CODE换取OPENID时出错！" + content + "\r\n CODE:" + code);
                clsSharedHelper.WriteInfo("通过CODE换取OPENID时出错,请关掉后重试！");
                return;
            }
            JsonSerializerSettings jSetting = new JsonSerializerSettings();
            jSetting.NullValueHandling = NullValueHandling.Ignore;
            WXAccessToken wx = JsonConvert.DeserializeObject<WXAccessToken>(content, jSetting);
            string userid = GetWXUserID(wx.AccessToken, wx.Openid);
            if (userid == "" || userid == "0" || userid == null)
            {
                clsSharedHelper.WriteErrorInfo("获取用户微信信息失败，请关掉重试！");
            }
            else
            {
                Session["TM_WXUserID"] = userid;                         
                Response.Redirect(state, false);
                //Response.End();
            }
        }
        catch (Exception ex) {
            //writeLog("NEW TMOauthAndRedirect.aspx " + ex.StackTrace);
        }
                  
    }

    public string GetWXUserID(string access_token,string openid)
    {
        string userid = "", posturl = "", content = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"select top 1 id from wx_t_vipBinging where objectid=101 and wxopenid=@wxopenid";            
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@wxopenid",openid));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count == 0)
                {
                    //新用户 获取用户信息并存入数据库
                    posturl = "https://api.weixin.qq.com/sns/userinfo?access_token={0}&openid={1}&lang=zh_CN";
                    posturl = String.Format(posturl, access_token, openid);
                    content = HttpRequest(posturl);                    
                    WXUserInfo user = JsonConvert.DeserializeObject<WXUserInfo>(content);
                    if (!CheckResult(content,openid))
                    {
                        clsSharedHelper.WriteInfo("请先关注LILANZ利郎商务男装公众号，再重试！");
                        Response.End();
                    }
                    str_sql = @"insert into wx_t_vipBinging 
                                (wxNick,wxSex,wxLanguage,wxCity,wxProvince,wxCountry,wxHeadimgurl,wxOpenid,ObjectID,gamecount,nowcount) 
                                values ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}',{8},{9},{10});select @@IDENTITY;";
                    str_sql = string.Format(str_sql, user.nickname, user.sex, user.language, user.city, user.province, user.country, user.headimgurl, openid, "101", 1, 0);
                    errinfo = dal.ExecuteQuery(str_sql, out dt);
                    if (errinfo == "" && dt.Rows.Count > 0)
                    {
                        userid = dt.Rows[0][0].ToString();
                    }
                    else
                        clsSharedHelper.WriteErrorInfo("创建微信用户信息失败！" + errinfo);
                }
                else
                    userid = dt.Rows[0]["id"].ToString();
            }
            else
                clsSharedHelper.WriteErrorInfo("查询微信用户信息失败！" + errinfo);
        }

        return userid;
    }
    
    public static void writeLog(string info)
    {
        try
        {
            clsLocalLoger.logDirectory = HttpContext.Current.Server.MapPath("logs/");
            if (System.IO.Directory.Exists(clsLocalLoger.logDirectory) == false)
            {
                System.IO.Directory.CreateDirectory(clsLocalLoger.logDirectory);
            }
            clsLocalLoger.WriteInfo(info);
        }
        catch (Exception ex)
        {

        }
    } 
    
    public string HttpRequest(string url)
    {
        HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
        request.ContentType = "application/x-www-form-urlencoded";

        HttpWebResponse myResponse = (HttpWebResponse)request.GetResponse();
        StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8);
        return reader.ReadToEnd();//得到结果
    }
    
    /// <summary>
    /// 检查执行是否错误(仅用于公众号)；如果Token异常则清空它以便下次重新获取新的
    /// </summary>
    /// <param name="content"></param>
    /// <returns></returns>
    private bool CheckResult(string content,string openid)
    {
        try
        {
            using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content))
            {
                string errcode = jh.GetJsonValue("errcode");
                if (errcode != "" && errcode != "0")
                {
                    writeLog("2015福利会游戏检查结果错误：OPENID:" + openid + "\r\nCONTENT:" + content);
                    return false;
                }
                else
                {
                    return true;
                }
            }
        }
        catch (Exception ex)
        {

            writeLog("2015福利会游戏检查执行结果错误：" + ex.Message);
            return false;
        }
    }
    
    public class WXAccessToken
    {

        private String accessToken;

        [JsonProperty("access_token")]
        public String AccessToken
        {
            get { return accessToken; }
            set { accessToken = value; }
        }


        private int expiresIn;

        [JsonProperty("expires_in")]
        public int ExpiresIn
        {
            get { return expiresIn; }
            set { expiresIn = value; }
        }


        private String refreshToken;

        [JsonProperty("refresh_token")]
        public String RefreshToken
        {
            get { return refreshToken; }
            set { refreshToken = value; }
        }


        private String openid;

        [JsonProperty("openid")]
        public String Openid
        {
            get { return openid; }
            set { openid = value; }
        }


        private String scope;

        [JsonProperty("scope")]
        public String Scope
        {
            get { return scope; }
            set { scope = value; }
        }

    }

    public class WXUserInfo
    {
        public string openid;
        public string nickname;
        public string sex;
        public string language;
        public string city;
        public string province;
        public string country;
        public string headimgurl;
        public string[] privilege;
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
