<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private string WXDBConnStr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private string ZBDBConnStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    public string user_id = "", user_type = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        //先判断用户是否在IM中打开
        string apptoken = Convert.ToString(Request.Params["apptoken"]);
        if (!string.IsNullOrEmpty(apptoken))
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
            {
                string str_sql = @"select top 1 uid from wx_t_appLoginStatus where token=@token;";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@token", apptoken));
                object scalar;
                string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                if (errinfo == "" && Convert.ToInt32(scalar) > 0)
                {
                    user_id = Convert.ToString(scalar);
                    user_type = "lilanzim";
                }
            }
        }
        else
        {
            //判断是否在微信中打开
            string userAgent = Request.UserAgent;
            if (userAgent.ToLower().Contains("micromessenger") && clsWXHelper.CheckUserAuth("5", "openid"))
            {
                string openid = Convert.ToString(Session["openid"]);
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ZBDBConnStr))
                {
                    string str_sql = @"select top 1 id from wx_t_vipbinging where wxopenid=@openid;";
                    List<SqlParameter> paras = new List<SqlParameter>();
                    paras.Add(new SqlParameter("@openid", openid));
                    object scalar;
                    string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                    if (errinfo == "" && Convert.ToInt32(scalar) > 0)
                    {
                        user_id = Convert.ToString(scalar);
                        user_type = "weixin";
                    }
                }
            }
        }
    }
</script>

<!DOCTYPE html>
<html>

<head>
    <meta charset=utf-8>
    <meta name=viewport content="width=device-width,initial-scale=1,user-scalable=no">
    <title>利郎供应商储备</title>
    <script type=text/javascript>var USER_ID = '<%=user_id%>';
    var USER_TYPE = '<%=user_type%>';</script>
    <link href=./static/css/app.e3662ece953c741529aa0f12d05c8fcd.css rel=stylesheet>
</head>

<body ontarchstart>
    <div id=app></div>
    <script charset="utf-8" type=text/javascript src="https://webapi.amap.com/maps?v=1.3&key=9eacb6f7f03f180ea391814261cf2f21&plugin=AMap.Geocoder"></script>
    <script charset="utf-8" type=text/javascript src=./static/js/manifest.3ad1d5771e9b13dbdad2.js></script>
    <script charset="utf-8" type=text/javascript src=./static/js/vendor.47a23c9687e30174432c.js></script>
    <script charset="utf-8" type=text/javascript src=./static/js/app.fdfa9735c7c8c87c3f6e.js></script>
</body>

</html>