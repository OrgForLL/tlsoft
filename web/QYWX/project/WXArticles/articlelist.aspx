<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>
<script runat="server">
    private const string ConfigKeyValue = "1";	//微信配置信息索引值
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数

    //验证文章是否需要身份判断
    public bool isValidate(string ssid)
    {
        bool rt = true;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("FormalModeConnStr")))
        {
            string sql = "select needvalidate from t_ArticleGroup where id=@ssid;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@ssid", ssid));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(sql, paras, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                if (dt.Rows[0][0].ToString() != "True")
                    rt = false;
            }

        }

        return rt;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string userid = Convert.ToString(Session["qy_customersid"]);
        string cname = Convert.ToString(Session["qy_cname"]);
        string ssid = Convert.ToString(Request.Params["ssid"]);
        if ((userid == "" || userid == null || userid == "0" || cname == "" || cname == null) && isValidate(ssid))
        {
            //获取用户鉴权的方法:该方法要求用户必须已成功关注企业号，主要是用于获取Session["qy_customersid"] 和其他登录信息
            if (!clsWXHelper.CheckQYUserAuth(true))
            {
                Response.Redirect("../../WebBLL/Error.aspx?msg=请先关注利郎企业号！");
                Response.End();
            }                        
        }
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);                   
    }            
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <title>文章列表</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <!--[if IE]>
       <link href="../../res/css/font-awesome-ie7.min.css" rel="stylesheet" />
    <![endif]-->
    <style type="text/css">
        * {
            padding: 0px;
            margin: 0px;
        }

        body {
            font-family: Helvetica,Arial,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            background-color: #f0f0f0;
        }

        #container {
            width: 90%;
            max-width: 900px;
            margin: 10px auto 20px auto;
            border: 1px solid #ddd;
            background: #f0f0f0;
        }

        #alist {
            list-style: none;
            box-shadow: 0 1px 3px rgba(0,0,0,0.18);
        }

            #alist li {
                opacity: 0;
                position: relative;
                background: #f8f8f8;
                cursor: pointer;
                font-size: 1.0em;
                color: #515151;
                padding: 10px;
                display: block;
                transition: all .3s ease-in-out 0s;
            }

                #alist li:hover, #alist li:active {
                    background: #ddd;
                    top: -3px;
                    left: -5px;
                    box-shadow: 3px 3px 10px #ccc;
                }

                #alist li:not(:last-child) {
                    border-bottom: 1px solid #cbcbcb;
                }

        i {
            margin-right: 5px;
        }

        .atime {
            position: absolute;
            right: 10px;
            bottom: 10px;
            color: #eee;
            font-size: 1em;
            font-weight: 600;
            line-height: 24px;
            background: #515151;
            padding: 0px 8px;
            text-align: center;
        }

        .atitle {
            text-overflow: ellipsis;
            display: inline-block;
            max-width: 300px;
            white-space: nowrap;
            overflow: hidden;
            line-height: 24px;
            vertical-align: middle;
        }

        .copyright, .rows {
            width: 90%;
            max-width: 900px;
            text-align: center;
            margin: 20px auto;
            font-size: 15px;
        }

        #searchdiv {
            width: 90%;
            max-width: 900px;
            margin: 15px auto 10px auto;
            position: relative;
            z-index: 2008;
        }

        #gname {
            width: 100%;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            text-align: center;
            font-size: 1.6em;
            height: 45px;
            line-height: 45px;
            vertical-align: middle;
            position: absolute;
        }

        .searchicon i {
            display: block;
            width: 45px;
            height: 45px;
            background: #515151;
            font-size: 22px;
            color: #fff;
            text-align: center;
            line-height: 45px;
            position: absolute;
            top: 0px;
            right: -5px;
            cursor: pointer;
            transition: all 0.5s;
        }

        .iconopen {
            border-top-left-radius: 0px;
            border-bottom-left-radius: 0px;
        }

        .search-input {
            border: none;
            outline: none;
            height: 45px;
            padding: 15px 55px 15px 15px;
            box-sizing: border-box;
            font-size: 16px;
            border-radius: 0px;
            color: #2c3e50;
            width: 0%;
            float: right;
            background: none;
            transition: width 0.5s;
        }

        .search-input-open {
            border: 1px solid #3B3D40;
            background: #fff;
            width: 100%;
            -webkit-appearance: none;
        }

        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }

        .search-submit {
            opacity: 0;
            display: none;
        }

        .info {
            display: none;
            width: 90%;
            max-width: 900px;
            margin: 15px auto 0px auto;
            text-align: center;
            font-size: 20px;
            text-align: center;
            font-weight: bold;
            color: #d43f3a;
        }

        /*侧边栏样式*/
        .menu-wrap {
            position: fixed;
            z-index: 2007;
            top: 0px;
            left: 0px;
            width: 200px;
            height: 100%;
            font-size: 1.2em;
            background: #272b2e;
            transition: all 0.5s;
        }

        #menu-wrap-right {
            position: fixed;
            z-index: 2006;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: #333;
            opacity: 0.2;
            display: none;
        }

        .menu {
            height: 100%;
            padding-top: 40px;
        }

        .icon-list {
            width: 200px;
        }

            .icon-list a {
                display: block;
                padding: 0.4em 0.8em;
                color: #fff;
                text-decoration: none;
                white-space: nowrap;
                text-overflow: ellipsis;
                overflow: hidden;
            }

                .icon-list a:hover {
                    background: #ebebeb;
                    color: #333;
                    border-right: 4px solid #d43f3a;
                    box-sizing: border-box;
                }

        .close-button {
            position: absolute;
            z-index: 2002;
            top: 0.5em;
            right: 0.5em;
            color: #fff;
            background: transparent;
            border: none;
            font-size: 1.2em;
            text-align: center;
            overflow: hidden;
            cursor: pointer;
        }

        .menu-button {
            top: 0px;
            left: 0px;
            position: fixed;
            z-index: 2000;
            width: 2.5em;
            height: 2.5em;
            font-size: 1.5em;
            color: #333;
            background: transparent;
            border: none;
            cursor: pointer;
        }

        .closemenu {
            left: -300px;
        }

        .openmenu {
            left: 300px;
        }

        .swb {
            position: absolute;
            width: 100%;
            height: 40px;
            left: 0;
            bottom: 0;
            background-color: rgba(255,255,255,0.04);
        }

        .swbi {
            width: 50%;
            float: left;
            box-sizing: border-box;
            text-align: center;
            height: 40px;
            line-height: 40px;
        }

        .btnselect {
            color: #333;
            background: #f8f8f8;
        }
    </style>
