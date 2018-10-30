<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server">
    public string mdid = "";
    public string AppSystemKey = "",RoleID="";
    private const string ConfigKeyValue = "1";	//微信配置信息索引值 1为企业号    
    
    private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        //Session["qy_customersid"] = "354";
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            clsWXHelper.CheckQQDMenuAuth(18);    //检查菜单权限
            
            string SystemID = "3";            
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            RoleID = Convert.ToString(Session["RoleID"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            //else if (RoleID == "1") {
            //    clsWXHelper.ShowError("对不起，越权访问！");
            //}
            else{
                mdid = Session["mdid"].ToString();                
                clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "导购业绩完成情况"));
            }
            
            if (mdid == "" || mdid == "0"){
                clsWXHelper.ShowError("该功能仅提供门店使用！");
            }
        }
        else
        {
            clsWXHelper.ShowError("鉴权失败！");
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
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link href="http://api.youziku.com/webfont/CSS/56d5c4fcf629d80420b28a91" rel="stylesheet" type="text/css" />
    <style type="text/css">
        body {
            font-size: 14px;
            background-color: #f7f7f7;
            color: #575d6a;
            font-family: "San Francisco",Helvitica Neue,Helvitica,Arial,sans-serif;
        }

        .header {
            height: 50px;
            line-height: 50px;
            text-align: center;
            font-size: 1.2em;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
        }

        .page {
            background-color: transparent;
            padding: 10px 0;
        }

        .footer {
            height: 30px;
            line-height: 30px;
            background-color: #f7f7f7;
            font-size: 0.9em;
        }

        .page-not-header-footer {
            top: 50px;
            bottom: 30px;
        }

        .header .fa-angle-left {
            position: absolute;
            top: 0;
            left: 0;
            height: 50px;
            line-height: 50px;
            padding: 0 20px;
            font-size: 1.4em;
            border-right: 1px solid #f5f5f5;
        }

            .header .fa-angle-left:hover {
                background-color: rgba(0,0,0,.1);
            }

        .target-list li {
            height: 56px;
            background-color: #fff;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            position: relative;
        }

        .target-item > p {
            padding-left: 66px;
            color: #575d6a;
            line-height: 22px;
        }

        .target-list li:not(:last-child) {
            margin-bottom: 5px;
        }

        .backimg {
            background-size: cover;
            background-position: 50% 50%;
            background-repeat: no-repeat;
        }

        .headimg {
            width: 46px;
            height: 46px;
            border-radius: 50%;
            border: 2px solid #f2f2f2;
            position: absolute;
            left: 10px;
            top: 5px;
        }

        .name {
            line-height: 24px;
        }

        .target-list li .process, .target-list li .process-mask {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;            
        }

        .target-list li .probg-by {
            background: -webkit-gradient(linear,left top,right bottom,from(#fddf81),to(#faaa05));
        }

        .target-list li .probg-sy {
            background: -webkit-gradient(linear,left top,right bottom,from(#b0df55),to(#629401));
        }

        .target-list li .probg-jn {
            background: -webkit-gradient(linear,left top,right bottom,from(#fe91ad),to(#e63863));
        }

        .target-list li .probg-qn {
            background: -webkit-gradient(linear,left top,right bottom,from(#50c9d8),to(#087583));
        }

        .target-list li .process-mask {
            background: #fff;
            z-index: 99;
            transition: all 1s ease-out;
            -webkit-transition: all 1s ease-out;
        }

        .target-item {
            position: relative;
            z-index: 100;
            padding: 6px 0 5px 0;
        }

        .process-mask .pro-val {
            margin-left: -70px;
            height: 100%;
            line-height: 56px;
            font-size: 1.2em;
            color: #fff;
            font-style: italic;            
            font-weight: bold;
            font-family: 'HelveticaNeue1d832c0a34d3c';
        }

        .menu {
            padding: 5px 40px;
            font-size: 0;
            background-color: #fff;
        }

            .menu > a {
                width: 25%;
                text-align: center;
                display: inline-block;
                font-size: 14px;
                color: #575d6a;
                height: 24px;
                line-height: 24px;
            }

        .m-item.current-select {
            background-color: #faaa05;
            color: #fff;
            border-radius: 3px;
        }
        /*mask style*/
        .mask {
            color: #fff;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1001;
            font-size: 1.1em;
            text-align: center;
            background-color: rgba(0,0,0,0.5);
            display:none;
        }

        .loader {
            background-color: rgba(39, 43, 46, 0.9);
            padding: 15px 20px;
            border-radius: 5px;
            max-height: 200px;
            overflow: hidden;
        }

        #loadtext {
            margin-top: 5px;
            font-weight: bold;
            font-size: 0.9em;
        }

    </style>
</head>
<body>
    <div class="header">
        店员业绩完成情况
        <i class="fa fa-angle-left" onclick=""></i>
    </div>
    <div class="wrap-page">
        <div class="page page-not-header-footer">
            <div class="menu">
                <a href="javascript:" onclick="" class="m-item current-select" rel="by">本 月</a>
                <a href="javascript:" onclick="" class="m-item" rel="sy">上 月</a>
                <a href="javascript:" onclick="" class="m-item" rel="jn">今 年</a>
                <a href="javascript:" onclick="" class="m-item" rel="qn">去 年</a>
            </div>
            <ul class="target-list">
            </ul>
        </div>
    </div>
    <div class="footer">
        &copy;2016 &nbsp;利郎(中国)有限公司
    </div>
    <!--MASK提示层-->
    <div class="mask">
        <div class="loader center-translate">
            <div style="font-size: 1.2em;">
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext">正在加载...</p>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/sea.js"></script>
    <script type="text/javascript">
        seajs.use('../../res/js/storesaler/showTarget', function (util) {
            FastClick.attach(document.body);
            util.init("<%=mdid%>", "by");
        });
    </script>
</body>
</html>
