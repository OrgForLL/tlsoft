<%@ WebHandler Language="C#" Class="Mobile_deal" %>

using System;
using System.Web;
using System.Data;
using System.IO;

public class Mobile_deal : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        //context.Response.Write(context.Request["sql"].ToString());
        //context.Response.End();
        context.Response.ContentType = "text/plain";
        
        TLBaseData._MyData sqlHelp = new TLBaseData._MyData();    //获取数据库连接
        Class_TLComm.MyBaseConn MyL = new Class_TLComm.MyBaseConn("");
        Class_BBweb.Mydata m = new Class_BBweb.Mydata();
        Class_TLtools.MyData MyData = new Class_TLtools.MyData();

        string returnV = "";
        string mysql = "";
        string mytzid = "1";
        string ppdm = context.Request["ppdm"].ToString();
        if (ppdm.Length > 0)
        {
            if (ppdm == "jtcw")
            {
                mytzid = "6784";
            }
            else if (ppdm == "zpp")
            {
                mytzid = "1";
            }
            else if (ppdm.Split('|')[0] == "kh")
            {
                mytzid = ppdm.Split('|')[1];
            }
        }
        string sql = context.Request["sql"].ToString();
        string bid = context.Request["bid"].ToString();

        object myconn = MyData.MyConn(mytzid);     //根据传进来的tzid进行跳转

        sql = sql.Trim();
        if (sql.Length == 0) 
        {
            context.Response.Write("传入参数异常，请重试！");
            context.Response.End();
        }
        mysql = sql;
        //DataSet ds = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn(), mysql);
        DataSet ds = (DataSet)MyData.MyDataSet(myconn, mysql);   //可以改套帐
        if (ds.Tables[0].Rows.Count > 0 && sql.Length > 0)
        {
            returnV = "提交成功";
            returnV = ds.Tables[0].Rows[0][0].ToString();
        }
        else
        {
            returnV = "提交失败"; 
        }
        context.Response.Write(returnV);
        context.Response.End();
/*
        string optionlist = "";

        TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
        string sql = "select * from t_uploadfile where id='" + fileID + "'";
        DataSet ds = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn(), sql);
        if (ds.Tables[0].Rows.Count > 0)
        {
            string url = ds.Tables[0].Rows[0]["URLAddress"].ToString();
            string filepath = context.Server.MapPath(url);
            FileInfo fi = new FileInfo(filepath);
            if (fi.Exists)
                fi.Delete();
            sql = "delete from t_uploadfile where id='" + fileID + "'";
            sqlHelp.MyDataTrans(sqlHelp.GetConn(), sql);
        }
*/
        
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}