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
        
        TLBaseData._MyData sqlHelp = new TLBaseData._MyData();    //��ȡ���ݿ�����
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

        object myconn = MyData.MyConn(mytzid);     //���ݴ�������tzid������ת

        sql = sql.Trim();
        if (sql.Length == 0) 
        {
            context.Response.Write("��������쳣�������ԣ�");
            context.Response.End();
        }
        mysql = sql;
        //DataSet ds = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn(), mysql);
        DataSet ds = (DataSet)MyData.MyDataSet(myconn, mysql);   //���Ը�����
        if (ds.Tables[0].Rows.Count > 0 && sql.Length > 0)
        {
            returnV = "�ύ�ɹ�";
            returnV = ds.Tables[0].Rows[0][0].ToString();
        }
        else
        {
            returnV = "�ύʧ��"; 
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