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
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
    <title>利郎供应商资源储备</title>
    <script type="text/javascript">
        var USER_ID = "<%=user_id%>";
        var USER_TYPE = "<%=user_type%>";
    </script>
    <link href="./static/css/app.800e6fc8c11c11af6906bbbd3c60f41f.css" rel="stylesheet">
</head>
<body>
    <div id="app"></div>
    <script charset="utf-8" type="text/javascript" src="http://tm.lilanz.com/qywx/test/area.js"></script>
    <script charset="utf-8" type="text/javascript" src="./static/js/manifest.3ad1d5771e9b13dbdad2.js"></script>
    <script charset="utf-8" type="text/javascript" src="./static/js/vendor.a095eebfb0c4581ad3d9.js"></script>
    <script charset="utf-8" type="text/javascript" src="./static/js/app.5567e8b9456c4bfa0a53.js"></script>
</body>
</html>
