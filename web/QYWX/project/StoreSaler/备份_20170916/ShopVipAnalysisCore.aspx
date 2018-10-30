<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<!DOCTYPE html>
<script runat="server">  

    string OAConnStr =clsConfig.GetConfigValue("OAConnStr");
    string CXDBConnStr =clsConfig.GetConfigValue("FXDBConStr");
    protected void Page_Load(object sender,EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string way = Convert.ToString(Request.Params["way"]);
        string ny = null;
        if (mdid == "" || mdid == null)
        {
            clsSharedHelper.WriteErrorInfo("缺少门店参数！");
            return;
        }

        if (way == "thisMonth")
        {
            ny = DateTime.Now.ToString("yyyyMM");

        }else if (way=="beforeMonth")
        {
            ny = DateTime.Now.AddMonths(-1).ToString("yyyyMM");
        }

        if (ny == "" || ny == null)
        {
            clsSharedHelper.WriteErrorInfo("缺少月份参数！");
            return;
        }
        switch (ctrl)
        {
            case "VipMain":
                getVipMainData(mdid,ny);
                break;
            case "VipAccounting":
                getVipAccountingData(mdid, ny);
                break;
            case "VipFrequency":
                getVipFrequencyData(mdid,ny);
                break;
            case "VipActivity":
                getVipActivityData(mdid);
                break;
            case "VipCardRatio":
                getProportion(mdid, ny);
                break;
            case "VipSaleRatio":
                getVipCategorySale(mdid, ny);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                break;
        };
    }

    public void getVipMainData(string mdid, string ny)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBConnStr))
        {
            DataTable dt = null;
            int vipCount = 0, thisNum = 0, otherNum = 0;
            //vip 总数为本店vip客户, 其他为包含本店的共用vip客户
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mdid", mdid));
            string mysql = "select COUNT(id) vipCount from yx_t_vipkh where  mdid=@mdid; ";
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            if(dt.Rows.Count>0)  vipCount =Convert.ToInt32( dt.Rows[0]["vipCount"]);
            clsSharedHelper.DisponseDataTable(ref dt);

            mysql = @"select COUNT(DISTINCT vip) xfvip
                        from zmd_v_lsdjmx 
                        where djbs=1 and isnull(vip,'')<>''  and mdid=@mdid  
                        and rq>=@ny+'01' and rq<DATEADD(month,1,@ny+'01') ";
            paras.Clear();
            paras.Add(new SqlParameter("@mdid", mdid));
            paras.Add(new SqlParameter("@ny", ny));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            if (dt.Rows.Count > 0) thisNum = Convert.ToInt32(dt.Rows[0]["xfvip"]);
            clsSharedHelper.DisponseDataTable(ref dt);

            mysql = @"select COUNT(DISTINCT vip) halfvip
                        from zmd_v_lsdjmx 
                        where djbs=1 and isnull(vip,'')<>'' and mdid=@mdid and rq>DATEADD(MONTH,-6,GETDATE())";
            paras.Clear();
            paras.Add(new SqlParameter("@mdid", mdid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            if (dt.Rows.Count > 0) otherNum =vipCount- Convert.ToInt32(dt.Rows[0]["halfvip"]);
            clsSharedHelper.DisponseDataTable(ref dt);
            string rt = string.Format(@"{{""rows"":[{{""vipCount"":""{0}"",""thisNum"":""{1}"",""otherNum"":""{2}""}}]}}",vipCount,thisNum,otherNum);
            clsSharedHelper.WriteInfo(rt);
        }
    }


    public void getVipAccountingData(string mdid,string ny){
        using (LiLanzDALForXLM ADal = new LiLanzDALForXLM(CXDBConnStr))
        {
            DataTable dt = null;

            string strsql = @"  select CAST(SUM(CASE WHEN ISNULL(vip,'')<>'' THEN a.je*ABS(djlb)/a.djlb ELSE 0 END) AS DECIMAL(11,2)) AS vipje,
                               CAST(SUM(a.je*ABS(djlb)/a.djlb) AS DECIMAL(11,2))AS otherje
                                from zmd_v_lsdjmx a    
                                where a.djbs=1 and a.mdid=@mdid and a.rq>=@ny+'01' and a.rq<DATEADD(month,1,@ny+'01') ;";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@mdid", mdid));
            param.Add(new SqlParameter("@ny", ny));
            string errinfo = ADal.ExecuteQuerySecurity(strsql,param,out dt);
            if(errinfo !="")   clsSharedHelper.WriteErrorInfo("统计数据时出错 info:"+errinfo);
            if(dt.Rows.Count <1) clsSharedHelper.WriteErrorInfo("计算图表数据时查询不到数据！");
            dt.Rows[0]["otherje"] = Convert.ToDecimal(dt.Rows[0]["otherje"]) - Convert.ToDecimal(dt.Rows[0]["vipje"]);
            string rt = JsonHelp.dataset2json(dt);
            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.WriteInfo(rt);
        }
    }

    public void getVipFrequencyData(string mdid,string ny)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            DataTable dt = null;
            string mysql = "select khid from t_mdb where mdid=@mdid";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@mdid", mdid));
            string errinfo = dal.ExecuteQuerySecurity(mysql, param, out dt);
            if(errinfo !="") clsSharedHelper.WriteErrorInfo("验证客户出错:" + errinfo);
            if(dt.Rows.Count <1 )clsSharedHelper.WriteErrorInfo("客户不存在");
            int khid = Convert.ToInt32(dt.Rows[0]["khid"]);
            LiLanzDALForXLM dalT = new LiLanzDALForXLM(khid);
            dal.ConnectionString =dalT.ConnectionString;
            dalT.Dispose();

            mysql = @"select SUM(ls.sl) AS lssl,ls.id
                            from zmd_v_lsdjmx ls
                            where ls.djbs=1  AND  ls.mdid=@mdid AND ls.rq>=@ny+'01' AND ls.rq<DATEADD(MONTH,1,@ny+'01') AND ls.djlb>0
                            GROUP BY ls.id
                            HAVING SUM(ls.sl)>0 ";
            param.Clear();
            param.Add(new SqlParameter("@mdid", mdid));
            param.Add(new SqlParameter("@ny", ny));
            errinfo = dal.ExecuteQuerySecurity(mysql, param, out dt);

            if(errinfo !="" )  clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errinfo);
            if (dt.Rows.Count < 1) clsSharedHelper.WriteErrorInfo("计算图表数据时查询不到数据！");
            dt.PrimaryKey = new DataColumn[] { dt.Columns["id"] };
            //  clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));

            mysql = @"select SUM(th.sl) AS thsl,b.lydjid AS id
                    from zmd_v_lsdjmx th INNER JOIN dbo.Zmd_T_Lsdjglb b ON th.id=b.id AND b.lydjid>0
                    where th.djbs=1  AND  th.mdid=@mdid and th.rq>=@ny+'01' AND th.rq<DATEADD(MONTH,1,@ny+'01') AND th.djlb<0
                    GROUP BY b.lydjid
                    HAVING SUM(th.sl)<0";
            DataTable dt_th;
            param.Clear();
            param.Add(new SqlParameter("@mdid", mdid));
            param.Add(new SqlParameter("@ny", ny));
            errinfo = dal.ExecuteQuerySecurity(mysql, param, out dt_th);
            if (errinfo != "") clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errinfo);
            DataRow []dr_ls;
            foreach (DataRow dr in dt_th.Rows)
            {
                dr_ls = dt.Select("id=" + dr["id"]);
                if (dr_ls.Length > 0) dr_ls[0]["lssl"] = Convert.ToInt32(dr_ls[0]["lssl"]) - Convert.ToInt32(dr["thsl"]);
            }
            int js;
            DataTable dtCount = new DataTable();
            dtCount.Columns.Add("js", typeof(string));
            dtCount.Columns.Add("sl", typeof(int));
            dtCount.Columns.Add("num", typeof(int));
            DataRow mydr;
            for (int i = 0; i < 4; i++)
            {
                mydr = dtCount.NewRow();
                mydr["js"] = (i+1).ToString()+ "件";
                if(i==3) mydr["js"] ="4件及以上";
                mydr["sl"] = i;
                mydr["num"] =0;
                dtCount.Rows.Add(mydr);
            }

            foreach (DataRow dr in dt.Rows)
            {
                js = Convert.ToInt32(dr["lssl"]);
                if (js <= 0) continue;
                if (js >= 4)
                {
                    js = 4;
                }
                dtCount.Rows[js - 1]["num"] =Convert.ToInt32(dtCount.Rows[js - 1]["num"] )+ 1;
            }
            string rt = JsonConvert.SerializeObject(dtCount);
            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.DisponseDataTable(ref dt_th);
            clsSharedHelper.DisponseDataTable(ref dtCount);
            clsSharedHelper.WriteInfo(string.Format(@"{{""rows"":{0}}}",rt ));
        }
    }

    public void getVipActivityData(string mdid)
    {
        string  mysql, errInfo;
        DataTable dt = new DataTable();
        DataRow dr;
        dt.Columns.Add("month", typeof(string));
        dt.Columns.Add("addvip", typeof(int));
        dt.Columns.Add("lostvip",typeof(int));
        for (int i= 5;i> -1; i--){
            dr = dt.NewRow();
            dr["month"] = DateTime.Now.AddMonths(-i).ToString("yyyyMM");
            dr["addvip"] = 0;
            dr["lostvip"] = 0;
            dt.Rows.Add(dr);
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBConnStr))
        {
            DataTable dt_temp;
            mysql = @"DECLARE @ksny VARCHAR(12);
                    SET @ksny=LEFT( CONVERT(VARCHAR(10),DATEADD(MONTH,-5,GETDATE()) ,23),8)+'01'
                    SELECT COUNT(1) addvip,convert(varchar(6),jdrq,112) month FROM dbo.YX_T_Vipkh 
                    WHERE mdid=@mdid AND jdrq>@ksny 
                    GROUP BY convert(varchar(6),jdrq,112)
                    ORDER BY convert(varchar(6),jdrq,112)";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mdid",mdid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt_temp);
            if(errInfo !="")  clsSharedHelper.WriteErrorInfo("查询新增vip出错："+errInfo);
            int i = 0;

            foreach (DataRow mydr in dt_temp.Rows)
            {
                while (i< dt.Rows.Count && mydr["month"].ToString() != dt.Rows[i]["month"].ToString())
                {
                    i++;
                }
                if (i >= dt.Rows.Count) break;
                dt.Rows[i]["addvip"] = mydr["addvip"];
                i++;
            }
            clsSharedHelper.DisponseDataTable(ref dt_temp);

            mysql = @"DECLARE @ksny VARCHAR(12);
                    SET @ksny=LEFT( CONVERT(VARCHAR(10),DATEADD(MONTH,-5,GETDATE()) ,23),8)+'01'
                    SELECT COUNT(DISTINCT vip) lostvip,convert(varchar(6),DATEADD(MONTH,3,rq),112) lostmonth
                    FROM dbo.zmd_v_lsdjmx
                    WHERE rq>=DATEADD(MONTH,-3,@ksny) AND mdid=@mdid AND vip<>'' AND rq<DATEADD(MONTH,-3,GETDATE())
                    GROUP BY convert(varchar(6),DATEADD(MONTH,3,rq),112)
                    ORDER BY  convert(varchar(6),DATEADD(MONTH,3,rq),112)";
            paras.Clear();
            paras.Add(new SqlParameter("@mdid",mdid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt_temp);
            if(errInfo !="")  clsSharedHelper.WriteErrorInfo("查询失去vip时出错："+errInfo);
            i = 0;
            foreach (DataRow mydr in dt_temp.Rows)
            {
                // clsSharedHelper.WriteInfo(dt.Rows[i]["month"].ToString());
                while (i< dt.Rows.Count && mydr["lostmonth"].ToString() != dt.Rows[i]["month"].ToString())
                {
                    i++;
                }
                if (i >= dt.Rows.Count) break;
                dt.Rows[i]["lostvip"] = mydr["lostvip"];
                i++;
            }
            clsSharedHelper.DisponseDataTable(ref dt_temp);

        }
        clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));

        /*   using (LiLanzDALForXLM ADal = new LiLanzDALForXLM(FXDBConnStr))
           {
               DataTable dt = null;
               string strsql = @" declare @kjny table(dm varchar(6));
                                  declare @ks varchar(6);
                                  declare @js varchar(6);
                                  declare @times int;
                                  set @times=-6;
                                  set @js=@ny;
                                  set @ks=convert(varchar(6),dateadd(month,@times+1,cast(@js+'01' as datetime)),112);

                                  select convert(varchar(6),vip.jdrq,112) as ny,COUNT(distinct vip.kh) as activNum ,row_number()over(order by convert(varchar(6),vip.jdrq,112)) as xh into #temp
                                  from YX_T_Vipkh vip
                                  where  isnull(vip.kh,'')<>'' and vip.mdid=@mdid
                                  and vip.jdrq<=dateadd(month,1,@js+'01') and vip.jdrq>=@ks+'01'
                                  group by convert(varchar(6),vip.jdrq,112);

                                  while @ks<=@js
                                     begin
                                        insert into @kjny(dm)
                                        select @ks;
                                        set @ks=convert(char(6),dateadd(m,1,@ks+'01'),112);
                                     end

                                  select right(a.dm,2) as ny,isnull(b.activNum,0) activNum,isnull((select  sum(c.activNum) from #temp c where c.xh<=b.xh),0) as sumNum
                                  from @kjny a                          
                                  left join  #temp b on a.dm=b.ny;
                                  drop table #temp;";
               List<SqlParameter> param = new List<SqlParameter>();
               param.Add(new SqlParameter("@mdid", mdid));
               param.Add(new SqlParameter("@ny", ny));
               string errinfo = ADal.ExecuteQuerySecurity(strsql, param, out dt);
               if (errinfo == "" && errinfo.Length == 0)
               {
                   if (dt.Rows.Count > 0)
                   {
                       clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                   }
                   else
                   {
                       clsSharedHelper.WriteErrorInfo("计算图表数据时查询不到数据！");
                   }
               }
               else
               {
                   clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errinfo);
               }
               dt.Rows.Clear(); dt.Dispose();  //释放资源
           }*/
    }

    public void getProportion(string mdid,string ny)
    {
        string errInfo, mysql, rt = @"{{""code"":""{0}"",""vip"":{1},""msg"":""{2}""}}";
        using (LiLanzDALForXLM dal=new LiLanzDALForXLM(CXDBConnStr))
        {
            //mysql = "select khid from t_mdb where mdid=@mdid";
            List<SqlParameter> paras = new List<SqlParameter>();
            //paras.Add(new SqlParameter("@mdid", mdid));
            DataTable dt = null;
            //errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            //if (errInfo != "") clsSharedHelper.WriteInfo(string.Format(rt,"201","\"\"",errInfo));
            //if (dt.Rows.Count<1) clsSharedHelper.WriteInfo(string.Format(rt,"201","\"\"","门店不存在"));
            //int khid = Convert.ToInt32(dt.Rows[0]["khid"]);
            //clsSharedHelper.DisponseDataTable(ref dt);
            //LiLanzDALForXLM dal1 = new LiLanzDALForXLM(khid);
            //dal.ConnectionString = dal1.ConnectionString;
            //dal1.Dispose();

            mysql = @"SELECT TOP  10 COUNT(1) AS sl,b.mc
                    FROM yx_t_vipkh a INNER JOIN dbo.YX_T_Viplb b ON a.klb=b.Dm
                    WHERE a.mdid=@mdid AND ty=0
                    GROUP BY b.mc,b.Dm
                    ORDER BY sl DESC";
            paras.Clear();
            paras.Add(new SqlParameter("@mdid", mdid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteInfo(string.Format(rt, "201", "\"\"", errInfo));

            rt = string.Format(rt, "200", JsonConvert.SerializeObject(dt), "");
            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.WriteInfo(rt);
        }
    }
    public void getVipCategorySale(string mdid,string ny)
    {
        string errInfo, mysql, rt = @"{{""code"":""{0}"",""sale"":{1},""msg"":""{2}""}}";
        using (LiLanzDALForXLM dal=new LiLanzDALForXLM(OAConnStr))
        {
            //mysql = "select khid from t_mdb where mdid=@mdid";
            List<SqlParameter> paras = new List<SqlParameter>();
            //paras.Add(new SqlParameter("@mdid", mdid));
            DataTable dt_sale=null;
            //errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            //if (errInfo != "") clsSharedHelper.WriteInfo(string.Format(rt,"201","\"\"",errInfo));
            //if (dt.Rows.Count<1) clsSharedHelper.WriteInfo(string.Format(rt,"201","\"\"","门店不存在"));
            //int khid = Convert.ToInt32(dt.Rows[0]["khid"]);
            //clsSharedHelper.DisponseDataTable(ref dt);
            //LiLanzDALForXLM dal1 = new LiLanzDALForXLM(khid);
            //dal.ConnectionString = dal1.ConnectionString;
           // dal1.Dispose();

            mysql = @"SELECT SUM(a.je) sje,c.mc
                        FROM dbo.zmd_v_lsdjmx a 
                        INNER JOIN dbo.YX_T_Vipkh b ON a.vip=b.kh AND a.vip<>''
                        INNER JOIN yx_T_viplb c ON b.klb=c.dm
                        WHERE a.mdid=@mdid AND a.rq>=@ny+'01' and a.rq<dateadd(month,1,@ny+'01')
                        GROUP BY c.mc
                        ORDER BY sje DESC";
            paras.Clear();
            paras.Add(new SqlParameter("@mdid", mdid));
            paras.Add(new SqlParameter("@ny", ny));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt_sale);
            if (errInfo != "") clsSharedHelper.WriteInfo(string.Format(rt, "201", "\"\"", errInfo));

            rt = string.Format(rt, "200",  JsonConvert.SerializeObject(dt_sale), "");
            clsSharedHelper.DisponseDataTable(ref dt_sale);
            clsSharedHelper.WriteInfo(rt);
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