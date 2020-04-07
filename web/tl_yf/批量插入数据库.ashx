<%@ WebHandler Language="C#" Class="LLWebApi_CL_GetWTSData" Debug="true" %>
using System;
using System.Web;
using System.Data;
using System.IO;
using System.Text;
using System.Data.SqlClient;
using System.Collections.Generic;
using LLWebApi.Base;
using LLWebApi.Utils;
using nrWebClass;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

public class LLWebApi_CL_GetWTSData : IHttpHandler
{
    string connStr = "";
    string testConn = "";
    public void ProcessRequest(HttpContext context)
    {

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            testConn = dal.ConnectionString;
            connStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
        }

        DataTable dt = getSpid();
        string strInfo; TimeSpan timeSpan;

        //string mbsql = "insert into yx_T_spidb_rfid_test values('{0}','{1}','{2}','{3}',getdate());";
        //StringBuilder str = new StringBuilder();
        //foreach (DataRow dr in dt.Rows)
        //{
        //    str.Append(string.Format(mbsql, "1", dr["spid"], "", "test"));
        //}
        //using (LiLanzDALForXLM zdal = new LiLanzDALForXLM(testConn))
        //{

        //    DateTime date1 = new DateTime();
        //    strInfo = zdal.ExecuteNonQuery(str.ToString());
        //    DateTime date2 = new DateTime();
        //    timeSpan = date2 - date1;
        //}
        //context.Response.Write(strInfo + "两次时间相差" + timeSpan.TotalMinutes + "分钟</br>");


        //string mbsql2 = "select  '{0}' as tzid,'{1}' as spid,'{2}' as epc,'{3}' as zdr,getdate() as zdrq ";
        //StringBuilder str2 = new StringBuilder();
        //foreach (DataRow dr in dt.Rows)
        //{
        //    str2.Append(string.Format(mbsql2, "1", dr["spid"], "", "test2"));
        //    if (dt.Rows.IndexOf(dr) == 0)
        //    {
        //        str2.Append(" into #temp ");
        //    }
        //    if (dt.Rows.IndexOf(dr) != dt.Rows.Count - 1)
        //    {
        //        str2.Append(" union ");
        //    }
        //}
        //using (LiLanzDALForXLM zdal = new LiLanzDALForXLM(testConn))
        //{

        //    DateTime date1 = new DateTime();
        //    strInfo = zdal.ExecuteNonQuery(str2.ToString() + ";insert into yx_T_spidb_rfid_test  select tzid,spid,epc,zdr,zdrq from #temp");
        //    DateTime date2 = new DateTime();
        //    timeSpan = date2 - date1;
        //    if (strInfo != "")
        //    {
        //    }
        //    else
        //    {
        //    }
        //}
        //context.Response.Write(strInfo + "两次时间相差" + timeSpan.TotalMinutes + "分钟</br>");
        //

        timeSpan = BatchInsertByTableValue(dt);
        context.Response.Write("两次时间相差" + timeSpan.TotalMilliseconds + "毫秒</br>");
        timeSpan = BulkToDBRun(dt);
        context.Response.Write("两次时间相差" + timeSpan.TotalMilliseconds + "毫秒</br>");
        //
        context.Response.End();
    }



    public TimeSpan BatchInsertByTableValue(DataTable dt)
    {
        string TSqlStatement =
"insert into yx_T_spidb_rfid_test (tzid,spid,spidhex,zdr,zdrq)" +
" SELECT 1, spid,spidhex,'test',getdate() " +
" FROM @dt ";
        DataTable dtNew = GetTableSchema();
        foreach (DataRow dr in dt.Rows)
        {
            if (dt.Rows.IndexOf(dr) == 50000)
            {
                //break;
            }
            DataRow r = dtNew.NewRow();
            r[0] = dr["spid"];
            r[1] = "";
            dtNew.Rows.Add(r);
        }
        TimeSpan timeSpan;
        using (SqlConnection sqlConn = new SqlConnection(connStr))
        {
            using (SqlCommand sqlCmd = new SqlCommand(TSqlStatement, sqlConn))
            {
                
                //把DataTable当做参数传入
                SqlParameter sqlPar = sqlCmd.Parameters.AddWithValue("@dt", dtNew);
                //指定表值参数中包含的构造数据的特殊数据类型。
                sqlPar.SqlDbType = SqlDbType.Structured;
                sqlPar.TypeName = "dbo.yx_T_spidb_rfid_type";//表值参数名称
                sqlConn.Open();
                    DateTime date1 = DateTime.Now; ;
                sqlCmd.ExecuteNonQuery();
                DateTime date2 = DateTime.Now; ;
                timeSpan = date2 - date1;
            }
        }
        return timeSpan;
    }
    public TimeSpan BulkToDBRun(DataTable dt)
    {
        DataTable dtNew = GetTableSchema2();
        foreach (DataRow dr in dt.Rows)
        {
            DataRow r = dtNew.NewRow();
            r[0] = 0;
            r[1] = 1;
            r[2] = dr["spid"];
            r[3] = "";
            r[4] = "test";
            r[5] = DateTime.Now;
            dtNew.Rows.Add(r);
        }
        DateTime date1 = DateTime.Now; ;
        BulkToDB(dtNew);
        DateTime date2 = DateTime.Now; ;
        return date2 - date1;
    }
    public void BulkToDB(DataTable dt)
    {
        SqlConnection sqlConn = new SqlConnection(connStr);
        SqlBulkCopy bulkCopy = new SqlBulkCopy(sqlConn);
        bulkCopy.DestinationTableName = "yx_T_spidb_rfid_test";
        bulkCopy.BatchSize = dt.Rows.Count;

        try
        {
            sqlConn.Open();
            if (dt != null && dt.Rows.Count != 0)
                bulkCopy.WriteToServer(dt);
        }
        catch (Exception ex)
        {
            throw ex;
        }
        finally
        {
            sqlConn.Close();
            if (bulkCopy != null)
                bulkCopy.Close();
        }
    }
    public static DataTable GetTableSchema2()
    {
        DataTable dt = new DataTable();
        dt.Columns.AddRange(new DataColumn[]{
            new DataColumn("id",typeof(int)),
            new DataColumn("tzid",typeof(int)),
            new DataColumn("spid",typeof(string)),
            new DataColumn("spidhex",typeof(string)),
            new DataColumn("zdr",typeof(string)),
            new DataColumn("zdrq",typeof(DateTime))
        });

        return dt;
    }
    public static DataTable GetTableSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.AddRange(new DataColumn[]{
            new DataColumn("spid",typeof(string)),
            new DataColumn("spidhex",typeof(string))
        });

        return dt;
    }

    private DataTable getSpid()
    {
        DataTable dt = null;
        string strSql = @"SELECT ckid,spid,ghsid,khid FROM yx_T_spidb WHERE lydjid IN (1796638,1787296,1789145,1789104,1789511,1788677,1786101,1795095,1789545,1757891,1789495,1787314,1787305,1796656,1796688)";
        List<SqlParameter> lstParams = new List<SqlParameter>();
        try
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
            {
                string strInfo = dal.ExecuteQuerySecurity(strSql, lstParams, out dt);
            }
        }
        catch (Exception e)
        {

        }
        return dt;

    }


    public bool IsReusable
    {
        get { return true; }
    }
}

