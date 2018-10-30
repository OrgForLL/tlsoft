<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data"%>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    public static object lockPrize = new object();
    private static DataTable _dtPrize = null;
    private static Int32 TokenIndex = 0;
    private static Random rd = new Random(TokenIndex + DateTime.Now.Millisecond);
    private static DateTime LastLoadTime;//记录dtPrize的最后一次刷新时间
    private const double WINPR = 0.4;
    public static String connStr = "server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456";
    //ActiveTime小于当前时间、未分配到客户的游戏券数据
    private static DataTable dtPrize() {
        DateTime ServerTime = DateTime.Now;        
        if (_dtPrize == null || LastLoadTime == null || ServerTime > LastLoadTime.AddMinutes(30)) {            
            lock (lockPrize) {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr)) {
                    string str_sql = @"select a.*,isnull(b.prizename,'') prizename from tm_t_gamerecords a    
                                       left join tm_t_prize b on a.prizeid=b.id                                    
                                        where a.userid=0 and a.isconsume=0 and a.activetime<'" + ServerTime.ToString() + "'";
                    string errinfo = dal.ExecuteQuery(str_sql,out _dtPrize);
                    if (errinfo != "") {
                        clsSharedHelper.WriteErrorInfo("生成静态dtPrize时出错 errinfo:" + errinfo);
                        return null;
                    }
                    else
                        LastLoadTime = ServerTime;
                }
            }
        }

        return _dtPrize;
    }
    
    protected void Page_Load(object sender, EventArgs e) {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "GenaratePrizePool":
                GenaratePrizePool();
                break;
            case "PlayGame":
                string gamecode = Convert.ToString(Request.Params["gamecode"]);
                string userid = Convert.ToString(Request.Params["userid"]);
                if (gamecode == "" || gamecode == null)
                    clsSharedHelper.WriteErrorInfo("GameCode is error!");
                else if (userid == "" || userid == null)
                    clsSharedHelper.WriteErrorInfo("UserID is error!");
                else
                    PlayGame(gamecode, userid);
                break;
            case "IsCanPlay":
                gamecode = Convert.ToString(Request.Params["gamecode"]);
                userid = Convert.ToString(Request.Params["userid"]);
                if (gamecode == "" || gamecode == null)
                    clsSharedHelper.WriteErrorInfo("GameCode is error!");
                else if (userid == "" || userid == null)
                    clsSharedHelper.WriteErrorInfo("UserID is error!");
                else
                    IsCanPlay(gamecode,userid);
                break;
            case "ConsumeGameToken":
                string token = Convert.ToString(Request.Params["gametoken"]);
                userid = Convert.ToString(Request.Params["userid"]);
                if (token == "" || token == null)
                    clsSharedHelper.WriteErrorInfo("游戏TOKEN参数有误！");
                else if (userid == "" || userid == null)
                    clsSharedHelper.WriteErrorInfo("用户信息参数有误！");
                else
                    ConsumeGameToken(token,userid);                    
                break;
            case "RegisterUserInfo":
                gamecode = Convert.ToString(Request.Params["gamecode"]);
                userid = Convert.ToString(Request.Params["userid"]);
                string idcard = Convert.ToString(Request.Params["idcard"]);
                string phone = Convert.ToString(Request.Params["phone"]);
                string uname = Convert.ToString(Request.Params["username"]);
                if (gamecode == "" || gamecode == null)
                    clsSharedHelper.WriteErrorInfo("GameCode is error!");
                else if (userid == "" || userid == null)
                    clsSharedHelper.WriteErrorInfo("UserID is error!");
                else
                    RegisterUserInfo(userid,idcard,phone,gamecode,uname);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无效的控制参数！ctrl:" + ctrl);
                break;
        }
    }
    
    //游戏开始前判断用户是否能玩 直接判断领奖纪录表
    private void IsCanPlay(string gamecode, string userid)
    {        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            //先判断游戏是否可玩
            string str_sql = @"select id from tm_t_gametype where gamecode=@gcode and isactive=1";
            List<SqlParameter> paras = new List<SqlParameter>();
            DataTable dt = null;            
            paras.Add(new SqlParameter("@gcode", gamecode));
            string errinfo = dal.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (!(errinfo == "" && dt.Rows.Count > 0)) {
                clsSharedHelper.WriteErrorInfo("获取游戏配置信息失败！Active");
                return;                    
            }                
            //再判断用户今天是否已经玩过
            str_sql = @"select top 1 a.*,c.prizename
                        from tm_t_gamerecords a                                 
                        left join tm_t_prize c on a.prizeid=c.id
                        where a.gamecode=@gcode and a.userid=@userid and a.isconsume=1 
                        and convert(varchar(10),getdate(),120)=convert(varchar(10),a.gametime,120)
                        order by a.gametime desc;";
            paras.Clear();
            dt = null;
            paras.Add(new SqlParameter("@gcode", gamecode));
            paras.Add(new SqlParameter("@userid", userid));            
            errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count == 0)//找不到记录说明用户当天还没玩过
                    clsSharedHelper.WriteSuccessedInfo("");
                else
                {
                    if (dt.Rows[0]["userinfo"].ToString() == "0")
                        clsSharedHelper.WriteInfo("您还未进行用户信息登记！|" + dt.Rows[0]["gametime"].ToString() + "|" + dt.Rows[0]["prizename"].ToString());
                    else
                        clsSharedHelper.WriteInfo("对不起，您今天已经玩过，请明天再来吧。");
                }
            }
            else
                clsSharedHelper.WriteErrorInfo("查询用户今日历史游戏数据时出错 errinfo:" + errinfo);
        }
    }

    //开奖方法
    private void PlayGame(string gamecode,string userid) {
        string rtMsg = "";        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr)) {
            //首先判断用户是否有绑定但未消费的游戏券
            string str_sql = @"select top 1 a.gametoken,a.prizeid,isnull(b.prizename,'') prizename
                                from tm_t_gamerecords a 
                                left join tm_t_prize b on a.prizeid=b.id
                                where a.gamecode=@gcode and a.userid=@userid and a.isconsume=0 order by a.gametime desc";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid",userid));
            paras.Add(new SqlParameter("@gcode",gamecode));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    rtMsg = dt.Rows[0]["gametoken"].ToString() + "|" + dt.Rows[0]["prizeid"].ToString()+"|"+dt.Rows[0]["prizename"].ToString();
                else
                {
                    DataTable PDT = dtPrize();
                    lock (lockPrize)
                    {
                        int PrizeCount = PDT.Rows.Count;//当前可用的游戏券券数
                        int MaxNext = Convert.ToInt32(PrizeCount / WINPR);
                        int PrizeIndex = PrizeCount > 0 ? rd.Next(1, MaxNext) : 0;
                        TokenIndex++;
                        if (PrizeIndex < PrizeCount)
                        {
                            str_sql = "update tm_t_gamerecords set gamecode='" + gamecode + "',userid='" + userid + "',gametime=getdate(),ip='" + HttpContext.Current.Request.UserHostAddress + "' where id='" + PDT.Rows[PrizeIndex]["id"].ToString() + "'";
                            errinfo = dal.ExecuteNonQuery(str_sql);
                            if (errinfo == "")
                            {                                                               
                                rtMsg = PDT.Rows[PrizeIndex]["gametoken"].ToString() + "|" + PDT.Rows[PrizeIndex]["prizeid"].ToString() + "|" + PDT.Rows[PrizeIndex]["prizename"].ToString();
                                //先取出数据再移除dtPrize中的此行数据 
                                PDT.Rows.Remove(PDT.Rows[PrizeIndex]);
                            }
                            else
                                rtMsg = "Error:更新游戏占用状态时失败 errinfo:" + errinfo;
                        }
                        else { 
                            //否则直接创建一行游戏券信息到数据库ID=0 并返回结果
                            string gtoken = System.Guid.NewGuid().ToString();
                            str_sql = @"insert into tm_t_gamerecords(gamecode,userid,gametoken,isconsume,prizeid,isgetprize,activetime,gametime,ip) 
                                        values(@gcode,@userid,@gtoken,0,0,0,getdate(),getdate(),@ip);";
                            paras.Clear();
                            paras.Add(new SqlParameter("@gcode", gamecode));
                            paras.Add(new SqlParameter("@userid", userid));
                            paras.Add(new SqlParameter("@gtoken", gtoken));
                            paras.Add(new SqlParameter("@ip", HttpContext.Current.Request.UserHostAddress));
                            errinfo = dal.ExecuteNonQuerySecurity(str_sql,paras);
                            if (errinfo == "")
                                rtMsg = gtoken + "|0|鼓励奖";
                            else
                                rtMsg = "Error:创建游戏券信息失败 errinfo:" + errinfo;
                        }                            
                    }//end lock
                }
            }
            else
                rtMsg = "Error:调用PlayGame时出错 errinfo:" + errinfo;
        }
            
        clsSharedHelper.WriteInfo(rtMsg);
    }
    
    //生成每天生成奖品池的方法 不区分是哪种游戏
    private void GenaratePrizePool() {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr)) {
            //先查询今天到此刻为止有没有游戏记录，主要是怕当天临时变动
            string str_sql = @"select a.prizeid,count(a.id) sl into #tmp
                                from tm_t_gamerecords a                                
                                where a.userid<>0 and a.isconsume=1 and a.prizeid<>0
                                and a.gametime>=convert(varchar(10),getdate(),120) 
                                and a.gametime<dateadd(day,1,convert(varchar(10),getdate(),120))
                                group by a.prizeid;
                                select a.*,a.numsperday-isnull(b.sl,0) todaynums 
                                from tm_t_prize a left join #tmp b on a.id=b.prizeid 
                                where a.id<>0;
                                drop table #tmp;
                                delete from tm_t_gamerecords
                                where userid=0 and isconsume=0 ";
            DataTable dtTodayPrize = null;
            string errinfo = dal.ExecuteQuery(str_sql,out dtTodayPrize);
            if (errinfo == "")
            {
                if (dtTodayPrize.Rows.Count > 0)
                {
                    //生成算法调整将每个奖项平分到一天当中 
                    //需要用到的变量
                    int timeblock = 0, prizeNum = 0;
                    string gametoken = "", activetime = "", prizeID = "";
                    int prizeSum = Convert.ToInt32(dtTodayPrize.Compute("sum(todaynums)", ""));
                    if (prizeSum > 0) {
                        for (int i = 0; i < dtTodayPrize.Rows.Count; i++)
                        {
                            prizeNum = Convert.ToInt32(dtTodayPrize.Rows[i]["todaynums"]);
                            if (prizeNum <= 0) continue;
                            prizeID = dtTodayPrize.Rows[i]["id"].ToString();
                            timeblock = Convert.ToInt32(Math.Floor(Convert.ToDouble(24 * 60 * 60 / prizeNum)));
                            int tcount = 0;
                            str_sql = "";
                            for (int j = 0; j < prizeNum; j++)
                            {
                                gametoken = System.Guid.NewGuid().ToString();
                                activetime = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd")).AddSeconds(timeblock * tcount).ToString();
                                tcount++;
                                str_sql += "insert into tm_t_gamerecords(gamecode,userid,gametoken,isconsume,prizeid,isgetprize,activetime)";
                                str_sql += " values ('',0,'" + gametoken + "',0,'" + prizeID + "',0,'" + activetime + "')";
                            }//end for j 
                            errinfo = dal.ExecuteNonQuery(str_sql);
                            if (errinfo != "")
                            {
                                clsSharedHelper.WriteErrorInfo("生成奖品【" + prizeID + "】池时出错 errinfo:" + errinfo);
                                break;
                            }                            
                        }//end for i
                    }else
                        clsSharedHelper.WriteErrorInfo("游戏奖品配置信息有误！"); 
                }
                else
                    clsSharedHelper.WriteErrorInfo("还未配置游戏奖品信息！");
            }
            else
                clsSharedHelper.WriteErrorInfo("生成游戏奖池数据查询数据失败 errinfo:"+errinfo);                
        }
    }
    
    //消费游戏券方法
    private void ConsumeGameToken(string token,string userid) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr)) {
            string str_sql = @"update a set a.isconsume=1,a.consumetime=getdate(),a.userinfo=isnull(b.id,0)
                                from tm_t_gamerecords a 
                                left join tm_t_UserInfo b on a.userid=b.userid
                                where a.gametoken=@token and a.userid=@userid and isconsume=0;
                                select top 1 userinfo from tm_t_gamerecords where gametoken=@token and userid=@userid;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@token", token));
            paras.Add(new SqlParameter("@userid", userid));
            DataTable dt=null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string userinfo = dt.Rows[0][0].ToString();
                    if (userinfo == "0" || userinfo == "")
                        clsSharedHelper.WriteInfo("Warn:您还未进行用户信息登记！");
                    else
                        clsSharedHelper.WriteSuccessedInfo("");
                }
                else
                    clsSharedHelper.WriteErrorInfo("GameToken【" + token + "】无效！ PDT:" + dtPrize().Rows.Count.ToString());
            }
            else
                clsSharedHelper.WriteErrorInfo("ConsumeGameToken Fail! errinfo:" + errinfo);
        }    
    }

    //登记用户信息方法
    private void RegisterUserInfo(string userid,string idcard,string phone,string gamecode,string uname) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"declare @id int;
                            if not exists(select top 1 1 from tm_t_userinfo where userid=@userid) 
                            begin 
                            insert into tm_t_userinfo(userid,idcard,phone,createtime,username) values (@userid,@idcard,@phone,getdate(),@username);
                            select @id=@@IDENTITY; 
                            end 
                            update tm_t_gamerecords set userinfo=@id where userid=@userid and isconsume=1 and gamecode=@gamecode;
                            select isnull(@id,0);";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid", userid));
            paras.Add(new SqlParameter("@idcard", idcard));
            paras.Add(new SqlParameter("@phone", phone));
            paras.Add(new SqlParameter("@gamecode", gamecode));
            paras.Add(new SqlParameter("@username", uname));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
                clsSharedHelper.WriteSuccessedInfo("");
            else
                clsSharedHelper.WriteErrorInfo("登记用户信息时出错 errinfo:" + errinfo);
        }
    }
</script>
<!DOCTYPE html>
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
