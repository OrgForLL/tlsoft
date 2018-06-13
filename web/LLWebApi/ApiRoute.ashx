<%@ WebHandler Language="C#" Class="ApiRoute" Debug="true" %>
using System;
using System.Web;
public class ApiRoute : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        if (context.Request.Params["action"] == null)
        {
            rspInfo("100","路由参数异常","");
        }
        
        switch(context.Request.Params["action"].ToString().ToUpper())
        {
            case "LLAPI_KD_BES":
                //根据serviceType服务类型调用不同接口实现; 返回结果如下
                HttpContext.Current.Server.TransferRequest("service/LLKdReceive.ashx", true);
                break;
            case "LLWEBAPI":
                //根据serviceType服务类型调用不同接口实现; 返回结果如下
                HttpContext.Current.Server.TransferRequest("LLWebApiRoute.ashx", true);
                break;
            default :
                rspInfo("101", "无效接口", "");
                break;           
        }        
    }
    private void rspInfo(string code, string msg, string body)
    {
        string str = "\"errcode\":\"{0}\",\"errmsg\":\"{1}\",\"body\":\"{2}\"";
        HttpContext.Current.Response.Write("{" + string.Format(str, code, msg, body) + "}");
        HttpContext.Current.Response.End();
    }
    public bool IsReusable
    {
        get { return true; }
    }
}


