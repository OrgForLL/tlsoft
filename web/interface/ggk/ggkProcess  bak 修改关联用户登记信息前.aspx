<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    public static object lockPrize = new object();
    private static DataTable _dtPrize = null;
    private static Int32 TokenIndex = 1;
    private static DateTime LastLoadTime;//记录dtPrize的最后一次刷新时间
    private const double WINPR = 0.4;//游戏中奖因子
    public static String connStr = "server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456";    

    //ActiveTime小于当前时间、未分配到客户的游戏券数据
    private static DataTable dtPrize()
    {
        DateTime ServerTime = DateTime.Now;
        if (_dtPrize == null || LastLoadTime == null || ServerTime > LastLoadTime.AddMinutes(30))
        {
            lock (lockPrize)
            {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
                {
                    string str_sql = @"select a.*,isnull(b.prizename,'') prizename from tm_t_gamerecords a    
                                       left join tm_t_prize b on a.prizeid=b.id                                    
                                       where a.userid=0 and a.isconsume=0 and a.activetime<'" + ServerTime.ToString() + "'";
                    string errinfo = dal.ExecuteQuery(str_sql, out _dtPrize);
                    if (errinfo != "")
                    {
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

    protected void Page_Load(object sender, EventArgs e)
    {
        string sessionid = Convert.ToString(Session["TM_WXUserID"]);
        if (sessionid == null || sessionid == "" || sessionid == "0")
        {
            clsSharedHelper.WriteInfo("TimeOut:SESSION超时");
            return;
        }

        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
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
                        clsSharedHelper.WriteErrorInfo("请输入合法的日期！");
                        return;
                    }

                    GenaretePrizePool(GTime);
                }
                break;
            case "IsCanPlay":
                string gameid = Convert.ToString(Request.Params["gameid"]);
                string userid = Convert.ToString(Request.Params["userid"]);
                if (gameid == "" || gameid == null || gameid == "0")
                    clsSharedHelper.WriteErrorInfo("GameID is error!");
                else if (userid == "" || userid == null)
                    clsSharedHelper.WriteErrorInfo("UserID is error!");
                else
                    IsCanPlay(gameid, userid);
                break;
            case "ConsumeGameToken":
                string token = Convert.ToString(Request.Params["gametoken"]);
                gameid = Convert.ToString(Request.Params["gameid"]);
                userid = Convert.ToString(Request.Params["userid"]);
                if (token == "" || token == null)
                    clsSharedHelper.WriteErrorInfo("GameToken is error!");
                else if (userid == "" || userid == null)
                    clsSharedHelper.WriteErrorInfo("UserID is error!");
                else
                    ConsumeGameToken(token, userid, gameid);
                break;
            case "RegisterUserInfo":
                userid = Convert.ToString(Request.Params["userid"]);
                string idcard = Convert.ToString(Request.Params["idcard"]);
                string phone = Convert.ToString(Request.Params["phone"]);
                string uname = Convert.ToString(Request.Params["username"]);
                if (userid == "" || userid == null)
                    clsSharedHelper.WriteErrorInfo("UserID is error!");
                else
                    RegisterUserInfo(userid, idcard, phone, uname);
                break;
            case "DelGameDatas":
                GTime = Convert.ToString(Request.Params["gtime"]);
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
                        clsSharedHelper.WriteErrorInfo("请输入合法的日期！");
                        return;
                    }

                    DelGameDatas(GTime);
                }
                break;
            case "GetMyGifts":
                userid = Convert.ToString(Request.Params["userid"]);
                string filter = Convert.ToString(Request.Params["filter"]);
                if (userid == "" || userid == "0" || userid == null)
                    clsSharedHelper.WriteErrorInfo("UserID is error!");
                else
                    GetMyGift(userid, filter);
                break;
            case "GetGiftDetail":
                token = Convert.ToString(Request.Params["gametoken"]);
                userid = Convert.ToString(Request.Params["userid"]);
                gameid = Convert.ToString(Request.Params["gameid"]);
                if (token == "" || token == null)
                    clsSharedHelper.WriteErrorInfo("GameToken is error!");
                else if (userid == "" || userid == null)
                    clsSharedHelper.WriteErrorInfo("UserID is error!");
                else
                    GetGiftDetail(token, userid, gameid);
                break;
            case "ActiveGift":
                token = Convert.ToString(Request.Params["gametoken"]);
                userid = Convert.ToString(Request.Params["userid"]);
                gameid = Convert.ToString(Request.Params["gameid"]);
                if (token == "" || token == null)
                    clsSharedHelper.WriteErrorInfo("GameToken is error!");
                else if (userid == "" || userid == null)
                    clsSharedHelper.WriteErrorInfo("UserID is error!");
                else
                    ActiveGift(token, userid, gameid);
                break;                
            case "ClearDTPrize":
                if (_dtPrize != null)
                {
                    _dtPrize.Dispose();
                    _dtPrize = null;
                    TokenIndex = 1;
                }
                clsSharedHelper.WriteSuccessedInfo("清除成功！");
                break;
            case "Prizer100":
                Prizer100();
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无效的控制参数！ctrl:" + ctrl);
                break;
        }
    }
    
    //获取我的游戏券数据
    private void GetMyGift(string userid, string filter) {
        //未激活 00 isget=0 and isactive=0
        //可领取 01 isget=0 and isactive=1
        //已领取 11 isget=1 and isactive=1
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"select a.id,g.gamename,a.gameid,a.gametoken,a.userid,a.prizeid,b.prizename,b.prizedesc,a.isget,a.isactive,
                                convert(varchar(10),a.gettime,120) gettime,convert(varchar(10),a.createtime,120) gametime,
                                case when getdate()<=a.validtime then 1 else 0 end isvalid,a.validtime
                                from tm_t_getprizerecords a
                                inner join tm_t_gametype g on a.gameid=g.id and g.isactive=1
                                left join tm_t_prize b on a.prizeid=b.id
                                where a.userid=@userid and a.prizeid<>0 ";
            switch (filter) { 
                case "00":
                    str_sql += " and a.isget=0 and a.isactive=0 order by a.createtime desc";
                    break;
                case "01":
                    str_sql += " and a.isget=0 and a.isactive=1 order by a.createtime desc";
                    break;
                case "11":
                    str_sql += " and a.isget=1 and a.isactive=1 order by a.createtime desc";
                    break;
                default:
                    str_sql += " order by a.createtime desc";
                    break;
            }
            
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid", userid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string rt = JsonHelp.dataset2json(dt);
                    clsSharedHelper.WriteSuccessedInfo(rt);
                }
                else
                    clsSharedHelper.WriteSuccessedInfo("");                
            }
            else
                clsSharedHelper.WriteErrorInfo("查询用户礼券时出错：" + errinfo);
        }
    }
    
    //获取游戏券的详细信息
    private void GetGiftDetail(string token,string userid,string gameid) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"select isnull(b.prizename,'') pname,isnull(b.prizedesc,'') pdesc,c.gamename,a.createtime gettime,a.validtime,
                                case when getdate()>a.validtime then '已失效' when a.isactive=0 and a.isget=0 then '去激活'
                                 when a.isactive=1 and a.isget=0 then '已激活去领取' else '已领取' end status
                                from tm_t_getprizerecords a
                                inner join tm_t_gametype c on a.gameid=c.id and c.isactive=1
                                left join tm_t_prize b on a.prizeid=b.id
                                where a.gametoken=@gametoken and a.userid=@userid and a.gameid=@gameid;";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gametoken", token));
            paras.Add(new SqlParameter("@userid", userid));
            paras.Add(new SqlParameter("@gameid", gameid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0) {
                    string rtmsg = string.Format("{0}|{1}|{2}|{3}|{4}|{5}", dt.Rows[0]["pname"].ToString(), dt.Rows[0]["pdesc"].ToString(), dt.Rows[0]["gamename"].ToString(), dt.Rows[0]["gettime"].ToString(), dt.Rows[0]["validtime"].ToString(), dt.Rows[0]["status"].ToString());
                    clsSharedHelper.WriteInfo(rtmsg);
                }
                else
                    clsSharedHelper.WriteErrorInfo("请核对礼券的有效性之后再打开此页面！");
            }
            else
                clsSharedHelper.WriteErrorInfo("Server error:" + errinfo);
        }
    }

    //激活游戏券接口
    private void ActiveGift(string token, string userid, string gameid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"update tm_t_getprizerecords set isactive=1,activetime=getdate() 
                                where gameid=@gameid and userid=@userid and gametoken=@gametoken and getdate()<=validtime and isget=0 and isactive=0";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gametoken", token));
            paras.Add(new SqlParameter("@userid", userid));
            paras.Add(new SqlParameter("@gameid", gameid));
            string errinfo = dal.ExecuteNonQuerySecurity(str_sql, paras);
            if (errinfo == "")
            {
                clsSharedHelper.WriteInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("Server error:" + errinfo);
        }
    }
    
    //删除指定日期未绑定用户的游戏TOKEN
    private void DelGameDatas(string GTime)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"delete from tm_t_gamerecords 
                                where userid=0 and isconsume=0 and gametime>=convert(varchar(10),@gtime,120) 
                                and gametime<dateadd(day,1,convert(varchar(10),@gtime,120));";
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@gtime", GTime));
            string errinfo = dal.ExecuteNonQuerySecurity(str_sql, para);
            if (errinfo == "")
            {
                if (_dtPrize != null) {
                    lock (lockPrize)
                    {
                        _dtPrize.Dispose();
                        _dtPrize = null;
                        TokenIndex = 1;
                    }
                }
                clsSharedHelper.WriteSuccessedInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }
    }

    //按指定日期生成游戏记录池
    private void GenaretePrizePool(string GTime)
    {        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            //先查询今天到此刻为止有没有游戏记录，主要是怕当天临时变动
            //只删除当天未绑定用户的游戏记录 因为之前未绑定的还可以继续玩
            string str_sql = @" delete from tm_t_gamerecords
                                where userid=0 and gametime>=convert(varchar(10),@gtime,120)
                                and gametime<dateadd(day,1,convert(varchar(10),@gtime,120));
                                select a.prizeid,count(a.id) sl into #tmp
                                from tm_t_gamerecords a                                
                                where a.userid<>0 and a.isconsume=1 and a.prizeid<>0
                                and a.gametime>=convert(varchar(10),@gtime,120) 
                                and a.gametime<dateadd(day,1,convert(varchar(10),@gtime,120))
                                group by a.prizeid;
                                select a.*,a.numsperday-isnull(b.sl,0) todaynums 
                                from tm_t_prize a left join #tmp b on a.id=b.prizeid 
                                where a.id<>0;
                                drop table #tmp;";
            DataTable dtTodayPrize = null;
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@gtime", GTime));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, para, out dtTodayPrize);
            if (errinfo == "")
            {                    
                if (dtTodayPrize.Rows.Count > 0)
                {                    
                    //生成算法调整将每个奖项平分到一天当中 
                    //需要用到的变量
                    int timeblock = 0, prizeNum = 0;
                    string gametoken = "", activetime = "", prizeID = "";
                    int prizeSum = Convert.ToInt32(dtTodayPrize.Compute("sum(todaynums)", ""));
                    DateTime _time = Convert.ToDateTime(GTime);
                    str_sql = "";
                    if (prizeSum > 0)
                    {
                        int sqlblocks = 0;int tt=0;                       
                        for (int i = 0; i < dtTodayPrize.Rows.Count; i++)
                        {                            
                            prizeNum = Convert.ToInt32(dtTodayPrize.Rows[i]["todaynums"]);
                            if (prizeNum <= 0) continue;
                            prizeID = dtTodayPrize.Rows[i]["id"].ToString();
                            timeblock = Convert.ToInt32(Math.Floor(Convert.ToDouble(24 * 60 * 60 / prizeNum)));
                            int tcount = 0;                            
                            for (int j = 0; j < prizeNum; j++)
                            {
                                gametoken = System.Guid.NewGuid().ToString();
                                activetime = _time.AddSeconds(timeblock * tcount).ToString();
                                tcount++;                                
                                //利用字符串拼接去优化速度
                                str_sql = string.Concat(str_sql, "insert into tm_t_gamerecords(gameid,userid,gametoken,isconsume,prizeid,activetime,gametime) values (0,0,'", gametoken, "',0,'", prizeID, "','", activetime, "','", GTime, "');");
                                sqlblocks++;
                                //每500条执行一次
                                if (sqlblocks == 500) {                                     
                                    tt++;
                                    writeLog("生成执行-" + tt.ToString());
                                    errinfo = dal.ExecuteNonQuery(str_sql);
                                    if (errinfo == "")
                                    {
                                        sqlblocks = 0;
                                        str_sql = "";
                                    }
                                    else {
                                        clsSharedHelper.WriteErrorInfo("生成奖品【" + prizeID + "】池时出错 errinfo:" + errinfo);
                                        break;
                                    }
                                }
                            }//end for j
                        }//end for i

                        //有可能最后还有一部分SQL没执行
                        if (str_sql != "") {
                            tt++;
                            writeLog("生成执行-" + tt.ToString());
                            errinfo = dal.ExecuteNonQuery(str_sql);
                            if (errinfo != "")
                                clsSharedHelper.WriteErrorInfo(errinfo);
                        }
                        //清空_dtPrize
                        if (_dtPrize != null)
                        {
                            lock (lockPrize)
                            {
                                _dtPrize.Dispose();
                                _dtPrize = null;
                            }
                        }
                        TokenIndex = 1;
                    }
                    else
                        clsSharedHelper.WriteErrorInfo("游戏奖品配置信息有误！");
                }
                else
                    clsSharedHelper.WriteErrorInfo("还未配置游戏奖品信息！");
            }
            else
                clsSharedHelper.WriteErrorInfo("生成游戏奖池数据查询数据失败 errinfo:" + errinfo);
        }
    }

    //游戏开始前判断用户是否能玩 判断用户的游戏次数
    private void IsCanPlay(string gameid, string userid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"select a.*,isnull(gm.id,0) gmid
                                from wx_t_vipbinging a 
                                left join tm_t_gametype gm on gm.id=@gameid and gm.isactive=1
                                where a.objectid=101 and a.id=@userid ";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gameid", gameid));
            paras.Add(new SqlParameter("@userid", userid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0]["gmid"].ToString() == "0")
                        clsSharedHelper.WriteErrorInfo("游戏配置信息有误！");
                    else
                    {
                        int gamecount = Convert.ToInt32(dt.Rows[0]["gamecount"]);
                        int nowcount = Convert.ToInt32(dt.Rows[0]["nowcount"]);
                        if (nowcount >= 0 && gamecount > nowcount)
                        {
                            //用户还有游戏次数 接下去获得游戏数据    
                            GetGameData(gameid, userid);
                        }
                        else
                            clsSharedHelper.WriteInfo("Warn:您可以分享到朋友圈或扫特定二维码来获取游戏次数。");
                    }
                }
                else
                    clsSharedHelper.WriteErrorInfo("系统中找不到您的微信信息！");
            }
            else
                clsSharedHelper.WriteErrorInfo("IsCanPlay Error:" + errinfo);
        }
    }

    //开奖算法，获得游戏相关数据
    private void GetGameData(string gameid, string userid)
    {
        string rtMsg = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            //判断用户到目前为止是否存在还未消费过的游戏TOKEN tm_t_gamerecords.isconsume=0。
            string str_sql = @"select top 1 a.gametoken,a.prizeid,isnull(b.prizename,'') prizename
                                from tm_t_gamerecords a                                 
                                left join tm_t_prize b on a.prizeid=b.id                                
                                where a.gameid=@gameid and a.userid=@userid and a.isconsume=0 
                                order by a.gametime desc";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid", userid));
            paras.Add(new SqlParameter("@gameid", gameid));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    rtMsg = "Successed:" + dt.Rows[0]["gametoken"].ToString() + "|" + dt.Rows[0]["prizeid"].ToString() + "|" + dt.Rows[0]["prizename"].ToString();
                else
                {
                    //接下来先判断用户用户的中奖情况 
                    //20151216 09:00 官部、小姚确认中奖概率调整为0.2，纪念奖还可以再中
                    str_sql = @"select top 1 1 from tm_t_getprizerecords where userid=@userid and gameid=@gameid and prizeid<>4
                                union all
                                select top 1 2 from tm_t_getprizerecords where userid=@userid and gameid=@gameid and prizeid=4
                                and createtime>=convert(varchar(10),getdate(),120) and createtime<dateadd(day,1,convert(varchar(10),getdate(),120))";
                    /*
                       and getdate()<=validtime
                       and createtime>=convert(varchar(10),getdate(),120) 
                       and createtime<dateadd(day,1,convert(varchar(10),getdate(),120));
                     */
                    paras.Clear();
                    paras.Add(new SqlParameter("@userid", userid));
                    paras.Add(new SqlParameter("@gameid", gameid));
                    if (dt != null)
                        dt.Dispose();
                    errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                    if (errinfo == "" && dt.Rows.Count > 0)
                    {
                        //否则直接创建一行游戏记录，prizeid=0谢谢参与，并返回
                        string gtoken = System.Guid.NewGuid().ToString();
                        str_sql = @"insert into tm_t_gamerecords(gameid,userid,gametoken,isconsume,prizeid,activetime,gametime,ip) 
                                        values(@gameid,@userid,@gtoken,0,0,getdate(),getdate(),@ip);";
                        paras.Clear();
                        paras.Add(new SqlParameter("@gameid", gameid));
                        paras.Add(new SqlParameter("@userid", userid));
                        paras.Add(new SqlParameter("@gtoken", gtoken));
                        paras.Add(new SqlParameter("@ip", HttpContext.Current.Request.UserHostAddress));
                        errinfo = dal.ExecuteNonQuerySecurity(str_sql, paras);
                        if (errinfo == "")
                            rtMsg = "Successed:" + gtoken + "|0|谢谢参与.";
                        else
                            rtMsg = "Error:创建游戏券信息失败 errinfo:" + errinfo;
                    }
                    else if (errinfo == "")
                    {
                        DataTable PDT = dtPrize();
                        lock (lockPrize)
                        {
                            int PrizeCount = PDT.Rows.Count;//当前可用的游戏券券数
                            Random rd = new Random(TokenIndex + DateTime.Now.Millisecond);
                            int MaxNext = Convert.ToInt32(PrizeCount / WINPR) + 100;
                            int PrizeIndex = rd.Next(0, MaxNext);
                            TokenIndex++;
                            
                            if (PrizeCount == 0 || (PrizeCount>0 && PrizeIndex >= PrizeCount))
                            {
                                //否则直接创建一行游戏记录，prizeid=0谢谢参与，并返回
                                string gtoken = System.Guid.NewGuid().ToString();
                                str_sql = @"insert into tm_t_gamerecords(gameid,userid,gametoken,isconsume,prizeid,activetime,gametime,ip) 
                                        values(@gameid,@userid,@gtoken,0,0,getdate(),getdate(),@ip);";
                                paras.Clear();
                                paras.Add(new SqlParameter("@gameid", gameid));
                                paras.Add(new SqlParameter("@userid", userid));
                                paras.Add(new SqlParameter("@gtoken", gtoken));
                                paras.Add(new SqlParameter("@ip", HttpContext.Current.Request.UserHostAddress));
                                errinfo = dal.ExecuteNonQuerySecurity(str_sql, paras);
                                if (errinfo == "")
                                    rtMsg = "Successed:" + gtoken + "|0|谢谢参与.";
                                else
                                    rtMsg = "Error:创建游戏券信息失败 errinfo:" + errinfo;
                            }
                            else
                            {
                                //Random rd = new Random(TokenIndex + DateTime.Now.Millisecond);
                                //int MaxNext = Convert.ToInt32(PrizeCount / WINPR) + 100;
                                //int PrizeIndex = rd.Next(0, MaxNext);
                                //TokenIndex++;
                                str_sql = "update tm_t_gamerecords set gameid='" + gameid + "',userid='" + userid + "',gametime=getdate(),ip='" + HttpContext.Current.Request.UserHostAddress + "' where id='" + PDT.Rows[PrizeIndex]["id"].ToString() + "'";
                                errinfo = dal.ExecuteNonQuery(str_sql);
                                if (errinfo == "")
                                {                                    
                                    rtMsg = "Successed:" + PDT.Rows[PrizeIndex]["gametoken"].ToString() + "|" + PDT.Rows[PrizeIndex]["prizeid"].ToString() + "|" + PDT.Rows[PrizeIndex]["prizename"].ToString();
                                    //先取出数据再移除dtPrize中的此行数据                                     
                                    PDT.Rows.Remove(PDT.Rows[PrizeIndex]);                                    
                                }
                                else
                                    rtMsg = "Error:更新游戏占用状态时失败 errinfo:" + errinfo;
                            }
                        }//end lock
                    }                   
                }
            }
            else
                rtMsg = "Error:调用GetGameData时出错 errinfo:" + errinfo;
        }

        clsSharedHelper.WriteInfo(rtMsg);
    }


    //消费游戏TOKEN方法
    private void ConsumeGameToken(string token, string userid, string gameid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @" if not exists(select top 1 1 from tm_t_gamerecords where gametoken=@token and userid=@userid)
                                select '00'
                                else 
                                begin
                                declare @gid int;declare @uid int;declare @pid int;declare @isactive int;
                                select @gid=a.id,@uid=isnull(b.id,0),@pid=a.prizeid,@isactive=case when isnull(b.id,0)<>0 then 1 else 0 end
                                from tm_t_gamerecords a 
                                left join tm_t_userinfo b on a.userid=b.userid
                                where a.gameid=@gameid and a.gametoken=@token and a.userid=@userid and a.isconsume=0;
                                update tm_t_gamerecords set isconsume=1,consumetime=getdate() where id=isnull(@gid,0);
                                if isnull(@pid,0)<>0
                                insert into tm_t_getprizerecords(gameid,gametoken,prizeid,isget,operator,userid,createtime,isactive,activetime)
                                values(@gameid,@token,@pid,0,'',@userid,getdate(),@isactive,getdate());
                                update wx_t_vipbinging set nowcount=nowcount+1 where objectid=101 and id=@userid;
                                select @uid;
                                end";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@token", token));
            paras.Add(new SqlParameter("@userid", userid));
            paras.Add(new SqlParameter("@gameid", gameid));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0][0].ToString() == "00")
                        clsSharedHelper.WriteErrorInfo("对不起，此游戏券【" + token + "】已经被消费过了！");
                    else if (dt.Rows[0][0].ToString() == "0")
                        clsSharedHelper.WriteSuccessedInfo("您还未登记用户信息！");
                    else
                        clsSharedHelper.WriteSuccessedInfo("");
                }
                else
                    clsSharedHelper.WriteErrorInfo("ConsumeGameToken fail dt is null!");
            }
            else
                clsSharedHelper.WriteErrorInfo("ConsumeGameToken Fail! errinfo:" + errinfo);
        }
    }
        

    //登记用户信息方法 保证身份证+手机号是唯一的
    private void RegisterUserInfo(string userid, string idcard, string phone, string uname)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"if not exists(select top 1 1 from tm_t_userinfo where idcard=@idcard or phone=@phone)                                                                                            
                                begin
                                insert into tm_t_userinfo(userid,idcard,phone,createtime,username) values (@userid,@idcard,@phone,getdate(),@username);
                                update tm_t_getprizerecords set isactive=1,activetime=getdate() where userid=@userid and isactive=0;                            
                                select '11';
                                end
                                else
                                select '00';";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid", userid));
            paras.Add(new SqlParameter("@idcard", idcard));
            paras.Add(new SqlParameter("@phone", phone));
            paras.Add(new SqlParameter("@username", uname));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                string result = dt.Rows[0][0].ToString();
                if (result == "00")
                    clsSharedHelper.WriteErrorInfo("对不起，你输入的身份证或手机号已经被使用过！");
                else if (result == "11")
                    clsSharedHelper.WriteSuccessedInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("登记用户信息时出错 errinfo:" + errinfo);
        }
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
    
    //滚动显示最新100名获奖者
    public void Prizer100() {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr)) {            
            string str_sql = @" select top 100 u.wxnick,b.prizename,convert(varchar(10),a.createtime,120) createtime 
                                from tm_t_getprizerecords a 
                                inner join wx_t_vipbinging u on a.userid=u.id and u.objectid=101
                                inner join tm_t_prize b on a.prizeid=b.id
                                where a.gameid=1 and a.prizeid<>0
                                order by a.createtime desc";
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(str_sql,out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                StringBuilder sb = new StringBuilder();                
                for (int i = 0; i < dt.Rows.Count; i++)
                {                    
                    sb.AppendFormat("<li><span class='prizer'>{0}</span><span class='pname'>{1}</span><span class='ptime'>{2}</span></li>", dt.Rows[i]["wxnick"].ToString(), dt.Rows[i]["prizename"].ToString(), dt.Rows[i]["createtime"].ToString());
                }
                sb.Append("<li>.....</li>");
                
                clsSharedHelper.WriteInfo(sb.ToString());
            }
            else
                clsSharedHelper.WriteErrorInfo("");
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
