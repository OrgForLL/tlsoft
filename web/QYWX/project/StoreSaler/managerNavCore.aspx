<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private string WXDBConstr = "";
    private string OAConstr = clsConfig.GetConfigValue("OAConnStr"); 
    
    protected void Page_Load(object sender, EventArgs e)
    { 
        if (clsConfig.Contains("WXConnStr"))
        {
            WXDBConstr = clsConfig.GetConfigValue("WXConnStr");
        }
        else
        {
            WXDBConstr = System.Web.Configuration.WebConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        }
        
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "getCompanyList":
                string roleName = Convert.ToString(Request.Params["roleName"]);
                string userid = Convert.ToString(Request.Params["userid"]);
                if (roleName == "")
                    clsSharedHelper.WriteErrorInfo("请检查传入的参数！");
                else
                    getCompanyList(roleName, userid);
                break;
            case "getStoreList":
                string khid = Convert.ToString(Request.Params["khid"]);
                if (khid == "" || khid == "0")
                    clsSharedHelper.WriteErrorInfo("请检查传入的参数！");
                else
                    getStoreList(khid);
                break;
            case "setSession":
                khid = Convert.ToString(Request.Params["khid"]);
                roleName = Convert.ToString(Request.Params["roleName"]);
                string mdid = Convert.ToString(Request.Params["mdid"]);
                string ManagerStore = Convert.ToString(Request.Params["ManagerStore"]);
                setSession(khid, mdid, ManagerStore, roleName);
                break;
            case "applogin":
                Session["qy_customersid"] = "138";
                Session["qy_name"]="ghw";
                Session["qy_cname"]="官海文";
                Session["qy_mobile"]="18960250808";
                Session["qy_status"]="1";
                Session["qy_OpenId"]="";
                Session["RoleName"] = "zb";
                Session["tzid"] = "1";
                clsSharedHelper.WriteSuccessedInfo("");
                break;
            case "clearSession":
                clearSession();
                break;
            default:
                clsSharedHelper.WriteErrorInfo("请检查传入的CTRL是否有效！");
                break;
        }
    }

    private void setSession(string khid, string mdid, string mname, string rolename) {
        //注意dz角色时虽然有传mname过来但是不写入！！！
        if (rolename == "kf" || rolename == "zb" || rolename == "my")
        {
            Session["tzid"] = khid;
            Session["mdid"] = mdid;
            Session["ManagerStore"] = mname;
            if (mdid != "")
            {
                Session["RoleName"] = "dz"; //薛灵敏增加以下两个属性
                Session["RoleID"] = "2";
            }

            clsSharedHelper.WriteSuccessedInfo("");
        }
        else
            clsSharedHelper.WriteErrorInfo("越权操作！");
    }

    private void clearSession() {
        Session.Clear();
        clsSharedHelper.WriteSuccessedInfo("");
    }
    
    public void getStoreList(string khid) {
        using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(OAConstr)) {
            string str_sql = @"select khid,mdid,upper(mddm) mddm,mdmc from t_mdb where khid=@khid
                                union all                                            
                                select b.khid,b.mdid,upper(B.mddm),B.mdmc from yx_t_khb A
                                inner join t_mdb B on A.khid = B.khid AND ISNULL(A.ty,0) = 0 AND ISNULL(B.ty,0) = 0
                                where A.ssid=@khid";
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@khid", khid));
            string errinfo = dal10.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                string rt = JsonHelp.dataset2json(dt);
                dt.Clear(); dt.Dispose();
                clsSharedHelper.WriteInfo(rt);
            }
            else
                clsSharedHelper.WriteErrorInfo("查询数据时出错 " + errinfo);
        }//end using
    }

    public void getCompanyList(string roleName,string customersId) {        
        using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(OAConstr)) {
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr)) {
                string str_sql = "",errinfo="";
                if (roleName == "zb" || roleName == "kf")
                    str_sql = @"select a.khid,0 mdid,upper(a.khdm)+'.'+a.khmc khmc
                            from yx_t_khb a 
                            where a.ssid=1 AND a.khfl IN ('xf','xd','xg','xk','xx') and isnull(a.ty,0)=0 and isnull(a.sfdm,'') not in('','0')
                            order by a.khdm";       // and a.yxrs=1；
                else if (roleName == "my")
                    str_sql = @"select d.khid,d.mdid,case when d.ssid=1 then '【贸】'+d.mdmc else '【店】'+d.mdmc end khmc,d.ssid
                            from wx_t_customers A 
                            inner join wx_t_AppAuthorized B ON B.UserID = A.ID AND B.SystemID = 3
                            inner join wx_t_OmniChannelUser C ON B.SystemKey = C.ID  
                            inner join t_Roles R ON C.RoleID = R.ID 
                            inner join wx_t_OmniChannelAuth D ON D.Customers_ID = A.ID AND C.ID = D.OCUID
                            where r.rolename='my' and a.id=@customersid";
                else
                    clsSharedHelper.WriteErrorInfo("越权请求数据！");

                DataTable dt;
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@customersid", customersId));

                if (roleName == "zb" || roleName == "kf")
                    errinfo = dal10.ExecuteQuerySecurity(str_sql, paras, out dt);
                else
                    errinfo = dal62.ExecuteQuerySecurity(str_sql, paras, out dt);

                if (errinfo == "")
                    if (dt.Rows.Count > 0)
                    {
                        string rt = JsonHelp.dataset2json(dt);                        
                        dt.Clear(); dt.Dispose();
                        clsSharedHelper.WriteInfo(rt);
                    }
                    else
                        clsSharedHelper.WriteErrorInfo("请检查您是否有授权管理对象！");
                else
                    clsSharedHelper.WriteErrorInfo("查询数据时出错 " + errinfo);
            }//end using62           
        }//end using10
    }    
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
