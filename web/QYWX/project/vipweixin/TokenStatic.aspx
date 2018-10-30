<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    private string ConfigKeyValue = "5";//利郎男装
    private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private string DBConstr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string TestDBConstr = "server=192.168.35.23;uid=lllogin;pwd=rw1894tla;database=tlsoft";

    public string openid = "", wxid = "", wxnick = "", wxhead = "";
    protected void Page_Load(object sender, EventArgs e)
    {

    }
</script>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        .page {
         background-color:#efefef;   
        }

        body {
            color: #363c44;
            -webkit-font-smoothing: antialiased;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page" id="index">

        </div>
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type="text/javascript">
        $(document).ready(function () {
            LeeJSUtils.LoadMaskInit();
            FastClick.attach(document.body);
        });
    </script>
</body>
</html>
