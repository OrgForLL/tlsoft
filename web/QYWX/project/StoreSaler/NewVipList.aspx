<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public string mdid = "", khid = "", customerid = "";
    public string AppSystemKey = "", RoleID = "";
    private const string ConfigKeyValue = "1";	//微信配置信息索引值 1为企业号
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数

    private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        //Session["qy_customersid"] = "354";
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string SystemID = "3";
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            RoleID = Convert.ToString(Session["RoleID"]);
            customerid = Convert.ToString(Session["qy_customersid"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            else
            {
                mdid = Convert.ToString(Session["mdid"]);
                if (string.IsNullOrEmpty(mdid) || mdid == "0")
                {
                    clsWXHelper.ShowError("对不起，您无门店信息无法使用此功能！");
                    return;
                }
                khid = Convert.ToString(Session["tzid"]);
                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
                clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "销售神器-客户模块"));
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
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        body {
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            color: #333;
        }

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

        .search_tag {
            height: 40px;
            position: relative;
            z-index: 201;
            background-color: #f0f0f0;
            padding: 0 60px;
            text-align: center;
            overflow: hidden;
        }

        .search_tag_title {
            position: absolute;
            top: 0;
            left: 0;
            width: 60px;
            height: 40px;
            padding-top: 6px;
        }

            .search_tag_title .fa-check-square {
                color: #ccc;
            }

            .search_tag_title.active .fa-check-square {
                color: #333;
            }

        .btn_search {
            position: absolute;
            top: 6px;
            right: 5px;
            height: 31px;
            width: 50px;
            display: block;
            text-align: center;
            background-color: #fff;
            line-height: 28px;
            color: #888;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        .search_tag #searchtxt {
            position: initial;
            left: 0;
            margin-left: 0;
            width: 100%;
        }

        /*attract_tools*/
        .attract_tools {
            background-color: #fff;
            position: absolute;
            left: 0;
            bottom: 0px;
            width: 100%;
            z-index: 900;
            text-align: center;
            font-size: 16px;
            overflow: hidden;
        }

            .attract_tools .title {
                line-height: 36px;
                height: 36px;
            }

            .attract_tools .select_all {
                position: absolute;
                bottom: 0;
                line-height: 36px;
                left: 10px;
                vertical-align: middle;
                color: #666;
            }

                .attract_tools .select_all.checked > .fa-check-circle {
                    color: #272b2e;
                }

            .attract_tools .fa-angle-double-up {
                transition: .2s;
            }

            .attract_tools.show {
                height: 100%;
                display: -webkit-box;
                display: -webkit-flex;
                display: flex;
                -webkit-flex-direction: column;
                flex-direction: column;
                -webkit-justify-content: flex-end;
                justify-content: flex-end;
                background-color: rgba(0, 0, 0, 0.4);
            }

            .attract_tools.show .bar_title {
                background-color: #ffffff;
            }

            .attract_tools.show .fa-angle-double-up {
                transform: rotate(180deg);
            }

            .attract_tools.show .select_all {
                display: none;
            }

            .attract_tools .select_all > .fa {
                font-size: 18px;
                color: #ccc;
                padding-right: 5px;
            }

            .attract_tools .title {
                font-weight: bold;
                display: block;
                margin: 0 60px;
            }

            .attract_tools.show .tool_content {
                height: auto;
                overflow: hidden;
            }

            .attract_tools.show .tools_wrap {
                opacity: 1;
                transform: translateY(0);
            }

            .attract_tools .tool_content {
                height: 0;
            }

            .attract_tools .tools_wrap {
                opacity: 0;
                font-size: 0;
                height: 200px;
                background-color: #fff;
                border-bottom: 1px solid #eee;
                overflow-y: auto;
                -webkit-overflow-scrolling: touch;
                text-align: left;
                transform: translateY(50%);
                transition: .3s;
            }

        .tools_wrap .tool_item {
            display: inline-block;
            width: 25%;
            margin-top: 10px;
            font-size: 14px;
            text-align: center;
            margin-bottom: 10px;
            color: #666;
        }

        .tool_item img {
            width: 60%;
        }

        /*weixincard list style*/
        #weixincard, #goodlink {
            z-index: 901;
            background-color: #f8f8f8;
            padding: 10px;
        }

        .card_item {
            display: -webkit-box;
            display: -webkit-flex;
            display: flex;
            -webkit-box-align: center;
            -webkit-align-items: center;
            align-items: center;
            color: #fff;
            margin-bottom: 10px;
        }

            .card_item .top {
                background-color: #63b359;
                width: 100%;
                padding: 10px;
                border-radius: 4px;
            }

            .card_item .card_name {
                font-size: 24px;
                font-weight: bold;
                line-height: 47px;
            }

            .card_item .card_time {
                margin-top: 10px;
            }

        #goodlink .top_bar {
            position: relative;
        }

        .goodslink_search {
            -webkit-appearance: none;
            width: 100%;
            height: 36px;
            line-height: 36px;
            border: none;
            background-color: #fff;
            box-shadow: 0 0 1px #ccc;
            font-size: 15px;
            line-height: 1;
            padding: 0 10px;
        }

        .goodslink_search_btn {
            text-align: center;
            border-left: 1px solid #ddd;
            color: #888;
            padding: 6px 10px;
            width: 60px;
            height: 36px;
            line-height: 24px;
            position: absolute;
            top: 0;
            right: 0;
        }

        .good_wrap .good_item {
            background-color: #fff;
            border: 1px solid #ebebeb;
            margin-top: 10px;
            position: relative;
            line-height: 1;
            min-height: 100px;
            padding: 10px;
            border-radius: 4px;
        }

        .good_item .good_img {
            position: absolute;
            top: 10px;
            left: 10px;
            bottom: 10px;
            width: 80px;
            background-position: center center;
            background-repeat: no-repeat;
            background-size: cover;
        }

        .good_item .good_infos {
            padding-left: 90px;
        }

        .good_infos .good_sphh {
            font-size: 18px;
            font-weight: 200;
        }

        .good_infos .good_spmc {
            font-size: 16px;
            padding: 8px 0;
        }

        .good_infos .good_spjg {
            color: #e74c3c;
            font-weight: 200;
            font-size: 16px;
            padding-top: 10px;
        }

        #filter-page {
            background-color: #272b2e;
        }

            #filter-page .filter-wrap {
                padding: 10px;
                color: #f0f0f0;
                position: absolute;
                top: 0;
                bottom: 40px;
                width: 100%;
                overflow-y: auto;
            }

        .filter-wrap .section {
            margin-bottom: 15px;
            clear: both;
        }

        .section .title {
            font-size: 16px;
            padding-left: 5px;
            padding-bottom: 10px;
        }

        #vip_wrap {
            position: absolute;
            top: 70px;
            left: 0;
            width: 100%;
            bottom: 38px;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            -webkit-transform: translate3d(0, 0, 0);
            transform: translate3d(0, 0, 0);
        }

        .sortul li.checked {
            color: #333;
            background-color: #f2f2f2;
        }

        .filterbtn[filter] {
            display: none;
        }

        #page-main {
            z-index: 900;
        }

        .appHeader {
            height: 70px !important;
            padding-top: 20px !important;
            z-index: 1001 !important;
        }
    </style>
