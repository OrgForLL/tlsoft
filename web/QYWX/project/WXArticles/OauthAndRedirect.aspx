<%@ Page Language="C#" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e){
        string redic_url = Convert.ToString(Request.Params["redic_url"]);
        String userid = Convert.ToString(Session["id"]);
        //微信鉴别类型        
        String WXType = Convert.ToString(Request.Params["wxtype"]);
        userid = "";                   
        if (userid == null || userid == "" || userid == "0")
        {
            if (WXType == "retail") {                
                SharedClass.CheckOAth(HttpUtility.UrlEncode(redic_url));                
                return;
            }
            else if (WXType == "enterprise") {                
                WxHelper cs = new WxHelper();                               
                string OAappID = "wxe46359cef7410a06";
                string OAappSecret = "w0IiKV3RGY6lzcx1QjdzMdWfhVMJEFOmnl_6HpYzfCgyNpORbyj6wlBnvmv2bw7x";                
                string QYuserid = cs.GetQYOAuthUserid(OAappID, OAappSecret, "1");                
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
                    string sql = "select id,cname from t_user where name='" + QYuserid + "';";
                    System.Data.DataTable dt = null;
                    string errInfo = dal.ExecuteQuery(sql,out dt);                    
                    if (errInfo == "")
                    {                        
                        if (dt.Rows.Count > 0)
                        {
                            Session["id"] = dt.Rows[0]["id"].ToString();
                            Session["cname"] = dt.Rows[0]["cname"].ToString();
                            if (redic_url == "")
                                clsSharedHelper.WriteSuccessedInfo("利郎企业号鉴权成功！");
                            else
                                Response.Redirect(redic_url);
                        }
                        else
                        {
                            //Response.Write("在利郎企业号中找不到您的用户信息！");
                            Response.Redirect("qynouserinfo.aspx?redic_url=" + HttpUtility.UrlEncode(redic_url));
                        }
                    }
                    else
                        Response.Write(errInfo);
                }
            }
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
