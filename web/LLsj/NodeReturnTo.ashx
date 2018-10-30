<%@ WebHandler Language="C#" Class="NextAduiter" Debug="true" %>

using System;
using System.Web;
using System.Data.SqlClient;
using System.Data;
using System.Collections;
using System.Web.SessionState;
public class NextAduiter : IHttpHandler, IRequiresSessionState
{

    nrWebClass.LiLanzDAL sqlhelper = new nrWebClass.LiLanzDAL();
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        string tzid = context.Session["userssid"].ToString();
        string zbid = context.Session["zbid"].ToString();
        int userid = int.Parse(context.Session["userid"].ToString());
        string xtlb = context.Session["xtlb"].ToString();
        string username = context.Session["username"].ToString();
        int flow_docID = int.Parse(context.Request.QueryString["docid"].ToString());
        int nodeid = int.Parse(context.Request.QueryString["nodeid"].ToString());
        string note = context.Request.QueryString["note"].ToString();
        SqlParameter[] paramters = new SqlParameter[]{
                new SqlParameter("@docID", flow_docID),
                new SqlParameter("@returnNodeID", nodeid),
                new SqlParameter("@returnNodeUser", userid),
                new SqlParameter("@opinion", note),
                new SqlParameter("@userid", userid),
                new SqlParameter("@userssid", tzid),
                new SqlParameter("@zbid", zbid),
                new SqlParameter("@xtlb", xtlb),
                new SqlParameter("@username", username),
                new SqlParameter("@pldocid", ""),
                new SqlParameter("@val","")
            };
        paramters[10].Direction = ParameterDirection.ReturnValue;        
        sqlhelper.ExecuteNonQuery(@"flow_up_sendReturnNode", CommandType.StoredProcedure, paramters);
        if (paramters[10].Value.ToString() == "1")
            context.Response.Write("done");
        else
            context.Response.Write("err");
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}