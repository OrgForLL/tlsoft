<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server">
    private const string ConfigKeyValue = "1";	//利郎企业号
    private string DBConStr = clsConfig.GetConfigValue("OAConnStr");
    
    public string mdid = "", mdmc = "", AppSystemKey = "", CustomerID = "", CustomerName = "", storeStr = "";
    private string strDhhCatpion = "订货自助参会登记";

    protected void Page_Load(object sender, EventArgs e)
    {
        ////设置为测试模式
        //SetIsTestMode();
        
        //鉴权判断身份
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string SystemID = "6";//订货会系统
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            CustomerID = Convert.ToString(Session["qy_customersid"]);
            CustomerName = Convert.ToString(Session["qy_cname"]);
            //clsSharedHelper.WriteInfo(AppSystemKey);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通订货会系统权限！");
            else
            {
                //访问统计
                clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "参会管理列表页[joinStoreList.aspx]"));
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
                { 
                    string dhbh =  clsErpCommon.getDhbh();
                    strDhhCatpion = clsErpCommon.getDhhCatpion(dhbh);                    

                    object objScal = null;
                    string errinfo = dal.ExecuteQuery(string.Format(@"select TOP 1 dhbh from yx_t_dhryxx where id={0} and mdid>0", AppSystemKey), out objScal);
                    if (errinfo != "")
                    {
                        clsSharedHelper.WriteErrorInfo(errinfo);
                        return ;
                    }
                    else if (objScal == null)
                    {
                        clsWXHelper.ShowError("未找到您之前的订货会参会信息！因此您无法自助登记参会资料。【" + AppSystemKey + "】");
                        return;
                    }
                    else if (Convert.ToString(objScal) != dhbh)
                    {
                        //尝试更新关联信息
                        errinfo = dal.ExecuteNonQuery(string.Format( @"UPDATE b SET b.SystemKey=d.id
                        FROM dbo.wx_t_AppAuthorized b INNER JOIN yx_t_dhryxx c ON b.SystemKey=c.id INNER JOIN yx_t_dhryxx d ON c.IdCard=d.IdCard
                        WHERE b.UserID={0} and b.SystemID=6 AND d.dhbh='{1}' and c.id={2} ", CustomerID, dhbh, AppSystemKey));
                    } 
                    
//                    string str_sql = @"declare @ccid varchar(100);declare @curmdid int;
//                                        select top 1 @ccid=kh.ccid,@curmdid=a.mdid from yx_t_dhryxx a inner join yx_t_khb kh on a.khid=kh.khid where a.id='{0}';
//                                        select md.mdid,upper(md.mddm)+'.'+md.mdmc mdmc,isnull(@curmdid,0) curmdid
//                                        from yx_t_khb a inner join t_mdb md on a.khid=md.khid 
//                                        where md.ty=0 and a.ty=0 and a.ccid+'-' like @ccid+'-%' order by md.mddm";
                    string str_sql = @"declare @khid INT;declare @curmdid int;
                                        select top 1 @khid=kh.khid,@curmdid=a.mdid from yx_t_dhryxx a inner join yx_t_khb kh on a.khid=kh.khid where a.id='{0}';

                                        select md.mdid,upper(md.mddm)+'.'+md.mdmc mdmc,isnull(@curmdid,0) curmdid,'' mddm
                                              from YX_T_khb a inner join t_mdb md on a.khid=md.khid       
                                               where md.ty=0 AND a.ty = 0 and A.khid = @khid 
			                                        UNION ALL
                                        select md.mdid,upper(md.mddm)+'.'+md.mdmc mdmc,isnull(@curmdid,0) curmdid,md.mddm
                                              from YX_T_khgxb a inner join t_mdb md on a.gxid=md.khid       
                                               where md.ty=0 and A.khid = @khid AND A.khfl IN ('xf','xd','xz','xg','xj','xq')
			                                        AND YEAR(GETDATE()) * 100 + MONTH(GETDATE()) >= A.ksny AND YEAR(GETDATE()) * 100 + MONTH(GETDATE()) <= A.jsny 
			                                        order by mddm
";
                    
                   
                    str_sql = string.Format(str_sql, AppSystemKey);
                    DataTable dt = null;
                    errinfo = dal.ExecuteQuery(str_sql, out dt);
                    if (errinfo == "")
                    {
                        if (dt.Rows.Count > 0)
                        {
                            StringBuilder sb = new StringBuilder();
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (i == 0)
                                    mdid = Convert.ToString(dt.Rows[0]["curmdid"]);
                                sb.AppendFormat("<li mdid='{0}' onclick='GotoMd(\"{0}\")'>{1}<i class='fa fa-angle-right'></i></li>", Convert.ToString(dt.Rows[i]["mdid"]), Convert.ToString(dt.Rows[i]["mdmc"]));
                            }//end for
                            storeStr = sb.ToString();
                            sb.Length = 0;
                            dt.Clear(); dt.Dispose();
                        }
                        else
                            clsSharedHelper.WriteInfo("Can't find  your data!");
                    }
                    else
                        clsSharedHelper.WriteErrorInfo(errinfo);
                }//end using                
            }
        }
        else
            clsWXHelper.ShowError("鉴权失败！");
    }

    /// <summary>
    /// 设置为测试模式。即将测试参数写到此处，用于测试
    /// </summary>
    private void SetIsTestMode()
    {
        DBConStr = "Data Source=192.168.35.10;Initial Catalog=tlsoft;User ID=ABEASD14AD;password=+AuDkDew";
    }
     
    
