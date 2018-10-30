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
<%@ Import Namespace="System.Web.Caching" %>


<!DOCTYPE html>
<script runat="server">

    static string WXDBConstr = null;
    private const int GAMEID = 10;
    private static String ConfigKey = clsConfig.GetConfigValue("CurrentConfigKey");
    private const double Seconds = 30 * 60;//缓存cache时间  本参数在此项目中无用
    private int redPackid = 46;
    private string superLuck = "45";
    private const int enlarge = 3;//大奖中奖难度上调倍率
    public static object _Prizelock = new object();
    double WINPR = 0.8;//0.9;     //中奖概率

    private int BUYAMOUNT = 666;        //限定购买金额
    private string DT1 = "2018-06-01";  //活动开始时间（包含）
    private string DT2 = "2018-07-01";  //活动结束时间（不包含）

    string allowIP = "192.168.35.34|127.0.0.1|10.0.0.15|192.168.35.231";//允许ip
    ResponseModel res = null;
    prize p = null;
    private DataTable rebPackPrizeDT()
    {
        //修改实时取数据库、消费时判断持有人是否为自己，不是则视为未中奖
        DataTable _PrizeDT;
        lock (_Prizelock)
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
            {
                string mysql = string.Format(@"SELECT a.id,a.GameToken,a.PrizeID,b.prizename,b.PrizeDesc
                                       FROM wx_t_gamerecords a    
                                       INNER JOIN wx_t_gameprize b on a.prizeid=b.id AND b.gameid={0}
                                       WHERE  a.UserID=0 AND a.gameid={0} AND a.isconsume=0 AND a.activetime<'{1}'", GAMEID, DateTime.Now.ToString());
                string errinfo = dal.ExecuteQuery(mysql, out _PrizeDT);
                if (errinfo != "")
                {
                    res = ResponseModel.setRes(400, "", "服务器出错了!");
                    clsLocalLoger.Log("【世界杯门票抽奖-奖池加载】" + errinfo);
                    clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                    return null;
                }
            }
        }
        return _PrizeDT;
    }
    protected void Page_Load(object sender, EventArgs e)
    {
         Session["openid"] = "oarMEt_qy06fc5FiGwtvNQDvYKzE";
        Session["wxid"] = "1981349";
        Session["vipid"] = 4928990;
        // clsWXHelper.CheckUserAuth(ConfigKey, "vipid");

        //   clsSharedHelper.WriteInfo("vipid=" + Convert.ToString(Session["vipid"]) + "|wxid=" + Convert.ToString(Session["wxid"]) + "|wxopenid=" + Convert.ToString(Session["openid"]));
        if (string.IsNullOrEmpty(Convert.ToString(Session["vipid"])))
        {
            Session.Clear();
            res = ResponseModel.setRes(401, "", "此活动仅限利郎会员参与!");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
        }

        if (string.IsNullOrEmpty(WXDBConstr)) WXDBConstr = clsConfig.GetConfigValue("WXConnStr");
        string ctrl = Convert.ToString(Request.Params["ctrl"]);//执行动作
        string wxid = Convert.ToString(Session["wxid"]);
        string openid = Convert.ToString(Session["openid"]);

        if (string.IsNullOrEmpty(wxid))
        {
            res = ResponseModel.setRes(401, "", "登录超时");
            clsLocalLoger.Log(JsonConvert.SerializeObject(res));
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }
        else if (DateTime.Now < Convert.ToDateTime(DT1))
        {
            res = ResponseModel.setRes(401, "", string.Format("活动将于{0}开始，期待您的参与！", Convert.ToDateTime(DT1).ToString("yyyy年M月d日")));
            clsLocalLoger.Log(JsonConvert.SerializeObject(res));
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }
        else if (DateTime.Now > Convert.ToDateTime(DT2))
        {
            res = ResponseModel.setRes(401, "", "对不起,活动已结束,谢谢参与!");
            clsLocalLoger.Log(JsonConvert.SerializeObject(res));
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }

        switch (ctrl.ToLower())
        {
            case "init": init(); break;
            case "consumegametoken": ConsumeGameToken(); break;
            case "prizeslist": PrizesList(); break;
            case "clearncache":
                clearnCache();
                break;
            case "saveuser": saveUserInfo(); break;

            case "settestmode":
                settestmode();      //设置测试模式
                break;
            default:
                clsSharedHelper.WriteErrorInfo("请检查传入的CTRL是否有效！");
                break;
        }
    }

    private void settestmode()
    {
        Session["wxid"] = "4037";
        Session["openid"] = "oarMEt3YWz0gndx1RmWolC423swM";
        Session["vipid"] = "3022548";
        Response.Write("设置成功！");
    }

    /// <summary>
    /// 清除缓存
    /// </summary>
    private void clearnCache()
    {
        HttpRuntime.Cache.Remove("_PrizeDT");
        if (HttpRuntime.Cache.Get("_PrizeDT") == null)
        {
            clsSharedHelper.WriteInfo("已清除");
        }
        else
        {
            clsSharedHelper.WriteInfo("未清除成功");
        }
    }
    private void saveUserInfo()
    {
        string cname = HttpUtility.UrlDecode(Convert.ToString(Request.Params["cname"]));
        string idcard = Convert.ToString(Request.Params["idcard"]);
        string phone = Convert.ToString(Request.Params["phone"]);

        if (idcard.Length != 18)
        {
            res = ResponseModel.setRes(401, "", "请维护正确的身份证号");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }

        if (phone.Length != 11 || phone.IndexOf("1") != 0)
        {
            res = ResponseModel.setRes(401, "", "请维护正确的手机号码");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }

        List<SqlParameter> paras = new List<SqlParameter>();
        string mysql = "update wc_t_users set cname=@cname,phone=@phone,idcard=@idcard where wxid=@wxid";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            paras.Add(new SqlParameter("@cname", cname));
            paras.Add(new SqlParameter("@idcard", idcard));
            paras.Add(new SqlParameter("@phone", phone));
            paras.Add(new SqlParameter("@wxid", Session["wxid"]));
            string errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo == "")
            {
                res = ResponseModel.setRes(200, "", "");
            }
            else
            {
                res = ResponseModel.setRes(401, "", errInfo);
            }
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    /// <summary>
    /// 初始化用户信息
    /// </summary>
    private void init()
    {
       
        string openid = Convert.ToString(Session["openid"]);
        string wxid = Convert.ToString(Session["wxid"]);
        string vipid = Convert.ToString(Session["vipid"]);
        string vipkh = "";
        string flag = Convert.ToString(Request.Params["flag"]);
        Boolean isrefesh = true;
        if (flag == "0")//是否重新计算可用次数
        {
            isrefesh = false;
        }

        //查询是否中大奖
        Boolean personInfo = false;
        DataTable dt = gameCount(wxid, vipid, openid, isrefesh);
        if (dt == null)
        {
            res = ResponseModel.setRes(401, "", "您无抽奖机会!");
            // clsLocalLoger.Log(JsonConvert.SerializeObject(res));
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }
        Dictionary<string, object> datadic = new Dictionary<string, object>();
        vipkh = Convert.ToString(dt.Rows[0]["vipkh"]);
        Int32 counts = Convert.ToInt32(dt.Rows[0]["gameCounts"]) - Convert.ToInt32(dt.Rows[0]["usedCounts"]);
        datadic.Add("counts", counts);
        datadic.Add("vipkh", vipkh);
        datadic.Add("totalcounts", dt.Rows[0]["gameCounts"]);
        datadic.Add("usedcounts", dt.Rows[0]["usedCounts"]);

        string mysql, errInfo, gtoken;

        if (dt.Rows[0]["cname"] == DBNull.Value || dt.Rows[0]["idcard"] == DBNull.Value || dt.Rows[0]["phone"] == DBNull.Value)
        {
            clsSharedHelper.DisponseDataTable(ref dt);
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
            {
                mysql = string.Format("SELECT top 1 id FROM dbo.wx_t_GetPrizeRecords WHERE wxID={0}  AND GameID={1} AND SSKey={2} AND PrizeID={3} ", wxid, GAMEID, ConfigKey, superLuck);
                errInfo = dal.ExecuteQuery(mysql, out dt);
                if (dt.Rows.Count > 0) personInfo = true;
            }
        }
        clsSharedHelper.DisponseDataTable(ref dt);
        datadic.Add("personInfo", personInfo);


        if (counts < 1)
        {
            datadic.Add("token", "");

            res = ResponseModel.setRes(200, datadic, "您已无抽奖机会!");
            //clsLocalLoger.Log(JsonConvert.SerializeObject(res));
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            mysql = string.Format("SELECT  * FROM dbo.wx_t_GameRecords WHERE wxid={0} AND IsConsume=0 AND GameID={1} AND SSKey={2}", wxid, GAMEID, ConfigKey);
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "")
            {
                res = ResponseModel.setRes(403, "", "内部错误,请重试!");
                clsLocalLoger.Log(JsonConvert.SerializeObject(res));
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                return;
            }
            else if (dt.Rows.Count > 0)
            {
                datadic.Add("token", dt.Rows[0]["GameToken"]);
                res = ResponseModel.setRes(200, datadic, "");
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                return;
            }

            lock (_Prizelock)
            {
                DataTable PDT = rebPackPrizeDT();
                int PrizeCount = PDT.Rows.Count;
                Random rd = new Random(DateTime.Now.Millisecond);
                int MaxNext = Convert.ToInt32(PrizeCount / WINPR); //+ 100
                int PrizeIndex = rd.Next(0, MaxNext+1);
                string prizeid;
                if (PrizeIndex < PrizeCount)
                {
                    prizeid = Convert.ToString(PDT.Rows[PrizeIndex]["PrizeID"]);
                    if (prizeid == superLuck)//中特等奖，判定该省份能不能中奖、
                    {
                        clsLocalLoger.WriteInfo("进入省份验证环节！卡号：" + vipkh);
                        string strProGroup = GetProGroup(vipkh);
                        if (strProGroup == "")
                        {
                            PrizeIndex = PrizeCount;
                            clsLocalLoger.WriteInfo("省份验证不通过，不予发奖！卡号：" + vipkh);
                        }
                        else
                        {
                            if (enlarge > 1)        //需要额外验证大奖是否发放
                            {
                                int maxValue = enlarge + 24 - DateTime.Now.Hour;    //时间越晚，中奖率概率越大

                                clsLocalLoger.WriteInfo("省份验证通过！开始验证放大~");
                                if (rd.Next(0, maxValue) == 0)//中了大奖再放大
                                {
                                    //clsLocalLoger.WriteInfo("写入验证省份成功！可以给予大奖！" + vipkh);
                                    clsLocalLoger.WriteInfo("放大验证通过！可以给予大奖！" + vipkh);
                                }
                                else
                                {
                                    PrizeIndex = PrizeCount;
                                    clsLocalLoger.WriteInfo("放大验证不通过，不予发奖！");
                                }
                            }

                            if (PrizeIndex < PrizeCount)
                            {
                                clsLocalLoger.WriteInfo("验证全部通过，写入省份:" + strProGroup);
                                bool rt = SetProGroupIsUse(strProGroup);
                                if (!rt)//设置省份中奖
                                {
                                    PrizeIndex = PrizeCount;
                                    clsLocalLoger.WriteError("写入验证省份失败，不予发奖！省份：" + strProGroup);
                                }
                            }
                        }
                    }
                }

                List<SqlParameter> paras = new List<SqlParameter>();
                if (PrizeIndex < PrizeCount)//中奖token
                {
                    mysql = "update wx_t_gamerecords set sskey=@sskey,gameid=@gameid,wxid=@wxid,gametime=getdate(),ip=@ip where id=@id;";
                    paras.Add(new SqlParameter("@id", PDT.Rows[PrizeIndex]["id"]));
                    gtoken = Convert.ToString(PDT.Rows[PrizeIndex]["GameToken"]);
                    PDT.Rows.Remove(PDT.Rows[PrizeIndex]);
                }
                else//未中奖
                {
                    mysql = @"insert into wx_t_gamerecords(gameid,userid,gametoken,isconsume,prizeid,activetime,gametime,ip,sskey,wxid) 
                                        values(@gameid,0,@gtoken,0,0,getdate(),getdate(),@ip,@sskey,@wxid);";
                    gtoken = Guid.NewGuid().ToString();
                    paras.Add(new SqlParameter("@gtoken", gtoken));
                }
                paras.Add(new SqlParameter("@gameid", GAMEID));
                paras.Add(new SqlParameter("@wxid", Session["wxid"]));
                paras.Add(new SqlParameter("@ip", HttpContext.Current.Request.UserHostAddress));
                paras.Add(new SqlParameter("@sskey", ConfigKey));
                errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
                if (errInfo == "")
                {
                    datadic.Add("token", gtoken);
                    res = ResponseModel.setRes(200, datadic, "");
                }
                else
                {
                    res = ResponseModel.setRes(400, "", errInfo);
                    clsLocalLoger.WriteError(string.Concat("记录抽奖情况失败！错误：" , errInfo));
                }
                clsSharedHelper.DisponseDataTable(ref PDT);
            }//end lock
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }


    /// <summary>
    /// 初始化游戏次数、获取用户信息
    /// </summary>
    /// <param name="wxid"></param>
    /// <param name="vipid"></param>
    /// <param name="openid"></param>
    /// <returns></returns>
    private DataTable gameCount(string wxid, string vipid, string openid, Boolean isrefesh)
    {
        string mysql, errInfo, vipkh;
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            if (isrefesh)
            {
                mysql = string.Format("select * from wc_t_users where wxid='{0}'", wxid);
                errInfo = dal.ExecuteQuery(mysql, out dt);
                if (errInfo != "") { clsLocalLoger.Log("【世界杯活动】：查询用户"+errInfo);  return null; }

                if(dt.Rows.Count >0 && vipid !=Convert.ToString(dt.Rows[0]["vipid"]))//更改绑定,删除当前关系，把微信id置为负数
                {
                    mysql = string.Format("update wc_t_users set wxid=-wxid where wxid={0}",wxid);
                    dal.ExecuteNonQuery(mysql);
                    dt.Rows.Clear();
                }

                if (dt.Rows.Count < 1 )
                {
                    dal.ConnectionString = clsConfig.GetConfigValue("OAConnStr");
                    mysql = string.Format("SELECT kh as vipkh FROM dbo.YX_T_Vipkh WHERE id={0}", vipid);
                    clsSharedHelper.DisponseDataTable(ref dt);
                    errInfo = dal.ExecuteQuery(mysql, out dt);
                    if (errInfo != "" || dt.Rows.Count < 1) { clsLocalLoger.Log("【世界杯活动】：查vip卡号出错:"+errInfo);  return null; }
                    //declare @usedcounts int;select @usedcounts=ISNULL(max(usedCounts),0) from wc_t_users where vipkh='{3}' 如果多卡绑定同一个vip,同已使用次数
                    mysql = string.Format(@"declare @usedcounts int;select @usedcounts=ISNULL(max(usedCounts),0) from wc_t_users where vipkh='{3}'; 
INSERT INTO wc_t_users (wxid,vipid,wxopenid,vipkh,gameCounts,usedCounts,createtime)
VALUES({0},{1},'{2}','{3}',0,@usedcounts,GETDATE());", wxid, vipid, openid, dt.Rows[0]["vipkh"]);
                    dal.ConnectionString = WXDBConstr;
                    dal.ExecuteNonQuery(mysql);
                }

                vipkh = Convert.ToString(dt.Rows[0]["vipkh"]);
                clsSharedHelper.DisponseDataTable(ref dt);

                dal.ConnectionString = clsConfig.GetConfigValue("FXDBConStr");
                mysql = string.Format(@"SELECT ISNULL(SUM(cs),0) as gamecounts FROM (
SELECT CAST(SUM(je)/{3} AS INT)  cs,id
FROM dbo.zmd_v_lsdjmx
WHERE djbs=1 and  rq>='{0}' and rq<'{1}' AND djlb>0 AND vip='{2}'
GROUP BY id HAVING SUM(je)>={3}) t", DT1, DT2, vipkh, BUYAMOUNT);
                errInfo = dal.ExecuteQuery(mysql, out dt);
                dal.ConnectionString = WXDBConstr;
                dal.ExecuteNonQuery(String.Format("UPDATE wc_t_users SET gameCounts={0} WHERE wxid={1} ", dt.Rows[0]["gamecounts"], wxid));
                clsSharedHelper.DisponseDataTable(ref dt);
            }

            mysql = string.Format("select * from wc_t_users where wxid='{0}'", wxid);
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "") return null;
        }
        return dt;
    }
    /// <summary>
    /// 消费游戏TOKEN方法
    /// </summary>
    private void ConsumeGameToken()
    {
        string wxid = Convert.ToString(Session["wxid"]);
        string openid = Convert.ToString(Session["openid"]);
        string vipid = Convert.ToString(Session["vipid"]);
        string token = Convert.ToString(Request.Params["token"]);
        string rt, prizeName = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string mysql = @"select top 1 a.PrizeID,isnull(b.prizeName,'') prizeName ,a.id
                             from wx_t_gamerecords a LEFT JOIN wx_t_gameprize b ON a.PrizeID=b.id 
                             where a.gametoken=@token and a.wxid=@wxid and a.sskey=@sskey and a.gameid=@gameid and a.isconsume=0";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@token", token));
            paras.Add(new SqlParameter("@wxid", wxid));
            paras.Add(new SqlParameter("@gameid", GAMEID));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            DataTable dt = null;
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                res = ResponseModel.setRes(400, "", errInfo);
                rt = JsonConvert.SerializeObject(res);
                clsSharedHelper.WriteInfo(rt);
            }
            else if (dt.Rows.Count < 1)
            {
                res = ResponseModel.setRes(400, "", "很遗憾，奖品与您擦肩而过!");
                rt = JsonConvert.SerializeObject(res);
                clsSharedHelper.WriteInfo(rt);
            }

            int prizeid = Convert.ToInt32(dt.Rows[0]["PrizeID"]);
            prizeName = Convert.ToString(dt.Rows[0]["prizeName"]);
            string id = Convert.ToString(dt.Rows[0]["id"]);
            clsSharedHelper.DisponseDataTable(ref dt);
            paras.Clear();

            int isget = 0;
            if (prizeid == redPackid)
            {
                DateTime sendTime0 = DateTime.Now;
                rt = SendMoneyForChicken(openid, id);
                DateTime sendTime2 = DateTime.Now;
                if (rt.IndexOf(clsSharedHelper.Successed) < 0)//返回未中奖信息、红包发放失败
                {
                    clsLocalLoger.WriteError(string.Concat("[世界杯活动]：发放红包失败！执行时间：", sendTime0.ToString("HH:mm:ss"), "~", sendTime2.ToString("HH:mm:ss"), "  错误：", rt));
                    // res = ResponseModel.setRes(400, "", "网络出错了,请重试！");
                    // clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                    // return;
                    prizeid = 0;
                    prizeName = "";
                    token = "";
                }
                else
                {
                    clsLocalLoger.WriteInfo(string.Concat("[世界杯活动]：发放红包成功！执行时间：", sendTime0.ToString("HH:mm:ss"), "~", sendTime2.ToString("HH:mm:ss")));
                }
                isget = 1;
            }

            mysql = @" update wx_t_gamerecords set isconsume=1,consumetime=getdate() where gametoken=@token and gameid=@gameid and sskey=@sskey;";  //不管中奖与否，无论如何都需要消费掉，否则下次还是它

            if (prizeid > 0)
            {
                mysql = string.Concat(mysql, @"insert into wx_t_getprizerecords(gameid,gametoken,prizeid,isget,operator,userid,createtime,isactive,activetime,sskey,wxid)
                    values(@gameid,@token,@pid,@isget,'',@userid,getdate(),1,getdate(),@sskey,@wxid);");
                paras.Add(new SqlParameter("@userid", "0"));
                paras.Add(new SqlParameter("@pid", prizeid));
                paras.Add(new SqlParameter("@isget", isget));
            }

            mysql = string.Concat(mysql, "update wc_t_users set usedCounts=usedCounts+1 where vipid=@vipid");
            paras.Add(new SqlParameter("@wxid", wxid));
            paras.Add(new SqlParameter("@token", token));
            paras.Add(new SqlParameter("@gameid", GAMEID));
            paras.Add(new SqlParameter("@sskey", ConfigKey));
            paras.Add(new SqlParameter("@vipid", vipid));

            //clsLocalLoger.WriteInfo("mysql=" + mysql);
            //clsLocalLoger.WriteInfo("wxid=" + Session["wxid"]);
            //clsLocalLoger.WriteInfo("token=" + token);
            //clsLocalLoger.WriteInfo("gameid=" + GAMEID);
            //clsLocalLoger.WriteInfo("sskey=" + ConfigKey);


            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo == "")
            {
                Dictionary<string, object> d_prize = new Dictionary<string, object>();
                d_prize.Add("prizename", prizeName);
                d_prize.Add("prizeid", prizeid);
                res = ResponseModel.setRes(200, d_prize, "");
            }
            else
                res = ResponseModel.setRes(400, "", "糟糕！出错了，请重试！" + errInfo);
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }

    /// <summary>
    /// 查询中奖记录
    /// </summary>
    public void PrizesList()
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string str_sql = string.Format(@"SELECT a.PrizeID,p.prizename,CONVERT(VARCHAR(100),a.createtime,120) createtime,c.RedPackMoney
                    FROM wx_t_getprizerecords a
                    INNER join wx_t_gameprize p on a.prizeid=p.id
                    INNER JOIN dbo.wx_t_GameRecords c ON a.GameToken=c.GameToken
                    WHERE a.gameid=@gameid  AND a.wxID=@wxid
                    ORDER BY a.createtime DESC");

            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gameid", GAMEID));
            paras.Add(new SqlParameter("@wxid", Session["wxid"]));
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                res = ResponseModel.setRes(200, dt, "");
                string rt = JsonConvert.SerializeObject(res);
                clsSharedHelper.DisponseDataTable(ref dt);
                clsSharedHelper.WriteInfo(rt);
            }
            else
            {
                res = ResponseModel.setRes(400, "", errinfo);
                string rt = JsonConvert.SerializeObject(res);
                clsSharedHelper.WriteInfo(rt);
            }
        }//end using
    }

    /***********发送红包接口*开始****************/
    /****************红包配置*************/
    private const string SendRedPackUrl = "https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack"; //发红包的接口URL
    private const string CheckRedPackUrl = "https://api.mch.weixin.qq.com/mmpaymkttransfers/gethbinfo "; //检查红包状态的接口URL
    private string ChickenAppid = clsWXHelper.GetAppID(ConfigKey);        //公众号是APPID；企业号CorpID：如果发红包到企业号中的应用，则该ID为转换ID 
    private string APISecret = clsConfig.GetConfigValue("APISecret");        //企业号绑定商户的API密钥，可在公众号商户后台进行查询
    private string certFile = "zs.aspx";        //公众号绑定商户的API证书的路径 
    private string mch_id = clsConfig.GetConfigValue("mch_id");               //商户号（同时也作为CertPassword）
    private string send_name = "利郎男装";           //红包发送者名称   String(32)
    private const string wishing = "感谢您参与活动，为您奉上红包！";  //红包祝福语 String(128)
    private const string act_name = "世界杯活动";                         //活动名称String(32)   。实测，字数超过十几个就会出错！                                                       
    /// <summary>
    /// 发放红包
    /// </summary> 
    /// <param name="openid">公众号的用户名 openid</param>
    /// <param name="GRID">游戏记录的ID。即： GameRecordsID</param>
    /// <returns></returns>
    private string SendMoneyForChicken(string openid, string GRID)
    {
        string RedPackSendInfo = "";
        string rid = "";
        string strInfo = "";
        object redPackMoney, rewardID;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            //clsLocalLoger.WriteInfo("红包发送阶段1");

            string mysql = "SELECT TOP 1 RedPackMoney FROM wx_t_GameRecords WHERE id=@GRID AND IsConsume=0";
            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.AddRange(new SqlParameter[] { new SqlParameter("@GRID", GRID) });
            strInfo = dal.ExecuteQueryFastSecurity(mysql, lstParams, out redPackMoney);
            if (strInfo != "")
            {
                return string.Format("创建世界杯红包失败！错误：{0}", strInfo);
            }
            else if (redPackMoney == null)
            {
                return string.Format("改奖品已领取！");
            }

            mysql = @"INSERT INTO wx_t_Reward (SourceTypeID,SourceID,SendUserID,SendUserName,SendUserFace,ReceiveUserID,ReceiveUserName,RewardMoney,RewardInfo)
		            VALUES (@SourceTypeID,@SourceID,@SendUserID,@SendUserName,@SendUserFace,@ReceiveUserID,@ReceiveUserName,@RedPackMoney,@RewardInfo);SELECT @@IDENTITY ID";
            lstParams.Clear();
            lstParams.AddRange(new SqlParameter[] {
                new SqlParameter("@SourceTypeID", 2),
                new SqlParameter("@SourceID", GRID),
                new SqlParameter("@SendUserID", "0"),
                new SqlParameter("@SendUserName", "2018世界杯活动"),
                new SqlParameter("@SendUserFace", ""),
                new SqlParameter("@ReceiveUserID", "0"),
                new SqlParameter("@ReceiveUserName", "0"),
                new SqlParameter("@RedPackMoney", redPackMoney),
                new SqlParameter("@RewardInfo", wishing)
            });
            strInfo = dal.ExecuteQueryFastSecurity(mysql, lstParams, out rewardID);

            //clsLocalLoger.WriteInfo("红包发送阶段2");

            WriteSendInfo(dal, rid, "正在推送红包..");

            //clsLocalLoger.WriteInfo("红包发送阶段3");

            int total_amount = Convert.ToInt32(Convert.ToDecimal(redPackMoney) * 100);

            //开始发放红包 
            string SendRedPackPost = @"<xml>
                                                    <sign>内容待生成</sign>
                                                    <mch_billno><![CDATA[{0}]]></mch_billno>
                                                    <mch_id><![CDATA[{1}]]></mch_id>
                                                    <wxappid><![CDATA[{2}]]></wxappid>
                                                    <send_name><![CDATA[{3}]]></send_name>
                                                    <re_openid><![CDATA[{4}]]></re_openid>
                                                    <total_amount><![CDATA[{5}]]></total_amount>
                                                    <total_num>1</total_num>
                                                    <wishing><![CDATA[{6}]]></wishing>
                                                    <client_ip><![CDATA[{7}]]></client_ip>
                                                    <act_name><![CDATA[{8}]]></act_name>
                                                    <remark><![CDATA[{9}]]></remark>
                                                    <nonce_str><![CDATA[{10}]]></nonce_str>
                                                </xml>";

            string nonce_str = Guid.NewGuid().ToString().Replace("-", "");
            string mch_billno = string.Concat(mch_id, DateTime.Now.ToString("yyyyMMdd")
                , DateTime.Now.ToString("HHmmss"), DateTime.Now.Millisecond.ToString().PadLeft(4, '0'));   //商户订单号（每个订单号必须唯一）组成：mch_id+yyyymmdd+10位一天内不能重复的数字。接口根据商户订单号支持重入，如出现超时可再调用。

            if (ConfigKey == "7")
            {
                send_name = "利郎轻商务";
            }

            SendRedPackPost = string.Format(SendRedPackPost, mch_billno, mch_id, this.ChickenAppid, send_name, openid, total_amount
                                            , wishing, clsSharedHelper.GetSourceIP(), act_name, wishing, nonce_str);

            SendRedPackPost = clsNetExecute.GetSign(SendRedPackPost, APISecret);

            if (certFile.Contains(":") == false)
            {
                certFile = Server.MapPath(certFile);
            }

            WriteSendInfo(dal, rid, "开始创建并推送红包..", mch_billno);

            //clsLocalLoger.WriteInfo("红包发送阶段4");

            string xmlInfo = clsNetExecute.HttpRequestCert(SendRedPackUrl, SendRedPackPost, certFile, mch_id);

            //clsLocalLoger.WriteInfo("红包发送阶段5");

            if (xmlInfo.IndexOf(clsNetExecute.Error) == 0)
            {
                RedPackSendInfo = string.Concat("红包接口调用失败！错误：", xmlInfo);   //错误可能是因为证书安装不正确，也可能是因为网络原因
            }
            else
            {
                RedPackSendInfo = string.Concat("红包发放失败！错误：", xmlInfo);
                XmlDocument doc = new XmlDocument();
                try
                {
                    doc.LoadXml(xmlInfo);
                    XmlNode xn = doc.FirstChild;

                    XmlNodeList xnl = xn.SelectNodes("return_code");
                    if (xnl.Count > 0 && xnl[0].InnerText == "SUCCESS")
                    {
                        XmlNodeList xnl2 = xn.SelectNodes("result_code");
                        if (xnl2.Count > 0 && xnl2[0].InnerText == "SUCCESS")
                        {
                            RedPackSendInfo = "打赏成功！";
                        }
                    }
                }
                catch (XmlException xmlErr)
                {
                    return xmlErr.ToString();
                }
            }


            WriteSendInfo(dal, rid, RedPackSendInfo, "");

            //clsLocalLoger.WriteInfo("红包发送阶段6");

            if (RedPackSendInfo.Contains("打赏成功"))
            {
                return string.Concat(clsSharedHelper.Successed, redPackMoney);
            }
            else
            {
                return RedPackSendInfo;
            }
        }
    }
    /// <summary>
    /// 写入红包状态和描述信息
    /// </summary>
    /// <param name="dal">数据操作对象</param>
    /// <param name="rid">打赏ID</param>
    /// <param name="RedPackSendInfo">描述信息。若该信息包含“打赏成功”的字样，会将发送状态置为1</param>
    /// <returns></returns>
    private bool WriteSendInfo(LiLanzDALForXLM dal, string rid, string RedPackSendInfo)
    {
        return WriteSendInfo(dal, rid, RedPackSendInfo, "");
    }
    /// <summary>
    /// 写入红包状态和描述信息。
    /// </summary>
    /// <param name="dal">数据操作对象</param>
    /// <param name="rid">打赏ID</param>
    /// <param name="RedPackSendInfo">描述信息。若该信息包含“打赏成功”的字样，会将发送状态置为1</param>
    /// <param name="mch_billno">红包单号，如果有传入该值。则更新到数据库</param>
    /// <returns></returns>
    private bool WriteSendInfo(LiLanzDALForXLM dal, string rid, string RedPackSendInfo, string mch_billno)
    {
        List<SqlParameter> lstParams = new List<SqlParameter>();
        lstParams.AddRange(new SqlParameter[]{
                new SqlParameter("@id", rid)
        });

        string Addmch_billno = "";
        if (mch_billno != "")
        {
            Addmch_billno = string.Concat(" ,mch_billno='", mch_billno, "' ");
        }

        string AddRedPackStatus = "";       //如果发送的状态中包含'打赏成功'的字样，则更新状态标识
        if (RedPackSendInfo.Contains("打赏成功"))
        {
            AddRedPackStatus = ",RedPackStatus=1 ";
        }

        string strSQL = string.Concat(@"UPDATE wx_t_Reward SET RedPackSendTime=GetDate(),RedPackSendInfo='", RedPackSendInfo, "'", Addmch_billno, AddRedPackStatus, " WHERE ID=@id");    //首先更新发送准备状态
        string strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);
        if (strInfo != "")
        {
            return false;
        }
        return true;
    }
    /***********发送红包接口*结束****************/

    /******查询是否允许中奖省份********/
    #region 核心代码

    private Hashtable ht = new Hashtable();

    private String getProCode(int khid)
    {
        if (ht.ContainsKey(khid))
        {
            return Convert.ToString(ht[khid]);
        }
        else
        {
            return "";
        }
    }

    private void setProCode(int khid, string ProCode)
    {
        if (ht.ContainsKey(khid))
        {
            ht.Remove(khid);
        }

        ht.Add(khid, ProCode);
    }

    /// <summary>
    /// 获取省份代码
    /// 获取省份代码_获取 vipkh 的最后消费单（金额大于等于666），得到消费单的 khid
    //  根据khid 获取其贸易公司的的sfdm  并放入哈希表【缓存】到内存中，下次可直接提取；
    //  取得sfdm之后，放入中奖限定表中进行查询并返回是否允许再中。
    //  注意1：这个方法至关重要，请将执行调用放在加锁的代码段中，以防止并发导致的奖品多发问题；
    /// </summary>
    /// <param name="Cardno">卡号</param>
    /// <returns>如果允许中奖则返回 省份分组名，否则只返回空；中间执行错误，也只返回空</returns>
    public string GetProGroup(string Cardno)
    {
        //首先，查询最后消费单符合条件的khid
        string CXFXDB = clsConfig.GetConfigValue("FXDBConStr");
        int khid = 0;
        string strInfo = "";
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXFXDB))
        {
            //首先获取最新开单的khid
            string strSQLBase = @" SELECT TOP 1 khid,rq FROM CX1.dbo.zmd_T_lsdjb
                WHERE djbs = 1 AND djlb > 0 AND {0}
                UNION ALL
                SELECT TOP 1 khid,rq FROM CX2.dbo.zmd_T_lsdjb
                WHERE djbs = 1 AND djlb > 0 AND {0}
                ORDER BY rq DESC";

            string strSQLWhere = string.Format("vip = '{0}' AND rq >= '{1}' AND rq < '{2}'", Cardno, DT1, DT2);

            string strSQL = string.Format(strSQLBase, strSQLWhere);

            strInfo = dal.ExecuteQuery(strSQL, out dt);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("[世界杯]获取近期消费数据失败！错误：", strInfo));
                return "";
            }
            if (dt.Rows.Count == 0)
            {
                clsSharedHelper.DisponseDataTable(ref dt);
                return "";
            }

            khid = Convert.ToInt32(dt.Rows[0]["khid"]);
            clsSharedHelper.DisponseDataTable(ref dt);
        }

        //至此，获取到最新开单的khid ，以下开始获取省份代码
        string sfdm = getProCode(khid); //尝试读取缓存            
        if (sfdm == "")
        {
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                string strSQL = string.Format("SELECT TOP 1 ccid,sfdm FROM yx_t_khb WHERE khid = {0}", khid);

                strInfo = dal.ExecuteQuery(strSQL, out dt);
                if (strInfo != "" || dt.Rows.Count == 0)
                {
                    clsSharedHelper.DisponseDataTable(ref dt);
                    clsLocalLoger.WriteError(string.Concat("[世界杯]获取CCID失败！错误：", strInfo));
                    return "";
                }
                string ccid = Convert.ToString(dt.Rows[0]["ccid"]);
                string mdsfdm = Convert.ToString(dt.Rows[0]["sfdm"]);
                clsSharedHelper.DisponseDataTable(ref dt);
                string[] cckhid = ccid.Split('-');
                if (cckhid.Length < 3)
                {
                    clsLocalLoger.WriteError(string.Concat("[世界杯]获取到的CCID错误：", ccid));
                    return "";
                }
                else if (cckhid.Length == 3)
                {
                    sfdm = mdsfdm;
                }
                else
                {
                    string mykhid = cckhid[2];
                    strSQL = string.Format("SELECT TOP 1 sfdm FROM yx_t_khb WHERE khid = {0}", mykhid);
                    object objsfdm = "";
                    strInfo = dal.ExecuteQueryFast(strSQL, out objsfdm);
                    if (strInfo != "")
                    {
                        clsLocalLoger.WriteError(string.Concat("[世界杯]获取贸易公司省份代码失败！错误：", strInfo));
                        return "";
                    }
                    sfdm = Convert.ToString(objsfdm);
                }

                setProCode(khid, sfdm); //写入缓存
            }
        }
        //开始根据省份代码判断对应贸易公司是否具有抽取资格
        string WxConn = clsWXHelper.GetWxConn();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WxConn))
        {
            object objProvinceGroup = "";
            string strSQL = string.Format("SELECT TOP 1 ProvinceGroup FROM wx_t_ProvinceCheck WHERE AllToken > NowToken AND IsActive = 1 AND ProvinceCode = '{0}'", sfdm);
            strInfo = dal.ExecuteQueryFast(strSQL, out objProvinceGroup);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("[世界杯]获取省份分组失败！错误：", strInfo));
                return "";
            }

            return Convert.ToString(objProvinceGroup);
        }
    }

    /// <summary>
    /// 设置省份分组 已经抽取出门票了（下次该分组下的省份将不允许再中出）
    /// 注意1：这个方法只会直接是否执行成功，并不会验证传入的省份分组是否正确；
    /// 注意2：这个方法至关重要，请将执行调用放在加锁的代码段中，以防止并发导致的奖品多发问题；
    /// </summary>
    /// <param name="ProvinceGroup">省份分组</param>
    /// <returns>执行成功返回true；否则返回false</returns>
    public bool SetProGroupIsUse(string ProvinceGroup)
    {
        if (string.IsNullOrEmpty(ProvinceGroup)) return false;

        //开始根据省份代码判断对应贸易公司是否具有抽取资格
        string WxConn = clsWXHelper.GetWxConn();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WxConn))
        {
            object objProvinceGroup = "";
            string strSQL = string.Format("UPDATE wx_t_ProvinceCheck SET NowToken = NowToken + 1,GetTime=GetDate() WHERE ProvinceGroup = '{0}'", ProvinceGroup);
            string strInfo = dal.ExecuteNonQuery(strSQL);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("[世界杯]设置省份分组限制失败！错误：", strInfo));
                return false;
            }
        }
        return true;
    }

    #endregion
    /*******是否中奖省份判断结束*******/
    //返回格式
    public class ResponseModel
    {
        private int _code;
        public int code
        {
            set { this._code = value; }
            get { return this._code; }
        }

        private object _data;
        public object data
        {
            set { this._data = value; }
            get { return this._data == null ? string.Empty : this._data; }
        }

        private string _message = "";
        public string message
        {
            set { this._message = value; }
            get { return this._message; }
        }

        public static ResponseModel setRes(int pcode, object pdata, string pmes)
        {
            ResponseModel res = new ResponseModel();
            res.code = pcode;
            res.data = pdata;
            res.message = pmes;
            return res;
        }

        public static ResponseModel setRes(int pcode, object pdata)
        {
            return setRes(pcode, pdata, string.Empty);
        }

        public static ResponseModel setRes(int pcode, string pmes)
        {
            return setRes(pcode, string.Empty, pmes);
        }
    }
    public class prize
    {
        private int _prizeid;
        public int prizeid
        {
            set { this._prizeid = value; }
            get { return this._prizeid; }
        }

        private string _prizename;
        public string prizename
        {
            set { this._prizename = value; }
            get { return this._prizename; }
        }
        public static prize setPrize(int id, string name)
        {
            prize p = new prize();
            p._prizeid = id;
            p._prizename = name;
            return p;
        }
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
