<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">

    private const string ConfigKeyValue = "7";	//微信配置信息索引值
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    public string AppSystemKey = "", CustomerID = "", CustomerName = "", mdid = "", tzid = "";
    protected void Page_Load(object sender, EventArgs e)
    {

        //if (clsWXHelper.CheckQYUserAuth(true))
        //{
        //    AppSystemKey = clsWXHelper.GetAuthorizedKey(3);//全渠道系统
        //    mdid = Convert.ToString(Session["mdid"]);
        //    if (AppSystemKey == "")
        //        clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
        //    else if (mdid == "" || mdid == "0")
        //    {
        //        clsWXHelper.ShowError("对不起，您无门店信息，无法使用此功能！");
        //    }
        //    else
        //    {
        //        CustomerID = Convert.ToString(Session["qy_customersid"]);
        //        CustomerName = Convert.ToString(Session["qy_cname"]);
                //传入参数wx_t_ActiveToken.id[tid]
                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
        //    }
        //}
    }
</script>

<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <title></title>
    <style>
        * {
            font-family: Helvetica Neue, Helvetica, Microsoft YaHei, PingFang SC, Hiragino Sans GB, SimSun, sans-serif;
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-size: 14px;
            color: #333;
            -webkit-tap-highlight-color: transparent;
        }
        
        
        ul{
            list-style: none;   
        }
         
         
        .page {
            position: absolute;
            left: 0;
            right: 0;
            top: 0;
            bottom: 0;
            background: #f8f8f8;
            overflow-y: auto;
            overflow-x: hidden;
             -webkit-overflow-scrolling: touch;
        }

        .title {
            font-size: 24px;
            font-weight: bold;
            padding: 20px 20px 0;
        }

        .content-wrap {
            width: 90vw;
            height: 90vw;
            /* border: 1px solid #f3f3f3; */
            -webkit-box-shadow: 0 6px 10px rgba(0, 0, 0, 0.06);
            box-shadow: 0 6px 10px rgba(0, 0, 0, 0.06);
            background: #fff;
            border-radius: 6px;
        }

        #nodata-wrap {
            margin-top: 16%;
            text-align: center;
            padding: 10px;
        }

        #nodata-wrap>img {
            width: 80%;
            margin: 10px 0;
        }

        #nodata-wrap>p {
            line-height: 28px;
            color: #c7c8cb;
        }

        #product-wrap {
            margin-top: 10%;
            display: none;
        }

        #product-wrap img {
            width: 100%;
            border-radius: 6px;
        }

        .tips {
            background-color: #f9ebdb;
            color: #a06d3a;
            padding: 6px 20px;
            border-radius: 4px;
            font-size: 12px;
            width: 100%;
            display:none;
        }
        
        #product-wrap .codetype-wrap
        {
            display: flex;
            justify-content: space-around;
            margin-top: 20px;
            display: none;
        }
        

        .foot-btn {
            display: flex;
            padding: 0 20px;
            position: absolute;
            left: 0;
            right: 0;
            bottom: 0px;
            margin-bottom: 30px;
            background-color: #f8f8f8;
            flex-direction: column;
        }
        
        
        .foot-btn > div
        {
            display: flex;
            justify-content: space-around;
            margin-bottom: 15px;
        }
        
        
        .foot-btn .IM-btn
        {
            display:none;    
        }
        
        
        .foot-btn button {
            width: 40%;
            height: 45px;
            border-radius: 6px;
            border: 0;
            font-size: 14px;
            -webkit-tap-highlight-color: transparent;
        }

        #btn-code {
            background-color: #fe7857;
            color: #fff;
        }

        #btn-code:active {
            background-color: #f6663e;
        }

        #btn-record {
            border: 1px solid #fe7857;
            color: #fe7857;
            background-color: transparent;
        }

        #btn-record:active {
            background-color: #fe7857;
            color: #fff;
        }
        
        #btn-sharefriend
        {
            background-color: #1aaf1c;
            color: #fff;    
        }
        
        #btn-sharefriend:active
        {
            background-color:#179f19;
        }
        
     
        #btn-sharecircle
        {
            background-color: transparent;
            border: 1px solid #1aaf1c;
            color: #1aaf1c;
        }
        
        #btn-sharecircle:active
        {
            background-color: #1aaf1c;
            color: #fff;    
        }
        
        
        #product-wrap .content-wrap
        {
            display: flex;
            align-items: center;
        }
        
        .tab-wrap
        {
            margin: 30px 20px 0; 
            -webkit-box-shadow: 0 6px 10px rgba(0, 0, 0, 0.06);
            box-shadow: 0 6px 10px rgba(0, 0, 0, 0.06);
            border-radius: 6px;
            padding: 2px;
            background-color:#fff;
        }
        
            
        ul.tab-title{
           display: flex;
           justify-content: space-around;   
           background-color:#fff; 
           border-bottom: 1px solid #f8f8f8;
        }
         
         
        ul.tab-title li{
            color: #656565;
            padding: 12px 0;
            -webkit-tap-highlight-color: transparent;
        }
        
        ul.tab-title li.tab-this
        {
            color:#333;
        }
        
        ul.tab-title li.tab-this:after
        {
            background-color: #f5603f;
            content: '';
            width: 50%;
            display: block;
            height: 3px;
            left: 50%;
            position: relative;
            top: 12px;
            transform: translateX(-50%);
         }
         
         .tab-content .tab-item
         {  
             background-color:#fff;
             display:none;
             margin-top:2px;
         }
         
         .tab-content .tab-show
         {  
             display:block;
          }
          
         .tab-content .tab-item img
         {  
             width: 100%;
         }
    </style>