</script>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />    
    <meta name="apple-mobile-web-app-status-bar-style" content="default" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/meeting/JoinOrderStyle.css" />
    <style type="text/css">
        #loading-center-absolute {
            position: absolute;
            left: 50%;
            top: 50%;
            height: 60px;
            width: 60px;
            margin-top: -30px;
            margin-left: -30px;
            -webkit-animation: loading-center-absolute 1s infinite;
            animation: loading-center-absolute 1s infinite;
        }

        .object {
            width: 20px;
            height: 20px;
            background-color: #444;
            float: left;
            -moz-border-radius: 50% 50% 50% 50%;
            -webkit-border-radius: 50% 50% 50% 50%;
            border-radius: 50% 50% 50% 50%;
            margin-right: 20px;
            margin-bottom: 20px;
        }

            .object:nth-child(2n+0) {
                margin-right: 0px;
            }

        #object_one {
            -webkit-animation: object_one 1s infinite;
            animation: object_one 1s infinite;
            background-color: #3498db;
        }

        #object_two {
            -webkit-animation: object_two 1s infinite;
            animation: object_two 1s infinite;
            background-color: #f1c40f;
        }

        #object_three {
            -webkit-animation: object_three 1s infinite;
            animation: object_three 1s infinite;
            background-color: #2ecc71;
        }

        #object_four {
            -webkit-animation: object_four 1s infinite;
            animation: object_four 1s infinite;
            background-color: #e74c3c;
        }

        @-webkit-keyframes loading-center-absolute {
            100% {
                -ms-transform: rotate(360deg);
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        @keyframes loading-center-absolute {
            100% {
                -ms-transform: rotate(360deg);
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        @-webkit-keyframes object_one {
            50% {
                -ms-transform: translate(20px,20px);
                -webkit-transform: translate(20px,20px);
                transform: translate(20px,20px);
            }
        }

        @keyframes object_one {
            50% {
                -ms-transform: translate(20px,20px);
                -webkit-transform: translate(20px,20px);
                transform: translate(20px,20px);
            }
        }

        @-webkit-keyframes object_two {
            50% {
                -ms-transform: translate(-20px,20px);
                -webkit-transform: translate(-20px,20px);
                transform: translate(-20px,20px);
            }
        }

        @keyframes object_two {
            50% {
                -ms-transform: translate(-20px,20px);
                -webkit-transform: translate(-20px,20px);
                transform: translate(-20px,20px);
            }
        }

        @-webkit-keyframes object_three {
            50% {
                -ms-transform: translate(20px,-20px);
                -webkit-transform: translate(20px,-20px);
                transform: translate(20px,-20px);
            }
        }

        @keyframes object_three {
            50% {
                -ms-transform: translate(20px,-20px);
                -webkit-transform: translate(20px,-20px);
                transform: translate(20px,-20px);
            }
        }

        @-webkit-keyframes object_four {
            50% {
                -ms-transform: translate(-20px,-20px);
                -webkit-transform: translate(-20px,-20px);
                transform: translate(-20px,-20px);
            }
        }

        @keyframes object_four {
            50% {
                -ms-transform: translate(-20px,-20px);
                -webkit-transform: translate(-20px,-20px);
                transform: translate(-20px,-20px);
            }
        }

        .animated {
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

        @-webkit-keyframes shake {
            0%,100% {
                -webkit-transform: translate3d(0,0,0);
                transform: translate3d(0,0,0);
            }

            10%,30%,50%,70%,90% {
                -webkit-transform: translate3d(-10px,0,0);
                transform: translate3d(-10px,0,0);
            }

            20%,40%,60%,80% {
                -webkit-transform: translate3d(10px,0,0);
                transform: translate3d(10px,0,0);
            }
        }

        @keyframes shake {
            0%,100% {
                -webkit-transform: translate3d(0,0,0);
                -ms-transform: translate3d(0,0,0);
                transform: translate3d(0,0,0);
            }

            10%,30%,50%,70%,90% {
                -webkit-transform: translate3d(-10px,0,0);
                -ms-transform: translate3d(-10px,0,0);
                transform: translate3d(-10px,0,0);
            }

            20%,40%,60%,80% {
                -webkit-transform: translate3d(10px,0,0);
                -ms-transform: translate3d(10px,0,0);
                transform: translate3d(10px,0,0);
            }
        }

        .shake {
            -webkit-animation-name: shake;
            animation-name: shake;
        }

        #no-result {
            display: none;
            white-space: nowrap;
            color: #999;
            z-index: 998;
        }

        .form-item .sex-item {
            width: 50%;
            float: left;
            text-align: center;
            line-height: 34px;
            font-size: 16px;
            color: #999;
            position: relative;
        }

            .form-item .sex-item i {
                margin-right: 10px;
            }

            .form-item .sex-item.selected {
                color: #50bb8d;
            }

        .hidden {
            display: none;
        }

        .SearchOthers {
            position: absolute;
            top: 3px;
            right: 0;
            height: 28px;
            line-height: 26px;
            border: 1px solid #f0f0f0;
            border-radius: 2px;
            padding: 0 10px;
            color: #50bb8d;
            font-weight: bold;
            display: none;
        }

        #fixed-name p {
            display: none;
        }

        .store-name {
            margin-bottom: 5px;
            font-weight: bold;
            display: inline-block;
            background-color: #50bb8d;
            color: #fff;
            padding: 2px 8px;
            border-radius: 4px;
        }

        .footer {
            background-color: #f0f0f0;
            border: none;
            height: 20px;
            line-height: 20px;
        }

            .footer p {
                font-size: 12px;
                color: #aaa;
            }

        .page-not-header-footer {
            padding-top: 71px;
            bottom: 20px;
        }

        #store-list {
            background-color: #fff;
            border: 1px solid #dcdcdc;
            border-bottom-left-radius: 4px;
            border-bottom-right-radius: 4px;
        }

            #store-list li {
                line-height: 1;
                padding: 12px;
                border-bottom: 1px solid #dcdcdc;
                position: relative;
            }

                #store-list li .fa-angle-right {
                    position: absolute;
                    top: 0;
                    right: 10px;
                    line-height: 38px;
                    font-size: 18px;                    
                }

                #store-list li:last-child {
                    border-bottom: none;
                }

        .current-store {
            background-color: #50bb8d;
            color: #fff;
            font-weight: bold;
        }

        #search-store {
            width: 100%;
            margin: 0 auto;
            -webkit-appearance: none;
            border: 1px solid #dcdcdc;
            border-radius: 0;
            border-top-left-radius: 4px;
            border-top-right-radius: 4px;
            height: 40px;
            line-height: 38px;
            font-size: 14px;
            padding: 0 10px;
            border-bottom: none;
        }

        .search-container .fa-search {
            position: absolute;
            top: 0;
            right: 10px;
            line-height: 40px;
            color: #999;
        }
    </style>
