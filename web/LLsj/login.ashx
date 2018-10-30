<%@ WebHandler Language="C#" Class="login" Debug="true" %>

using System;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Web.SessionState;
public class login : IHttpHandler, IRequiresSessionState{
    nrWebClass.LiLanzDAL sqlhelper = new nrWebClass.LiLanzDAL();
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        String name = context.Request.Form["username"].ToString();
        String pwd = context.Request.Form["password"].ToString();
        SqlParameter[] paramters = new SqlParameter[]{
            new SqlParameter("@name", name),
            new SqlParameter("@pwd", nrWebClass.Security.String2MD5(pwd))
        };
        String backMsg = "";
        String Comm = "select id,cname,isnull(qx,0) qx,unid from t_user where name=@name and pass=@pwd";
        using (IDataReader dataReader = sqlhelper.ExecuteReader(Comm, CommandType.Text, paramters))
        {
            if (dataReader.Read())
            {
                
                int qx = 0;
                int.TryParse(dataReader[2].ToString(), out qx);
                context.Session["qx"] = qx;
                context.Session["userid"] = dataReader[0].ToString();
                context.Session["username"] = dataReader[1].ToString();
                context.Session["user"] = dataReader[1].ToString();
                context.Session["zbid"] = 1;
                context.Session["unid"] = dataReader[3].ToString();
                backMsg = "success";
                //log.add(Request.ServerVariables["REMOTE_ADDR"].ToString(),
                //    int.Parse(dataReader[0].ToString()), "login Success");
            }
            else
                backMsg = "用户名或密码错误";
            
        }
        context.Response.Write(backMsg);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}