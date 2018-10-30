<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html>
<script runat="server"> 
    private string AppKey = "3836648073";
    private string AppSecret = "52dad9817e10a13e66e06664eaacd021";
    private string WXDBConStr = "server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456";
    //private string ConnStr = clsConfig.GetConfigValue("OAConnStr");//正式库    
    private string ConnStr = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
    private const string ConfigKey = "7";//利郎轻商务      

    protected void Page_Load(object sender, EventArgs e)
    {
        string sessionid = Convert.ToString(Session["QSW_UID"]);
        string code = Convert.ToString(Request.Params["code"]);
        string intro = Convert.ToString(Request.Params["intro"]);
        //防止页面刷新导致CODE失效问题
        if (!(sessionid == "" || sessionid == null))
        {
            Response.Redirect("nggkGame.aspx", false);
            return;
        } 
        
        if (code == "" || code == null)
        {
            clsSharedHelper.WriteErrorInfo("缺少code参数！");
            return;
        }
        try
        {
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConStr))
            {
                //通过CODE换取ACCESS_TOKEN
                string url = "https://api.weibo.com/oauth2/access_token?client_id={0}&client_secret={1}&grant_type=authorization_code&redirect_uri=http://tm.lilanz.com/project/EasyBusiness/WeiBoOAuth.aspx&code=" + code;
                url = string.Format(url, AppKey, AppSecret);
                string rt = clsNetExecute.HttpRequest(url, "", "post", "utf-8", 5000);
                JObject jh = JObject.Parse(rt);
                string uid = Convert.ToString(jh["uid"]);
                string access_token = Convert.ToString(jh["access_token"]);
                //通过ACCESS_TOKEN获取用户信息
                url = string.Format("https://api.weibo.com/2/users/show.json?access_token={0}&uid={1}", access_token, uid);
                string userinfo = clsNetExecute.HttpRequest(url);
                int UID = CreateCheckUserGameData(uid, intro, userinfo);
                if (UID > 0)
                {
                    Session["QSW_UID"] = UID;
                    Session["QSW_UTYPE"] = "WeiBo";                    
                    Response.Redirect("nggkGame.aspx", false);
                }
                else
                    writeLog("微博认证失败 执行结果错误 " + userinfo);
            }
        }
        catch (Exception ex) {
            writeLog("轻商务游戏 微博认证失败" + ex.Message);
            clsSharedHelper.WriteInfo("利郎轻商务游戏 微博认证失败，请稍后重试！");
            return;
        }
    }

    private int CreateCheckUserGameData(string WBUID, string psharedkey, string content) {
        try {
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConStr)) {
                clsJsonHelper cjh = clsJsonHelper.CreateJsonHelper(content);
                string str_sql = @"declare @ID int;declare @PID int;declare @GID int;
                                    select @ID=0,@PID=0,@GID=0;
                                    select top 1 @ID=id from wx_t_userinfo where WeiBoID=@WBUID;                                    
                                    if @psharedkey <> ''
                                      select top 1 @PID=userid from wx_t_usergameinfos where sharedkey=@psharedkey and sskey=@sskey and gameid=@gameid;
                                    if @ID=0
                                    begin
                                      insert into wx_t_userinfo(username,sex,location,WeiBoID) values (@nickname,@sex,@location,@WBUID);
                                      select @ID=@@IDENTITY;
                                      insert into wx_t_usergameinfos(userid,gameid,gamecounts,nowcounts,sharedkey,relationuid,sskey) 
                                      values (@ID,@gameid,5,0,@sharedkey,@PID,@sskey);
                                      update wx_t_usergameinfos set gamecounts=gamecounts+1 where sskey=@sskey and gameid=@gameid and userid=@PID;
                                    end
                                    else 
                                      begin
                                        select top 1 @GID=id from wx_t_usergameinfos where userid=@ID and sskey=@sskey and gameid=@gameid;
                                        if @GID=0
                                          begin
                                          insert into wx_t_usergameinfos(userid,gameid,gamecounts,nowcounts,sharedkey,relationuid,sskey) 
                                          values (@ID,@gameid,5,0,@sharedkey,@PID,@sskey);
                                          update wx_t_usergameinfos set gamecounts=gamecounts+1 where sskey=@sskey and gameid=@gameid and userid=@PID;
                                          end
                                      end
                                    select @ID;";

                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@WBUID", WBUID));
                paras.Add(new SqlParameter("@psharedkey", psharedkey));
                paras.Add(new SqlParameter("@sskey", ConfigKey));
                paras.Add(new SqlParameter("@gameid", "1"));
                paras.Add(new SqlParameter("@nickname", cjh.GetJsonValue("name")));
                paras.Add(new SqlParameter("@sex", cjh.GetJsonValue("gender")));
                paras.Add(new SqlParameter("@location", cjh.GetJsonValue("location")));
                paras.Add(new SqlParameter("@sharedkey", GenerateKey(12)));
                object scalar;
                string errinfo = dal62.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                if (errinfo == "")
                    return Convert.ToInt32(scalar);
                else
                {
                    writeLog("利郎轻商务游戏 微博认证失败检查创建用户游戏档案失败！错误：" + errinfo);
                    return -1;
                }                
            }
        }
        catch (Exception ex)
        {
            writeLog("利郎轻商务游戏 微博认证检查创建用户游戏数据时出错：" + ex.Message);
            return -1;
        }    
    }

    //生成指定位数的随机串
    private int rep = 0;
    public string GenerateKey(int codeCount)
    {
        string str = string.Empty;
        long num2 = DateTime.Now.Ticks + this.rep;
        this.rep++;
        Random random = new Random(((int)(((ulong)num2) & 0xffffffffL)) | ((int)(num2 >> this.rep)));
        for (int i = 0; i < codeCount; i++)
        {
            char ch;
            int num = random.Next();
            if ((num % 2) == 0)
            {
                ch = (char)(0x30 + ((ushort)(num % 10)));
            }
            else
            {
                ch = (char)(0x41 + ((ushort)(num % 0x1a)));
            }
            str = str + ch.ToString();
        }
        return str;
    }
    
    //写日志方法
    public static void writeLog(string info)
    {
        try
        {
            clsLocalLoger.logDirectory = string.Concat(HttpContext.Current.Server.MapPath("~"), "\\Logs");
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
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
</body>
</html>
