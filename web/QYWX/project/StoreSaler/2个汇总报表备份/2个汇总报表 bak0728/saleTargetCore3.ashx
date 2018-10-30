<%@ WebHandler Language="C#" Class="saleTargetCore" %>

using System;
using System.Web;
using nrWebClass;
using System.Data;
using System.Collections.Generic;
using System.Data.SqlClient;

public class saleTargetCore : IHttpHandler, System.Web.SessionState.IRequiresSessionState 
{

    private string ZBDBConstr = clsConfig.GetConfigValue("OAConnStr");
    private string AnalysisConstr = clsConfig.GetConfigValue("FXDBConStr");
    private string FXDBConstr = clsConfig.GetConfigValue("FXConStr");
    private string ERPDBConstr = clsConfig.GetConfigValue("ERPConStr");
    private string CX1ConStr = clsConfig.GetConfigValue("CX1ConStr");
    private string CX2ConStr = clsConfig.GetConfigValue("CX2ConStr");
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;
        
        string ctrl = context.Request.Params["ctrl"];
        switch (ctrl)
        {
            case "LoadData":
                LoadData(context);                
                break;

        }
    }

    private void MyMerge(ref DataTable sourceDt, ref DataTable targetDt, List<string> columnsName)
    {
        DataRow targetDr = null,sourceDr = null;
        string keyName = sourceDt.PrimaryKey[0].ColumnName;
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

        foreach (DataRow dr in targetDt.Rows)
        {
            sourceDr = sourceDt.Rows.Find(dr[keyName]);
            if (sourceDr == null)
            {
                sourceDt.ImportRow(dr); 
            }
        }    
    }

    private void LoadData(HttpContext context) 
    {       
        if (string.IsNullOrEmpty(Convert.ToString(context.Session["qy_customersid"])))
        {
            clsSharedHelper.WriteErrorInfo("您已超时,请重新访问!");
            return;
        }

        string filterJSON = Convert.ToString(context.Request.Params["filters"]);
        
        string ksrq,jsrq,kbxz,khfl,zmdfl, khid, mdmc;
        using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(filterJSON))
        {
            ksrq = Convert.ToString(jh.GetJsonValue("ksrq"));
            jsrq = Convert.ToString(jh.GetJsonValue("jsrq"));
            kbxz = Convert.ToString(jh.GetJsonValue("kbxz"));
            khfl = Convert.ToString(jh.GetJsonValue("khfl"));
            zmdfl = Convert.ToString(jh.GetJsonValue("zmdfl"));  
            khid = Convert.ToString(jh.GetJsonValue("khid")); 
            mdmc = Convert.ToString(jh.GetJsonValue("mdmc")); 
        }
        
        //执行SQL，返回查询结果
        //难点，销售目标yx_t_xsmbje 在各自分库，要进行数据处理

        //首先先去分析库查询 零售数据 
        DateTime dtKsrq = DateTime.Parse(ksrq);
        DateTime dtJsrq = DateTime.Parse(jsrq); 
        DataTable dt1 = GetSaleData(dtKsrq, dtJsrq, khfl, zmdfl, khid, mdmc); 
        DataTable dt1Qn = GetSaleData(dtKsrq.AddYears(-1), dtJsrq.AddYears(-1), khfl, zmdfl, khid, mdmc); 
        

        List<string> lstColumns = new List<string>(); 
        dt1Qn.Columns["xsje"].ColumnName = "qnje";
        lstColumns.Add("qnje");            
        MyMerge(ref dt1, ref dt1Qn, lstColumns); 
        clsSharedHelper.DisponseDataTable(ref dt1Qn);
        
        DataTable dt2;
        string strConn = "";
        if (string.IsNullOrEmpty(khid) == false)
        {
            strConn = GetDBConstrReal(Convert.ToInt32(khid));
            dt2 = GetSaleTarget(strConn, dtKsrq, dtJsrq, khfl, zmdfl, khid, mdmc);
        }
        else
        {
            dt2 = GetSaleTarget(FXDBConstr, dtKsrq, dtJsrq, khfl, zmdfl, khid, mdmc);
            DataTable dt2_tmp = GetSaleTarget(ERPDBConstr, dtKsrq, dtJsrq, khfl, zmdfl, khid, mdmc);
            
            lstColumns.Clear();
            MyMerge(ref dt2, ref dt2_tmp, lstColumns);            
        } 
        
        DataTable dt;
        lstColumns.Clear();
        lstColumns.Add("mbje");
        MyMerge(ref dt1, ref dt2, lstColumns);
        dt = dt1;           
        clsSharedHelper.DisponseDataTable(ref dt2);
         
        
        dt.Columns.Add("wcbl", typeof(string), "");
        dt.Columns.Add("wwce", typeof(int), "");
        dt.Columns.Add("tqzzl", typeof(string), "");
        
        //开始计算完成比率、未完成额、同期增长率
        foreach (DataRow dr in dt.Rows)
        {
            if (DBNull.Value.Equals(dr["xsje"]) == false && DBNull.Value.Equals(dr["mbje"]) == false)
            {
                dr["wcbl"] = string.Format("{0:N2}", Convert.ToInt32(dr["xsje"]) * 100.0 / Convert.ToInt32(dr["mbje"]));
                dr["wwce"] = Convert.ToInt32(dr["xsje"]) - Convert.ToInt32(dr["mbje"]);
            }
            if (DBNull.Value.Equals(dr["xsje"]) == false && DBNull.Value.Equals(dr["qnje"]) == false)
            {
                dr["tqzzl"] = string.Format("{0:N2}", (Convert.ToInt32(dr["xsje"]) - Convert.ToInt32(dr["qnje"])) * 100.0 / Convert.ToInt32(dr["qnje"]));
            }
        }        
        
        //处理 kbxz 可比选择
        DataRow[] drDelete = null;
        if (kbxz == "1") drDelete = dt.Select("xsje IS NULL OR qnje IS NULL");
        else if (kbxz == "2") drDelete = dt.Select("(xsje IS NOT NULL) AND (qnje IS NOT NULL)"); 
        if (drDelete != null)
        {
            foreach (DataRow dr in drDelete)
            {
                dt.Rows.Remove(dr);
            }
        }
        //删除屏蔽数据
        RemoveMyData(ref dt);
        
        //开始计算合计值
        long sumXsje, sumMbje, sumQnje, sumWwce;
        string strSumWcbl, strTqzzl;
        object objTemp = null;
        objTemp = dt.Compute("SUM(xsje)", "");
        sumXsje = DBNull.Value.Equals(objTemp) ? 0 : Convert.ToInt64(objTemp);
        objTemp = dt.Compute("SUM(mbje)", "");
        sumMbje = DBNull.Value.Equals(objTemp) ? 0 : Convert.ToInt64(objTemp);
        objTemp = dt.Compute("SUM(qnje)", "");
        sumQnje = DBNull.Value.Equals(objTemp) ? 0 : Convert.ToInt64(objTemp);
        objTemp = dt.Compute("SUM(wwce)", "");
        sumWwce = DBNull.Value.Equals(objTemp) ? 0 : Convert.ToInt64(objTemp);
        if (sumMbje != 0) strSumWcbl = string.Format("{0:N2}", sumXsje * 100.0 / sumMbje);
        else strSumWcbl = "0";
        if (sumQnje != 0) strTqzzl = string.Format("{0:N2}", (sumXsje - sumQnje) * 100.0 / sumQnje);
        else strTqzzl = "0";
        
        string JsonSum = string.Format(@" ""Sum"":{{""SumXsje"":""{0}"",""SumMbje"":""{1}"",""SumQnje"":""{2}"",""SumWwce"":""{3}"",""SumWcbl"":""{4}"",""SumTqzzl"":""{5}""}}, "
            , sumXsje, sumMbje, sumQnje, sumWwce, strSumWcbl, strTqzzl) ;
                          
        string json = "";
        
        string OrderColumn = Convert.ToString(context.Request.Params["OrderColumn"]);
        string OrderDirec = Convert.ToString(context.Request.Params["OrderDirec"]);
        SetOrder(ref dt, OrderColumn, OrderDirec);
          
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(""))
        {
            json = dal.DataTableToJson(dt);
            if (json.Length > 0)   json = json.Insert(1, JsonSum);
        }
        clsSharedHelper.DisponseDataTable(ref dt);
                 
        context.Response.Write(json);
        json = "";
        JsonSum = ""; 
        context.Response.End();
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
    
    //限总部查：构造查询销售情况的SQL  查询条件统一封装成JSON串        
    public DataTable GetSaleData(DateTime dtKsrq, DateTime dtJsrq, string khfl, string zmdfl, string mdmc)
    {
        string strSQL;
        List<SqlParameter> lstParams = new List<SqlParameter>();
        string errinfo = "";
        
        string strConn = AnalysisConstr;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(strConn))
        {
            lstParams.Clear();
            //添加筛选条件     
            strSQL = @"SELECT khgx.khid 'mdid',khgx.khmc mdmc,khgx.khdm,
                        CONVERT(INT,SUM(case when A.djlb in (-1,-2) then -1*A.je else A.je end)) xsje          
                        from zmd_v_lsdjmx A                                           
                        INNER JOIN yx_t_khgxb gx on A.khid=gx.gxid and gx.ty=0 and A.rq>=convert(datetime,gx.ksny+'01') and A.rq<=convert(datetime,gx.jsny+'01') 
                        INNER JOIN t_mdb B ON A.mdid = B.mdid 
                        INNER JOIN yx_t_khb khgx on gx.myid=khgx.khid and khgx.ty=0 AND khgx.ssid = 1 ";

            strSQL = string.Concat(strSQL, " WHERE A.djlb in (1,-1,2,-2) and A.djbs=1 ");

            if (string.IsNullOrEmpty(khfl) == false)
            {
                strSQL = string.Concat(strSQL, " AND khgx.khfl = @khfl ");
                lstParams.Add(new SqlParameter("@khfl", khfl));
            }

            //增加查询月份作为条件         
            strSQL = string.Concat(strSQL, string.Concat(" AND DATEDIFF(day, '", dtKsrq.ToString("yyyy-MM-dd"), "' , A.rq ) >= 0 AND DATEDIFF(day , A.rq, '", dtJsrq.ToString("yyyy-MM-dd"), "' ) >= 0 "));
            if (zmdfl != "")
            {
                if (zmdfl.Contains("[")) strSQL = string.Concat(strSQL, " AND gx.khfl LIKE @zmdfl ");
                else strSQL = string.Concat(strSQL, " AND gx.khfl = @zmdfl "); 
                lstParams.Add(new SqlParameter("@zmdfl", zmdfl));
            }
            if (mdmc != "")
            {
                strSQL = string.Concat(strSQL, " AND gx.gxmc like '%' + @mdmc + '%' ");
                lstParams.Add(new SqlParameter("@mdmc", mdmc));
            }

            strSQL = string.Concat(strSQL, @" GROUP BY khgx.khid,khgx.khmc,khgx.khdm ");

            //clsLocalLoger.WriteInfo("销售目标cccstrConn=" + strConn);
            //clsLocalLoger.WriteInfo("销售目标cc对照：" + strSQL);

            DataTable dt;
            //WriteLog(_sql + "\r\n" + filterJSON);
            errinfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (errinfo != "")
            {
                clsLocalLoger.WriteError("读取销售数据失败！" + errinfo);
                clsSharedHelper.WriteErrorInfo("销售数据读取错误：" + errinfo);
                return null;
            }

            dt.PrimaryKey = new DataColumn[] { dt.Columns["mdid"] };

            return dt;            
        }        
    }
    
    //构造查询销售情况的SQL  查询条件统一封装成JSON串        
    public DataTable GetSaleData(DateTime dtKsrq, DateTime dtJsrq, string khfl, string zmdfl, string khid, string mdmc)
    {
        if (string.IsNullOrEmpty(khid)) return GetSaleData(dtKsrq, dtJsrq, khfl, zmdfl, mdmc);  //如果是不查贸易公司，则视为总部在查
        
        string strSQL;
        List<SqlParameter> lstParams = new List<SqlParameter>();
        string errinfo = "";
        
        string strConn = AnalysisConstr;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(strConn))
        {
            object ccid = "";
            if (string.IsNullOrEmpty(khid) == false){
                strSQL = "SELECT TOP 1 ccid FROM yx_t_khb WHERE khid = @khid";
                lstParams.Add(new SqlParameter("@khid", khid));
                errinfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out ccid);
                if (errinfo != "")
                {
                    clsSharedHelper.WriteErrorInfo("无法获取查询范围CCID");
                    return null;
                }
            } 
                
            lstParams.Clear();      
            //添加筛选条件     
            strSQL = @"SELECT A.mdid,B.mdmc,
                        CONVERT(INT,SUM(case when A.djlb in (-1,-2) then -1*A.je else A.je end)) xsje          
                        from zmd_v_lsdjmx A                                           
                        INNER JOIN yx_t_khgxb gx on A.khid=gx.gxid and gx.ty=0 and A.rq>=convert(datetime,gx.ksny+'01') and A.rq<=convert(datetime,gx.jsny+'01') 
                        INNER JOIN t_mdb B ON A.mdid = B.mdid ";
            if (string .IsNullOrEmpty(khid) == false || string.IsNullOrEmpty(khfl) == false){
                string AddKhSQL = " LEFT JOIN yx_t_khb khgx on gx.khid=khgx.khid and khgx.ty=0 ";
                strSQL = string.Concat(strSQL ,AddKhSQL);
            }
             
            strSQL = string.Concat(strSQL ," WHERE A.djlb in (1,-1,2,-2) and A.djbs=1 ");
            
            if (string .IsNullOrEmpty(khid) == false){
                strSQL = string.Concat(strSQL ," AND gx.ccid + '-' LIKE '" , ccid , "-%' ");                
            }
            if (string .IsNullOrEmpty(khfl) == false){
                strSQL = string.Concat(strSQL ," AND khgx.khfl = @khfl ");  
                lstParams.Add(new SqlParameter("@khfl", khfl));                              
            }
                         
            //增加查询月份作为条件         
            strSQL = string.Concat(strSQL, string.Concat(" AND DATEDIFF(day, '", dtKsrq.ToString("yyyy-MM-dd"), "' , A.rq ) >= 0 AND DATEDIFF(day , A.rq, '", dtJsrq.ToString("yyyy-MM-dd"), "' ) >= 0 "));                 
            if (zmdfl != "")
            {
                if (zmdfl.Contains("[")) strSQL = string.Concat(strSQL, " AND gx.khfl LIKE @zmdfl ");
                else strSQL = string.Concat(strSQL, " AND gx.khfl = @zmdfl "); 
                lstParams.Add(new SqlParameter("@zmdfl", zmdfl));
            }
            if (mdmc != "")
            {
                strSQL = string.Concat(strSQL, " AND gx.gxmc like '%' + @mdmc + '%' ");
                lstParams.Add(new SqlParameter("@mdmc", mdmc));
            }

            strSQL = string.Concat(strSQL, @" GROUP BY A.mdid,B.mdmc ");

            //clsLocalLoger.WriteInfo("销售目标strConn=" + strConn);
            //clsLocalLoger.WriteInfo("销售目标对照：" + strSQL);
        
            DataTable dt;
            //WriteLog(_sql + "\r\n" + filterJSON);
            errinfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (errinfo != "")
            {
                clsLocalLoger.WriteError("读取销售数据失败！" + errinfo);
                clsSharedHelper.WriteErrorInfo("销售数据读取错误：" + errinfo);
                return null ;                
            }

            dt.PrimaryKey = new DataColumn[] { dt.Columns["mdid"] }; 
            return dt;            
        }
    }


    //限总部查：构造查询销售情况的SQL  查询条件统一封装成JSON串        
    public DataTable GetSaleTarget(string strConn, DateTime dtKsrq, DateTime dtJsrq, string khfl, string zmdfl, string mdmc)
    {
        string strSQL;
        List<SqlParameter> lstParams = new List<SqlParameter>();
        string errinfo = "";

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(strConn))
        {            
            lstParams.Clear();

            //添加筛选条件     
            strSQL = @"SELECT khgx.khid 'mdid',khgx.khmc 'mdmc',khgx.khdm,SUM(CONVERT(INT,je)) mbje FROM yx_t_xsmbje A
                        INNER JOIN t_mdb B ON A.mdid = B.mdid
                        INNER JOIN yx_t_khgxb gx on A.khid=gx.gxid and gx.ty=0 and A.ny>=gx.ksny and A.ny<=gx.jsny 
                        INNER JOIN yx_t_khb khgx on gx.myid=khgx.khid and khgx.ty=0 AND khgx.ssid = 1 ";  

            //增加查询月份作为条件
            string Between = string.Concat(" WHERE A.ny >= ", dtKsrq.ToString("yyyyMM"), " AND A.ny <=", dtJsrq.ToString("yyyyMM"));
            strSQL = string.Concat(strSQL, Between);
              
            if (string.IsNullOrEmpty(khfl) == false)
            {
                strSQL = string.Concat(strSQL, " AND khgx.khfl = @khfl ");
                lstParams.Add(new SqlParameter("@khfl", khfl));
            }

            if (zmdfl != "")
            {
                if (zmdfl.Contains("[")) strSQL = string.Concat(strSQL, " AND gx.khfl LIKE @zmdfl ");
                else strSQL = string.Concat(strSQL, " AND gx.khfl = @zmdfl "); 
                lstParams.Add(new SqlParameter("@zmdfl", zmdfl));
            }
            if (mdmc != "")
            {
                strSQL = string.Concat(strSQL, " AND gx.gxmc like '%' + @mdmc + '%' ");
                lstParams.Add(new SqlParameter("@mdmc", mdmc));
            }

            strSQL = string.Concat(strSQL, " GROUP BY khgx.khid,khgx.khmc,khgx.khdm");

            //clsLocalLoger.WriteInfo("销售目标strConn=" + strConn);
            //clsLocalLoger.WriteInfo("销售目标strSQL=" + strSQL);

            DataTable dt;
            errinfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (errinfo != "")
            {
                clsLocalLoger.WriteError("读取销售目标数据失败！" + errinfo);
                clsSharedHelper.WriteInfo("销售目标数据读取错误：" + errinfo);
                return null;
            }

            dt.PrimaryKey = new DataColumn[] { dt.Columns["mdid"] }; 
            return dt;
        }
    }
     
    //构造查询销售情况的SQL  查询条件统一封装成JSON串        
    public DataTable GetSaleTarget(string strConn, DateTime dtKsrq, DateTime dtJsrq, string khfl, string zmdfl, string khid, string mdmc)
    {
        if (string.IsNullOrEmpty(khid)) return GetSaleTarget(strConn,dtKsrq, dtJsrq, khfl, zmdfl, mdmc);  //如果是不查贸易公司，则视为总部在查
        
        string strSQL;
        List<SqlParameter> lstParams = new List<SqlParameter>();
        string errinfo = "";
        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(strConn))
        {
            object ccid = "";
            if (string.IsNullOrEmpty(khid) == false){
                strSQL = "SELECT TOP 1 ccid FROM yx_t_khb WHERE khid = @khid";
                lstParams.Add(new SqlParameter("@khid", khid));
                errinfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out ccid);
                if (errinfo != "")
                {
                    clsSharedHelper.WriteErrorInfo("无法获取查询范围CCID_2");
                    return null;
                }
            }
            
            lstParams.Clear(); 
        
            //添加筛选条件     
            strSQL = @"SELECT A.mdid,B.mdmc,SUM(CONVERT(INT,je)) mbje FROM yx_t_xsmbje A
                        INNER JOIN t_mdb B ON A.mdid = B.mdid
                        INNER JOIN yx_t_khgxb gx on A.khid=gx.gxid and gx.ty=0 and A.ny>=gx.ksny and A.ny<=gx.jsny ";
            if (string.IsNullOrEmpty(khid) == false || string.IsNullOrEmpty(khfl) == false)
            {
                string AddKhSQL = " LEFT JOIN yx_t_khb khgx on gx.khid=khgx.khid and khgx.ty=0 ";                        
                strSQL = string.Concat(strSQL, AddKhSQL);
            }

            //增加查询月份作为条件
            string Between = string.Concat(" WHERE A.ny >= ", dtKsrq.ToString("yyyyMM"), " AND A.ny <=", dtJsrq.ToString("yyyyMM"));
            strSQL = string.Concat(strSQL, Between);

            if (string.IsNullOrEmpty(khid) == false)
            {
                strSQL = string.Concat(strSQL, " AND gx.ccid + '-' LIKE '", ccid, "-%' ");
            }
            if (string.IsNullOrEmpty(khfl) == false)
            {
                strSQL = string.Concat(strSQL, " AND khgx.khfl = @khfl ");
                lstParams.Add(new SqlParameter("@khfl", khfl));
            }
         
            if (zmdfl != "")
            {
                if (zmdfl.Contains("[")) strSQL = string.Concat(strSQL, " AND gx.khfl LIKE @zmdfl ");
                else strSQL = string.Concat(strSQL, " AND gx.khfl = @zmdfl "); 
                lstParams.Add(new SqlParameter("@zmdfl", zmdfl));
            }
            if (mdmc != "")
            {
                strSQL = string.Concat(strSQL, " AND gx.gxmc like '%' + @mdmc + '%' ");
                lstParams.Add(new SqlParameter("@mdmc", mdmc));
            }

            strSQL = string.Concat(strSQL, " GROUP BY A.mdid,B.mdmc");
            
            //clsLocalLoger.WriteInfo("销售目标strConn=" + strConn);
            //clsLocalLoger.WriteInfo("销售目标strSQL=" + strSQL);
        
            DataTable dt; 
            errinfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (errinfo != "")
            {
                clsLocalLoger.WriteError("读取销售目标数据失败！" + errinfo);
                clsSharedHelper.WriteInfo("销售目标数据读取错误：" + errinfo);
                return null;
            }

            dt.PrimaryKey = new DataColumn[] { dt.Columns["mdid"] };
            //string json = dal.DataTableToJson(dt);
            //clsSharedHelper.WriteInfo(json);
            //clsSharedHelper.DisponseDataTable(ref dt);
            return dt;
        }
    }


    //20170517。By:xlm .要屏蔽 领航营销管理有限公司-综合帐套、领航营销管理有限公司(特卖专户)、内部结算(部门领用) 三个套帐的数据；参考PC存储的写法执行效率较低，因此考虑删除 khdm LIKE '0000__' 的数据即可
    private void RemoveMyData(ref DataTable dt)
    {
        if (dt.Columns.Contains("khdm") == false) return;
        int j = dt.Rows.Count;
        for (int i = j - 1; i > -1; i--)
        {
            if (Convert.ToString(dt.Rows[i]["khdm"]).StartsWith("0000"))
            {
                dt.Rows.RemoveAt(i);
            }
        }
    }

    private string GetDBConstrReal(int khid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ZBDBConstr))
        {
            string dbcon = dal.GetDBName(khid);
            return GetDBConstrReal(dbcon);
        }
    }
    private string GetDBConstrReal(string dbcon)
    {
        if (dbcon == "ERPDB") return ERPDBConstr;
        else if (dbcon == "FXDB") return FXDBConstr;
        else return ZBDBConstr;
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}