<%@ Page Language="C#" %>

<%@ Import Namespace="WebBLL.Core" %>

<!DOCTYPE html>
<script runat="server">
    public string gametoken = "", userid = "", gameid = "";
    private const string appID = "wxc368c7744f66a3d7";	//APPID
    private const string appSecret = "74ebc70df1f964680bd3bdd2f15b4bed";	//appSecret	
    public string[] wxConfig;       //微信OPEN_JS 动态生成的调用参数

    protected void Page_Load(object sender, EventArgs e)
    {
        userid = Convert.ToString(Session["TM_WXUserID"]);
        gametoken = Convert.ToString(Request.Params["token"]);
        gameid = Convert.ToString(Request.Params["gameid"]);

        if (userid == null || userid == "" || userid == "0")
        {
            string gourl = HttpUtility.UrlEncode("http://tm.lilanz.com/supersalegames/TMOauthAndRedirect.aspx");
            string curURL = HttpUtility.UrlEncode(Request.Url.ToString());
            string OauthURL = @"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxc368c7744f66a3d7&redirect_uri={0}&response_type=code&scope=snsapi_userinfo&state={1}#wechat_redirect";
            OauthURL = string.Format(OauthURL, gourl, curURL);
            Response.Redirect(OauthURL);
            Response.End();
        }
        else if (gametoken == "" || gametoken == null)
        {
            gametoken = "";
        }
        else
        {
            using (WxHelper wh = new WxHelper())
            {
                wxConfig = wh.GetWXJsApiConfig(appID, appSecret);
            }
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <title></title>
    <link href="css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        body {
            color: #333;
            /*background: #55994c;*/
            background: #333;
            font-family: "微软雅黑";
        }

        .container {
            width: 94%;
            margin: 80px auto 20px auto;
            background: #fff;
            border-radius: 5px;
            padding: 70px 10px 10px 10px;
            box-sizing: border-box;
            overflow: hidden;
        }

        .logo {
            width: 80px;
            height: 80px;
            margin: 0 auto;
            overflow: hidden;
            border: 5px solid #eee;
            box-shadow: 0 6px 20px 0 rgba(0,0,0,.19),0 8px 17px 0 rgba(0,0,0,.2);
            background: url(img/lilanzlogo.jpg) no-repeat;
            background-size: cover;
            border-radius: 50%;
            position: absolute;
            margin-top: -45px;
            left: 50%;
            margin-left: -45px;
        }

        .title h4 {
            text-align: center;
            color: #757575;
            font-weight: 600;
            letter-spacing: 1px;
        }

        .title h2 {
            text-align: center;
            margin-top: 10px;
            font-weight: 600;
            letter-spacing: 4px;
            text-shadow: 0 0 1px #808080;
        }

        .title {
            border-bottom: 1px dashed #e1e1e1;
            padding-bottom: 10px;
        }

        .btn {
            display: block;
            text-decoration: none;
            color: #fff;
            width: 100px;
            /*background: #63b35a;*/
            background: #333;
            padding: 8px 25px;
            border-radius: 6px;
            letter-spacing: 2px;
            font-size: 1.1em;
            margin: 10px auto 0 auto;
            text-align: center;
        }

        .static {
            list-style: none;
            border-bottom: 1px dashed #e1e1e1;
        }

            .static li {
                font-size: 1em;
                background: #fff;
            }

                .static li:not(:last-child) {
                    border-bottom: 1px solid #e1e1e1;
                }

                .static li:after {
                    content: "";
                    display: table;
                    clear: both;
                }

            .static span {
                display: block;
                width: 50%;
                float: left;
                text-align: center;
                padding: 8px 0;
                overflow: hidden;
                white-space: nowrap;
                text-overflow: ellipsis;
                box-sizing: border-box;
            }

        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }

        .sname {
            font-weight: bold;
            border-right: 1px solid #e1e1e1;
        }

        .copyright {
            text-align: center;
            color: #fff;
            font-size: 1em;
            margin: 20px 0;
            text-shadow: 0 0 1px #fff;
        }

        #qrcode {
            width: 200px;
            height: 200px;
            margin: 10px 0;
            padding: 8px;
            border: 1px solid #ccc;
        }

        #qrcon {
            text-align: center;
            display: none;
        }

            #qrcon p {
                color: #fff;
                /*background: #55994c;*/
                background: #333;
                width: 240px;
                padding: 5px;
                margin: 0 auto;
                border-radius: 5px;
            }

        .info {
            color: #333;
            background-color: #fff;
            width: 96%;
            margin: 20px auto;
            overflow: hidden;
            box-shadow: 0px 0px 2px #e2e2e2;
            padding: 10px;
            box-sizing: border-box;
            border-top: 4px solid #333;
        }

            .info p {
                line-height: 26px;
            }

        .sharelayer {
            position: fixed;
            top: 0;
            left: 0;
            z-index: 1000;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,.5);
            display:none;
        }

        .shareimg1 {
            position: absolute;
            right: 0;
            top: 0;
            width: 320px;
            height: auto;
        }

        .shareimg2 {
            top: 60px;
        }

        #status {
            color: #DD6B55;
            font-weight: bold;
        }

        /*animated*/
        .animated {
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

        @-webkit-keyframes flip {
            0% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,-360deg);
                transform: perspective(400px) rotate3d(0,1,0,-360deg);
                -webkit-animation-timing-function: ease-out;
                animation-timing-function: ease-out;
            }

            40% {
                -webkit-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-190deg);
                transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-190deg);
                -webkit-animation-timing-function: ease-out;
                animation-timing-function: ease-out;
            }

            50% {
                -webkit-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-170deg);
                transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-170deg);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }

            80% {
                -webkit-transform: perspective(400px) scale3d(.95,.95,.95);
                transform: perspective(400px) scale3d(.95,.95,.95);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }

            100% {
                -webkit-transform: perspective(400px);
                transform: perspective(400px);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }
        }

        @keyframes flip {
            0% {
                -webkit-transform: perspective(400px) rotate3d(0,1,0,-360deg);
                -ms-transform: perspective(400px) rotate3d(0,1,0,-360deg);
                transform: perspective(400px) rotate3d(0,1,0,-360deg);
                -webkit-animation-timing-function: ease-out;
                animation-timing-function: ease-out;
            }

            40% {
                -webkit-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-190deg);
                -ms-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-190deg);
                transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-190deg);
                -webkit-animation-timing-function: ease-out;
                animation-timing-function: ease-out;
            }

            50% {
                -webkit-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-170deg);
                -ms-transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-170deg);
                transform: perspective(400px) translate3d(0,0,150px) rotate3d(0,1,0,-170deg);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }

            80% {
                -webkit-transform: perspective(400px) scale3d(.95,.95,.95);
                -ms-transform: perspective(400px) scale3d(.95,.95,.95);
                transform: perspective(400px) scale3d(.95,.95,.95);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }

            100% {
                -webkit-transform: perspective(400px);
                -ms-transform: perspective(400px);
                transform: perspective(400px);
                -webkit-animation-timing-function: ease-in;
                animation-timing-function: ease-in;
            }
        }

        .animated.flip {
            -webkit-backface-visibility: visible;
            -ms-backface-visibility: visible;
            backface-visibility: visible;
            -webkit-animation-name: flip;
            animation-name: flip;
        }
    </style>
