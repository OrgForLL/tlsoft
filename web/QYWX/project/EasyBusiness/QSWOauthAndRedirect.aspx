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
    //利郎轻商务公众号
    private string AppID = "wx60aada4e94aa0b73";
    private string AppSecret = "5baaa8061418367e557f2591b03162e5";
    private string WXDBConStr = "server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456";
    //private string ConnStr = clsConfig.GetConfigValue("OAConnStr");//正式库
    private string ConnStr = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
    private const string ConfigKey = "7";//利郎轻商务   
    public string parentUrl = "";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string sessionid = Convert.ToString(Session["QSW_UID"]);
        string code = Convert.ToString(Request.Params["code"]);//微信用户鉴权的CODE
        string state = Convert.ToString(Request.Params["state"]);//目标页地址
        string psharedkey = Convert.ToString(Request.Params["rand"]);//由谁分享的链接打开的
        
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
            //S1通过CODE获取网页授权access_token、OPENID、UnionID
            string APIURL = string.Format(@"https://api.weixin.qq.com/sns/oauth2/access_token?appid={0}&secret={1}&code={2}&grant_type=authorization_code", AppID, AppSecret, code);
            string content = HttpRequest(APIURL);
            if (clsWXHelper.CheckResult(ConfigKey,content))
            {
                string token = clsWXHelper.GetAT(ConfigKey);
                using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content)) {
                    //S2接下为拉取用户信息
                    APIURL = string.Format("https://api.weixin.qq.com/sns/userinfo?access_token={0}&openid={1}&lang=zh_CN", jh.GetJsonValue("access_token"), jh.GetJsonValue("openid"));
                    content = HttpRequest(APIURL);
                    if (clsWXHelper.CheckResult(ConfigKey, content))
                    {
                        //S3检查该用户在本地是否已建档
                        int UID = UserInfoCreateGetID(psharedkey, content);
                        if (UID > 0) {                            
                            Session["QSW_UID"] = UID;
                            Session["QSW_UTYPE"] = "WeiXin";                        
                            Response.Redirect(state, false);
                        }
                        else
                            writeLog("执行结果错误 " + content);
                    }
                    else {
                        writeLog("轻商务游戏 拉取用户信息时失败！" + content + "\r\n CODE:" + code);
                        clsSharedHelper.WriteInfo("轻商务游戏 拉取用户信息时失败,请关掉后重试！");
                        return;
                    }
                }//end using
            }
            else
            {                
                writeLog("轻商务游戏 通过CODE换取OPENID时出错！" + content + "\r\n CODE:" + code);
                clsSharedHelper.WriteInfo("轻商务游戏 通过CODE换取OPENID时出错,请关掉后重试！" + content);
                return;
            }
        }
        catch (Exception) { }
                  
    }

    private int CreateCheckUserGameData(string VID,string psharedkey,string content) {
        try
        {            
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConStr)) {
                clsJsonHelper cjh = clsJsonHelper.CreateJsonHelper(content);                
                string str_sql = @"declare @ID int;declare @PID int;declare @GID int;
                                    select @ID=0,@PID=0,@GID=0;
                                    select top 1 @ID=id from wx_t_userinfo where wxunionid=@unionid;                                    
                                    if @psharedkey <> ''
                                      select top 1 @PID=userid from wx_t_usergameinfos where sharedkey=@psharedkey and sskey=@sskey and gameid=@gameid;
                                    if @ID=0
                                    begin
                                      insert into wx_t_userinfo(username,sex,location,wxunionid) values (@nickname,@sex,@location,@unionid);
                                      select @ID=@@IDENTITY;
                                      insert into wx_t_usergameinfos(userid,gameid,gamecounts,nowcounts,sharedkey,relationuid,sskey,weixinid,wxopenid) 
                                      values (@ID,@gameid,5,0,@sharedkey,@PID,@sskey,@vid,@openid);
                                      update wx_t_usergameinfos set gamecounts=gamecounts+1 where sskey=@sskey and gameid=@gameid and userid=@PID;
                                    end
                                    else 
                                      begin
                                        select top 1 @GID=id from wx_t_usergameinfos where userid=@ID and sskey=@sskey and gameid=@gameid;
                                        if @GID=0
                                          begin
                                          insert into wx_t_usergameinfos(userid,gameid,gamecounts,nowcounts,sharedkey,relationuid,sskey,weixinid,wxopenid) 
                                          values (@ID,@gameid,5,0,@sharedkey,@PID,@sskey,@vid,@openid);
                                          update wx_t_usergameinfos set gamecounts=gamecounts+1 where sskey=@sskey and gameid=@gameid and userid=@PID;
                                          end
                                      end
                                    select @ID;";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@unionid", cjh.GetJsonValue("unionid")));
                paras.Add(new SqlParameter("@psharedkey", psharedkey));
                paras.Add(new SqlParameter("@sskey", ConfigKey));
                paras.Add(new SqlParameter("@gameid", "1"));
                paras.Add(new SqlParameter("@nickname", cjh.GetJsonValue("nickname")));
                paras.Add(new SqlParameter("@sex", cjh.GetJsonValue("sex")));
                paras.Add(new SqlParameter("@location", cjh.GetJsonValue("province") + "-" + cjh.GetJsonValue("city")));
                paras.Add(new SqlParameter("@sharedkey", GenerateKey(12)));
                paras.Add(new SqlParameter("@vid", VID));
                paras.Add(new SqlParameter("@openid", cjh.GetJsonValue("openid")));
                object scalar;
                string errinfo = dal62.ExecuteQueryFastSecurity(str_sql,paras,out scalar);
                if (errinfo == "")
                    return Convert.ToInt32(scalar);
                else {
                    writeLog("利郎轻商务游戏 检查创建用户游戏档案(S2)失败！错误：" + errinfo + " 【SQL】:" + str_sql);
                    return -1;
                }
            }
        }//end try
        catch (Exception ex) {
            writeLog("利郎轻商务游戏 检查创建用户游戏数据时出错：" + ex.Message);
            return -1;
        }
    }
    
    //创建或者是获取用户ID 如果不存在则新增
    private int UserInfoCreateGetID(string psharedkey,string content) {
        try
        {
            using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content))
            {
                string sqlcomm = @"DECLARE @ID INT,@ObjectID INT;
                SELECT @ID = 0,@ObjectID = 4;
                SELECT TOP 1 @ID = ID FROM wx_t_vipBinging WHERE wxOpenid = @openid and objectid=@ObjectID;
                IF (@ID = 0)	    
                BEGIN
	                INSERT INTO [wx_t_vipBinging]([wxNick],[wxSex],[wxLanguage],[wxCity],[wxProvince],[wxCountry],[wxHeadimgurl],[wxOpenid],createTime,[ObjectID],wxUnionid)
								                VALUES (@nickname,@sex,@language,@city,@province,@country,@headimgurl,@openid,GetDate(),@ObjectID,@wxUnionid);
                    SELECT @ID = @@IDENTITY;
                END
                ELSE
	                UPDATE wx_t_vipBinging SET wxNick = @nickname,wxSex = @sex,wxLanguage = @language,wxCity = @city,wxProvince = @province
								                ,wxCountry = @country,wxHeadimgurl = @headimgurl,wxUnionid=@wxUnionid WHERE ID = @ID;
                SELECT @ID;";

                List<SqlParameter> listSqlParameter = new List<SqlParameter>();

                listSqlParameter.Add(new SqlParameter("@openid", jh.GetJsonValue("openid")));
                listSqlParameter.Add(new SqlParameter("@nickname", jh.GetJsonValue("nickname")));
                listSqlParameter.Add(new SqlParameter("@sex", jh.GetJsonValue("sex")));
                listSqlParameter.Add(new SqlParameter("@language", jh.GetJsonValue("language")));
                listSqlParameter.Add(new SqlParameter("@city", jh.GetJsonValue("city")));
                listSqlParameter.Add(new SqlParameter("@province", jh.GetJsonValue("province")));
                listSqlParameter.Add(new SqlParameter("@country", jh.GetJsonValue("country")));
                listSqlParameter.Add(new SqlParameter("@headimgurl", jh.GetJsonValue("headimgurl").Replace("\\", "")));
                listSqlParameter.Add(new SqlParameter("@wxUnionid", jh.GetJsonValue("unionid")));
                
                using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(ConnStr))
                {
                    object scalar;
                    string strInfo = dal10.ExecuteQueryFastSecurity(sqlcomm, listSqlParameter, out scalar);
                    if (strInfo == "")
                    {
                        string WXID = Convert.ToString(scalar);
                        //S4检查用户的游戏数据
                        int UID = CreateCheckUserGameData(WXID, psharedkey, content);
                        if (UID != -1) {
                            updateVipIDByUnionID(jh.GetJsonValue("unionid"));
                            return UID;
                        }
                        else
                            return 0;                                
                    }
                    else
                    {
                        writeLog("利郎轻商务游戏 检查创建用户信息档案(S1)失败！错误：" + strInfo + " 【SQL】:" + sqlcomm);
                        return 0;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            writeLog("利郎轻商务游戏 存储用户信息错误：" + ex.Message);
            return 0;
        }
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
        
    //网络请求
    public string HttpRequest(string url)
    {
        HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
        request.ContentType = "application/x-www-form-urlencoded";

        HttpWebResponse myResponse = (HttpWebResponse)request.GetResponse();
        StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8);
        return reader.ReadToEnd();//得到结果
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

    //此方法用于更新同一个UINIONID所对应的VIPID，在生成微信用户资料时调用一次即可
    //前期仅用在利郎男装(objectid=1)与利郎轻商务(objectid=4)的会员打通
    public string updateVipIDByUnionID(string unionid)
    {
        string msg = "";
        using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(ConnStr))
        {
            string str_sql = @"declare @vipid int;
                                select top 1 @vipid=vipid from wx_t_vipbinging where objectid in (1,4) and wxunionid=@unionid and vipid>0;
                                if isnull(@vipid,0)<>0
                                  update wx_t_vipbinging set vipid=@vipid where objectid in (1,4) and wxunionid=@unionid and vipid=0";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@unionid", unionid));
            msg = dal10.ExecuteNonQuerySecurity(str_sql, paras);
        }//end using

        return msg;
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
