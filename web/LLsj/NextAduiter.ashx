<%@ WebHandler Language="C#" Class="NextAduiter" %>

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
        int tzid = 1;
        int zbid = 1;
        int userid = int.Parse(context.Session["userid"].ToString());
        string xtlb = "Z";
        string username = "";
        int flow_docID = int.Parse(context.Request.QueryString["docid"].ToString());
        int nodeid = int.Parse(context.Request.QueryString["nodeid"].ToString());
        SqlParameter[] paramters = new SqlParameter[]{
                new SqlParameter("@docID", flow_docID),
                new SqlParameter("@nodeID", nodeid),
                new SqlParameter("@userssid", tzid),
                new SqlParameter("@zbid", zbid),
                new SqlParameter("@userid", userid),
                new SqlParameter("@username", username),
                new SqlParameter("@xtlb", xtlb)
            };
        ArrayList list = new ArrayList();
        using (SqlDataReader read = sqlhelper.ExecuteReader(@"flow_up_getNodeUser",
                CommandType.StoredProcedure, paramters))
        {
            while(read.Read())
            {
                //userid,username
                list.Add(String.Format("{{\"userid\":\"{0}\",\"username\":\"{1}\"}}",
                    read["userid"], read["username"]));
            }
        }
        context.Response.Write("["+string.Join(",", list.ToArray(typeof(string)) as string[])+"]");
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}