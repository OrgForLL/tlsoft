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
        DataRow targetDr = null;
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
    }

    private void LoadData(HttpContext context) 
    {       
        if (string.IsNullOrEmpty(Convert.ToString(context.Session["qy_customersid"])))
        {
            clsSharedHelper.WriteErrorInfo("您已超时,请重新访问!");
            return;
        }

        string filterJSON = Convert.ToString(context.Request.Params["filters"]);
        
        string rq, status, khid, mdmc, tgchk;
        using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(filterJSON))
        {
            rq = Convert.ToString(jh.GetJsonValue("rq"));
            status = Convert.ToString(jh.GetJsonValue("status"));
            khid = Convert.ToString(jh.GetJsonValue("khid")); 
            mdmc = Convert.ToString(jh.GetJsonValue("mdmc"));
            tgchk = Convert.ToString(jh.GetJsonValue("tgchk"));
        }
        
        //执行SQL，返回查询结果
        //难点，销售目标yx_t_xsmbje 在各自分库，要进行数据处理

        //首先先去分析库查询 零售数据 
        DateTime dtRq = DateTime.Parse(string.Concat(rq, "-1"));
        DataTable dt1 = GetSaleData(dtRq, Convert.ToInt32(khid), mdmc);
        DataTable dt1Qn = GetSaleData(dtRq.AddYears(-1), Convert.ToInt32(khid), mdmc);        
        DataTable dt2 = GetSaleTarget(rq, Convert.ToInt32(khid), mdmc);

        List<string> lstColumns = new List<string>(); 
        dt1Qn.Columns["xsje"].ColumnName = "qnje";
        lstColumns.Add("qnje");            
        MyMerge(ref dt1, ref dt1Qn, lstColumns); 
        clsSharedHelper.DisponseDataTable(ref dt1Qn);
        

        DataTable dt;
        if (tgchk == "1")   //以销售目标为主
        {

            lstColumns.Clear();
            lstColumns.Add("xsje");
            lstColumns.Add("qnje");
            MyMerge(ref dt2, ref dt1, lstColumns);
            clsSharedHelper.DisponseDataTable(ref dt1);
            dt = dt2;
        }
        else
        { 
            lstColumns.Clear();
            lstColumns.Add("mbje");
            MyMerge(ref dt1, ref dt2, lstColumns);
            clsSharedHelper.DisponseDataTable(ref dt2);
            dt = dt1;
        }
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
        
        //处理 1已达标>=、0未达标< 的数据
        DataRow[] drDelete = null;
        if (status == "1") drDelete = dt.Select("wwce < 0 OR wwce IS NULL");
        else if (status == "0") drDelete = dt.Select("wwce >= 0");
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


    //构造查询销售情况的SQL  查询条件统一封装成JSON串        
    public DataTable GetSaleData(DateTime dtRq,int khid ,string mdmc)
    { 
        //添加筛选条件     
        string strSQL = @"SELECT A.mdid,B.mdmc,
                    CONVERT(INT,SUM(case when A.djlb in (-1,-2) then -1*A.je else A.je end)) xsje          
                    from zmd_v_lsdjmx A                                           
                    INNER JOIN tlsoft.dbo.yx_t_khgxb gx on A.khid=gx.gxid and gx.ty=0 and A.rq>=convert(datetime,gx.ksny+'01') and A.rq<dateadd(month,1,convert(datetime,gx.jsny+'01')) 
                    INNER JOIN tlsoft.dbo.t_mdb B ON A.mdid = B.mdid
                    WHERE A.djlb in (1,-1,2,-2) and A.djbs=1 
                    ";
        //增加查询月份作为条件         
        strSQL = string.Concat(strSQL, string.Concat(" AND a.rq >= '", dtRq.ToString("yyyy-MM-dd"), "' AND a.rq < '", dtRq.AddMonths(1).ToString("yyyy-MM-dd"), "' "));

        List<SqlParameter> lstParams = new List<SqlParameter>();
        strSQL = string.Concat(strSQL, " AND (gx.khid = @khid OR A.khid = @khid) ");        
        lstParams.Add(new SqlParameter("@khid", khid));

        if (mdmc != "")
        {
            strSQL = string.Concat(strSQL, " AND gx.gxmc like '%' + @mdmc + '%' ");
            lstParams.Add(new SqlParameter("@mdmc", mdmc));
        }

        strSQL = string.Concat(strSQL, @" GROUP BY A.mdid,B.mdmc
                                        ORDER BY B.mdmc");

        //clsLocalLoger.WriteInfo("销售目标对照：" + strSQL);
        
        string strConn = GetDBConstr(khid);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(strConn))
        {
            DataTable dt;
            //WriteLog(_sql + "\r\n" + filterJSON);
            string errinfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
            if (errinfo != "")
            {
                clsLocalLoger.WriteError("读取销售数据失败！" + errinfo);
                clsSharedHelper.WriteInfo("销售数据读取错误：" + errinfo);
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
    public DataTable GetSaleTarget(string rq, int khid , string mdmc)
    {
        //添加筛选条件     
        string strSQL = string.Format(@"SELECT A.mdid,B.mdmc,CONVERT(INT,je) mbje FROM yx_t_xsmbje A
                    INNER JOIN t_mdb B ON A.mdid = B.mdid
                    WHERE (A.tzid = {0} OR A.khid={0}) "  ,khid);
        
        //增加查询月份作为条件
        DateTime dtRq = DateTime.Parse(string.Concat(rq, "-1"));
        strSQL = string.Concat(strSQL, string.Concat(" AND A.ny = ", dtRq.ToString("yyyyMM")));

        List<SqlParameter> lstParams = new List<SqlParameter>(); 

        if (mdmc != "")
        {
            strSQL = string.Concat(strSQL, " AND B.mdmc LIKE '%' + @mdmc + '%' ");
            lstParams.Add(new SqlParameter("@mdmc", mdmc));
        }

        strSQL = string.Concat(strSQL, @" ORDER BY B.mdmc");
        string strConn = GetDBConstrReal(khid);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(strConn))
        {
            DataTable dt; 
            string errinfo = dal.ExecuteQuerySecurity(strSQL, lstParams, out dt);
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
        if (dbcon == "ERPDB") return CX2ConStr;
        else if (dbcon == "FXDB") return CX1ConStr;
        else return ZBDBConstr;
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