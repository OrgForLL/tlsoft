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
        
        .dialog-wrap
        {
            display: none;
         }
         
         .global_mask {
             position: fixed;
             z-index: 8000;
             top: 0;
             left: 0;
             right: 0;
             bottom: 0;
             background-color: rgba(0, 0, 0, 0.6);
         }
 
        .dialog {
            position: fixed;
            z-index: 8005;
            width: 80%;
            max-width: 300px;
            top: 50%;
            left: 50%;
            -webkit-transform: translate(-50%, -50%);
            transform: translate(-50%, -50%);
            background-color: #FFFFFF;
            text-align: center;
            border-radius: 3px;
            overflow: hidden;
   
         }
 
         .loading,
         .prompt {
             position: fixed;
             z-index: 8004;
             width: 120px;
             height: 80px;
             top: 50%;
             left: 50%;
             -webkit-transform: translate(-50%, -50%);
             transform: translate(-50%, -50%);
             background-color: rgba(0, 0, 0, .4);
             text-align: center;
             border-radius: 3px;
             overflow: hidden;
             color: #fff;
             align-items: center;
             flex-direction: column;
             justify-content: center;
             display: none;
         }
 
         .prompt {
             background-color: rgba(0, 0, 0, .7);
         }
 
         .prompt > .iconfont {
             font-size: 24px;
             font-weight: bold;
         }
 
         .loading>img {
             width: 28px;
             height: 28px;
             margin-bottom: 5px;
         }
 
         .dialog_hd {
             padding: 15px 10px 10px 10px;
             font-size: 18px;
         }
 
         .dialog_ft {
             position: relative;
             line-height: 48px;
             font-size: 16px;
             display: -webkit-box;
             display: -webkit-flex;
             display: flex;
         }
 
         .dialog_ft:after {
             content: " ";
             position: absolute;
             left: 0;
             top: 0;
             right: 0;
             height: 1px;
             border-top: 1px solid #D5D5D6;
             color: #D5D5D6;
             -webkit-transform-origin: 0 0;
             transform-origin: 0 0;
             -webkit-transform: scaleY(0.5);
             transform: scaleY(0.5);
         }
 
         .dialog_bd {
            padding: 15px 10px 20px 10px;
            min-height: 40px;
            font-size: 15px;
            line-height: 1.3;
            word-wrap: break-word;
            word-break: break-all;
            color: #999999;
            display: flex;
            justify-content: space-around;
         }
         
         .dialog_bd > p
         {
            text-align:left;
            line-height: 34px;
            margin-left: 10px;  
         }
 
         .dialog_btn {
             display: block;
             -webkit-box-flex: 1;
             -webkit-flex: 1;
             flex: 1;
             color: #3CC51F;
             text-decoration: none;
             -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
             position: relative;
         }
 
         .dialog_btn:active {
             background-color: rgb(238, 238, 238);
         }
 
         .dialog_btn:after {
             content: " ";
             position: absolute;
             left: 0;
             top: 0;
             width: 1px;
             bottom: 0;
             border-left: 1px solid #D5D5D6;
             color: #D5D5D6;
             -webkit-transform-origin: 0 0;
             transform-origin: 0 0;
             -webkit-transform: scaleX(0.5);
             transform: scaleX(0.5);
         }
         
         /*radio checkbox style*/
    	
    	input[type=checkbox],
    	input[type=radio] {
    	    -webkit-appearance: none;
    	    background-color: transparent;
    	    outline: 0 !important;
    	    border: 0;
    	    font-size: 1em !important;
    	    vertical-align: middle;
    	    margin-top: -5px;
    	}
    	
    	input[type=checkbox]:before,
    	input[type=radio]:before {
    	    display: inline-block;
    	    text-align: center;
    	    font: normal normal normal 16px/1 FontAwesome;
    	    font-size: 20px;
    	    -webkit-font-smoothing: antialiased;
    	    -moz-osx-font-smoothing: grayscale;
    	    color: #d4d4d4;
    	}
    	
    	input[type=checkbox]:checked:before,
    	input[type=radio]:checked:before {
    	    color: #fe7857;
    	}
    	
    	input[type=checkbox]:before {
    	    content: "\f096";
    	}
    	
    	input[type=checkbox]:checked:before {
    	    content: "\f14a";
    	}
    	
    	input[type=radio]:before {
    	    content: "\f1db";
    	}
    	
    	input[type=radio]:checked:before {
    	    content: "\f192";
    	}
    	/*end radio checkbox style*/
        

        .page {
            position: absolute;
            left: 0;
            right: 0;
            top: 0;
            bottom: 0;
            background: #f8f8f8;
            padding: 20px;
        }

        .title {
            font-size: 24px;
            font-weight: bold;
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

        #product-wrap .tips {
            background-color: #f9ebdb;
            color: #a06d3a;
            padding: 6px 10px;
            border-radius: 4px;
            margin: 20px 0 10px;
            font-size: 12px;
        }
        
        #product-wrap .codetype-wrap
        {
            display: flex;
            justify-content: space-around;
            margin-top: 20px;
            display: none;
        }
        
        .codetype input
        {
            margin-right:4px;   
         }

        .foot-btn {
            display: flex;
            justify-content: space-around;
            margin-top: 40px;
        }

        .foot-btn>button {
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
        
        #product-wrap .content-wrap
        {
            display: flex;
            align-items: center;
        }
        
    </style>
</head>

<body ontouchstart>
    <div class="page">
        <p class="title">商品分享</p>
        <!-- 未扫码无数据时 -->
        <div class="content-wrap" id="nodata-wrap">
            <img src="no_photo.png" alt="无分享图片提示" />
            <p>还没有可分享的商品二维码，</p>
            <p>赶紧点击「扫码分享」唤醒我把~</p>
        </div>
        <!-- 扫码后商品图片二维码 -->
        <div id="product-wrap">
            <p class="tips">温馨提示：可长按图片分享或者点击右上角转发</p>
            <div class="content-wrap">
                <img src="no_photo.png" alt="分享图片" />
            </div>
            <div class="codetype-wrap">
                <p class="codetype">
                    <input type="radio" name="qrcode" value="1"/>
                    <label>小程序二维码</label>
                </p>
                <p class="codetype">
                    <input type="radio" name="qrcode" value="0"/>
                    <label>商品详情页二维码</label>
                </p>
            </div>
        </div>
        <div class="foot-btn">
            <button id="btn-code">扫码分享</button>
            <button id="btn-record">扫码记录</button>
        </div>
    </div>
    <div class="dialog-wrap">
    <div class="global_mask"></div>
    <div class="dialog">
        <div class="dialog_hd"><strong>选择生成的二维码种类</strong></div>
        <div class="dialog_bd">
            <p class="codetype">
                <input type="radio" name="qrcode" value="1"/>
                <label>小程序</label>
            </p>
            <p class="codetype">
                <input type="radio" name="qrcode" value="0"/>
                <label>商品详情页</label>
            </p>
        </div>
        <div class="dialog_ft">
            <a href="javascript:;" class="dialog_btn cancle" style="color:#353535;">取 消</a>
            <a href="javascript:;" class="dialog_btn confirm">确 认</a>
        </div>
    </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/jweixin-1.1.0.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="http://tm.lilanz.com/oa/api/lilanzAppWVJBridge-0.1.6.min.js"></script>
    <script type="text/javascript">

        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var mdid = "<%=mdid%>", cid = "<%=CustomerID%>";

        $(function () {
            llApp.init();

            // 获取地址栏URL参数
            function getUrlParam(name) {
                var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); // 构造一个含有目标参数的正则表达式对象  
                var r = window.location.search.substr(1).match(reg); // 匹配目标参数  
                if (r != null) return unescape(r[2]);
                return null; // 返回参数值  
            }

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

                    //预览图片
                    $("#product-wrap").on("click", "img", function () {
                        wx.previewImage({
                            current: $(this).attr("data-bigImg"),
                            urls: [$(this).attr("data-bigImg")]
                        });
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

                                //alert(result + "id:" + id);

                            } else
                                alert("该功能仅限扫描利郎吊牌二维码！");
                        }

                    });
                });
            }


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


            // 点击分享记录
            $("#btn-record").click(function () {
                window.location.href = "shareRecord.aspx";
            });



            //点击对话框取消按钮
            $(".cancle").click(function () {
                $(".dialog-wrap").hide();
            });



            //选择二维码类型
            $(".codetype").click(function () {
                $(this).find("input").attr("checked", "checked");
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
                            $(".dialog-wrap").show();

                            //点击对话框确认按钮
                            $(".confirm").click(function () {
                                var isminiprogram = $(".dialog_bd input:checked ").val();
                                loadImg(sphh, isminiprogram);
                                $(".dialog-wrap").hide();
                            });

                        } else
                            alert("获取商品货号接口：" + msg.errmsg);
                    }
                });
            }


            //获取分享图片
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

                            $("#product-wrap img").attr("src", msg.imgurl);
                            $("#product-wrap img").attr("data-bigImg", msg.imgurl);
                            $("#nodata-wrap").hide();
                            $("#product-wrap").show();

                            var shareDesc = msg.sphh + "|好物分享，一起来看。"
                            wxShare(msg.linkurl, "利郎|" + msg.spmc, msg.miniimgurl, shareDesc);

                            $("#leemask").hide();

                        } else
                            alert("获取分享图片：" + msg.errmsg);
                    }
                });
            }

            jsConfig();

        });
    </script>
</body>

</html>