</head>
<body>
    <div class="sharelayer">
        <div>
            <img class="shareimg1" src="img/weinxin_share_arrow.png" />
            <img class="shareimg1 shareimg2" src="img/weinxin_share_txt.png" />
        </div>
    </div>
    <div class="logo animated flip"></div>
    <div class="container">
        <div class="title">
            <h4>利郎2015福利会</h4>
            <h2>礼 券 详 情</h2>
            <a class="btn" href="http://tm.lilanz.com/supersalegames/myprizelist.aspx">我的礼券</a>
        </div>
        <div>
            <ul class="static">
                <li>
                    <span class="sname">奖项</span>
                    <span class="svals" id="prizename">--</span>
                </li>
                <li>
                    <span class="sname">描述</span>
                    <span class="svals" id="prizedesc">--</span>
                </li>
                <li>
                    <span class="sname">来源</span>
                    <span class="svals" id="source">--</span>
                </li>
                <li>
                    <span class="sname">获取时间</span>
                    <span class="svals" id="gettime">--</span>
                </li>
                <li>
                    <span class="sname">有效期</span>
                    <span class="svals" id="validtime">--</span>
                </li>
                <li>
                    <span class="sname">礼券状态</span>
                    <span class="svals" id="status">--</span>
                </li>
            </ul>
        </div>
        <div id="qrcon">
            <img id="qrcode" src="" alt="" />
            <p>请持本二维码至礼品领取处兑奖</p>
        </div>
        <div class="info">
            <strong>温馨提示：</strong>
            <p>1.单击右上角菜单选择“分享到朋友圈”之后，即可<strong style="color: #f00;">激活成功</strong>！</p>
            <p>2.激活成功后的礼券才能在领奖处兑换礼品！</p>
            <p>3.请持本人身份证或中奖微信号兑奖；</p>
            <p>4.只有在有效期内的礼券才能兑换礼品；</p>
        </div>
    </div>
    <div class="copyright">&copy;2015 利郎信息技术部</div>
    <script src="js/jquery.js" type="text/javascript"></script>
    <script src="js/sweet-alert.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script>
        var _hmt = _hmt || [];
        (function () {
            var hm = document.createElement("script");
            hm.src = "//hm.baidu.com/hm.js?f274c2a4c37455fe3bba3b7477d74d26";
            var s = document.getElementsByTagName("script")[0];
            s.parentNode.insertBefore(hm, s);
        })();
    </script>
    <script type="text/javascript">
        var gametoken = "<%=gametoken%>", userid = "<%=userid%>", gameid = "<%=gameid%>";
        window.onload = function () {
            //参数检查
            if (userid == "" || gameid == "" || gametoken == "" || gametoken == null) {
                swal("请正确打开此页面", "", "error");
            } else {
                $.ajax({
                    type: "POST",
                    timeout: 5000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "ggkProcess.aspx",
                    data: { ctrl: "GetGiftDetail", gametoken: gametoken, userid: userid, gameid: gameid },
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1) {
                            swal({ title: "出错了", text: msg.replace("Error:", ""), type: "error", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "确定", closeOnConfirm: true });
                            return;
                        } else {
                            var arr = msg.split("|");
                            $("#prizename").text(arr[0]);
                            $("#prizedesc").text(arr[1]);
                            $("#source").text(arr[2]);
                            $("#gettime").text(arr[3]);
                            $("#validtime").text(arr[4]);
                            $("#status").text(arr[5]);
                            wxjdk();
                            if ($("#status").text() == "去激活")
                                $(".sharelayer").show();
                            else
                                $(".sharelayer").hide();

                            if ($("#status").text() == "已激活去领取") {
                                $("#qrcode").attr("src", "http://tm.lilanz.com/WebBLL/WX2wCodeProject/GetQrCode.aspx?code=" + gametoken);
                                $("#qrcon").show();
                            } else {
                                $("#qrcon").hide();
                                $("#qrcode").attr("src", "");
                            }
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        swal("您的网络不给力,请重试！", "", "error");
                    }
                });
            }
        }

        function jump() {
            window.location.href = "http://tm.lilanz.com/supersalegames/myprizelist.aspx";
        }

        function wxjdk() {
            //以下是微信开发的JS
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: '<%= wxConfig[0] %>', // 必填，公众号的唯一标识
                timestamp: '<%= wxConfig[1] %>', // 必填，生成签名的时间戳
                nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
                signature: '<%= wxConfig[3] %>',// 必填，签名，见附录1
                jsApiList: [
                'onMenuShareTimeline'
                ] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });

            wx.ready(function () {
                // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。
                //alert("JS注入成功！");                                
                var sharelink = "http://tm.lilanz.com/supersalegames/ggkgame.aspx";
                var title = "我在利郎2015福利会游戏中获得了【" + $("#prizedesc").text() + "】，你也快来试试手气吧！";
                //分享到朋友圈
                wx.onMenuShareTimeline({
                    title: title, // 分享标题
                    link: sharelink, // 分享链接
                    imgUrl: 'http://tm.lilanz.com/supersalegames/img/thumb2.jpg', // 分享图标
                    success: function () {
                        // 用户确认分享后执行的回调函数
                        $.ajax({
                            type: "POST",
                            timeout: 5000,
                            contentType: "application/x-www-form-urlencoded; charset=utf-8",
                            url: "ggkProcess.aspx",
                            data: { ctrl: "ActiveGift", gametoken: gametoken, userid: userid, gameid: gameid },
                            success: function (msg) {
                                if (msg == "")
                                    swal({
                                        title: "此游戏券激活成功！",
                                        text: "", type: "success",
                                        confirmButtonColor: "rgb(89, 167, 20)",
                                        showCancelButton: false,
                                        confirmButtonText: "确定",
                                        closeOnConfirm: true
                                    }, function (isConfirm) {
                                        //if (isConfirm) {
                                        //    //window.location.href = "http://tm.lilanz.com/supersalegames/myprizelist.aspx";
                                        //    //分享成功后显示出二维码
                                        //    $("#status").text("已激活可领取");
                                        //    $("#qrcode").attr("src", "http://tm.lilanz.com/WebBLL/WX2wCodeProject/GetQrCode.aspx?code=" + gametoken);
                                        //    $("#qrcon").show();
                                        //}
                                        window.location.reload();
                                    });
                                else
                                    swal({
                                        title: "此游戏券激活失败！",
                                        text: "请稍后重试！", type: "error",
                                        confirmButtonColor: "#DD6B55",
                                        showCancelButton: false,
                                        confirmButtonText: "确定",
                                        closeOnConfirm: true
                                    });
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                swal("您的网络不给力,请重试！", "", "error");
                            }
                        });
                    },
                    cancel: function () {
                        // 用户取消分享后执行的回调函数   

                    }
                });
            });
        }
    </script>
</body>
</html>
