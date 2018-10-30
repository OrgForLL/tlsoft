<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>

<!DOCTYPE html>
<script runat="server">
    private string ZBDBConstr = clsConfig.GetConfigValue("OAConnStr");
    private string LSDBConstr = clsConfig.GetConfigValue("FXDBConStr");
    private string FXDBConstr = clsConfig.GetConfigValue("CX1ConStr");
    private string ERPDBConstr = clsConfig.GetConfigValue("CX2ConStr");
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "GetDHData":
                string filterJSON = Convert.ToString(Request.Params["filters"]);
                GetDHData(filterJSON);                
                break;
            case "GetLSSQL":
                filterJSON = Convert.ToString(Request.Params["filters"]);                
                clsSharedHelper.WriteInfo(JsonHelp.dataset2json(GetLSSQL(filterJSON)));
                break; 
            case "sphhcmmx":
                string type = Convert.ToString(Request.Params["type"]);
                string sphh = Convert.ToString(Request.Params["sphh"]);
                GetSphhCmmx(type, sphh);
                break;
            case "SessionCheck":
                string userid = Convert.ToString(Session["qy_customersid"]);
                if (userid == "" || userid == null)
                    clsSharedHelper.WriteInfo("0");
                else
                    clsSharedHelper.WriteInfo("1");
                break;
            default:
                clsSharedHelper.WriteErrorInfo("请检查传入的CTRL是否有效！");
                break;
        }
    }        
     
    //该方法用于查询主库的销售订单数据  查询条件统一封装成JSON串    
    public void GetDHData(string filterJSON) {        
        JObject jo = JObject.Parse(filterJSON);
        string lx = Convert.ToString(jo["lx"]);        

        //添加筛选条件
        string filterStr = "", innerTables = "";
        string khb = " inner join tlsoft.dbo.yx_t_khb kh on a.khid=kh.khid and kh.ty=0 ";
        string spdmb = " inner join tlsoft.dbo.yx_t_spdmb sp on a.sphh=sp.sphh ";
        string splbb = " inner join tlsoft.dbo.yx_t_splb lb on sp.splbid=lb.id ";

        string khid = Convert.ToString(jo["khid"]);
        string kfbh = Convert.ToString(jo["kfbh"]);
        string lbid = Convert.ToString(jo["lbid"]);
        string sphh = Convert.ToString(jo["sphh"]);
        string mdid = Convert.ToString(jo["mdid"]);
        string ksrq = Convert.ToString(jo["ksrq"]);
        string jsrq = Convert.ToString(jo["jsrq"]);
        string khlb = Convert.ToString(jo["khlb"]);
        string zmdfl = Convert.ToString(jo["zmdfl"]);
        //由贸易公司钻取门店数据时带入的参数用于判断是否去分库查，直营大客户的直接查主库
        string curkhfl = Convert.ToString(jo["curkhfl"]);
        int roleid = Convert.ToInt32(jo["roleid"]);
        string curkhid = Convert.ToString(jo["curkhid"]);
        string order_col = Convert.ToString(jo["order"]["col"]);
        string order_direc = Convert.ToString(jo["order"]["direc"]);
        
        //验证参数合法性
        if (CheckCurkhid(curkhid) == false) { clsSharedHelper.WriteErrorInfo("参数不合法！"); return; }
        
        List<SqlParameter> paras = new List<SqlParameter>();

        if (ksrq != "" && jsrq != "")
        {
            filterStr = string.Concat(filterStr, " and a.rq>=convert(datetime,@ksrq) and a.rq<dateadd(day,1,convert(datetime,@jsrq))");
            paras.Add(new SqlParameter("@ksrq", ksrq));
            paras.Add(new SqlParameter("@jsrq", jsrq));
        }
        
        //客户类别只有在统计贸易公司时才起作用
        if (khlb != "" && lx == "kh"){
            innerTables = string.Concat(innerTables.Replace(khb, ""), khb);  //把筛选条件改成khb的，但是需要先清空khb的内容
            filterStr = string.Concat(filterStr, " and kh.khfl=@khfl");
            paras.Add(new SqlParameter("@khfl", khlb));
        }

        if (roleid < 3)     //如果是店长及以下，则强制限定其门店范围
        {
            mdid = curkhid;
        }

        if (mdid != "")
        {
            //如果有限定门店，则无需计算客户ID
            filterStr = string.Concat(filterStr, " and a.khid=@mdkhid");
            paras.Add(new SqlParameter("@mdkhid", mdid));
        }
        else {
            if (curkhid != "") khid = curkhid;//有注入风险。可事先检查 curkhid 逗号分隔符的每一项是否为整数即可消除风险。
            if (khid != "")
            {
                //需要到各自分库去查
                if ((lx == "md" || mdid != "") && curkhfl != "xg")
                {
                    filterStr = string.Concat(filterStr, " and a.tzid='" + khid + "'");
                    //paras.Add(new SqlParameter("@khid", khid));
                }
                else
                {
                    filterStr = string.Concat(filterStr, " and a.tzid=1 and a.khid=@khid");
                    paras.Add(new SqlParameter("@khid", khid));
                }
            }
        }

        if (kfbh != "")
        {
            innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
            filterStr = string.Concat(filterStr, " and sp.kfbh=@kfbh");
            paras.Add(new SqlParameter("@kfbh", kfbh));
        }

        if (lbid != "")
        {
            innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
            filterStr = string.Concat(filterStr, " and sp.splbid=@lbid");
            paras.Add(new SqlParameter("@lbid", lbid));
        }

        if (sphh != "")
        {
            //filterStr = string.Concat(filterStr, " and a.sphh=@sphh");
            filterStr = string.Concat(filterStr, " and a.sphh LIKE @sphh + '%' ");
            paras.Add(new SqlParameter("@sphh", sphh));
        }

        string str_sql = @" select {0},sum(a.sl) ddsl
                            from yx_v_dddjmx a                                                            
                            {1}                                
                            where a.djlx=201 and a.djbs=1 {3}
                            group by {2} order by sum(a.sl) desc";

        switch (lx)
        {
            case "kh":
                filterStr = string.Concat(filterStr, " and a.tzid=1");
                innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
                str_sql = string.Format(str_sql, "convert(varchar(10),a.khid) khid,upper(kh.khdm) khdm,kh.khmc,kh.khjc,kh.khfl", innerTables, "a.khid,kh.khdm,kh.khmc,kh.khjc,kh.khfl", filterStr);
                break;
            case "md":
                innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
                str_sql = string.Format(str_sql, "a.khid,kh.khmc,kh.khjc", innerTables, "a.khid,kh.khmc,kh.khjc", filterStr);
                break;
            case "lb":
                if (mdid != "" || (roleid != 3 && roleid != 99))
                {
                    innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
                    innerTables = string.Concat(innerTables.Replace(splbb, ""), splbb); 
                    str_sql = string.Format(str_sql, "lb.id lbid,lb.mc lbmc,'' zzl,'' bhl", innerTables, "lb.id,lb.mc", filterStr);
                }
                else {
                    //查看类别时多了周转量与备货量
                    innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
                    str_sql = @"select {0},sum(a.sl) ddsl into #zb
                            from yx_v_dddjmx a                            
                            {1}                                
                            where a.tzid=1 and a.djlx=201 and a.djbs=1 {3}
                            group by {2};
                            --备货量与周转量
                            select distinct lbid,sphh into #sphh from #zb;
                            select a.sphh,isnull(a.tcl,0) tcl,c.bhl,isnull(a.tcl,0)-isnull(b.ddsl,0) zzl into #zzbh
                            from #sphh s
                            left join (
                              --统筹计划量
                              select a.sphh,sum(b.sl0) tcl 
                              from #sphh s inner join yx_t_tcjhb a on s.sphh=a.sphh
                              inner join yx_t_tcjhcmmx b on a.id=b.id
                              where a.tzid=1 and a.shbs=1 group by a.sphh
                            ) a on s.sphh=a.sphh
                            left join (
                              select a.sphh,sum(a.sl) ddsl  
                              from #sphh s inner join yx_v_dddjmx a on a.sphh=s.sphh
                              where a.djlx=201 and a.djbs=1 group by a.sphh
                            ) b on a.sphh=b.sphh
                            left join (
                              --备货库存
                              select a.sphh,sum(a.sl0-a.dbdf0-a.qtdf0) bhl 
                              from #sphh s inner join YX_T_Spkccmmx a on a.sphh=s.sphh
                              where a.tzid=1 and a.ckid not in (9325,6671,7013) group by a.sphh
                            ) c on a.sphh=c.sphh
                            
                            select lb.id lbid,lb.mc lbmc,sum(b.zzl) zzl,sum(b.bhl) bhl,sum(a.ddsl) ddsl
                            from #zb a 
                            inner join yx_t_splb lb on lb.id=a.lbid
                            left join #zzbh b on a.sphh=b.sphh
                            group by lb.id,lb.mc

                            drop table #zb;drop table #sphh;drop table #zzbh;";
                    str_sql = string.Format(str_sql, "sp.splbid lbid,sp.sphh,sp.spmc", innerTables, "sp.splbid,sp.sphh,sp.spmc", filterStr);
                }                
                break;
            case "sphh":
                innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
                if (mdid != "" || (roleid != 3 && roleid != 99))
                {
                    //有传入门店ID限制条件的无法统计周转量与备货量
                    //只有总部权限才会显示周转量与备货量
                    str_sql = string.Format(str_sql, "sp.sphh,sp.spmc,'' zzl,'' bhl", innerTables, "sp.sphh,sp.spmc", filterStr);
                }
                else
                {
                    //查看货号时多了周转量与备货量
                    str_sql = @"select {0},sum(a.sl) ddsl into #zb
                            from yx_v_dddjmx a                            
                            {1}                                
                            where a.tzid=1 and a.djlx=201 and a.djbs=1 {3}
                            group by {2} order by sum(a.sl) desc;
                            --备货量与周转量
                            select distinct sphh into #sphh from #zb;
                            select a.sphh,isnull(a.tcl,0) tcl,c.bhl,isnull(a.tcl,0)-isnull(b.ddsl,0) zzl into #zzbh
                            from #sphh s
                            left join (
                              --统筹计划量
                              select a.sphh,sum(b.sl0) tcl 
                              from #sphh s inner join yx_t_tcjhb a on s.sphh=a.sphh
                              inner join yx_t_tcjhcmmx b on a.id=b.id
                              where a.tzid=1 and a.shbs=1 group by a.sphh
                            ) a on s.sphh=a.sphh
                              --订单数量
                            left join (
                              select a.sphh,sum(a.sl) ddsl  
                              from #sphh s inner join yx_v_dddjmx a on a.sphh=s.sphh
                              where a.djlx=201 and a.djbs=1 group by a.sphh
                            ) b on a.sphh=b.sphh
                            left join (
                              --备货库存
                              select a.sphh,sum(a.sl0-a.dbdf0-a.qtdf0) bhl 
                              from #sphh s inner join YX_T_Spkccmmx a on a.sphh=s.sphh
                              where a.tzid=1 and a.ckid not in (9325,6671,7013) group by a.sphh
                            ) c on a.sphh=c.sphh
                            
                            select a.*,b.zzl,b.bhl from #zb a left join #zzbh b on a.sphh=b.sphh

                            drop table #zb;drop table #sphh;drop table #zzbh;";
                    str_sql = string.Format(str_sql, "sp.sphh,sp.spmc", innerTables, "sp.sphh,sp.spmc", filterStr);
                }                
                break;
            default:
                clsSharedHelper.WriteErrorInfo("未知请求类型！");
                return;
        }
        
        //接下来进行分库查询
        string DBConn = "";
        if ((lx == "md" || mdid != "") && curkhfl != "xg")
        {
            DBConn = GetDBConstr(khid, mdid);
            //WriteLog(string.Format("khid={0},mdid={1},dbconstr={2}", khid, mdid, DBConn));
        }
        else {
            DBConn = ZBDBConstr;            
        }            
        
        using (LiLanzDALForXLM dal_dd = new LiLanzDALForXLM(DBConn)) {
            DataTable dt_dd, dt_ls;
            //WriteLog(str_sql + "\r\n" + filterJSON);
            //WriteParas(paras);
            string errinfo = dal_dd.ExecuteQuerySecurity(str_sql,paras,out dt_dd);            
            WriteLog("订单数据查询结束！" + DBConn);
            if (errinfo == "")
            {
                //查询零售数据
                dt_ls = GetLSSQL(filterJSON);
                dt_dd.PrimaryKey = new DataColumn[] { dt_dd.Columns[0] };
                dt_ls.PrimaryKey = new DataColumn[] { dt_ls.Columns[0] };
                //WriteLog("dt_dd-rows:"+dt_dd.Rows.Count.ToString()+" dt_ls-rows:"+dt_ls.Rows.Count.ToString());
                dt_dd.Merge(dt_ls);
                
                if (dt_dd.Rows.Count > 0)
                {
                    //计算完成率
                    //WriteLog("开始计算完成率");
                    double ddsl, lssl, percent;
                    dt_dd.Columns.Add("wcl", typeof(double));
                    for (int i = 0; i < dt_dd.Rows.Count; i++)
                    {
                        string _ddsl = Convert.ToString(dt_dd.Rows[i]["ddsl"]);
                        string _lssl = Convert.ToString(dt_dd.Rows[i]["xssl"]);
                        if (_ddsl == "" || _lssl == "" || _ddsl == "0" || _lssl == "0")
                            continue;
                        ddsl = Convert.ToInt32(_ddsl);
                        lssl = Convert.ToInt32(_lssl);
                        percent = Convert.ToDouble(lssl / ddsl);
                        dt_dd.Rows[i]["wcl"] = Math.Round(percent, 4) * 100;
                    }//end for

                    //查看货号视图或者是类别视图时统计
                    //if (lx != "md" && mdid == "")
                    //    if (lx == "lb")
                    //        StaticZZBH("lbid", ref dt_dd, kfbh);

                    //排序  
                    if (order_col != "")
                    {
                        DataView dv = dt_dd.DefaultView;
                        switch (order_col)
                        {
                            case "kh":
                                dv.Sort = "khdm " + order_direc;
                                break;
                            case "lb":
                                dv.Sort = "lbmc " + order_direc;
                                break;
                            case "md":
                                dv.Sort = "khmc " + order_direc;
                                break;
                            case "sphh":
                                dv.Sort = "sphh " + order_direc;
                                break;
                            default:
                                dv.Sort = order_col + " " + order_direc;
                                break;
                        }
                        dt_dd = dv.ToTable();
                    }

                    string outJson = JsonHelp.dataset2json(dt_dd);
                    dt_dd.Clear(); dt_dd.Dispose();
                    dt_ls.Clear(); dt_ls.Dispose();
                    //WriteLog("计算完成率结束");
                    clsSharedHelper.WriteInfo(outJson);
                }
                else
                    clsSharedHelper.WriteInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("GetDHData" + errinfo + "|" +filterJSON);
        }//end using
    }

    //计算周转量与备货量 商品货号使用IN查询效率很低，即使是用了ID
    public void StaticZZBH(string groupby, ref DataTable dt, string kfbh)
    {
        WriteLog("开始统计周转量与备货量");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ZBDBConstr))
        {
            StringBuilder sb = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
            {
                sb.AppendFormat(",'{0}'", dr[groupby]);
            }
            if (sb.Length == 0) return;
            sb.Remove(0, 1);
            string str_sql = @"--备货量与周转量                            
                                select {0},sum(b.sl0) tcl into #tcl
                                from yx_t_spdmb sp  
                                {3}                              
                                inner join yx_t_tcjhb a on a.sphh=sp.sphh
                                inner join yx_t_tcjhcmmx b on a.id=b.id
                                where a.tzid=1 and a.shbs=1 {1}
                                group by {2}

                                select {0},sum(a.sl0) ddsl into #ddl
                                from yx_t_spdmb sp    
                                {3}                            
                                inner join yx_v_dddjcmmx a on a.sphh=sp.sphh
                                where a.djlx=201 and a.djbs=1 {1}
                                group by {2}

                                select {0},sum(a.sl0-a.dbdf0-a.qtdf0) bhl into #bhl
                                from yx_t_spdmb sp
                                {3}
                                inner join YX_T_Spkccmmx a on a.sphh=sp.sphh
                                where a.tzid=1 and a.ckid not in (9325,6671,7013) {1}
                                group by {2} ";

            if (groupby == "spid")
            {
                string sphh_sql = @"DECLARE @str VARCHAR(MAX);
                                    SET @str = '{0}';
                                    CREATE TABLE #sphhs
                                    (
                                      id int
                                    ) 
                                    DECLARE @i    INT 
                                    DECLARE @len  INT 
                                    SET @i = 1 
                                    WHILE @i < LEN(@str + ',')
                                    BEGIN
                                      INSERT #sphhs;
                                      SELECT SUBSTRING(@str + ',', @i, CHARINDEX(',', @str + ',', @i) -@i);
                                      SET @i = CHARINDEX(',', @str + ',', @i) + 1;
                                    END;CREATE INDEX IX_spid  ON #sphhs(id); ";                
                sphh_sql = string.Format(sphh_sql, sb.ToString().Replace("'", ""));                
                str_sql = string.Format(str_sql, "sp.sphh", "", "sp.sphh", "inner join #sphhs s on sp.id=s.id");
                str_sql = sphh_sql + str_sql;                
                str_sql += @" select a.sphh,isnull(t.tcl,0)-isnull(d.ddsl,0) zzl,isnull(b.bhl,0) bhl
                                from yx_t_spdmb a
                                inner join #sphhs sp on a.id=sp.id
                                left join #tcl t on a.sphh=t.sphh
                                left join #ddl d on a.sphh=d.sphh
                                left join #bhl b on a.sphh=b.sphh
                                drop table #tcl;drop table #ddl;drop table #bhl;drop table #sphhs;";
            }
            else if (groupby == "lbid")
            {
                if (kfbh == "")
                    str_sql = string.Format(str_sql, "sp.splbid", " and sp.splbid in (" + sb.ToString() + ")", "sp.splbid", "");
                else
                    str_sql = string.Format(str_sql, "sp.splbid", " and sp.kfbh='" + kfbh + "' and sp.splbid in (" + sb.ToString() + ")", "sp.splbid", "");
                str_sql += @" select a.splbid lbid,isnull(t.tcl,0)-isnull(d.ddsl,0) zzl,isnull(b.bhl,0) bhl
                                from (select distinct splbid from yx_t_spdmb where splbid in (" + sb.ToString() + ")  ) a " + @"
                                left join #tcl t on a.splbid=t.splbid
                                left join #ddl d on a.splbid=d.splbid
                                left join #bhl b on a.splbid=b.splbid;
                                drop table #tcl;drop table #ddl;drop table #bhl;";
            }

            DataTable dt2;
            string errinfo = dal.ExecuteQuery(str_sql, out dt2);

            if (errinfo == "")
            {
                dt2.PrimaryKey = new DataColumn[] { dt2.Columns[0] };
                dt.Merge(dt2);
            }
            else
                WriteLog("统计周转量和备货量时出错！" + errinfo + str_sql);

            if (dt2 != null) dt2.Clear(); dt2.Dispose();
        }//end using
        WriteLog("结束统计周转量与备货量");
    }
    
    //构造查询销售情况的SQL  查询条件统一封装成JSON串        
    public DataTable GetLSSQL(string filterJSON) {
        JObject jo = JObject.Parse(filterJSON);
        string lx = Convert.ToString(jo["lx"]);       
        //添加筛选条件
        string filterStr = "", innerTables = "", _sql = "";
        string spdmb = " inner join yx_t_spdmb sp on a.sphh=sp.sphh ";
        string splbb = " inner join yx_t_splb lb on sp.splbid=lb.id ";

        string mdb = " inner join t_mdb md on a.mdid=md.mdid and md.ty=0 ";
        string khb = " inner join yx_t_khb kh on md.khid=kh.khid and kh.ty=0 ";
        string khgxb = " inner join yx_t_khgxb gx on md.khid=gx.gxid and gx.ty=0 and a.rq>=convert(datetime,gx.ksny+'01') and a.rq<dateadd(month,1,convert(datetime,gx.jsny+'01')) ";
        
        string khid = Convert.ToString(jo["khid"]);
        string kfbh = Convert.ToString(jo["kfbh"]);
        string lbid = Convert.ToString(jo["lbid"]);
        string sphh = Convert.ToString(jo["sphh"]);        
        string mdid = Convert.ToString(jo["mdid"]);
        string ksrq = Convert.ToString(jo["ksrq"]);
        string jsrq = Convert.ToString(jo["jsrq"]);
        string khlb = Convert.ToString(jo["khlb"]);
        string zmdfl = Convert.ToString(jo["zmdfl"]);
        int roleid = Convert.ToInt32(jo["roleid"]);
        string curkhid = Convert.ToString(jo["curkhid"]);
        
        List<SqlParameter> paras = new List<SqlParameter>();        
        switch (lx)
        {
            case "kh":
                innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
                //innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
                innerTables = string.Concat(innerTables.Replace(khgxb, ""), khgxb);
                
                _sql = @"select substring(a.ccid0,0,charindex('-',a.ccid0)) khid,upper(kh.khdm) khdm,kh.khmc,kh.khfl,sum(a.sl) xssl
                         from (
                           select a.khid,replace(gx.ccid,'-1-','')+'-' ccid0,a.djlb/abs(a.djlb)*sl sl
                           from zmd_v_lsdjmx a                                                     
                           {0}
                           where a.djlb in (1,-1,2,-2) and a.djbs=1 {1}
                           ) a
                         inner join yx_t_khb kh on kh.khid=substring(a.ccid0,0,charindex('-',a.ccid0)) AND kh.khfl <> 'xq' {2}
                         group by substring(a.ccid0,0,charindex('-',a.ccid0)),kh.khdm,kh.khmc,kh.khfl";
                break;
            case "md":
                innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
                innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
                _sql = @"select a.khid,m.khmc,sum(a.djlb/abs(a.djlb)*sl) xssl
                          from zmd_v_lsdjmx a                          
                          inner join yx_t_khb m on a.khid=m.khid
                          {0}                                                    
                          where a.djlb in (1,-1,2,-2) and a.djbs=1 {1}
                          group by a.khid,m.khmc";
                break;
            case "lb":
                innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
                innerTables = string.Concat(innerTables.Replace(splbb, ""), splbb);                
                _sql = @"select sp.splbid lbid,lb.mc lbmc,sum(a.djlb/abs(a.djlb)*sl) xssl
                         from zmd_v_lsdjmx a
                         {0}
                         where a.djlb in (1,-1,2,-2) and a.djbs=1 {1}
                         group by sp.splbid,lb.mc";                
                break;
            case "sphh":
                innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
                _sql = @"select a.sphh,sp.spmc,sum(a.djlb/abs(a.djlb)*sl) xssl
                         from zmd_v_lsdjmx a
                         {0}
                         where a.djlb in (1,-1,2,-2) and a.djbs=1 {1}
                         group by a.sphh,sp.spmc";
                break;
        }//end switch
        
        if (roleid < 3)     //如果是店长及以下，则强制限定其门店范围
        {
            mdid = curkhid;
        }
        
        if (curkhid != "") khid = curkhid;      //如果已经指定了客户，则在这里直接强制指定。
        if (khid != "")
        {
            khid = "-1-" + khid + "-%";
            innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
            //innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
            if (lx == "kh")
            {
                innerTables = string.Concat(innerTables.Replace(khgxb, ""), khgxb);
                filterStr = string.Concat(filterStr, " and gx.ccid+'-' like @khid");
            }
            else
            {
                innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
                filterStr = string.Concat(filterStr, " and kh.ccid+'-' like @khid");
            }    
            
            //filterStr = string.Concat(filterStr, " and kh.ccid+'-' like @khid");
            paras.Add(new SqlParameter("@khid", khid));
        }

        //客户类别只有在统计贸易公司时才起作用
        if (khlb != "" && lx == "kh"){
            innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
            //innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
            innerTables = string.Concat(innerTables.Replace(khgxb, ""), khgxb);
        }

        if (ksrq != "" && jsrq != "") {
            filterStr = string.Concat(filterStr, " and a.rq>=convert(datetime,@ksrq) and a.rq<convert(datetime,@jsrq)");
            paras.Add(new SqlParameter("@ksrq", ksrq));
            paras.Add(new SqlParameter("@jsrq", jsrq));
        }        

        if (mdid != "") {
            filterStr = string.Concat(filterStr, " and a.khid=@mdkhid");
            paras.Add(new SqlParameter("@mdkhid", mdid));
        }            

        if (kfbh != "")
        {
            if (lx == "lb")
            {
                //因为先后顺序问题，否则如果只连spdmb则会移至splbb后导致出错
                innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
                innerTables = string.Concat(innerTables.Replace(splbb, ""), splbb);
            }
            else
                innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);//应区分开否则查询速度下降
            filterStr = string.Concat(filterStr, " and sp.kfbh=@kfbh");
            paras.Add(new SqlParameter("@kfbh", kfbh));  
        }

        if (lbid != "")
        {
            innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
            innerTables = string.Concat(innerTables.Replace(splbb, ""), splbb);
            filterStr = string.Concat(filterStr, " and sp.splbid=@lbid");
            paras.Add(new SqlParameter("@lbid", lbid));  
        }

        if (sphh != "") {
            //filterStr = string.Concat(filterStr, " and a.sphh=@sphh");
            filterStr = string.Concat(filterStr, " and a.sphh LIKE @sphh + '%' ");
            paras.Add(new SqlParameter("@sphh", sphh));
        }

        if (lx == "kh") {
            if (zmdfl != "") {
                filterStr = string.Concat(filterStr, " and gx.khfl=@zmdfl ");
                paras.Add(new SqlParameter("@zmdfl", zmdfl));
            }
            if (khlb != "") {
                _sql = string.Format(_sql, innerTables, filterStr, " and kh.khfl=@khfl");
                paras.Add(new SqlParameter("@khfl", khlb));
           }else
                _sql = string.Format(_sql, innerTables, filterStr, "");
        }else
            _sql = string.Format(_sql, innerTables, filterStr);

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(LSDBConstr)) { 
            DataTable dt;
            WriteLog(_sql + "\r\n" + filterJSON);            
            string errinfo = dal.ExecuteQuerySecurity(_sql,paras,out dt);
            WriteLog("销售数据查询结束！");
            WriteParas(paras);
            if (errinfo != "")
                WriteLog(errinfo);            
            return dt;
        }//end using                        
    }

    /// <summary>
    /// 检查SQL参数合法性，防止注入
    /// </summary>
    /// <param name="curkhid"></param>
    /// <returns></returns>
    public bool CheckCurkhid(string curkhid)
    {
        if (curkhid == "") return true;

        string[] lstkhid = curkhid.Split(',');

        int tmp;
        foreach (string strkhid in lstkhid)
        {
            if (int.TryParse(strkhid, out tmp) == false) return false;
        }
        return true;
    } 
    
    //查询货号对应的尺码明细
    public void GetSphhCmmx(string type,string sphh) {
        string _sql = "",rtJson="";
        DataTable dt;
        if (type == "zzl")
        {
            _sql = @"select a.cm cmdm,sum(isnull(tc.sl,0)-isnull(dd.sl,0)) cmsl
                    from  yx_t_cmzh a
                    inner join yx_t_spdmb c on a.tml=c.tml and c.sphh=@sphh and c.tzid=1
                    left join (
                    select b.cmdm,sum(b.sl0) as sl 
                    from yx_t_tcjhb a inner join yx_t_tcjhcmmx b on a.id=b.id 
                    where a.sphh=@sphh and a.shbs=1 group by b.cmdm ) tc on a.cmdm=tc.cmdm
                    left join (
                    select cmdm,sum(sl0) as sl
                    from yx_v_dddjcmmx where sphh=@sphh and djlx=201 and djbs=1
                    group by cmdm ) dd on a.cmdm=dd.cmdm 
                    group by a.cm having sum(isnull(tc.sl,0)-isnull(dd.sl,0))<>0";
            
        }
        else if (type == "bhl")
        {
            _sql = @"select a.cm cmdm,sum(ISNULL(b.sl0,0)) cmsl
                    from  yx_t_cmzh a
                    inner join yx_t_spdmb c on a.tml=c.tml and c.sphh=@sphh and c.tzid=1
                    left join(SELECT sl0-dbdf0-qtdf0 AS sl0,cmdm 
                    from yx_t_spkccmmx where ckid not in (9325,6671,7013) and sphh=@sphh and tzid=1) b on a.cmdm=b.cmdm
                    where a.tzid=1 
                    group by a.cm having sum(isnull(b.sl0,0))>0
                    order by a.cm";
        }
        else {
            clsSharedHelper.WriteErrorInfo("未知类型！");
            return;
        }

        if (_sql != "") {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ZBDBConstr)) {
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@sphh", sphh));
                string errinfo = dal.ExecuteQuerySecurity(_sql, paras, out dt);
                if (errinfo == "" && dt.Rows.Count > 0)
                {
                    rtJson = JsonHelp.dataset2json(dt);
                }
                else
                    rtJson = "Error:" + errinfo;

                dt.Clear(); dt.Dispose();                       
            }//end using
        }

        clsSharedHelper.WriteInfo(rtJson);
    }

    public void WriteParas(List<SqlParameter> paras) {
        for (int i = 0; i < paras.Count; i++) {
            WriteLog(string.Format("{0}={1}", paras[i].ParameterName, paras[i].Value));
        }
    }
    
    //查询不同贸易公司所使用的数据库  
    private string GetDBConstr(int khid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ZBDBConstr))
        {
            string dbcon = dal.GetDBName(khid);
            return GetDBConstr(dbcon);
        }
    }
    private string GetDBConstr(string dbcon)
    {
        if (dbcon == "ERPDB") return ERPDBConstr;
        else if (dbcon == "FXDB") return FXDBConstr;
        else return ZBDBConstr;
    }
    private string GetDBConstr(string khid, string mdid)
    {
        if (khid != "" && khid != "0")
        {
            return GetDBConstr(Convert.ToInt32(khid));
        }
        else if (mdid.Length != 0 && mdid != "0")
        {
            return GetDBConstr(Convert.ToInt32(mdid));
        }
        else
            return "";
    }
    
    //字符串的拼接
    //停用string.Concat效率更高
    private string StringPlus(string str0, string str1)
    {
        string str = "";
        StringBuilder sb = new StringBuilder(str0);                
        sb.Append(str1);
        str = sb.ToString();
        sb.Length = 0;
        return str;
    }
    
    //写日志:仅调试的时候使用
    private void WriteLog(string strText)
    {
        return;
        //if (strText.Contains("错误")) clsLocalLoger.WriteError(strText);
        //else clsLocalLoger.WriteInfo(strText);
        
        //String path = HttpContext.Current.Server.MapPath("logs/");
        //if (!System.IO.Directory.Exists(System.IO.Path.GetDirectoryName(path)))
        //{
        //    System.IO.Directory.CreateDirectory(path);
        //}

        //System.IO.StreamWriter writer = new System.IO.StreamWriter(path + DateTime.Now.ToString("yyyyMMdd") + ".log", true);
        //string str;
        //str = "【" + DateTime.Now.ToString() + "】" + "  " + strText;
        //writer.WriteLine(str);
        //writer.Close();
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