</head>

<body ontouchstart>
    <div class="page">
        <p class="tips">温馨提示：可长按图片分享或者点击右上角转发</p>
        <p class="title">商品分享</p>
        <div class="tab-wrap">
            <ul class="tab-title">
                <li class="tab-this" data-value="0">网页二维码</li>
                <li data-value="1">小程序二维码</li>
            </ul>
            <div class="tab-content">
                <div class="tab-item tab-show">
                    <img src="no_detailcode.jpg" data-bigimg="http://tm.lilanz.com/QYWX/project/productShare/no_detailcode.jpg" alt="详情分享图" />
                </div>
                <div class="tab-item">
                    <img src="no_miniprocode.jpg" data-bigimg="http://tm.lilanz.com/QYWX/project/productShare/no_miniprocode.jpg" alt="小程序分享图" />
                </div>
            </div>
        </div>
    </div>
    <div class="foot-btn">
        <div>
            <button id="btn-code">扫码</button>
            <button id="btn-record">扫码记录</button>
        </div>
        <div class="IM-btn">
            <button id="btn-sharefriend">发送给朋友</button>
            <button id="btn-sharecircle">分享到朋友圈</button>
        </div>
    </div>
    
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/jweixin-1.1.0.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="http://tm.lilanz.com/oa/api/lilanzAppWVJBridge-0.1.6.min.js"></script>
    <script type="text/javascript">

        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var mdid = "<%=mdid%>", cid = "<%=CustomerID%>";
        var isWXCode = 0, currentSPHH = "";

        $(function () {

            llApp.init();

            //判断是否在微信中打开
            function is_weixn() {
                var ua = navigator.userAgent.toLowerCase();
                if (ua.match(/MicroMessenger/i) == "micromessenger") {
                    return true;
                } else {
                    return false;
                }
            }


            var wxConfig = {
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['checkJsApi', 'scanQRCode', 'previewImage', 'onMenuShareTimeline', 'onMenuShareQQ', 'onMenuShareAppMessage', 'onMenuShareQZone', 'getNetworkType'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            };


            //微信JS-SDK
            function jsConfig() {

                wx.config(wxConfig);

                wx.ready(function () {

                    wx.checkJsApi({
                        jsApiList: ['scanQRCode', 'previewImage', 'onMenuShareTimeline', 'onMenuShareQQ', 'onMenuShareAppMessage', 'onMenuShareQZone'],
                        success: function (res) {

                        }
                    });


                });

                wx.error(function (res) {
                    console.log("微信JS-SDK注册失败！");
                });
            }



            // 微信分享（注意：分享链接的域名或路径必须与当前页面对应的公众号JS安全域名一致）
            function wxShare(sharelink, shareTitle, shareImgurl, shareDesc) {

                wx.ready(function () {

                    //分享到朋友圈
                    wx.onMenuShareTimeline({
                        title: shareTitle, // 分享标题
                        link: sharelink, // 分享链接                        
                        imgUrl: shareImgurl, // 分享图标
                        desc: shareDesc,
                        success: function () {
                        },
                        cancel: function () {
                        }
                    });

                    //分享给QQ好友
                    wx.onMenuShareQQ({
                        title: shareTitle, // 分享标题
                        link: sharelink, // 分享链接                        
                        imgUrl: shareImgurl, // 分享图标
                        desc: shareDesc,
                        success: function () {
                        },
                        cancel: function () {
                        }
                    });

                    //分享给朋友
                    wx.onMenuShareAppMessage({
                        title: shareTitle, // 分享标题
                        link: sharelink, // 分享链接                        
                        imgUrl: shareImgurl, // 分享图标
                        desc: shareDesc,
                        type: 'link', // 分享类型,music、video或link，不填默认为link
                        dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                        success: function () {
                        },
                        cancel: function () {
                        }
                    });

                    //分享到QQ空间
                    wx.onMenuShareQZone({
                        title: shareTitle, // 分享标题
                        link: sharelink, // 分享链接                        
                        imgUrl: shareImgurl, // 分享图标
                        desc: shareDesc,
                        success: function () {
                        },
                        cancel: function () {
                        }
                    });

                });

                wx.error(function (res) {
                    console.log("微信JS-SDK注册失败！");
                });

            }


            //微信扫码
            function wxScanQRCode() {
                wx.ready(function () {
                    wx.scanQRCode({
                        needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                        scanType: ["qrCode"],
                        success: function (res) {
                            var result = res.resultStr; // 当needResult 为 1 时，扫码返回的结果
                            //当扫描的二维码是利郎吊牌时
                            if (result.indexOf("http://tm.lilanz.com/tm.aspx") != -1) {

                                var id = result.split("id=")[1];
                                loadQRCode(id);

                            } else
                                alert("该功能仅限扫描利郎吊牌二维码！");
                        }

                    });
                });
            }


            //预览图片
            $(".tab-item").on("click", "img", function () {
                var imgurl = $(this).attr("data-bigimg");
                if (is_weixn()) {
                    wx.ready(function () {
                        wx.previewImage({
                            current: imgurl,
                            urls: [imgurl]
                        });
                    });

                } else {

                    llApp.previewImage({
                        current: imgurl,
                        urls: [imgurl]
                    });
                }

            });


            // 点击扫码分享
            $("#btn-code").click(function () {
                if (is_weixn()) {
                    wxScanQRCode();
                } else {

                    llApp.scanQRCode(function (result) {

                        //当扫描的二维码是利郎吊牌时
                        if (result.indexOf("http://tm.lilanz.com/tm.aspx") != -1) {
                            var id = result.split("id=")[1];
                            loadQRCode(id);

                        } else
                            alert("该功能仅限扫描利郎吊牌二维码！");
                    });
                }

            });



            // 点击分享记录
            $("#btn-record").click(function () {
                window.location.href = "shareRecord.aspx?isminiprogram=" + isWXCode;
            });


            //点击tab
            $(".tab-title li").click(function () {
                isWXCode = $(this).attr("data-value");
                var index = $(this).index();

                $(".tab-title li").removeClass("tab-this");
                $(this).addClass("tab-this");

                if (currentSPHH != "") {
                    loadImg(currentSPHH, isWXCode);
                }

                $(".tab-item").removeClass("tab-show");
                $(".tab-item").eq(index).addClass("tab-show");



            });



            //扫吊牌上的二维码获取接口地址，请求得到商品货号
            function loadQRCode(id) {
                $.ajax({
                    url: "../StoreSaler/TurnoversCore.aspx?ctrl=ProductDecode&id=" + id,
                    type: "post",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: {},
                    cache: false,
                    timeout: 15000,
                    error: function (e) {
                        alert("获取商品货号接口: 网络异常,请稍后重试！");
                    },
                    success: function (res) {
                        var msg = JSON.parse(res);

                        if (msg.errcode == "0") {

                            var sphh = msg.data;
                            currentSPHH = sphh;
                            loadImg(sphh, isWXCode);

                        } else
                            alert("获取商品货号接口：" + msg.errmsg);
                    }
                });
            }


            //获取分享图片（isminiprogram=1时生成小程序二维码）
            function loadImg(sphh, isminiprogram) {

                LeeJSUtils.showMessage("loading", "正在加载..");
                $.ajax({
                    url: "../StoreSaler/TurnoversCore.aspx?ctrl=getShareUrl&mdid=" + "249" + "&cid=" + "587" + "&sphh=" + sphh + "&isminiprogram=" + isminiprogram,
                    type: "post",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: {},
                    cache: false,
                    timeout: 15000,
                    error: function (e) {
                        alert("获取分享图片接口：网络异常,请稍后重试！");
                    },
                    success: function (res) {
                        var msg = JSON.parse(res);
                        if (msg.errcode == "0") {

                            var imgurl = msg.imgurl,
                                miniimgurl = msg.miniimgurl,
                                title = "利郎|" + msg.spmc,
                                desc = msg.sphh + "|好物分享，一起来看。",
                                linkurl;

                            if (isminiprogram == 1) {
                                linkurl = msg.imgurl;
                            } else
                                linkurl = msg.linkurl;

                            $(".tips").show();
                            $(".tab-show img").attr("src", imgurl);
                            $(".tab-show img").attr("data-bigimg", imgurl);


                            wxShare(linkurl, title, miniimgurl, desc); ;


                            //IM分享到朋友圈
                            $("#btn-sharecircle").click(function () {
                                llApp.ShareLinkToWeiXin(linkurl, title, desc, miniimgurl, "circle");
                            });


                            //IM发送给朋友
                            $("#btn-sharefriend").click(function () {
                                llApp.ShareLinkToWeiXin(linkurl, title, desc, miniimgurl, "friend");
                            });

                            init();

                            $("#leemask").hide();

                        } else
                            alert("获取分享图片：" + msg.errmsg);
                    }
                });
            }



            function init() {

                if (!is_weixn()) {

                    $(".IM-btn").css("display", "flex");
                }
            }

            jsConfig();


        });
    </script>
</body>

</html>
