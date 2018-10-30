<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">      
    protected void Page_Load(object sender, EventArgs e) {
        string DBConnStr = clsConfig.GetConfigValue("OAConnStr");
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string wxid = Convert.ToString(Request.Params["wxid"]);
        if (mdid == "" || mdid == "0" || mdid == null)
            clsSharedHelper.WriteErrorInfo("请检查传入的参数【MDID】！");
        else if (wxid == "" || wxid == "0" || wxid == null)
            clsSharedHelper.WriteErrorInfo("请检查传入的参数【WXID】！");
        else {
            using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConnStr)) {
                string str_sql = @"select top 1 a.mdmc,kh.vipbs,a.ty
                                    from t_mdb a 
                                    inner join yx_t_khb kh on a.khid=kh.khid
                                    where a.mdid=@mdid and a.ty=0";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@mdid", mdid));
                DataTable dt;
                string errinfo = dal10.ExecuteQuerySecurity(str_sql,paras,out dt);
                if (errinfo == "")
                    if (dt.Rows.Count > 0)
                    {
                        if (Convert.ToString(dt.Rows[0]["vipbs"]).StartsWith("new") == false)
                            clsSharedHelper.WriteErrorInfo("对不起，【" + Convert.ToString(dt.Rows[0]["mdmc"]) + "】还未加入利郎新积分体系！");
                        else {
                            str_sql = @"declare @khid int;
                                        select top 1 @khid=khid from t_mdb where mdid=@mdid;                                        
                                        update wx_t_vipbinging set khid=@khid,mdid=@mdid where id=@wxid and objectid=1;
                                        update b set b.khid=@khid,b.mdid=@mdid
                                        from wx_t_vipbinging a
                                        inner join yx_t_vipkh b on a.vipid=b.id
                                        where a.id=@wxid and a.objectid=1";
                            paras.Clear();
                            paras.Add(new SqlParameter("@mdid", mdid));
                            paras.Add(new SqlParameter("@wxid", wxid));
                            errinfo = dal10.ExecuteNonQuerySecurity(str_sql, paras);
                            if (errinfo == "")
                                clsSharedHelper.WriteSuccessedInfo("");
                            else
                                clsSharedHelper.WriteErrorInfo(errinfo);
                        }
                    }
                    else
                        clsSharedHelper.WriteErrorInfo("请检查传入参数【MDID】的有效性！");
                else
                    clsSharedHelper.WriteErrorInfo(errinfo);
            }//end using
        }
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
