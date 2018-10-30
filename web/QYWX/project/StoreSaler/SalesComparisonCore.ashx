<%@ WebHandler Language="C#" Class="SalesClerkCore" %>
using System;
using System.Web;
using nrWebClass;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;
using System.Threading;

public class SalesClerkCore : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    private string LSDBConstr = clsConfig.GetConfigValue("FXDBConStr");
    private string FXDBConstr = clsConfig.GetConfigValue("FXConStr");
    private string ERPDBConstr = clsConfig.GetConfigValue("ERPConStr");
    private string CX1Constr = clsConfig.GetConfigValue("CX1ConStr");
    private string CX2Constr = clsConfig.GetConfigValue("CX2ConStr");
    string OAConStr = clsConfig.GetConfigValue("OAConnStr"); 

    const string innerkhb = " INNER JOIN tlsoft.dbo.yx_t_khb kh ON a.khid=kh.khid AND kh.ty=0";
    const string innerspdmb = " INNER JOIN tlsoft.dbo.yx_t_spdmb sp on b.sphh=sp.sphh ";
    const string innersplb = " INNER JOIN tlsoft.dbo.yx_t_splb lb on sp.splbid=lb.id ";
    const string innerkhgxb = " INNER JOIN tlsoft.dbo.yx_t_khgxb m on A.khid=m.gxid and m.ty=0 and a.rq>=convert(datetime,m.ksny+'01') and a.rq<=convert(datetime,m.jsny+'01') ";
    const string innerkhbmy = "  INNER JOIN tlsoft.dbo.yx_t_khb kh ON m.myid = kh.khid AND kh.ty=0 AND kh.ssid = 1";
    const string innerkhbck = " INNER JOIN tlsoft.dbo.yx_t_khb kh ON a.tzid=kh.khid AND kh.ty=0 AND kh.ssid = 1";

    private bool IsZydkh = false;   //查询的curkhid是否为直营大客户    
    
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ClearHeaders();
        context.Response.AppendHeader("Access-Control-Allow-Origin", "*");
        string requestHeaders = context.Request.Headers["Access-Control-Request-Headers"];
        context.Response.AppendHeader("Access-Control-Allow-Headers", string.IsNullOrEmpty(requestHeaders) ? "*" : requestHeaders);
        context.Response.AppendHeader("Access-Control-Allow-Methods", "POST, GET,OPTIONS");
        
        context.Response.ContentType = "text/plain";
        string ctrl = Convert.ToString(context.Request.Params["ctrl"]); 
        switch (ctrl)
        {
            case "GetDZData":
                getData(context);
                break; 
            default:                
                break;
        } 
    }
    public void getData(HttpContext context)
    {
        string filterJSON = Convert.ToString(context.Request.Params["filters"]); 
        using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(filterJSON))
        {
            string spsearch = jh.GetJsonValue("spsearch");
            string curkhid = jh.GetJsonValue("auth/curkhid");
            string lx = jh.GetJsonValue("core/lx");
            string khid = jh.GetJsonValue("core/khid");
            string lbid = jh.GetJsonValue("core/lbid");
            string cxtj = jh.GetJsonValue("filter/cxtj");
            string thksrq = jh.GetJsonValue("filter/thksrq");
            string thjsrq = jh.GetJsonValue("filter/thjsrq");
            string xsksrq = jh.GetJsonValue("filter/xsksrq");
            string xsjsrq = jh.GetJsonValue("filter/xsjsrq");
            string kfbh = jh.GetJsonValue("filter/kfbh");
            string khlb = jh.GetJsonValue("filter/khlb");
            string zmdlb = jh.GetJsonValue("filter/zmdlb");

            string orderColName = jh.GetJsonValue("order/colname");
            string ordertype = jh.GetJsonValue("order/ordertype");

            List<string> innerList = new List<string>();

            string rt = "";
                        
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(LSDBConstr))
            {
                DataTable dt;
                DataTable dtDD,dtTH,dtCK,dtLS;

                if (string.IsNullOrEmpty(curkhid) == false)
                {
                    //如果被判断的门店是一个大客户，则只查主库
                    IsZydkh = IsZYDKH(curkhid);
                    if (IsZydkh == false) dal.ConnectionString = GetDBConstr(Convert.ToInt32(curkhid));
                }
                dtDD = LoadDDData(jh, dal); 
                dtTH = LoadTHData(jh, dal); 
                dal.ConnectionString = LSDBConstr; 
                dtCK = LoadCKData(jh, dal); 
                dal.ConnectionString = LSDBConstr;
                dtLS = LoadLSData(jh, dal); 

                dt = dtDD;
                List<string> lstCol = new List<string>();
                lstCol.Add("ths");
                MyMerge(ref dt, ref dtTH, lstCol); clsSharedHelper.DisponseDataTable(ref dtTH);
                lstCol.Clear(); lstCol.Add("cks");
                MyMerge(ref dt, ref dtCK, lstCol); clsSharedHelper.DisponseDataTable(ref dtCK);
                lstCol.Clear(); lstCol.Add("lss");
                MyMerge(ref dt, ref dtLS, lstCol); clsSharedHelper.DisponseDataTable(ref dtLS);
                                 
                dt.Columns.Add("kcs", typeof(int), "").DefaultValue = 0;
                dt.Columns.Add("dxl", typeof(decimal), "").DefaultValue = 0;
                dt.Columns.Add("sql", typeof(decimal), "").DefaultValue = 0;
                
                //提货数量减去出库数量，得到库存数
                foreach (DataRow dr in dt.Rows)
                {
                    dr["kcs"] = getValue(dr["ths"]) - getValue(dr["lss"]);
                    if (getValue(dr["ths"]) == 0) dr["dxl"] = DBNull.Value;
                    else dr["dxl"] =  Convert.ToDecimal(Math.Round(getValue(dr["lss"]) * 100.0 / getValue(dr["ths"]),1));
                    if (getValue(dr["dds"]) == 0) dr["sql"] = DBNull.Value;
                    else dr["sql"] = Convert.ToDecimal(Math.Round(getValue(dr["lss"]) * 100.0 / getValue(dr["dds"]),1));
                }

                RemoveMyData(ref dt);
                SetOrder(ref dt, orderColName, ordertype);
                
                rt = JsonConvert.SerializeObject(dt);
                clsSharedHelper.DisponseDataTable(ref dt);
                
            }
            clsSharedHelper.WriteInfo(rt);
        } 
    }
    
    private int getValue(object obj){
        if (DBNull.Value.Equals(obj)) return 0;
        else return Convert.ToInt32(obj);
            
    }
       
        
        

    #region 读取数据

    private DataTable LoadDDData(clsJsonHelper jh,LiLanzDALForXLM dal)
    {
        DataTable dt = null;
        string spsearch = jh.GetJsonValue("spsearch");
        string curkhid = jh.GetJsonValue("auth/curkhid");
        string lx = jh.GetJsonValue("core/lx");
        string khid = jh.GetJsonValue("core/khid");
        string lbid = jh.GetJsonValue("core/lbid");
        string cxtj = jh.GetJsonValue("filter/cxtj");
        string thksrq = jh.GetJsonValue("filter/thksrq");
        string thjsrq = jh.GetJsonValue("filter/thjsrq");
        //string xsksrq = jh.GetJsonValue("filter/xsksrq");
        //string xsjsrq = jh.GetJsonValue("filter/xsjsrq");
        string kfbh = jh.GetJsonValue("filter/kfbh");
        string khlb = jh.GetJsonValue("filter/khlb");
        string zmdlb = jh.GetJsonValue("filter/zmdlb");

        List<string> lstInner = new List<string>();
        List<SqlParameter> lstParams = new List<SqlParameter>();
        string GroupByStr = "";
        string InnerStr = "";
        string WhereStr = "";

        if (string.IsNullOrEmpty(curkhid) == false && string.IsNullOrEmpty(khid) == false)
        {
            curkhid = "";
        }
                
        switch (lx)
        {
            case "kh":
                GroupByStr = "kh.khid,kh.khdm,kh.khmc,kh.khjc";
                TryAddStr(lstInner, innerkhb);                
                break;
            case "lb":
                GroupByStr = "lb.id,lb.dm,lb.mc";
                TryAddStr(lstInner, innerspdmb);
                TryAddStr(lstInner, innersplb);
                break;
            case "sphh":
                GroupByStr = "sp.sphh,sp.spmc";
                TryAddStr(lstInner, innerspdmb);
                break;
        }
        if (string.IsNullOrEmpty(spsearch) == false)
        {
            TryAddStr(lstInner, innerspdmb);
            WhereStr = string.Concat(WhereStr, " AND b.sphh = @sphh");
            lstParams.Add(new SqlParameter("@sphh", spsearch));
        }
        if (string.IsNullOrEmpty(curkhid) == false)
        {
            TryAddStr(lstInner, innerkhb);
            if (IsZydkh) WhereStr = string.Concat(WhereStr, " AND a.khid = @curkhid ");
            else WhereStr = string.Concat(WhereStr, " AND a.tzid = @curkhid ");
            lstParams.Add(new SqlParameter("@curkhid", curkhid)); 
        }
        if (string.IsNullOrEmpty(khid) == false)
        {
            TryAddStr(lstInner, innerkhb);
            WhereStr = string.Concat(WhereStr, " AND (a.khid = @khid OR a.zmdid = @khid) ");
            lstParams.Add(new SqlParameter("@khid", khid));
        }
        if (string.IsNullOrEmpty(lbid) == false)
        {
            TryAddStr(lstInner, innersplb);
            WhereStr = string.Concat(WhereStr, " AND lb.id = @lbid ");
            lstParams.Add(new SqlParameter("@lbid", lbid));
        }
        if (cxtj == "date")
        {
            WhereStr = string.Concat(WhereStr, " AND a.rq>=@ksrq AND a.rq<dateadd(day,1,@jsrq) ");
            lstParams.Add(new SqlParameter("@ksrq", thksrq));
            lstParams.Add(new SqlParameter("@jsrq", thjsrq));
        }
        else
        {
            TryAddStr(lstInner, innerspdmb);
            WhereStr = string.Concat(WhereStr, " AND sp.kfbh = @kfbh ");
            lstParams.Add(new SqlParameter("@kfbh", kfbh));
            //用开发编号限定日期
            if (kfbh.Length > 4)
            {
                DateTime dtkssj = getKssjBykfbh(kfbh);
                WhereStr = string.Concat(WhereStr, " AND a.rq>=@ksrq ");
                lstParams.Add(new SqlParameter("@ksrq", dtkssj));
            }
        }
        if (string.IsNullOrEmpty(khlb) == false && string.IsNullOrEmpty(curkhid) == true)
        {
            TryAddStr(lstInner, innerkhb);
            WhereStr = string.Concat(WhereStr, " AND kh.khfl = @khlb ");
            lstParams.Add(new SqlParameter("@khlb", khlb));
        }
        if (string.IsNullOrEmpty(zmdlb) == false && string.IsNullOrEmpty(curkhid) == false)
        {
            TryAddStr(lstInner, innerkhb);
            WhereStr = string.Concat(WhereStr, " AND kh.khfl = @zmdlb ");
            lstParams.Add(new SqlParameter("@zmdlb", zmdlb));
        }
        InnerStr = string.Join(" ", lstInner.ToArray());
        lstInner.Clear(); 
        
        string strSQL = string.Concat(@"--订单数:如果未传入查询目标curkhid则查主库，否则查对应的查询库
                    SELECT ", GroupByStr, @" ,SUM(b.sl) dds
                         FROM YX_t_dddjb a INNER JOIN yx_t_dddjmx b ON a.id = b.id ",
                                     InnerStr, @"
                         WHERE A.djlx = 201 AND a.shbs=1 AND a.qrbs=1 AND a.djbs=1	--201销售订单 
                           " ,WhereStr , @"
	                        GROUP BY ", GroupByStr);
                             
        string errInfo = dal.ExecuteQuerySecurity(strSQL,lstParams, out dt);

        //clsLocalLoger.WriteInfo("1 Dal.Conn=" + dal.ConnectionString);
        //clsLocalLoger.WriteInfo("strSQL=" + strSQL);
        if (errInfo != "")
        {
            clsLocalLoger.WriteError(string.Concat("[提货销售对照分析]订单查询失败！错误：", errInfo, " SQL=", strSQL));
            clsSharedHelper.WriteErrorInfo("服务器繁忙，暂时无法查询订单数据！");
            return null;
        }
        dt.PrimaryKey = new DataColumn[] { dt.Columns[0] };
        return dt;
    }
    
    private DataTable LoadTHData(clsJsonHelper jh, LiLanzDALForXLM dal)
    {
        DataTable dt = null;
        string spsearch = jh.GetJsonValue("spsearch");
        string curkhid = jh.GetJsonValue("auth/curkhid");
        string lx = jh.GetJsonValue("core/lx");
        string khid = jh.GetJsonValue("core/khid");
        string lbid = jh.GetJsonValue("core/lbid");
        string cxtj = jh.GetJsonValue("filter/cxtj");
        string thksrq = jh.GetJsonValue("filter/thksrq");
        string thjsrq = jh.GetJsonValue("filter/thjsrq");
        //string xsksrq = jh.GetJsonValue("filter/xsksrq");
        //string xsjsrq = jh.GetJsonValue("filter/xsjsrq");
        string kfbh = jh.GetJsonValue("filter/kfbh");
        string khlb = jh.GetJsonValue("filter/khlb");
        string zmdlb = jh.GetJsonValue("filter/zmdlb");

        List<string> lstInner = new List<string>();
        List<SqlParameter> lstParams = new List<SqlParameter>();
        string GroupByStr = "";
        string InnerStr = "";
        string WhereStr = "";

        if (string.IsNullOrEmpty(curkhid) == false && string.IsNullOrEmpty(khid) == false)
        {
            curkhid = "";
        }

        switch (lx)
        {
            case "kh":
                GroupByStr = "kh.khid,kh.khdm,kh.khmc,kh.khjc";
                TryAddStr(lstInner, innerkhb);
                break;
            case "lb":
                GroupByStr = "lb.id,lb.dm,lb.mc";
                TryAddStr(lstInner, innerspdmb);
                TryAddStr(lstInner, innersplb);
                break;
            case "sphh":
                GroupByStr = "sp.sphh,sp.spmc";
                TryAddStr(lstInner, innerspdmb);
                break;
        }
        if (string.IsNullOrEmpty(spsearch) == false)
        {
            TryAddStr(lstInner, innerspdmb);
            WhereStr = string.Concat(WhereStr, " AND b.sphh = @sphh");
            lstParams.Add(new SqlParameter("@sphh", spsearch));
        }
        if (string.IsNullOrEmpty(curkhid) == false)
        {
            TryAddStr(lstInner, innerkhb);
            if (IsZydkh) WhereStr = string.Concat(WhereStr, " AND a.khid = @curkhid ");
            else WhereStr = string.Concat(WhereStr, " AND a.tzid = @curkhid ");
            lstParams.Add(new SqlParameter("@curkhid", curkhid));
        }
        if (string.IsNullOrEmpty(khid) == false)
        {
            TryAddStr(lstInner, innerkhb);
            WhereStr = string.Concat(WhereStr, " AND a.khid = @khid ");
            lstParams.Add(new SqlParameter("@khid", khid));
        }
        if (string.IsNullOrEmpty(lbid) == false)
        {
            TryAddStr(lstInner, innersplb);
            WhereStr = string.Concat(WhereStr, " AND lb.id = @lbid ");
            lstParams.Add(new SqlParameter("@lbid", lbid));
        }
        if (cxtj == "date")
        {
            WhereStr = string.Concat(WhereStr, " AND a.rq>=@ksrq AND a.rq<dateadd(day,1,@jsrq) ");
            lstParams.Add(new SqlParameter("@ksrq", thksrq));
            lstParams.Add(new SqlParameter("@jsrq", thjsrq));
        }
        else
        {
            TryAddStr(lstInner, innerspdmb);
            WhereStr = string.Concat(WhereStr, " AND sp.kfbh = @kfbh ");
            lstParams.Add(new SqlParameter("@kfbh", kfbh));
            //用开发编号限定日期
            if (kfbh.Length > 4)
            {
                DateTime dtkssj = getKssjBykfbh(kfbh);
                WhereStr = string.Concat(WhereStr, " AND a.rq>=@ksrq ");
                lstParams.Add(new SqlParameter("@ksrq", dtkssj));
            }
        }
        if (string.IsNullOrEmpty(khlb) == false && string.IsNullOrEmpty(curkhid) == true)
        {
            TryAddStr(lstInner, innerkhb);
            WhereStr = string.Concat(WhereStr, " AND kh.khfl = @khlb ");
            lstParams.Add(new SqlParameter("@khlb", khlb));
        }
        if (string.IsNullOrEmpty(zmdlb) == false && string.IsNullOrEmpty(curkhid) == false)
        {
            TryAddStr(lstInner, innerkhb);
            WhereStr = string.Concat(WhereStr, " AND kh.khfl = @zmdlb ");
            lstParams.Add(new SqlParameter("@zmdlb", zmdlb));
        }
        InnerStr = string.Join(" ", lstInner.ToArray());
        lstInner.Clear();

//        string strSQL = string.Concat(@"--提货数:如果未传入查询目标curkhid则查主库，否则查对应的查询库
//                    SELECT ", GroupByStr, @" ,0 - SUM(b.sl * DJLB.kc) ths
//                         	FROM yx_t_kcdjb a INNER JOIN yx_t_kcdjmx b ON a.id = b.id
//	                        INNER JOIN tlsoft.dbo.t_djlxb DJLB ON a.djlx = DJLB.dm ",
//                                     InnerStr, @"
//                         WHERE a.djlx IN (111,112)  AND a.shbs=1 AND a.qrbs=1 AND a.djbs=1		--111销售出库单  112销售退货入库单
//                           ", WhereStr, @"
//	                        GROUP BY ", GroupByStr);

        string strSQL = string.Concat(@"--提货数:如果未传入查询目标curkhid则查主库，否则查对应的查询库
                    SELECT ", GroupByStr, @" ,0 - SUM(b.sl * DJLB.kc) ths
                         	FROM yx_t_kcdjb a INNER JOIN yx_t_kcdjmx b ON a.id = b.id
	                        INNER JOIN tlsoft.dbo.t_djlxb DJLB ON a.djlx = DJLB.dm ",
                                     InnerStr, @"
                         WHERE (DJLB.kzx1=8 or DJLB.lsjxc=6) AND a.shbs=1 AND a.qrbs=1 AND a.djbs=1		--111销售出库单  112销售退货入库单
                           ", WhereStr, @"
	                        GROUP BY ", GroupByStr);

        //clsLocalLoger.WriteInfo("2 Dal.Conn=" + dal.ConnectionString);
        //clsLocalLoger.WriteInfo("strSQL=" + strSQL);
        
        string errInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
        if (errInfo != "")
        {
            clsLocalLoger.WriteError(string.Concat("[提货销售对照分析]提货查询失败！错误：", errInfo, " SQL=", strSQL));
            clsSharedHelper.WriteErrorInfo("服务器繁忙，暂时无法查询提货数据！");
            return null;
        }
        dt.PrimaryKey = new DataColumn[] { dt.Columns[0] };
        return dt;
    }



    private DataTable LoadCKData(clsJsonHelper jh, LiLanzDALForXLM dal)
    {
        string curkhid = jh.GetJsonValue("auth/curkhid");
        string khid = jh.GetJsonValue("core/khid");
        string DBConn = "";

        if (IsZydkh) DBConn = LSDBConstr;
        else if (string.IsNullOrEmpty(khid) == false) DBConn = GetDBConstr(Convert.ToInt32(khid));
        else if (string.IsNullOrEmpty(curkhid) == false) DBConn = GetDBConstr(Convert.ToInt32(curkhid));
 
        if (DBConn != "") return LoadCKData(jh, dal, DBConn);
        else
        {
            DataTable dt1 = LoadCKData(jh, dal, CX1Constr);
            DataTable dt2 = LoadCKData(jh, dal, CX2Constr);
            //DataTable dt3 = LoadCKData(jh, dal, LSDBConstr);
            List<string> lstCol = new List<string>();
            lstCol.Add("cks");
            MySum(ref dt1, ref dt2, lstCol);
            //MySum(ref dt1, ref dt3, lstCol);
            clsSharedHelper.DisponseDataTable(ref dt2);
            //clsSharedHelper.DisponseDataTable(ref dt3);

            return dt1;
        } 
    }
    private DataTable LoadCKData(clsJsonHelper jh, LiLanzDALForXLM dal, string strConn)
    {
        dal.ConnectionString = strConn;
        
        DataTable dt = null;
        string spsearch = jh.GetJsonValue("spsearch");
        string curkhid = jh.GetJsonValue("auth/curkhid");
        string lx = jh.GetJsonValue("core/lx");
        string khid = jh.GetJsonValue("core/khid");
        string lbid = jh.GetJsonValue("core/lbid");
        string cxtj = jh.GetJsonValue("filter/cxtj");
        //string thksrq = jh.GetJsonValue("filter/thksrq");
        //string thjsrq = jh.GetJsonValue("filter/thjsrq");
        string xsksrq = jh.GetJsonValue("filter/xsksrq");
        string xsjsrq = jh.GetJsonValue("filter/xsjsrq");
        string kfbh = jh.GetJsonValue("filter/kfbh");
        string khlb = jh.GetJsonValue("filter/khlb");
        string zmdlb = jh.GetJsonValue("filter/zmdlb");

        List<string> lstInner = new List<string>();
        List<SqlParameter> lstParams = new List<SqlParameter>(); 
        string GroupByStr = "";
        string InnerStr = "";
        string WhereStr = "";
        bool IsFindStoreMode = false;//是否为查店模式
        
        if (string.IsNullOrEmpty(curkhid) == false && string.IsNullOrEmpty(khid) == false)
        {
            curkhid = "";
            IsFindStoreMode = true;
        }

        switch (lx)
        {
            case "kh": 
                GroupByStr = "kh.khid,kh.khdm,kh.khmc,kh.khjc";
                if (curkhid == "") TryAddStr(lstInner, innerkhbck);
                else TryAddStr(lstInner, innerkhb);           
                break;
            case "lb":
                GroupByStr = "lb.id,lb.dm,lb.mc"; 
                TryAddStr(lstInner, innerspdmb);
                TryAddStr(lstInner, innersplb);
                break;
            case "sphh":
                GroupByStr = "sp.sphh,sp.spmc"; 
                TryAddStr(lstInner, innerspdmb);
                break;
        }
        if (string.IsNullOrEmpty(spsearch) == false)
        {
            TryAddStr(lstInner, innerspdmb);
            WhereStr = string.Concat(WhereStr, " AND b.sphh = @sphh");
            lstParams.Add(new SqlParameter("@sphh", spsearch));
        }
        if (string.IsNullOrEmpty(curkhid) == false)
        {
            TryAddStr(lstInner, innerkhb);
            //if (IsZydkh) WhereStr = string.Concat(WhereStr, " AND a.khid = @curkhid ");
            //else 
            WhereStr = string.Concat(WhereStr, " AND a.tzid = @curkhid ");
            lstParams.Add(new SqlParameter("@curkhid", curkhid)); 
        }
        if (string.IsNullOrEmpty(khid) == false)
        {
            TryAddStr(lstInner, innerkhbck);
            if (IsFindStoreMode) WhereStr = string.Concat(WhereStr, " AND a.khid = @khid ");
            else WhereStr = string.Concat(WhereStr, " AND a.tzid = @khid ");
            lstParams.Add(new SqlParameter("@khid", khid)); 
        }
        if (string.IsNullOrEmpty(lbid) == false)
        {
            TryAddStr(lstInner, innersplb);
            WhereStr = string.Concat(WhereStr, " AND lb.id = @lbid ");
            lstParams.Add(new SqlParameter("@lbid", lbid));
        }
        if (cxtj == "date")
        {
            WhereStr = string.Concat(WhereStr, " AND a.rq>=@ksrq AND a.rq<dateadd(day,1,@jsrq) ");
            lstParams.Add(new SqlParameter("@ksrq", xsksrq));
            lstParams.Add(new SqlParameter("@jsrq", xsjsrq));
        }
        else
        {
            TryAddStr(lstInner, innerspdmb);
            WhereStr = string.Concat(WhereStr, " AND sp.kfbh = @kfbh ");
            lstParams.Add(new SqlParameter("@kfbh", kfbh));
            //用开发编号限定日期
            if (kfbh.Length > 4)
            {
                DateTime dtkssj = getKssjBykfbh(kfbh); 
                WhereStr = string.Concat(WhereStr, " AND a.rq>=@ksrq ");
                lstParams.Add(new SqlParameter("@ksrq", dtkssj)); 
            }
        }
        if (string.IsNullOrEmpty(khlb) == false && curkhid == "")
        {
            WhereStr = string.Concat(WhereStr, " AND kh.khfl = @khlb ");
            lstParams.Add(new SqlParameter("@khlb", khlb));
        }
        if (string.IsNullOrEmpty(zmdlb) == false && curkhid != "")
        {
            WhereStr = string.Concat(WhereStr, " AND kh.khfl LIKE @zmdlb ");
            lstParams.Add(new SqlParameter("@zmdlb", zmdlb));
        }
        InnerStr = string.Join(" ", lstInner.ToArray());
        lstInner.Clear();
                
        string strSQL = string.Concat(@"--出库数：必须要到对应库搜索。如果未传入查询目标curkhid则查两个分库，否则查对应的查询库
                        SELECT ", GroupByStr, @",0 - SUM(b.sl * DJLB.kc) cks
                       	FROM dbo.yx_t_kcdjb a INNER JOIN dbo.yx_t_kcdjmx b ON a.id = b.id
	                    INNER JOIN tlsoft.dbo.t_djlxb DJLB ON a.djlx = DJLB.dm ",
                                     InnerStr, @"
                         WHERE a.djlx IN (111,112)  AND a.shbs=1 AND a.qrbs=1 AND a.djbs=1		--111销售出库单  112销售退货入库单
                           ", WhereStr, @"
	                        GROUP BY ", GroupByStr);

        clsLocalLoger.WriteInfo("3Dal.Conn=" + dal.ConnectionString);
        clsLocalLoger.WriteInfo("strSQL=" + strSQL);
                  
        string errInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
        if (errInfo != "")
        {
            clsLocalLoger.WriteError(string.Concat("[提货销售对照分析]出库查询失败！错误：", errInfo, " SQL=", strSQL));
            clsSharedHelper.WriteErrorInfo("服务器繁忙，暂时无法查询出库数据！");
            return null;
        }

        //clsLocalLoger.WriteInfo(dal.DataTableToXML(dt, "dt"));
        
        dt.PrimaryKey = new DataColumn[] { dt.Columns[0] };
        return dt;
    }


    private DataTable LoadLSData(clsJsonHelper jh, LiLanzDALForXLM dal)
    { 
        string curkhid = jh.GetJsonValue("auth/curkhid");
        string khid = jh.GetJsonValue("core/khid");
        string DBConn = "";

        if (string.IsNullOrEmpty(khid) == false) DBConn = GetDBConstr(Convert.ToInt32(khid));
        else if (string.IsNullOrEmpty(curkhid) == false) DBConn = GetDBConstr(Convert.ToInt32(curkhid));

        if (DBConn != "") return LoadLSData(jh, dal, DBConn);
        else
        {
            DataTable dt1 = LoadLSData(jh, dal, CX1Constr);
            DataTable dt2 = LoadLSData(jh, dal, CX2Constr);
            List<string> lstCol = new List<string>();
            lstCol.Add("lss");
            MySum(ref dt1, ref dt2, lstCol);
            clsSharedHelper.DisponseDataTable(ref dt2);

            return dt1;
        }
    }
    


    private DataTable LoadLSData(clsJsonHelper jh, LiLanzDALForXLM dal,string strConn)
    {
        dal.ConnectionString = strConn;
        
        DataTable dt = null;
        string spsearch = jh.GetJsonValue("spsearch");
        string curkhid = jh.GetJsonValue("auth/curkhid");
        string lx = jh.GetJsonValue("core/lx");
        string khid = jh.GetJsonValue("core/khid");
        string lbid = jh.GetJsonValue("core/lbid");
        string cxtj = jh.GetJsonValue("filter/cxtj");
        //string thksrq = jh.GetJsonValue("filter/thksrq");
        //string thjsrq = jh.GetJsonValue("filter/thjsrq");
        string xsksrq = jh.GetJsonValue("filter/xsksrq");
        string xsjsrq = jh.GetJsonValue("filter/xsjsrq");
        string kfbh = jh.GetJsonValue("filter/kfbh");
        string khlb = jh.GetJsonValue("filter/khlb");
        string zmdlb = jh.GetJsonValue("filter/zmdlb");

        List<string> lstInner = new List<string>();
        List<SqlParameter> lstParams = new List<SqlParameter>(); 
        string SelectCols = "";
        string GroupByStr = "";
        string InnerStr = "";
        string WhereStr = "";
        bool IsFindStoreMode = false;//是否为查店模式
         
        if (string.IsNullOrEmpty(curkhid) == false && string.IsNullOrEmpty(khid) == false)
        {
            curkhid = "";
            IsFindStoreMode = true;            
        }

        switch (lx)
        {
            case "kh":
                if (curkhid == "")
                {
                    SelectCols = "kh.khid,kh.khdm,kh.khmc,kh.khjc";
                    GroupByStr = SelectCols;          
                    TryAddStr(lstInner, innerkhgxb);
                    TryAddStr(lstInner, innerkhbmy);
                }
                else
                {
                    SelectCols = "a.khid khid,m.gxdm khdm,m.gxmc khmc,m.gxmc khjc";
                    GroupByStr = "a.khid,m.gxdm,m.gxmc";          
                    TryAddStr(lstInner, innerkhgxb); 
                }
                break;
            case "lb":
                SelectCols = "lb.id,lb.dm,lb.mc";
                GroupByStr = SelectCols;                
                TryAddStr(lstInner, innerspdmb);
                TryAddStr(lstInner, innersplb);
                break;
            case "sphh":
                SelectCols = "sp.sphh,sp.spmc";
                GroupByStr = SelectCols;           
                TryAddStr(lstInner, innerspdmb);
                break;
        }
        if (string.IsNullOrEmpty(spsearch) == false)
        {
            TryAddStr(lstInner, innerspdmb);
            WhereStr = string.Concat(WhereStr, " AND b.sphh = @sphh");
            lstParams.Add(new SqlParameter("@sphh", spsearch));
        }
        if (string.IsNullOrEmpty(curkhid) == false)
        {
            TryAddStr(lstInner, innerkhgxb);
            TryAddStr(lstInner, innerkhbmy);
            WhereStr = string.Concat(WhereStr, " AND kh.khid = @curkhid ");
            lstParams.Add(new SqlParameter("@curkhid", curkhid)); 
        }
        if (string.IsNullOrEmpty(khid) == false)
        {
            TryAddStr(lstInner, innerkhgxb);
            TryAddStr(lstInner, innerkhbmy);
            if (IsFindStoreMode) WhereStr = string.Concat(WhereStr, " AND a.khid = @khid ");
            else WhereStr = string.Concat(WhereStr, " AND kh.khid = @khid ");
            lstParams.Add(new SqlParameter("@khid", khid)); 
        }
        if (string.IsNullOrEmpty(lbid) == false)
        {
            TryAddStr(lstInner, innersplb);
            WhereStr = string.Concat(WhereStr, " AND lb.id = @lbid ");
            lstParams.Add(new SqlParameter("@lbid", lbid));
        }
        if (cxtj == "date")
        {
            WhereStr = string.Concat(WhereStr, " AND a.rq>=@ksrq AND a.rq<dateadd(day,1,@jsrq) ");
            lstParams.Add(new SqlParameter("@ksrq", xsksrq));
            lstParams.Add(new SqlParameter("@jsrq", xsjsrq));
        }
        else
        {
            TryAddStr(lstInner, innerspdmb);
            WhereStr = string.Concat(WhereStr, " AND sp.kfbh = @kfbh ");
            lstParams.Add(new SqlParameter("@kfbh", kfbh));
            //用开发编号限定日期
            if (kfbh.Length > 4)
            {
                DateTime dtkssj = getKssjBykfbh(kfbh); 
                WhereStr = string.Concat(WhereStr, " AND a.rq>=@ksrq ");
                lstParams.Add(new SqlParameter("@ksrq", dtkssj));
            }
        }
        if (string.IsNullOrEmpty(khlb) == false && IsFindStoreMode == false)
        {
            TryAddStr(lstInner, innerkhgxb);
            TryAddStr(lstInner, innerkhbmy);
            WhereStr = string.Concat(WhereStr, " AND kh.khfl = @khlb ");
            lstParams.Add(new SqlParameter("@khlb", khlb));
        }
        if (string.IsNullOrEmpty(zmdlb) == false)
        {
            TryAddStr(lstInner, innerkhgxb);
            TryAddStr(lstInner, innerkhbmy);
            WhereStr = string.Concat(WhereStr, " AND m.khfl LIKE @zmdlb ");
            lstParams.Add(new SqlParameter("@zmdlb", zmdlb));
        }
        InnerStr = string.Join(" ", lstInner.ToArray());
        lstInner.Clear();

        string strSQL = string.Concat(@"--零售数：直接取视图数据
	                    SELECT ", SelectCols, @"
	                    ,sum(case when a.djlb in (-1,-2) then -1*b.sl else b.sl end) lss
	                    FROM dbo.zmd_t_lsdjb a INNER JOIN dbo.zmd_t_lsdjmx b ON a.id = b.id ",
                                     InnerStr, @"
                         	WHERE a.djbs=1	 	 
                           ", WhereStr, @"
	                        GROUP BY ", GroupByStr);

        //clsLocalLoger.WriteInfo("3Dal.Conn=" + dal.ConnectionString);
        //clsLocalLoger.WriteInfo("strSQL=" + strSQL);

        //if (DBName == "FXDB") dal.ConnectionString = CX1Constr;
        //else if (DBName == "ERPDB") dal.ConnectionString = CX2Constr;
        //else
        //{
        //    strSQL = string.Concat(strSQL.Replace(" dbo.zmd_t_lsdj", " CX1.dbo.zmd_t_lsdj"), " UNION ALL ", strSQL.Replace(" dbo.zmd_t_lsdj", " CX2.dbo.zmd_t_lsdj"));
        //}

        string errInfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
        if (errInfo != "")
        {
            clsLocalLoger.WriteError(string.Concat("[提货销售对照分析]销售查询失败！错误：", errInfo, " SQL=", strSQL));
            clsSharedHelper.WriteErrorInfo("服务器繁忙，暂时无法查询销售数据！");
            return null;
        }

        //string json = dal.DataTableToJson(dt);
        //clsLocalLoger.WriteInfo(json);
        
        dt.PrimaryKey = new DataColumn[] { dt.Columns[0] };
        return dt;
    }

    private DateTime getKssjBykfbh(string kfbh)
    {
        DateTime dtkssj = Convert.ToDateTime(kfbh.Substring(0, 4) + "-01-01").AddMonths(-6);
        string strInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(LSDBConstr))
        {
            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@kfbh",kfbh));
            object objKsjj = null;
            strInfo = dal.ExecuteQueryFastSecurity("SELECT TOP 1 kssj FROM YF_T_Kfbh WHERE dm = @kfbh", lstParams, out objKsjj);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError("[提货销售对照分析]读取开发编号时间失败！错误：" + strInfo);                
                clsSharedHelper.WriteErrorInfo("服务器繁忙，暂时无法查询开发编号日期！");
            }

            if (objKsjj == null || Convert.ToDateTime(objKsjj).Subtract(dtkssj).TotalDays < 0) return dtkssj;
            else return Convert.ToDateTime(objKsjj);            
        }
    }

    //是否为直营大客户
    private bool IsZYDKH(string khid)
    { 
        string strInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(LSDBConstr))
        {
            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@khid", khid));
            object objkhfl = null;
            strInfo = dal.ExecuteQueryFastSecurity("SELECT TOP 1 khfl FROM yx_t_khb WHERE khid = @khid", lstParams, out objkhfl);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError("[提货销售对照分析]读取客户分类时间失败！错误：" + strInfo);
                clsSharedHelper.WriteErrorInfo("服务器繁忙，暂时无法查询开发客户分类！");
            }

            if (objkhfl != null && Convert.ToString(objkhfl) == "xg") return true;
            else return false;
        }
    }
    
    #endregion

    #region 基础功能
    //合并两个表
    private void MyMerge(ref DataTable sourceDt, ref DataTable targetDt, List<string> columnsName)
    {
        if (sourceDt == null || targetDt == null) return;
        
        DataRow targetDr = null, sourceDr = null;
        string keyName = sourceDt.PrimaryKey[0].ColumnName;
        if (columnsName != null)
        {
            foreach (string strColumnName in columnsName)
            {
                sourceDt.Columns.Add(strColumnName, targetDt.Columns[strColumnName].DataType, "");

                foreach (DataRow dr in sourceDt.Rows)
                {
                    targetDr = targetDt.Rows.Find(dr[keyName]);
                    if (targetDr != null)
                    {
                        dr[strColumnName] = targetDr[strColumnName];
                    }
                }
            }
        }

        foreach (DataRow dr in targetDt.Rows)
        {
            sourceDr = sourceDt.Rows.Find(dr[keyName]);
            if (sourceDr == null)
            {
                sourceDt.ImportRow(dr);
            }
        }
    }
    //合并两个表的数据
    private void MySum(ref DataTable sourceDt, ref DataTable targetDt, List<string> columnsName)
    {
        if (sourceDt == null || targetDt == null) return;

        DataRow sourceDr = null;
        string keyName = sourceDt.PrimaryKey[0].ColumnName;
     
        foreach (DataRow dr in targetDt.Rows)
        {
            sourceDr = sourceDt.Rows.Find(dr[keyName]);
            if (sourceDr == null)
            {
                sourceDt.ImportRow(dr);
            }
            else
            { 
                foreach (string strColumnName in columnsName)
                {
                    sourceDr[strColumnName] = Convert.ToInt32(sourceDr[strColumnName]) + Convert.ToInt32(dr[strColumnName]);                    
                } 
            }
        }
    }

    private void SetOrder(ref DataTable dt, string order_colName, string order_direc)
    { 
        //排序          
        if (string.IsNullOrEmpty(order_colName) == false)
        {
            //clsLocalLoger.WriteInfo("排序列名：" + order_colName);
            //foreach (DataColumn dc in dt.Columns)
            //{
            //    clsLocalLoger.WriteInfo(dc.ColumnName);
            //}
            //clsLocalLoger.WriteInfo("列名输出完毕！");            
            if (dt.Columns.Contains(order_colName) == false) return;
                        
            DataView dv = dt.DefaultView;
            dv.Sort = string.Concat(order_colName, " ", order_direc);
                        
            DataTable dt2 = dv.ToTable();
            dt.Clear(); dt.Dispose();

            dt = dt2;
        }
    }
    //20170517。By:xlm .官部提出需求：要屏蔽 领航营销管理有限公司-综合帐套、领航营销管理有限公司(特卖专户)、内部结算(部门领用) 三个套帐的数据；参考PC存储的写法执行效率较低，因此考虑删除 khdm LIKE '0000__' 的数据即可
    private void RemoveMyData(ref DataTable dt)
    {
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


    private void TryAddStr(List<string> lstInner, string addstr)
    {
        if (lstInner.Contains(addstr) == false) lstInner.Add(addstr);
    }
     
    //查询不同贸易公司所使用的数据库     
    private string GetDBConstr(int khid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(LSDBConstr))
        {
            string dbcon = dal.GetDBName(khid);
            return GetDBConstr(dbcon);
        }
    }
    private string GetDBConstr(string dbcon)
    {
        if (dbcon == "ERPDB") return CX2Constr;
        else if (dbcon == "FXDB") return CX1Constr;
        else return OAConStr;
    }

    //查询不同贸易公司所使用的数据库:实时库    
    private string GetDBConstrReal(int khid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(LSDBConstr))
        {
            string dbcon = dal.GetDBName(khid);
            return GetDBConstr(dbcon);
        }
    }
    private string GetDBConstrReal(string dbcon)
    {
        if (dbcon == "ERPDB") return ERPDBConstr;
        else if (dbcon == "FXDB") return FXDBConstr;
        else return LSDBConstr;
    } 

    #endregion

     

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}
 
