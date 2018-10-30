<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    public static string access_token = "";
    public static string access_token_time = "";

    public static string jsapi_ticket = "";
    public static string jsapi_ticket_time = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = "", wxopenid = "";

        try
        {
            ctrl = Request.Params["ctrl"].ToString();// Request.QueryString["ctrl"].ToString();
        }
        catch
        {
            clsSharedHelper.WriteErrorInfo("糟糕！您的网络出了点问题,请稍后访问！");
        }

        string cid = "4";

        string Appid = "wxe4ef27b28da6709f";
        string AppScript = "62e7f8a1f6a879c630f01cf20024c941";

        string result = "";

        switch (ctrl)
        {
            case "JSConfig":
                string url = "";
                try
                {
                    url = Request.Params["myUrl"].ToString();
                }
                catch
                {
                    clsSharedHelper.WriteErrorInfo("糟糕！您的网络出了点问题,请稍后访问！");
                }
                url = url.Replace("|", "&");
                result = JSConfig(url, Appid, AppScript);
                clsSharedHelper.WriteInfo(result);
                break;
            case "checkInfo":

                try
                {
                    wxopenid = Request.Params["wxopenid"].ToString();
                }
                catch
                {
                    clsSharedHelper.WriteErrorInfo("糟糕！您的网络出了点问题,请稍后访问！");
                }
				if(Session["wxopenid"]==null || Session["wxopenid"]==""){
					Session["wxopenid"]=wxopenid;
				}
				
				if(wxopenid==""){
					wxopenid=Session["wxopenid"].ToString();
				}
			
                result = CheckInfo(cid, Appid, AppScript, wxopenid);
                clsSharedHelper.WriteInfo(result);
                break;
            case "AddGameCount":
                string shareType = "", vipid = "";
                vipid = Convert.ToString(Session["vipid"]);
                shareType = Convert.ToString(Request.Params["shareType"]) ;
               
				if(vipid==""){
				 clsSharedHelper.WriteErrorInfo("您停留时间太长了,请重新进入游戏再分享！");
				}else{
				  AddGameCount(vipid, cid, shareType);
                  clsSharedHelper.WriteInfo(Session["vipid"].ToString());
				}
              
                break;
            default:
                clsSharedHelper.WriteInfo("非法访问1");
                break;

        }
        Response.End();
    }

    /**********************获取签名结果*****************************/
    private string JSConfig(string url, string appid, string appScript)
    {
        string rt = "", posturl = "", content = "";
        clsJsonHelper json;
        DateTime currentTime = DateTime.Now;
        if (access_token == "" || access_token_time == "" || DateTime.Compare(currentTime.AddSeconds(-7000), Convert.ToDateTime(access_token_time))>0  )
        {
            posturl = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid={0}&secret={1}";
            posturl = string.Format(posturl, appid, appScript);
            content = common.HttpRequest(posturl);
            json = clsJsonHelper.CreateJsonHelper(content);
            access_token = json.GetJsonValue("access_token");
            access_token_time = currentTime.ToShortTimeString();
        }

        currentTime = DateTime.Now;
        if (jsapi_ticket == "" || jsapi_ticket_time == "" || DateTime.Compare(currentTime.AddSeconds(-7000), Convert.ToDateTime(jsapi_ticket_time)) > 0)
        {
            posturl = "https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token={0}&type=jsapi";
            posturl = string.Format(posturl, access_token);
            content = common.HttpRequest(posturl);
            json = clsJsonHelper.CreateJsonHelper(content);
            jsapi_ticket = json.GetJsonValue("ticket");
            jsapi_ticket_time = currentTime.ToShortTimeString();
        }

        string[] str = calJsApiConfig(appid, jsapi_ticket, url);

        for (int i = 0; i < str.Length; i++)
        {
            rt += str[i] + "|";
        }
        return rt;
    }

    /**********分享成功后统一把游戏可玩次数置为7************/
    private void AddGameCount(string vipid, string cid, string shareType)
    {
        string mySql = "update wx_t_vipBinging set GameCount=7 where id='" + vipid + "';";
        mySql += " insert into wx_t_SharedHistory(UserID,SharedType,CreateTime) values(" + vipid + "," + shareType + ",getdate())";
        DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
        dbHelper.ExecuteNonQuery(mySql);
    }


    private string CheckInfo(string cid, string Appid, string AppScript, string wxopenid)
    {
        string rt = "", posturl = "", content = "";
        clsJsonHelper json;
        DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
        DateTime currentTime = DateTime.Now;

        string sqlcomm = String.Format("select CAST( id as varchar)+'|'+CAST( wxHeadimgurl as varchar(1000))+'|'+ CAST( GameCount-NowCount as varchar)  from [wx_t_vipBinging] where wxOpenid = '{0}' ", wxopenid);
        object reslut = dbHelper.ExecuteScalar(sqlcomm);

        if (reslut != null)
        {
            Session["vipid"] = reslut.ToString().Split('|')[0].ToString();
            rt = reslut.ToString();
        }
        else
        {
            if (access_token == "" || access_token_time == "" || DateTime.Compare(currentTime.AddSeconds(-7000), Convert.ToDateTime(access_token_time))>0)
            {
                posturl = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid={0}&secret={1}";
                posturl = string.Format(posturl, Appid, AppScript);
                content = common.HttpRequest(posturl);
                json = clsJsonHelper.CreateJsonHelper(content);
                access_token = json.GetJsonValue("access_token");
                access_token_time = currentTime.ToShortTimeString();
            }
            posturl = "https://api.weixin.qq.com/cgi-bin/user/info?access_token={0}&openid={1}&lang=zh_CN";
			        
            posturl = String.Format(posturl, access_token, wxopenid);
            content = common.HttpRequest(posturl);
            
            json = clsJsonHelper.CreateJsonHelper(content);
            string errorcode = json.GetJsonValue("errcode");
            
            common.WriteLog(content);
            WXUserInfo user = JsonConvert.DeserializeObject<WXUserInfo>(content);
            if (user.openid != null)
            {
                sqlcomm = @"declare @id  int; insert into wx_t_vipBinging 
                                (wxNick,wxSex,wxLanguage,wxCity,wxProvince,wxCountry,wxHeadimgurl,wxOpenid,GameCount,NowCount,HighScore) 
                                values ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}',6,0,0); set @id=SCOPE_IDENTITY();select @id";
                sqlcomm = string.Format(sqlcomm, user.nickname, user.sex, user.language,
                    user.city, user.province, user.country, user.headimgurl, user.openid);
                reslut = dbHelper.ExecuteScalar(sqlcomm);
                Session["vipid"] = reslut;
                rt = reslut.ToString() + "|" + user.headimgurl + "|6|";
            }
            else
            {
                rt = "Error:无法获取信息;" + errorcode;
               if (errorcode == "40001" || errorcode == "40014" || errorcode == "41001" || errorcode == "42001")
                {
                    access_token ="";
                }
            }
        }
        return rt;
    }


    private string[] calJsApiConfig(string appid, string jsapi_ticket, string url)
    {
        string[] rtString = new string[4];

        //先拼接成string1
        string string1 = "jsapi_ticket={0}&noncestr={1}&timestamp={2}&url={3}";
        string noncestr = Guid.NewGuid().ToString().Replace("-", "");
        noncestr = noncestr.Substring(noncestr.Length - 16);
        string timestamp = ConvertDateTimeInt(DateTime.Now).ToString();
        // string url = HttpContext.Current.Request.Url.ToString();
        if (url.Contains("#")) url = url.Substring(0, url.IndexOf('#'));

        string1 = string.Format(string1, jsapi_ticket, noncestr, timestamp, url);
        //使用SHA1方法，换算成 signature
        string signature = FormsAuthentication.HashPasswordForStoringInConfigFile(string1, "SHA1");
        signature = signature.ToLower();
        rtString[0] = appid;
        rtString[1] = timestamp;
        rtString[2] = noncestr;
        rtString[3] = signature;

        return rtString;
    }

    private int ConvertDateTimeInt(System.DateTime time)
    {
        System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1));
        return (int)(time - startTime).TotalSeconds;
    }

    public static void writeLog(string info)
    {
        clsLocalLoger.logDirectory = HttpContext.Current.Server.MapPath("logs/");
        if (System.IO.Directory.Exists(clsLocalLoger.logDirectory) == false)
        {
            System.IO.Directory.CreateDirectory(clsLocalLoger.logDirectory);
        }
        clsLocalLoger.WriteInfo(info);
    }

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    </div>
    </form>
</body>
</html>
