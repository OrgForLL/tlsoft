<%@ Page Language="C#" %>

<!DOCTYPE html>
<script runat="server">
    public string UNAME = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        string UID = Convert.ToString(Session["AR_UID"]);
        UNAME = Convert.ToString(Session["AR_UNAME"]);
        if (UID == "" || UID == "0" || UID == null)
        {
            Response.Redirect("Login.html");
            Response.End();
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta name="renderer" content="webkit" />
    <title>利郎文章管理</title>
    <link rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link rel="icon" href="favicon.ico" />
    <style>
        * {
            margin: 0;
            padding: 0;
        }

        body {
            font: 14px/1.125;
            font-family: "Microsoft Yahei",Arial,Helvetica,sans-serif;
            background-color: #fafcff;
            line-height: 1;
            -webkit-font-smoothing: antialiased;
        }

        ul, ol {
            list-style: none;
        }

        a {
            text-decoration: none;
            color: #999;
        }

        input, textarea, select {
            font-size: 100%;
            color: #333;
            font-family: "Microsoft Yahei",Arial,Helvetica,sans-serif;
        }

        .header {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 50px;
            padding: 0 20px;
            background-color: #333;
            z-index: 100;
            box-shadow: 0 2px 5px 0 rgba(0, 0, 0, 0.16), 0 2px 10px 0 rgba(0, 0, 0, 0.12);
            z-index: 210;
        }

        .header-inner {
            color: #fff;
            font-weight: bold;
            line-height: 50px;
            width: 100%;
        }

            .header-inner .title {
                float: left;
                font-size: 16px;
                letter-spacing: 2px;
            }

            .header-inner .infos {
                float: right;
                font-weight: 400;
                margin-right: 30px;
                font-size: 14px;
            }

        .floatfix {
            content: '';
            display: table;
            clear: both;
        }

        .footer {
            position: fixed;
            left: 0;
            bottom: 0;
            width: 100%;
            height: 24px;
            line-height: 24px;
            color: #58666e;
            font-size: 12px;
            text-align: center;
            z-index: 100;
        }

        /*main style*/
        .mycontainer {
            width: 1120px;
            margin: 70px auto 40px auto;
            color: #5b5b5b;
            position: relative;
            z-index: 200;
        }

            .mycontainer .left {
                width: 280px;                
                float: left;
                box-sizing: border-box;                
                float: left;
            }

            .mycontainer .right {
                box-sizing: border-box;
                width: 822px;
                margin-left: 18px;
                background-color: #fff;
                float: left;
                border: 1px solid #e9eaec;
                padding: 10px 0 0 10px;
            }

        .groups {
            background-color: #fff;
            border: 1px solid #e9eaec;
        }

        #btn-loadmore {
            width: 820px;
            box-sizing: border-box;
            text-align: center;
            height: 34px;
            line-height: 32px;
            float: right;
            font-size: 14px;
            margin-top: 10px;
            background-color: #f0f0f0;
            color: #333;
            position: relative;
            z-index: 200;
        }

            #btn-loadmore:hover {
                background-color: #292826;
                color: #fff;
            }

        .left .title {
            color: #333;
            font-weight: bold;
            padding: 12px;
            border-bottom: 1px solid #e9eaec;
            background-color: #f7f7f7;
        }

        .left .nums {
            background-color: #d9534f;
            color: #fff;
            height: 20px;
            line-height: 20px;
            position: absolute;
            top: 10px;
            right: 10px;
            border-radius: 4px;
            padding: 0 5px;
            font-size: 12px;
        }

        #grouplist li {
            height: 40px;
            line-height: 40px;
            padding-left: 22px;
            color: #444;
            font-size: 14px;
            cursor: pointer;
            position: relative;
        }
        .group-active {
            border-left:2px solid #3eb94e;
        }
            #grouplist li:not(:last-child) {
                border-bottom: 1px solid #f0f0f0;
            }

            #grouplist li:hover {
                background-color: #f2f2f2;
            }

        .back-image {
            background-repeat: no-repeat;
            background-position: 50% 50%;
            background-size: cover;
        }

        .article-item {
            width: 260px;
            height: 270px;
            /*border: 1px solid #e9eaec;*/
            margin-right: 10px;
            margin-bottom: 10px;
            float: left;
            box-sizing: border-box;
            background-color: #fff;
            cursor: pointer;
            color: #333;
            -webkit-transition: all .2s linear;
            transition: all .2s linear;
        }

            .article-item:hover {
                /*background-color: #292826 !important;
                color: #fff !important;*/
                -webkit-box-shadow: 0 15px 30px rgba(0,0,0,0.1);
                box-shadow: 0 15px 30px rgba(0,0,0,0.1);
                -webkit-transform: translate3d(0, -2px, 0);
                transform: translate3d(0, -2px, 0);
            }

            .article-item .title {
                height: 50px;
                overflow: hidden;
                text-overflow: ellipsis;
                display: -webkit-box!important;
                -webkit-box-orient: vertical;
                -webkit-line-clamp: 2;
                padding: 10px;
                font-size: 16px;
                line-height: 1.7;
            }

            .article-item .infos {
                color: #afafaf;
                font-size: 13px;
                height: 38px;
                line-height: 38px;
                box-sizing: border-box;
                padding: 0 8px;
            }

        .infos p {
            width: 50%;
            float: left;
        }

        .infos .time {
            text-align: right;
        }

        .article-item .thumb {
            height: 160px;
            position:relative;
        }

        .thumb .viewtimes {
            position: absolute;
            bottom: 5px;
            right: 5px;
            height:20px;
            line-height:20px;
            padding:0 6px;                    
            color: #fe6649;
            font-size: 14px;
            padding-left:22px;
        }

        .plusGlobalIcon {
            display: inline-block;
            background-image: url(view-icon.png);
            background-repeat: no-repeat;            
            background-size:auto 20px;
            padding-left:6px;
        }    

        .infos i {
            padding-right: 5px;
        }

        /*加载动画*/
        #load-animate {
            height: 50px;
            margin-right: 10px;
            clear: both;
            position: relative;
            display: none;
        }

        [data-loader='jumping'] {
            position: relative;
            top: 20px;
            width: 50px;
            -webkit-perspective: 200px;
            perspective: 200px;
            margin: 0 auto;
        }

            [data-loader='jumping']:before,
            [data-loader='jumping']:after {
                position: absolute;
                width: 20px;
                height: 20px;
                content: '';
                animation: jumping .5s infinite alternate;
                background: rgba(41,40,38,0);
            }

            [data-loader='jumping']:before {
                left: 0;
            }

            [data-loader='jumping']:after {
                right: 0;
                animation-delay: .15s;
            }

        @-webkit-keyframes jumping {
            0% {
                -webkit-transform: scale(1.0) translateY(0px) rotateX(0deg);
                -ms-transform: scale(1.0) translateY(0px) rotateX(0deg);
                -o-transform: scale(1.0) translateY(0px) rotateX(0deg);
                transform: scale(1.0) translateY(0px) rotateX(0deg);
                -webkit-box-shadow: 0 0 0 rgba(41,40,38,0);
                box-shadow: 0 0 0 rgba(41,40,38,0);
            }

            100% {
                -webkit-transform: scale(1.2) translateY(-25px) rotateX(45deg);
                -ms-transform: scale(1.2) translateY(-25px) rotateX(45deg);
                -o-transform: scale(1.2) translateY(-25px) rotateX(45deg);
                transform: scale(1.2) translateY(-25px) rotateX(45deg);
                background: rgb(41,40,38);
                -webkit-box-shadow: 0 25px 40px rgb(41,40,38);
                box-shadow: 0 25px 40px rgb(41,40,38);
            }
        }

        @keyframes jumping {
            0% {
                -webkit-transform: scale(1.0) translateY(0px) rotateX(0deg);
                -ms-transform: scale(1.0) translateY(0px) rotateX(0deg);
                -o-transform: scale(1.0) translateY(0px) rotateX(0deg);
                transform: scale(1.0) translateY(0px) rotateX(0deg);
                -webkit-box-shadow: 0 0 0 rgba(0,0,0,0);
                box-shadow: 0 0 0 rgba(0,0,0,0);
            }

            100% {
                -webkit-transform: scale(1.2) translateY(-25px) rotateX(45deg);
                -ms-transform: scale(1.2) translateY(-25px) rotateX(45deg);
                -o-transform: scale(1.2) translateY(-25px) rotateX(45deg);
                transform: scale(1.2) translateY(-25px) rotateX(45deg);
                background: rgb(41,40,38);
                -webkit-box-shadow: 0 25px 40px rgb(41,40,38);
                box-shadow: 0 25px 40px rgb(41,40,38);
            }
        }

        /*search style*/
        .search-area {
            height:40px;
            margin-top:10px;
            border:1px solid #e9eaec;
            position:relative;
        }

        #search-input {
            width:100%;
            height:40px;
            line-height:40px;
            outline:none;
            border:none;
            padding:0 48px 0 8px;
            box-sizing:border-box;
            font-size:13px;
        }

        .fa-search {
            width:40px;
            height:40px;
            position:absolute;
            top:0;
            right:0;
            line-height:40px;
            text-align:center;
            border-left:1px solid #e9eaec;
            background-color:#f5f5f5;
        }

        .btn-group {
            margin-top:10px;
            text-align:center;
        }

            .btn-group > a {
                color:#fff;                
                display:block;
                height:40px;
                line-height:40px;
                background-color:#3eb94e;
            }
    </style>
