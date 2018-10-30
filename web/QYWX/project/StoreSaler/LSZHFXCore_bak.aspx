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

    private const int MaxDataCount = 5000;//一次最多呈现的数据行数

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "GetCGData":
                string filterJSON = Convert.ToString(Request.Params["filters"]);
                GetCGData(filterJSON);
                break;
            case "GetLSSQL":
                filterJSON = Convert.ToString(Request.Params["filters"]);
                //GetLSSQL(filterJSON);
                clsSharedHelper.WriteInfo(JsonHelp.dataset2json(GetLSSQL(filterJSON)));
                break;
            default:
                clsSharedHelper.WriteErrorInfo("请检查传入的CTRL是否有效！");
                break;
        }
    }

    //该方法用于查询主库的销售订单数据  查询条件统一封装成JSON串    
    public void GetCGData(string filterJSON) {
        //JObject jo = JObject.Parse(filterJSON);
        clsJsonHelper jo = clsJsonHelper.CreateJsonHelper(filterJSON);

        string lx = Convert.ToString(jo.GetJsonValue("core/lx"));

        if (lx == "kh" || lx == "md")
        {
            GetMDLSSQL(filterJSON);
            return;
        }
        string dbstr = Convert.ToString(jo.GetJsonValue("core/dbstr"));     //用于确定数据源

        string order_col = Convert.ToString(jo.GetJsonValue("order/colname"));//  排序列名
        string order_direc = Convert.ToString(jo.GetJsonValue("order/ordertype"));// 排序类型

        DataTable dt_ls;
        string errinfo = "";

        if (errinfo == "")
        {

            //查询零售数据
            dt_ls = GetLSSQL(filterJSON);
            dt_ls.PrimaryKey = new DataColumn[] { dt_ls.Columns[0] };

            //删除隐藏数据
            RemoveMyData(ref dt_ls);

            if (dt_ls.Rows.Count > 0)
            {
                //计算完成率 
                if (order_col != "") SetOrder(ref dt_ls, order_col, order_direc);       //设置排序输出                                    

                //计算合计值 
                object objSumXssl = dt_ls.Compute("SUM(xssl)", "");
                object objSumXsje = dt_ls.Compute("SUM(xsje)", "");
                long SumXssl = objSumXssl == DBNull.Value ? 0 : Convert.ToInt64(objSumXssl);
                long SumXsje = objSumXsje == DBNull.Value ? 0 : Convert.ToInt64(objSumXsje);

                string JsonAdd = @"""sumXssl"":""{0}"",""sumXsje"":""{1}"",";
                JsonAdd = string.Format(JsonAdd, SumXssl, SumXsje);
                //计算合计值完毕                     

                //如果数据量过大，则只输出x条 
                int j = dt_ls.Rows.Count;
                if (j > MaxDataCount)
                {
                    for (int i = j-1; i >= MaxDataCount; i--)
                    {
                        dt_ls.Rows.RemoveAt(i);
                    }
                }
                //删除多余数据

                string outJson = JsonHelp.dataset2json(dt_ls);
                outJson = outJson.Insert(1, JsonAdd);

                clsSharedHelper.DisponseDataTable(ref dt_ls);

                clsSharedHelper.WriteInfo(outJson);
            }
            else
                clsSharedHelper.WriteInfo("");
        }
        else
            clsSharedHelper.WriteErrorInfo(errinfo);
    }

    private void SetOrder(ref DataTable dt, string order_colName, string order_direc)
    {
        //排序  
        if (string.IsNullOrEmpty(order_colName) == false)
        {
            if (dt.Columns.Contains(order_colName) == false) return;

            DataView dv = dt.DefaultView;
            dv.Sort = string.Concat(order_colName, " ", order_direc);

            DataTable dt2 = dv.ToTable();
            dt.Clear(); dt.Dispose();

            dt = dt2;
        }
    }

    /// <summary>
    /// 检查SQL参数合法性，防止注入
    /// </summary>
    /// <param name="curkhid"></param>
    /// <returns></returns>
    public bool CheckCurkhid(string curkhid){
        if (curkhid == "") return true;

        string[] lstkhid = curkhid.Split(',');

        int tmp;
        foreach (string strkhid in lstkhid)
        {
            if (int.TryParse(strkhid, out tmp) == false) return false;
        }
        return true;
    }

    //构造查询销售情况的SQL  查询条件统一封装成JSON串        
    public DataTable GetLSSQL(string filterJSON) {
        clsJsonHelper jo = clsJsonHelper.CreateJsonHelper(filterJSON);

        //添加筛选条件  
        string lx = Convert.ToString(jo.GetJsonValue("core/lx"));
        string dbstr = Convert.ToString(jo.GetJsonValue("core/dbstr"));     //用于确定数据源

        //添加筛选条件
        string filterStr = "", innerTables = "", _sql = "";

        string mdb = @" inner join tlsoft.dbo.t_mdb md on a.mdid=md.mdid and md.ty=0 ";
        string khb = " inner join tlsoft.dbo.yx_t_khb kh on md.khid=kh.khid and kh.ty=0 ";
        string spdmb = " inner join tlsoft.dbo.yx_t_spdmb sp on a.sphh=sp.sphh ";
        string splbb = " inner join tlsoft.dbo.yx_t_splb lb on sp.splbid=lb.id ";
        string khgxb = " inner join tlsoft.dbo.yx_t_khgxb gx on md.khid=gx.gxid and gx.ty=0 and a.rq>=convert(datetime,gx.ksny+'01') and a.rq<dateadd(month,1,convert(datetime,gx.jsny+'01')) ";

        string khid = Convert.ToString(jo.GetJsonValue("core/khid"));
        string kfbh = Convert.ToString(jo.GetJsonValue("filter/kfbh"));  //
        string lbid = Convert.ToString(jo.GetJsonValue("core/lbid"));//
        string sphh = Convert.ToString(jo.GetJsonValue("spsearch"));//
        string mdkhid = Convert.ToString(jo.GetJsonValue("core/mdkhid"));     //原先是mdid
        string ksrq = Convert.ToString(jo.GetJsonValue("filter/ksrq"));//
        string jsrq = Convert.ToString(jo.GetJsonValue("filter/jsrq"));//
        string khfl = Convert.ToString(jo.GetJsonValue("filter/khfl"));//.Split('-')[0];// 
        string zmdfl = "";
        if (khfl != "") {
            zmdfl = khfl.Split('-')[1];
            khfl = khfl.Split('-')[0];
        }

        int roleid = Convert.ToInt32(jo.GetJsonValue("auth/roleid"));//        
        string curkhid = Convert.ToString(jo.GetJsonValue("auth/curkhid"));// 

        jo.Dispose();

        List<SqlParameter> paras = new List<SqlParameter>();
        switch (lx)
        {
            case "lb":
                innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
                innerTables = string.Concat(innerTables.Replace(splbb, ""), splbb);

                _sql = @"select sp.splbid lbid,lb.mc lbmc,sum(case when a.djlb in (-1,-2) then -1*a.sl else a.sl end) xssl,
                            sum(case when a.djlb in (-1,-2) then -1*a.je else a.je end) xsje          
                         from zmd_v_lsdjmx a
                         {0}
                         where a.djlb in (1,-1,2,-2) and a.djbs=1 {1}
                         group by sp.splbid,lb.mc";
                break;
            case "sphh":
                _sql = @"select a.sphh,sum(case when a.djlb in (-1,-2) then -1*a.sl else a.sl end) xssl,
                            sum(case when a.djlb in (-1,-2) then -1*a.je else a.je end) xsje   
                         from zmd_v_lsdjmx a                         
                         {0}
                         where a.djlb in (1,-1,2,-2) and a.djbs=1 {1}
                         group by a.sphh";
                break;
        }//end switch

        //if (roleid < 3)     //如果是店长及以下，则强制限定其门店范围 :这条限定已经没有必要。 By:xlm 20170814
        //{
        //    mdkhid = curkhid;
        //}

        if (curkhid != "") khid = curkhid;      //如果已经指定了客户，则在这里直接强制指定。
        if (khid != "")
        {
            khid = getCcid(Convert.ToInt32(khid)) + "-%";
            innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);

            innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
            filterStr = string.Concat(filterStr, " and kh.ccid+'-' like @khid");
            paras.Add(new SqlParameter("@khid", khid));
        }


        if (khfl != "" && lx == "kh")
        {
            innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
            //innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
            innerTables = string.Concat(innerTables.Replace(khgxb, ""), khgxb);
        }

        if (ksrq != "" && jsrq != "")
        {
            //filterStr = string.Concat(filterStr, " and a.rq BETWEEN @ksrq and @jsrq");
            //paras.Add(new SqlParameter("@ksrq", Convert.ToDateTime(ksrq)));
            //paras.Add(new SqlParameter("@jsrq", Convert.ToDateTime(jsrq).AddDays(1)));
            filterStr = string.Concat(filterStr, " and a.rq>=@ksrq and a.rq<dateadd(day,1,@jsrq)");
            paras.Add(new SqlParameter("@ksrq", Convert.ToDateTime(ksrq)));
            paras.Add(new SqlParameter("@jsrq", Convert.ToDateTime(jsrq)));
        }

        if (mdkhid != "")
        {
            //filterStr = string.Concat(filterStr, " and a.khid=@mdkhid");
            filterStr = string.Concat(filterStr, " and a.mdid=@mdkhid");    //由于上一个级别已经改成mdid传入，因此在这里也改成这个。
            paras.Add(new SqlParameter("@mdkhid", mdkhid));
        }

        if (kfbh != "")
        {
            if (lx == "lb")
            {
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

        if (sphh != "")
        {
            //filterStr = string.Concat(filterStr, " and a.sphh=@sphh");
            filterStr = string.Concat(filterStr, " and a.sphh LIKE @sphh + '%' ");
            paras.Add(new SqlParameter("@sphh", sphh));
        }

        if (lx == "kh")
        {
            if (zmdfl != "") {
                filterStr = string.Concat(filterStr, " and gx.khfl LIKE @zmdfl ");
                paras.Add(new SqlParameter("@zmdfl", zmdfl));
            }
            if (khfl != "")
            {
                _sql = string.Format(_sql, innerTables, filterStr, " and kh.khfl=@khfl");
                paras.Add(new SqlParameter("@khfl", khfl));
            }

            else
                _sql = string.Format(_sql, innerTables, filterStr, "");

        }
        if (lx != "kh")
        {
            if (zmdfl != "")
            {
                innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
                innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
                filterStr = string.Concat(filterStr, " and kh.khfl LIKE @zmdfl ");
                paras.Add(new SqlParameter("@zmdfl", zmdfl));
            }
            _sql = string.Format(_sql, innerTables, filterStr);
        }
        else
            _sql = string.Format(_sql, innerTables, filterStr);

        //clsLocalLoger.WriteInfo("khid:" + khid);
        //clsLocalLoger.WriteInfo("SQL:" + _sql);        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(LSDBConstr))
        {
            DataTable dt;
            //WriteLog(_sql + "\r\n" + filterJSON);
            string errinfo = dal.ExecuteQuerySecurity(_sql, paras, out dt);

            if (errinfo != "")
                LeeWriteLog(errinfo);

            //WriteLog("销售数据查询结束！");            
            //if (errinfo != "")
            //    WriteLog(errinfo);
            return dt;
        }//end using                     
    }

    //20170517。By:xlm .官部提出需求：要屏蔽 领航营销管理有限公司-综合帐套、领航营销管理有限公司(特卖专户)、内部结算(部门领用) 三个套帐的数据；参考PC存储的写法执行效率较低，因此考虑删除 khdm LIKE '0000__' 的数据即可
    private void RemoveMyData(ref DataTable dt){
        if (dt == null || dt.Columns.Contains("khdm") == false) return;
        int j = dt.Rows.Count;
        for (int i = j - 1; i > -1; i--)
        {
            if (Convert.ToString(dt.Rows[i]["khdm"]).StartsWith("0000"))
            {
                dt.Rows.RemoveAt(i);
            }
        }
    }


    //构造查询销售情况的SQL  查询条件统一封装成JSON串        
    public void GetMDLSSQL(string filterJSON)
    {
        clsJsonHelper jo = clsJsonHelper.CreateJsonHelper(filterJSON);

        //添加筛选条件  
        string lx = Convert.ToString(jo.GetJsonValue("core/lx"));
        string dbstr = Convert.ToString(jo.GetJsonValue("core/dbstr"));     //用于确定数据源

        //添加筛选条件
        string filterStr = "", innerTables = "", _sql = "";

        //string mdb = @" inner join tlsoft.dbo.t_mdb md on m.gxid = md.khid AND a.mdid=md.mdid and md.ty=0 ";
        string khb = " inner join tlsoft.dbo.yx_t_khb kh on md.khid=kh.khid and kh.ty=0 ";
        string spdmb = " inner join tlsoft.dbo.yx_t_spdmb sp on a.sphh=sp.sphh ";
        string splbb = " inner join tlsoft.dbo.yx_t_splb lb on sp.splbid=lb.id ";

        string khid = Convert.ToString(jo.GetJsonValue("core/khid"));
        string kfbh = Convert.ToString(jo.GetJsonValue("filter/kfbh"));  //
        string lbid = Convert.ToString(jo.GetJsonValue("core/lbid"));//
        string sphh = Convert.ToString(jo.GetJsonValue("spsearch"));//
        string mdkhid = Convert.ToString(jo.GetJsonValue("core/mdkhid"));     //原先是mdid
        string ksrq = Convert.ToString(jo.GetJsonValue("filter/ksrq"));//
        string jsrq = Convert.ToString(jo.GetJsonValue("filter/jsrq"));//
        string khfl = Convert.ToString(jo.GetJsonValue("filter/khfl"));//.Split('-')[0];// 
        string zmdfl = "";
        if (khfl != "")
        {
            zmdfl = khfl.Split('-')[1];
            khfl = khfl.Split('-')[0];
        }

        int roleid = Convert.ToInt32(jo.GetJsonValue("auth/roleid"));//        
        string curkhid = Convert.ToString(jo.GetJsonValue("auth/curkhid"));// 

        string order_col = Convert.ToString(jo.GetJsonValue("order/colname"));//  排序列名
        string order_direc = Convert.ToString(jo.GetJsonValue("order/ordertype"));// 排序类型
        jo.Dispose();

        List<SqlParameter> paras = new List<SqlParameter>();
        //innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
        //innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
        string tempsql = @"SELECT a.id,a.khid,SUM(a.sl) AS djsl into #tempsl
			from zmd_v_lsdjmx a                        
            INNER JOIN yx_t_khgxb m on A.khid=m.gxid and m.ty=0 and a.rq>=convert(datetime,m.ksny+'01') and a.rq<=convert(datetime,m.jsny+'01')
            inner join t_mdb md on m.gxid = md.khid AND a.mdid=md.mdid and md.ty=0
            {0}    
            where a.djbs=1 {1}
            group by a.id,a.khid;";

        _sql = @"
            select a.mdid khid,md.mdmc khmc,m.myid, COUNT(DISTINCT CASE when tsl.djsl<>0 THEN a.id ELSE 0 end)-1 djs,sum(case when a.djlb in (-1,-2) then -1*a.sl else a.sl end) xssl,
            CONVERT(Decimal(18,2),sum(case when a.djlb < 0 then -1*a.je else a.je end)) xsje,
            CONVERT(Decimal(18,2),sum(case when a.djlb < 0 then -1*a.sl*a.bj else a.sl*a.bj end)) bjje          
            from zmd_v_lsdjmx a                        
            INNER JOIN yx_t_khgxb m on A.khid=m.gxid and m.ty=0 and a.rq>=convert(datetime,m.ksny+'01') and a.rq<=convert(datetime,m.jsny+'01')          
            inner join t_mdb md on m.gxid = md.khid AND a.mdid=md.mdid and md.ty=0  
            inner join #tempsl tsl on a.id=tsl.id and a.khid=tsl.khid    
            {0}
            where a.djbs=1 {1}
            group by a.mdid,md.mdmc,m.myid";


        if (roleid < 3)     //如果是店长及以下，则强制限定其门店范围
        {
            mdkhid = curkhid;
        }

        if (curkhid != "") khid = curkhid;      //如果已经指定了客户，则在这里直接强制指定。
        if (khid != "")
        {
            khid = getCcid(Convert.ToInt32(khid)) + "-%";
            //innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);      
            //innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
            filterStr = string.Concat(filterStr, " and m.ccid+'-' like @khid");
            paras.Add(new SqlParameter("@khid", khid));
        }
        else
        {
            filterStr = string.Concat(filterStr, " and m.ccid like '-1-%'");
        }

        if (ksrq != "" && jsrq != "")
        {
            //filterStr = string.Concat(filterStr, " and a.rq>=@ksrq and a.rq<dateadd(day,1,@jsrq)");
            //paras.Add(new SqlParameter("@ksrq", Convert.ToDateTime(ksrq)));
            //paras.Add(new SqlParameter("@jsrq", Convert.ToDateTime(jsrq)));
            //改用时间直接拼接，会提升查询速度
            filterStr = string.Concat(filterStr, string.Format(" and a.rq>='{0}' and a.rq<dateadd(day,1,'{1}')"
                , Convert.ToDateTime(ksrq).ToString("yyyy-MM-dd"), Convert.ToDateTime(jsrq).ToString("yyyy-MM-dd")));
        }

        if (mdkhid != "")
        {
            filterStr = string.Concat(filterStr, " and a.khid=@mdkhid");
            paras.Add(new SqlParameter("@mdkhid", mdkhid));
        }

        if (kfbh != "")
        {
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

        if (sphh != "")
        {
            filterStr = string.Concat(filterStr, " and a.sphh LIKE @sphh + '%' ");
            paras.Add(new SqlParameter("@sphh", sphh));
        }

        string SqlMygskhfl = "";
        if (khfl != "")
        {
            SqlMygskhfl = " AND K.khfl = @khfl ";
            paras.Add(new SqlParameter("@khfl", khfl));
        }
        if (zmdfl != "")
        {
            //innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
            //innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
            filterStr = string.Concat(filterStr, " and m.khfl LIKE @zmdfl ");
            paras.Add(new SqlParameter("@zmdfl", zmdfl));
        }
        _sql = string.Format(_sql, innerTables, filterStr);
       tempsql=string.Format(tempsql, innerTables, filterStr);

        //clsLocalLoger.WriteInfo("khid=" + khid);

        if (string.IsNullOrEmpty(khid))
        {
            _sql = string.Concat(@"SELECT T.myid khid,K.khmc khmc,K.khjc,K.khdm,SUM(djs) djs,SUM(xssl) xssl,SUM(xsje) xsje,SUM(bjje) bjje FROM (", _sql
                        , @") AS T INNER JOIN yx_t_khb K ON T.myid = K.khid 
                                    WHERE K.ssid = 1 AND K.ty = 0 " ,SqlMygskhfl , @"
                                    GROUP BY T.myid,K.khmc,K.khjc,K.khdm");
        }

        //WriteLog(_sql + "\r\n" + filterJSON); 
        clsLocalLoger.WriteInfo("_sql=" + _sql);

        _sql = string.Concat(tempsql, _sql, ";DROP TABLE #tempsl;");


        // clsLocalLoger.Log(_sql);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(LSDBConstr))
        {
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(_sql, paras, out dt);
            if (errinfo != "")
            {
                LeeWriteLog("[零售综合分析]查询出现异常。错误：" + errinfo);
                clsSharedHelper.WriteErrorInfo("网络故障！请稍后重试！");
                return;
            }

            RemoveMyData(ref dt);

            //计算 客单量  客单价 平均折扣
            dt.Columns.Add("kdl", typeof(decimal), "");
            dt.Columns.Add("kdj", typeof(int), "");
            dt.Columns.Add("pjzk", typeof(decimal), "");
            foreach (DataRow dr in dt.Rows)
            {
                if (DBNull.Value == dr["xssl"] || Convert.ToInt32(dr["xssl"]) == 0)
                {
                    dr["kdl"] = 0; dr["kdj"] = 0;
                }
                else
                {
                    dr["kdl"] = Convert.ToDecimal(Math.Round(Convert.ToInt32(dr["xssl"]) * 1.00 / Convert.ToInt32(dr["djs"]), 1));
                    dr["kdj"] = Convert.ToInt32(Convert.ToInt32(dr["xsje"]) / Convert.ToInt32(dr["djs"]));
                }

                if (DBNull.Value == dr["bjje"] || Convert.ToInt32(dr["bjje"]) == 0) dr["pjzk"] = 0;
                else dr["pjzk"] = Convert.ToDecimal(Math.Round(Convert.ToInt32(dr["xsje"]) * 10.0 / Convert.ToInt32(dr["bjje"]), 2));
            }
            //计算合计值 
            object objSumDjs = dt.Compute("SUM(djs)", "");
            object objSumXssl = dt.Compute("SUM(xssl)", "");
            object objSumXsje = dt.Compute("SUM(xsje)", "");
            object objSumBjje = dt.Compute("SUM(bjje)", "");
            int SumDjs = objSumDjs == DBNull.Value ? 0 : Convert.ToInt32(objSumDjs);
            long SumXssl = objSumXssl == DBNull.Value ? 0 : Convert.ToInt64(objSumXssl);
            long SumXsje = objSumXsje == DBNull.Value ? 0 : Convert.ToInt64(objSumXsje);
            long SumBjje = objSumBjje == DBNull.Value ? 0 : Convert.ToInt64(objSumBjje);
            decimal avgKdl = SumDjs == 0 ? 0 : Convert.ToDecimal(Math.Round(SumXssl * 1.0 / SumDjs, 1));
            long avgKdj = SumDjs == 0 ? 0 : SumXsje / SumDjs;
            decimal avgPjzk = SumBjje == 0 ? 0 : Convert.ToDecimal(Math.Round(SumXsje * 10.0 / SumBjje, 2));

            string JsonAdd = @"""sumXssl"":""{0}"",""sumXsje"":""{1}"",""avgKdl"":""{2}"",""avgKdj"":""{3}"",""avgPjzk"":""{4}"",";
            JsonAdd = string.Format(JsonAdd, SumXssl, SumXsje, avgKdl, avgKdj, avgPjzk);
            //计算合计值完毕                     
            dt.Columns.Remove("djs");
            dt.Columns.Remove("bjje");
            if (order_col != "") SetOrder(ref dt, order_col, order_direc);       //设置排序输出   

            string outJson = JsonHelp.dataset2json(dt);
            outJson = outJson.Insert(1, JsonAdd);

            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.WriteInfo(outJson);
        }
    }

    private string getCcid(int khid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(LSDBConstr))
        {
            string strSQL = string.Concat("SELECT TOP 1 ccid FROM yx_t_khb WHERE khid =", khid);
            object objCcid = "";
            string strInfo = dal.ExecuteQueryFast(strSQL, out objCcid);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError("【LSZHFXCore】CCID获取失败！错误：" + khid.ToString());
                throw new Exception("网络繁忙，请稍候重试！");
            }

            return Convert.ToString(objCcid);
        }

    }


    //查询不同贸易公司所使用的数据库    
    private string GetDBConstr(int khid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ZBDBConstr)) {
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

    //写日志
    private void WriteLog(string strText)
    {
        clsLocalLoger.WriteInfo(string.Concat("【零售综合分析】", strText));
    }

    //写日志
    private void LeeWriteLog(string strText)
    {
        clsLocalLoger.WriteError(strText);
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
