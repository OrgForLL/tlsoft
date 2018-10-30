<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>

<!DOCTYPE html>
<script runat="server">  
    public string bindResult = "", ConfigKeyValue = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string storeName = "";
        if (mdid == "0" || mdid == "" || mdid == null)
        {
            bindResult = "Error:缺少必要参数！";
            return;
        }
        else
        {
            //20180420 liqf 流程有调整 统一调用小薛封装好的方法
            ConfigKeyValue = clsErpCommon.GetStoreSSKey(mdid);            
            if (ConfigKeyValue == "0")
            {
                bindResult = "Error:MDID无效！";
                return;
            }
            else if (ConfigKeyValue == "-1")
            {
                bindResult = "Error:门店已停用！";
                return;
            }
        }

        //微信公众号鉴权
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            string openid = Convert.ToString(Session["openid"]);
            storeName = getStoreName(Convert.ToInt32(mdid));
            string result = clsWXHelper.FansBindStore(openid, Convert.ToInt32(mdid), clsWXHelper.DisBindVipOpinion.顾客主动扫描关注其它店铺);
            JObject jo = JObject.Parse(result);
            if (Convert.ToString(jo["errcode"]) == "0")
                bindResult = "Successed:尊敬的用户，您已经成功绑定到【" + storeName + "】！";
            else
                bindResult = "Error:关注失败！ 原因：" + Convert.ToString(jo["errmsg"]);

            //bindResult = bindResult.Replace("\"", "");
        }
    }

    public string getStoreName(int StoreID)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
        {
            string str_sql = "select top 1 mdmc from t_mdb where mdid=@mdid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mdid", StoreID));
            object scalar;
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
            if (errinfo == "")
                return Convert.ToString(scalar);
            else
                return "";
        }//end using
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <title>正在处理,请稍候..</title>
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
</head>
<body>
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <script type="text/javascript">
        window.onload = function () {
            var msg = "<%=bindResult%>";
            var touchURL = "./touchFollowV2.html?key=" + "<%=ConfigKeyValue%>";
            if (msg.indexOf("Successed:") > -1) {
                swal({
                    title: "关注成功！",
                    text: msg.replace("Successed:", ""),
                    type: "success",
                    confirmButtonColor: "#59a714",
                    confirmButtonText: "确定"
                }, function (isConfirm) {
                    //WeixinJSBridge.call('closeWindow');
                    window.location.href = touchURL;
                });
            } else {
                swal({
                    title: "关注失败！",
                    text: msg.replace("Error:", ""),
                    type: "error",
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "确定"
                }, function (isConfirm) {
                    //WeixinJSBridge.call('closeWindow');
                    window.location.href = touchURL;
                });
            }
        }
    </script>
</body>
</html>
