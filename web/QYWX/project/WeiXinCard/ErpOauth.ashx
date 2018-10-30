<%@ WebHandler Language="C#" Class="ErpOauth" %>

using System;
using System.Web;
using System.Web.SessionState;
using nrWebClass;
using System.Data;
public class ErpOauth : IHttpHandler,IRequiresSessionState {

    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        //context.Response.Write("Hello World");
        //context.Request.ContentEncoding = System.Text.Encoding.UTF8;
        //context.Response.ContentEncoding = System.Text.Encoding.UTF8;

        if (context.Request == null)
        {
            clsSharedHelper.WriteErrorInfo("超时或非法访问！");
            return;
        }

        //string userid = Convert.ToString(context.Session["userid"]);
        //string username = Convert.ToString(context.Session["username"]);
        //string tzid = Convert.ToString(context.Session["userssid"]);

        string userid = Convert.ToString(context.Request.Params["userid"]);
        string username = Convert.ToString(context.Request.Params["username"]);
        string tzid = Convert.ToString(context.Request.Params["userssid"]);

        //用userid和username验证有效性，如果通过，则执行全渠道鉴权
        string strInfo = "";
        //string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        //using(LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        //{
        //    object objCname = "";
        //    strInfo = dal.ExecuteQuery(string.Format("SELECT TOP 1 cname FROM t_user WHERE ID={0}", userid), out objCname);
        //    if (strInfo != "")
        //    {
        //        clsSharedHelper.WriteErrorInfo(string.Concat("无法获取身份信息！错误：", strInfo));
        //        return;
        //    }
        //    if (Convert.ToString(objCname) != username)
        //    {
        //        clsSharedHelper.WriteErrorInfo(string.Concat("身份信息验证不通过！身份——", username));
        //        return;
        //    }
        //}

        context.Session["tzid"] = tzid;
        context.Session["mdid"] = "0";
        context.Session["RoleID"] = "2";
        context.Session["relateID"] = "0";
        context.Session["RoleName"] = "dz";

        //需要再获取的Session
        using(LiLanzDALForXLM dal = new LiLanzDALForXLM(clsWXHelper.GetWxConn()))
        {
            DataTable dt = null;
            strInfo = dal.ExecuteQuery(string.Format(@"SELECT TOP 1 A.id,A.cname,A.IsActive FROM wx_t_customers A
                        INNER JOIN wx_t_AppAuthorized B ON A.id = B.UserID AND B.SystemID = 1 AND B.SystemKey = '{0}'", userid), out dt);
            if (strInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("无法获取手机协同权限信息！错误：", strInfo));
                return;
            }
            if (dt.Rows.Count == 0)
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("无法获取手机协同权限信息！您还未开通手机协同权限？账号：", username));
                return;
            }

            if (Convert.ToBoolean(dt.Rows[0]["IsActive"]) == false)
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("账户(", username, ")已停用！"));
                return;
            }
            context.Session["qy_customersid"] = dt.Rows[0]["id"];
            context.Session["qy_cname"] =dt.Rows[0]["cname"];
        }

        HttpContext.Current.Response.Redirect("couponV3.aspx");
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}