</head>
<body>
    <div class="header">
        <ul class="header-inner floatfix">
            <li class="title"><i class="fa fa-file-text" style="padding-right: 5px;"></i>利郎微信文章管理</li>
            <li class="infos">
                <span id="username"><i class="fa fa-user" style="padding-right: 5px;"></i><%=UNAME %></span>，您好！
                <a href="javascript:;" onclick="logout();" style="color: #fff;">退出</a>
            </li>
        </ul>
    </div>
    <div class="mycontainer floatfix">
        <!--文章分组-->
        <div class="left">
            <div class="groups">
                <p class="title">利郎男装 <i class="fa fa-angle-right"></i> 品牌速递</p>
                <ul id="grouplist">
                </ul>
            </div>
            <!--搜索框-->
            <div class="search-area">
                <input type="text" id="search-input" placeholder="文章标题关键字.." />
                <i class="fa fa-search"></i>
            </div>
            <!--相关功能按钮-->
            <div class="btn-group">
                <a href="LLEditor.aspx" target="_blank"><i class="fa fa-edit" style="padding-right:5px;"></i>新建文章</a>
            </div>
        </div>
        <!--文章列表-->
        <div class="right">
            <div id="articles">
                <!--<div class="article-item">
                    <div class="thumb back-image" style="background-image: url(bg5.jpg)"></div>
                    <div class="title">
                        LILANZ 2015秋季陈列手册
                    </div>
                    <div class="infos">
                        <p class="user"><i class="fa fa-user"></i>李家的风</p>
                        <p class="time"><i class="fa fa-clock-o"></i>2016-06-28</p>
                    </div>
                </div>-->
            </div>
            <!--加载动画-->
            <div id="load-animate">
                <div data-loader="jumping"></div>
            </div>
        </div>
        <!--加载更多按钮-->
        <a href="javascript:" id="btn-loadmore" onclick="LoadMore();">加载更多</a>
    </div>
    <!--页脚-->
    <div class="footer">&copy;2016 利郎信息技术部</div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>

    <!--模板区-->
    <script id="articleItem-temp" type="text/html">
        <div class="article-item" xh="{{xh}}" id="{{id}}" onclick="ClickArticle({{id}})">
            <div class="thumb back-image" style="background-image: url({{thumb}})">
               <p class="viewtimes plusGlobalIcon">{{viewtimes}}</p>
            </div>
            <div class="title">
                {{title}}
            </div>
            <div class="infos">
                <p class="user"><i class="fa fa-user"></i>{{author}}</p>
                <p class="time"><i class="fa fa-clock-o"></i>{{createtime}}</p>
            </div>
        </div>
    </script>
    
    <script id="articleGroup-temp" type="text/html">
        <li gid="{{id}}" onclick="ClickGroup({{id}})">
            <span>{{groupname}}</span>
            <p class="nums">{{sl}}</p>
        </li>
    </script>

    <script type="text/javascript">
        var CurrGroupID = "0";

        $(document).ready(function () {
            LeeJSUtils.LoadMaskInit();
            LoadGroups();
        });


        function LoadMore() {
            $("#load-animate").show();
            setTimeout(function () {
                LoadArticleList(false);
            }, 1000);
        }

        function ClickArticle(aid) {
            var url = "LLEditor.aspx?aid=" + aid + "&gid=" + CurrGroupID;
            window.open(url);
        }

        //加载分组数据
        function ClickGroup(gid) {
            LeeJSUtils.showMessage("loading", "正在加载文章数据，请稍候..");
            setTimeout(function () {
                CurrGroupID = gid;
                $("#grouplist li").removeClass("group-active");
                $("#grouplist li[gid=" + CurrGroupID + "]").addClass("group-active");
                LoadArticleList(true);
            }, 100);
        }

        //加载分组列表
        function LoadGroups() {
            LeeJSUtils.showMessage("loading", "正在加载分组数据，请稍候..");
            $.ajax({
                type: "POST",
                timeout: 5000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "LLEditorCore.aspx",
                data: { ctrl: "LoadGroups_PC", ssid: "10" },
                success: function (msg) {
                    if (msg == "") {

                    }
                    else {
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {
                            var data = JSON.parse(msg);
                            var len = data.rows.length;
                            var str_html = "";
                            for (var i = 0; i < len; i++) {
                                var row = data.rows[i];
                                row.sl = row.sl == "" ? "0" : row.sl;
                                str_html += template("articleGroup-temp", row);
                            }//end for
                            //alert(str_html);
                            $("#grouplist").empty().append(str_html);
                            CurrGroupID = $("#grouplist li:first-child").attr("gid");                            
                            $("#grouplist li:first-child").addClass("group-active");
                            LoadArticleList(true);
                        }//end else
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });//end AJAX
        }

        //加载文章列表
        function LoadArticleList(isFirst) {
            if (isFirst) {
                LeeJSUtils.showMessage("loading", "正在加载文章数据，请稍候..");
                $("#btn-loadmore").text("加载更多...");
            }
            else {
                $("#load-animate").show();
            }
            var lastxh = $("#articles .article-item:last-child").attr("xh");
            if (lastxh == "" || lastxh == undefined || isFirst)
                lastxh = "0";
            $.ajax({
                type: "POST",
                timeout: 5000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "LLEditorCore.aspx",
                data: { ctrl: "LoadArticle_PC", gid: CurrGroupID, lastxh: lastxh },
                success: function (msg) {
                    if (msg == "" && !isFirst) {
                        $("#btn-loadmore").text("该分组无数据啦...");
                        $("#load-animate").fadeOut(400);
                    }
                    else {                        
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else if (msg != "") {
                            var data = JSON.parse(msg);
                            var len = data.rows.length;
                            var str_html = "";
                            for (var i = 0; i < len; i++) {
                                var row = data.rows[i];
                                row.author = row.author == "" ? "利郎男装" : row.author;
                                row.thumb = row.thumb == "" ? "default.jpg" : row.thumb;
                                str_html += template("articleItem-temp", row);
                            }//end for     
                            if (isFirst) {
                                $("#articles").empty().append(str_html);
                                $("#leemask").hide();
                            }
                            else {
                                $("#load-animate").fadeOut(400);
                                $("#articles").append(str_html);
                            }
                        } else {
                            $("#articles").empty();
                            LeeJSUtils.showMessage("warn","该分组暂时还没有数据！");
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });//end AJAX
        }

        //退出
        function logout() {
            $.ajax({
                type: "POST",
                timeout: 10000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "LLEditorCore.aspx",
                data: { ctrl: "logout" },
                success: function (msg) {
                    if (msg.indexOf("Successed") > -1) {
                        window.location.reload();
                    } else
                        LeeJSUtils.showMessage("error", "操作失败 !" + msg.replace("Error:", ""));
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });
        }
    </script>
</body>
</html>
