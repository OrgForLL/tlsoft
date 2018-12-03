<%@ WebHandler Language="C#" Class="gotoWX" %>

using System;
using System.Web;
using System.IO;
using System.Net;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography.X509Certificates;
using System.Net.Security;

public class gotoWX : IHttpHandler
{    
    public void ProcessRequest(HttpContext context){
        WXJumpOuterSite jump = new WXJumpOuterSite(@"http://192.168.35.231/service/wszxddatapull.asmx?");
        context.Response.Write(jump.Post(context.Request));
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
    
   
    
}