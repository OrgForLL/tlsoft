<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public string AppSystemKey = "", CustomerID = "", RoleName = "", headImg = "", userName = "", cnRole = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string DBConnStr = clsConfig.GetConfigValue("OAConnStr");

            CustomerID = Convert.ToString(Session["qy_customersid"]);
            RoleName = Convert.ToString(Session["RealRole"]);
            string ManagerStore = Convert.ToString(Session["ManagerStore"]);

            if (ManagerStore != "APPMODE_3")
            {
                clsWXHelper.ShowError("请在利郎APP中打开！");
                return;
            }

            //20180319 角色名称改为从数据库中获取
            if (RoleName == "zb" || RoleName == "my" || RoleName == "kf")
            {
                cnRole = getRoleName(RoleName);
            }
            else
            {
                clsWXHelper.ShowError("对不起，您没权限使用此功能！");
                return;
            }

            DBConnStr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
            {
                string str_sql = @"select top 1 cname,avatar from wx_t_customers where id='" + CustomerID + "'";
                DataTable dt;
                string errinfo = dal.ExecuteQuery(str_sql, out dt);
                if (errinfo == "")
                {
                    if (dt.Rows.Count == 0)
                        clsWXHelper.ShowError("对不起，找不到您的全渠道用户信息！");
                    else
                    {
                        userName = Convert.ToString(dt.Rows[0]["cname"]);
                        string imgUrlHead = clsConfig.GetConfigValue("OA_WebPath");
                        headImg = getMiniImage(ref imgUrlHead, Convert.ToString(dt.Rows[0]["avatar"]));
                        Session["ManagerStore"] = null;
                        Session["tzid"] = null;
                        Session["mdid"] = null;
                        Session["RoleName"] = null;
                        Session["RoleID"] = null;
                    }
                }
                else
                    clsWXHelper.ShowError(errinfo);
            }//end using
        }
        else
            clsWXHelper.ShowError("对不起，本地鉴权失败！");
    }

    public string getRoleName(string role)
    {
        string ret = "";
        string WXDBConnStr = clsConfig.GetConfigValue("WXConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string str_sql = string.Format("select top 1 cname from t_roles where rolename='{0}'", role);
            object scalar;
            string errinfo = dal.ExecuteQueryFast(str_sql, out scalar);
            if (errinfo == "")
                ret = Convert.ToString(scalar);
        }

        return ret;
    }

    /// <summary>
    /// 获取缩略图路径
    /// </summary>
    /// <param name="imgUrlHead"></param>
    /// <param name="sourceImage"></param>
    /// <returns></returns>
    private string getMiniImage(ref string imgUrlHead, string sourceImage)
    {
        if (clsWXHelper.IsWxFaceImg(sourceImage)) return clsWXHelper.GetMiniFace(sourceImage);
        else return string.Concat(imgUrlHead, sourceImage);
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
    <style type="text/css">
        .white_mask {
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            background-color: #fff;
            z-index: 99999;
            display: none;
        }
    </style>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            text-size-adjust:none;
            -webkit-text-size-adjust:none;
        }

        .back-img {
            background-position: center center;
            background-repeat: no-repeat;
            background-size: cover;
        }

        .page {
            padding: 0;
            color: #f2f2f2;
            background-color: transparent;
        }

        #index {
            background-image: url(../../res/img/storesaler/page_bg.jpg);
        }

        .color-mask {
            background-color: rgba(0,0,0,.6);
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
        }

        .content {
            z-index: 200;
            margin-top: -10px;
        }

        .headimg {
            width: 66px;
            height: 66px;
            background-color: #f2f2f2;
            margin: 0 auto;
            position: relative;
            z-index: 210;
            border-radius: 2px;
            border: 1px solid #ccc;
        }

        .headimg_wrap {
            margin: 0 0 20px 0;
            text-align: center;
        }

        .head1, .head2 {
            background-color: rgba(255,255,255,.6);
            width: 66px;
            height: 66px;
            position: absolute;
            top: 0;
            left: 50%;
            margin-left: -33px;
            transform: rotate(10deg);
            z-index: 202;
            border-radius: 2px;
        }

        .head2 {
            transform: rotate(-10deg);
            background-color: rgba(255,255,255,.4);
            z-index: 201;
        }

        .username {
            font-size: 20px;
            font-weight: bold;
            margin: 32px 0 10px 0;
        }

        .rolename > span {
            background-color: rgba(255,255,255,.5);
            padding: 2px 8px;
            color: #303030;
            font-weight: 600;
            border-radius: 2px;
        }

        .tips {
            text-align: center;
            margin: 60px 0 20px 0;
            font-weight: 400;
        }

        .buttons {
            text-align: center;
            white-space: nowrap;
        }

        .button-item {
            display: inline-block;
            width: 34vw;
            height: 34vw;
            background-color: rgba(255,255,255,.5);
            border-radius: 2px;
            position: relative;
        }

        .nav-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto;
        }

        .nav_name {
            text-align: center;
            color: #222;
            font-weight: 600;
        }

        #company, #store {
            background-color: rgba(0,0,0,.8);
        }

        .select_ul {
            color: #f2f2f2;
            width: 90%;
            margin: 0 auto;
            border: 1px solid #f2f2f2;
            border-radius: 4px;
        }

            .select_ul li {
                height: 40px;
                line-height: 39px;
                padding: 0 10px;
            }

                .select_ul li:active {
                    background-color: #f2f2f2;
                    color: #333;
                }

                .select_ul li .fa {
                    font-size: 18px;
                    float: right;
                    line-height: 38px;
                }

                .select_ul li:not(:last-child) {
                    border-bottom: 1px solid #ccc;
                }

        .back-btn {
            background-color: rgba(240,240,240,.8);
            height: 40px;
            width: 44px;
            color: #333;
            text-align: center;
            line-height: 40px;
            border-radius: 4px;
            font-size: 16px;
            font-weight: bold;
            position: fixed;
            top: 10px;
            left: 10px;
            z-index: 2000;
            display: none;
        }

        .navbtns {
            font-size: 0;
            position: relative;
        }

        .btnitem {
            width: 50%;
            display: inline-block;
            height: 40px;
            line-height: 40px;
            text-align: center;
            font-size: 14px;
        }

        .list_wrap {
            position: absolute;
            top: 85px;
            left: 0;
            width: 100%;
            bottom: 0;
            overflow-y: auto;
            padding-bottom: 20px;
        }

        #searchForCom, #searchForStore {
            -webkit-appearance: none;
            border: none;
            border-bottom: 1px solid #fff;
            background-color: transparent;
            color: #fff;
            width: 90%;
            margin: 5px auto 0 auto;
            display: block;
            line-height: 28px;
            border-radius: 0;
            font-size: 14px;
        }

        .search_icon {
            width: 18px;
            height: 18px;
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center center;
            background-image: url(../../res/img/storesaler/search_icon.png);
            position: absolute;
            right: 24px;
            bottom: 7px;
        }

        @media all and (orientation : landscape) {
            .button-item {
                width: 34vh;
                height: 34vh;
            }
        }
    </style>
