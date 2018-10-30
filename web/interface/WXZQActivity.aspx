<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public static object _syncObj = new object();//用于控制_CakeDT的高并发读取造成的NULL问题
    public static object _sync66 = new object();//用于控制_Cake66DT的高并发读取造成的对象丢失问题
    private static Int32 TokenIndex = 0;    //用于记录令牌生成的个数
    
    private static DataTable _CakeDT = null;
    private static DataTable _Cake66DT = null;//66月饼生成信息表
    public static String connStr = "server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,123";
    public String userid = "";
    private const int CAKENUMBERS = 100;//每次游戏产生的月饼数
    private const string CAKE66NO = "7";//66饼的编号

    private const string GAMESTARTTIME = "2015-09-24 17:00:00";
    private const string GAMEENDTIME = "2015-9-28 00:00:00";

    private static Random rd = new Random(TokenIndex + DateTime.Now.Millisecond);       
    //避免重复取月饼的配置信息
    private static DataTable CakeDT()
    {
        string errInfo = "";
        if (_CakeDT == null)
        {
            lock (_syncObj)
            {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
                {
                    string sql = "select * from zq_t_cakeconfig order by probability desc;";
                    errInfo = dal.ExecuteQuery(sql, out _CakeDT);
                    if (errInfo == "")
                    {
                        _CakeDT.Columns.Add("startSec", typeof(int));
                        _CakeDT.Columns.Add("endSec", typeof(int));                        
                    }
                    //处理DATATABLE构造每种月饼的区间范围 
                    for (int i = 0; i < _CakeDT.Rows.Count; i++)
                    {
                        if (i == 0)
                        {
                            _CakeDT.Rows[i]["startSec"] = 0;
                            _CakeDT.Rows[i]["endSec"] = CakeDT().Rows[i]["probability"];
                        }
                        else
                        {
                            _CakeDT.Rows[i]["startSec"] = _CakeDT.Rows[i - 1]["endSec"];
                            _CakeDT.Rows[i]["endSec"] = Convert.ToInt32(CakeDT().Rows[i]["probability"]) + Convert.ToInt32(_CakeDT.Rows[i]["startSec"]);
                        }                        
                    }
                }
            }// end lock

            if (errInfo != "")
            {
                writeLog("生成静态_CakeDT出错！" + errInfo);
            }
        }

        return _CakeDT;
    }

    private static DataTable Cake66DT()
    {
        string errInfo = "";
        if (_Cake66DT == null)
        {
            lock (_sync66)
            {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
                {
                    string sql = @"select *,dateadd(mi,2,preordertime) EndPreOrderTime from zq_t_cake66pool;";
                    errInfo = dal.ExecuteQuery(sql, out _Cake66DT);
                }
            }//end lock
        }

        if (errInfo != "")
            writeLog("生成静态_Cake66DT时出错！" + errInfo);
        return _Cake66DT;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        userid = Convert.ToString(Session["vipid"]);        
        //除了保存提交的游戏数据函数其它的都需要判断SESSION
        switch (ctrl)
        {
            case "CakeOrders":
                GenarateCakeOrders();
                break;
            case "RankList":
                GetRankList();
                break;
            case "SaveGameData":
                string gametoken = Convert.ToString(Request.Params["GameToken"]);
                string gameinfo = Convert.ToString(Request.Params["GameInfo"]);
                if (gametoken == "" || gametoken == null)
                    clsSharedHelper.WriteErrorInfo("缺少游戏TOKEN！");
                else if (gameinfo == "" || gameinfo == null)
                    clsSharedHelper.WriteErrorInfo("无游戏数据，无须保存！");
                else
                    SaveGameData(gametoken, gameinfo);
                break;
            case "SaveUserInfo":
                //传入三个参数GameToken、UserName、UserPhone
                gametoken = Convert.ToString(Request.Params["GameToken"]);
                string username = Convert.ToString(Request.Params["UserName"]);
                string userphone = Convert.ToString(Request.Params["UserPhone"]);
                if (gametoken == "" || gametoken == null)
                    clsSharedHelper.WriteErrorInfo("缺少游戏TOKEN！");
                username = username == null ? "" : username;
                userphone = userphone == null ? "" : userphone;
                SaveUserInfo(gametoken, username, userphone);
                break;
            case "ClearCakeConfig":
                if (_CakeDT != null)
                {
                    _CakeDT.Dispose();
                    _CakeDT = null;
                    TokenIndex = 0;
                }
                break;
            case "ClearCake66DT":
                if (_Cake66DT != null)
                {
                    _Cake66DT.Dispose();
                    _Cake66DT = null;
                    TokenIndex = 0;
                }
                break;
            case "GetCakeConfig":
                GetCakeConfig();
                break;
            case "printCake66DT":
                printDataTable(Cake66DT());
                break;
            case "GetDBNowTime":
                clsSharedHelper.WriteInfo(GetDBNowTime());
                break;
            case "test":
                jsontest();                
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无效的控制参数！ctrl:" + ctrl);
                break;
        }
    }

    //用于客户端读取月饼信息
    private void GetCakeConfig()
    {
        string cakeStr = JsonHelp.dataset2json(CakeDT());
        clsSharedHelper.WriteInfo(cakeStr);
    }

    private void GenarateCakeOrders()
    {
        if (DateTime.Now < Convert.ToDateTime(GAMESTARTTIME)) {
            clsSharedHelper.WriteErrorInfo("活动还未开始！活动开始时间：2015-9-24 17:00:00 敬请期待...");
            return;
        }
        
        if (DateTime.Now>Convert.ToDateTime(GAMEENDTIME)) {
            clsSharedHelper.WriteErrorInfo("活动已经结束！活动结束时间：2015-9-28 00:00:00");
            return;
        }
        
        if (userid == "" || userid == null)
        {
            clsSharedHelper.WriteErrorInfo("系统超时，请重新登录！");
            return;
        }
        else
        {
            if (!CheckUserGameCount())
            {
                clsSharedHelper.WriteErrorInfo("对不起，您的游戏次数已经用完！");
                return;
            }
            else
            {
                String cakeOrders = "", strGUID = "";
                DataTable dt = CakeDT();                
                string Cake66ID = "";//是否需要更新66的预定信息
                //-------------------------------------测试数据-----------------------------------------
                int y1sl = 0, y2sl = 0, y3sl = 0, y4sl = 0, y5sl = 0, y6sl = 0, y7sl = 0;
                //-------------------------------------测试数据-----------------------------------------
                lock (_syncObj)
                {
                    if (dt.Rows.Count > 0)
                    {
                        int sumb = Convert.ToInt32(dt.Rows[dt.Rows.Count - 1]["endSec"]);
                        TokenIndex++;                        
                        bool One66 = false;//用于控制一次循环里面只能产生出一个66
                        string eachCakeNo = "";
                        string dataBaseTime = GetDBNowTime();
                        for (int i = 0; i < CAKENUMBERS; i++)
                        {
                            int val = rd.Next(sumb);
                            DataRow[] drList = dt.Select("startSec<=" + val + " and " + val + "<endSec", "");
                            if (drList.Length > 0)
                            {
                                eachCakeNo = Convert.ToString(drList[0]["cakeno"]);
                                if (eachCakeNo == CAKE66NO)
                                {
                                    if (One66 || Cake66DT() == null)
                                    {
                                        //本次循环已经产生过了，直接跳过
                                        //或者是_Cake66DT出现问题也直接跳过
                                        i--;
                                        continue;
                                    }
                                    //随机产生了66月饼
                                    Cake66ID = CheckCake66(dataBaseTime);
                                    //Cake66ID有具体ID值时表示此次产生的66有效
                                    if (!(Cake66ID == "" || Cake66ID == "0"))
                                    {
                                        One66 = true;
                                    }
                                    else
                                    {
                                        i--;
                                        continue;
                                    }
                                }
                                //-------------------------------------测试数据-----------------------------------------
                                switch (eachCakeNo)
                                {
                                    case "1":
                                        y1sl++;
                                        break;
                                    case "2":
                                        y2sl++;
                                        break;
                                    case "3":
                                        y3sl++;
                                        break;
                                    case "4":
                                        y4sl++;
                                        break;
                                    case "5":
                                        y5sl++;
                                        break;
                                    case "6":
                                        y6sl++;
                                        break;
                                    case "7":
                                        y7sl++;
                                        break;
                                }
                                //-------------------------------------测试数据-----------------------------------------
                                cakeOrders += eachCakeNo + ",";
                            }
                        }
                    }
                    else
                    {
                        clsSharedHelper.WriteErrorInfo("糟糕，服务器还没准备好月饼！");
                        return;
                    }                    
                } //end lock 

                if (cakeOrders != "")
                {
                    cakeOrders = cakeOrders.Substring(0, cakeOrders.Length - 1);
                    //生成一个GUID
                    strGUID = System.Guid.NewGuid().ToString();
                    //先保存部分游戏信息
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
                    {
                        //生成月饼顺序成功后记得将次数加1上去，防止作弊                     
                        string sql = @"insert into zq_t_gamescore(userid,gametoken,cakelist,starttime,y1sl,y2sl,y3sl,y4sl,y5sl,y6sl,y7sl) values(@userid,@token,@orders,getdate(),@y1,@y2,@y3,@y4,@y5,@y6,@y7);
                                       update wx_t_vipbinging set nowcount=nowcount+1 where id=@userid;";
                        List<SqlParameter> paras = new List<SqlParameter>();
                        paras.Add(new SqlParameter("@userid", userid));
                        paras.Add(new SqlParameter("@token", strGUID));
                        paras.Add(new SqlParameter("@orders", cakeOrders));
                        paras.Add(new SqlParameter("@y1", y1sl));
                        paras.Add(new SqlParameter("@y2", y2sl));
                        paras.Add(new SqlParameter("@y3", y3sl));
                        paras.Add(new SqlParameter("@y4", y4sl));
                        paras.Add(new SqlParameter("@y5", y5sl));
                        paras.Add(new SqlParameter("@y6", y6sl));
                        paras.Add(new SqlParameter("@y7", y7sl));

                        string errInfo = dal.ExecuteNonQuerySecurity(sql, paras);
                        if (errInfo == "")
                        {
                            if (!(Cake66ID == "" || Cake66ID == "0"))
                            {
                                PreOrder66Cake(Cake66ID, strGUID);
                            }
                            clsSharedHelper.WriteInfo(strGUID + "|" + cakeOrders);
                            return;
                        }
                        else
                        {
                            clsSharedHelper.WriteErrorInfo("预保存用户游戏数据失败！" + errInfo);
                            return;
                        }
                    }
                }
            }
        }
    }

    //更新66配置表
    public bool PreOrder66Cake(string id, string gametoken)
    {
        bool result = false;
        string errlog = "";
        lock (_sync66)
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
            {
                string sql = @"update zq_t_cake66pool set preorderrecordid=(
                                select top 1 id from zq_t_gamescore where gametoken=@gametoken
                                ),preordertime=getdate() where id=@id";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@gametoken", gametoken));
                paras.Add(new SqlParameter("@id", id));
                string errInfo = dal.ExecuteNonQuerySecurity(sql, paras);
                if (errInfo == "")
                {
                    //清空
                    _Cake66DT.Dispose();
                    _Cake66DT = null;
                    result = true;
                }
                else
                {
                    errlog += "更新66月饼时间表时出错！" + errInfo + "|gametoken=" + gametoken + "|id:" + id;
                }
            }
        }//end lock
        if (errlog != "")
            writeLog("执行方法PreOrder66Cake：" + errlog + "|IP:" + Request.UserHostAddress);
        return result;
    }

    public string CheckCake66(string DBNowTime)
    {
        string Cake66ID_tmp = "";
        DataTable dt66 = Cake66DT();
        lock (_sync66)
        {            
            if (dt66.Rows.Count > 0)
            {
                //string DBNowTime = GetDBNowTime();
                DataRow[] drList = dt66.Select("starttime<='" + DBNowTime + "' and '" + DBNowTime + "'<endtime and '" + DBNowTime + "'>EndPreOrderTime");
                if (drList.Length > 0)
                {
                    bool isPre = false;
                    string recordID = Convert.ToString(drList[0]["recordid"]);                    
                    string preOrderID = Convert.ToString(drList[0]["preorderrecordid"]);
                    //该时间段内66未被抽中或者是有预定记录但是已经失效了则此时产生的66有效
                    if (recordID == "0" || recordID == "")
                    {
                        DateTime starttime = Convert.ToDateTime(drList[0]["starttime"]);
                        DateTime endtime = Convert.ToDateTime(drList[0]["endtime"]);
                        DateTime preordertime = Convert.ToDateTime(drList[0]["preordertime"]);
                        DateTime EndPreOrderTime = Convert.ToDateTime(drList[0]["EndPreOrderTime"]);
                        if (preordertime >= starttime && preordertime < endtime && Convert.ToDateTime(DBNowTime) < EndPreOrderTime)
                        {
                            isPre = true;
                        }
                        
                        if (preOrderID != "0" && preOrderID != "" && isPre)
                            Cake66ID_tmp = "";
                        else
                            Cake66ID_tmp = Convert.ToString(drList[0]["id"]);
                    }
                    else
                    {
                        Cake66ID_tmp = "";
                    }
                }
            }
        }//end lock

        return Cake66ID_tmp;
    }

    public string GetDBNowTime()
    {
        string rtMsg = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = "select getdate();";
            DataTable dt = null;
            dal.ExecuteQuery(str_sql, out dt);
            if (dt.Rows.Count > 0)
            {
                rtMsg = dt.Rows[0][0].ToString();
            }
        }
        return rtMsg;
    }

    public bool CheckUserGameCount()
    {
        bool result = false;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string sql = @"select gamecount,nowcount from wx_t_vipbinging where id=@userid;";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@userid", userid));
            string errInfo = dal.ExecuteQuerySecurity(sql, paras, out dt);
            if (errInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    int gcount = Convert.ToInt32(dt.Rows[0]["gamecount"]);
                    int ncount = Convert.ToInt32(dt.Rows[0]["nowcount"]);
                    if (gcount > ncount)
                        result = true;
                    else result = false;
                }
                else
                    writeLog("查询不到用户【" + userid + "】游戏剩余次数！"); ;
            }
            else
                writeLog("查询用户【" + userid + "】游戏剩余次数出错！" + errInfo);
        }

        return result;
    }


    //保存用户游戏数据报文格式如下
    /*
     上传数据的参数有两个
        GameToken  和  GameInfo

        GameToken是你传给我的guid，
              gameinfo = @"        {
            ""yb1Count"": 5,
            ""yb2Count"": 2,
            ""yb3Count"": 1,
            ""yb4Count"": 2,
            ""yb5Count"": 0,
            ""yb6Count"": 0,
            ""yb7Count"": 1,
            ""yb1Score"": 5,
            ""yb2Score"": 10,
            ""yb3Score"": 10,
            ""yb4Score"": 40,
            ""yb5Score"": 0,
            ""yb6Score"": 0,
            ""yb7Score"": 666,
            ""AllCount"": 11,
            ""AllScore"": 731
        }";
     */

    public void SaveGameData(string gametoken, string gameinfo)
    {
        clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(gameinfo);
        //数量合法性的判断如果客户端提交的数据已经超过设定的阀值则不保存
        int count = Convert.ToInt32(jh.GetJsonValue("AllCount"));
        if (count > CAKENUMBERS)
        {
            clsSharedHelper.WriteErrorInfo("您的网络开了会儿小差，本次游戏数据没被记录！");
            return;
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            DataTable tmpdt = null;
            String dataid = "", cakelist = "", userid = "";
            String str_sql = @"select a.id,a.userid,a.gametoken,a.cakelist,isnull(b.gamecount,0) gcount,isnull(b.nowcount,0) ncount,isnull(hs.score,0) bestscore,a.gameinfo,
                                case when getdate()<=dateadd(s,20,a.starttime) then 1 else 0 end isActive
                                from zq_t_gamescore a 
                                left join wx_t_vipbinging b on a.userid=b.id 
                                left join zq_t_gamescore hs on hs.id=b.highscore and hs.userid=a.userid
                                where a.gametoken=@gtoken;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gtoken", gametoken));
            string errInfo = dal.ExecuteQuerySecurity(str_sql, paras, out tmpdt);
            if (errInfo == "")
            {
                if (tmpdt.Rows.Count > 0)
                {                    
                    //加上时间的限制判断当超过1分钟后就不再保存数据
                    if (tmpdt.Rows[0]["gameinfo"].ToString() != "" || tmpdt.Rows[0]["isActive"].ToString() == "0")
                    {
                        clsSharedHelper.WriteErrorInfo("您的网络不给力，本次游戏成绩没被保存！");
                        return;
                    }

                    int lcount = Convert.ToInt32(tmpdt.Rows[0]["gcount"]) - Convert.ToInt32(tmpdt.Rows[0]["ncount"]);
                    dataid = tmpdt.Rows[0]["id"].ToString();
                    cakelist = tmpdt.Rows[0]["cakelist"].ToString();
                    userid = tmpdt.Rows[0]["userid"].ToString();
                    Int32 score = Convert.ToInt32(jh.GetJsonValue("AllScore"));
                    Int32 bestscore = Convert.ToInt32(tmpdt.Rows[0]["bestscore"]);
                    int yb7Sl = Convert.ToInt32(jh.GetJsonValue("yb7Count"));
                    if (cakelist != "")
                    {
                        string[] cakeArray = cakelist.Split(',');
                        if (!CheckGameData(cakeArray, score, count))
                        {
                            writeLog("服务器校验数据异常:" + cakelist + Convert.ToString(score) + "|" + Convert.ToString(count));
                            clsSharedHelper.WriteErrorInfo("服务器校验数据异常！" + Convert.ToString(score) + "|" + Convert.ToString(count));
                            return;
                        }
                        else
                        {
                            if (yb7Sl > 0)
                            {
                                if (!CheckAndSave66(yb7Sl, cakeArray, count, dataid))
                                {
                                    clsSharedHelper.WriteErrorInfo("对不起，您的网络出了点问题，本次数据无法提交！");
                                    return;
                                }
                            }
                            //数据校验成功，更新数据
                            str_sql = @"update zq_t_gamescore set gameinfo=@ginfo,eatcount=@count,score=@score,endtime=getdate() where id=@id;                                        
                                        select username,phone,gamecount,nowcount from wx_t_vipbinging where id=@userid;";
                            //产生最好成绩时应该更新用户表中的最好成绩ID                            
                            if (score > bestscore)
                                str_sql += "update wx_t_vipbinging set highscore=@id where id=@userid;";
                            paras.Clear();
                            paras.Add(new SqlParameter("@ginfo", gameinfo));
                            paras.Add(new SqlParameter("@count", count));
                            paras.Add(new SqlParameter("@score", score));
                            paras.Add(new SqlParameter("@id", dataid));
                            paras.Add(new SqlParameter("@userid", userid));
                            errInfo = dal.ExecuteQuerySecurity(str_sql, paras, out tmpdt);
                            if (errInfo == "")
                            {
                                if (tmpdt.Rows.Count > 0)
                                {
                                    clsSharedHelper.WriteInfo(tmpdt.Rows[0]["username"].ToString() + "|" + tmpdt.Rows[0]["phone"].ToString() + "|" + lcount.ToString());
                                    return;
                                }
                            }
                            else
                            {
                                clsSharedHelper.WriteErrorInfo("更新此次游戏结果出错！" + errInfo);
                                return;
                            }
                        }
                    }
                }
                else
                {
                    clsSharedHelper.WriteErrorInfo("查询不到当前TOKEN【" + gametoken + "】对应的游戏记录！");
                    return;
                }
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("查询当前游戏记录出错！" + errInfo);
                return;
            }
        }
    }

    //保存游戏数据前如果包含66饼的检查其合法性
    public bool CheckAndSave66(int yb7Count, string[] cakeList, int eatCount, string dataid)
    {
        bool result = false;
        string errlog = "";
        if (yb7Count == 1)
        { //客户端的数据有吃到66饼            
            //errlog += "客户端的数据有吃到66饼";
            for (int i = 0; i < eatCount; i++)
            {
                if (cakeList[i] == CAKE66NO)
                {
                    //errlog += "服务端校验找到66饼";
                    result = true;
                    break;
                }
                else
                    result = false;
            }

            if (result)
            {
                //更新66饼池的最终记录ID       
                DataTable dt = Cake66DT();
                lock (_sync66)
                {
                    DataRow[] drList = dt.Select("preorderrecordid=" + dataid + "");
                    if (drList.Length > 0)
                    {
                        int cake66poolID = Convert.ToInt32(drList[0]["id"]);
                        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
                        {
                            string str_sql = "update zq_t_cake66pool set recordid=preorderrecordid where id=" + cake66poolID + ";";
                            string errInfo = dal.ExecuteNonQuery(str_sql);
                            if (errInfo == "")
                            {
                                _Cake66DT.Dispose();
                                _Cake66DT = null;
                            }
                            else
                            {
                                errlog += "更新66饼池的最终记录ID出错【" + errInfo + "】";
                                result = false;
                            }
                        }
                    }
                    else
                        result = false;
                }//end lock
            }

            if (errlog != "")
                writeLog("执行CheckAndSave66方法：" + errlog);
        }

        return result;
    }

    //检验用户提交数据的合法性
    public bool CheckGameData(string[] cakeList, Int32 Score, int cakeNums)
    {
        int sscore = 0;
        DataTable dt = CakeDT();

        lock (_syncObj)
        {
            for (int i = 0; i < cakeNums; i++)
            {
                //先设置主键
                dt.PrimaryKey = new DataColumn[] { dt.Columns["cakeno"] };
                DataRow dr = dt.Rows.Find(cakeList[i]);
                if (dr != null)
                    sscore += Convert.ToInt32(dr["cakescore"]);
            }
        }

        if (sscore == Score)
            return true;
        else
            writeLog("Score=" + Score.ToString() + " 但:cakeNums=" + cakeNums.ToString() + " sscore=" + sscore.ToString());
        return false;
    }

    //获取排行数据
    public void GetRankList()
    {
        if (userid == "" || userid == null)
        {
            clsSharedHelper.WriteErrorInfo("系统超时，请重新登录！");
            return;
        }
        else
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
            {
                string str_sql = @"select top 100 row_number() over(order by b.score desc,b.starttime asc) xh,a.id userid,a.wxnick,a.wxheadimgurl,b.score,b.starttime
                                    from wx_t_vipbinging a
                                    inner join zq_t_gamescore b on a.highscore=b.id and a.id=b.userid
                                    where a.username<>'' and a.phone<>''
                                    order by b.score desc,b.starttime asc";
                DataTable dt = null;
                string errInfo = dal.ExecuteQuery(str_sql, out dt);
                if (errInfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        //DT中要把微信名中影响JSON解析的字符替换掉
                        for (int i = 0; i < dt.Rows.Count; i++) {
                            dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace(",", "");
                            dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace("[", "");
                            dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace("]", "");
                            dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace(":", "");
                            dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace("{", "");
                            dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace("}", "");
                        }
                        
                        string myrank = "";
                        string myscore = "";
                        //查询自己的排名
                        DataRow[] drList = dt.Select("userid=" + userid, "");
                        if (drList.Length > 0)
                        {
                            myrank = drList[0]["xh"].ToString();
                            myscore = drList[0]["score"].ToString();
                        }
                        else
                        {
                            //没提交姓名和电话号码的就不统计进来
                            str_sql = @"declare @myscore int;
                                        declare @gametime datetime;declare @myrank int;
                                        select @myscore=isnull(b.score,0),@gametime=b.starttime from wx_t_vipbinging a 
                                        left join zq_t_gamescore b on a.highscore=b.id and a.id=b.userid where a.id=@userid and a.username<>'' and a.phone<>'';

                                        select @myrank=count(a.id)
                                        from wx_t_vipbinging a
                                        inner join zq_t_gamescore b on a.highscore=b.id and a.id=b.userid
                                        where b.score>@myscore or (b.score=@myscore and b.starttime<@gametime);

                                        select @myrank myrank,isnull(@myscore,0) myscore;";
                            DataTable myrankdt = new DataTable();
                            List<SqlParameter> paras = new List<SqlParameter>();
                            paras.Add(new SqlParameter("@userid", userid));

                            errInfo = dal.ExecuteQuerySecurity(str_sql, paras, out myrankdt);
                            if (errInfo == "")
                            {
                                if (myrankdt.Rows.Count > 0)
                                {
                                    myrank = myrankdt.Rows[0]["myrank"].ToString();
                                    myscore = myrankdt.Rows[0]["myscore"].ToString();
                                    if (myscore != "0")
                                        myrank = Convert.ToString(Convert.ToInt32(myrank) + 1);
                                    else
                                    {
                                        myrank = "";
                                        myscore = "";
                                    }
                                }
                            }
                            else
                            {
                                clsSharedHelper.WriteErrorInfo("查询自己的排名出错！" + errInfo);
                                return;
                            }
                        }

                        string jsonData = JsonHelp.dataset2json(dt);
                        jsonData = jsonData.Replace("|", "");
                        
                        clsSharedHelper.WriteInfo(myrank + "|" + myscore + "|" + jsonData);
                        return;
                    }
                    else
                    {
                        clsSharedHelper.WriteErrorInfo("无排行数据！");
                        return;
                    }
                }
                else
                {
                    clsSharedHelper.WriteErrorInfo(errInfo);
                    return;
                }
            }
        }
    }

    //用于保存用户游戏结束后提交的姓名和电话的保存
    public void SaveUserInfo(string gametoken, string username, string userphone)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"if exists (select userid from zq_t_gamescore where gametoken=@gametoken)
                                begin
                                update wx_t_vipbinging set username=@username,phone=@userphone
                                where id=(select userid from zq_t_gamescore where gametoken=@gametoken);
                                select 1;
                                end
                                else
                                begin
                                select 0;
                                end";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gametoken", gametoken));
            paras.Add(new SqlParameter("@username", username));
            paras.Add(new SqlParameter("@userphone", userphone));
            String errInfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0][0].ToString() == "1")
                    {
                        clsSharedHelper.WriteSuccessedInfo("");
                        return;
                    }
                    else if (dt.Rows[0][0].ToString() == "0")
                    {
                        clsSharedHelper.WriteErrorInfo("查询不到对应此次TOKEN的用户记录！");
                        return;
                    }
                }
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("更新用户信息时出错！" + errInfo);
                return;
            }
        }
    }

    public void jsontest() {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr)) {
            string sql = @"select * from wx_t_vipBinging where 
                            wxNick collate Chinese_PRC_CS_AS_WS like '%,%'    
                            OR 
                            wxNick  collate Chinese_PRC_CS_AS_WS  like '%[[]%'   
                            OR 
                            wxNick  collate Chinese_PRC_CS_AS_WS  like '%]%' 
                            OR 
                            wxNick  collate Chinese_PRC_CS_AS_WS  like '%:%' 
                            OR 
                            wxNick  collate Chinese_PRC_CS_AS_WS  like '%{%' 
                            OR 
                            wxNick  collate Chinese_PRC_CS_AS_WS  like '%}%' ";            
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(sql,out dt);
            if (errinfo == "" && dt.Rows.Count > 0 ) {
                for (int i = 0; i < dt.Rows.Count; i++) {
                    dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace(",","");
                    dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace("[", "");
                    dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace("]", "");
                    dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace(":", "");
                    dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace("{", "");
                    dt.Rows[i]["wxnick"] = dt.Rows[i]["wxnick"].ToString().Replace("}", "");
                }
                clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
            }
        }
    }
    
    public void printDataTable(DataTable dt)
    {
        string printStr = "";
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    if (dt.Rows[i][j] == null)
                        printStr += "null&nbsp;";
                    else
                        printStr += dt.Rows[i][j].ToString() + "&nbsp;";
                }
                printStr += "<br />";
            }
            Response.Write(printStr);
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
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
