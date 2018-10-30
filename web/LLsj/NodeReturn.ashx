<%@ WebHandler Language="C#" Class="NextAduiter"  debug="true"%>

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
        int userid = int.Parse(context.Session["userid"].ToString());
        int flow_docID = int.Parse(context.Request.QueryString["docid"].ToString()); ;
        int nodeid = int.Parse(context.Request.QueryString["nodeid"].ToString());
        SqlParameter[] paramters = new SqlParameter[]{
                new SqlParameter("@docID", flow_docID),
                new SqlParameter("@currentNodeID", nodeid)
            };
        ArrayList list = new ArrayList();
        using (SqlDataReader read = sqlhelper.ExecuteReader(@"flow_up_getReturnNode",
                CommandType.StoredProcedure, paramters))
        {
            while(read.Read())
            {
                list.Add(String.Format("{{\"nodeid\":\"{0}\",\"nodename\":\"{1}\"}}",
                    read["nodeid"], read["nodename"]));
            }
        }
        context.Response.Write("{\"nodes\":["+string.Join(",", list.ToArray(typeof(string)) as string[])+"]");
        list.Clear();
        SqlParameter[] _paramters = new SqlParameter[]{
                new SqlParameter("@docID", flow_docID),
                new SqlParameter("@currentNodeID", nodeid)
            };
        using (SqlDataReader read = sqlhelper.ExecuteReader(@"flow_up_getReturnNodeUser",
                CommandType.StoredProcedure, _paramters))
        {
            while (read.Read())
            {
                //userid,username
                list.Add(String.Format("{{\"nodeid\":\"{0}\",\"userid\":\"{1}\",\"username\":\"{2}\"}}",
                   read["nodeid"], read["userid"], read["username"]));
            }
        }
        context.Response.Write(",\"users\":[" + string.Join(",", list.ToArray(typeof(string)) as string[]) + "]}");
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}