<%@ WebHandler Language="C#" Class="mTagPick" %>
using System.Web;
using System.Collections.Generic;
using System;
using System.Security.Cryptography;
using System.Text;
using nrWebClass;
public class mTagPick : IHttpHandler
{

    string connStr = "";
    public void ProcessRequest(HttpContext context)
    {

        context.Response.ContentType = "text/plain";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            connStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
            //connStr = dal.ConnectionString;
            dal.ConnectionString = connStr;

        }
        context.Response.Write("");
    }





    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}
 