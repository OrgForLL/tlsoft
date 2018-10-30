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
        clsLocalLoger.WriteInfo("检查点0");
        DataTable dt1 = GetSaleData(dtKsrq, dtJsrq, khfl, zmdfl, khid, mdmc);
        clsLocalLoger.WriteInfo("检查点1");
        DataTable dt1Qn = GetSaleData(dtKsrq.AddYears(-1), dtJsrq.AddYears(-1), khfl, zmdfl, khid, mdmc);
        clsLocalLoger.WriteInfo("检查点2");
        DataTable dt2 = GetSaleTarget(dtKsrq, dtJsrq, khfl,zmdfl, khid, mdmc);
        clsLocalLoger.WriteInfo("检查点3");

        List<string> lstColumns = new List<string>(); 
        dt1Qn.Columns["xsje"].ColumnName = "qnje";
        lstColumns.Add("qnje");            
        MyMerge(ref dt1, ref dt1Qn, lstColumns); 
        clsSharedHelper.DisponseDataTable(ref dt1Qn);
        
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
        
        //开始计算合计值
        int sumXsje, sumMbje, sumQnje, sumWwce;
        string strSumWcbl, strTqzzl;
        object objTemp = null;
        objTemp = dt.Compute("SUM(xsje)", "");
        sumXsje = DBNull.Value.Equals(objTemp) ? 0 : Convert.ToInt32(objTemp);
        objTemp = dt.Compute("SUM(mbje)", "");
        sumMbje = DBNull.Value.Equals(objTemp) ? 0 : Convert.ToInt32(objTemp);
        objTemp = dt.Compute("SUM(qnje)", "");
        sumQnje = DBNull.Value.Equals(objTemp) ? 0 : Convert.ToInt32(objTemp);
        objTemp = dt.Compute("SUM(wwce)", "");
        sumWwce = DBNull.Value.Equals(objTemp) ? 0 : Convert.ToInt32(objTemp);
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
        
        clsLocalLoger.WriteInfo("检查点4");
        
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
    
    
    //构造查询销售情况的SQL  查询条件统一封装成JSON串        
    public DataTable GetSaleData(DateTime dtKsrq, DateTime dtJsrq, string khfl, string zmdfl, string khid, string mdmc)
    {
        string strSQL;
        List<SqlParameter> lstParams = new List<SqlParameter>();
        string errinfo = "";
        
        string strConn = AnalysisConstr;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(strConn))
        {
            object ccid = "";
            if (string.IsNullOrEmpty(khid) == false){
                strSQL = "SELECT TOP 1 ccid FROM yx_t_khb WHERE khid = @khid";
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
                        INNER JOIN tlsoft.dbo.yx_t_khgxb gx on A.khid=gx.gxid and gx.ty=0 and A.rq>=convert(datetime,gx.ksny+'01') and A.rq<=convert(datetime,gx.jsny+'01') 
                        INNER JOIN tlsoft.dbo.t_mdb B ON A.mdid = B.mdid ";
            if (string .IsNullOrEmpty(khid) == false || string.IsNullOrEmpty(khfl) == false){
                string AddKhSQL = " INNER JOIN tlsoft.dbo.yx_t_khgxb khgx on gx.khid=khgx.gxid and khgx.ty=0 and A.rq>=convert(datetime,khgx.ksny+'01') and A.rq<=convert(datetime,gx.jsny+'01')  ";
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
                strSQL = string.Concat(strSQL, " AND gx.khfl LIKE @khfl ");
                lstParams.Add(new SqlParameter("@khfl", zmdfl));
            }
            if (mdmc != "")
            {
                strSQL = string.Concat(strSQL, " AND gx.gxmc like '%' + @mdmc + '%' ");
                lstParams.Add(new SqlParameter("@mdmc", mdmc));
            }

            strSQL = string.Concat(strSQL, @" GROUP BY A.mdid,B.mdmc
                                          ");

            //clsLocalLoger.WriteInfo("strConn=" + strConn);
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
            //string json = dal.DataTableToJson(dt);
            //clsSharedHelper.WriteInfo(json);
            //clsSharedHelper.DisponseDataTable(ref dt);
            return dt;            
        }
    }

     
    //构造查询销售情况的SQL  查询条件统一封装成JSON串        
    public DataTable GetSaleTarget(DateTime dtKsrq, DateTime dtJsrq, string khfl, string zmdfl, string khid, string mdmc)
    {  
        string strSQL;
        List<SqlParameter> lstParams = new List<SqlParameter>();
        string errinfo = "";
        
        string strConn = GetDBConstrReal(khid);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(strConn))
        {
            object ccid = "";
            if (string.IsNullOrEmpty(khid) == false){
                strSQL = "SELECT TOP 1 ccid FROM yx_t_khb WHERE khid = @khid";
                errinfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out ccid);
                if (errinfo != "")
                {
                    clsSharedHelper.WriteErrorInfo("无法获取查询范围CCID_2");
                    return null;
                }
            }
            
        lstParams.Clear(); 
        
        //添加筛选条件     
        strSQL = @"SELECT A.mdid,B.mdmc,CONVERT(INT,je) mbje FROM yx_t_xsmbje A
                    INNER JOIN t_mdb B ON A.mdid = B.mdid
                    INNER JOIN yx_t_khgxb gx on A.khid=gx.gxid and gx.ty=0 and A.ny>=gx.ksny and A.ny<=gx.jsny 
                    ";
        if (string.IsNullOrEmpty(khid) == false || string.IsNullOrEmpty(khfl) == false)
        {
            string AddKhSQL = " INNER JOIN yx_t_khgxb khgx on gx.khid=khgx.gxid and khgx.ty=0 and A.ny>=khgx.ksny and A.ny<=khgx.jsny  ";                        
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
            strSQL = string.Concat(strSQL, " AND gx.khfl LIKE @khfl ");
            lstParams.Add(new SqlParameter("@khfl", zmdfl));
        }
        if (mdmc != "")
        {
            strSQL = string.Concat(strSQL, " AND gx.gxmc like '%' + @mdmc + '%' ");
            lstParams.Add(new SqlParameter("@mdmc", mdmc));
        }
        
        
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