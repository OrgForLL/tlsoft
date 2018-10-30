<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server">  
    public string AppSystemKey = "", khid = "", mdid = "", mdmc = "", customersId = "", ConfigKey = "";
    //private string DBConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    //CurrentConfigKey
    private string DBConnStr = clsConfig.GetConfigValue("OAConnStr");
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            AppSystemKey = clsWXHelper.GetAuthorizedKey(3);//全渠道系统
            if (AppSystemKey == "")
                clsWXHelper.ShowError("您还未开通全渠道系统权限,请联系IT解决！");
            else
            {
                customersId = Convert.ToString(Session["qy_customersid"]);
                mdid = Convert.ToString(Session["mdid"]);
                khid = Convert.ToString(Session["tzid"]);
                if (mdid == "" || mdid == "0")
                    clsWXHelper.ShowError("对不起，您没有门店信息，无法使用此功能！");
                else
                {
                    ConfigKey = clsErpCommon.GetStoreSSKey(mdid);
                    if (string.IsNullOrEmpty(ConfigKey) || ConfigKey == "0" || ConfigKey == "-1")
                        clsWXHelper.ShowError("获取当前门店所属CONFIGKEY失败！" + ConfigKey);
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
                    {
                        string str_sql = "select top 1 mdmc from t_mdb where mdid='" + mdid + "'";
                        object scalar;
                        string errinfo = dal.ExecuteQueryFast(str_sql, out scalar);
                        mdmc = Convert.ToString(scalar);
                    }
                }
            }//全渠道鉴权通过            
        }
    }
</script>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <title>关注店铺</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <style type="text/css">
        body, html {
            background-color: #f0f0f0;
        }

        .page {
            background-color: #f0f0f0;
            height: 100%;
        }

        .container {
            max-height: 100%;
            overflow-y: auto;
        }

            .container::-webkit-scrollbar {
                height: 0;
                display: none;
            }

        .page.index {
            padding: 15px 10px;
        }

        .qrcode_card {
            background-color: #fff;
            padding: 10px;
            padding-top: 40px;
            border-radius: 4px;
        }

        .index .logo {
            width: 56px;            
            height: auto;
            display: block;
            margin: 0 auto;
            margin-bottom: -30px;
        }

        .gzh_name {
            text-align: center;
            color: #888;
        }

        .qrcode_card .title {
            text-align: center;
            color: #2f2f2f;
            font-size: 18px;
            font-weight: bold;
            margin: 20px 0 5px 0;
        }

            .qrcode_card .title.sub {
                text-align: center;
                color: #999;
                font-size: 13px;
                margin: 0;
            }

        #store_qrcode {
            margin: 15px auto;
            width: 180px;
            height: auto;
            display: block;
        }

        .tips {
            padding: 0 10px;
        }

            .tips .title {
                text-align: left;
                color: #444;
                font-size: 14px;
                margin: 0;
            }

            .tips .params {
                color: #888;
                line-height: 24px;
            }

        .copy_right {
            text-align: center;
            padding-top: 10px;
            font-size: 12px;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page index">
            <div class="container">
                <img class="logo" src="" />
                <div class="qrcode_card">
                    <p class="gzh_name">LILANZ</p>
                    <p class="title"><%=mdmc %></p>
                    <p class="title sub">关注本店请扫下方二维码</p>
                    <img id="store_qrcode" src="http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" />
                    <div class="tips">
                        <p class="title">使用说明</p>
                        <p class="params">1.具有门店信息的全渠道用户才可以使用该功能，如店长、导购等身份；</p>
                        <p class="params">2.若顾客之前没有绑定门店信息则扫描上方的二维码后将与当前店铺绑定；</p>
                        <p class="params">3.反之若顾客之前已经绑定了门店，扫码后并不会改变原有的绑定关系！</p>
                        <p class="copy_right">&copy;2018 利郎（中国）有限公司</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript">
        var ConfigKey = "<%=ConfigKey%>";
        window.onload = function () {
            if (ConfigKey == "5") {
                document.querySelector(".gzh_name").innerText = "利郎男装";
                var targetSrc = escape("http://tm.lilanz.com/project/NewVip/storeInviteMemV2.aspx?mdid=<%=mdid%>");
                document.querySelector("#store_qrcode").setAttribute("src", "http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" + targetSrc);
                document.querySelector(".logo").setAttribute("src", "../../res/img/logo_lilanz.png");
            } else if (ConfigKey == "7") {
                document.querySelector(".gzh_name").innerText = "利郎轻商务";
                var targetSrc = escape("http://tm.lilanz.com/vip2/project/NewVip/storeInviteMemV2.aspx?mdid=<%=mdid%>");
                document.querySelector("#store_qrcode").setAttribute("src", "http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" + targetSrc);
                document.querySelector(".logo").setAttribute("src", "../../res/img/logo_qsw.png");
            }
        }
    </script>
</body>
</html>
