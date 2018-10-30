<%@ WebHandler Language="C#" Class="ErpOauth" %>

using System;
using System.Web;
using System.Web.SessionState;
using nrWebClass;
using System.Data;
public class ErpOauth : IHttpHandler,IRequiresSessionState {

    public void ProcessRequest (HttpContext context) {
        clsWXHelper.ClearAT("1");
        clsWXHelper.ClearAT("5");
        clsWXHelper.ClearAT("7");
            clsSharedHelper.WriteSuccessedInfo(clsWXHelper.GetAT("1"));
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}