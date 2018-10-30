<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>

<!DOCTYPE html>
<script runat="server">
    /*
     *20170207    
     *该文件主要用于情人节抽玫瑰小游戏
<img src="file:///C:\Users\curcry\AppData\Local\Temp\SGPicFaceTpBq\5228\1A6F11B6.png" />
     */
    //private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    //private string WXDBConstr = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";

    public static object rosePirzeLock = new object();
    public static object consumeLock = new object(); //消费锁
    private static DataTable _roseDtPrize = null;
    private const double eggWINPR = 0.3;//中奖因子
    private static DateTime roseLastLoadTime;//记录dtPrize的最后一次刷新时间
    private static string WXDBConstr = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";// "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";// "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private const string ConfigKey = "7";
    private static string roseGameid = "6";
    //奖品池放在内存表中，半个小时重新下载一次
    private static DataTable dtPrize()
    {
        DateTime ServerTime = DateTime.Now;
        if (_roseDtPrize == null || roseLastLoadTime == null || ServerTime > roseLastLoadTime.AddMinutes(30))
        {
            lock (rosePirzeLock)
            {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
                {
                    string str_sql = string.Format(@"select a.*,isnull(b.prizename,'') prizename 
                                       from wx_t_gamerecords a    
                                       left join wx_t_gameprize b on a.prizeid=b.id and b.gameid={1} and b.sskey={0}
                                       where a.sskey={0} and a.wxid=0 AND a.gameid={1} and a.isconsume=0 and a.activetime<'{2}'", ConfigKey, roseGameid, ServerTime.ToString());
                    string errinfo = dal.ExecuteQuery(str_sql, out _roseDtPrize);
                    if (errinfo != "")
                    {
                        clsSharedHelper.WriteErrorInfo("生成静态zpdtPrize时出错 errinfo:" + errinfo);
                        return null;
                    }
                    else
                        roseLastLoadTime = ServerTime;
                }//end using
            }//end lock
        }//end if
        return _roseDtPrize;
    }

    /*限制访问人数，30秒1000人*/
    public static DataTable _roseUserDT = null;
    public static DataTable roseUserDR()
    {
        /*限制访问人数*/
        if (_roseUserDT == null)
        {
            _roseUserDT = new DataTable();
            _roseUserDT.Columns.Add("wxid", typeof(int));
            _roseUserDT.Columns.Add("modifyTime", typeof(DateTime));
        }
        DataRow[] drlist = _roseUserDT.Select("modifyTime <'" + DateTime.Now.AddSeconds(-30).ToString() + "'");
        foreach (DataRow dr in drlist)
        {
            _roseUserDT.Rows.Remove(dr);
        }
        return _roseUserDT;
    }
    
    
    protected void Page_Load(object sender, EventArgs e)
    {
        Boolean isTest = false;//测试阶段标识,测试时使用
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string wxid = Convert.ToString(Session["wxid"]);

       // wxid = Convert.ToString(Request.Params["wxid"]);
        if (wxid == "" || wxid == "0" || wxid == null)
        {
            clsSharedHelper.WriteErrorInfo("访问超时,请刷新后访问!");
            return;
        }

        /*限制访问人数*/
        DataTable activeDT = roseUserDR();
        int i;
        for (i = 0; i < activeDT.Rows.Count; i++)
        {
            if (Convert.ToString(activeDT.Rows[i]["wxid"]) == wxid)
            {
                activeDT.Rows[i]["modifyTime"] = DateTime.Now.ToString();
                break;
            }
        }

        if (i >= activeDT.Rows.Count && activeDT.Rows.Count > 1000)
        {
            clsSharedHelper.WriteInfo("访问人数超限，请稍后访问！");
            return;
        }
        else if (i >= activeDT.Rows.Count && activeDT.Rows.Count <= 1000)
        {
            DataRow dr = _roseUserDT.NewRow();
            dr["wxid"] = wxid;
            dr["modifyTime"] = DateTime.Now.ToString();
            _roseUserDT.Rows.Add(dr);
            //  clsSharedHelper.WriteInfo("成功访问" + _roseUserDT.Rows.Count);
        }
        
        isTest = true;//测试模式
        if (isTest)
        {
            string mysql = "SELECT id FROM wx_T_testUser WHERE wxid=@wxid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@wxid", wxid));
            DataTable dt;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
            {
                string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "")
                {
                    clsSharedHelper.WriteInfo(errInfo);
                }
                else if (dt.Rows.Count <= 0)
                {
                    clsSharedHelper.WriteInfo(clsNetExecute.Error + "正在测试中,请使用测试身份访问。。");
                }
                else
                {
                    dt.Clear(); dt.Dispose();
                }
            }
        }
        
        string rt = "";
        switch (ctrl)
        {
            case "GetGameCount"://获取游戏次数
                rt = GetGameCount(roseGameid, wxid);
                break;
            case "GetGameData"://获取中奖情况
                GetGameData(roseGameid, wxid);
                break;
            case "ConsumeGameToken":
                string gameToken=Convert.ToString(Request.Params["gametoken"]);
                ConsumeGameToken(gameToken, wxid, roseGameid);
                break;
            case "ClearAwardPool":
                ClearAwardPool();
                break;
            case "createUser":
                wxid = Convert.ToString(Request.Params["wxid"]);
                createUser(wxid);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("请检查传入的CTRL是否有效！");
                break;
        }
        if (rt != "")
        {
            clsSharedHelper.WriteInfo(rt);
        }
    }
    //创建用户
    private void createUser(string wxid)
    {
        if (string.IsNullOrEmpty(wxid))
        {
            clsSharedHelper.WriteErrorInfo("wxid不正确");
        }
        string mysql = "SELECT * FROM tm_T_TurnTable WHERE wxID=@wxid";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@wxid",wxid));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
            }
            else if (dt.Rows.Count > 0)
            {
                dt.Clear(); dt.Dispose();
                clsSharedHelper.WriteErrorInfo("用户已存在,不需要再创建");
            }
            else
            {
                mysql = "INSERT INTO tm_T_TurnTable(wxid,Gameid,GameCounts,UsedCounts,SSKey,OriginFrom) VALUES(@wxid,@Gameid,@GameCounts,0,@SSKey,@OriginFrom)";
                paras.Clear();
                paras.Add(new SqlParameter("@wxid", wxid));
                paras.Add(new SqlParameter("@Gameid", roseGameid));
                paras.Add(new SqlParameter("@GameCounts", "3"));
                paras.Add(new SqlParameter("@SSKey",ConfigKey ));
                paras.Add(new SqlParameter("@OriginFrom", ""));
                errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
                if (errInfo != "")
                {
                    clsSharedHelper.WriteErrorInfo(errInfo);
                }
                else
                {
                    paras.Clear();
                    clsSharedHelper.WriteSuccessedInfo("");
                }
            }
        }
    }
    
    //我的奖品记录
    private void getMyPrize(string userid)
    {
        string myslq = @"SELECT TOP 50  d.wxNick,d.wxOpenid,a.CreateTime AS GameTime,a.IsGet,b.PrizeName
                    FROM dbo.wx_t_GetPrizeRecords a 
                    INNER JOIN dbo.wx_t_GamePrize b ON a.PrizeID=b.ID 
                    INNER JOIN dbo.wx_t_vipBinging d ON a.wxID=d.id
                    WHERE a.UserID=@userid AND a.GameID=@gameid AND a.SSKey=@sskey order by a.id desc ";
        DataTable dt = null;
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@userid", userid));
        para.Add(new SqlParameter("@gameid", roseGameid));
        para.Add(new SqlParameter("@sskey", ConfigKey));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string errinfo = dal.ExecuteQuerySecurity(myslq, para, out dt);
            if (errinfo == "")
                clsSharedHelper.WriteInfo(DataTableToJson("rows", dt));
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }//end using
    }
    
    //游戏开始前判断用户是否能玩 判断用户的游戏次数
    private string GetGameCount(string gameid, string wxid)
    {
        string rt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string str_sql = @"SELECT gameCounts-usedCounts AS counts
                               FROM tm_T_TurnTable 
                               WHERE SSKey=@sskey AND gameid=@gameid AND wxid=@wxid";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gameid", gameid));
            paras.Add(new SqlParameter("@wxid", wxid));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                   rt =clsNetExecute.Successed+ Convert.ToString(dt.Rows[0]["counts"]);
                }
                else
                    rt = clsNetExecute.Error + "系统中找不到您的微信信息！" + wxid;
            }
            else
                 rt=clsNetExecute.Error+"GetGameCount Error:" + errinfo;
        }
        return rt;
    }
    /// <summary>
    /// 开奖算法
    /// </summary>
    /// <param name="gameid"></param>
    /// <param name="userid"></param>
    private void GetGameData(string gameid, string wxid)
    {
        string gamecount = GetGameCount(gameid,wxid);
        if (gamecount.IndexOf(clsNetExecute.Error) > -1)
        {
            clsSharedHelper.WriteInfo(gamecount);
            return;
        }
        else 
        {
            gamecount = gamecount.Replace(clsNetExecute.Successed, "");
            if (Convert.ToInt32(gamecount) <= 0)
            {
                clsSharedHelper.WriteErrorInfo("您已经没有抽取的机会了");
                return;
            }
        }
        string rtMsg = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            DataTable dt = null;

            //判断用户到目前为止是否存在还未消费过的游戏TOKEN wx_t_gamerecords.isconsume=0。
          string str_sql = @"select top 1 a.gametoken,a.prizeid,isnull(b.prizename,'谢谢参与') prizename
                                from wx_t_gamerecords a                                 
                                left join wx_t_gameprize b on a.prizeid=b.id
                                where a.sskey=@sskey and a.gameid=@gameid and a.wxid=@wxid and a.isconsume=0 
                                order by a.gametime desc";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@wxid", wxid));
            paras.Add(new SqlParameter("@gameid", gameid));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    rtMsg = "Successed:" + dt.Rows[0]["gametoken"].ToString() + "|" + dt.Rows[0]["prizeid"].ToString() + "|" + dt.Rows[0]["prizename"].ToString();
                else
                {
                    //接下来先判断用户用户的中奖情况 暂定一个用户只能中一次奖
                    str_sql = @"select top 1 1 from wx_t_getprizerecords where wxid=@wxid and gameid=@gameid and sskey=@sskey ";
                    paras.Clear();
                    paras.Add(new SqlParameter("@wxid", wxid));
                    paras.Add(new SqlParameter("@gameid", gameid));
                    paras.Add(new SqlParameter("@sskey", ConfigKey));
                    if (dt != null)
                        dt.Dispose();
                    errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                    lock (rosePirzeLock)
                    {
                        if (errinfo == "" && dt.Rows.Count > 0)
                        {
                            //否则直接创建一行游戏记录，prizeid=0谢谢参与，并返回
                            string gtoken = System.Guid.NewGuid().ToString();
                            str_sql = @"insert into wx_t_gamerecords(gameid,userid,gametoken,isconsume,prizeid,activetime,gametime,ip,sskey,wxid) 
                                        values(@gameid,@userid,@gtoken,0,0,getdate(),getdate(),@ip,@sskey,@wxid);";
                            paras.Clear();
                            paras.Add(new SqlParameter("@gameid", gameid));
                            paras.Add(new SqlParameter("@userid", "0"));
                            paras.Add(new SqlParameter("@wxid", wxid));
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
                            int PrizeCount = PDT.Rows.Count;
                            Random rd = new Random(DateTime.Now.Millisecond);
                            int MaxNext = Convert.ToInt32(PrizeCount / eggWINPR);
                            int PrizeIndex = rd.Next(0, MaxNext);

                            if (PrizeCount == 0 || (PrizeCount > 0 && PrizeIndex >= PrizeCount))
                            {
                                //否则直接创建一行游戏记录，prizeid=0谢谢参与，并返回
                                string gtoken = System.Guid.NewGuid().ToString();
                                str_sql = @"insert into wx_t_gamerecords(gameid,userid,gametoken,isconsume,prizeid,activetime,gametime,ip,sskey,wxid) 
                                        values(@gameid,@userid,@gtoken,0,0,getdate(),getdate(),@ip,@sskey,@wxid);";
                                paras.Clear();
                                paras.Add(new SqlParameter("@gameid", gameid));
                                paras.Add(new SqlParameter("@userid", "0"));
                                paras.Add(new SqlParameter("@wxid", wxid));
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
                                str_sql = "update wx_t_gamerecords set sskey='" + ConfigKey + "',gameid='" + gameid + "',wxid='" + wxid + "',gametime=getdate(),ip='" + HttpContext.Current.Request.UserHostAddress + "' where id='" + PDT.Rows[PrizeIndex]["id"].ToString() + "'";
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
                        }
                    }//end lock
                }
            }
            else
                rtMsg = "Error:调用GetGameData时出错 errinfo:" + errinfo;
        }
        clsSharedHelper.WriteInfo(rtMsg);
    }
    //消费游戏TOKEN方法
    private void ConsumeGameToken(string token, string wxid, string gameid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string mysql = "select top 1 id,prizeid from wx_t_gamerecords where gametoken=@token and wxid=@wxid and sskey=@sskey and gameid=@gameid and isconsume=0";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@token", token));
            paras.Add(new SqlParameter("@wxid", wxid));
            paras.Add(new SqlParameter("@gameid", gameid));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            DataTable dt = null;
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }
            else if (dt.Rows.Count < 1)
            {
                clsSharedHelper.WriteErrorInfo("对不起，此游戏券【" + token + "】无效！");
                return;
            }

            string gid, prizeid;//gid=wx_t_gamerecords.id;prizeid=wx_t_gamerecords.prizeid
            gid = Convert.ToString(dt.Rows[0]["id"]);
            prizeid = Convert.ToString(dt.Rows[0]["prizeid"]);

            lock (consumeLock)
            {
                mysql = " update wx_t_gamerecords set isconsume=1,consumetime=getdate() where id=@gid;";
                paras.Clear();
                paras.Add(new SqlParameter("@gid", gid));
                errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
                if (errInfo != "")
                {
                    clsSharedHelper.WriteErrorInfo("ConsumeGameToken Fail! errinfo:" + errInfo);
                    return;
                }

                mysql = "update tm_T_TurnTable set UsedCounts =UsedCounts +1 where wxid=@wxid and gameid=@gameid and sskey=@sskey;";
                paras.Clear();
                paras.Add(new SqlParameter("@wxid", wxid));
                paras.Add(new SqlParameter("@gameid", gameid));
                paras.Add(new SqlParameter("@sskey", ConfigKey));
                errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
                if (errInfo != "")
                {
                    clsSharedHelper.WriteErrorInfo("ConsumeGameToken Fail! errinfo:" + errInfo);
                    return;
                }

                if (Convert.ToInt32(prizeid) > 0)
                {
                    mysql = @"insert into wx_t_getprizerecords(gameid,gametoken,prizeid,isget,operator,userid,createtime,isactive,activetime,sskey,wxid)
                    values(@gameid,@token,@pid,0,'',0,getdate(),1,getdate(),@sskey,@wxid);";
                    paras.Clear();
                    paras.Add(new SqlParameter("@gameid", gameid));
                    paras.Add(new SqlParameter("@token", token));
                    paras.Add(new SqlParameter("@pid", prizeid));
                    paras.Add(new SqlParameter("@sskey", ConfigKey));
                    paras.Add(new SqlParameter("@wxid", wxid));
                    errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
                    if (errInfo != "")
                    {
                        clsSharedHelper.WriteErrorInfo("ConsumeGameToken Fail! errInfo:" + errInfo);
                        return;
                    }
                }
            }//end lock
            clsSharedHelper.WriteSuccessedInfo("");
            
           /* mysql = @"declare @gid int;declare @pid int;
                    select @gid=a.id,@pid=a.prizeid
                    from wx_t_gamerecords a                                
                    where a.sskey=@sskey and a.gameid=@gameid and a.gametoken=@token and a.wxid=@wxid and a.isconsume=0;
                    update wx_t_gamerecords set isconsume=1,consumetime=getdate() where id=isnull(@gid,0) and gameid=@gameid and sskey=@sskey;
                    if isnull(@pid,0)<>0
                    insert into wx_t_getprizerecords(gameid,gametoken,prizeid,isget,operator,userid,createtime,isactive,activetime,sskey,wxid)
                    values(@gameid,@token,@pid,0,'',@userid,getdate(),1,getdate(),@sskey,@wxid);
                    update tm_T_TurnTable set UsedCounts =UsedCounts +1 where wxid=@wxid and gameid=@gameid and sskey=@sskey";
            paras.Clear();
            paras.Add(new SqlParameter("@token", token));
            paras.Add(new SqlParameter("@wxid", wxid));
            paras.Add(new SqlParameter("@gameid", gameid));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            paras.Add(new SqlParameter("@userid", "0"));
            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo == "")
                  clsSharedHelper.WriteSuccessedInfo("");
            else
                clsSharedHelper.WriteErrorInfo("ConsumeGameToken Fail! errinfo:" + errInfo);*/
        }
    }
    /// <summary>
    /// 清除内存
    /// </summary>
    private void ClearAwardPool()
    {
        if (_roseDtPrize != null)//奖池内存表
        {
            lock (rosePirzeLock)
            {
                _roseDtPrize.Clear();
                _roseDtPrize.Dispose();
                _roseDtPrize = null;
            }
        }
        clsSharedHelper.WriteSuccessedInfo("");
    }
    /// <summary>
    /// datatable转成json格式
    /// </summary>
    /// <param name="jsonName">转换后的json名称</param>
    /// <param name="dt">待转数据表</param>
    /// <returns></returns>
    public static string DataTableToJson(string jsonName, DataTable dt)
    {
        StringBuilder Json = new StringBuilder();
        Json.Append("{\"" + jsonName + "\":[");
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                Json.Append("{");
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    Json.Append("\"" + dt.Columns[j].ColumnName.ToString() + "\":\"" + dt.Rows[i][j].ToString() + "\"");
                    if (j < dt.Columns.Count - 1)
                    {
                        Json.Append(",");
                    }
                }
                Json.Append("}");
                if (i < dt.Rows.Count - 1)
                {
                    Json.Append(",");
                }
            }
        }
        Json.Append("]}");
        return Json.ToString();
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