</head>
<body>
    <!--防止页面跳转中的显示 一闪而过-->
    <div class="white_mask"></div>
    <div class="wrap-page">
        <div class="page back-img" id="index">
            <div class="color-mask"></div>
            <div class="content center-translate">
                <div class="headimg_wrap">
                    <div class="head1"></div>
                    <div class="head2"></div>
                    <div class="back-img headimg" style="background-image: url(<%=headImg%>);"></div>
                    <p class="username"><%=userName %></p>
                    <p class="rolename"><span><%=cnRole %></span></p>
                </div>
                <div class="tips">- 请选择下方管理模式 -</div>
                <div class="buttons">
                    <div class="button-item" style="margin-right: 6vw;" onclick="navRedirct('0')">
                        <div class="center-translate" style="margin-top: -4px;">
                            <div class="back-img nav-icon" style="background-image: url(../../res/img/storesaler/manager_nav_icons.png); background-position: 0 0;"></div>
                            <p class="nav_name">管理者</p>
                        </div>
                    </div>
                    <div class="button-item">
                        <div class="center-translate" style="margin-top: -4px;" onclick="navRedirct('1')">
                            <div class="back-img nav-icon" style="background-image: url(../../res/img/storesaler/manager_nav_icons.png); background-position: 0 -80px;"></div>
                            <p class="nav_name">门店管理</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!--贸易公司列表页-->
        <div class="page page-right" id="company">
            <div class="navbtns">
                <div class="btnitem" onclick="javascript:backFunc();">返回</div>
                <div class="btnitem" onclick="javascript:scroll2Top();">回到顶部</div>
                <input type="text" id="searchForCom" placeholder="输入贸易公司名称.." oninput="searchFunc('com')" />
                <div class="search_icon"></div>
            </div>
            <div class="list_wrap">
                <ul class="select_ul"></ul>
            </div>
        </div>
        <!--门店列表页-->
        <div class="page page-right" id="store">
            <div class="navbtns">
                <div class="btnitem" onclick="javascript:backFunc();">返回</div>
                <div class="btnitem" onclick="javascript:scroll2Top();">回到顶部</div>
                <input type="text" id="searchForStore" placeholder="输入门店名称.." oninput="searchFunc('store')" />
                <div class="search_icon"></div>
            </div>
            <div class="list_wrap">
                <ul class="select_ul"></ul>
            </div>
        </div>
    </div>

    <script type="text/html" id="company_li_temp">
        <li data-khid="{{khid}}" data-mdid="{{mdid}}"><span>{{khmc}}</span><i class="fa fa-angle-right"></i></li>
    </script>

    <script type="text/html" id="store_li_temp">
        <li data-khid="{{khid}}" data-mdid="{{mdid}}"><span>{{mddm}}.{{mdmc}}</span></li>
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js?ver=20170329_00"></script>
    <script type="text/javascript">
        var currentSite = "index", userId = "<%=CustomerID%>", roleName = "<%=RoleName%>";

        $(document).ready(function () {
            FastClick.attach(document.body);
            LeeJSUtils.LoadMaskInit();

            $(".white_mask").hide();
            llApp.init();
            localStorage.removeItem("app_tzid");
            localStorage.removeItem("app_mdid");
        });

        function navRedirct(code) {
            if (code == "0") {
                //管理者模式调用APP-JS
                if (isInApp) {
                    localStorage.setItem("app_tzid", "");
                    localStorage.setItem("app_mdid", "");
                    //alert("设置成功！");
                    LeeJSUtils.showMessage("successed", "设置成功！" + localStorage.getItem("app_tzid") + "|" + localStorage.getItem("app_mdid"));
                    setTimeout(function () {
                        llApp.closeWKView();
                    }, 1000);
                }
            } else {
                if ($("#company .select_ul").attr("loaded") != "1")
                    loadCompanyList();
                else {
                    $("#company").removeClass("page-right");
                    currentSite = "company";
                }
            }
        }

        function loadCompanyList() {
            LeeJSUtils.showMessage("loading", "正在加载,请稍候..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 5000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "managerNavCore.aspx",
                    data: { ctrl: "getCompanyList", roleName: roleName, userid: userId },
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {
                            var data = JSON.parse(msg), html = "";
                            for (var i = 0; i < data.rows.length; i++) {
                                var row = data.rows[i];
                                html += template("company_li_temp", row);
                            }

                            $("#company .select_ul").html(html).attr("loaded", "1");
                            $("#leemask").hide();
                            $("#company").removeClass("page-right");
                            currentSite = "company";

                            //如果结果唯一则自动点击 . By:xlm 20170211
                            AutoClickCompany(data);
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "您的网络有问题..");
                    }
                }); //end AJAX
            }, 250);
        }

        function AutoClickCompany(data) {
            if (data.rows.length == 1) {
                loadStoreList(data.rows[0].khid);
            }
        }

        function loadStoreList(khid) {
            LeeJSUtils.showMessage("loading", "正在加载,请稍候..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 5000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "managerNavCore.aspx",
                    data: { ctrl: "getStoreList", khid: khid },
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {
                            var data = JSON.parse(msg), html = "";
                            if (data.rows.length == 0)
                                LeeJSUtils.showMessage("warn", "对不起，查询不到有效数据！");
                            else {
                                for (var i = 0; i < data.rows.length; i++) {
                                    var row = data.rows[i];
                                    html += template("store_li_temp", row);
                                }

                                $("#store .select_ul").empty().html(html);
                                $("#leemask").hide();
                                $("#company").addClass("page-left");
                                $("#store").removeClass("page-right");
                                $("#searchForStore").val("");
                                currentSite = "store";
                            }
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "您的网络有问题..");
                    }
                });//end AJAX
            }, 250);
        }

        //返回动作
        function backFunc() {
            switch (currentSite) {
                case "index":
                    break;
                case "company":
                    $("#" + currentSite).addClass("page-right");
                    currentSite = "index";
                    break;
                case "store":
                    $("#" + currentSite).addClass("page-right");
                    $("#company").removeClass("page-left");
                    currentSite = "company";
                    break;
            }
        }

        //返回顶部
        function scroll2Top() {
            $("#" + currentSite + " .list_wrap").animate({ scrollTop: 0 }, 200);
        }

        $("#company").on("click", ".select_ul li", function () {
            var khid = $(this).attr("data-khid");
            loadStoreList(khid);
        });

        $("#store").on("click", ".select_ul li", function () {
            //alert($(this).attr("data-khid") + "|" + $(this).attr("data-mdid") + "|" + $(this).text());
            var khid = $(this).attr("data-khid");
            var mdid = $(this).attr("data-mdid");
            var khmc = $(this).text();
            setCertification(khid, mdid, khmc);
        });

        function setCertification(khid, mdid, cerName) {
            //调用APP-JS写入COOKIE
            if (isInApp) {
                localStorage.setItem("app_tzid", khid);
                localStorage.setItem("app_mdid", mdid);
                //alert("设置成功！");
                LeeJSUtils.showMessage("successed", "设置成功！");
                setTimeout(function () {
                    llApp.closeWKView();
                }, 1000);
            }
        }

        function GetDateDiff(startDate, endDate) {
            var startTime = new Date(Date.parse(startDate.replace(/-/g, "/"))).getTime();
            var endTime = new Date(Date.parse(endDate.replace(/-/g, "/"))).getTime();
            var dates = Math.abs((startTime - endTime)) / (1000 * 60 * 60 * 24);
            return dates;
        }

        Date.prototype.format = function (format) {
            var o = {
                "M+": this.getMonth() + 1, //month 
                "d+": this.getDate(), //day 
                "h+": this.getHours(), //hour 
                "m+": this.getMinutes(), //minute 
                "s+": this.getSeconds(), //second 
                "q+": Math.floor((this.getMonth() + 3) / 3), //quarter 
                "S": this.getMilliseconds() //millisecond 
            }

            if (/(y+)/.test(format)) {
                format = format.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
            }

            for (var k in o) {
                if (new RegExp("(" + k + ")").test(format)) {
                    format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k] : ("00" + o[k]).substr(("" + o[k]).length));
                }
            }
            return format;
        }

        //搜索功能
        $.expr[":"].Contains = function (a, i, m) {
            return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
        };

        function searchFunc(type) {
            if (type == "com") {
                var obj = $("#company .select_ul li span");
                if (obj.length > 0) {
                    var filter = $("#searchForCom").val();
                    if (filter) {
                        $matches = $("#company .select_ul li").find("span:Contains(" + filter + ")").parent();
                        $("li", $("#company .select_ul")).not($matches).hide();
                        $matches.show();
                    } else
                        $("#company .select_ul li").show();
                }
            } else if (type == "store") {
                var obj = $("#store .select_ul li span");
                if (obj.length > 0) {
                    var filter = $("#searchForStore").val();
                    if (filter) {
                        $matches = $("#store .select_ul li").find("span:Contains(" + filter + ")").parent();
                        $("li", $("#store .select_ul")).not($matches).hide();
                        $matches.show();
                    } else
                        $("#store .select_ul li").show();
                }
            }
        }
    </script>
</body>
</html>
