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
        }else if (gametoken == "" || gametoken == null)
        {
            gametoken = "";
        }
        else {
            using (WxHelper wh = new WxHelper())
            {
                wxConfig = wh.GetWXJsApiConfig(appID, appSecret);
            }
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <title>礼券详情</title>
    <link href="css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }
        body {
            font-family:微软雅黑;            
            background: #eeeeee;
            text-shadow:0px 0px 1.5px #ccc;
        }
        .container {
            color: #333;
            background-color:#fff;
            width:94%;
            margin:20px auto;
            overflow:hidden;
            box-shadow:1px 1px 1px #e2e2e2;
            padding:10px 20px 20px 20px;
            box-sizing:border-box;
            border-top:4px solid #ff6a00;
        }
        h2 {
            text-align:center;
            margin-bottom:10px;                       
        }
        .container p {
            height:28px;
            line-height:28px;
            vertical-align:middle;
            overflow:hidden;
            white-space:nowrap;
            text-overflow:ellipsis;
            font-size:1.1em;
        }
        .info {
            color: #333;
            background-color:#fff;
            width:94%;
            margin:20px auto;
            overflow:hidden;
            box-shadow:1px 1px 1px #e2e2e2;
            padding:10px 20px 20px 20px;
            box-sizing:border-box;
            border-top:4px solid #749d4a;
        }
            .info p {
                line-height:26px;
            }
        .btn {
            width:120px;
            padding:10px 10px;
            background:#fff;
            text-align:center;
            margin:0 auto 20px auto;
            border-top:4px solid #749d4a;
            border-bottom:4px solid #749d4a;
        }
            .btn a {
                font-size:1.2em;
                font-weight:bold;
                color:#333;
                text-decoration:none;
            }
        #qrcode {            
            width:200px;
            height:200px;
            margin:10px 0;
        }

        #qrcon {
            text-align:center;  
            display:none;          
        }
        #qrcon p{
            font-weight:bold;
            text-shadow:0px 0px 1px #ccc;
        }

        .sharelayer {
            position:fixed;
            top:0;
            left:0;
            z-index:1000;
            width:100%;
            height:100%;
            background:rgba(0,0,0,.5);
        }
        .shareimg1 {
            position:absolute;
            right:0;
            top:0;
            width:320px;
            height:auto;
        }
        .shareimg2 {
            top:60px;

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
    <div class="container">
        <h2>利郎2015福利会礼券</h2>        
        <p><strong>奖&nbsp;&nbsp;&nbsp;项：</strong><span id="prizename">--</span></p>
        <p><strong>描&nbsp;&nbsp;&nbsp;述：</strong><span id="prizedesc">--</span></p>
        <p><strong>来&nbsp;&nbsp;&nbsp;源：</strong><span id="source">--</span></p>
        <p><strong>获取时间：</strong><span id="gettime">--</span></p>
        <p><strong>有效期：</strong><span id="validtime">--</span></p>
        <p><strong>礼券状态：</strong><span id="status">--</span></p>
    </div>
    <div class="info" id="qrcon">
        <img id="qrcode" src="" alt="" />
        <p>请持本二维码至礼品领取处兑奖</p>
    </div>
    <div class="info">
        <strong>温馨提示：</strong>
        <p>1.单击右上角菜单选择“分享到朋友圈”之后，即可<strong style="color:#f00;">激活成功</strong>！</p>
        <p>2.激活成功后的礼券才能在领奖处兑换礼品！</p>
    </div>
    <div class="btn" onclick="jump()"><a href="#" >我的礼券</a></div>
    <script src="js/jquery.js" type="text/javascript"></script>
    <script src="js/sweet-alert.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
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
                            if ($("#status").text() == "未激活")
                                $(".sharelayer").show();
                            else
                                $(".sharelayer").hide();

                            if ($("#status").text()=="已激活可领取") {
                                $("#qrcode").attr("src", "http://tm.lilanz.com/WebBLL/WX2wCodeProject/GetQrCode.aspx?code=" + gametoken);
                                $("#qrcon").show();
                            }else
                                $("#qrcode").attr("src", "");
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
                var title ="我在利郎2015福利会游戏中获得了【"+$("#prizedesc").text()+"】，你也快来试试手气吧！"; 
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
