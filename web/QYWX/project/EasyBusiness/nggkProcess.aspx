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
    private const double WINPR = 0.2;//游戏中奖因子    
    private static string connStr = "server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456";
    private static string DBConStr_10 = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
    private const string ConfigKey = "7";
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
                    string str_sql = @"select a.*,isnull(b.prizename,'') prizename 
                                       from wx_t_gamerecords a    
                                       left join wx_t_gameprize b on a.prizeid=b.id and b.gameid=1 and b.sskey=7
                                       where a.userid=0 and a.isconsume=0 and a.activetime<'" + ServerTime.ToString() + "'";
                    string errinfo = dal.ExecuteQuery(str_sql, out _dtPrize);
                    if (errinfo != "")
                    {
                        clsSharedHelper.WriteErrorInfo("生成静态dtPrize时出错 errinfo:" + errinfo);
                        return null;
                    }
                    else
                        LastLoadTime = ServerTime;
                }//end using
            }//end lock
        }//end if

        return _dtPrize;
    }

    protected void Page_Load(object sender, EventArgs e)
    {        
        string sessionid = Convert.ToString(Session["QSW_UID"]);
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        if (ctrl == "Prizer10") {
            Prizer10();
            return;        
        }
        
        if (ctrl != "GetMyGifts")
            clsSharedHelper.WriteErrorInfo("对不起，活动截止到2016.09.29，感谢您对利郎的支持！");
            
        if (sessionid == null || sessionid == "" || sessionid == "0")
        {
            clsSharedHelper.WriteErrorInfo("越权访问！");
            return;
        }
        
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
                    catch (Exception)
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
                    IsCanPlay(gameid, sessionid);
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
                    ConsumeGameToken(token, sessionid, gameid);
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
                    GetMyGift(sessionid, filter);
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
                    GetGiftDetail(token, sessionid, gameid);
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
                    ActiveGift(token, sessionid, gameid);
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
            case "LogOut":
                Session["QSW_UID"] = null;                
                Session.Remove("QSW_UID");
                Session["QSW_UTYPE"] = null;                
                Session.Remove("QSW_UTYPE");
                clsSharedHelper.WriteSuccessedInfo("");
                break;
            case "ShareTo":
                string sharedtype = Convert.ToString(Request.Params["sharedtype"]);
                ShareTo(sharedtype);
                break;
            case "ClearPrizePool":
                try
                {
                    //清空_dtPrize 刷新内存中的表数据
                    if (_dtPrize != null)
                    {
                        lock (lockPrize)
                        {
                            _dtPrize.Clear();
                            _dtPrize.Dispose();
                            _dtPrize = null;
                        }
                    }
                    clsSharedHelper.WriteSuccessedInfo("清除成功");
                }
                catch (Exception ex) {
                    clsSharedHelper.WriteErrorInfo(ex.StackTrace);
                }

                break;
            default:
                clsSharedHelper.WriteErrorInfo("无效的控制参数！ctrl:" + ctrl);
                break;
        }
    }

    //获取我的游戏券数据
    private void GetMyGift(string userid, string filter)
    {        
        //未激活 00 isget=0 and isactive=0
        //可领取 01 isget=0 and isactive=1
        //已领取 11 isget=1 and isactive=1
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"select a.gametoken,b.prizename,b.prizedesc,a.isget,a.gettime
                                from wx_t_getprizerecords a
                                inner join wx_t_gametype g on a.gameid=g.id and g.isactive=1 and g.sskey=7
                                left join wx_t_gameprize b on a.prizeid=b.id and b.gameid=g.id and b.sskey=7
                                where a.userid=@userid and a.prizeid<>0 and a.sskey=@sskey";
            switch (filter)
            {
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
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {                    
                    clsSharedHelper.WriteSuccessedInfo(JsonHelp.dataset2json(dt));
                }
                else
                    clsSharedHelper.WriteInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("查询用户礼券时出错：" + errinfo);
        }
    }

    //获取游戏券的详细信息
    private void GetGiftDetail(string token, string userid, string gameid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"select isnull(b.prizename,'') pname,isnull(b.prizedesc,'') pdesc,c.gamename,a.createtime gettime,a.validtime,
                               case when a.validtime<getdate() and a.prizeid in (1,2) then '已过期' else case when a.isactive=0 and a.isget=0 then '去激活'
                                 when a.isactive=1 and a.isget=0 then '已激活去领取' else '已领取' end end status
                                from wx_t_getprizerecords a
                                inner join wx_t_gametype c on a.gameid=c.id and c.isactive=1 and c.sskey=@sskey
                                left join wx_t_gameprize b on a.prizeid=b.id
                                where a.gametoken=@gametoken and a.userid=@userid and a.gameid=@gameid and a.sskey=@sskey;";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gametoken", token));
            paras.Add(new SqlParameter("@userid", userid));
            paras.Add(new SqlParameter("@gameid", gameid));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
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
            string str_sql = @"update wx_t_getprizerecords set isactive=1,activetime=getdate() 
                                where sskey=@sskey and gameid=@gameid and userid=@userid 
                                and gametoken=@gametoken and getdate()<=validtime and isget=0 and isactive=0";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gametoken", token));
            paras.Add(new SqlParameter("@userid", userid));
            paras.Add(new SqlParameter("@gameid", gameid));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
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
            string str_sql = @"delete from wx_t_gamerecords 
                                where gameid=0 and userid=0 and isconsume=0 and convert(varchar(10),gametime,120)=@gtime and sskey=@sskey;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gtime", GTime));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            string errinfo = dal.ExecuteNonQuerySecurity(str_sql, paras);
            if (errinfo == "")
            {
                if (_dtPrize != null)
                {
                    lock (lockPrize)
                    {
                        _dtPrize.Clear();
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
            //改为配置表设多少就新增多少进去
            string str_sql = @" select a.*,a.numsperday todaynums from wx_t_gameprize a where a.id<>0 and a.gameid=1 and a.sskey=@sskey;";
            DataTable dtTodayPrize = null;
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@gtime", GTime));
            para.Add(new SqlParameter("@sskey", ConfigKey));
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
                        int sqlblocks = 0; int tt = 0;
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
                                str_sql = string.Concat(str_sql, "insert into wx_t_gamerecords(gameid,userid,gametoken,isconsume,prizeid,activetime,gametime,sskey) values (0,0,'", gametoken, "',0,'", prizeID, "','", activetime, "','", GTime, "'," + ConfigKey + ");");
                                sqlblocks++;
                                //每500条执行一次
                                if (sqlblocks == 500)
                                {
                                    tt++;
                                    writeLog("生成执行-" + tt.ToString());
                                    errinfo = dal.ExecuteNonQuery(str_sql);
                                    if (errinfo == "")
                                    {
                                        sqlblocks = 0;
                                        str_sql = "";
                                    }
                                    else
                                    {
                                        clsSharedHelper.WriteErrorInfo("生成奖品【" + prizeID + "】池时出错 errinfo:" + errinfo);
                                        break;
                                    }
                                }
                            }//end for j
                        }//end for i

                        //有可能最后还有一部分SQL没执行
                        if (str_sql != "")
                        {
                            tt++;
                            writeLog("生成执行-" + tt.ToString());
                            errinfo = dal.ExecuteNonQuery(str_sql);
                            if (errinfo != "")
                                clsSharedHelper.WriteErrorInfo(errinfo);
                        }
                        //清空_dtPrize 刷新内存中的表数据
                        if (_dtPrize != null)
                        {
                            lock (lockPrize)
                            {
                                _dtPrize.Dispose();
                                _dtPrize = null;
                            }
                        }
                        TokenIndex = 1;
                        clsSharedHelper.WriteSuccessedInfo("");
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
            string str_sql = @"select a.gamecounts,a.nowcounts,isnull(gm.id,0) gmid
                                from wx_t_usergameinfos a 
                                left join wx_t_gametype gm on gm.id=@gameid and gm.isactive=1 and gm.sskey=@sskey
                                where a.userid=@userid and a.gameid=@gameid and a.sskey=@sskey ";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gameid", gameid));
            paras.Add(new SqlParameter("@userid", userid));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0]["gmid"].ToString() == "0")
                        clsSharedHelper.WriteErrorInfo("游戏配置信息有误！");
                    else
                    {
                        int gamecount = Convert.ToInt32(dt.Rows[0]["gamecounts"]);
                        int nowcount = Convert.ToInt32(dt.Rows[0]["nowcounts"]);
                        if (nowcount >= 0 && gamecount > nowcount)
                        {
                            //用户还有游戏次数 接下去获得游戏数据    
                            GetGameData(gameid, userid);
                        }
                        else
                            clsSharedHelper.WriteInfo("Warn:您可以点击“分享”然后将链接发送给朋友，即可增加游戏次数！");
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
            string str_sql = @"select top 1 a.gametoken,a.prizeid,isnull(b.prizename,'谢谢参与') prizename
                                from wx_t_gamerecords a                                 
                                left join wx_t_gameprize b on a.prizeid=b.id
                                where a.sskey=@sskey and a.gameid=@gameid and a.userid=@userid and a.isconsume=0 
                                order by a.gametime desc";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid", userid));
            paras.Add(new SqlParameter("@gameid", gameid));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    rtMsg = "Successed:" + dt.Rows[0]["gametoken"].ToString() + "|" + dt.Rows[0]["prizeid"].ToString() + "|" + dt.Rows[0]["prizename"].ToString();
                else
                {
                    //接下来先判断用户用户的中奖情况 
                    //暂定中过纪念奖的还能再中，但是一个用户一天最多中一双袜子
                    str_sql = @"select top 1 1 from wx_t_getprizerecords where userid=@userid and gameid=@gameid and prizeid<>6 and sskey=@sskey
                                union all
                                select top 1 2 from wx_t_getprizerecords where userid=@userid and gameid=@gameid and prizeid=6 and sskey=@sskey
                                and convert(varchar(10),createtime,120)=convert(varchar(10),getdate(),120)";
                    paras.Clear();
                    paras.Add(new SqlParameter("@userid", userid));
                    paras.Add(new SqlParameter("@gameid", gameid));
                    paras.Add(new SqlParameter("@sskey", ConfigKey));
                    if (dt != null) {
                        dt.Clear();
                        dt.Dispose();
                    }                        
                    errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                    if (errinfo == "" && dt.Rows.Count > 0)
                    {
                        //否则直接创建一行游戏记录，prizeid=0谢谢参与，并返回
                        string gtoken = System.Guid.NewGuid().ToString();
                        str_sql = @"insert into wx_t_gamerecords(gameid,userid,gametoken,isconsume,prizeid,activetime,gametime,ip,sskey) 
                                        values(@gameid,@userid,@gtoken,0,0,getdate(),getdate(),@ip,@sskey);";
                        paras.Clear();
                        paras.Add(new SqlParameter("@gameid", gameid));
                        paras.Add(new SqlParameter("@userid", userid));
                        paras.Add(new SqlParameter("@gtoken", gtoken));
                        paras.Add(new SqlParameter("@ip", HttpContext.Current.Request.UserHostAddress));
                        paras.Add(new SqlParameter("@sskey", ConfigKey));
                        errinfo = dal.ExecuteNonQuerySecurity(str_sql, paras);
                        if (errinfo == "")
                            rtMsg = "Successed:" + gtoken + "|0|谢谢参与";
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
                            int MaxNext = Convert.ToInt32(PrizeCount / WINPR);
                            int PrizeIndex = rd.Next(0, MaxNext);
                            TokenIndex++;

                            if (PrizeCount == 0 || (PrizeCount > 0 && PrizeIndex >= PrizeCount))
                            {
                                //否则直接创建一行游戏记录，prizeid=0谢谢参与，并返回
                                string gtoken = System.Guid.NewGuid().ToString();
                                str_sql = @"insert into wx_t_gamerecords(gameid,userid,gametoken,isconsume,prizeid,activetime,gametime,ip,sskey) 
                                        values(@gameid,@userid,@gtoken,0,0,getdate(),getdate(),@ip,@sskey);";
                                paras.Clear();
                                paras.Add(new SqlParameter("@gameid", gameid));
                                paras.Add(new SqlParameter("@userid", userid));
                                paras.Add(new SqlParameter("@gtoken", gtoken));
                                paras.Add(new SqlParameter("@ip", HttpContext.Current.Request.UserHostAddress));
                                paras.Add(new SqlParameter("@sskey", ConfigKey));
                                errinfo = dal.ExecuteNonQuerySecurity(str_sql, paras);
                                if (errinfo == "")
                                    rtMsg = "Successed:" + gtoken + "|0|谢谢参与";
                                else
                                    rtMsg = "Error:创建游戏券信息失败 errinfo:" + errinfo;
                            }
                            else
                            {
                                str_sql = "update wx_t_gamerecords set sskey='" + ConfigKey + "',gameid='" + gameid + "',userid='" + userid + "',gametime=getdate(),ip='" + HttpContext.Current.Request.UserHostAddress + "' where id='" + PDT.Rows[PrizeIndex]["id"].ToString() + "'";
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
            string str_sql = @" if not exists(select top 1 1 from wx_t_gamerecords where gametoken=@token and userid=@userid and sskey=@sskey and gameid=@gameid)
                                select '00'
                                else if exists (select top 1 1 from wx_t_gamerecords where gametoken=@token and userid=@userid and sskey=@sskey and gameid=@gameid and isconsume=1)
                                select '10'
                                else
                                begin
                                  declare @gid int;declare @pid int;
                                  select @gid=a.id,@pid=a.prizeid from wx_t_gamerecords a                                
                                  where a.sskey=@sskey and a.gameid=@gameid and a.gametoken=@token and a.userid=@userid and a.isconsume=0;
                                  update wx_t_gamerecords set isconsume=1,consumetime=getdate() where id=isnull(@gid,0) and gameid=@gameid and sskey=@sskey;
                                  if isnull(@pid,0)<>0
                                    insert into wx_t_getprizerecords(gameid,gametoken,prizeid,isget,operator,userid,createtime,isactive,activetime,sskey,validtime)
                                    values(@gameid,@token,@pid,0,'',@userid,getdate(),1,getdate(),@sskey,'2016-10-09 23:59:59');
                                  update wx_t_usergameinfos set nowcounts=nowcounts+1 where userid=@userid and gameid=@gameid and sskey=@sskey and gamecounts>nowcounts;
                                  select '11';
                                end";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@token", token));
            paras.Add(new SqlParameter("@userid", userid));
            paras.Add(new SqlParameter("@gameid", gameid));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0][0].ToString() == "00")
                        clsSharedHelper.WriteErrorInfo("对不起，此游戏券【" + token + "】无效！");
                    else if (dt.Rows[0][0].ToString() == "10")
                        clsSharedHelper.WriteErrorInfo("对不起，您的网络真不给力！");
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
        catch (Exception) { }
    }

    //滚动显示最新10名获奖者
    public void Prizer10()
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @" select top 10 case when len(u.username)>2 then substring(u.username,1,2)+'*' else substring(u.username,1,1)+'**' end username,
                                b.prizename,convert(varchar(10),a.createtime,120) time 
                                from wx_t_getprizerecords a 
                                inner join wx_t_userinfo u on a.userid=u.id
                                inner join wx_t_gameprize b on a.prizeid=b.id
                                where a.gameid=1 and a.prizeid<>0 and a.prizeid<>6
                                order by a.createtime desc  ";
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(str_sql, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count == 0)
                    clsSharedHelper.WriteInfo("");
                else
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
            }
            else
                clsSharedHelper.WriteErrorInfo("GetPrizer10 Error:" + errinfo);
        }
    }  
    
    //分享给朋友或者至朋友圈 游戏次数加一次 一天最多加四次
    //sharedtype 0-微信分享给好友，1-微信分享至朋友圈 2-微信分享至QQ好友 3-微信分享至QQ空间
    public void ShareTo(string sharedtype) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            if (sharedtype != "0" && sharedtype != "1" && sharedtype != "2" && sharedtype != "3" || sharedtype == "")
                sharedtype = "0";
            string str_sql = @"if not exists (select top 1 1 from wx_t_sharedhistory where userid=@userid and sharedtype=@sharedtype and gameid=@gameid 
                                            and sskey=@sskey and convert(varchar(10),createtime,120)=convert(varchar(10),getdate(),120))
                                begin
                                insert into wx_t_sharedhistory(userid,sharedtype,createtime,gameid,sskey) values(@userid,@sharedtype,getdate(),@gameid,@sskey);
                                update wx_t_usergameinfos set gamecounts=gamecounts+1 where gameid=@gameid and sskey=@sskey and userid=@userid;
                                end";            
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid", Convert.ToString(Session["QSW_UID"])));
            paras.Add(new SqlParameter("@sharedtype", sharedtype));
            paras.Add(new SqlParameter("@gameid", "1"));
            paras.Add(new SqlParameter("@sskey", "7"));
            string errinfo = dal.ExecuteNonQuerySecurity(str_sql, paras);
            if (errinfo == "")
            {
                clsSharedHelper.WriteSuccessedInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("Shared2 Is Error:" + errinfo);
        } 
    } 
    
    //此方法用于更新同一个UINIONID所对应的VIPID，在生成微信用户资料时调用一次即可，
    //前期仅用在利郎男装(objectid=1)与利郎轻商务(objectid=4)的会员打通
    public string updateVipIDByUnionID(string unionid) {
        string msg = "";
        using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConStr_10)) {
            string str_sql = @"declare @vipid int;
                                select top 1 @vipid=vipid from wx_t_vipbinging where objectid in (1,4) and wxunionid=@unionid and vipid>0;
                                if isnull(@vipid,0)<>0
                                  update wx_t_vipbinging set vipid=@vipid where objectid in (1,4) and wxunionid=@unionid and vipid=0";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@unionid", unionid));
            msg = dal10.ExecuteNonQuerySecurity(str_sql,paras);
        }//end using
        
        return msg;    
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
