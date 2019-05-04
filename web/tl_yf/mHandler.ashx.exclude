<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using MicroService;

public class Handler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {

        Stock stock = new Stock();
        string api = context.Request.Form["api"];
        int mykey =int.Parse( context.Request.Form["mykey"].ToString());
        int tableID =int.Parse( context.Request.Form["tableID"].ToString());
        string json = context.Request.Form["json"];
        context.Response.ContentType = "text/plain";
        context.Response.Write(stock.upData(api, mykey,tableID,json));

    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}