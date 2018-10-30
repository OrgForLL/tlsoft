<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html>
<script runat="server">
    private List<string> wxConfig = new List<string>();
    private string DBConnStr = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
    public string gname = "品牌速递";
    protected void Page_Load(object sender, EventArgs e)
    {
        //using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr)) {
        //    string gid = Convert.ToString(Request.Params["gid"]);
        //    if (gid != "" && gid != "0" && gid != null) {
        //        string str_sql = "select top 1 groupname from t_articlegroup where id=@id;";
        //        List<SqlParameter> para = new List<SqlParameter>();
        //        para.Add(new SqlParameter("@id",gid));
        //        object scalar;
        //        string errinfo = dal.ExecuteQueryFastSecurity(str_sql, para, out scalar);
        //        if (errinfo == "")
        //            gname = Convert.ToString(scalar);                    
        //    }
        //}//end using
        wxConfig = clsWXHelper.GetJsApiConfig("1");
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <title></title>
    <link rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            background-color: #f7f7f7;
            line-height: 1;
        }

        .page {
            background-color: #f7f7f7;
            padding: 0;
        }

        .footer {
            height: 24px;
            line-height: 24px;
            font-size: 12px;
            text-align: center;
            color: #999;
            background-color: #f7f7f7;
        }

        .page-not-header-footer {
            top:90px;
            bottom: 24px;
        }

        .header {
            font-size: 18px;
            color: #363c44;            
            height: 90px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
        }

        .page-title {
            height:50px;
            line-height:50px;
            border-bottom: 1px solid #4f6f95;            
        }

        .page-nav {
            height: 40px;
            width:100%;
        }

            .page-nav .navs {
                white-space: nowrap;
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
                padding: 0 20px;
            }

        .navs::-webkit-scrollbar {
            display:none;
        }

        .navs .nav-item {
            display: inline-block;
            line-height: 39px;
            height: 40px;
            font-size: 15px;
            margin-left: 10px;
            padding: 0 5px;
        }

        .nav-item.active {
            color: #31343d;
            border-bottom: 2px solid #31343d;
            font-weight: bold;
        }

        .fa-angle-left {
            position: absolute;
            top: 0;
            left: 0;
            height: 50px;
            line-height: 50px;
            padding: 0 18px;
            font-size: 24px;
        }

            .fa-angle-left:hover {
                background-color: rgba(0,0,0,0.1);
            }

        .a-item {
            background-color: #fff;
            margin-top: 8px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
        }

        .a-top {
            height: 36px;
            border-top: 1px dashed #ebebec;
            position: relative;
            padding-left: 10px;
        }

            .a-top > div {
                height: 36px;
                line-height: 35px;
                font-size: 14px;
            }

        .author {
            color: #777;
        }

        .a-top .a-time {
            position: absolute;
            top: 0;
            right: 10px;
            color: #aaa;
            font-size: 14px;
        }

        .a-bot {
            padding: 8px 10px;
        }

        .a-title {
            font-size: 18px;
            color: #212025;
            position: relative;
            line-height: 1.4em;
            max-height: 2.8em;
            overflow: hidden;
        }

        .a-prev {
            margin-top: 5px;
            color: #647185;
            position: relative;
            line-height: 1.4em;
            max-height: 4.2em;
            overflow: hidden;
            text-indent: 20px;
        }

        .icons {
            text-align: right;
            margin-top: 10px;
            color: #a6a5aa;
        }

        .no-result {
            color: #999;
            font-size: 15px;
            display: none;
            z-index: 1000;
            margin-top:20px;
        }
        /*loader style*/
        .mask {
            color: #fff;
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1001;
            font-size: 1.1em;
            text-align: center;
            background-color: rgba(0,0,0,0.5);
            display: none;
        }

        .loader {
            background-color: rgba(39, 43, 46, 0.9);
            padding: 15px;
            border-radius: 5px;
            max-height: 200px;
            overflow: hidden;
            min-width: 100px;
        }

        #loadtext {
            margin-top: 10px;
            font-weight: bold;
            letter-spacing: 1px;
        }

        #SearchIn {
            -webkit-appearance: none;
            width: 98%;
            border: 1px solid #e7e7eb;
            margin: 0 auto;
            display: block;
            border-radius: 0;
            height: 34px;
            line-height: 34px;
            vertical-align: middle;
            padding: 0 8px;
            margin-top: 5px;
            margin-bottom:-3px;
            font-size: 14px;
            outline: none;
        }
        .loadmore {
            height:40px;
            line-height:40px;
            text-align:center;
        }
        /*thumb style*/
        .a-item .thumb {
            height: 200px;
            position:relative;
        }

        .back-image {
            background-position: 50% 50%;
            background-size: cover;
            background-repeat: no-repeat;
        }

        .views {
            padding:0 5px;
            height:20px;
            line-height:20px;
            background-color:#000;
            color:#fff;
            position:absolute;
            bottom:8px;
            right:8px;
        }

        .plusGlobalIcon {
            display: inline-block;
            background-image: url(mview-icon.png);
            background-repeat: no-repeat;
            background-size: auto 20px;
            padding-left: 20px;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="page-title">
            <i class="fa fa-angle-left" onclick="javascript:window.history.go(-1);"></i>
            <span id="gname"><%=gname %></span>
        </div>
        <div class="page-nav">
            <ul class="navs">
                <li class="nav-item active" gid="-1">最新</li>
            </ul>
        </div>
    </div>
    <div class="wrap-page">
        <div class="page page-not-header-footer">
            <input type="text" placeholder="根据文章标题进行搜索" id="SearchIn" oninput="searchFunc()" />
            <div id="a-lists">
                <!--<div class="a-item">
                    <div class="a-top">
                        <div class="author">李家的风</div>
                        <div class="a-time">5月5日 15:30</div>
                    </div>
                    <div class="a-bot">
                        <p class="a-title">
                            是销售却又不仅仅是销售
                        </p>
                        <p class="a-prev">
                            这家伙好懒居然连个摘要都没写....
                        </p>
                        <div class="icons">
                            <i class="fa fa-eye" style="padding-right: 5px;"></i>浏览次数
                        </div>
                    </div>
                </div>-->
            </div>
            <div class="loadmore" onclick="LoadData($('.nav-item.active').attr('gid'),false)">加载更多...</div>
        </div>
        <div class="no-result center-translate">Sorry,空空如也...</div>
    </div>
    <!--加载提示层-->
    <section class="mask">
        <div class="loader center-translate">
            <div style="font-size: 1.2em;">
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext">正在加载...</p>
        </div>
    </section>
    <div class="footer">
        &copy;2016 利郎信息技术部 提供技术支持
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        window.onload = function () {
            //var gid = getQueryString("gid");
            var ssid = getQueryString("ssid");
            if (ssid == "" || ssid == "0" || ssid == undefined) {
                showLoader("error", "传入的参数SSID有误!");
                return;
            }

            WXAPIConfig();
            LoadGroups(ssid);//10为利郎男装            
            LeeJSUtils.stopOutOfPage(".page", true);            
            LeeJSUtils.stopOutOfPage(".footer", false);
        }

        function WXAPIConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['hideOptionMenu'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                wx.hideOptionMenu();
            });
        }

        //本地搜索功能
        $.expr[":"].Contains = function (a, i, m) {
            return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
        };

        function searchFunc() {
            var obj = $("#.a-item .a-bot .a-title");
            if (obj.length > 0) {
                var filter = $("#SearchIn").val();
                if (filter) {
                    $matches = $("#a-lists .a-item").find(".a-title:Contains(" + filter + ")").parent().parent();
                    $("#a-lists .a-item").not($matches).hide();
                    $matches.show();
                } else {
                    $("#a-lists .a-item").show();
                }
            }
        }

        //加载顶部的分组
        function LoadGroups(ssid) {
            showLoader("loading", "正在加载文章分组...");
            $.ajax({
                type: "POST",
                timeout: 10000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "LLEditorCore.aspx",
                data: { ctrl: "LoadGroups_PC", ssid: ssid },
                success: function (msg) {                    
                    if (msg.indexOf("Error:") > -1)
                        showMessage("error", "加载失败 !" + msg.replace("Error:", ""));
                    else {
                        var htmlList = "<li class='nav-item active' onclick='LoadData(-1,true)' gid='-1'>最新</li>";
                        var _Temp = "<li class='nav-item' onclick='LoadData(#gid#,true)' gid='#gid#'>#groupname#</li>";
                        var data = JSON.parse(msg);
                        var len = data.rows.length;
                        for (var i = 0; i < len; i++) {
                            var row = data.rows[i];
                            htmlList += _Temp.replace(/#gid#/g, row.id).replace(/#groupname#/g, row.groupname);
                        }//end for
                        $(".navs").empty().append(htmlList);                        
                        $(".mask").hide();
                        LoadData("-1",true);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });
        }

        //加载某个分组的数据
        function LoadData(gid,isfirst) {
            showLoader("loading", "正在加载文章列表...");
            $(".navs .active").removeClass("active");
            $(".nav-item[gid=" + gid + "]").addClass("active");
            var xh = $(".a-item:last-child").attr("xh");
            if (xh == "" || xh == undefined || isfirst)
                xh = "-1";
            $.ajax({
                type: "POST",
                timeout: 10000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "LLEditorCore.aspx",
                data: { ctrl: "LoadArticleList", gid: gid, xh:xh },
                success: function (msg) {
                    if (msg == "") {
                        if (isfirst) {
                            $("#a-lists").empty();
                            $(".no-result").show();
                            $(".loadmore").hide();
                        } else {
                            $(".loadmore").text("已无更多数据...");
                        }
                        $(".mask").hide();
                    } else if (msg.indexOf("Error:") > -1)
                        showMessage("error", "加载失败 !" + msg.replace("Error:", ""));
                    else {
                        var htmlList = "";
                        var _Temp = "<div class='a-item' onclick='JumpGo(#id#);' xh=#xh#><div class='thumb back-image' style='background-image:url(#coverimg#);'><div class='views'><p class='times plusGlobalIcon'>#viewtimes#</p></div></div><div class='a-bot'><p class='a-title'>#title#</p><p class='a-prev'>#summary#</p></div><div class='a-top'><div class='author'>#author#</div><div class='a-time'>#yf#月#dd#日 #sj#</div></div></div>";
                        var data = JSON.parse(msg);
                        $.each(data.rows, function (i, el) {
                            if (el.summary == "")
                                el.summary = "&nbsp;";
                            if (el.author == "")
                                el.author = "利郎男装";
                            if (el.coverimg == "")
                                el.coverimg = "default.jpg";
                            htmlList += _Temp.temp(el);
                        });                        
                        $(".no-result").hide();
                        if (isfirst)
                            $("#a-lists").empty().append(htmlList);
                        else
                            $("#a-lists").append(htmlList);
                        $(".loadmore").text("加载更多...");
                        showLoader("successed", "加载成功");
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });
        }

        function JumpGo(aid) {
            window.location.href = "ArticleShow.aspx?aid=" + aid;
        }

        //提示层
        function showLoader(type, txt) {
            switch (type) {
                case "loading":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
                case "successed":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(200);
                    }, 500);
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 2000);
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 1500);
                    break;
            }
        }

        String.prototype.temp = function (obj) {
            return this.replace(/\#\w+\#/gi, function (matchs) {
                var returns = obj[matchs.replace(/\#/g, "")];
                return (returns + "") == "undefined" ? "" : returns;
            });
        };

        function getQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            var r = window.location.search.substr(1).match(reg);
            if (r != null)
                return unescape(r[2]);
            else
                return null;
        }
    </script>
</body>
</html>