</head>
<body style="overflow: hidden;">
    <!--loading mask-->
    <div id="loadingmask" style="position: fixed; background-color: #f0f0f0; top: 0; height: 100%; left: 0; width: 100%; z-index: 2000;">
        <div id="loading-center-absolute">
            <div class="object" id="object_one"></div>
            <div class="object" id="object_two"></div>
            <div class="object" id="object_three"></div>
            <div class="object" id="object_four"></div>
        </div>
    </div>

    <header class="header" id="header">
        <div class="logo">
            <div class="backbtn"><i class="fa fa-chevron-left"></i></div>
            <img src="../../res/img/StoreSaler/lllogo6.png" alt="" />
        </div>
        <div class="tags" onclick="switchTags()">打标签</div>
        <div class="sorts" onclick="mysort()" style="display: block;" isshow="0"><i class="fa fa-filter"></i></div>
    </header>
    <div id="main" class="wrap-page">
        <!--主页-->
        <section class="page page-not-header-footer" id="page-main">
            <div class="viplist floatfix">
                <div class="search_tag">
                    <div class="search_tag_title">
                        <i class="fa fa-check-square"></i>
                        <p style="font-size: 12px; line-height: 1;">搜标签</p>
                    </div>
                    <input id="searchtxt" type="text" placeholder="搜索VIP名字.." />
                    <a href="javascript:SearchFunc();" class="btn_search">搜索</a>
                </div>
                <p style="text-align: center; margin-top: 4px;">
                    <span id="vipcount">
                        <span>总数: <span id="vipall">--</span>
                        </span>
                    </span>
                </p>
                <div id="vip_wrap">
                    <ul class="vipul" id="vipdiv">
                    </ul>
                    <div class="pagination_wrap">
                        <a href="javascript:getPageData('prev')">上一页</a>
                        <a href="javascript:" style="text-decoration: none;"><span id="currentPageNo">-</span>页，共<span id="allPageNo">-</span>页</a>
                        <a href="javascript:getPageData('next')">下一页</a>
                    </div>
                </div>
            </div>
            <!--全选 引流方式-->
            <div class="attract_tools">
                <div class="tool_content">
                    <div class="tools_wrap">
                        <a class="tool_item" data-tool="weixincard">
                            <img src="../../res/img/storesaler/weixincard.png" />
                            <p>微信卡券</p>
                        </a>
                        <a class="tool_item" data-tool="goodlink">
                            <img src="../../res/img/storesaler/goodlink.png" />
                            <p>推送商品</p>
                        </a>
                    </div>
                </div>
                <div class="bar_title">
                    <span class="select_all"><i class="fa fa-check-circle"></i>全选 (<span id="select_count">0</span>)</span>
                    <span class="title">引 流 <i class="fa fa-angle-double-up"></i></span>
                </div>
            </div>
        </section>

        <!--用户详情页-->
        <section class="page page-not-header page-right" id="info-page" style="z-index: 901;">
        </section>
        <!--消费单据详情页-->
        <section class="page page-not-header page-right" id="consumedetail" style="z-index: 903; padding: 0 8px;">
            <div style="margin-top: 10px; font-size: 1.1em; padding: 0 5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                <strong>单据号:</strong>
                <span id="cd_djh"></span>&nbsp;&nbsp;<strong>时间:</strong>
                <span id="cd_djsj"></span>
            </div>
            <p style="padding: 5px 5px 0 5px; color: #d9534f; font-weight: bold; letter-spacing: 1px;">温馨提示：点击货号可以查看对应的图片！</p>
            <div class="usernav floatfix" style="position: relative; padding: 0 8px;">
                <div class="cdetail theader floatfix" id="ctheader">
                    <div class="citem sphh">商品货号</div>
                    <div class="citem cm">尺码</div>
                    <div class="citem sl">数量</div>
                    <div class="citem dj">单价</div>
                </div>
                <div id="cdetaillist" style="padding-top: 37px;">
                </div>
            </div>
        </section>
        <!--打标签-->
        <section class="page page-not-header page-top" id="tags-page" style="z-index: 902;">
            <div class="topnav">
                <div id="subtags">提 交</div>
            </div>
        </section>

        <!--标签页 用于搜索-->
        <section class="page page-not-header page-top" id="searchTagPage" style="z-index: 902;">
            <div class="topnav">
                <div id="btn_searchTag">搜 索</div>
            </div>
        </section>

        <!--排序列表-->
        <section class="page page-not-header mysort page-top" isshow="0" id="filter-page">
            <div class="filter-wrap">
                <div class="section floatfix">
                    <p class="title">归属</p>
                    <ul class="sortul" data-type="VIPcard">
                        <li data-dm="false">未关联线下卡</li>
                    </ul>
                </div>
                <div class="section floatfix">
                    <p class="title">消 费</p>
                    <ul class="sortul" data-type="consume">
                        <li data-dm="m3">最近有消费</li>
                        <li data-dm="1">一个月无消费</li>
                        <li data-dm="3">三个月无消费</li>
                        <li data-dm="6">六个月无消费</li>
                    </ul>
                </div>
                <div class="section floatfix">
                    <p class="title">生 日</p>
                    <ul class="sortul" data-type="birthday">
                        <li data-dm="7">7天内生日</li>
                        <li data-dm="0">当天生日</li>
                    </ul>
                </div>
                <div class="section floatfix">
                    <p class="title">品 类</p>
                    <ul class="sortul" data-type="goodClass"></ul>
                </div>
            </div>
            <div id="filter-btn" class="floatfix">
                <a href="javascript:mysort();">取 消</a>
                <a href="javascript:SearchFunc();">筛 选</a>
            </div>
        </section>
        <!--粉丝引导页面-->
        <section class="page page-not-header-footer page-right" id="NewGuide" bid="">
        </section>
        <!--老用户VIP绑定页面-->
        <section class="page page-not-header-footer page-right" id="bindWX"></section>
        <!--新用户注册VIP页面-->
        <section class="page page-not-header-footer page-right" id="registerVIP"></section>

        <!--引流卡券列表页-->
        <section class="page page-not-header-footer page-right" id="weixincard">
            <div class="card_wrap">
                <!--<a class="card_item">
                    <div class="top">
                        <div><i class="fa fa-weixin"></i>利郎男装</div>
                        <div class="card_name">利郎9折优惠券</div>
                        <div class="card_desc">卡券说明</div>
                        <div class="card_time">有效期：<span class="starttime">2017-12-12</span> 至 <span>2017-12-12</span></div>
                        <div class="card_stock">当前库存：<span>50</span></div>
                    </div>
                    <div class="bot"></div>
                </a>-->
            </div>
            <p style="color: #aaa; font-size: 12px; line-height: 1.6; text-align: center;">点击任一一张卡券即可开始发送</p>
            <p class="noresult center-translate" style="color: #cecece; min-width: 80%; text-align: center; display: none;">对不起，您所属门店暂时无可用卡券..</p>
        </section>

        <!--发送商品链接页面-->
        <section class="page page-not-header-footer page-right" id="goodlink">
            <div class="top_bar">
                <input type="text" placeholder="请输入具体货号.." class="goodslink_search" />
                <a href="javascript:SearchGoods()" class="goodslink_search_btn">搜索</a>
            </div>
            <div class="good_wrap">
                <!--<div class="good_item">
                    <div class="good_img" style="background-image: url(http://webt.lilang.com:9001/MyUpload/201606QJ/6QZC0076Y/6QZC0076Y-01.jpg);"></div>
                    <div class="good_infos">
                        <p class="good_sphh">5DNK0011Y</p>
                        <p class="good_spmc">商品名称商品名称</p>
                        <p class="good_spjg"><strong>零售价：</strong>2099</p>
                    </div>
                </div>-->
            </div>
            <p class="noresult center-translate" style="color: #cecece; display: none;">对不起，啥都没找到..</p>
        </section>
        <div class="filterbtn" id="to-top"><i class="fa fa-chevron-up"></i></div>
        <div class="filterbtn" filter="own" onclick=""><i class="fa fa-user"></i></div>
        <div class="filterbtn" filter="all" onclick=""><i class="fa fa-university"></i></div>
        <div id="mask2"></div>
    </div>
    <footer class="footer">
        <div class="bottomnav">
            <ul class="navul floatfix">
                <li onclick="switchMenu(0)">
                    <i class="fa fa-comments"></i>
                    <p>消 息</p>
                </li>
                <li onclick="switchMenu(1)" id="selected">
                    <i class="fa fa-users"></i>
                    <p>客 户</p>
                </li>
                <li onclick="javascript:window.location.href='AttractTools.html';">
                    <i class="fa fa-retweet"></i>
                    <p>引 流</p>
                </li>
                <li onclick="switchMenu(3)">
                    <i class="fa fa-user"></i>
                    <p>我 的</p>
                </li>
            </ul>
        </div>
    </footer>
    <!--加载提示层-->
    <section class="mask">
        <div class="loader center-translate">
            <div style="font-size: 1.2em;">
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext">正在加载...</p>
        </div>
    </section>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type='text/javascript' src='../../res/js/template.js'></script>
    <script type='text/javascript' src='../../res/js/require.js'></script>
    <script type='text/javascript' src='http://tm.lilanz.com/oa/api/lilanzAppWVJBridge-0.1.5.min.js'></script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var LoadingCheck, CheckTimes = 0;
        var mdid = "<%=mdid%>", AppSystemKey = "<%=AppSystemKey%>", RoleID = "<%=RoleID%>", khid = "<%=khid%>";
        var selectedUsers = 0;
        var customerID = "<%=customerid%>";

        LoadingCheck = setInterval(function () {
            if (CheckTimes >= 6) {
                alert("您的网络好像出了点问题，请重新打开此页面！");
                CheckTimes = 0;
                return;
            } else {
                if (document.getElementById("loadingmask").style.display == "block") {
                    CheckTimes++;
                }
            }
        }, 1000);

        /* 已加载文件缓存列表,用于判断文件是否已加载过，若已加载则不再次加载*/
        var classcodes = [];
        window.Import = {
            /*加载一批文件，_files:文件路径数组,可包括js,css,less文件,succes:加载成功回调函数*/
            LoadFileList: function (_files, succes) {
                var FileArray = [];
                if (typeof _files === "object") {
                    FileArray = _files;
                } else {
                    /*如果文件列表是字符串，则用,切分成数组*/
                    if (typeof _files === "string") {
                        FileArray = _files.split(",");
                    }
                }
                if (FileArray != null && FileArray.length > 0) {
                    var LoadedCount = 0;
                    for (var i = 0; i < FileArray.length; i++) {
                        loadFile(FileArray[i], function () {
                            LoadedCount++;
                            if (LoadedCount == FileArray.length) {
                                succes();
                            }
                        })
                    }
                }
                /*加载JS文件,url:文件路径,success:加载成功回调函数*/
                function loadFile(url, success) {
                    var urlArgs = "2_5";
                    if (!FileIsExt(classcodes, url)) {
                        var ThisType = GetFileType(url);
                        var fileObj = null;
                        if (ThisType == ".js") {
                            fileObj = document.createElement('script');
                            fileObj.src = url;
                        } else if (ThisType == ".css") {
                            fileObj = document.createElement('link');
                            fileObj.href = url + "?ver=" + urlArgs;
                            fileObj.type = "text/css";
                            fileObj.rel = "stylesheet";
                        } else if (ThisType == ".less") {
                            fileObj = document.createElement('link');
                            fileObj.href = url;
                            fileObj.type = "text/css";
                            fileObj.rel = "stylesheet/less";
                        }
                        success = success || function () { };
                        fileObj.onload = fileObj.onreadystatechange = function () {
                            if (!this.readyState || 'loaded' === this.readyState || 'complete' === this.readyState) {
                                success();
                                classcodes.push(url)
                            }
                        }
                        document.getElementsByTagName('head')[0].appendChild(fileObj);
                    } else {
                        success();
                    }
                }
                /*获取文件类型,后缀名，小写*/
                function GetFileType(url) {
                    if (url != null && url.length > 0) {
                        return url.substr(url.lastIndexOf(".")).toLowerCase();
                    }
                    return "";
                }
                /*文件是否已加载*/
                function FileIsExt(FileArray, _url) {
                    if (FileArray != null && FileArray.length > 0) {
                        var len = FileArray.length;
                        for (var i = 0; i < len; i++) {
                            if (FileArray[i] == _url) {
                                return true;
                            }
                        }
                    }
                    return false;
                }
            }
        }

        var FilesArray = ["../../res/css/font-awesome.min.css", "../../res/css/LeePageSlider.css", "../../res/css/StoreSaler/VIPMainStyle_v2.css"];

        Import.LoadFileList(FilesArray, function () {
            /*这里写加载完成后需要执行的代码或方法*/
            require.config({
                urlArgs: "ver=2_6_" + parseInt(Math.random() * 100),
                paths: {
                    "jquery": ["../../res/js/jquery-3.2.1.min"],
                    "fastclick": ["../../res/js/StoreSaler/fastclick.min"],
                    "chartjs": ["../../res/js/Chart.min"],
                    "underscore": ["../../res/js/underscore-min"],
                    "lazyload": ["../../res/js/jquery.lazyload.min"],
                    "vipmain": ["../../res/js/StoreSaler/vipmain_v2.min"]
                },
                shim: {
                    'jquery': {
                        exports: '$'
                    },
                    'underscore': {
                        exports: '_'
                    },
                    'fastclick': {
                        exports: 'FastClick'
                    },
                    'lazyload': {
                        deps: ['jquery']
                    },
                    'vipmain': {
                        deps: ['jquery', 'chartjs', 'underscore', 'lazyload'],
                        exports: 'vipmain'
                    }
                }
            });

            require(["../../res/js/plugins/text.js!VipTemplate_v2.html", "fastclick", "vipmain"], function (content, FastClick) {
                setTimeout(function () {
                    $("#loadingmask").hide();
                    if (LoadingCheck != null) {
                        clearInterval(LoadingCheck);
                        CheckTimes = null;
                    }
                }, 800);

                $($("script")[0]).before(content);
                FastClick.attach(document.body);
                jsConfig();

                $(".attract_tools").click(function() {
                    $(".attract_tools").removeClass("show");
                });

                $(".attract_tools").on("click", ".tool_content", function (e) {
                    e.stopPropagation();
                });

                $(".attract_tools").on("click", ".title", function (e) {
                    e.stopPropagation();
                    if ($(".attract_tools").hasClass("show")) {
                        $(".attract_tools").removeClass("show");
                    } else {
                        $(".attract_tools").addClass("show");
                    }
                })

                //全选
                //$(".attract_tools").on("click", ".fa-check-circle", function () {
                //    if (confirm("每次最多批量发送100个用户，确定继续？")) {
                //        $("#vipdiv .checkbox.checked").removeClass("checked");
                //        $("#select_count").text("0");

                //        var items = $("#vipdiv li");
                //        var len = items.length >= 100 ? 100 : items.length;
                //        for (var i = 0; i < len; i++) {
                //            items.eq(i).find(".checkbox").addClass("checked");
                //        }
                //        $("#select_count").text(len);
                //    }
                //})

                $(".attract_tools").on("click", ".tool_item", function () {
                    var selectedNos = $("#vipdiv .checked").length;
                    if (selectedNos <= 0) {
                        showLoader("warn", "请先从列表中选择需要发送的对象！");
                        return;
                    }
                    var tool = $(this).attr("data-tool");
                    if (tool == "weixincard")
                        loadWXCards();
                    else if (tool == "goodlink") {
                        $("#goodlink .good_wrap").empty();
                        $("#goodlink .noresult").hide();
                        $(".goodslink_search").val("");
                    }
                    $("#" + tool).removeClass("page-right");
                    CurrentSite = tool;
                })

                $("#vipdiv").on("click", "li .checkbox", function (e) {
                    if ($(this).hasClass("checked")) {
                        $(this).removeClass("checked");
                        $("#select_count").text(--selectedUsers);
                    }
                    else {
                        var bid = $(this).parent().attr("bid");
                        if (selectedUsers >= 100) {
                            showLoader("warn", "对不起，一次最多只能发送100个用户！！");
                            return;
                        } else if (bid == "" || bid == "0" || bid === undefined) {
                            alert("对不起，该用户还未绑定微信，无法发送通知！");
                            return;
                        }
                        $(this).addClass("checked");
                        $("#select_count").text(++selectedUsers);
                    }

                    e.stopPropagation();
                })

                //筛选条件
                $("#filter-page .sortul").on("click", "li", function () {
                    if ($(this).hasClass("checked")) {
                        $(this).removeClass("checked");
                    } else {
                        $(this).parent().find("li.checked").removeClass("checked");
                        $(this).addClass("checked");
                    }
                });

                //APP环境初始化
                initInApp();
            });
        });

        function initInApp() {
            llApp.init().then(function (res) {
                $(".footer").hide();
                $(".wrap-page .page-not-header-footer").removeClass("page-not-header-footer").addClass("page-not-header");
                llApp.hideNavBar();
                llApp.setStatusBar("#161A1C", "white");
                $(".header").addClass("appHeader");
                $(".tags, .sorts").css("margin-top", "-5px");
                $(".backbtn").css("top", "initial");
                $(".backbtn").css("border", "none");
                $(".page-not-header").css("top", "70px");
            });
        }

        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['previewImage'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {

            });
            wx.error(function (res) {
                alert("JS注入失败！");
            });
        }

        var imgURLs = new Array();
        //微信的预览图片接口
        function previewImage(sphh) {
            showLoader("loading", "正在加载图片,请稍候...");
            $.ajax({
                url: "VIPListCore.aspx?ctrl=GetClothesPics",
                type: "POST",
                dataType: "text",
                data: { sphh: sphh },
                timeout: 5000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "您的网络好像出了点问题,请稍后重试...");
                },
                success: function (result) {
                    if (result == "") {
                        showLoader("warn", "对不起,这个货号暂时还没上传图片!");
                    } else if (result.indexOf("Error:") > -1) {
                        showLoader("error", result);
                    } else {
                        var imgs = result.split('|');
                        imgURLs = [];//每次都先清空数组
                        for (var i = 0; i < imgs.length - 1; i++) {
                            imgURLs.push("http://webt.lilang.com:9001" + imgs[i].replace("..", ""));
                        }//end for
                        if (llApp && llApp.isInApp) {
                            llApp.previewImage({
                                current: imgURLs[0],
                                urls: imgURLs
                            })
                        } else {
                            wx.previewImage({
                                current: imgURLs[0], // 当前显示图片的http链接
                                urls: imgURLs // 需要预览的图片http链接列表
                            });
                        }
                        $(".mask").hide();
                    }
                }
            });
        }
    </script>
</body>
</html>
