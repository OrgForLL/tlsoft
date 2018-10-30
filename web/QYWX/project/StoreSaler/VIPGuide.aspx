<%@ Page Title="分配顾问" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>
<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>  
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    public string SystemKey = "", tzid = "", mdid = "";
    public string OA_WebPath = "";

    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (!this.IsPostBack)
        {
            SystemKey = this.Master.AppSystemKey;
            tzid = Convert.ToString(Session["tzid"]);
            mdid = Convert.ToString(Session["mdid"]);
            string RoleID = Convert.ToString(Session["RoleID"]);
             
            clsWXHelper.CheckQQDMenuAuth(11);    //检查菜单权限
                        
            //if (RoleID != "2" && RoleID != "99")
            //    clsWXHelper.ShowError("您没有权限使用该功能！");
            OA_WebPath = clsConfig.GetConfigValue("OA_WebPath");
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        /*清除浏览器默认样式*/
        *
        {
            margin: 0;
            padding: 0;
            -webkit-box-sizing: border-box;
            -moz-box-sizing: border-box;
            box-sizing: border-box; 
        }
        
        ul
        {
            list-style: none;
        }
        
        a, button, input, textarea
        {
            -webkit-tap-highlight-color: rgba(0,0,0,0);
        }
        
        body
        {
            font-family: Helvetica,Arial, "Hiragino Sans GB" , "Microsoft Yahei" , "微软雅黑" ,STHeiti, "华文细黑" ,sans-serif;
            font-size: 14px;
            background-color: #f0f0f0;
            color:#515151;
        }
        a
        {
            color: #666;
            text-decoration: none;
            font-weight: bold;
        }
        .header
        {
            display: block;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 900;
            height: 50px;
            background-color: #272b2e;
            border-bottom: 1px solid #cbcbcb;
            text-align: center;
            padding: 0 10px;
            box-sizing: border-box;
        }
        
        .logo
        {
            height: 20px;
            margin: 0 auto;
            margin-top: 15px;
            color: #fff;
            z-index: 110;
        }
        
        .logo img
        {
            height: 100%;
            width: auto;
        }
        .vipul
        {
            top: 103px; /*width: 100%;*/
            list-style: none;
            box-shadow: inset 0 0 0 1px rgba(0,0,0,.16),0 1px 3px rgba(0,0,0,.06);
            background-color: #f0f0f0;
            overflow-x: hidden;
            -webkit-overflow-scrolling: touch;
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);
        }
        
        .vipul li, .guideul li
        {
            height: 65px;
            padding: 6px 10px;
            border-bottom: 1px solid #ddd;
            position: relative;
            overflow: hidden;
        }
        
        .guideul li:last-child
        {
            border: none;
        }
        
        .vipul li p span
        {
            position: absolute;
            display: inline-block;
            right: -20px;
            box-shadow: 0px 0px 5px rgba(0,0,0,0.2), inset 0px 5px 30px rgba(255,255,255,0.2);
            text-align: center;
            text-transform: uppercase;
            top: 6px;
            background: #333333; /*#d93131#666666*/
            width: 75px;
            padding: 2px 10px;
            -webkit-transform: rotate(45deg);
            -moz-transform: rotate(45deg);
            -o-transform: rotate(45deg);
            -ms-transform: rotate(45deg);
            color: #fff;
            font-size: 10px;
        }
        
        .userimg
        {
            border: 2px solid #fff;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            overflow: hidden;
            float: left;
            background-size: cover;
            background-position: 50% 50%;
            background-repeat: no-repeat;
            color: #d93131;
            font-weight: bold;
            text-align: center;
            padding: 10px 0px;
        }
        
        .userimg span
        {
            position: absolute;
            display: inline-block;
            left: -25px;
            box-shadow: 0px 0px 5px rgba(0,0,0,0.2), inset 0px 5px 30px rgba(255,255,255,0.2);
            text-align: center;
            text-transform: uppercase;
            top: 45px;
            background: #d93131;
            width: 75px;
            padding: 0px 0px;
            -webkit-transform: rotate(45deg);
            -moz-transform: rotate(45deg);
            -o-transform: rotate(45deg);
            -ms-transform: rotate(45deg);
            color: #fff;
            font-size: 10px;
        }
        
        .userimg img
        {
            width: 100%;
            height: 100%;
        }
        
        .vipul li > h3, .guideul li > h3
        {            
            font-weight: 400;
            font-size: 16px;
            margin: 2px 0 0 66px;
            line-height: 1.5;
            letter-spacing: 1px;
        }
        
        .vipul li p:not(:last-child), .guideul li p
        {            
            line-height: 1;
            margin: 8px 0 0 66px;
            letter-spacing: 1px;
            white-space: nowrap;
            text-overflow: ellipsis;
        }   
        
        /*.guideul li p
        {            
            margin: 8px 0 0 66px;
            letter-spacing: 1px;
            white-space: nowrap;
            text-overflow: ellipsis;
        }*/
        
        .ri
        {
            position: absolute;
            right: 10px;
            top: 50%;
            padding: 5px;
            font-size: 1.1em;
            border: 1px solid #ebebeb;
            border-radius: 5px;
            -webkit-transform: translate(0, -50%);
        }
        
        
        .showguide
        {
            transform: translate3d(0,0,0);
            -webkit-transform: translate3d(0,0,0);
            -webkit-transform: translate(0,0,0);
        }
        
        .floatfix:after
        {
            content: "";
            display: table;
            clear: both;
        }
        
        /*用户信息css*/
        .userinfo
        {
            position: fixed;
            top: 50px;
            bottom: 0;
            width: 100%;
            background-color: rgb(229,229,229);
            z-index: 206;
            padding: 0 10px;
            box-sizing: border-box;
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);
            -webkit-transform: translate(100%,0);
            -webkit-transform: translate3d(100%,0,0);
            transform: translate3d(100%,0,0);
            overflow-x: hidden;
            -webkit-overflow-scrolling: touch;
        }
        
        .showinfo
        {
            transform: translate3d(0,0,0);
            -webkit-transform: translate3d(0,0,0);
            -webkit-transform: translate(0,0,0);
        }
        
        .guidelist
        {
            position: fixed;
            top: 59px;
            bottom: 60px;
            width: 100%;
            list-style: none;
            box-shadow: inset 0 0 0 1px rgba(0,0,0,.16),0 1px 3px rgba(0,0,0,.06);
            background-color: #f0f0f0;
            overflow-x: hidden;
            overflow-y: hidden;
            -webkit-overflow-scrolling: touch;
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transform: translate3d(100%,0,0);
        }
        
        .showguidelist
        {
            transform: translate3d(0,0,0);
            -webkit-transform: translate3d(0,0,0);
            -webkit-transform: translate(0,0,0);
        }
        
        .headimg
        {
            width: 70px;
            height: 70px;
            border: 4px solid #ebebeb;
            border-radius: 50%;
            -webkit-border-radius: 50%;
            background-size: cover;
            background-position: top center;
            margin: 0 auto;
        }
        
        .userinfo hr
        {
            width: 80%;
            margin: 10px auto 15px auto;
            border: none;
            height: 1px;
            background-color: #ccc;
        }
        
        .nickname
        {
            text-align: center;
            font-size: 1.4em;
            margin-top: 10px;
            letter-spacing: 1px;
            color: #666;
            font-weight: bold;
        }
        
        .userinfo ul
        {
            list-style: none;
        }
        
        .userheader ul li
        {
            color: #808080;
            float: left;
            width: 33.33%;
            text-align: center;
            box-sizing: border-box;
        }
        
        .userheader ul li:not(:first-child)
        {
            border-left: 1px solid #ccc;
        }
        
        .userval
        {
            color: #494747;
            font-size: 1.1em;
            text-shadow: 0 0 1px #ccc;
        }
        
        .userheader, .usernav
        {
            background-color: #fff;
            border-radius: 5px;
            padding-bottom: 10px;
            margin: 10px auto;
            box-shadow: inset 0 0 0 1px rgba(0,0,0,.16),0 1px 3px rgba(0,0,0,.06);
        }
        
        .userinfo .copyright
        {
            text-align: center;
            color: #808080;
            position: relative;
        }
        .copyright
        {
            margin-bottom: 20px;
        }
        .backbtn
        {
            position: absolute;
            top: 0;
            bottom: 0;
            line-height: 50px;
            font-size: 1.4em;
            color: #b1afaf;
            left: 0;
            display: none;
            padding: 0 20px;
        }
        
        .viewout
        {
            transform: translate3d(-100%,0,0);
            -webkit-transform: translate3d(-100%,0,0);
            -webkit-transform: translate(-100%,0,0);
        }
        
        /*mask css*/
        .mask
        {
            color: #fff;
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            font-size: 1.1em;
            text-align: center;
            display: none;
        }
        
        .loader
        {
            position: absolute;
            top: 50%;
            left: 50%;
            -webkit-transform: translate(-50%, -50%);
            transform: translate(-50%, -50%);
            background-color: rgba(39, 43, 46, 0.52);
            padding: 15px 25px;
            border-radius: 5px;
        }
        
        #loadtext
        {
            margin-top: 5px;
            font-weight: bold;
        }
        
        .search
        {
            height: 44px;
            margin-top: 50px;
            position: relative;
            z-index: 201;
            background-color: #f0f0f0;            
            text-align: center;
            box-sizing: border-box;
        }
        
        #searchtxt
        {
            position: absolute;
            outline: none;
            display: block;
            width: 92%;
            left: 50%;
            margin-left: -46%;
            height: 31px;
            margin-top: 6px;
            -webkit-appearance: none;
            border-radius: 5px;
            font-size: 1.1em;
            padding: 0 10px;
            box-sizing: border-box;
            border: 1px solid #dedee0;
            text-align: center;
        }
        
        .userinfo h4
        {
            margin: 10px 10px;
            padding: 10px 0;
            font-size: 1.2em;
            color: #666;
            font-weight: bold;
            border-bottom: 1px solid #ebebeb;
        }
        
        
        /*loadmore style*/
        #loadmore_btn
        {
            padding: 7px 10px;
            color: #333;
            font-size: 1.1em;
        }
        .lmdiv
        {
            text-align: center;
            margin-top: 10px;
        }
        
        /*回到顶部样式*/
        .cd-top
        {
            height: 40px;
            width: 40px;
            position: fixed;
            bottom: 40px;
            right: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            z-index: 1000;
            white-space: nowrap;
            background: rgba(0,0,0,0.7);
            visibility: hidden;
            opacity: 0;
            border-radius: 5px;
            -webkit-transition: opacity .3s 0s, visibility 0s .3s;
            -moz-transition: opacity .3s 0s, visibility 0s .3s;
            transition: opacity .3s 0s, visibility 0s .3s;
        }
        .cd-top i
        {
            padding: 12px;
            color: #fff;
            font-size:15px;
        }
        .cd-top.cd-is-visible, .cd-top.cd-fade-out, .no-touch .cd-top:hover
        {
            -webkit-transition: opacity .3s 0s, visibility 0s 0s;
            -moz-transition: opacity .3s 0s, visibility 0s 0s;
            transition: opacity .3s 0s, visibility 0s 0s;
        }
        .cd-top.cd-is-visible
        {
            visibility: visible;
            opacity: 1;
        }
        
        .bindSaler
        {
            background-color:#272B2E;
            color:#fff;
        }
        
        #vipcount
        {
            padding: 5px;
            font-weight: bold;
            color: #fff;
            background-color: rgba(0,0,0,0.4);
            border-radius: 4px;
        }
        
        .page-top
        {
            top: 0;
            -webkit-transform: translate3d(0, -100%, 0);
            transform: translate3d(0, -100%, 0);
        }
        
        .sorts
        {
            background-color: #272B2E;
            position: absolute;
            right: 10px;
            top: 50%;
            margin-top: -15px;
            padding: 0 12px;
            height: 30px;
            border-radius: 4px;
            line-height: 29px;
            border: 1px solid #161A1C;
            box-shadow: 0 1px 1px #2B2F32 inset;
            font-size: 15px;
            color: #DFE0E0;
            z-index: 120;
            cursor: pointer;
            display: none;
        }
        
        /*sortstyle*/
        .mysort
        {
            position: fixed;
            top: 50px;
            right: 0;
            width: 100%;
            z-index: 800;
            -webkit-transition: -webkit-transform .4s cubic-bezier(.4,.01,.165,.99);
            transition: transform .4s cubic-bezier(.4,.01,.165,.99);
        }
        
        .sortul
        {
            background-color: #272b2e;
            
        }
        
        .sortul li
        {
            text-align: center;
            color: #f0f0f0;
            font-size: 1.1em;
            float: left;
            padding: 8px;
            width: 33.3%;
            border-bottom: 1px solid #161A1C;
            /*border-left:1px solid #161A1C;right: 0;*/
        }

        .sortul li:not(:last-child)
        {
            border-right: 1px solid #161A1C;
        }
        
        .filter-item
        {
            display: none;
        }
        
        #filter-btn a
        {
            display: block;
            width: 50%;
            text-align: center;
            float: left;
            background-color: #eee;
            height: 40px;
            line-height: 40px;
            font-size: 1.1em;
            font-weight: bold;
        }
        
        .icon-group {
            position:absolute;
            width:40px;
            height:20px;
            top:50%;
            margin-top:-10px;
            right:30px;
            text-align: right;
        }
        .icon-group img {
            height:20px;
            width:auto;    
        }
    </style>

