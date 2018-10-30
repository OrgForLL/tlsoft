<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public string mdid = "";
    public string AppSystemKey = "",RoleID="";
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
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            else
            {
                mdid = Session["mdid"].ToString();
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
        }

        #object_two {
            -webkit-animation: object_two 1s infinite;
            animation: object_two 1s infinite;
        }

        #object_three {
            -webkit-animation: object_three 1s infinite;
            animation: object_three 1s infinite;
        }

        #object_four {
            -webkit-animation: object_four 1s infinite;
            animation: object_four 1s infinite;
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
                <div class="search">
                    <input id="searchtxt" type="text" placeholder="请输入昵称关键字" oninput="searchFunc()" />
                </div>
                <p style="text-align: center; margin-top: 4px;">
                    <span id="vipcount">
                        <span>总数: <span id="vipall">--</span>
                        </span>
                        <span>当前数: <span id="vipcurr">--</span>
                        </span>
                    </span>
                </p>
                <ul class="vipul" id="vipdiv">
                </ul>
            </div>
            <div class="lmdiv">
                <a href="javascript:;" id="loadmore_btn">- 加载更多 -</a>
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
            <p style="padding: 5px 5px 0 5px;color: #d9534f;font-weight: bold;letter-spacing: 1px;">温馨提示：点击货号可以查看对应的图片！</p>
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
        <!--排序列表-->
        <section class="mysort page-top" isshow="0">
            <ul class="sortul floatfix">
                <li class="sort-item" onclick="FilterData('jf',0)">按积分</li>
                <li class="sort-item" onclick="FilterData('ml',0)">按魅力值</li>
                <li class="sort-item" onclick="FilterData('je',0)">按消费总金额</li>
                <li class="sort-item" onclick="FilterData('sj',0)">最近购买时间</li>
                <li class="filter-item" onclick="FilterData('lessm1',0)">一个月内有消费</li>
                <li class="filter-item" onclick="FilterData('lessm3',0)">三个月内有消费</li>
                <li class="filter-item" onclick="FilterData('lessy1',0)">一年内有消费</li>
                <li class="filter-item" onclick="FilterData('morey1',0)">超过一年无消费</li>
            </ul>
            <div id="filter-btn">
                <a class="fchecked" onclick="switchSF('sort',this)">排 序</a>
                <a onclick="switchSF('filter',this)">筛 选</a>
            </div>
        </section>
        <!--粉丝引导页面-->
        <section class="page page-not-header-footer page-right" id="NewGuide" bid="">
        </section>
        <!--老用户VIP绑定页面-->
        <section class="page page-not-header-footer page-right" id="bindWX">
        </section>
        <!--新用户注册VIP页面-->
        <section class="page page-not-header-footer page-right" id="registerVIP">
        </section>
        <div class="filterbtn" id="to-top"><i class="fa fa-chevron-up"></i></div>
        <div class="filterbtn" filter="own" onclick="FilterData('dzfilter', 1)"><i class="fa fa-user"></i></div>
        <div class="filterbtn" filter="all" onclick="FilterData('dzfilter', 2)"><i class="fa fa-university"></i></div>
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
                <li onclick="switchMenu(2)">
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
    <script type='text/javascript' src='../../res/js/require.js'></script>   
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var LoadingCheck, CheckTimes = 0;
        var mdid = "<%=mdid%>", AppSystemKey = "<%=AppSystemKey%>", RoleID = "<%=RoleID%>";

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
                    if (!FileIsExt(classcodes, url)) {
                        var ThisType = GetFileType(url);
                        var fileObj = null;
                        if (ThisType == ".js") {
                            fileObj = document.createElement('script');
                            fileObj.src = url;
                        } else if (ThisType == ".css") {
                            fileObj = document.createElement('link');
                            fileObj.href = url;
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

        var FilesArray = [ "../../res/css/font-awesome.min.css", "../../res/css/LeePageSlider.css", "../../res/css/StoreSaler/VIPMainStyle.css"];

        Import.LoadFileList(FilesArray, function () {
            /*这里写加载完成后需要执行的代码或方法*/
            require.config({
                paths: {
                    "jquery": ["../../res/js/jquery"],
                    "fastclick": ["../../res/js/StoreSaler/fastclick.min"],
                    "chartjs": ["../../res/js/Chart.min"],
                    "underscore": ["../../res/js/underscore-min"],
                    "vipmain": ["../../res/js/StoreSalerV2/vipmain"]
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
                    'vipmain': {
                        deps: ['jquery', 'chartjs', 'underscore'],
                        exports: 'vipmain'
                    }
                }
            });

            require(["../../res/js/plugins/text.js!VipTemplate.html", "fastclick", "vipmain"], function (content, FastClick) {
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
            });
        });

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
                url: "../../WebBLL/VIPListCore.aspx?ctrl=GetClothesPics",
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
                        wx.previewImage({
                            current: imgURLs[0], // 当前显示图片的http链接
                            urls: imgURLs // 需要预览的图片http链接列表
                        });
                        $(".mask").hide();
                    }
                }
            });
        }
    </script>
</body>
</html>