</head>
<body>
    <div class="menu-wrap closemenu">
        <nav class="menu">
            <div class="icon-list">
                <a href="#"><i class="fa fa-chevron-right"></i><span>分组一</span></a>
                <a href="#"><i class="fa fa-chevron-right"></i><span>分组二</span></a>
                <a href="#"><i class="fa fa-chevron-right"></i><span>分组三</span></a>
                <a href="#"><i class="fa fa-chevron-right"></i><span>分组四</span></a>
                <a href="#"><i class="fa fa-chevron-right"></i><span>分组五</span></a>
                <a href="#"><i class="fa fa-chevron-right"></i><span>分组六</span></a>
            </div>
        </nav>
        <div class="swb">
            <div class="swbi btnselect" onclick="switchMode('txt')">文 字</div>
            <div class="swbi" onclick="switchMode('pic')">图 文</div>
        </div>
        <button class="menu-button" id="open-button"><i class="fa fa-navicon"></i></button>
        <button class="close-button" id="close-button"><i class="fa fa-close"></i></button>
    </div>
    <div id="menu-wrap-right"></div>
    <div class="floatfix">
        <div id="gname">--</div>
        <div id="searchdiv">
            <form onsubmit="return formFunc()">
                <input class="search-input" placeholder="请输入标题关键词..." status="close" />
                <input class="search-submit" type="submit" value="" />
                <span class="searchicon">
                    <i class="fa fa-search"></i>
                </span>
            </form>
        </div>
    </div>
    <div class="info">-查询无数据-</div>
    <div id="container">
        <ul id="alist">
            <li><span class="atitle"><i class="fa fa-file-text"></i>--</span><span class="atime">2015-1-1</span></li>
            <li><span class="atitle"><i class="fa fa-file-text"></i>--</span><span class="atime">2015-1-1</span></li>
            <li><span class="atitle"><i class="fa fa-file-text"></i>--</span><span class="atime">2015-1-1</span></li>
            <li><span class="atitle"><i class="fa fa-file-text"></i>--</span><span class="atime">2015-1-1</span></li>
        </ul>
    </div>
    <div class="rows">共有--条记录</div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript">
        var isAnimated = false;
        var groupSsid = "";
        $(document).ready(function () {
            var len = 0;
            groupSsid = GetQueryString("ssid");
            if (groupSsid == "" || groupSsid == null) {
                alert("缺少参数SSID！");
                return;
            } else {
                loadData("");
                loadGroup(groupSsid);
                len = $("#alist").children().length;
            }

            //WeiXin JSSDK
            jsConfig();
        });

        $(".searchicon").click(function () {
            //关闭侧边菜单栏
            $(".menu-wrap").addClass("closemenu");
            $("#open-button").css("opacity", "1");
            $("#menu-wrap-right").hide();

            var status = $(".search-input").attr("status");
            if (status == "open") {
                var searchval = $(".search-input").val();
                //swal({ title: "搜索内容不能为空", text: "", type: "warning", showCancelButton: false, confirmButtonColor: "#ec971f", confirmButtonText: "知道了", closeOnConfirm: true }, function () { });
                swal({ title: "正在搜索", text: "", type: "", showCancelButton: false, showConfirmButton: false });
                $("#swdiv").css("padding-top", "40px");
                $("#swdiv").css("border-top-color", "#3B3D40");
                if (!isAnimated) {
                    window.setInterval(function () {
                        isAnimated = true;
                        var text = $("#swdiv h2").text();
                        if (text.length < 9) {
                            $("#swdiv h2").text(text + '.');
                        } else {
                            $("#swdiv h2").text('正在搜索');
                        }
                    }, 200);
                }

                loadData(searchval);
                closeinput("");
            } else if (status == "close") {
                $(".search-input").attr("status", "open");
                $(".search-input").addClass("search-input-open");
            }
        });
        //图文模式地址 window.location.replace("imgtxtmode.html?ssid=18");
        function switchMode(mode) {
            switch (mode) {
                case "pic":
                    window.location.replace("imgtxtmode.html?ssid=18");
                    break;
            }
        }


        $("#close-button").click(function () {
            $(".menu-wrap").addClass("closemenu");
            $("#open-button").css("opacity", "1");
            $("#menu-wrap-right").hide();
        });

        $("#open-button").click(function () {
            closeinput("");
            $(".menu-wrap").removeClass("closemenu");
            $("#open-button").css("opacity", "0");
            $("#menu-wrap-right").show();
        });

        $("#menu-wrap-right").click(function () {
            $(".menu-wrap").addClass("closemenu");
            $("#open-button").css("opacity", "1");
            $("#menu-wrap-right").hide();
        });

        function closeinput(value) {
            if (value == "") {
                $(".search-input").attr("status", "close");
                $(".search-input").removeClass("search-input-open");
            }
        }

        function formFunc() {
            var searchval = $(".search-input").val();
            loadData(searchval);
            return false;
        }

        function loadGroupDetail(ssid, name) {
            $("#gname").text(name);
            groupSsid = ssid;
            loadData("");
            $(".menu-wrap").addClass("closemenu");
            $("#open-button").css("opacity", "1");
            $("#menu-wrap-right").hide();
        }

        //加载分组数据
        function loadGroup(ssid) {
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: true,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "../../WebBLL/AjaxuploadHandler.aspx",
                data: { ctrl: "loadGroup", ssid: ssid },
                success: function (msg) {
                    if (msg.indexOf("Successed:") > -1) {
                        //处理返回的JSON数据         
                        msg = jQuery.parseJSON(msg.replace("Successed:", ""));
                        var bn = msg.rows.length;
                        var listhtml = "";
                        for (var i = 0; i < bn; i++) {
                            var row = msg.rows[i];
                            if (groupSsid == row.id) {
                                $("#gname").text(row.groupname);
                            }
                            listhtml += "<a href='#' onclick='loadGroupDetail(" + row.id + ",\"" + row.groupname + "\")'><i class='fa fa-chevron-right'></i><span>" + row.groupname + "</span></a>";
                        }//end for
                        $(".icon-list").children().remove();
                        $(".icon-list").append(listhtml);
                    } else if (msg.indexOf("Error:") > -1) {
                        alert(msg);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    //alert("服务器错误：" + XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                    alert("您的网络好像有点问题，请刷新重试！");
                }
            });
        }
        //加载主体数据
        function loadData(txt) {
            var ctrl = "";
            if (txt == "")
                ctrl = "loadArticleList";
            else
                ctrl = "searchArticle";
            $.ajax({
                type: "POST",
                timeout: 2000,
                async: true,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "../../WebBLL/AjaxuploadHandler.aspx",
                data: { ctrl: ctrl, txt: txt, ssid: groupSsid },
                success: function (msg) {
                    if (msg == "") {
                        $(".info").show();
                        $(".rows").text("共有--条记录");
                        $("#alist").children().remove();
                        $("#swdiv").fadeOut();
                        $(".sweet-overlay").fadeOut();
                    } else if (msg.indexOf("Successed:") > -1) {
                        //处理返回的JSON数据         
                        msg = jQuery.parseJSON(msg.replace("Successed:", ""));
                        var bn = msg.rows.length;
                        var listhtml = "";
                        for (var i = 0; i < bn; i++) {
                            var row = msg.rows[i];
                            listhtml += "<li onclick='gourl(" + row.id + ")'>";
                            listhtml += "<span class='atitle'><i class='fa fa-file-text'></i>" + row.title + "</span><span class='atime'>" + row.createtime + "</span>";
                            listhtml += "</li>";
                        }//end for
                        if (listhtml != "") {
                            $("#alist").children().remove();
                            $("#alist").append(listhtml);

                            var timelen = parseInt($(".atime").css("width").replace("px", "")) + 16;
                            var titlelen = parseInt($("#alist").css("width").replace("px", "")) - 30 - timelen;
                            $(".atitle").css("max-width", titlelen + "px");

                            var obj = $("#alist").children();
                            obj.fadeInWithDelay();
                            $(".rows").text("共有" + bn + "条记录");
                            $(".info").hide();
                        }

                        $("#swdiv").fadeOut();
                        $(".sweet-overlay").fadeOut();
                        if (txt == "")
                            closeinput(txt);
                    } else if (msg.indexOf("Error:") > -1) {
                        alert(msg);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    //alert("服务器错误：" + XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                    alert("您的网络好像有点问题，请刷新重试！");
                }
            });
        }

        function gourl(aid) {
            //window.open("showarticle.aspx?id=" + aid);
            //window.location.href = "showarticle.aspx?id=" + aid;
            window.location.replace("showarticle.aspx?id=" + aid);
        }

        $.fn.fadeInWithDelay = function () {
            var delay = 0;
            return this.each(function () {
                $(this).delay(delay).animate({ opacity: 1 }, 200);
                delay += 100;
            });
        };

        //获取URL参数
        function GetQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }

        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        /********************签名**********************/
        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['onMenuShareAppMessage', 'hideMenuItems'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                //alert("JS注入成功！");
                //分享给朋友
                //图标取第一张图片没有则使用封面图
                //分享的时候链接中去掉自动跳转的参数authAuto=retail autoAuth=enterprise
                var sharelink = location.href.replace("&autoAuth=retail", "").replace("&autoAuth=enterprise", "");
                wx.onMenuShareAppMessage({
                    title: $("#gname").text(), // 分享标题
                    desc: '这些文章都不错，不妨看看吧！', // 分享描述
                    link: sharelink, // 分享链接
                    imgUrl: 'http://tm.lilanz.com/retail/wxarticles/getheadimg.jpg', // 分享图标
                    type: '', // 分享类型,music、video或link，不填默认为link
                    dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                    success: function () {
                        // 用户确认分享后执行的回调函数
                    },
                    cancel: function () {
                        // 用户取消分享后执行的回调函数
                    }
                });
                wx.hideMenuItems({
                    menuList: ['menuItem:share:qq', 'menuItem:share:timeline', 'menuItem:share:weiboApp', 'menuItem:share:QZone', 'menuItem:openWithSafari', 'menuItem:openWithQQBrowser', 'menuItem:share:email'] // 要隐藏的菜单项，只能隐藏“传播类”和“保护类”按钮，所有menu项见附录3
                });
            });
            wx.error(function (res) {
                alert("JS注入失败！");
            });
        }

        /************获取签名数据*************/
        //function Getsignature() {
        //    var MyUrl = escape(location.href);
        //    $.ajax({
        //        url: "../../WebBLL/AjaxuploadHandler.aspx?ctrl=JSConfig&myUrl=" + MyUrl,
        //        type: "POST",
        //        dataType: "HTML",
        //        cache: false,//不使用缓存
        //        timeout: 5000,
        //        error: function (XMLHttpRequest, textStatus, errorThrown) {
        //            alert("AJAX调用签名接口失败！");
        //        },
        //        success: function (result) {
        //            var strArr = new Array();
        //            strArr = result.split('|');
        //            if (strArr.length < 1) {
        //                alert("您的网络不给力~，请尝试重新打开！");
        //            } else {
        //                appIdVal = strArr[0];
        //                timestampVal = strArr[1];
        //                nonceStrVal = strArr[2];
        //                signatureVal = strArr[3];
        //                jsConfig();
        //            }
        //        }
        //    });
        //}
    </script>
</body>
</html>

