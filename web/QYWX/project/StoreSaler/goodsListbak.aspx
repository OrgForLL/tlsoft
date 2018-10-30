﻿<%@ Page Title="" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    string mdid, mdmc, showType;
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    private const string ConfigKeyValue = "1";
    protected void Page_PreRender(object sender, EventArgs e)
    {
        // Response.Write(string.Format("qy_customersid ={0} , SystemKey={1} , tzid={2} , mdid={3}",
        //Session["qy_customersid"], this.Master.AppSystemKey, Session["tzid"], Session["mdid"]));
        // showType = Convert.ToString(Session["showType"]);
        showType = Convert.ToString(Request.Params["showType"]);
        if (showType == string.Empty)
        {
            showType = "0";
        }
        //showType="1";
        //mdid="1906";

        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        switch (showType)
        {
            case "1": 
                clsWXHelper.CheckQQDMenuAuth(8);    //检查菜单权限
                    
                mdid = Convert.ToString(Session["mdid"]);
                using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
                {
                    DataTable dt = null;
                    string strsql = @" select top 1 mdmc from t_mdb a where a.mdid=@mdid";
                    List<SqlParameter> param = new List<SqlParameter>();
                    param.Add(new SqlParameter("@mdid", mdid));
                    string errinfo = MDal.ExecuteQuerySecurity(strsql, param, out dt);
                    if (errinfo == "" && errinfo.Length == 0)
                    {
                        if (dt.Rows.Count > 0)
                        {
                            mdmc = Convert.ToString(dt.Rows[0][0]);
                        }
                        else
                        {
                            clsWXHelper.ShowError("无权限或获取权限异常(Store),请重试！");
                        }
                    }
                    else
                    {
                        clsWXHelper.ShowError("获取门店信息数据时出错 info:" + errinfo);
                    }
                    dt.Rows.Clear(); dt.Dispose();  //释放资源
                };
                break;
            case "2":
                mdid = "0";
                mdmc = "商品信息";
                break;
            default:
                clsWXHelper.ShowError("无权限或获取权限异常(Other),请重试！");
                break;
        };

        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);

    }

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        //this.Master.SystemID = "3";     //可设置SystemID,默认为3（全渠道系统）
        //this.Master.AppRootUrl = "../../../";     //可手动设置WEB程序的根目录,默认为 当前页面的向上两级
        //showType = Convert.ToString(Session["showType"]);
        showType = Convert.ToString(Request.Params["showType"]);
        if (showType == string.Empty)
        {
            showType = "0";
        }
        //showType="2";
        if (showType == "2") //  区分鉴权(1.门店人员 | 2.顾客)
        {
            this.Master.IsTestMode = true;
        }
        else
        {
            this.Master.IsTestMode = false;
        }
        //this.Master.IsTestMode = true;
        //统一的后台错误输出方法
        //clsWXHelper.ShowError("错误提示内容121113456，自定义内容");
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta name="format-detection" content="telephone=no" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/vipweixin/touchSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />

    <link rel="stylesheet" href="../../res/css/StoreSaler/layout.css" type="text/css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/base.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/layer.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/StoreSaler/shop.css" />
    <style type="text/css">
        body {
            background-color: #f7f7f7;
            color: #2f2f2f;
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
        }

        .header {
            height: 50px;
            line-height: 50px;
            width: 100%;
            text-align: center;
            font-size: 1.2em;
            letter-spacing: 2px;
            background-color: #000;
            color: #fff;
            border-bottom: 1px solid #e5e5e5;
        }

        .fa-angle-left {
            font-size: 1.4em;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            padding: 0 18px;
            line-height: 50px;
            color: #fff;
        }

            .fa-angle-left:hover {
                background-color: rgba(0,0,0,.1);
            }

        .page {
            top: 50px;
            bottom: 32px;
            padding: 0;
            background-color: #f7f7f7;
        }

        .banner {
            height: 220px;
            margin-top: -1px;
            background-color: #fafafa;
        }

        .foot-btns {
            background-color: #eceef1;
            height: 48px;
            line-height: 48px;
            font-size: 0;
        }

            .foot-btns > a {
                display: inline-block;
                text-align: center;
                width: 40%;
                color: #575d6a;
                font-size: 16px;
            }

            .foot-btns .color-btn {
                background-color: #575d6a;
                color: #fff;
                width: 60%;
            }

        .product-info, .product-stock, .product-detail1, .product-detail2, .product-cminfo {
            background-color: #fff;
            margin: 5px 0;
            padding: 0 5px;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            position: relative;
        }
        .product-info {
            padding:0 10px;
        }
            .product-info .fa-star, .product-info .fa-star-o {
                position: absolute;
                top: 0;
                right: 0;
                font-size: 22px;
                line-height: 44px;
                padding: 0 15px;
                margin-top: 8px;
                border-left: 1px solid #f2f2f2;
            }

            .product-info .pro-name {
                font-size: 1.1em;
                font-weight: bold;
                color: #555;
                /*line-height: 30px;*/
                padding-top:5px;
                color:#2b363a;
            }
        .product-info .llzp,.product-info .zdzt {
            background-color: #000;
            color: #fff;
            padding: 4px 8px;
            font-size: 12px;            
            line-height: 28px;
            margin-right:5px;
        }
            .product-info .zdzt {
                background-color:#e54801;
            }
        .points {
            color: #888;
            font-size: 1.2em;
            font-weight: bold;
            margin-top: 5px;
        }

            .points span {
                color: #ff6600;
                font-size: 1.5em;
                font-weight: bold;
            }
        .money {
            color:#ff5000;
        }
        .money span {            
            font-size: 1.2em;            
        }

        .product-stock li {
            list-style-type: none;
            margin: 0 1.6666% 8px;
            box-sizing: border-box;
            color: #000;
            text-align: center;
            width: 30%;
            height: 28px;
            line-height: 28px;
            overflow: hidden;
            word-break: break-all;
            white-space: nowrap;
            text-overflow: ellipsis;
            border-radius: 3px;
            display: inline-block;
        }

            .product-stock li.none {
                color: #c5c9cd;
                border: 1px solid #d8dcdf;
                background-color: #f0f1f3;
            }

            .product-stock li.choose {
                border: 1px solid #000;
                background: #fff;
                cursor: pointer;
            }

        .product-stock .title, .product-cminfo .title {
            font-size: 16px;
            letter-spacing: 1px;
            /*border-bottom: 1px solid #f7f7f7;*/
            margin-bottom: 8px;
            border-left: 4px solid #333;
            padding: 8px 0 8px 8px;
            font-weight: 600;
        }

        .product-stock {
            font-size: 1.1em;
        }

            .product-stock > p {
                line-height: 20px;
            }

        .product-detail1 {
            font-size: 1.1em;
        }

            .product-detail1 > p {
                line-height: 20px;
            }

            .product-detail1 .title {
                font-size: 16px;
                letter-spacing: 1px;
                /*border-bottom: 1px dashed #f2f2f2;*/
                border-left: 4px solid #333;
                padding: 8px 0 8px 8px;
                font-weight: 600;
            }

        .product-detail2 {
            padding-top: 8px;
        }

            .product-detail2 > img {
                width: 100%;
                height: auto;
                margin-top: 10px;
            }

            .product-detail2 .title {
                font-size: 16px;
                letter-spacing: 1px;
                /*border-bottom: 1px solid #f7f7f7;*/
                margin: -8px 0 0 0;
                border-left: 4px solid #333;
                padding: 8px 0 8px 8px;
                font-weight: 600;
            }

            .product-detail2 p {
                line-height: 20px;
            }
        /*幻灯区样式*/
        .main_image, .main_image ul, .main_image li, .main_image li span, .main_image li a {
            height: 220px;
        }

        div.flicking_con .flicking_inner {
            top: 200px;
        }

        .product-stock .u-detail-sl {
            color: #d9534f;
            line-height: 28px;
        }

        .flicking_inner a {
            border: #c9c9c9 0px solid;
        }

        .product-stock ul {
            padding: 0px;
        }

        .footer {
            text-align: center;
            height: 30px;
            line-height: 30px;
            font-size: 12px;
            background-color: transparent;
            color: #999;
        }

        .u-pro-list-top {
            margin-top: 40px;
        }

        p, .p {
            margin-bottom: 0;
        }

        .product-detail2 .img-tips {
            text-align: center;
            font-size: 12px;
            color: #333;
            font-weight: 600;
        }

        .money span {
            line-height: 24px;
        }

        td {
            padding: 2px 0;
        }

        .header .icon-camera {
            font-size: 1.2em;
        }

        .top-fixed .top-search input {
            line-height: 30px;
        }

        .top-fixed .top-title {
            white-space: nowrap;
            max-width: 210px;
            text-overflow: ellipsis;
        }
        /*cminfos style*/
        .product-cminfo .cm-content {
            width: 100%;
            height: 220px;
            overflow: auto;
            -webkit-overflow-scrolling: touch;
        }

        .cm-table {
            border-collapse: collapse;
            border: none;
            margin: 0 auto;
            color: #333;
        }

            .cm-table th {
                font-size: 14px;
                background-color: #535353;
                color: #fff;
                white-space: nowrap;
            }

            .cm-table td, .cm-table th {
                border: solid #e1e1e1 1px;
                min-width: 60px;
                text-align: center;
                padding: 6px 10px;
            }

        .cm-tips {
            padding: 5px 0;
        }

            .cm-tips p {                
                color: #666;
                font-size: 14px;
                font-weight: 600;
                line-height: 1.4;
            }
        .header {
            border-bottom:none;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="html_container">
        <div id="htmlList">

            <script type="text/html" id="page1">
                <div class="top-fixed bg-yellow bg-inverse">
                    <div class="top-back">
                        <a class="top-addr" href="javascript:Scan()"><i class="icon-camera"></i></a>
                    </div>
                    <div class="top-title">
                        <%=mdmc %>
                    </div>
                    <div class="top-search" style="display: none;">
                        <input id="keyword" name="keyword" placeholder="输入商品货号" />
                        <button type="button" class="icon-search" onclick="searchFunc()"></button>
                    </div>
                    <div class="top-signed">
                        <a id="search-btn" href="javascript:void(0);"><i class="icon-search"></i></a>
                    </div>
                </div>

                <div id="search-bar" class="search-bar">
                    <ul class="line">
                        <li class="x3"><span>库存</span><i></i></li>
                        <li class="x3"><span>类别</span><i></i></li>
                        <li class="x3"><span>主推</span><i></i></li>
                        <li class="x3"><span>排序</span><i></i></li>
                    </ul>
                </div>

                <div class="serch-bar-mask" style="display: none;">
                    <div class="serch-bar-mask-list">
                        <ul>
                            <li class="on"><a href="javascript:goodsfilter('kczt','')">全部</a></li>
                            <li><a title="有货" href="javascript:goodsfilter('kczt','1')">有货商品</a></li>
                            <li><a title="缺货" href="javascript:goodsfilter('kczt','0')">缺货商品</a></li>
                        </ul>
                    </div>
                    <div class="serch-bar-mask-list">
                        <ul>
                            <li class="on"><a href="javascript:goodsfilter('splb','')">全部</a></li>
                            <li><a title="西服" href="javascript:goodsfilter('splb','西服')">西服</a></li>
                            <li><a title="茄克" href="javascript:goodsfilter('splb','茄克')">茄克</a></li>
                            <li><a title="风衣" href="javascript:goodsfilter('splb','风衣')">风衣</a></li>
                            <li><a title="裤子" href="javascript:goodsfilter('splb','裤子')">裤子</a></li>
                        </ul>
                    </div>
                    <div class="serch-bar-mask-list">
                        <ul>
                            <li class="on"><a href="javascript:goodsfilter('yxzt','')">全部</a></li>
                            <li><a title="主推" href="javascript:goodsfilter('yxzt',1)">主推商品</a></li>
                        </ul>
                    </div>
                    <div class="serch-bar-mask-list">
                        <ul>
                            <li><a href="#">新货排序</a></li>
                        </ul>
                    </div>
                    <div class="serch-bar-mask-bg"></div>
                </div>
                <div id="main" class="u-pro-list clearfix u-pro-list-top">
                </div>

                <div class="u-more-btn"><a href="javascript:goodsList();" id="u-more-btn">- 加载更多 -</a></div>
            </script>
        </div>
        <div id="htmlDetail">
        </div>

        <script type="text/html" id="page2">
            <div class="header">
                <i class="fa fa-angle-left" onclick="javascript:childDetail();"></i>
                <i class="fa-angle-left icon-camera" onclick="javascript:Scan()"></i>
                商品详情
            </div>
            <div id="goodsDetail" class="wrap-page none">
                <div class="page page-not-header-footer">
                    <!--幻灯片区-->
                    <div class="banner">
                        <div class="main_visual">
                            <div class="flicking_con">
                                <div class="flicking_inner">
                                    <!--样衣图序号-->
                                </div>
                            </div>
                            <div class="main_image">
                                <!--样衣图-->
                            </div>
                        </div>
                    </div>
                    <div class="product-info" style="margin-top: 0; padding-bottom: 5px;">
                        <!-- 商品一般信息高亮 -->
                        <i class="fa fa-star"></i>
                    </div>
                    <div class="product-stock">
                        <!-- 商品库存信息 -->
                    </div>
                    <div class="product-detail1">
                        <!-- 商品信息(卖点成份) -->
                    </div>
                    <!-- 货号尺码信息 20160613 by liqf -->
                    <div class="product-cminfo">
                        <p class="title">尺码信息：单位CM</p>
                        <div class="cm-content">
                            <table class="cm-table">
                            </table>
                        </div>
                        <div class="cm-tips">
                            <p>1、尺码信息过多时，请滑动表格查看；</p>
                            <p>2、尺码表数据仅供参考，由于人工测量，可能会存在1-2cm左右偏差；</p>
                        </div>
                    </div>
                    <div class="product-detail2">
                        <!--<p class="title">商品详情</p>-->
                    </div>
                </div>
            </div>
            <div class="footer">
                &copy;2016 利郎(中国)有限公司						
            </div>
        </script>
    </div>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/jquery.event.drag-1.5.min.js"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/jquery.touchSlider.js"></script>
    <script type="text/javascript">
        if("<%=showType%>"=="2"){
            //对外顾客
            $('#htmlDetail').html($("#page2").html());
            $(".fa.fa-angle-left").hide();
            $("#goodsDetail").hide();                      
        }else{
            //内部使用可以看到库存
            $('#htmlList').html($("#page1").html());
            $("#main").css(top,"100px");
            (function(){ setTimeout(function () { goodsList(); }, 200); })();
        }

    </script>

    <script>
        $(function () {
		
            $("#serch-bar-mask-bg").click(function () {
                $(".serch-bar-mask").hide();
            });
            $("#search-btn").click(function () {
                if ($(".top-search").css("display") == 'block') {
                    $(".top-search").hide();
                    $(".top-title").show(200);
                    $("#main dl").show();
                }
                else {
                    $(".top-search").show();
                    $(".top-title").hide(200);
                }
            });		

            $("#search-bar li").each(function (e) {
                $(this).click(function () {
                    if ($(this).hasClass("on")) {
                        $(this).parent().find("li").removeClass("on");
                        $(this).removeClass("on");
                        $(".serch-bar-mask").hide();
                    }
                    else {
                        $(this).parent().find("li").removeClass("on");
                        $(this).addClass("on");
                        $(".serch-bar-mask").show();
                    }
                    $(".serch-bar-mask .serch-bar-mask-list").each(function (i) {
                        if (e == i) {
                            $(this).parent().find(".serch-bar-mask-list").hide();
                            $(this).show();
                        }
                        else {
                            $(this).hide();
                        }
                        $(this).find("li").click(function () {
                            $(this).parent().find("li").removeClass("on");
                            $(this).addClass("on");
                            (function () { setTimeout(function () { $(".serch-bar-mask").hide(); $("#search-bar").find("li").removeClass("on"); }, 200); })();
                        });
                    });
                });
            });
        });
	
    </script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var lastID = "-1",searchLastID="-1";
        var isProcessing = false; //用于控制在上一次操作完成后才能开始扫下一个二维码
        var data_mid="";//由于是单页所以当分享出去的是详情页时根据此参数来判断  当对内时存放的是列表对应的data-mid对外则存放的是对应扫描的值
        var codeType="";
		
        window.onload=function(){
            var viewType="<%=showType%>";
            var cid=getQueryString("cid");
            var ctype=getQueryString("codeType");
            if(viewType=="2"&&cid!=""&&cid!="0"&&cid!=undefined){
                goodsDetail(cid,ctype);
            }else if(viewType=="2"){ //vip进入时
                Scan();
            }else if(cid!=""&&cid!="0"&&cid!=undefined){
                goodsDetail(cid,ctype);
            }
        }

        function childDetail(){
            $("#htmlList").show();
            $("#htmlDetail").hide();
            lastID="-1";
            searchLastID="-1";//返回时将此ID重置为-1否则再次搜索商品将搜索不到
        }

        $('#keyword').bind('keypress', function(event) {
            if (event.keyCode == "13") { 
                //回车执行查询
                searchFunc();
                return false;
            }
        });
		
        (function () {
            var qrcodeid=getQueryString("qrcodeid");
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ["scanQRCode","previewImage","onMenuShareTimeline","onMenuShareAppMessage"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {                
                if(qrcodeid!=""){
                    goodsDetail(qrcodeid,"qrCode");
                }else
                    scanQRCode();
                // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。
            });
            wx.error(function (res) {
                alert("JS注入失败！");
            });              
        })();
		
        var GetQueryParams = function (name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            var r = window.location.search.substr(1).match(reg);
            if (r != null)
                return unescape(r[2])
            else
                return "";
        };

        function WXShareLink(cid){
            var title="我发现了利郎的一款好货【"+$(".pro-name").text()+"】";
            var imgurl=$(".main_image ul li:first-child span").css("background").match(new RegExp("\\((.| )+?\\)","igm"))[1];
            imgurl=imgurl.substring(1,imgurl.length-1);
            //20160607 liqf重复分享会使链接参数过长
            //var link=window.location.href+"&cid="+data_mid+"&codeType="+codeType;            
            var _link=setQueStr(window.location.href,"cid",data_mid);
            var link=setQueStr(_link,codeType,codeType);
            //分享给朋友
            wx.onMenuShareAppMessage({
                title: title, // 分享标题                
                imgUrl:imgurl,
                desc:'赶快点开一探究竟吧....',
                link: link, // 分享链接                    
                type: 'link', // 分享类型,music、video或link，不填默认为link
                dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                success: function () {
                    // 用户确认分享后执行的回调函数                        
                },
                cancel: function () {
                    // 用户取消分享后执行的回调函数
                }
            });

            //分享到朋友圈
            wx.onMenuShareTimeline({
                title:title, // 分享标题
                imgUrl:imgurl,
                link: link, // 分享链接                    
                success: function () {
                    // 用户确认分享后执行的回调函数                        
                },
                cancel: function () {
                    // 用户取消分享后执行的回调函数
                }
            });
        }

        function searchFunc() {   
            var stxt = $("[id$=keyword]").val().toUpperCase(); 
            goodsListSingle(stxt,"");
        }

        function Scan(){ 
            isProcessing=true;
            scanQRCode();             
        }
		
        //showType=1内部使用 =2外部使用
        function scanQRCode() {
            if (isProcessing == false) { return false;}
            
            wx.scanQRCode({
                needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                scanType: ["barCode","qrCode"], // 可以指定扫二维码还是一维码，默认二者都有 //, "qrCode"
                success: function (res) {
                    var result = res.resultStr; // 当needResult 为 1 时，扫码返回的结果
                    if(result.indexOf("http")>-1){ 
                        if("<%=showType%>"=="2"){
                            goodsDetail(result.split("?id=")[1],"qrCode");                            
                        }else{
                            goodsListSingle(result.split("?id=")[1],"qrCode"); //待完善
                        }
                        data_mid=result.split("?id=")[1];
                        codeType="qrCode";
                    }else{                        
                        if("<%=showType%>"=="2"){                            
                            goodsDetail(result.split(",")[1],"barCode");                            
                        }else{                                     
                            goodsListSingle(result.split(",")[1],"barCode"); //待完善
                        }
                        data_mid=result.split(",")[0];
                        codeType="barCode";
                    }
                }
            });
        }
		
        function previewImage(s) { //微信预览图片
            var arrUrls = new Array();
            var p;
            if(s["tagName"].toUpperCase()=="SPAN"){
                p=$(s).parent().parent();
                $.each($(p).find("span"), function (i, val) {
                    arrUrls[i] = $(val).attr("style");
                    arrUrls[i] = arrUrls[i].substring(arrUrls[i].indexOf("(")+1,arrUrls[i].indexOf(")"));
                });
                wx.previewImage({
                    current: $(s).attr("style").substring($(s).attr("style").indexOf("(")+1,$(s).attr("style").indexOf(")")), // 当前显示图片的http链接
                    urls: arrUrls // 需要预览的图片http链接列表
                });
            }
            else{
                p=$(s).parent();
                $.each($(p).find("img"), function (i, val) {
                    arrUrls[i] = $(val).attr("src");
                });
                wx.previewImage({
                    current: $(s).attr("src"), // 当前显示图片的http链接
                    urls: arrUrls // 需要预览的图片http链接列表
                });
            }
            arrUrls.length=0;
        }

        //列表加载主函数
        function goodsList(){ 
            ShowLoading("拼命加载中...", 15); 
            var stxt = $("[id$=keyword]").val().toUpperCase();
            $.ajax({
                url: "goodsListCore.aspx?ctrl=goodsList",
                type: "post",
                dataType: "text",
                data: { showType:"<%=showType %>", mdid: "<%=mdid%>", lastID:lastID, scanResult:stxt },
                cache: false,
                timeout: 15000,
                error: function (e) {      
                    HideLoading();
                    ShowInfo("网络异常",1);
                    //RedirectErr();
                },
                success: function (res) {  
                    if (res.indexOf("Error：") > -1) {
                        HideLoading();
                        ShowInfo("goodsList "+res.replace("Error：", ""),1);
                    }else if (res.indexOf("Warn:") > -1) {
                        HideLoading();
                        ShowInfo("获取成功！",1);
                        $("[id$=u-more-btn]").text("已无更多数据...");
                    }else{ 
                        var obj = JSON.parse(res);
                        var temp="<dl class='rs-item pg1' data-mid='$mid$'><a class='clearfix ablock' href=javascript:data_mid='$mid$';goodsDetail(\'$sphh$\',\'$spmc$\',\'$lsdj$\')> <dt class='pic'><img class='j_item_image pg1' src='$url$'  data-onerror='$url$' data-productid='$productid$' data-brandid=1 /></dt> <dd class='b_goods_sphh'>$sphh$ </dd> <dd class='b_goods_name'>$spmc$</dd> <dd class='pricebox clearfix'> <span class='grallyprice f-left'>&yen;$lsdj$</span>  <span class='f-right discount'>库存 $kc$</span></dd></a> </dl>";
                        var htmlStr="";

                        for (var i = 0; i < obj.rows.length; i++) {
                            if(obj.rows[i]["urlAddress"].toString()!=""){
                                htmlStr+=temp.replace(/\$mid\$/g,obj.rows[i]["xh"].toString()).replace(/\$url\$/g,"http://webt.lilang.com:9001"+obj.rows[i]["urlAddress"].toString().replace("..",'')).replace("$productid$",obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g,obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g,obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g,obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g,obj.rows[i]["kc"].toString());
                            }else{
                                htmlStr+=temp.replace(/\$mid\$/g,obj.rows[i]["xh"].toString()).replace(/\$url\$/g,"http://tm.lilanz.com"+"/oa/res/img/StoreSaler/lllogo5.jpg").replace("$productid$",obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g,obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g,obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g,obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g,obj.rows[i]["kc"].toString());
                            }
                        }  
                        if(lastID=="-1"){
                            $("#main").html(htmlStr);
                        }else{
                            $("#main").append(htmlStr);
                        }
                        lastID=$("#main dl:last-child").attr("data-mid");
					   
                        HideLoading();
                        ShowInfo("加载成功!",1);

                        //直接跳转到详情页
                        var cid=getQueryString("cid");
                        if(cid!=""&&cid!="0"&&cid!=undefined)
                            eval($(".rs-item.pg1[data-mid='"+cid+"'] a").attr("href"));
                    }             
                }
            });
        }
		
        function getQueryString(name) { 
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i"); 
            var r = window.location.search.substr(1).match(reg); 
            if (r != null) 
                return unescape(r[2]); 
            else
                return ""; 
        } 

        //搜索框调用的函数
        //20160610 liqf 搜索内容也进行分页
        function goodsListSingle(scanResult,scanType) {
            ShowLoading("拼命加载中...", 5);
            $.ajax({
                url: "goodsListCore.aspx?ctrl=goodsListSingle",
                type: "post",
                dataType: "text",
                data: { showType:"<%=showType %>", mdid: "<%=mdid%>", scanResult: scanResult, scanType:scanType, lastID:searchLastID },
                cache: false,
                timeout: 15000,
                error: function (e) {				    
                    HideLoading();
                    ShowInfo("网络异常",1);
                },
                success: function (res) { 
                    if(res.indexOf("Error")>-1){ 
                        HideLoading();
                        ShowInfo("goodsListSingle "+res.replace("Error:", ""),1);
                    }else if(res.indexOf("Warn")>-1){
                        HideLoading();
                        ShowInfo("goodsListSingle "+res.replace("Warn:", ""),1);
                    }else{
                        var obj = JSON.parse(res);                          
                        var temp="<dl class='rs-item pg1' data-mid='$mid$'><a class='clearfix ablock' href=javascript:data_mid='$mid$';goodsDetail(\'$sphh$\',\'$spmc$\',\'$lsdj$\')> <dt class='pic'><img class='j_item_image pg1' src='$url$' data-brandlazy='false' data-onerror='$url$' data-productid='$productid$' data-brandid=1 /></dt> <dd class='b_goods_sphh'>$sphh$ </dd> <dd class='b_goods_name'>$spmc$</dd> <dd class='pricebox clearfix'> <span class='grallyprice f-left'>&yen;$lsdj$</span>  <span class='f-right discount'>库存 $kc$</span></dd></a> </dl>";
                        var htmlStr="";
                        for (var i = 0; i < obj.rows.length; i++) {
                            if(obj.rows[i]["urlAddress"].toString()!=""){
                                htmlStr+=temp.replace(/\$mid\$/g,obj.rows[i]["xh"].toString()).replace(/\$url\$/g,"http://webt.lilang.com:9001"+obj.rows[i]["urlAddress"].toString().replace("..",'')).replace("$productid$",obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g,obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g,obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g,obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g,obj.rows[i]["kc"].toString());
                            }else{
                                htmlStr+=temp.replace(/\$mid\$/g,obj.rows[i]["xh"].toString()).replace(/\$url\$/g,"http://tm.lilanz.com"+"/oa/res/img/StoreSaler/lllogo5.jpg").replace("$productid$",obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g,obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g,obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g,obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g,obj.rows[i]["kc"].toString());
                            }
                        } 
                        if(obj.rows.length==0){
                            htmlStr+=temp.replace(/\$mid\$/g,obj.rows[i]["xh"].toString()).replace(/\$url\$/g,"http://tm.lilanz.com"+"/oa/res/img/StoreSaler/lllogo5.jpg").replace("$productid$",obj.rows[i]["xh"].toString()).replace(/\$sphh\$/g,obj.rows[i]["sphh"].toString()).replace(/\$spmc\$/g,obj.rows[i]["spmc"].toString()).replace(/\$lsdj\$/g,obj.rows[i]["lsdj"].toString()).replace(/\$kc\$/g,obj.rows[i]["kc"].toString());
                        }
                        $("#main").html(htmlStr);
                        searchLastID=$("#main dl:last-child").attr("data-mid");
                        $("#u-more-btn").text("-加载更多-");
                        HideLoading();
						if(obj.rows.length==1){ //筛选只有1条记录时直接进入detail
							goodsDetail(scanResult,scanType);
						}else{
						    ShowInfo("加载成功!",1); 
						}                       
                    }
                }
            });
        }
		
        function goodsfilter(scanResult,scanType){ //字段:值
            ShowLoading("拼命加载中...", 15);
            $.ajax({
                url: "goodsListCore.aspx?ctrl=goodsfilter",
                type: "post",
                dataType: "text",
                data: { showType:<%=showType %>,mdid: <%=mdid %>, scanResult: scanResult,scanType:scanType },
                cache: false,
                timeout: 15000,
                error: function (e) {
                    //RedirectErr();
                    HideLoading();
                    ShowInfo("网络异常",1);
                },
                success: function (res) {
                    if(res.indexOf("Error")=="-1"){
                        var obj = JSON.parse(res);
                        $("#main").html("");
                        for (var i = 0; i < obj.rows.length; i++) {
                            $("#main").append("<dl class='rs-item pg1' data-mid='" + obj.rows[i]["xh"].toString() + "'><a class='clearfix ablock' href=javascript:data_mid='"+obj.rows[i]["xh"].toString()+"';goodsDetail(\'"+obj.rows[i]["sphh"].toString()+"\',\'"+obj.rows[i]["spmc"].toString()+"\',\'"+obj.rows[i]["lsdj"].toString()+"\')> <dt class='pic'><img class='j_item_image pg1' src="+"http://webt.lilang.com:9001" + obj.rows[i]["urlAddress"].toString().replace("..",'') + " data-brandlazy='false' data-onerror="+"http://webt.lilang.com:9001" + obj.rows[i]["urlAddress"].toString().replace("..",'') + " data-productid='" + obj.rows[i]["xh"].toString() + "' data-brandid=1 /></dt> <dd class='b_goods_sphh'>" + obj.rows[i]["sphh"].toString() + " </dd> <dd class='b_goods_name'> " + obj.rows[i]["spmc"].toString() + "</dd> <dd class='pricebox clearfix'> <span class='grallyprice f-left'>&yen;" + obj.rows[i]["lsdj"].toString() + "</span>  <span class='f-right discount'>库存 "+obj.rows[i]["kc"].toString()+"</span></dd></a> </dl>");
                        } 
                        HideLoading();
                        ShowInfo("",1); 
                    }else{
                        HideLoading();
                        ShowInfo("goodsfilter "+res.replace("Error:",''),1); 
                    }                                             
                }
            });
        }
		
        //加载详情页
        function goodsDetail(scanResult,scanType,other){            
            if("<%=showType%>"!="2"){		
                $("#htmlList").hide();
                $('#htmlDetail').html($("#page2").html()).show();
                $(".fa-angle-left.icon-camera").hide();
            }else{
                ShowLoading("拼命加载中...", 15); 
            }
            $.ajax({
                url: "goodsListCore.aspx?ctrl=goodsDetail",
                type: "post",
                dataType: "text",
                data: { showType:"<%=showType %>", mdid:"<%=mdid %>", scanResult:scanResult, scanType:scanType},
                cache: false,
                timeout: 15000,
                error: function (e) {
                    HideLoading();
                    ShowInfo("网络异常",1);				    
                },
                success: function (res) {                    
                    if(res.indexOf("Error")=="-1"){ //有图片有货号
                        var obj=JSON.parse(res);				    
                        var htmlTemp="<p class='pro-name'>$spmc$（$sphh$）</p><p class='money'>￥<span style='text-decoration: blink;'>$lsdj$</span></p><i class='fa fa-star-o'></i><span class='llzp'>利郎正品</span><span class='zdzt'>重点主推</span>";
                        var topHtml="";
                        var htmlStr=htmlTemp.replace(/\$sphh\$/g,obj.rows[0]["sphh"].toString()).replace(/\$spmc\$/g,obj.rows[0]["spmc"].toString()).replace(/\$lsdj\$/g,obj.rows[0]["lsdj"].toString());
                        var endHtml="<ul>";
		               
                        for(var i=0;i<obj.rows.length;i++){
                            topHtml+="<a href='javascript:'>"+(i+1)+"</a>";
                            endHtml+="<li><span class='img_"+(i+1).toString()+"' onclick='javascript:previewImage(this);'></span></li>";					
                        }					
                        endHtml+="</ul> <a href='javascript:;' id='btn_prev'></a> <a href='javascript:;' id='btn_next'></a>";
                        if("<%=showType%>"=="2"){
                            $(".product-stock").hide();
                            $("#goodsDetail").show();
                        }
                        $(".flicking_inner").html(topHtml);
                        $(".main_image").html(endHtml);
                        $(".product-info").html(htmlStr);	
                        for(var i=0;i<obj.rows.length;i++){
                            if (obj.rows[i]["urlAddress"].toString()!=""){
                                $(".img_"+(i+1)).css({"background":"url('"+"http://webt.lilang.com:9001" + obj.rows[i]["urlAddress"].toString().replace("..",'')+"') center center no-repeat","background-size":"contain"});
                            }else{
                                $(".img_"+(i+1)).css({"background":"url('"+"http://tm.lilanz.com" + "/oa/res/img/StoreSaler/lllogo5.jpg"+"') center center no-repeat","background-size":"contain"});	
                            }
                        }
                        data_mid=obj.rows[0]["sphh"].toString();
                        if(obj.rows.length>1){
                            (function(){ //多图才轮播
                                $dragBln = false;
                                $(".main_image").touchSlider({
                                    flexible: true,
                                    speed: 250,
                                    delay:3000,
                                    autoplay:true,
                                    btn_prev: $("#btn_prev"),
                                    btn_next: $("#btn_next"),
                                    paging: $(".flicking_con a"),
                                    counter: function (e) {
                                        $(".flicking_con a").removeClass("on").eq(e.current - 1).addClass("on");
                                    }
                                });
                                $(".main_image").bind("mousedown", function () {
                                    $dragBln = false;
                                })
                                $(".main_image").bind("dragstart", function () {
                                    $dragBln = true;
                                })
                                $(".main_image a").click(function () {
                                    if ($dragBln) {
                                        return false;
                                    }
                                })
                                timer = setInterval(function () { $("#btn_next").click(); }, 5000);
                                $(".main_visual").hover(function () {
                                    clearInterval(timer);
                                }, function () {
                                    timer = setInterval(function () { $("#btn_next").click(); }, 5000);
                                })
                                $(".main_image").bind("touchstart", function () {
                                    clearInterval(timer);
                                }).bind("touchend", function () {
                                    timer = setInterval(function () { $("#btn_next").click(); }, 5000);
                                });					
                            })();
                        }
                    }else if(res == "Error:未找到关联商品图片"){
                        alert("对不起，查询不到该二维码信息！");
                        HideLoading();
                        return;
                    }else{ //无图片
                        var htmlTemp="<p class='pro-name'>$sphh$ &nbsp; $spmc$ </p><p class='money'>零售价：￥<span style='text-decoration: blink;'>$lsdj$</span></p>";
                        var topHtml="";
                        var htmlStr=htmlTemp.replace(/\$sphh\$/g,scanResult).replace(/\$spmc\$/g,scanType).replace(/\$lsdj\$/g,other);				        
                        var endHtml="<ul><li><span class='img_1' onclick='javascript:previewImage(this);'></span></li>";
                        if("<%=showType%>"=="2"){
                            $(".product-stock").hide();
                            $("#goodsDetail").show();
                        }
                        $(".flicking_inner").html(topHtml);
                        $(".main_image").html(endHtml);
                        $(".product-info").html(htmlStr);	

                        $(".img_1").css({"background":"url('"+"http://tm.lilanz.com" + "/oa/res/img/StoreSaler/lllogo5.jpg"+"') center center no-repeat","background-size":"contain"});
                        data_mid=scanResult;
                    }
				  
                    WXShareLink(data_mid);

                    if("<%=showType%>"=="2"){						
		                goodsImg(scanResult,scanType);					
		            }else{
		                goodsStock(scanResult,scanType);						
		            }
                    
                    //加载尺码信息
		            LoadCMInfos(scanResult,scanType);
                }
            });		
        }
		
        //商品库存		
        function goodsStock(scanResult,scanType){
            $.ajax({
                url: "goodsListCore.aspx?ctrl=goodsStock",
                type:"post",
                dataType: "text",
                data: { showType:<%=showType %>,mdid:<%=mdid %>,scanResult:scanResult,scanType:scanType},
                catch: false,
                timeout: 15000,
                error: function(e){
                    HideLoading();				
                    ShowInfo("网络异常",1);
                    //RedirectErr();				
                },
                success:function (res){
                    if(res.indexOf("Error")>-1){
                        HideLoading();
                        ShowInfo("goodsStock "+res.replace("Error:",''),1);
                    }else if(res.indexOf("Warn")>-1){
                        HideLoading();
                        ShowInfo("goodsStock "+res.replace("Warn:", ""),1);
                    }else{					
                        var obj=JSON.parse(res); 
                        var htmlTemp="<li $style$>$cm$<span class='u-detail-sl'>$sl$</span></li>";
                        var htmlStr="<p class='title'>库存信息</p><ul>";
                        for(var i=0;i<obj.rows.length ;i++){
                            if(obj.rows[i]["sl"]>0){
                                htmlStr+=htmlTemp.replace(/\$sl\$/g,"("+obj.rows[i]["sl"].toString()+")").replace("$style$","class='choose'").replace("$cm$",obj.rows[i]["cm"].toString());                                   
                            }else{
                                htmlStr+=htmlTemp.replace(/\$sl\$/g,'').replace("$style$","class='none' ").replace("$cm$",obj.rows[i]["cm"].toString());
                            }
                        }				   
                        $(".product-stock").html(htmlStr);
						
                        goodsImg(scanResult,scanType);
                    }	
                }
            });		
        }
		
        function goodsImg(scanResult,scanType){
            //alert("goodsImg:"+scanResult+"|"+scanType);
            $.ajax({
                url: "goodsListCore.aspx?ctrl=goodsImg",
                type:"post",
                dataType: "text",
                data: { showType:<%=showType %>,mdid:<%=mdid %>,scanResult:scanResult,scanType:scanType},
                catch: false,
                timeout: 15000,
                error: function(e){
                    HideLoading();				
                    ShowInfo("网络异常",1);
                    //RedirectErr();
                },
                success:function (res){
                    //alert(res);
                    if(res.indexOf("Error")>-1){
                        HideLoading();
                        ShowInfo("goodsImg "+res.replace("Error:",''),1);
                        $(".product-detail1").hide();
                        $(".product-detail2").hide();
                    }else if(res.indexOf("Warn")>-1){
                        HideLoading();
                        //ShowInfo("goodsImg "+res.replace("Warn:", ""),1);
                        $(".product-detail1").hide();
                        $(".product-detail2").hide();
                    }else{
                        var obj=JSON.parse(res);					    
                        //alert(obj);
                        //商品卖点成份信息
                        var htmlStr="<p class='title'>商品参数</p><div style='padding:8px;'><table>";
                        htmlTemp="<tr ><td style='min-width:85px' >$name$:</td><td>$value$</td></tr>";					
                        htmlStr+=htmlTemp.replace(/\$name\$/g,"商品货号").replace(/\$value\$/g,obj.rows[0]["sphh"].toString());
                        htmlStr+=htmlTemp.replace(/\$name\$/g,"商品名称").replace(/\$value\$/g,obj.rows[0]["spmc"].toString());
                        if(unescape(obj.rows[0]["cpmd"]).length>0){
                            htmlStr+=htmlTemp.replace(/\$name\$/g,"产品解读").replace(/\$value\$/g,unescape(obj.rows[0]["cpmd"]));
                        }
                        if(obj.rows[0]["mlcf"].toString().length>0){
                            htmlStr+=htmlTemp.replace(/\$name\$/g,"面料成份").replace(/\$value\$/g,obj.rows[0]["mlcf"].toString());
                        }
                        htmlStr+="</table></div>";
                        //商品图片
                        var PicStr="<p class='title'>商品图片</p>";
                        var PicTemp="<img src='$url$' onclick='javascript:previewImage(this);'/><p class='img-tips'>@SIMPLE YET SOPHISTICATED</p>";
                        for(var i=0;i<obj.rows.length;i++){
                            PicStr+=PicTemp.replace(/\$url\$/,"http://webt.lilang.com:9001"+obj.rows[i]["urlAddress"].toString().replace('..',""));
                        }
                        if(obj.rows.length==0){ //无图片时
                            PicStr+=PicTemp.replace(/\$url\$/,"http://tm.lilanz.com"+"/oa/res/img/StoreSaler/lllogo5.jpg");
                        }

                        $(".product-detail1").html(htmlStr);
                        $(".product-detail2").html(PicStr);
                        HideLoading();
                        ShowInfo("加载成功!",1); 
                    }
                }
            });
        }			
       
        //加载尺码信息20160613 by liqf
        function LoadCMInfos(sphh,scanType){		    
            $.ajax({
                url: "goodsListCore.aspx",
                type: "post",
                dataType: "text",
                data: { showType: 2, ctrl: "LoadCMInfos", sphh: sphh,scanType:scanType },
                cache: false,
                timeout: 10 * 1000,
                error: function (e) {

                },
                success: function (datas) {
                    if (datas != "") {
                        if (datas.indexOf("Error:") > -1)
                            $(".cm-content").empty().append(datas);
                        else {
                            var data = JSON.parse(datas);
                            var len = data.rows.length;
                            //遍历属性，构造出表头
                            var table_html = "<thead><tr>";
                            for (var p in data.rows[0]) {
                                table_html += "<th>" + p + "</th>";
                            }//end for
                            table_html += "</tr></thead><tbody>";
                            //遍历值，构造表体
                            for (var i = 0; i < len; i++) {
                                var row = data.rows[i];
                                table_html += "<tr>";
                                for (var p in row) {
                                    table_html += "<td>" + parseFloat(row[p]) + "</td>";
                                }//end for row
                                table_html += "</tr>";
                            }//end for all
                            table_html += "</tbody></table>";
                            //alert(table_html);
                            $(".cm-table").empty().append(table_html);
                        }
                    } else {                        
                        $(".product-cminfo").hide();
                    }
                }
            });
        }

        //20160607 liqf 设置URL中指定参数的值        
        function setQueStr(url, ref, value) //设置参数值
        {
            var str = "";
            if (url.indexOf('?') != -1)
                str = url.substr(url.indexOf('?') + 1);
            else
                return url + "?" + ref + "=" + value;
            var returnurl = "";
            var setparam = "";
            var arr;
            var modify = "0";

            if (str.indexOf('&') != -1) {
                arr = str.split('&');

                for (i in arr) {
                    if (arr[i].split('=')[0] == ref) {
                        setparam = value;
                        modify = "1";
                    }
                    else {
                        setparam = arr[i].split('=')[1];
                    }
                    returnurl = returnurl + arr[i].split('=')[0] + "=" + setparam + "&";
                }

                returnurl = returnurl.substr(0, returnurl.length - 1);

                if (modify == "0")
                    if (returnurl == str)
                        returnurl = returnurl + "&" + ref + "=" + value;
            }
            else {
                if (str.indexOf('=') != -1) {
                    arr = str.split('=');

                    if (arr[0] == ref) {
                        setparam = value;
                        modify = "1";
                    }
                    else {
                        setparam = arr[1];
                    }
                    returnurl = arr[0] + "=" + setparam;
                    if (modify == "0")
                        if (returnurl == str)
                            returnurl = returnurl + "&" + ref + "=" + value;
                }
                else
                    returnurl = ref + "=" + value;
            }
            return url.substr(0, url.indexOf('?')) + "?" + returnurl;
        }
    </script>
</asp:Content>
