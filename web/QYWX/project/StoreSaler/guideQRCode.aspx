<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public string ConfigKey = "", StoreID = "", CustomerID = "";
    public string cusAvatar = "", cusName = "", cusStore = "";
    private string DBConnStr = clsConfig.GetConfigValue("OAConnStr");
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string AppSystemKey = clsWXHelper.GetAuthorizedKey(3);//全渠道系统
            if (AppSystemKey == "")
                clsWXHelper.ShowError("您还未开通全渠道系统权限,请联系IT解决！");
            else
            {
                CustomerID = Convert.ToString(Session["qy_customersid"]);
                StoreID = Convert.ToString(Session["mdid"]);
                if (string.IsNullOrEmpty(StoreID) || StoreID == "0")
                    clsWXHelper.ShowError("对不起，您没有门店信息，无法使用此功能！");
                else
                {
                    ConfigKey = clsErpCommon.GetStoreSSKey(StoreID);
                    if (string.IsNullOrEmpty(ConfigKey) || ConfigKey == "0" || ConfigKey == "-1")
                        clsWXHelper.ShowError("获取当前门店所属CONFIGKEY失败！" + ConfigKey);
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
                    {
                        string str_sql = @"declare @mdmc varchar(200);
                                            select @mdmc=mdmc from t_mdb where mdid=@mdid;
                                            select isnull(@mdmc,'') mdmc,cname,avatar from wx_t_customers where id=@cid";
                        List<SqlParameter> paras = new List<SqlParameter>();
                        paras.Add(new SqlParameter("@mdid", StoreID));
                        paras.Add(new SqlParameter("@cid", CustomerID));
                        DataTable dt;
                        string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                        if (errinfo == "" && dt.Rows.Count > 0)
                        {
                            string _avatar = Convert.ToString(dt.Rows[0]["avatar"]);
                            cusName = Convert.ToString(dt.Rows[0]["cname"]);
                            cusStore = Convert.ToString(dt.Rows[0]["mdmc"]);
                            if (clsWXHelper.IsWxFaceImg(_avatar))
                                cusAvatar = clsWXHelper.GetMiniFace(_avatar);
                            else
                                cusAvatar = string.Concat("../../", _avatar);
                        }
                        dt.Clear(); dt.Dispose();
                    }//end using
                }
            }//全渠道鉴权通过            
        }
    }
</script>
<html>

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>邀请会员V2</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/guideQRCode.css" />
</head>
<body>
    <div class="page">
        <div class="container">
            <div class="guideInfo">
                <div class="avatar_wrap">
                    <div class="avatar" style="background-image: url(<%=cusAvatar%>)"></div>
                </div>
                <div class="guide_txt">
                    <p class="guide_name"><%=cusName %></p>
                    <p class="guide_shop"><%=cusStore %></p>
                </div>
            </div>
            <img class="qrcode" src="">
            <p class="tips">扫一扫二维码，关注我！</p>
        </div>
        <div class="logo">
            <p class="text">LILANZ</p>
            <p class="copyright">&copy;2018 利郎(中国)有限公司</p>
        </div>
    </div>

    <script type="text/javascript">
        var cid = "<%=CustomerID%>", mdid = "<%=StoreID%>", configkey = "<%=ConfigKey%>";
        window.onload = function () {
            var _target = "";
            if (configkey == "5") {
                _target = escape("http://tm.lilanz.com/project/NewVip/VSBV2.aspx?cid=" + "<%=CustomerID%>" + "&mdid=" + "<%=StoreID%>");
                document.querySelector(".logo .text").innerText = "利郎男装 | LESS IS MORE";
                document.querySelector(".qrcode").setAttribute("src", "http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" + _target);
            } else if (configkey == "7") {
                _target = escape("http://tm.lilanz.com/vip2/project/NewVip/VSBV2.aspx?cid=" + "<%=CustomerID%>" + "&mdid=" + "<%=StoreID%>");
                document.querySelector(".logo .text").innerText = "利郎轻商务 | LESS IS MORE";
                document.querySelector(".qrcode").setAttribute("src", "http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" + _target);
            }
        }
    </script>
</body>
</html>
