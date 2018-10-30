<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>

<!DOCTYPE html>
<script runat="server">
    private string ZBDBConstr = "server='192.168.35.10';database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
    private string LSDBConstr = "server='192.168.35.32';database=tlsoft;uid=lllogin;pwd=rw1894tla";
    private string FXDBConstr = "server='192.168.35.11';database=FXDB;uid=ABEASD14AD;pwd=+AuDkDew";
    private string ERPDBConstr = "server='192.168.35.19';database=ERPDB;uid=ABEASD14AD;pwd=+AuDkDew";

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
        string dbstr = Convert.ToString(jo.GetJsonValue("core/dbstr"));     //用于确定数据源
         
        //添加筛选条件
        string filterStr = "", innerTables = "";
        //string khb = " inner join yx_t_khb kh on a.khid=kh.khid and kh.ty=0 ";
        string spdmb = " inner join yx_t_spdmb sp on b.sphh=sp.sphh ";
        string splbb = " inner join yx_t_splb lb on sp.splbid=lb.id ";

        string khid = Convert.ToString(jo.GetJsonValue("core/khid"));
        string kfbh = Convert.ToString(jo.GetJsonValue("filter/kfbh"));  //
        string lbid = Convert.ToString(jo.GetJsonValue("core/lbid"));//
        string sphh = Convert.ToString(jo.GetJsonValue("spsearch"));//
        string mdkhid = Convert.ToString(jo.GetJsonValue("core/mdkhid"));     //原先是mdid
        string ksrq = Convert.ToString(jo.GetJsonValue("filter/ksrq"));//
        string jsrq = Convert.ToString(jo.GetJsonValue("filter/jsrq"));//
        string khfl = Convert.ToString(jo.GetJsonValue("filter/khfl"));// 
        int roleid = Convert.ToInt32(jo.GetJsonValue("auth/roleid"));// 
        string curkhid = Convert.ToString(jo.GetJsonValue("auth/curkhid"));// 
        
        string order_col = Convert.ToString(jo.GetJsonValue("order/colname"));//  排序列名
        string order_direc = Convert.ToString(jo.GetJsonValue("order/ordertype"));// 排序类型
         
        jo.Dispose();
        
        //验证参数合法性
        if (CheckCurkhid(curkhid) == false) { clsSharedHelper.WriteErrorInfo("参数不合法！"); return; }
        
        List<SqlParameter> paras = new List<SqlParameter>();

        if (ksrq != "" && jsrq != "")
        {
            filterStr = string.Concat(filterStr, " and a.rq BETWEEN @ksrq and @jsrq ");
            paras.Add(new SqlParameter("@ksrq", Convert.ToDateTime(ksrq)));
            paras.Add(new SqlParameter("@jsrq", Convert.ToDateTime(jsrq).AddDays(1)));
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
            filterStr = string.Concat(filterStr, " and b.sphh=@sphh");
            paras.Add(new SqlParameter("@sphh", sphh));
        }
        if (khfl != "" && lx == "kh")
        {
            filterStr = string.Concat(filterStr, " and kh.khfl=@khfl");
            paras.Add(new SqlParameter("@khfl", khfl));
        }
         
        if (roleid < 3)     //如果是店长及以下，则强制限定其门店范围
        {
            mdkhid = curkhid;
        }
        
        if (mdkhid != "")       //如果有限定门店，则无需计算客户ID
        {
            filterStr = string.Concat(filterStr, " and a.khid=@mdkhid ");
            paras.Add(new SqlParameter("@mdkhid", mdkhid));
        }
        else
        {
            if (curkhid != "") khid = curkhid;//有注入风险。可事先检查 curkhid 逗号分隔符的每一项是否为整数即可消除风险。

            if (khid != "")
            {
                if (lx == "kh") filterStr = string.Concat(filterStr, " and a.khid=@khid ");
                else filterStr = string.Concat(filterStr, " and a.tzid=@khid ");
                
                paras.Add(new SqlParameter("@khid", khid));
            } 
        } 
          
        //定位数据源
        string DBConn = "";
        if (mdkhid != "") DBConn = GetDBConstr(Convert.ToInt32(mdkhid));
        else if (khid != "" && lx != "kh") DBConn = GetDBConstr(Convert.ToInt32(khid));
        else DBConn = ZBDBConstr; 
        clsLocalLoger.WriteDebug(DBConn);

        //141,142采购 等价于  上一级别的111,112销售        
        string str_sql = @" select {0},0 - sum(b.sl * DJLB.kc) cgsl
                            from yx_t_kcdjb a
                            inner join yx_t_kcdjmx b on a.id=b.id                                
                            INNER JOIN t_djlxb DJLB ON a.djlx = DJLB.dm
                            INNER JOIN yx_t_khb kh ON a.khid=kh.khid and kh.ty=0 
                            {1}                                
                            WHERE a.djlx IN (111,112)  and a.shbs=1 and a.qrbs=1 and a.djbs=1 {3}
                            group by {2} ";

        switch (lx)
        {
            case "kh":           
                filterStr = string.Concat(filterStr, " and a.tzid=1 "); 
                str_sql = string.Format(str_sql, "convert(varchar(10),a.khid) khid,upper(kh.khdm) khdm,kh.khmc", innerTables, "a.khid,kh.khdm,kh.khmc", filterStr);
                break;
            case "md":
                str_sql = string.Format(str_sql, "a.khid,upper(kh.khdm) khdm,kh.khmc", innerTables, "a.khid,kh.khdm,kh.khmc", filterStr);
                break;
            case "lb":                               
                innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
                innerTables = string.Concat(innerTables.Replace(splbb, ""), splbb);
                str_sql = string.Format(str_sql, "lb.id lbid,lb.mc lbmc", innerTables, "lb.id,lb.mc", filterStr);
                break;
            case "sphh":
                innerTables = string.Concat(innerTables.Replace(spdmb, ""), spdmb);
                str_sql = string.Format(str_sql, "sp.sphh,sp.spmc", innerTables, "sp.sphh,sp.spmc", filterStr);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("未知请求类型！");
                return;
        }
                 
        using (LiLanzDALForXLM dal_dd = new LiLanzDALForXLM(DBConn)) {
            DataTable dt_cg, dt_ls;
            WriteLog(str_sql + "\r\n" + filterJSON);
            string errinfo = dal_dd.ExecuteQuerySecurity(str_sql,paras,out dt_cg);
            WriteLog("订单数据查询结束！" + DBConn);
             
            if (errinfo == "")
            {
                //查询零售数据
                dt_ls = GetLSSQL(filterJSON);
                dt_cg.PrimaryKey = new DataColumn[] { dt_cg.Columns[0] };
                dt_ls.PrimaryKey = new DataColumn[] { dt_ls.Columns[0] };
                dt_cg.Merge(dt_ls);
                 
                if (dt_cg.Rows.Count > 0)
                {
                    //计算完成率
                    double ddsl, lssl, percent;
                    dt_cg.Columns.Add("wcl", typeof(double));
                    for (int i = 0; i < dt_cg.Rows.Count; i++)
                    {
                        string _cgsl = Convert.ToString(dt_cg.Rows[i]["cgsl"]);
                        string _lssl = Convert.ToString(dt_cg.Rows[i]["xssl"]);
                        if (_cgsl == "" || _lssl == "" || _cgsl == "0" || _lssl == "0")
                            continue;
                        ddsl = Convert.ToInt32(_cgsl);
                        lssl = Convert.ToInt32(_lssl);
                        percent = Convert.ToDouble(lssl / ddsl);
                        dt_cg.Rows[i]["wcl"] = Math.Round(percent, 4) * 100;
                    }//end for
                     
                    if (order_col != "") SetOrder(ref dt_cg, order_col, order_direc);       //设置排序输出                                    
                    
                    //计算合计值
                    object objSumCgsl = dt_cg.Compute("SUM(cgsl)", "");
                    object objSumXssl = dt_cg.Compute("SUM(xssl)", "");
                    object objSumXsje = dt_cg.Compute("SUM(xsje)", "");
                    long SumCgsl = objSumCgsl == DBNull.Value ? 0 : Convert.ToInt64(objSumCgsl);
                    long SumXssl = objSumXssl == DBNull.Value ? 0 : Convert.ToInt64(objSumXssl);
                    long SumXsje = objSumXsje == DBNull.Value ? 0 : Convert.ToInt64(objSumXsje);
                    string strWcl = "";

                    if (SumCgsl == 0) strWcl = "-";
                    else strWcl = string.Format("{0:P1}", SumXssl * 1.0 / SumCgsl);
                    string JsonAdd = @"""sumCgsl"":""{0}"",""sumXssl"":""{1}"",""sumXsje"":""{2}"",""Wcl"":""{3}"",";
                    JsonAdd = string.Format(JsonAdd, SumCgsl, SumXssl, SumXsje, strWcl);
                    //计算合计值完毕                     
                                                                               
                    //如果数据量过大，则只输出x条 
                    int j = dt_cg.Rows.Count;
                    if (j > MaxDataCount)
                    {
                        for (int i = j-1; i >= MaxDataCount; i--)
                        {
                            dt_cg.Rows.RemoveAt(i);
                        }                                                
                    }
                    //删除多余数据
                     
                    string outJson = JsonHelp.dataset2json(dt_cg);
                    outJson = outJson.Insert(1, JsonAdd);

                    dt_ls.Clear(); dt_ls.Dispose();
                    dt_cg.Clear(); dt_cg.Dispose(); 

                    clsSharedHelper.WriteInfo(outJson);
                }
                else
                    clsSharedHelper.WriteInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }//end using
    }

    private void SetOrder(ref DataTable dt, string order_colName, string order_direc)
    {
        //排序  
        if (order_colName != "")
        {
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

        string mdb = " inner join t_mdb md on a.mdid=md.mdid and md.ty=0 ";
        string khb = " inner join yx_t_khb kh on md.khid=kh.khid and kh.ty=0 ";        
        string spdmb = " inner join yx_t_spdmb sp on a.sphh=sp.sphh ";
        string splbb = " inner join yx_t_splb lb on sp.splbid=lb.id "; 

        string khid = Convert.ToString(jo.GetJsonValue("core/khid"));
        string kfbh = Convert.ToString(jo.GetJsonValue("filter/kfbh"));  //
        string lbid = Convert.ToString(jo.GetJsonValue("core/lbid"));//
        string sphh = Convert.ToString(jo.GetJsonValue("spsearch"));//
        string mdkhid = Convert.ToString(jo.GetJsonValue("core/mdkhid"));     //原先是mdid
        string ksrq = Convert.ToString(jo.GetJsonValue("filter/ksrq"));//
        string jsrq = Convert.ToString(jo.GetJsonValue("filter/jsrq"));//
        string khfl = Convert.ToString(jo.GetJsonValue("filter/khfl"));// 
        int roleid = Convert.ToInt32(jo.GetJsonValue("auth/roleid"));//        
        string curkhid = Convert.ToString(jo.GetJsonValue("auth/curkhid"));// 

        jo.Dispose();
         
        List<SqlParameter> paras = new List<SqlParameter>();
        switch (lx)
        {
            case "kh":
                innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
                innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
                _sql = @"select substring(a.ccid0,0,charindex('-',a.ccid0)) khid,upper(kh.khdm) khdm,kh.khfl,kh.khmc,sum(a.sl) xssl,SUM(a.xsje) 'xsje'
                         from (
                           select a.khid,replace(kh.ccid,'-1-','')+'-' ccid0,a.djlb/abs(a.djlb)*sl sl,
                            (case when a.djlb in (-1,-2) then -1*a.je else a.je end) xsje          
                           from zmd_v_lsdjmx a                           
                           {0}
                           where a.djlb in (1,-1,2,-2) and a.djbs=1 {1}
                           ) a
                         inner join yx_t_khb kh on kh.khid=substring(a.ccid0,0,charindex('-',a.ccid0)) {2}
                         group by substring(a.ccid0,0,charindex('-',a.ccid0)),kh.khdm,kh.khfl,kh.khmc";
                break;
            case "md":                
                innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
                innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
                _sql = @"select a.khid,m.khmc,sum(case when a.djlb in (-1,-2) then -1*a.sl else a.sl end) xssl,
                            sum(case when a.djlb in (-1,-2) then -1*a.je else a.je end) xsje          
                          from zmd_v_lsdjmx a    
                          inner join yx_t_khb m on a.khid=m.khid                      
                          {0}
                          where a.djlb in (1,-1,2,-2) and a.djbs=1 {1}
                          group by a.khid,m.khmc";
                break;
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

        if (roleid < 3)     //如果是店长及以下，则强制限定其门店范围
        {
            mdkhid = curkhid;
        }

        if (curkhid != "") khid = curkhid;      //如果已经指定了客户，则在这里直接强制指定。
        if (khid != "")
        {
            khid = "-1-" + khid + "-%";
            innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
            innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
            filterStr = string.Concat(filterStr, " and kh.ccid+'-' like @khid");
            paras.Add(new SqlParameter("@khid", khid));
        }


        if (khfl != "" && lx == "kh")
        {
            innerTables = string.Concat(innerTables.Replace(mdb, ""), mdb);
            innerTables = string.Concat(innerTables.Replace(khb, ""), khb);
        }
         
        if (ksrq != "" && jsrq != "")
        {
            filterStr = string.Concat(filterStr, " and a.rq BETWEEN @ksrq and @jsrq");
            paras.Add(new SqlParameter("@ksrq", Convert.ToDateTime(ksrq)));
            paras.Add(new SqlParameter("@jsrq", Convert.ToDateTime(jsrq).AddDays(1)));
        }

        if (mdkhid != "")
        {
            filterStr = string.Concat(filterStr, " and a.khid=@mdkhid");
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
            filterStr = string.Concat(filterStr, " and a.sphh=@sphh");
            paras.Add(new SqlParameter("@sphh", sphh));
        }
        
        if (lx == "kh")
        {
            if (khfl != "")
            {
                _sql = string.Format(_sql, innerTables, filterStr, " and kh.khfl=@khfl");
                paras.Add(new SqlParameter("@khfl", khfl));
            }
            else
                _sql = string.Format(_sql, innerTables, filterStr, "");
        }
        else
            _sql = string.Format(_sql, innerTables, filterStr);

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(LSDBConstr))
        {
            DataTable dt;
            WriteLog(_sql + "\r\n" + filterJSON);
            string errinfo = dal.ExecuteQuerySecurity(_sql, paras, out dt);
            if (errinfo != "")
                LeeWriteLog(errinfo);
            WriteLog("销售数据查询结束！");
            if (errinfo != "")
                WriteLog(errinfo);
            return dt;
        }//end using                     
    }    
    
    
    //查询不同贸易公司所使用的数据库    
    private string GetDBConstr(int khid) { 
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
        clsLocalLoger.IsDebugMode = true;
        clsLocalLoger.WriteDebug(string.Concat("【薛灵敏调试】", strText));
    }

    //写日志
    private void LeeWriteLog(string strText)
    {
        String path = HttpContext.Current.Server.MapPath("logs/");
        if (!System.IO.Directory.Exists(System.IO.Path.GetDirectoryName(path)))
        {
            System.IO.Directory.CreateDirectory(path);
        }

        System.IO.StreamWriter writer = new System.IO.StreamWriter(path + DateTime.Now.ToString("yyyyMMdd") + ".log", true);
        string str;
        str = "【" + DateTime.Now.ToString() + "】" + "  " + strText;
        writer.WriteLine(str);
        writer.Close();
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
