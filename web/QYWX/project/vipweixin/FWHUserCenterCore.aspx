<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<script runat="server">
    private string DBConStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn_1"].ConnectionString; 
    private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
    private string FXDB11 = clsConfig.GetConfigValue("FXConStr");
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "SignToday":
                string vipid = Convert.ToString(Request.Params["vipid"]);
                if (vipid == "" || vipid == null || vipid == "0")
                    clsSharedHelper.WriteErrorInfo("缺少参数vipid!");
                else
                    SignToday(vipid);
                break;
            case "LoadUserPoints":
                vipid = Convert.ToString(Request.Params["vipid"]);
                if (vipid == "" || vipid == null || vipid == "0")
                    clsSharedHelper.WriteErrorInfo("缺少参数vipid!");
                else
                    LoadUserPoints(vipid);
                break;
            case "LoadConsumeRecords":
                string vipkh = Convert.ToString(Request.Params["vipkh"]);
                if (vipkh == "" || vipkh == null)
                    clsSharedHelper.WriteErrorInfo("传入的参数有误!");
                else
                    LoadConsumeRecords(vipkh);
                break;
            case "LoadConsumeDetail":
                string djid = Convert.ToString(Request.Params["djid"]);
                if (djid == "" || djid == "0" || djid == null)
                    clsSharedHelper.WriteErrorInfo("传入的参数有误!");
                else
                    LoadConsumeDetail(djid);
                break;
            case "LoadNewPointRecords":
                vipid = Convert.ToString(Request.Params["vipid"]);
                if (vipid == "" || vipid == null)
                    clsSharedHelper.WriteErrorInfo("传入的参数有误!");
                else
                    LoadNewPointRecords(vipid);
                break;
            case "LoadNewPointRecords2":
                vipid = Convert.ToString(Request.Params["vipid"]);
                if (vipid == "" || vipid == null)
                    clsSharedHelper.WriteErrorInfo("传入的参数有误!");
                else
                    LoadNewPointRecords2(vipid);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无ctrl=" + ctrl + "对应操作！【注意大小写】");
                break;
        }
    }

    //查询用户的积分记录
    public void LoadNewPointRecords2(string vipid)
    {
        Session["userpoint"] = "";      //每次查询积分的时候，都将缓存的积分清空

        using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConStr))
        {
            List<SqlParameter> paras = new List<SqlParameter>();
            string str_sql0 = @"DECLARE @kh VARCHAR(30),
				                            @khid INT,
				                            @DBName VARCHAR(30),
				                            @vipbs VARCHAR(6)

                            SELECT @kh = '',@khid=0,@vipbs = ''

                            SELECT TOP 1 @kh = kh,@khid = khid FROM yx_t_vipkh WHERE ID = @vipid
                            IF (@khid > 0)	SELECT TOP 1 @DBName=DBName,@vipbs = vipbs FROM yx_t_khb WHERE khid = @khid

                            SELECT @kh kh,@DBName DBName,@vipbs vipbs";

            paras.Add(new SqlParameter("@vipid", vipid));
            DataTable dt = null;
            string errinfo = dal10.ExecuteQuerySecurity(str_sql0, paras, out dt);
            if (errinfo != "")
            {
                clsLocalLoger.WriteError(string.Format("获取VIP（ID:{0}）的基础信息2失败！错误：{1}", vipid, errinfo));
                clsSharedHelper.WriteErrorInfo("暂时无法查询积分记录!");
            }
            else
            {
                string kh = Convert.ToString(dt.Rows[0]["kh"]);
                string DBName = Convert.ToString(dt.Rows[0]["DBName"]).ToUpper();
                string vipbs = Convert.ToString(dt.Rows[0]["vipbs"]);

                dt.Clear(); dt.Dispose();

                string str_sql; 
                if (vipbs == "new")     //如果是新积分体系，则走新积分体系的查询（这个逻辑尚未测试到）
                {
                    LoadNewPointRecords(vipid);
                    return;
                }
                else
                {
                    if (DBName == "FXDB") DBName = clsConfig.GetConfigValue("FXConStr");
                    else DBName = DBName = clsConfig.GetConfigValue("ERPConStr");

                    str_sql = @"
                                DECLARE @DateFind DATETIME;
                                --只允许查询近12个月的积分记录
                                SELECT  @DateFind = CONVERT(VARCHAR(10), DATEADD(MONTH, -12, GETDATE()), 120);

                                SELECT  YEAR(rq) nf ,
                                        MONTH(rq) yf ,
                                        jfs changeval,
                                        CONVERT(VARCHAR(10),rq,120) eventtime,
                                        jfType + bz pname
                                FROM    ( SELECT    a.rq ,
                                                    ( CASE b.kc
                                                        WHEN 1 THEN '退货'
                                                        ELSE '购买商品'
                                                        END ) jfType ,
                                                    -( CASE WHEN ISNULL(a.jfbs, 0) = 0
                                                            THEN CASE WHEN ISNULL(a.xfjf, 0) = 0
                                                                        THEN a.yskje * b.kc
                                                                        ELSE a.xfjf * b.kc
                                                                    END
                                                            ELSE 0
                                                        END ) jfs ,
                                                    '' bz
                                            FROM      Zmd_T_lsdjb a
                                                    INNER JOIN T_Djlb b ON a.djlb = b.dm
                                                    INNER JOIN yx_t_khb c ON a.khid = c.khid
                                                                                AND a.rq >= c.jfqyrq
                                            WHERE     a.vip = @kh
                                                    AND a.djbs = 1
                                                    AND a.djlb < 10
                                                    AND a.rq >= @DateFind
                                            UNION ALL
                                            SELECT    b.rq ,
                                                    ( CASE WHEN b.jflx = 1 THEN '兑换'
                                                            ELSE '赠送'
                                                        END ) jfType ,
                                                    (b.dhjfs) jfs ,
                                                    ' ' + b.bz
                                            FROM      YX_T_Vipkh a
                                                    INNER JOIN zmd_t_xfjfdhb b ON a.kh = b.kh
                                            WHERE     1 = 1
                                                    AND a.kh = @kh
                                                    AND b.rq >= @DateFind
                                        ) AS T
                                ORDER BY rq DESC
                                    ";
                    paras.Clear();
                    paras.Add(new SqlParameter("@kh", kh));
                    paras.Add(new SqlParameter("@vipid", vipid));
                }

                using (LiLanzDALForXLM dalDB = new LiLanzDALForXLM(DBName))
                {
                    errinfo = dalDB.ExecuteQuerySecurity(str_sql, paras, out dt);
                    if (errinfo == "")
                    {
                        if (dt.Rows.Count > 0)
                        {
                            dt.Columns.Add("ip", typeof(string), "").DefaultValue = "0";
                            dt.Columns.Add("op", typeof(string), "").DefaultValue = "0";

                            string ny = "";
                            string strinpoints = "";
                            string stroutpoints = ""; 
                            
                            foreach (DataRow dr in dt.Rows)
                            {
                                if (ny != string.Concat(dr["nf"], dr["yf"]))
                                {
                                    ny = string.Concat(dr["nf"], dr["yf"]);
                                    
                                    strinpoints = Convert.ToString(dt.Compute("SUM(changeval)", string.Concat(" nf = " ,dr["nf"] , " AND yf = " ,dr["yf"], " AND changeval > 0")));
                                    stroutpoints = Convert.ToString(dt.Compute("SUM(changeval)", string.Concat(" nf = ", dr["nf"], " AND yf = ", dr["yf"], " AND changeval < 0")));                                    
                                }

                                dr["ip"] = strinpoints;
                                dr["op"] = stroutpoints;                                
                            }
                                                         
                            clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                        }
                        else
                            clsSharedHelper.WriteInfo("");

                        dt.Clear(); dt.Dispose();
                    }
                    else
                    {
                        clsLocalLoger.WriteError(string.Format("获取VIP（ID:{0}）的历史积分记录失败！错误：{1}", vipid, errinfo));
                        clsSharedHelper.WriteErrorInfo("暂时无法查询积分记录!");
                    }
                }
            }
        }
    }
    
    
    //查询用户新积分体系下的积分记录
    public void LoadNewPointRecords(string vipid)
    {
        using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConStr))
        {
            string str_sql = @"
                                declare @vipkh varchar(50);
                                select top 1 @vipkh=ltrim(rtrim(kh)) from yx_t_vipkh where id=@vipid;

                                select a.*,case when a.flag=1 then a.changeval else 0 end inpoints,
                                case when a.flag=-1 then a.changeval else 0 end outpoints into #tmp
                                from (
                                    select year(a.rq) nf,month(a.rq) yf,
                                    case when a.bz='' or a.bz is null then isnull(lx.mc,'') else a.bz end pname,
                                    a.rq eventtime,a.dhjfs changeval,isnull(a.fh,1) flag
                                    from zmd_t_xfjfdhb a
                                    left join yx_v_vipjflxb lx on a.jflx=lx.id
                                    where a.xtlx=0 and a.djbs=1 and a.kh=@vipkh
                                ) a

                                select a.*,isnull(b.ip,0) ip,isnull(b.op,0) op 
                                from #tmp a
                                left join (select yf,sum(inpoints) ip,sum(outpoints) op,nf from #tmp group by nf,yf) b on a.yf=b.yf AND a.nf=b.nf
                                order by a.eventtime desc;
                                drop table #tmp;";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipid", vipid));
            string errinfo = dal10.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));                    
                else
                    clsSharedHelper.WriteInfo("");

                dt.Clear(); dt.Dispose();
            }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }
    }

    //加载消费单据详情
    public void LoadConsumeDetail(string djid)
    {
        using (LiLanzDALForXLM dal11 = new LiLanzDALForXLM(FXDB11))
        {
            string str_sql = @"select isnull(sp.spmc,a.sphh) spmc,cm.cm cmmc,a.sphh,a.sl,a.dj
                                from zmd_t_lsdjmx a 
                                left join yx_t_spdmb sp on a.sphh=sp.sphh
                                left join yx_t_cmzh cm on cm.tml=sp.tml and a.cmdm=cm.cmdm
                                where a.id=@djid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@djid", djid));
            DataTable dt = null;
            string errinfo = dal11.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    //clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                    //到正式库查询对应的衣服图片
                    DataColumn dc = new DataColumn();
                    dc.DataType = Type.GetType("System.String");
                    dc.ColumnName = "urladdress";
                    dc.AllowDBNull = false;
                    dc.DefaultValue = "";
                    dt.Columns.Add(dc);//衣服图片                    
                    string sphhs = "";
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        sphhs += "'" + Convert.ToString(dt.Rows[i]["sphh"]) + "',";
                    }
                    sphhs = sphhs.Substring(0, sphhs.Length - 1);
                    using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConStr))
                    {
                        str_sql = @"select a.sphh,min(t1.urladdress) urladdress
                                    from yx_v_ypdmb a
                                    left join yf_t_cpkfsjtg cy on (a.zlmxid>0 and a.zlmxid=cy.zlmxid and cy.tplx='cyzp' ) 
                                    or (a.zlmxid=0 and cy.tplx='cgyptp' and a.yphh=cy.yphh)
                                    left join t_uploadfile t1 on case when isnull(a.zlmxid,0)=0 then 1002 else 1003 end=t1.groupid
                                    and case when isnull(a.zlmxid,0)=0 then isnull(cy.id,0) else isnull(a.zlmxid,0) end=t1.tableid
                                    where a.tzid=1 and a.sphh in (" + sphhs + ") group by a.sphh";
                        DataTable picdt = null;
                        errinfo = dal10.ExecuteQuery(str_sql, out picdt);
                        if (errinfo == "" && picdt.Rows.Count > 0)
                        {
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                string sphh = dt.Rows[i]["sphh"].ToString();
                                DataRow[] drs = picdt.Select("sphh='" + sphh + "'");
                                if (drs.Length > 0)
                                    dt.Rows[i]["urladdress"] = Convert.ToString(drs[0]["urladdress"]);
                            }//end for
                            clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                        }
                        else if (errinfo != "")
                            clsSharedHelper.WriteErrorInfo("查询衣服图片时出错 " + errinfo);
                        else
                            clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));

                        picdt.Dispose();
                    }
                }
                else
                    clsSharedHelper.WriteInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("查询用户消费详情时出错 " + errinfo);

            dt.Dispose();
        }
    }

    //20160414 liqf 利郎男装公众号顾客查询消费记录
    public void LoadConsumeRecords(string vipkh)
    {
        using (LiLanzDALForXLM dal11 = new LiLanzDALForXLM(FXDB11))
        {
            string str_sql = @"select a.id,convert(varchar(10),a.rq,120) rq,(CASE WHEN a.djlb > 0 THEN CONVERT(VARCHAR(10),sskje) ELSE 	
									CONVERT(VARCHAR(10),0-sskje) + '(退货）' END) 'sskje',md.mdmc,convert(varchar(8),a.rq,112)+a.djh ordernum
                                from zmd_t_lsdjb a
                                left join t_mdb md on md.mdid=a.mdid
                                where a.djbs=1 and a.vip=@vipkh
                                order by a.rq desc";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipkh", vipkh));
            DataTable dt = null;
            string errinfo = dal11.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                else
                    clsSharedHelper.WriteInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("查询用户消费记录时出错 " + errinfo);
        }
    }

    //加载用户积分
    public void LoadUserPoints(string vipid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = @"select a.*,case when a.flag=1 then a.changeval else 0 end inpoints,
                                case when a.flag=-1 then a.changeval else 0 end outpoints into #tmp
                                from (
                                select year(a.eventtime) nf,month(a.eventtime) yf,
                                t.name pname,a.eventtime,a.changevalue*a.changeflag changeval,a.changeflag flag                                
                                from wx_t_VIPPointRecords a
                                inner join wx_t_vippointtype t on t.id=a.pointtype
                                where a.vipid=@vipid 
                                ) a

                                select a.*,isnull(b.ip,0) ip,isnull(b.op,0) op 
                                from #tmp a
                                left join (select yf,sum(inpoints) ip,sum(outpoints) op from #tmp group by yf) b on a.yf=b.yf
                                order by a.eventtime desc;
                                drop table #tmp;";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipid", vipid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    clsSharedHelper.WriteSuccessedInfo(JsonHelp.dataset2json(dt));
                }
                else
                    clsSharedHelper.WriteSuccessedInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("查询用户记录时出错 " + errinfo);
        }
    }

    //签到
    public void SignToday(string vipid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = @"if exists (select top 1 1 from wx_t_VIPPointRecords a where a.pointtype=1 and convert(varchar(10),a.eventtime,120)=convert(varchar(10),getdate(),120) and a.vipid=@vipid)
                                    select '00';
                                    else
                                     begin
                                       if not exists (select top 1 1 from wx_t_vipinfo where vipid=@vipid)
                                         begin
                                           insert wx_t_vipinfo(vipid,vipcardno,consumepoints,activitypoints,userpoints,charmvalue,viptitle,mdid)
                                           select a.id,a.kh,0,b.points*b.flag,b.points*b.flag,b.points*b.flag,0,isnull(a.mdid,0)
                                           from yx_t_vipkh a
                                           left join wx_t_vippointtype b on b.id=1 and b.isactive=1
                                           where a.id=@vipid;
                                           insert wx_t_VIPPointRecords(vipid,vipcardno,changevalue,changeflag,leftpoints,remarks,eventtime,operator,pointtype) 
                                           select a.vipid,a.vipcardno,b.points,b.flag,a.userpoints+b.flag*b.points,b.name,getdate(),'',isnull(b.id,0)
                                           from wx_t_vipinfo a
                                           left join wx_t_vippointtype b on b.id=1 and b.isactive=1
                                           where a.vipid=@vipid;
                                           select '11';
                                         end
                                       else
                                         begin
                                           insert wx_t_VIPPointRecords(vipid,vipcardno,changevalue,changeflag,leftpoints,remarks,eventtime,operator,pointtype) 
                                           select a.vipid,a.vipcardno,b.points,b.flag,a.userpoints+b.flag*b.points,b.name,getdate(),'',isnull(b.id,0)
                                           from wx_t_vipinfo a
                                           left join wx_t_vippointtype b on b.id=1 and b.isactive=1
                                           where a.vipid=@vipid;
                                           update a set a.activitypoints=a.activitypoints+isnull(b.val,0),a.userpoints=a.userpoints+isnull(b.val,0),
                                           a.charmvalue=a.charmvalue+isnull(b.val,0)
                                           from wx_t_vipinfo a
                                           left join (select points*flag val from wx_t_vippointtype where id=1 and isactive=1) b on 1=1
                                           where a.vipid=@vipid;
                                           select '11';
                                         end
                                     end";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipid", vipid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                string dm = dt.Rows[0][0].ToString();
                if (dm == "00")
                    clsSharedHelper.WriteInfo("Warn:今日已签到过啦,明天再来吧!");
                else if (dm == "01")
                    clsSharedHelper.WriteErrorInfo("Can't find your static data!");
                else if (dm == "11")
                    clsSharedHelper.WriteSuccessedInfo("");
                else
                    clsSharedHelper.WriteErrorInfo("未知错误!");
            }
            else
                clsSharedHelper.WriteInfo("每日签到处理错误 " + errinfo);
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
            Response.End();
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