</head>
<body>
    <!--loading mask-->
    <div id="loadingmask" style="position: fixed; background-color: #f0f0f0; top: 0; height: 100%; left: 0; width: 100%; z-index: 2000;">
        <div id="loading-center-absolute">
            <div class="object" id="object_one"></div>
            <div class="object" id="object_two"></div>
            <div class="object" id="object_three"></div>
            <div class="object" id="object_four"></div>
        </div>
    </div>

    <div class="header">
        <div class="center-translate">
            <div class="title">利郎订货会参会人员信息管理</div>
            <div class="season"><%= strDhhCatpion %></div>
        </div>
    </div>
    <div class="wrap-page">
        <!--主页-->
        <div class="page page-not-header-footer" id="main">
            <div style="text-align: center;">
                <div class="store-name">请从下面列表中选择一家门店</div>
            </div>
            <div class="search-container" style="position: relative;">
                <input id="search-store" type="text" placeholder="搜索门店名称.." oninput="SearchFunc()" />
                <i class="fa fa-search"></i>
            </div>
            <ul id="store-list">
                <%=storeStr %>
            </ul>
            <div id="no-result" class="center-translate">对不起，没有记录！</div>
        </div>
    </div>
    <div class="footer" id="footer-btns">
        <p>&copy;2016 利郎信息技术部提供技术支持</p>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>

    <!--模板区-->

    <script type="text/javascript">
        var mdid = "<%=mdid%>";
        $(document).ready(function () {
            FastClick.attach(document.getElementById("main"));
            LeeJSUtils.stopOutOfPage("#main", true);
            LeeJSUtils.stopOutOfPage(".footer", false);
            LeeJSUtils.stopOutOfPage(".header", false);
            LeeJSUtils.LoadMaskInit();
        });

        window.onload = function () {
            $("#loadingmask").hide();
            $("#store-list li[mdid='" + mdid + "']").addClass("current-store");           

            if ($("#store-list li[mdid='" + mdid + "']").length == 1 && $("#store-list li").length == 1) {
                LeeJSUtils.showMessage("loading", "正在自动跳转..");
                setTimeout(function () {                    
                    window.location.href = "joinOrderInfo.aspx?mdid=" + mdid;
                }, 1000);
            }
//            else {
//                //移到第一行.  经xlm 20170116测试，该代码会将第一个目标移除，因此暂时屏蔽
//                $("#store-list li[mdid='" + mdid + "']").insertBefore("#store-list li:eq(0)");
//            }
        }

        $.expr[":"].Contains = function (a, i, m) {
            return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
        };

        function SearchFunc() {
            var obj = $("#store-list li");
            if (obj.length > 0) {
                var filter = $("#search-store").val();
                if (filter) {
                    $matches = $("#store-list").find("li:Contains(" + filter + ")");
                    $("li", $("#store-list")).not($matches).hide();
                    $matches.show();
                } else {
                    $("#store-list").find("li").show();
                }
            }
        }

        function GotoMd(mdid) {
            if (mdid != "" && mdid != "0")
                window.location.href = "joinOrderInfo.aspx?mdid=" + mdid;
        }
    </script>
</body>
</html>
