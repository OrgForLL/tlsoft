<%@ WebHandler Language="C#" Class="SupremeGlory" %>
using System;
using System.Web;
using nrWebClass;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;
using System.Threading;

public class SupremeGlory : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    const int saledays = -10;
    private string WXConnStr;
    string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    private bool IsTestMode = false;

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string ctrl = Convert.ToString(context.Request.Params["ctrl"]);
        string rt,sid,bid,refreshtime;
        SupremeGloryOperate sgo = new SupremeGloryOperate();
        string cid = Convert.ToString(context.Request.Params["cid"]);
        if (string.IsNullOrEmpty(cid))
        {
            cid = Convert.ToString(context.Session["qy_customersid"]);
        }
        switch (ctrl)
        {
            case "inituser":
                rt = sgo.initUser(Convert.ToInt32(cid));
                break;
            case "signup":
                string ryid = Convert.ToString(context.Request.Params["ryid"]);
                sid = Convert.ToString(context.Request.Params["sid"]);//报名id，无则新建一条报名
                string stype = Convert.ToString(context.Request.Params["signtype"]);
                rt=sgo.signUp(ryid,cid,sid,stype);
                break;
            case "getSign":
                sid = Convert.ToString(context.Request.Params["sid"]);
                rt = sgo.getSign(cid,sid);
                break;
            case "matchteammate":
                sid = Convert.ToString(context.Request.Params["sid"]);
                rt=  sgo.matchTeammate(cid, sid);
                break;
            case "getmatching"://获取匹配轮询
                sid = Convert.ToString(context.Request.Params["sid"]);
                rt = sgo.getMatching(cid, sid);
                break;
            case "cancelsign":
                sid = Convert.ToString(context.Request.Params["sid"]);
                rt = sgo.cancelSign(sid,cid);
                break;
            case "invitingfriends":
                string fid = Convert.ToString(context.Request.Params["fid"]);
                sid = Convert.ToString(context.Request.Params["sid"]);//报名id，无则新建一条报名
                rt = sgo.invitingFriends(cid,sid, fid);
                break;
            case "battleinfo":
                refreshtime= Convert.ToString(context.Request.Params["refreshtime"]);
                bid = Convert.ToString(context.Request.Params["bid"]);
                rt = sgo.getBattletInfo(cid,bid, refreshtime);
                break;
            case "battleresult":
                bid= Convert.ToString(context.Request.Params["bid"]);
                rt = sgo.getBattletResult(bid);
                break;
            case "settlement":
                rt = sgo.settlement();
                break;
            case "countsales":
                string countdate=Convert.ToString(context.Request.Params["countdate"]);
                rt = sgo.countSales(countdate);
                break;
            case "rankinglist":
                string rtype=Convert.ToString(context.Request.Params["rtype"]);
                rt = sgo.rankingList(rtype, cid);
                break;
            case "resultlist":
                bid = Convert.ToString(context.Request.Params["bid"]);
                rt = sgo.getResultlist(cid, bid); ;
                break;
            case "savemsg":;
                bid = Convert.ToString(context.Request.Params["bid"]);
                string content = Convert.ToString(context.Request.Params["content"]);
                rt = sgo.saveMeg(bid, cid, content);
                break;
            case "getmsgmould":
                rt =sgo.getMsgMould();
                break;
            case "getdanchange":
                bid = Convert.ToString(context.Request.Params["bid"]);
                rt =sgo.getDanChange(cid,bid);
                break;
            default:rt = "{\"code\":\"201\",\"info\":\"\",\"msg\":\"无效请求\"}";
                break;
        }
        clsSharedHelper.WriteInfo(rt);
    }
    class SupremeGloryOperate
    {
        string oaconn = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";
        string wxconn = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
        string testconn = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=weChatTest";
        string cxconn = "server='192.168.35.20';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
        string rtstr = @"{{""code"":""{0}"",""info"":{1},""msg"":""{2}""}}";
        public const int gamePoints = 50;

        public string getDanChange(string cid, string bid)
        {
            Response rs = new Response();
            DataTable dt;
            string mysql = @"SELECT b.result,a.originalDan,a.originalStars,a.originalPoints,c.danname AS originalDanName,c.icon AS origninalIcon,
                                a.NewDan,a.NewStars,a.NewPoints,d.danname AS newDanName,d.icon AS newIcon
                                FROM dbo.ry_t_BattleHarvest a 
                                INNER JOIN dbo.ry_t_BattleDetail b ON a.mxid=b.id 
                                INNER JOIN dbo.ry_t_DanGrading c ON a.originalDan=c.id
                                INNER JOIN dbo.ry_t_DanGrading d ON a.NewDan=d.id
                                WHERE a.battleID=@bid AND a.cid=@cid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@bid",bid));
            paras.Add(new SqlParameter("@cid",cid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                string errInfo= dal.ExecuteQuerySecurity(mysql,paras,out dt);
                if (errInfo != "")
                {
                    rs.msg = errInfo;
                }
                else
                {
                    rs.code = "200";
                    rs.info = dt;
                }
            }
            return JsonConvert.SerializeObject(rs);
        }

        public string getMsgMould()
        {
            Response rs = new Response();
            DataTable dt;
            string mysql = @"SELECT * FROM dbo.ry_t_Battlefield WHERE btype=98";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                string errInfo= dal.ExecuteQuery(mysql,out dt);
                if (errInfo != "")
                {
                    rs.msg = errInfo;
                }
                else
                {
                    rs.code = "200";
                    rs.info = dt;
                }
            }
            return JsonConvert.SerializeObject(rs);
        }

        public string saveMeg(string bid, string cid, string content)
        {
            string mysql = @"INSERT INTO ry_t_BattleInfo(battleid,fightingparty,createtime,cid,ryid,content)
                             SELECT pid,fightingparty,GETDATE(),cid,ryid,@content FROM dbo.ry_t_BattleDetail WHERE pid=@bid AND cid=@cid";
            content = HttpUtility.UrlDecode(content);
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@bid",bid));
            paras.Add(new SqlParameter("@cid", cid));
            paras.Add(new SqlParameter("@content",content));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                string errInfo= dal.ExecuteNonQuerySecurity(mysql,paras);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
            }
            return string.Format(rtstr,"200","\"保存成功\"","") ;
        }

        public string getResultlist(string cid,string bid)
        {
            string mysql, errInfo,resultType,bdate,rt=@"{{""persons"":{0},""rje"":""{1}"",""ravgje"":""{2}"",""rsl"":""{3}"",""bje"":""{4}"",""bavgje"":""{5}"",""bsl"":""{6}"",""resultType"":""{7}"",""bdate"":""{8}"" }}";
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            decimal rje, bje,ravgje,bavgje;
            int rsl, bsl;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                mysql = @"SELECT convert(varchar(10), a.createtime,120) bdate, c.avatar,c.cname,u.mdmc,b.amount,b.salecount,b.avgje,d.danname,u.stars,d.icon,b.fightingparty,b.result,b.cid
                        FROM ry_t_Battle a INNER JOIN ry_t_BattleDetail b ON a.id=b.pid
                        INNER JOIN dbo.wx_t_customers c ON b.cid=c.ID
                        INNER JOIN dbo.ry_t_User u ON b.cid=u.cid
                        INNER JOIN dbo.ry_t_DanGrading d ON u.dan=d.id
                        WHERE a.id=@bid
                        ORDER BY b.fightingparty DESC,b.amount DESC";
                paras.Add(new SqlParameter("@bid",bid));
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if (dt.Rows.Count < 1) return string.Format(rtstr, "201", "\"\"", "未找到战斗信息");
                foreach (DataRow dr in dt.Rows)
                {
                    if (string.IsNullOrEmpty(Convert.ToString(dr["avatar"])))
                    {
                        dr["avatar"] = "http://tm.lilanz.com/QYWX/res/img/vipweixin/lilanzlogo.jpg";
                    }
                    else if (Convert.ToString(dr["avatar"]).IndexOf("http://") < 0)
                        dr["avatar"] = "http://tm.lilanz.com/oa/" + dr["avatar"];
                }
                bdate = Convert.ToString(dt.Rows[0]["bdate"]);
                dt.Columns.Remove("bdate");
                rje = Convert.ToDecimal(dt.Compute("sum(amount)","fightingparty='r'"));
                bje = Convert.ToDecimal(dt.Compute("sum(amount)","fightingparty='b'"));
                ravgje = Convert.ToDecimal(dt.Compute("sum(avgje)","fightingparty='r'"))/5;
                bavgje = Convert.ToDecimal(dt.Compute("sum(avgje)","fightingparty='b'"))/5;
                rsl = Convert.ToInt16(dt.Compute("sum(salecount)", "fightingparty='r'"));
                bsl = Convert.ToInt16(dt.Compute("sum(salecount)","fightingparty='b'"));
                if (Convert.ToInt32(dt.Select("cid=" + cid)[0]["result"]) == 1) resultType = "victory";
                else resultType = "lose";
                rt = string.Format(rt,JsonConvert.SerializeObject(dt),rje,ravgje,rsl,bje,bavgje,bsl,resultType,bdate);
            }
            return string.Format(rtstr,"200",rt,"");
        }
        /// <summary>
        /// 匹配轮询
        /// </summary>
        /// <param name="cid"></param>
        /// <param name="sid"></param>
        /// <returns></returns>
        public string getMatching(string cid, string sid)
        {
            string mysql, errInfo;
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            if (string.IsNullOrEmpty(sid))
            {
                mysql = @"select b.id
                            from ry_t_SignUpDetail a 
                            inner join ry_t_SignUp b on a.pid=b.id and a.cid=@cid and b.signstatus=1;";
                paras.Add(new SqlParameter("@cid", cid));

                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
                {
                    errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                    if (dt.Rows.Count < 1) return string.Format(rtstr, "201", "\"\"", "未找到您的报名记录");
                    sid = Convert.ToString(dt.Rows[0]["id"]);

                    clsSharedHelper.DisponseDataTable(ref dt);
                }
            }
            mysql = "select a.id,b.signstatus ,b.signtype from ry_t_SignUpDetail a INNER JOIN dbo.ry_t_SignUp b ON a.pid=b.id where a.pid=@sid and a.cid=@cid";
            paras.Clear();
            paras.Add(new SqlParameter("@sid", sid));
            paras.Add(new SqlParameter("@cid", cid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if (dt.Rows.Count < 1) return string.Format(rtstr, "201", "\"\"", "未找到报名信息");
                string sdetail=Convert.ToString(dt.Rows[0]["id"]);
                string stype=Convert.ToString(dt.Rows[0]["signtype"]);
                string status = Convert.ToString(dt.Rows[0]["signstatus"]);
                if (status == "0")
                {
                    status = "sign_0";
                }
                else if (status == "1")
                {
                    status = "sign_1";
                }
                else
                {
                    mysql = @"SELECT 'battle_'+CAST(c.battlestatus AS VARCHAR(10)) AS status
                            FROM  ry_t_BattleDetail b 
                            INNER JOIN ry_t_Battle c ON b.pid=c.id where b.signid=@signid";
                    paras.Clear();
                    paras.Add(new SqlParameter("@signid", sdetail));
                    errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                    if (dt.Rows.Count < 1) string.Format(rtstr,"200",@"{{""status"":""""}}","" );//队伍已取消
                    status = Convert.ToString(dt.Rows[0]["status"]);
                    clsSharedHelper.DisponseDataTable(ref dt);
                }

                clsSharedHelper.DisponseDataTable(ref dt);
                //  if (status != "1" && status != "2") return string.Format(rtstr, "201", "\"\"", "您的队伍不在匹配中");

                if (status == "sign_1")
                {
                    mysql = @"select top 9 * from (
                    select c.cname,c.avatar,d.danname,d.icon
                    from ry_t_SignUp a 
                    inner join ry_t_SignUpDetail b on a.id=b.pid
                    inner join wx_t_customers c on b.cid=c.id
                    inner join ry_t_user u on b.cid=u.cid
                    inner join ry_t_DanGrading d on u.dan=d.id
                    where a.id=@sid and a.signstatus=1
                    union all
                    select top 8 '--' cname, '' avatar, '--' danname, '' icon
                    from ry_t_SignUp a 
                    inner join ry_t_SignUpDetail b on a.id=b.pid
                    where a.id<>@sid and a.signstatus=1
                    ) t";
                }
                else{
                    mysql = @"select c.cname,c.avatar,d.danname,d.icon,mx.fightingparty
                                from  ry_t_SignUpDetail a 
                                INNER JOIN  ry_t_BattleDetail b ON a.id=b.signid 
                                INNER JOIN ry_t_BattleDetail mx ON b.pid=mx.pid
                                inner join wx_t_customers c on mx.cid=c.id
                                inner join ry_t_user u on mx.cid=u.cid
                                INNER JOIN ry_t_DanGrading d on u.dan=d.id 
                                WHERE a.pid=@sid  ORDER BY mx.fightingparty";
                }
                paras.Clear();
                paras.Add(new SqlParameter("@sid", sid));

                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                foreach (DataRow dr in dt.Rows)
                {
                    if (string.IsNullOrEmpty(Convert.ToString(dr["avatar"])))
                    {
                        dr["avatar"] = "http://tm.lilanz.com/QYWX/res/img/vipweixin/lilanzlogo.jpg";
                    }else if(  Convert.ToString(dr["avatar"]).IndexOf("http://") < 0)
                        dr["avatar"] = "http://tm.lilanz.com/oa/" + dr["avatar"];
                }
                string rt = JsonConvert.SerializeObject(dt);
                clsSharedHelper.DisponseDataTable(ref dt);
                return string.Format(rtstr,"200",string.Format(@"{{""status"":""{0}"",""stype"":""{1}"",""rows"":{2}}}",status,stype,rt),"");
            }
        }
        /// <summary>
        /// 取消报名
        /// </summary>
        /// <returns></returns>
        public string cancelSign(string sid,string cid)
        {
            string mysql, errInfo;
            DataTable dt;
            mysql = @"select a.id,a.homeOwner,b.numbers,b.signstatus
                        from ry_t_SignUpDetail a 
                        inner join ry_t_SignUp b on a.pid=b.id
                        where a.cid=@cid and b.id=@sid and b.signstatus in(0,1)";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@cid", cid));
            paras.Add(new SqlParameter("@sid", sid));
            string id, homeOwner, numbers,signstatus;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if (dt.Rows.Count < 1) return string.Format(rtstr, "201", "\"\"", "未找到您的报名记录");
                id = Convert.ToString(Convert.ToString(dt.Rows[0]["id"]));
                homeOwner = Convert.ToString(Convert.ToString(dt.Rows[0]["homeOwner"]));
                numbers = Convert.ToString(Convert.ToString(dt.Rows[0]["numbers"]));
                signstatus = Convert.ToString(Convert.ToString(dt.Rows[0]["signstatus"]));
                clsSharedHelper.DisponseDataTable(ref dt);
                paras.Clear();
                if (signstatus == "1")//队伍处于匹配
                {
                    if (homeOwner == "0") return string.Format(rtstr, "201", "\"\"", "您不是房主，不能取消匹配");
                    mysql = "update ry_t_SignUp set signstatus =0 where id=@sid;";
                }
                else//队伍处于排队中
                {
                    if (homeOwner == "1")
                        mysql = "delete ry_t_SignUp where id=@sid;delete ry_t_SignUpDetail where pid=@sid;";
                    else
                    {
                        mysql = @" delete ry_t_SignUpDetail where pid=@sid and cid=@cid;
                                UPDATE ry_t_SignUp SET numbers=(SELECT COUNT(1) FROM ry_t_SignUpDetail WHERE pid=@sid),totalsales=(SELECT sum(sales) FROM ry_t_SignUpDetail WHERE pid=@sid) WHERE id=@sid";
                    }
                }
                paras.Add(new SqlParameter("@cid", cid));
                paras.Add(new SqlParameter("@sid", sid));
                errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
            }
            return string.Format(rtstr, "200", "\"取消成功\"", "");
        }
        /// <summary>
        /// 报名轮询
        /// </summary>
        /// <returns></returns>
        public string getSign(string cid,string sid)
        {
            string mysql, errInfo,rt,homeOwner,stype,signstatus,rt1=@"{{""stype"":""{0}"",""signstatus"":""{1}""}}";
            DataTable dt;

            mysql = "select a.id, a.homeOwner,b.signstatus ,b.signtype from ry_t_SignUpDetail a INNER JOIN dbo.ry_t_SignUp b ON a.pid=b.id where a.pid=@sid and a.cid=@cid";
            List<SqlParameter> paras=new List<SqlParameter>();
            paras.Add(new SqlParameter("@cid",cid));
            paras.Add(new SqlParameter("@sid", sid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if (dt.Rows.Count < 1) return string.Format(rtstr,"200",@"{""status"":"""",""stype"":""0""}","" );//队伍已取消
                homeOwner = Convert.ToString(dt.Rows[0]["homeOwner"]);
                stype = Convert.ToString(dt.Rows[0]["signtype"]);
                signstatus = Convert.ToString(dt.Rows[0]["signstatus"]);
                string sdetail=Convert.ToString(dt.Rows[0]["id"]);
                clsSharedHelper.DisponseDataTable(ref dt);
                if (signstatus == "0") signstatus = "sign_0";
                else if (signstatus == "1") signstatus = "sign_1";
                else
                {
                    mysql = @"SELECT 'battle_'+CAST(c.battlestatus AS VARCHAR(10)) AS status
                            FROM  ry_t_BattleDetail b 
                            INNER JOIN ry_t_Battle c ON b.pid=c.id where b.signid=@signid";
                    paras.Clear();
                    paras.Add(new SqlParameter("@signid", sdetail));
                    errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                    if (dt.Rows.Count < 1) string.Format(rtstr,"200",@"{{""status"":""""}}","" );//队伍已取消
                    signstatus = Convert.ToString(dt.Rows[0]["status"]);
                    clsSharedHelper.DisponseDataTable(ref dt);
                }
                mysql = @"select c.id,c.cid,d.cname,d.avatar,e.danname,e.icon
                            from ry_t_SignUp b 
                            inner join ry_t_SignUpDetail c on b.id=c.pid
                            inner join wx_T_customers d on c.cid=d.id
                            inner join ry_t_user u on c.cid=u.cid
                            inner join ry_t_DanGrading e on u.dan=e.id
                            where b.id=@sid and b.signstatus=0";
                paras.Clear();
                paras.Add(new SqlParameter("@sid",sid));

                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr,"201","\"\"",errInfo);
                foreach (DataRow dr in dt.Rows)
                {
                    if (Convert.ToString(dr["avatar"]).IndexOf("http://") < 0) dr["avatar"] = "http://tm.lilanz.com/oa/" + dr["avatar"];
                }
                rt = JsonConvert.SerializeObject(dt);
                clsSharedHelper.DisponseDataTable(ref dt);
            }
            return string.Format(rtstr,"200",string.Format(@"{{""homeOwner"":""{0}"",""stype"":""{1}"",""status"":""{2}"",""rows"":{3}}}",homeOwner,stype,signstatus,rt),"" ) ;
        }
        public string invitingFriends(string cid, string sid,string fid)
        {
            string mysql, errInfo,cname;
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            mysql = @"SELECT 'sign' statu
                    FROM dbo.ry_t_SignUpDetail a INNER JOIN dbo.ry_t_SignUp b ON a.pid=b.id
                    WHERE cid=@fid AND b.signstatus IN(0,1)
                    UNION ALL
                    SELECT 'battle' statu
                    FROM dbo.ry_t_BattleDetail a INNER JOIN dbo.ry_t_Battle b ON a.pid=b.id
                    WHERE cid=@fid AND b.battlestatus IN(0,1,2)";
            paras.Add(new SqlParameter("@fid", fid));

            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if (dt.Rows.Count > 0) return string.Format(rtstr, "201", "\"\"", "好友已经处于比赛中,不能接受邀请");
                clsSharedHelper.DisponseDataTable(ref dt);

                mysql = @"select a.id,c.cname from  ry_t_SignUp a 
                    inner join ry_t_SignUpDetail b on a.id=b.pid 
                    inner join wx_t_customers c on b.cid=c.id 
                    where b.cid=@cid and a.id=@sid;";
                paras.Clear();
                paras.Add(new SqlParameter("@sid", sid));
                paras.Add(new SqlParameter("@cid", cid));
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if (dt.Rows.Count < 1) return string.Format(rtstr, "201", "\"\"", "未找到报名记录");
                cname = Convert.ToString(dt.Rows[0]["cname"]);
                clsSharedHelper.DisponseDataTable(ref dt);
                paras.Clear();
                mysql = "select name from wx_T_customers where id=@fid;";
                paras.Add(new SqlParameter("@fid", fid));
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if (dt.Rows.Count < 1) return string.Format(rtstr, "201", "\"\"", "未找到好友");
                string fname = Convert.ToString(dt.Rows[0]["name"]);
                clsSharedHelper.DisponseDataTable(ref dt);
                string centen = string.Format(@" {{
                               ""articles"":[
                                   {{
                                       ""title"": ""LILANZ至尊荣耀邀请！"",
                                       ""description"": ""您的好友【{2}】邀请您到至尊荣耀一起组队"",
                                       ""url"": ""{0}"",
                                       ""picurl"": ""{1}""
                                   }} 
                               ]
                                }}", "http://tm.lilanz.com/qywx/project/ryfight/matching5.aspx?sid="+sid+"&cname="+HttpUtility.UrlEncodeUnicode(cname),"http://tm.lilanz.com/qywx/res/img/RyFight/thumb.jpg",cname);
                fname = "xuelm|liqf|8DFFEECA-4237-47F1-BCBB-EA8E32D05F7D";
                using (clsJsonHelper jh = clsWXHelper.SendQYMessageNews(fname, 0, centen))
                {
                    clsLocalLoger.WriteInfo(string.Concat("【至尊荣耀】好友邀请：sid="+sid+";发送结果", jh.jSon));
                }
            }
            return string.Format(rtstr, "200", "\"邀请成功\"", "");
        }
        public string settlement()
        {
            string mysql, errInfo;
            DataTable dt,dt_detail;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                //加载段位基础数据到内存
                mysql = "SELECT id,stars,letuppoints,danname,protectpoint FROM ry_t_DanGrading";
                errInfo = dal.ExecuteQuery(mysql, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                Dictionary<int, DanGrading> dicdan = new Dictionary<int, DanGrading>();//段位表信息
                DanGrading dg;
                foreach (DataRow dr in dt.Rows)
                {
                    dg = new DanGrading();
                    dg.id = Convert.ToInt32(dr["id"]);
                    dg.stars = Convert.ToInt32(dr["stars"]);
                    dg.letUpPoints = Convert.ToInt32(dr["letuppoints"]);
                    dg.protectPoint = Convert.ToInt32(dr["protectpoint"]);
                    dg.danName = Convert.ToString(dr["id"]);
                    dicdan.Add(dg.id, dg);
                }
                clsSharedHelper.DisponseDataTable(ref dt);

                //战队主信息
                mysql = @"SELECT a.id,SUM( CASE WHEN b.fightingparty ='b' THEN b.amount ELSE 0 END) AS bje,SUM( CASE WHEN b.fightingparty ='r' THEN b.amount end) as rje
                        FROM ry_t_Battle a INNER JOIN ry_t_BattleDetail b ON a.id=b.pid
                        WHERE a.battlestatus=1
                        GROUP BY a.id";
                errInfo = dal.ExecuteQuery(mysql, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if (dt.Rows.Count < 1) return string.Format(rtstr, "201", "\"\"", "已无战斗信息,不需要再生成");

                //战斗的明细
                mysql = @"SELECT a.id,b.fightingparty,b.cid,b.ryid,c.dan,c.points,c.stars,b.amount,b.id as detailid
                        FROM ry_t_Battle a INNER JOIN ry_t_BattleDetail b ON a.id=b.pid
                        INNER JOIN ry_t_user c on b.cid=c.cid
                        WHERE a.battlestatus=1";
                errInfo = dal.ExecuteQuery(mysql, out dt_detail);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                Dictionary<int, List<SettlementUser>> dicTeam = new Dictionary<int, List<SettlementUser>>();
                SettlementUser su;
                foreach(DataRow dr in dt_detail.Rows)
                {
                    if (!dicTeam.ContainsKey(Convert.ToInt32(dr["id"])))
                    {
                        dicTeam.Add(Convert.ToInt32(dr["id"]), new List<SettlementUser>());
                    }
                    su = new SettlementUser();
                    su.cid = Convert.ToInt32(dr["cid"]);
                    su.ryid = Convert.ToInt32(dr["ryid"]);
                    su.dan= Convert.ToInt32(dr["dan"]);
                    su.points= Convert.ToInt32(dr["points"]);
                    su.stars= Convert.ToInt32(dr["stars"]);
                    su.fightingparty = Convert.ToString(dr["fightingparty"]);
                    su.amount = Convert.ToDecimal(dr["amount"]);
                    su.detailid = Convert.ToInt32(dr["detailid"]);
                    dicTeam[Convert.ToInt32(dr["id"])].Add(su);
                }
                clsSharedHelper.DisponseDataTable(ref dt_detail);

                string bid;//战斗表id
                decimal bje, rje;//蓝方金额、红方金额
                StringBuilder sb = new StringBuilder();
                foreach (DataRow dr in dt.Rows)
                {
                    bid = Convert.ToString(dr["id"]);
                    bje = Convert.ToDecimal(dr["bje"]);
                    rje = Convert.ToDecimal(dr["rje"]);
                    if(Convert.ToDecimal(dr["bje"]) <=0 && Convert.ToDecimal(dr["rje"])<=0 )  continue;
                    foreach (SettlementUser su1 in dicTeam[Convert.ToInt32(dr["id"])])
                    {
                        su1.setBettleInfo(bje,rje , dicdan);
                        sb.Append(string.Format("UPDATE ry_t_user SET points={0},danid={1},stars={2} WHERE cid={3};",su1.points,su1.dan,su1.stars,su1.cid));
                        sb.Append(string.Format("UPDATE ry_t_BattleDetail SET result={0},points={1} WHERE id={2};",su1.result,su1.points,su1.detailid));
                    }
                    sb.Append(string.Format("UPDATE ry_t_Battle SET battlestatus=2 WHERE id={0};",bid));
                }
                errInfo = dal.ExecuteNonQuery(mysql);
                if(errInfo !="" ) return string.Format(rtstr, "201", "\"\"", errInfo);
            }
            return string.Format(rtstr,"200","\"\"","");
        }
        public string countSales(string countdate)
        {
            //查询销售数据 客单量、客单价、平均折扣
            DateTime mydate;
            if (DateTime.TryParse(countdate, out mydate))
            {
                countdate = mydate.ToShortDateString();
            }
            else
            {
                countdate = DateTime.Now.ToShortDateString();
            }
            string mysql, errInfo;
            DataTable dt;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                mysql = @"SELECT b.ryid,b.id
                        FROM ry_t_Battle a INNER JOIN ry_t_BattleDetail b ON a.id=b.pid
                        WHERE a.battlestatus=1 AND (b.avgsl =0 OR avgje=0 OR avgdiscount=0)";
                //  mysql = "SELECT TOP 10 id as ryid,id FROM dbo.Rs_T_Rydwzl WHERE id IN(19841,25232)";//无数据，测试用
                errInfo = dal.ExecuteQuery(mysql, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if(dt.Rows.Count < 1) return string.Format(rtstr, "200", "\"\"", "已全部生成!");
                List<string> rylist = new List<string>();
                Dictionary<string, string> dicBdetail = new Dictionary<string, string>();
                foreach (DataRow dr in dt.Rows)
                {
                    rylist.Add(dr["id"].ToString());
                    dicBdetail.Add(dr["ryid"].ToString(),dr["id"].ToString());
                }
                clsSharedHelper.DisponseDataTable(ref dt);
                //查询销售数据
                dal.ConnectionString = cxconn;
                string[] ryarray = new string[rylist.Count];
                rylist.CopyTo(ryarray);
                rylist.Clear();
                mysql = string.Format(@"SELECT ryid,SUM(je) AS sumje,SUM(sl) AS sumsl,CAST(AVG(zks) AS DECIMAL(5,2)) azks,COUNT(DISTINCT id) djs
                        FROM dbo.zmd_v_lsdjmx 
                        WHERE rq=CONVERT(VARCHAR(10),GETDATE(),120)  AND ryid IN({0})
                        GROUP BY ryid ",string.Join(",",ryarray));
                errInfo = dal.ExecuteQuery(mysql, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                dal.ConnectionString = testconn;//更新到微信服务器
                decimal avgsl, avgje, azks;
                StringBuilder sbstr = new StringBuilder();
                foreach(DataRow dr in dt.Rows)
                {
                    avgje = Convert.ToDecimal(dr["sumje"])/Convert.ToInt32(dr["djs"]);
                    avgsl = Convert.ToDecimal(dr["sumsl"])/Convert.ToInt32(dr["djs"]);
                    azks = Convert.ToDecimal(dr["azks"]);
                    sbstr.Append(string.Format("UPDATE ry_t_BattleDetail SET avgsl={0:f},avgje={1:f},avgdiscount={2:f} WHERE id={3};",avgsl,avgje,azks, dicBdetail[dr["ryid"].ToString()]));
                    if(sbstr.Length > 30000)
                    {
                        errInfo = dal.ExecuteNonQuery(sbstr.ToString());
                        if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                        sbstr.Remove(0,sbstr.Length);
                    }
                }
                if (sbstr.Length > 0)
                {
                    errInfo = dal.ExecuteNonQuery(sbstr.ToString());
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                    sbstr.Remove(0,sbstr.Length);
                }
                return string.Format(rtstr, "200", "\"全部都生成了\"", "");
            }
        }

        /// <summary>
        /// 获取比赛结果
        /// </summary>
        /// <param name="bid"></param>
        /// <returns></returns>
        public string getBattletResult(string bid)
        {
            string mysql, errInfo;
            mysql = @"SELECT c.cname,d.mdmc,c.avatar,b.nums AS sl,b.amount AS je,0.00 AS kdj,e.danname,e.icon,b.fightingparty
                    FROM ry_t_Battle a INNER JOIN ry_t_BattleDetail b ON a.id=b.pid
                    INNER JOIN dbo.wx_t_customers c ON b.cid=c.ID
                    INNER JOIN ry_t_user d ON b.cid=d.cid
                    INNER JOIN ry_t_DanGrading e ON d.dan=e.id 
                    WHERE a.id=@bid AND ABS(a.battlestatus)=3
                    ORDER BY  b.fightingparty ASC,b.amount DESC";
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@bid", bid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if (dt.Rows.Count < 1) return string.Format(rtstr, "201", "\"\"", "比赛不存在或还未结束,无法查看");
                foreach (DataRow dr in dt.Rows)
                {
                    if(Convert.ToDecimal(dr["sl"])>0)
                        dr["kdj"] = Convert.ToDecimal(dr["je"]) / Convert.ToDecimal(dr["sl"]);
                }
                rtstr = string.Format(rtstr,"200",JsonConvert.SerializeObject(dt),"");
            }
            return rtstr;
        }

        /// <summary>
        /// 获取战斗中数据
        /// </summary>
        /// <returns></returns>
        public string getBattletInfo(string cid,string bid,string refreshtime)
        {
            string mysql, errInfo,plist,status,msglist,rt=@"{{""persons"":{0},""msglist"":{1},""refreshtime"":""{2}"",""status"":""{3}"",""rje"":""{4}"",""bje"":""{5}"",""bid"":""{6}""}}";
            decimal rje = 0, bje = 0;
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();

            string ptime, msgid;
            if (string.IsNullOrEmpty(refreshtime))
            {
                ptime = DateTime.Now.AddDays(-1).ToString("yyyy-MM-dd hh:mm:ss");
                msgid = "0";
            }
            else
            {
                ptime = refreshtime.Split('|')[0];
                msgid = refreshtime.Split('|')[1];
            }

            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                mysql = "SELECT a.id,a.createtime,content,a.cid,a.fightingparty FROM ry_t_BattleInfo a";
                errInfo = dal.ExecuteQuery(mysql, out dt);

                if (string.IsNullOrEmpty(bid) || bid == "0")
                {
                    mysql = @"SELECT a.id
                            FROM dbo.ry_t_Battle a INNER JOIN dbo.ry_t_BattleDetail b ON a.id=b.pid
                            WHERE b.cid=@cid AND a.battlestatus IN(0,1)";
                    paras.Add(new SqlParameter("@cid", cid));
                    errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                    if(dt.Rows.Count < 1 ) return string.Format(rtstr, "201", "\"\"", "未找到您的比赛记录!");
                    bid = Convert.ToString(dt.Rows[0]["id"]);

                    clsSharedHelper.DisponseDataTable(ref dt);
                }

                mysql = @"SELECT refreshtime,'battle_'+cast(battlestatus as varchar(10)) status FROM ry_t_Battle WHERE id=@bid";
                paras.Clear();
                paras.Add(new SqlParameter("@bid", bid));
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if(dt.Rows.Count < 1 ) return string.Format(rtstr, "201", "\"\"", "未找到您的比赛记录!");
                status = Convert.ToString(dt.Rows[0]["status"]);
                DateTime mainrefreshtime= Convert.ToDateTime(dt.Rows[0]["refreshtime"]);
                if (Convert.ToDateTime(ptime) < mainrefreshtime)
                {
                    ptime = mainrefreshtime.AddSeconds(1).ToString("yyyy-MM-dd hh:mm:ss");
                    mysql = @"SELECT u.cname,e.avatar,b.amount,d.icon,d.danname,u.stars,b.fightingparty,b.cid
                            FROM ry_t_Battle a 
                            INNER JOIN ry_t_BattleDetail b ON a.id=b.pid
                            INNER JOIN ry_T_user u ON b.cid=u.cid
                            INNER JOIN ry_t_DanGrading d ON u.dan=d.id
                            INNER JOIN dbo.wx_t_customers e ON b.cid=e.id
                            WHERE a.id=@bid";
                    paras.Clear();
                    paras.Add(new SqlParameter("@bid", bid));
                    errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                    foreach (DataRow dr in dt.Rows)
                    {
                        if (string.IsNullOrEmpty(Convert.ToString(dr["avatar"])))
                        {
                            dr["avatar"] = "http://tm.lilanz.com/QYWX/res/img/vipweixin/lilanzlogo.jpg";
                        }
                        else if (Convert.ToString(dr["avatar"]).IndexOf("http://") < 0)
                            dr["avatar"] = "http://tm.lilanz.com/oa/" + dr["avatar"];
                    }
                    bje = Convert.ToDecimal(dt.Compute("sum(amount)","fightingparty='b'"));
                    rje = Convert.ToDecimal(dt.Compute("sum(amount)","fightingparty='r'"));
                    plist = JsonConvert.SerializeObject(dt);
                    clsSharedHelper.DisponseDataTable(ref dt);
                }
                else
                {
                    plist = "[]";
                }
                //查询看板数据
                mysql = "SELECT a.id,a.createtime,content,a.cid,a.fightingparty  FROM ry_t_BattleInfo a WHERE a.battleid=@bid AND id>@msgid order by a.id";
                paras.Clear();
                paras.Add(new SqlParameter("@bid", bid));
                paras.Add(new SqlParameter("@msgid",msgid));
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if (dt.Rows.Count > 0) msgid=Convert.ToString(dt.Compute("max(id)",""));
                foreach (DataRow dr in dt.Rows)
                {
                    dr["content"] = HttpUtility.UrlEncodeUnicode(Convert.ToString(dr["content"]));
                }
                refreshtime = ptime + "|" + msgid;
                rt = string.Format(rt,plist,JsonConvert.SerializeObject(dt),refreshtime,status,rje,bje,bid);
                clsSharedHelper.DisponseDataTable(ref dt);
            }
            return string.Format(rtstr,"200",rt,"");
        }


        /// <summary>
        /// 匹配队友
        /// </summary>
        /// <returns></returns>
        public string matchTeammate(string cid, string sid)
        {
            string mysql, errInfo;
            mysql = @"SELECT  signstatus,a.homeOwner
                    FROM ry_t_SignUpDetail a INNER JOIN ry_t_SignUp b ON a.pid=b.id
                    WHERE a.cid=@cid AND b.id=@sid";
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@cid", cid));
            paras.Add(new SqlParameter("@sid", sid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if(dt.Rows.Count < 1 ) return string.Format(rtstr, "201", "\"\"", "您的报名组已解散或您不在该分组中,不能匹配队友!");
                if(Convert.ToInt32(dt.Rows[0]["signstatus"]) == 1)  return string.Format(rtstr, "201", "\"\"", "已在匹配队友中,请耐心等待!");
                if(Convert.ToInt32(dt.Rows[0]["signstatus"]) == 2)  return string.Format(rtstr, "201", "\"\"", "您的报名组已进入比赛!");
                if (Convert.ToInt32(dt.Rows[0]["signstatus"]) == -1) return string.Format(rtstr, "201", "\"\"", "您的报名组匹配失败,请重新组队!");
                if (Convert.ToInt32(dt.Rows[0]["homeOwner"]) == 0) return string.Format(rtstr, "201", "\"\"", "您不是房主,不能开始比赛!");

                mysql = "UPDATE ry_t_SignUp SET signstatus =1 WHERE id=@id";
                paras.Clear();
                paras.Add(new SqlParameter("@id", sid));
                errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                clsRunSignUpOrder rsuo = new clsRunSignUpOrder();
                rsuo.Run();
                rtstr = string.Format(rtstr, "200", "\"\"","");
            }
            return rtstr;
        }
        /// <summary>
        /// 报名
        /// </summary>
        /// <param name="cid">用户微信id</param>
        /// <param name="sid">报名id</param>
        /// <returns></returns>
        public string signUp(string ryid, string cid, string sid,string stype)
        {
            if (string.IsNullOrEmpty(stype)) stype = "1";

            if (DateTime.Now.Hour < 6 || DateTime.Now.Hour > 23)
            {
                return string.Format(rtstr, "201", "\"\"", "报名时间已过,请明天在6点-10点间报名！");
            }
            string mysql, errInfo,rt=@"{{""sid"":""{0}""}}";
            int homeOwner = 0;
            //判断是否处于报名状态或比赛状态
            mysql = @"SELECT CASE WHEN signstatus=0 THEN '报名等待' ELSE '正在匹配' END AS statu
                    FROM ry_t_SignUpDetail a INNER JOIN ry_t_SignUp b ON a.pid=b.id
                    WHERE a.cid=@cid AND signstatus IN(0,1)
                    UNION ALL 
                    SELECT  '努力战斗' AS statu
                    FROM ry_t_BattleDetail a INNER JOIN ry_t_Battle b ON a.pid=b.id
                    WHERE a.cid=@cid AND a.result=0";
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@cid", cid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                if (dt.Rows.Count > 0) return string.Format(rtstr, "201", "\"\"", "用户处于【" + dt.Rows[0]["statu"].ToString() + "】中,不允许再报名");
                clsSharedHelper.DisponseDataTable(ref dt);


                if (string.IsNullOrEmpty(sid) || sid=="0")
                {
                    homeOwner = 1;
                    mysql = "INSERT INTO ry_t_SignUp(signdate,numbers,totalsales,signstatus,signtype) VALUES(GETDATE(),1,0,0,@stype); SELECT @@Identity";
                    paras.Clear();
                    paras.Add(new SqlParameter("@stype", stype));
                    errInfo = dal.ExecuteQuerySecurity(mysql,paras ,out dt);
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                    sid = Convert.ToString(dt.Rows[0][0]);
                }

                else //判断状态及人数
                {
                    mysql = "SELECT COUNT(1) rows,a.signtype FROM ry_t_SignUp a INNER JOIN ry_t_SignUpDetail b ON a.id=b.pid WHERE a.id=@sid AND  a.signstatus =0 group by a.signtype";
                    paras.Clear();
                    paras.Add(new SqlParameter("@sid", sid));
                    errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                    if (dt.Rows.Count < 1 || Convert.ToInt32(dt.Rows[0][0]) < 1) return string.Format(rtstr, "201", "\"\"", "该队伍已不存在,请重新报名");
                    if (Convert.ToInt32(dt.Rows[0][0]) >= 5) return string.Format(rtstr, "201", "\"\"", "队伍人数已达上限,请重新报名组队");
                    if(Convert.ToString(dt.Rows[0]["signtype"]) != stype) return string.Format(rtstr, "201", "\"\"", "单人匹配房间,不允许加入");
                }

                //开始报名信息
                dal.ConnectionString = cxconn;
                mysql = "SELECT CAST(ISNULL(SUM(je*ABS(djlb)/djlb),0) AS DECIMAL(9,2)) FROM dbo.zmd_v_lsdjmx WHERE rq>=DATEADD(DAY,@days,GETDATE()) AND ryid=@ryid";
                paras.Clear();
                paras.Add(new SqlParameter("@days", saledays));
                paras.Add(new SqlParameter("@ryid", ryid));
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                dal.ConnectionString = testconn;
                mysql = @"INSERT INTO ry_t_SignUpDetail(pid,cid,ryid,signtime,sales,homeOwner) VALUES(@pid,@cid,@ryid,getdate(),@sales,@homeOwner);
                        UPDATE ry_t_SignUp SET numbers=(SELECT COUNT(1) FROM ry_t_SignUpDetail WHERE pid=@pid),totalsales=(SELECT sum(sales) FROM ry_t_SignUpDetail WHERE pid=@pid) WHERE id=@pid;
                        SELECT b.cname,c.avatar,d.danname,a.homeOwner
                        FROM ry_t_SignUpDetail a INNER JOIN ry_t_user b ON a.cid=b.cid INNER JOIN dbo.wx_t_customers c ON a.cid=c.ID INNER JOIN ry_t_DanGrading d ON b.dan=d.id
                        WHERE a.pid=@pid ORDER BY a.id;";
                paras.Clear();
                paras.Add(new SqlParameter("@pid",sid));
                paras.Add(new SqlParameter("@cid", cid));
                paras.Add(new SqlParameter("@ryid", ryid));
                paras.Add(new SqlParameter("@sales", dt.Rows[0][0]));
                paras.Add(new SqlParameter("@homeOwner",homeOwner));
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);//需要修改
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                rtstr = string.Format(rtstr,"200",string.Format(rt,sid),"");//JsonConvert.SerializeObject(dt)
            }
            return rtstr;
        }

        /// <summary>
        /// 排行榜
        /// </summary>
        /// <param name="type"></param>
        /// <param name="cid"></param>
        /// <returns></returns>
        public string rankingList(string rtype, string cid)
        {
            Response rs = new Response();
            string mysql, errInfo;
            Dictionary<string, RankInfo> dicRank = new Dictionary<string, RankInfo>();
            List<SqlParameter> paras = new List<SqlParameter>();
            DataTable dt;
            mysql = string.Format(@"SELECT b.cid,b.dan,c.danname,c.icon,b.cname,a.mdmc,d.avatar,a.stars
                         FROM dbo.ry_t_User a INNER JOIN ry_t_User b ON a.{0}=b.{0}
                         INNER JOIN dbo.ry_t_DanGrading c ON b.dan=c.id
                         INNER JOIN wx_T_customers d on b.cid=d.id
                         WHERE a.cid=@cid order by b.dan desc",rtype);
            if (!rtype.Contains("khid") && !rtype.Contains("mdid")) return string.Format(rtstr, "201", "\"\"", "输入类型不合法");
            paras.Add(new SqlParameter("@cid", cid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "")
                {
                    rs.msg = errInfo;
                    return JsonConvert.SerializeObject(rs);
                }
                if (dt.Rows.Count < 1)
                {
                    rs.code = "200";
                    rs.info =dt;
                    return JsonConvert.SerializeObject(rs);
                }
                foreach (DataRow dr in dt.Rows)
                {
                    dicRank.Add(Convert.ToString(dr["cid"]),new RankInfo());
                    dicRank[Convert.ToString(dr["cid"])].cid = Convert.ToInt32(dr["cid"]);
                    dicRank[Convert.ToString(dr["cid"])].danname = Convert.ToString(dr["danname"]);
                    dicRank[Convert.ToString(dr["cid"])].cname = Convert.ToString(dr["cname"]);
                    dicRank[Convert.ToString(dr["cid"])].icon = Convert.ToString(dr["icon"]);
                    dicRank[Convert.ToString(dr["cid"])].mdmc = Convert.ToString(dr["mdmc"]);
                    dicRank[Convert.ToString(dr["cid"])].avatar = Convert.ToString(dr["avatar"]);
                    dicRank[Convert.ToString(dr["cid"])].stars = Convert.ToInt32(dr["stars"]);
                }
                clsSharedHelper.DisponseDataTable(ref dt);
                String[]cidArray= new String[dicRank.Count];
                dicRank.Keys.CopyTo(cidArray, 0);
                string cidList = string.Join(",",cidArray);

                mysql = string.Format(@" SELECT cid,MAX(status) status,MAX(gameTimes) gameTimes,MAX(winTimes) winTimes
                        FROM ( 
                        SELECT b.cid,'sign_0' as status,0 AS gameTimes,0 AS winTimes
                        FROM dbo.ry_t_SignUp a INNER JOIN dbo.ry_t_SignUpDetail b ON a.id=b.pid
                        WHERE b.cid IN({0}) AND a.signstatus IN(0,1)
                        UNION ALL
                        SELECT b.cid, 'battle_2' as status,0 AS gameTimes,0 AS winTimes
                        FROM dbo.ry_t_Battle a INNER JOIN dbo.ry_t_BattleDetail b ON a.id=b.pid
                        WHERE b.cid IN({0}) AND a.battlestatus IN(0,1,2)
                        UNION ALL 
                        SELECT cid,'' AS status, count(1) AS gameTimes,SUM(CASE result WHEN 1 THEN 1 ELSE 0 END) AS winTimes
						FROM ry_t_BattleDetail
						WHERE cid IN({0}) AND ABS(result)=1
						GROUP BY cid ) t GROUP BY cid",cidList);
                errInfo = dal.ExecuteQuery(mysql, out dt);
                if (errInfo != "")
                {
                    rs.msg = errInfo;
                    return JsonConvert.SerializeObject(rs);
                }
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow dr in dt.Rows)
                    {
                        dicRank[Convert.ToString(dr["cid"])].status = Convert.ToString(dr["status"]);
                        dicRank[Convert.ToString(dr["cid"])].gameTimes = Convert.ToInt32(dr["gameTimes"]);
                        dicRank[Convert.ToString(dr["cid"])].winTimes = Convert.ToInt32(dr["winTimes"]);
                    }
                    clsSharedHelper.DisponseDataTable(ref dt);
                }
                rs.code = "200";
                RankInfo[] rkArr = new RankInfo[dicRank.Count];
                dicRank.Values.CopyTo(rkArr, 0);
                dicRank.Clear();
                rs.info = rkArr;
            }
            return JsonConvert.SerializeObject(rs); ;
        }

        /// <summary>
        /// 初始化用户，无用户则创建，使用微信企业号身份
        /// </summary>
        /// <param name="cid"></param>
        /// <returns></returns>
        public string initUser(int cid)
        {
            string mysql = "SELECT a.*,b.danname,c.avatar FROM ry_t_User a inner join ry_t_DanGrading b ON a.dan=b.id INNER JOIN dbo.wx_t_customers c ON a.cid=c.id  WHERE a.cid=@cid";
            string errInfo;
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@cid", cid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(testconn))
            {
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                user u = new user();
                u.cid = Convert.ToInt32(cid);
                if (dt.Rows.Count > 0)
                {
                    u.ryid = Convert.ToInt32(dt.Rows[0]["ryid"]);
                    u.cname = Convert.ToString(dt.Rows[0]["cname"]);
                    u.points = Convert.ToInt32(dt.Rows[0]["points"]); ;
                    u.dan = Convert.ToInt32(dt.Rows[0]["dan"]); ;
                    u.danname = Convert.ToString(dt.Rows[0]["danname"]);
                    u.headimg = Convert.ToString(dt.Rows[0]["avatar"]);
                    u.experience = Convert.ToInt32(dt.Rows[0]["experience"]); ;
                    u.stars = Convert.ToInt32(dt.Rows[0]["stars"]); ;
                    u.coins = Convert.ToInt32(dt.Rows[0]["coins"]); ;
                    u.mdid = Convert.ToInt32(dt.Rows[0]["mdid"]);
                    u.mdmc = Convert.ToString(dt.Rows[0]["mdmc"]);
                    u.khid = Convert.ToInt32(dt.Rows[0]["khid"]);
                    u.khmc = Convert.ToString(dt.Rows[0]["khmc"]);
                    mysql = "SELECT COUNT(1) AS matchesNum,ISNULL(SUM(CASE WHEN result=1 THEN 1 ELSE 0 END),0) AS winNum FROM ry_t_BattleDetail WHERE cid=@cid AND ABS(result)=1";
                    paras.Clear();
                    paras.Add(new SqlParameter("@cid", cid));
                    clsSharedHelper.DisponseDataTable(ref dt);
                    errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                    u.matchesNum = Convert.ToInt32(dt.Rows[0]["matchesNum"]);
                    u.winNum = Convert.ToInt32(dt.Rows[0]["winNum"]);
                    clsSharedHelper.DisponseDataTable(ref dt);

                    //查询当前状态
                    mysql = @"SELECT a.id as sid, 'sign_'+CAST(a.signstatus AS VARCHAR(10)) as status,b.homeOwner,a.signtype as stype
                            FROM dbo.ry_t_SignUp a INNER JOIN ry_t_SignUpDetail b ON a.id=b.pid
                            WHERE a.signstatus in(0,1) AND b.cid=@cid
                            UNION all
                            SELECT a.id as sid,  'battle_'+CAST(a.battlestatus AS VARCHAR(10)) as status,0 as homeOwner,0 as stype
                            FROM ry_t_Battle a INNER JOIN ry_t_BattleDetail b ON a.id=b.pid
                            WHERE a.battlestatus IN(0,1) AND b.cid=@cid";
                    paras.Clear();
                    paras.Add(new SqlParameter("@cid", cid));
                    clsSharedHelper.DisponseDataTable(ref dt);
                    errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                    if (dt.Rows.Count < 1) u.status = "";
                    else
                    {
                        u.status = Convert.ToString(dt.Rows[0]["status"]);
                        u.sid=Convert.ToInt32(dt.Rows[0]["sid"]);
                        u.homeOwner=Convert.ToInt32(dt.Rows[0]["homeOwner"]);
                        u.stype = Convert.ToInt32(dt.Rows[0]["stype"]);
                        if (u.status.Contains("battle"))
                        {
                            u.bid = u.sid;
                            u.sid = 0;
                        }
                    }

                    clsSharedHelper.DisponseDataTable(ref dt);
                }
                else //创建用户
                {
                    u.points = 0; u.dan = 1; u.experience = 0; u.stars = 0; u.coins = 0; u.matchesNum = 0; u.winNum = 0; u.status = ""; u.danname = "店铺跑腿Ⅲ"; u.sid = 0; u.bid=0;
                    clsSharedHelper.DisponseDataTable(ref dt);
                    mysql = @"SELECT a.id AS cid,a.cname, c.relateID AS ryid,d.mdid,a.avatar
                            FROM dbo.wx_t_customers a 
                            INNER JOIN dbo.wx_t_AppAuthorized b ON a.id=b.UserID AND b.SystemID=3
                            INNER JOIN dbo.wx_t_OmniChannelUser c ON b.SystemKey=c.ID
                            INNER JOIN dbo.Rs_T_Rydwzl d ON c.relateID=d.id
                            WHERE a.id=@cid";
                    paras.Clear();
                    paras.Add(new SqlParameter("@cid", cid));
                    errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                    if (dt.Rows.Count < 1) return string.Format(rtstr, "201", "\"\"", "未找到您的人资信息,因此无法参加游戏!");
                    u.ryid = Convert.ToInt32(dt.Rows[0]["ryid"]);
                    u.cname = Convert.ToString(dt.Rows[0]["cname"]);
                    u.mdid = Convert.ToInt32(dt.Rows[0]["mdid"]);
                    u.headimg = Convert.ToString(dt.Rows[0]["avatar"]);
                    clsSharedHelper.DisponseDataTable(ref dt);
                    dal.ConnectionString = oaconn;//查询主库数据
                    mysql = @"SELECT  a.mdid,a.mdmc,c.khid,c.khmc
                                FROM dbo.t_mdb a 
                                INNER JOIN dbo.yx_t_khb b ON a.khid=b.khid
                                INNER JOIN yx_t_khb c ON dbo.split(b.ccid,'-',2)=c.khid
                                WHERE a.mdid=@mdid";

                    paras.Clear();
                    paras.Add(new SqlParameter("@mdid", u.mdid));
                    errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                    u.mdmc = Convert.ToString(dt.Rows[0]["mdmc"]);
                    u.khid = Convert.ToInt32(dt.Rows[0]["khid"]);
                    u.khmc = Convert.ToString(dt.Rows[0]["khmc"]);

                    dal.ConnectionString = testconn;//插入到测试库
                    mysql = @"INSERT INTO ry_t_User(cid,ryid,points,dan,experience,stars,coins,mdid,mdmc,khid,khmc,cname)
                              VALUES(@cid,@ryid,@points,@dan,@experience,@stars,@coins,@mdid,@mdmc,@khid,@khmc,@cname)";
                    paras.Clear();
                    paras.Add(new SqlParameter("@cid", u.cid));
                    paras.Add(new SqlParameter("@ryid", u.ryid));
                    paras.Add(new SqlParameter("@points", u.points));
                    paras.Add(new SqlParameter("@dan", u.dan));
                    paras.Add(new SqlParameter("@experience", u.experience));
                    paras.Add(new SqlParameter("@stars", u.stars));
                    paras.Add(new SqlParameter("@coins", u.coins));
                    paras.Add(new SqlParameter("@mdid", u.mdid));
                    paras.Add(new SqlParameter("@mdmc", u.mdmc));
                    paras.Add(new SqlParameter("@khid", u.khid));
                    paras.Add(new SqlParameter("@khmc", u.khmc));
                    paras.Add(new SqlParameter("@cname", u.cname));

                    errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
                    if (errInfo != "") return string.Format(rtstr, "201", "\"\"", errInfo);
                }
                rtstr = string.Format(rtstr, "200", JsonConvert.SerializeObject(u), "");
            }
            return rtstr;
        }
    }

    class user
    {
        int _cid;
        public int cid
        {
            get { return _cid; }
            set { _cid = value; }
        }
        string _cname;
        public string cname
        {
            get { return _cname; }
            set { _cname = value; }
        }
        int _ryid;
        public int ryid
        {
            get { return _ryid; }
            set { _ryid = value; }
        }
        int _points;
        public int points
        {
            get { return _points; }
            set { _points = value; }
        }
        int _dan;
        public int dan
        {
            get { return _dan; }
            set { _dan = value; }
        }
        string _danname;
        public string danname
        {
            get { return _danname; }
            set { _danname = value; }
        }
        string _headimg;
        public string headimg
        {
            get
            {
                if (_headimg.IndexOf("http://") < 0)
                {
                    return "http://tm.lilanz.com/oa/" + _headimg;
                }
                else return _headimg;
            }
            set { _headimg = value; }
        }
        int _experience;
        public int experience
        {
            get { return _experience; }
            set { _experience = value; }
        }
        int _stars;
        public int stars
        {
            get { return _stars; }
            set { _stars = value; }
        }
        int _coins;
        public int coins
        {
            get { return _coins; }
            set { _coins = value; }
        }
        int _mdid;
        public int mdid
        {
            get { return _mdid; }
            set { _mdid = value; }
        }
        string _mdmc;
        public string mdmc
        {
            get { return _mdmc; }
            set { _mdmc = value; }
        }
        int _khid;
        public int khid
        {
            get { return _khid; }
            set { _khid = value; }
        }
        string _khmc;
        public string khmc
        {
            get { return _khmc; }
            set { _khmc = value; }
        }
        int _winNum;
        public int winNum
        {
            get { return _winNum; }
            set { _winNum = value; }
        }
        int _matchesNum;
        public int matchesNum {
            get { return _matchesNum; }
            set { _matchesNum = value; }
        }
        string _status;
        public string status
        {
            get { return _status; }
            set { _status = value; }
        }
        int _sid;
        public int sid
        {
            get { return _sid; }
            set { _sid = value; }
        }
        int _homeOwner;
        public int homeOwner
        {
            get {  return _homeOwner; }
            set { _homeOwner = value; }
        }
        int _stype;
        public int stype
        {
            get {  return _stype; }
            set { _stype = value; }
        }
        int _bid;
        public int bid
        {
            get {  return _bid; }
            set { _bid = value; }
        }
    }
    class DanGrading
    {
        int _id;
        public int id {
            get { return _id; }
            set { _id = value; }
        }

        int _stars;
        public int stars {
            get { return _stars; }
            set { _stars = value; }
        }
        int _letUpPoints;
        public int letUpPoints {
            get { return _letUpPoints; }
            set { _letUpPoints = value; }
        }
        int _protectPoint;
        public int protectPoint {
            get { return _protectPoint; }
            set { _protectPoint = value; }
        }
        string  _danName;
        public string danName {
            get { return _danName; }
            set { _danName = value; }
        }

    }
    class RankInfo
    {
        int _cid;
        public int cid{
            set { _cid = value; }
            get { return _cid; }
        }
        string _cname;
        public string cname {
            get { return _cname; }
            set { _cname = value; }
        }
        string _mdmc;
        public string mdmc
        {
            get { return _mdmc; }
            set { _mdmc = value; }
        }
        string _danname;
        public string danname
        {
            get { return _danname; }
            set { _danname = value; }
        }
        string _icon;
        public string icon
        {
            get { return _icon; }
            set { _icon = value; }
        }
        string _avatar;
        public string avatar
        {
            get
            {
                if (string.IsNullOrEmpty(_avatar))
                {
                    return "http://tm.lilanz.com/QYWX/res/img/vipweixin/lilanzlogo.jpg";
                }
                else if (_avatar.IndexOf("http://") < 0)
                {
                    return "http://tm.lilanz.com/oa/" + _avatar;
                }
                else
                    return _avatar;
            }
            set { _avatar = value; }
        }
        int _gameTimes;
        public int gameTimes
        {
            get { return _gameTimes; }
            set { _gameTimes = value; }
        }
        int _winTimes;
        public int winTimes
        {
            get { return _winTimes; }
            set { _winTimes = value; }
        }
        string _status;
        public string status
        {
            get { return _status == null ? "":_status; }
            set { _status = value; }
        }
        int _stars;
        public int stars
        {
            get { return _stars; }
            set { _stars = value; }
        }
    }
    /// <summary>
    /// 结算积分
    /// </summary>
    class SettlementUser
    {
        string _fightingparty;
        public string fightingparty {
            get { return _fightingparty; }
            set { _fightingparty = value; }
        }
        int _cid;
        public int cid{
            set { _cid = value; }
            get { return _cid; }
        }
        int _ryid;
        public int ryid
        {
            get { return _ryid; }
            set { _ryid = value; }
        }
        int _points;
        public int points
        {
            get { return _points; }
            set { _points = value; }
        }
        int _dan;
        public int dan
        {
            get { return _dan; }
            set { _dan = value; }
        }

        int _stars;
        public int stars
        {
            get { return _stars; }
            set { _stars = value; }
        }
        decimal _amount;
        public decimal amount
        {
            get { return _amount; }
            set { _amount = value; }
        }
        int _detailid;
        public int detailid
        {
            get { return _detailid; }
            set { _detailid = value; }
        }
        int _result;
        public int result
        {
            get { return _result; }
        }
        public void setBettleInfo(decimal bje,decimal rje ,Dictionary<int, DanGrading> dicdan)
        {
            string winParty;
            int addPoints =0;
            if (bje > rje) winParty = "b";
            else winParty = "r";
            if(_fightingparty =="b") addPoints = Convert.ToInt32(SupremeGloryOperate.gamePoints*_amount/bje);
            else addPoints = Convert.ToInt32(SupremeGloryOperate.gamePoints*_amount / rje);

            if (this._fightingparty == winParty)//胜方加星
            {
                _stars++;
                _result = 1;
            }
            else//败方减星
            {
                _stars--;
                _result = -1;
            }


            if (_stars < 0 && dicdan[this._dan].protectPoint <= this._points)
            {
                _stars = 0;
                this._points = 0;
            }
            else
            {
                this._points = this._points + addPoints;//增加积分
            }

            //计算连胜和虽败犹荣

            if(this._points >= dicdan[this._dan].letUpPoints )//大于当前段的积分则加一星
            {
                _stars +=  this._points / dicdan[this._dan].letUpPoints;
                this._points = this._points % dicdan[this._dan].letUpPoints; // dicdan[this._dan].letUpPoints;
            }


            if (_stars > dicdan[this._dan].stars)//大于当前段的星数则升段减星
            {
                _stars -= dicdan[this._dan].stars;
                _dan++;
            }
            else if(_stars <0)//减段加星
            {
                _dan--;
                _stars += dicdan[this._dan].stars;
            }
        }
    }

    /// <summary>
    /// 执行排位并推送信息
    /// </summary>
    public class clsRunSignUpOrder:IDisposable
    {
        #region 开始排位

        private static object RunLockObj = new object();    //在运行时，用静态变量锁定实例，以免排位数据冲突
        public DataTable dtSignUp = null;
        public DataTable dtRedGroup = null;
        public DataTable dtBlueGroup = null;
        private DataTable dtWho = null;
        private int SumRedQZ = 0;
        private int SumBlueQZ = 0;
        private List<string> CIDList = new List<string>();
        private const int GROUPMENMAX = 5;
        //微信开发数据库连接目标，在正式环境下务必改成参数获取方式
        private string WXConnStr = "server='192.168.35.23';database=weChatTest;uid=lllogin;pwd=rw1894tla";

        public clsRunSignUpOrder()
        {

        }
        /// <summary>
        /// 指定执行的微信开发库连接字符串
        /// </summary>
        /// <param name="_WXConnStr"></param>
        public clsRunSignUpOrder(string _WXConnStr)
        {
            WXConnStr = _WXConnStr;
        }

        /// <summary>
        /// 首先为 Red添加一个最大排位权值的 报名组
        /// 然后循环比对 两组的权值，给权值低的且数量小于5个的，增加一个分组(限定被增加的分组的人数不能超过可添加的数量)。
        /// 如果两组的人数均为5人，则排位结束，保存数据并输出结果。如果无法分配分组，则排位失败，等待下一个提交排位申请的数据。  
        /// </summary>
        private bool CalOrderFight()
        {
            //初始化数据
            CIDList.Clear();
            dtRedGroup.Rows.Clear(); dtBlueGroup.Rows.Clear();
            SumRedQZ = 0; SumBlueQZ = 0;

            DataRow[] drList1 = dtSignUp.Select("队长 = true", "numbers DESC,队伍权值 DESC");
            if (drList1.Length > 0)
            {
                AddOrderFight(ref dtRedGroup, Convert.ToString(drList1[0]["pid"]), ref SumRedQZ);
            }
            int redAllowMenCount = GetAllowMen(ref dtRedGroup);
            int blueAllowMenCount = GetAllowMen(ref dtBlueGroup);

            while (redAllowMenCount > 0 || blueAllowMenCount > 0)
            {
                drList1 = null;
                dtWho = null;
                if (redAllowMenCount > 0 && SumRedQZ <= SumBlueQZ)   //理想状况下：为红队增加一个人数在redAllowMenCount内且队伍权值最大的报名组
                {
                    drList1 = dtSignUp.Select(string.Concat("numbers <= ", redAllowMenCount
                            , " AND CID NOT IN (", string.Join(",", CIDList.ToArray()), ")"), "队伍权值 DESC");
                    dtWho = dtRedGroup;
                }
                else if (blueAllowMenCount > 0 && SumRedQZ >= SumBlueQZ)   //理想状况下：为蓝队增加一个人数在blueAllowMenCount内且队伍权值最大的报名组
                {
                    drList1 = dtSignUp.Select(string.Concat("numbers <= ", blueAllowMenCount
                            , " AND CID NOT IN (", string.Join(",", CIDList.ToArray()), ")"), "队伍权值 DESC");
                    dtWho = dtBlueGroup;
                }
                else if (redAllowMenCount > 0 && SumRedQZ >= SumBlueQZ)   //非理想状况下：为红队增加一个人数在redAllowMenCount内且队伍权值最小的报名组
                {
                    drList1 = dtSignUp.Select(string.Concat("numbers <= ", redAllowMenCount
                            , " AND CID NOT IN (", string.Join(",", CIDList.ToArray()), ")"), "队伍权值 ASC");
                    dtWho = dtRedGroup;
                }
                else if (blueAllowMenCount > 0 && SumRedQZ <= SumBlueQZ)   //非理想状况下：为蓝队增加一个人数在blueAllowMenCount内且队伍权值最小的报名组
                {
                    drList1 = dtSignUp.Select(string.Concat("numbers <= ", blueAllowMenCount
                            , " AND CID NOT IN (", string.Join(",", CIDList.ToArray()), ")"), "队伍权值 ASC");
                    dtWho = dtBlueGroup;
                }

                if (drList1 == null || drList1.Length == 0 || dtWho == null)
                {
                    //MessageBox.Show("暂时无法匹配！等待下个报名数据！");
                    return false;
                }

                if (dtWho.Equals(dtRedGroup))
                {
                    AddOrderFight(ref dtRedGroup, Convert.ToString(drList1[0]["pid"]), ref SumRedQZ);
                    redAllowMenCount = GetAllowMen(ref dtRedGroup);
                }
                else
                {
                    AddOrderFight(ref dtBlueGroup, Convert.ToString(drList1[0]["pid"]), ref SumBlueQZ);
                    blueAllowMenCount = GetAllowMen(ref dtBlueGroup);
                }
            }

            //记录排位结果到数据库

            return true;
        }
        /// <summary>
        /// 添加一个报名组到红蓝之一的队伍中
        /// </summary>
        /// <param name="dt"></param>
        /// <param name="AddgroupID"></param>
        /// <param name="SumQZ"></param>
        private void AddOrderFight(ref DataTable dt, string AddgroupID, ref int SumQZ)
        {
            DataRow[] drList = dtSignUp.Select(string.Concat("pid='", AddgroupID, "'"));
            foreach (DataRow dr in drList)
            {
                CIDList.Add(Convert.ToString(dr["cid"]));
                dt.ImportRow(dr);
            }
            SumQZ += Convert.ToInt32(dt.Compute("SUM(排位权值)", ""));
        }

        /// <summary>
        /// 获取红蓝队的当前允许加入人数
        /// </summary>
        /// <param name="dt"></param>
        /// <returns></returns>
        private int GetAllowMen(ref DataTable dt)
        {
            return GROUPMENMAX - dt.Rows.Count;
        }

        /// <summary>
        /// 输出排位结果。仅用于调试输出
        /// </summary>
        /// <returns></returns>
        public string printInfo()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("________至尊荣耀排位结果：如下_________\n");
            sb.Append(string.Concat(DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), "匹配结果：\n"));
            object objTemp = dtRedGroup.Compute("SUM(sales)", "");
            int jdyj1 = Convert.ToInt32(objTemp == DBNull.Value ? 0 : objTemp);
            objTemp = dtRedGroup.Compute("SUM(排位权值)", "");
            int pwqz1 = Convert.ToInt32(objTemp == DBNull.Value ? 0 : objTemp);
            sb.Append(string.Format("红队：  总阶段业绩为：{0}  队伍权值：{1} \n", jdyj1, pwqz1));
            objTemp = dtBlueGroup.Compute("SUM(sales)", "");
            int jdyj2 = Convert.ToInt32(objTemp == DBNull.Value ? 0 : objTemp);
            objTemp = dtBlueGroup.Compute("SUM(排位权值)", "");
            int pwqz2 = Convert.ToInt32(objTemp == DBNull.Value ? 0 : objTemp);
            sb.Append(string.Format("蓝队：  总阶段业绩为：{0}  队伍权值：{1} \n", jdyj2, pwqz2));
            sb.Append("_________至尊荣耀排位结果：结束__________\n");

            string info = sb.ToString();
            clsLocalLoger.WriteInfo(info);
            sb.Length = 0;

            return info;
        }


        #endregion

        #region 读写数据库的方法

        /// <summary>
        /// 获取等待匹配的数据
        /// </summary>
        private DataTable getdtSignUp()
        {
            string strInfo = "";
            DataTable dt = null;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
            {
                string strSQL = string.Format(@"SELECT TOP 100 B.pid,B.cid,B.ryid,B.sales,A.numbers,B.id signid FROM ry_t_SignUp A
                                    INNER JOIN ry_t_SignUpDetail B ON A.id = B.pid
                                    WHERE A.signstatus = 1 AND A.signdate > '{0}'
                                    ORDER BY A.id,B.id ", DateTime.Now.ToString("yyyy-MM-dd"));
                strInfo = dal.ExecuteQuery(strSQL, out dt);
                if (strInfo != "")
                {
                    clsLocalLoger.WriteError(string.Concat("读取报名数据失败！错误：", strInfo));
                    return null;
                }
            }
            dt.Columns.Add("排位权值", typeof(int), "");
            dt.Columns.Add("队伍权值", typeof(int), "");
            dt.Columns.Add("队长", typeof(bool), "");     //如果队长身份直接取自数据库，则不需要额外添加这个字段，下方的 “生成队长身份”循环逻辑也可以注释掉。

            dtRedGroup = dt.Clone();
            dtBlueGroup = dt.Clone();

            //生成队长身份
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                dt.Rows[i]["队长"] = true;
                i += Convert.ToInt32(dt.Rows[i]["numbers"]);
                i--;
            }

            //生成排位权值
            DataRow[] drList = dt.Select("", "sales ASC");
            for (int i = 0; i < drList.Length; i++)
            {
                drList[i]["排位权值"] = i + 1;
            }
            //生成队伍权值
            foreach (DataRow dr in dt.Rows)
            {
                dr["队伍权值"] = Convert.ToInt32(dt.Compute("SUM(排位权值)", string.Concat("pid=", dr["pid"])));
            }

            return dt;
        }

        /// <summary>
        /// 保存排位信息
        /// </summary>
        /// <returns></returns>
        private bool SaveOrderInfo()
        {
            string strInfo = "";
            object ObjID = null;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
            {
                //创建战斗主表
                string strSQL = string.Format(@"INSERT INTO ry_t_Battle(createtime,refreshtime,battlestatus)VALUES('{0}','{0}',0)
                                                SELECT @@IDENTITY ", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                strInfo = dal.ExecuteQueryFast(strSQL, out ObjID);
                if (strInfo != "")
                {
                    clsLocalLoger.WriteError(string.Concat("创建战斗主表数据失败！错误：", strInfo));
                    return false;
                }
                //创建战斗从表
                int pid = Convert.ToInt32(ObjID);
                StringBuilder sb = new StringBuilder();
                string addSQL = "INSERT INTO ry_t_BattleDetail(pid,cid,ryid,signid,fightingparty) VALUES ({0},{1},{2},{3},'{4}') ";
                List<string> signpid = new List<string>();
                foreach (DataRow dr in dtRedGroup.Rows)
                {
                    sb.AppendFormat(addSQL, pid, dr["cid"], dr["ryid"], dr["signid"], "r");
                    if (!signpid.Contains(Convert.ToString(dr["pid"]))) signpid.Add(Convert.ToString(dr["pid"]));
                }
                foreach (DataRow dr in dtBlueGroup.Rows)
                {
                    sb.AppendFormat(addSQL, pid, dr["cid"], dr["ryid"], dr["signid"], "b");
                    if (!signpid.Contains(Convert.ToString(dr["pid"]))) signpid.Add(Convert.ToString(dr["pid"]));
                }

                strInfo = dal.ExecuteNonQuery(sb.ToString());
                sb.Length = 0;
                if (strInfo != "")
                {
                    clsLocalLoger.WriteError(string.Concat("创建战斗明细表数据失败（pid:" ,pid, "）！错误：", strInfo));
                    return false;
                }
                //更新报名标识表
                strSQL = string.Format("UPDATE ry_t_SignUp SET signstatus = 2 WHERE ID IN ({0}) ",string.Join(",", signpid.ToArray()));
                strInfo = dal.ExecuteNonQuery(strSQL);
                if (strInfo != "")
                {
                    clsLocalLoger.WriteError(string.Concat("更新报名明细表失败（SQL:", strSQL, "）！错误：", strInfo));
                    return false;
                }
                return true;
            }
        }

        /// <summary>
        /// 获取推送提醒的name列表
        /// </summary>
        /// <returns></returns>
        private string getCustomerNames()
        {
            string strInfo = "";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
            {
                List<string> lisCid = new List<string>();
                foreach (DataRow dr in dtRedGroup.Rows)
                {
                    lisCid.Add(Convert.ToString(dr["cid"]));
                }
                foreach (DataRow dr in dtBlueGroup.Rows)
                {
                    lisCid.Add(Convert.ToString(dr["cid"]));
                }

                //创建战斗主表
                string strSQL = string.Format(@"SELECT TOP 10 name + '|'  FROM wx_t_customers WHERE ID IN ({0}) FOR XML Path('')", string.Join(",", lisCid.ToArray()));
                object ObjName = null;
                strInfo = dal.ExecuteQueryFast(strSQL, out ObjName);
                if (strInfo != "")
                {
                    clsLocalLoger.WriteError(string.Concat("获取推送提醒失败！错误：", strInfo));
                    return "";
                }
                string strNames = Convert.ToString(ObjName);
                if (string.IsNullOrEmpty(strNames)) return "";
                else return strNames.Remove(strNames.Length - 1, 1);
            }
        }
        #endregion

        #region 公开的方法
        /// <summary>
        /// 启动一个线程，计算
        /// </summary>
        public void Run()
        {
            Thread t = new Thread(TRun);
            t.Start();
        }

        private void TRun()
        {
            lock (RunLockObj)
            {
                dtSignUp = getdtSignUp();

                if (dtSignUp.Rows.Count < GROUPMENMAX * 2) return;  //人数不够
                else
                {
                    bool rtn = CalOrderFight();
                    rtn = SaveOrderInfo();

                    if (rtn) //推送企业号提醒
                    {
                        clsAsynTask.Submit("RyFightServer", 0, @"{ ""Commmand"":""ReLoadBattle"" }");
                        //获取红蓝队队员的企业号name
                        string cName = getCustomerNames();

                        string RyFightUrl = clsConfig.GetConfigValue("OA_WebPath");

                        string centen = string.Format(@" {{
                               ""articles"":[
                                   {{
                                       ""title"": ""至尊荣耀排位赛匹配成功！"",
                                       ""description"": ""欢迎来到至尊荣耀，您已成功匹配到对手了！祝您大获全胜！"",
                                       ""url"": ""{0}/project/ryfight/main.aspx"",
                                       ""picurl"": ""{0}res/img/RyFight/thumb.jpg""
                                   }} 
                               ]
                                }}", RyFightUrl);
                        cName = "liqf|xuelm|8DFFEECA-4237-47F1-BCBB-EA8E32D05F7D";
                        using (clsJsonHelper jh = clsWXHelper.SendQYMessageNews(cName, 0, centen))
                        {
                            clsLocalLoger.WriteInfo(string.Concat("排位通知推送结果：", jh.jSon));
                        }
                    }
                }
            }
        }

        public void Dispose()
        {
            clsSharedHelper.DisponseDataTable(ref dtSignUp);
            clsSharedHelper.DisponseDataTable(ref dtBlueGroup);
            clsSharedHelper.DisponseDataTable(ref dtRedGroup);
            clsSharedHelper.DisponseDataTable(ref dtWho);
        }
        #endregion
    }
    public class Response
    {
        string _code;
        public string code
        {
            get
            {
                if (string.IsNullOrEmpty(_code)) _code = "201";
                return _code;
            }
            set
            {
                _code = value;
            }
        }
        object _info;
        public object info
        {
            get { return _info == null ? "" : _info; }
            set { _info = value; }
        }
        string _msg;
        public string msg
        {
            get
            {
                if (string.IsNullOrEmpty(_msg)) _msg = "";
                return _msg;
            }
            set
            {
                _msg = value;
            }
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}