</asp:Content>      
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="header">
        <div class="logo">
            <div class="backbtn">
                <i class="fa fa-chevron-left"></i>
            </div>
            <img src="../../res/img/StoreSaler/lllogo6.png" alt="" />
        </div>
        <div class="sorts" onclick="mysort()" style="display: block;" isshow="0">
            <i class="fa fa-filter"></i>
        </div>
    </div>
    <div id="container">
        <!--VIP信息-->
        <div class="viplist floatfix">
            <div class="search">
                <input id="searchtxt" type="text" placeholder="请输入VIP或导购名称关键字" oninput="searchFunc()"/>
                <input type="text" style="display:none" />
            </div>
            <p style="text-align: center; margin: 4px 0 10px 0;">
                <span id="vipcount">
                    <span>VIP总数：<span id="vipAll">--</span></span>
                    <span>当前数：<span id="vipCurr">--</span></span>
                </span>
            </p>
            <ul class="vipul" id="ulVIP" runat="server">
            </ul>
            <div class="lmdiv">
                <a href="javascript:;" id="loadmore_btn">- 加载更多 -</a>
            </div>
        </div>
        <!--VIP信息 end-->
        <!--导购信息-->
        <div class="userinfo" id="guideview">
            <div class="userheader">
                <h4>TA的专属导购</h4>
                <div class="headimg" style="background-image: url(../../res/img/StoreSaler/defaulticon.jpg);" id="headimg" onclick="autoSearch()"></div>
                <p class="nickname" id="name" onclick="autoSearch()">未分配</p>
                <input id='salerID' type='hidden' style='display: none' value='' />
                <hr />
                <ul class="floatfix">
                    <li>
                        <p class="userval" id="post">
                        </p>
                        <p>
                            岗位</p>
                    </li>
                    <li onclick="Responsible()">
                        <p class="userval" id="rs">
                            0</p>
                        <p>
                            负责人数</p>
                    </li>
                    <li>
                        <p class="userval" id="level">
                            --</p>
                        <p>
                            等级</p>
                    </li>
                </ul>
            </div>
            <div class="usernav">
                <h4>
                    分配导购</h4>
                <ul class="guideul" id="ulGuide" runat="server">
                </ul>
            </div>
        </div>
        <!--导购信息 end-->
    </div>
    <!--排序列表-->
    <section id="filter" class="mysort page-top" isshow="0">
        <ul class="sortul floatfix">
            <li class="sort-item" onclick="FilterAll()">全&nbsp;&nbsp;&nbsp;&nbsp;部</li>
            <li class="sort-item" onclick="FilterVIP('hasSaler')">已分配导购</li>
            <li class="sort-item" onclick="FilterVIP('notSaler')">未分配导购</li>
            <!-- <li class="sort-item" onclick="FilterVIP('fans')">未注册VIP</li>
            <li class="sort-item" onclick="FilterVIP('haswx')">已激活微信</li>
            <li class="sort-item" onclick="FilterVIP('notwx')">未激活微信</li> -->
            
        </ul>
    </section>
    <div class="cd-top">
        <i class="fa fa-chevron-up"></i>
    </div>
    <!--加载提示层-->
    <div class="mask">
        <div class="loader center-translate">
            <div>
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext">
                正在加载...</p>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type="text/javascript">
        var guideShow = false;
        var createID = "<%=SystemKey %>";
        var tzid = "<%=tzid %>";
        var mdid = "<%=mdid %>";
        var defaultImg = "<%=OA_WebPath %>res/img/StoreSaler/defaulticon.jpg";
        var vipID = "", openid = "";
        var lastID = "-1";
        var bs = true;

        $(function () {
            FastClick.attach(document.body);
            LoadVipList();

            $("[id$=loadmore_btn]").click(function () {
                if ($("[id$=loadmore_btn]").text() == "已无更多数据...") return;
                LoadVipList();
            });

            $(".backbtn").on("click", function () {
                $(".backbtn").fadeOut(500);
                $(".cd-top").fadeIn(500);
                $(".sorts").fadeIn(500);
                $("[id$=filter]").fadeIn(500);
                $(".userinfo").removeClass("showinfo");
                $(".vipul").removeClass("viewout");
            });

            /*返回顶部*/
            var offset = 300,
		    offset_opacity = 1200,
		    scroll_top_duration = 700,
		    $back_to_top = $('.cd-top');
            $(window).scroll(function () {
                ($(this).scrollTop() > offset) ? $back_to_top.addClass('cd-is-visible') : $back_to_top.removeClass('cd-is-visible cd-fade-out');
                if ($(this).scrollTop() > offset_opacity) {
                    $back_to_top.addClass('cd-fade-out');
                }
            });
            $back_to_top.on('click', function (event) {
                event.preventDefault();
                $('body,html').animate({
                    scrollTop: 0
                });
            });
        });

        $.expr[":"].Contains = function (a, i, m) {
            return (a.textContent || a.innerText || "").toUpperCase().indexOf(m[3].toUpperCase()) >= 0;
        };
        
        //点击导购头像或者是姓名自动进行筛选
        function autoSearch() {
            $("[id$=searchtxt]").val($("#name").text())            
            searchFunc();
            $(".backbtn").fadeOut(500);
            $(".cd-top").fadeIn(500);
            $(".sorts").fadeIn(500);
            $("[id$=filter]").fadeIn(500);
            $(".userinfo").removeClass("showinfo");
            $(".vipul").removeClass("viewout");
        }

        /*搜索框实时本地检索*/
        function searchFunc() {
            var stxt = $("[id$=searchtxt]").val();
            SearchVIP(stxt);
        }

        /*搜索VIP*/
        function SearchVIP(stxt) {
            var obj = $(".vipul li h3");
            if (obj.length > 0) {
                if (stxt) {
                    $matches = $(".vipul li").find("h3:Contains(" + stxt + ")").parent();
                    $matches2 = $(".vipul li .vipdg").find("span:Contains(" + stxt + ")").parent().parent();
                    $("li", $(".vipul")).not($matches.add($matches2)).hide();
                    $matches.add($matches2).show();
                    $(".lmdiv").hide();
                    $("[id$=vipCurr]").text($matches.add($matches2).length); 
                    $("[id$=vipCurr]").parent().show();
                } else {
                    $(".vipul").find("li").show();
                    $(".lmdiv").show();
                    $("[id$=vipCurr]").text("--");
                    $("[id$=vipCurr]").parent().hide();
                }
            }
        }

        /*负责人数onclick*/
        function Responsible() {
            FilterVIP('saler');
            $(".backbtn").fadeOut(500);
            $(".cd-top").fadeIn(500);
            $(".sorts").fadeIn(500);
            $("[id$=filter]").fadeIn(500);
            $(".userinfo").removeClass("showinfo");
            $(".vipul").removeClass("viewout");
        }

        /*VIP li onclick*/
        function VIPClick(obj){
            if (bs) {
                LoadSalerList();
                bs = false;
            }
            $(".ri a").css('display', 'block');
            $("[id$=ulGuide] li").removeClass("bindSaler");
            var salerID = $(obj).attr("saler").replace("S", "");
            vipID = $(obj).attr("id").replace("VIP", "");
            openid = $(obj).attr("openid");
            var vipName = $(obj).children("h3").html();
            $(".userheader h4").text(vipName + "的专属导购");
            $("[id$=dg" + salerID + "]").addClass("bindSaler");
            $("[id$=Saler" + salerID + "]").css('display', 'none');
            LoadVIPGuide(salerID);

            $(".vipul").addClass("viewout");
            $(".userinfo").addClass("showinfo");
            $(".backbtn").fadeIn(500);
            $(".cd-top").fadeOut(500);
            $(".sorts").fadeOut(500);
            $("[id$=filter]").fadeOut(500);
        }

        /*筛选全部onclick*/
        function FilterAll() {
            lastID = "-1";
            $(".lmdiv").show();
            $("[id$=loadmore_btn]").text("- 加载更多 -");
            LoadVipList();
        }

        /*筛选VIP*/
        function FilterVIP(type) {
            var img;
            var row;
            var strHtml = "";
            var saler = $("[id$=salerID]").val();
            showLoader("loading", "正在筛选...");
            $.ajax({
                type: "POST",
                timeout: 10000,
                url: "VIPGuideCore.aspx",
                data: { ctrl: "FilterVIP", type: type, mdid: mdid, saler: saler, SystemKey: createID },
                success: function (data) {
                    if (data.indexOf("Error：") > -1) {
                        showLoader("warn", data.replace("Error：", ""));
                    } else if (data.indexOf("Warn:") > -1) {
                        showLoader("successed", data.replace("Warn:", ""));
                        $("[id$=ulVIP]").html('');
                        $("[id$=vipCurr]").text('0');
                        $("[id$=vipCurr]").parent().show();
                        $(".mask").hide();
                        $(".lmdiv").show();
                        $("[id$=loadmore_btn]").text("已无更多数据...");
                        $("[id$=filter]").addClass("page-top");
                    } else {
                        data = JSON.parse(data);
                        var len = data.rows.length;
                        if (len > 0) {
                            strHtml = VIPHtml(data);
                            $("[id$=ulVIP]").html(strHtml);
                            $("[id$=vipCurr]").text(len);
                            $("[id$=vipCurr]").parent().show();
                            $(".mask").hide();
                            $(".lmdiv").hide();
                            $("[id$=filter]").addClass("page-top");
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "VIP筛选失败，请刷新重试！" + XMLHttpRequest + textStatus + errorThrown);
                }
            });
        }

        function VIPHtml(data) {
            var img, typeimg;
            var row;
            var strHtml = "";
            for (var i = 0; i < data.rows.length; i++) {
                row = data.rows[i];
                img = row.wxHeadimgurl.replace("", "");
                if (img == "")
                    img = defaultImg;

                if (row.usertype == "VIP") {
                    typeimg = "<img src='../../res/img/storesaler/icon-vip-1.png' />";
                } else {
                    typeimg = "<img src='../../res/img/storesaler/icon-vip-0.png' />";
                }
                /* if (row.usertype == "VIP")
                    typeimg = "<img src='../../res/img/storesaler/icon-wechat-0.png' /><img src='../../res/img/storesaler/icon-vip-1.png' />";
                else if (row.usertype == "WX")
                    typeimg = "<img src='../../res/img/storesaler/icon-wechat-1.png' /><img src='../../res/img/storesaler/icon-vip-0.png' />";
                else if (row.usertype == "VIP-WX")
                    typeimg = "<img src='../../res/img/storesaler/icon-wechat-1.png' /><img src='../../res/img/storesaler/icon-vip-1.png' />";
                else
                    typeimg = "<img src='../../res/img/storesaler/icon-wechat-0.png' /><img src='../../res/img/storesaler/icon-vip-0.png' />";
 */
                strHtml += "<li id='VIP" + row.vipid + "' saler='S" + row.salerid + "' openid='" + row.openid + "' onclick='VIPClick(this)' xh=" + row.xh + ">";
                strHtml += "<div class='userimg' style='background-image:url(" + img + ")'></div><h3>" + row.xm + "</h3>";
                strHtml += "<div class='icon-group'>" + typeimg + "</div><p>性别:" + row.xb + " &nbsp;加入时间:" + row.createTime + "</p>";
                if (row.salerid == "0" || row.salername == '')
                    strHtml += "<p class='vipdg' style='display:none;'><span>" + row.salername + "</span></p></li>";
                else
                    strHtml += "<p class='vipdg'><span>" + row.salername + "</span></p></li>";
            }
            return strHtml;
            
        }

        //加载VIP列表
        function LoadVipList() {
            var img;
            var row;
            var strHtml = "";
            showLoader("loading", "正在加载...");
            $.ajax({
                type: "POST",
                timeout: 10000,
                url: "VIPGuideCore.aspx",
                data: { ctrl: "getVIPList", mdid: mdid, lastID: lastID, SystemKey: createID },
                success: function (data) {
                    if (data.indexOf("Error：") > -1) {
                        showLoader("warn", data.replace("Error：", ""));
                    } else if (data.indexOf("Warn:") > -1) {
                        showLoader("successed", "获取成功！");
                        $("[id$=loadmore_btn]").text("已无更多数据...");
                    } else {
                        data = JSON.parse(data);
                        var len = data.rows.length;
                        if (len > 0) {
                            strHtml = VIPHtml(data);
                            $("[id$=filter]").addClass("page-top");
                            if (lastID == "-1") {
                                $("[id$=vipAll]").text(data.rows[0].rs);
                                $("[id$=vipCurr]").parent().hide();
                                $("[id$=ulVIP]").html(strHtml);
                                lastID = $(".vipul li:last-child").attr("xh");
                                $(".mask").hide();
                            } else {
                                $("[id$=ulVIP]").append(strHtml);
                                lastID = $(".vipul li:last-child").attr("xh");
                                showLoader("successed", "获取成功！");
                            }
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "VIP加载失败，请刷新重试！" + XMLHttpRequest + textStatus + errorThrown);
                }
            });

        }

        //加载导购列表
        function LoadSalerList() {
            var row;
            var strHtml = "";
            $.ajax({
                type: "POST",
                timeout: 5000,
                async: false,
                url: "VIPGuideCore.aspx",
                data: { ctrl: "getSalerList", tzid: tzid, mdid: mdid },
                success: function (data) {
                    if (data.indexOf("Error：") > -1) {
                        showLoader("warn", data.replace("Error：", ""));
                    } if (data.indexOf("Warn：") > -1) {
                        strHtml = "<li><h3>对不起！当前店铺没有已激活系统的导购人员。</h3><p style='color: red;'>小贴士：导购人员必须先激活全渠道系统，才可被分配为VIP的专属顾问！</p></li>";
                        $("[id$=ulGuide]").html(strHtml);
                        //showLoader("warn", "");
                    } else {
                        data = JSON.parse(data);
                        var len = data.rows.length;
                        var img;
                        if (len > 0) {
                            for (var i = 0; i < len; i++) {
                                row = data.rows[i];
                                img = row.avatar.replace("", "");
                                if (img == "")
                                    img = defaultImg;
                                strHtml += "<li id='dg" + row.salerid + "'><div class='userimg' style='border-color: #ebebeb;background-image:url(" + img + ")'></div><h3>" + row.xm + "</h3><p>岗位:" + row.gwmc + " &nbsp;等级：" + row.mc + "</p><div class='ri'><a id='Saler" + row.salerid + "' sn='" + row.xm + "' href='#' onclick='javascript:BindSaler(this)'>分配</a></div></li>";
                            }
                            $("[id$=ulGuide]").html(strHtml);
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "导购员加载失败，请刷新重试！");
                }
            });
        }

        //分配导购事件
        function BindSaler(obj) {
            var salerID = obj.id.replace("Saler", "");
            showLoader("loading", "正在处理...");
            $.ajax({
                type: "POST",
                timeout: 5000,
                url: "VIPGuideCore.aspx",
                data: { ctrl: "bindVIPSaler", mdid: mdid, salerID: salerID, openid: openid, opinion: '8' }, // mdid, opinion vipID: vipID createID: createID
                success: function (data) {
                    if (data.indexOf("Successed") >= 0) {
                        lastID = "-1";
                        //LoadVipList();
                        showLoader("successed", "分配成功！");
                        var oldSaler = $("[id$=salerID]").val();
                        $("[id$=dg" + oldSaler + "]").removeClass("bindSaler");
                        $("[id$=Saler" + oldSaler + "]").css('display', 'block');
                        $("[id$=dg" + salerID + "]").addClass("bindSaler");
                        $("[id$=Saler" + salerID + "]").css('display', 'none');

                        var salerName = $(obj).attr("sn");
                        $("[id$=VIP" + vipID + "] .vipdg").css('display', 'block');
                        $("[id$=VIP" + vipID + "] .vipdg span").text(salerName);
                        $("[id$=VIP" + vipID + "]").attr("saler","S" + salerID);
                        LoadVIPGuide(salerID);
                    } else {
                        showLoader("warn", data);
//                        setTimeout(function () {
//                            $(".mask").hide();
//                        }, 1000);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "分配导购失败！");
                }
            });
        }

        //专属导购信息
        function LoadVIPGuide(salerID) {
            var img = "";
            $.ajax({
                type: "POST",
                dataType: "text",
                cache: false,
                timeout: 5000,
                url: "VIPGuideCore.aspx",
                data: { ctrl: "getBindSaler", salerID: salerID },
                success: function (data) {
                    if (data.indexOf("Error：") > -1) {
                        showLoader("warn", data.replace("Error：", ""));
                    } else if (data.indexOf("Successed") >= 0) {
                        data = data.replace("Successed:", "");
                        var strArr = data.split("|");
                        img = strArr[0].toString();
                        if (img == "")
                            img = "url(" + defaultImg + ")";
                        else
                            img = "url(" + img + ")";
                        $("[id$=headimg]").css("background-image", img)
                        $("[id$=name]").text(strArr[1]);
                        $("[id$=post]").text(strArr[2]);
                        $("[id$=rs]").text(strArr[4]);
                        $("[id$=level]").text(strArr[3]);
                        $("[id$=salerID]").val(salerID);
                    } else {
                        img = "url(" + defaultImg + ")";
                        $("[id$=headimg]").css("background-image", img)
                        $("[id$=name]").text("未分配");
                        $("[id$=post]").text("--");
                        $("[id$=rs]").text("0");
                        $("[id$=level]").text("--");
                        $("[id$=salerID]").val("0");
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "专属导购加载失败，请刷新重试！");
                }
            });
        }

        //打开排序
        function mysort() {
            if ($("[id$=filter]").attr("isshow") == "0") {
                $("[id$=filter]").attr("isshow", "1");
                $("[id$=filter]").removeClass("page-top");
            }
            else {
                $("[id$=filter]").attr("isshow", "0");
                $("[id$=filter]").addClass("page-top");
            }
        }

        //提示层
        function showLoader(type, txt) {
            switch (type) {
                case "loading":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                    $("[id$=loadtext]").text(txt);
                    $(".mask").show();
                    break;
                case "successed":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                    $("[id$=loadtext]").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(800);
                    }, 1500);
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("[id$=loadtext]").text(txt);
                    $(".mask").show();
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("[id$=loadtext]").text(txt);
                    $(".mask").show();
                    break;
            }
        }

    </script>
</asp:Content>

