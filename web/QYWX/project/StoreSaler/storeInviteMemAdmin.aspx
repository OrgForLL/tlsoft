<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server">  
    public string AppSystemKey = "", khid = "", mdid = "", mdmc = "", customersId = "", roleName = "";
    private string DBConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
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
                roleName = Convert.ToString(Session["RoleName"]);                
                if (mdid == "" || mdid == "0")
                    clsWXHelper.ShowError("对不起，您没有门店信息，无法使用此功能！");
                else
                {
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr)) {
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
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        .mywrap {
            background-color:rgba(0,0,0,.8);
            width:100%;
            height:100%;
        }
        #main {
            padding: 0;
            background-image:url(../../res/img/storesaler/page_bg.jpg);
            background-size:cover;
            background-repeat:no-repeat;
            background-position:center center;
        }
        .content {
            padding:20px;
        }
        .title,.storeName {
            color:#fff;
            font-weight:bold;
            font-size:16px;
            border-bottom:1px solid #666;
            padding-bottom:10px;
        }
        .storeName {
            text-align:center;
            border-bottom:none;
            padding-bottom:20px;
            font-size:20px;
        }
        .qrcode {
            padding:10px;
            background-color:#fff;
            margin:24px auto;
            display:block;
        }
        .tips {
            color:#888;
            line-height:24px;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page" id="main">
            <div class="mywrap">
                <div class="content">
                    <p class="storeName"><%=mdmc %></p>
                    <p class="title">关注本店请扫下方二维码</p>
                    <img class="qrcode" src="" />
                    <p class="title">使用说明</p>
                    <p class="tips" style="margin-top:10px;">1.具有门店信息的全渠道用户才可以使用该功能，如店长、导购等身份；</p>
                    <p class="tips">2.若顾客之前没有绑定门店信息则扫描上方的二维码后将与当前店铺绑定；</p>
                    <p class="tips">3.反之若顾客之前已经绑定了门店，扫码后并不会改变原有的绑定关系！</p>                    
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript">        
        window.onload = function () {            
            var targetSrc = escape("http://tm.lilanz.com/project/vipweixin/storeinvitemem.aspx?mdid=<%=mdid%>");            
            $(".qrcode").attr("src", "http://tm.lilanz.com/oa/project/StoreSaler/GetQrCode.aspx?code=" + targetSrc);
            LeeJSUtils.stopOutOfPage("#main", true);
        }
    </script>
</body>
</html>
