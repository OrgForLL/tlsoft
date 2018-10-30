<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public string UID = "", ShareKey = "", UserName = "", GameNums = "", IntroKey = "", wxopenid = "", UTYPE = "";
    private string WXDBConStr = "server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456";
    private List<string> wxConfig = new List<string>();
    protected void Page_Load(object sender, EventArgs e)
    {
        wxConfig.Add(""); wxConfig.Add(""); wxConfig.Add(""); wxConfig.Add("");
        UID = Convert.ToString(Session["QSW_UID"]);
        UTYPE = Convert.ToString(Session["QSW_UTYPE"]);
        IntroKey = Convert.ToString(Request.Params["intro"]);
        string OAuth = Convert.ToString(Request.Params["OAuth"]);
        if (UID == "" || UID == "0" || UID == null)
        {
            //当程序部署在微信环境下带上参数OAuth来区分，自动进行鉴权登陆
            if (OAuth == "WeiXin")
            {
                string gourl = HttpUtility.UrlEncode("http://tm.lilanz.com/project/EasyBusiness/QSWOauthAndRedirect.aspx?rand=" + IntroKey);
                string curURL = HttpUtility.UrlEncode(Request.Url.ToString());
                string OauthURL = @"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx60aada4e94aa0b73&redirect_uri={0}&response_type=code&scope=snsapi_userinfo&state={1}#wechat_redirect";
                OauthURL = string.Format(OauthURL, gourl, curURL);
                Response.Redirect(OauthURL);
                Response.End();
            }
        }
        else
        {
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConStr))
            {
                string str_sql = @"select top 1 a.gamecounts-a.nowcounts gamenums,b.username,a.sharedkey,a.wxopenid 
                                    from wx_t_usergameinfos a
                                    inner join wx_t_userinfo b on b.id=@uid
                                    where a.userid=@uid and a.sskey=7 and a.gameid=1";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@uid", UID));
                DataTable dt = null;
                string errinfo = dal62.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo == "")
                {
                    if (dt.Rows.Count == 0)
                        clsSharedHelper.WriteErrorInfo("加载用户信息失败，请稍后重试！");
                    else
                    {
                        UserName = Convert.ToString(dt.Rows[0]["username"]);
                        ShareKey = Convert.ToString(dt.Rows[0]["sharedkey"]);
                        GameNums = Convert.ToString(dt.Rows[0]["gamenums"]);
                        wxopenid = Convert.ToString(dt.Rows[0]["wxopenid"]);
                    }
                }
                else
                    clsSharedHelper.WriteErrorInfo("加载用户信息失败！" + errinfo);
            }//end using              
        }

        wxConfig = clsWXHelper.GetJsApiConfig("7");
    }
</script>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="format-detection" content="telephone=no" />
    <script>
        (function (f, j) { var i = document, d = window; var b = i.documentElement; var c; var h = i.querySelector('meta[name="viewport"]'); var e = "width=device-width,initial-scale=1,maximum-scale=1.0,user-scalable=no"; if (h) { h.setAttribute("content", e) } else { h = i.createElement("meta"); h.setAttribute("name", "viewport"); h.setAttribute("content", e); if (b.firstElementChild) { b.firstElementChild.appendChild(h) } else { var a = i.createElement("div"); a.appendChild(h); i.write(a.innerHTML) } } function g() { var k = b.getBoundingClientRect().width; if (!j) { j = 540 } if (k > j) { k = j } var l = k * 100 / f; b.style.fontSize = l + "px" } g(); d.addEventListener("resize", function () { clearTimeout(c); c = setTimeout(g, 300) }, false); d.addEventListener("pageshow", function (k) { if (k.persisted) { clearTimeout(c); c = setTimeout(g, 300) } }, false); if (i.readyState === "complete") { i.body.style.fontSize = "16px" } else { i.addEventListener("DOMContentLoaded", function (k) { i.body.style.fontSize = "16px" }, false) } })(640, 640);
    </script>
    <title>庆祝利郎轻商务天津店开业</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        a {
            text-decoration: none;
            color: #fff;
        }

        body {
            background-color: #f67a00;
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
        }

        /*loader css*/
        .loader {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #d1595a;
            z-index: 1002;
            color: #fff;
            text-align: center;
        }

        .slice {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%,-50%);
            -webkit-transform: translate(-50%,-50%);
        }

        [data-loader='circle-side'] {
            position: relative;
            width: 40px;
            height: 40px;
            -webkit-animation: circle infinite .75s linear;
            animation: circle infinite .75s linear;
            border: 4px solid #fff;
            border-top-color: rgba(0, 0, 0, .2);
            border-right-color: rgba(0, 0, 0, .2);
            border-bottom-color: rgba(0, 0, 0, .2);
            border-radius: 100%;
        }

        @-webkit-keyframes circle {
            0% {
                -webkit-transform: rotate(0);
                transform: rotate(0);
            }

            100% {
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        @keyframes circle {
            0% {
                -webkit-transform: rotate(0);
                transform: rotate(0);
            }

            100% {
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        #qsw_qrcode {
            width: 80%;
            margin: 0 auto 10px auto;
        }

            #qsw_qrcode img {
                width: 100%;
            }
    </style>
    <link rel="stylesheet" href="nggkStyle.css" />
    <style type="text/css">
        .gametimes {
            margin-top: 10px;
        }

        #close-btn {
            right: initial;
            left: 10px;
        }

        .remark p {
            line-height: 1.4;
        }

        .header .shake, .gcontainer .header .title {
            top: 0.7rem;
        }

        .login-area {
            text-align: center;
        }

        @-webkit-keyframes tada {
            0% {
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }

            10%,20% {
                -webkit-transform: scale3d(.9,.9,.9) rotate3d(0,0,1,-3deg);
                transform: scale3d(.9,.9,.9) rotate3d(0,0,1,-3deg);
            }

            30%,50%,70%,90% {
                -webkit-transform: scale3d(1.1,1.1,1.1) rotate3d(0,0,1,3deg);
                transform: scale3d(1.1,1.1,1.1) rotate3d(0,0,1,3deg);
            }

            40%,60%,80% {
                -webkit-transform: scale3d(1.1,1.1,1.1) rotate3d(0,0,1,-3deg);
                transform: scale3d(1.1,1.1,1.1) rotate3d(0,0,1,-3deg);
            }

            100% {
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        @keyframes tada {
            0% {
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }

            10%,20% {
                -webkit-transform: scale3d(.9,.9,.9) rotate3d(0,0,1,-3deg);
                transform: scale3d(.9,.9,.9) rotate3d(0,0,1,-3deg);
            }

            30%,50%,70%,90% {
                -webkit-transform: scale3d(1.1,1.1,1.1) rotate3d(0,0,1,3deg);
                transform: scale3d(1.1,1.1,1.1) rotate3d(0,0,1,3deg);
            }

            40%,60%,80% {
                -webkit-transform: scale3d(1.1,1.1,1.1) rotate3d(0,0,1,-3deg);
                transform: scale3d(1.1,1.1,1.1) rotate3d(0,0,1,-3deg);
            }

            100% {
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        .tada {
            -webkit-animation-name: tada;
            animation-name: tada;
        }

        .animated {
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

            .animated.infinite {
                -webkit-animation-iteration-count: infinite;
                animation-iteration-count: infinite;
            }
    </style>
    <script>
        var _hmt = _hmt || [];
        (function () {
            var hm = document.createElement("script");
            hm.src = "//hm.baidu.com/hm.js?a4b8900538688ca16dc65d26e9c141b2";
            var s = document.getElementsByTagName("script")[0];
            s.parentNode.insertBefore(hm, s);
        })();
    </script>
</head>
<body>
    <div class="loader">
        <div class="slice">
            <div data-loader="circle-side"></div>
        </div>
    </div>
    <div class="main-doc">
        <div class="gcontainer">
            <div class="header">
                <img src="../../res/img/EasyBusiness/header2.jpg" alt="" />
                <div class="title">
                    <p class="time"></p>
                </div>
                <div class="shake"></div>
            </div>
            <div class="wrapper">
                <!--用户登陆区-->
                <div class="login-area animated infinite tada">
                    <span id="username">
                        <img src="../../res/img/EasyBusiness/user-icon.png" alt="" />
                        <span>--</span>
                    </span>
                    <a id="WBLogin" href="javascript:;">
                        <img src="../../res/img/EasyBusiness/weibo-icon.png" alt="" />
                        微博登陆
                    </a>
                    <a id="WXLogin" href="javascript:;">
                        <img src="../../res/img/EasyBusiness/weixin-icon.png" alt="" />
                        微信登陆
                    </a>
                    <a href="javascript:LogOut();" id="LogOut" style="display: none;">
                        <img src="../../res/img/EasyBusiness/logout-icon.png" alt="" />
                        登 出
                    </a>
                </div>
                <p class="title">刮 奖 区</p>
                <div style="position: relative;">
                    <img class="glayer" src="../../res/img/EasyBusiness/glayer.png" alt="" />
                    <div class="jlayer" id="scratchpad"><span id="prize-name"></span></div>
                </div>
                <!--<div style="width:5.6rem;margin:10px auto;text-align:right;">
                    <wb:share-button appkey="3836648073" addition="simple" type="button" default_text="庆祝利郎隆重推出【轻商务】系列，这有一大堆丰厚奖品（iPad Air、iPad Mini4等）赶快一起来试试手气吧 ......" pic="http%3A%2F%2Ftm.lilanz.com%2Fres%2Fimg%2FEasyBusiness%2Fqswlogo.jpg"></wb:share-button>
                </div>-->
                <div class="gametimes">亲爱的用户您今天还有 <span id="times">--</span> 次刮奖机会</div>
                <div class="btns">
                    <a class="btn-item" id="again" onclick="javascript:window.location.reload();">再玩一次</a>
                    <a class="btn-item" id="mygift" href="javascript:;" onclick="ShowMyPrizeList();">获奖记录</a>
                    <a class="btn-item" id="share-btn" href="javascript:;" onclick="javascript:ShowShareInfo();">马上分享</a>
                </div>
                <!--奖项设置列表-->
                <div class="wawards">
                    <p class="title">奖项设置</p>
                    <p style="text-align: center; font-size: 0.9em; margin: -10px 0 5px 0;">(单击查看奖品美图)</p>
                    <ul class="awards pl">
                        <li prize="1">
                            <span class="name">特等奖</span>
                            <span class="prize">iPad Air2一台 (共1台) </span>
                            <img src="../../res/img/EasyBusiness/right-icon.png" />
                        </li>
                        <li prize="2">
                            <span class="name">一等奖</span>
                            <span class="prize">iPad mini4一台 (共2台) </span>
                            <img src="../../res/img/EasyBusiness/right-icon.png" />
                        </li>
                        <li prize="3">
                            <span class="name">二等奖</span>
                            <span class="prize">价值439元钱夹一个 (共200个) </span>
                            <img src="../../res/img/EasyBusiness/right-icon.png" />
                        </li>
                        <li prize="4">
                            <span class="name">三等奖</span>
                            <span class="prize">价值339元皮带一条 (共200条) </span>
                            <img src="../../res/img/EasyBusiness/right-icon.png" />
                        </li>
                        <li prize="5">
                            <span class="name">四等奖</span>
                            <span class="prize">价值159元领带一条 (共200条) </span>
                            <img src="../../res/img/EasyBusiness/right-icon.png" />
                        </li>
                        <li>
                            <span class="name">纪念奖</span>
                            <span class="prize">精美袜子一双 (共1000双) </span>
                        </li>
                    </ul>
                </div>
                <!--中奖名单-->
                <div class="wawards">
                    <p class="title">获奖动态</p>
                    <ul class="awards" id="prizer10">
                    </ul>
                </div>
                <!--规则说明-->
                <div class="tips">
                    <p class="title">规则说明</p>
                    <div class="remark">
                        <p>1、本次活动有效期：2016年9月1日至2016年9月29日；本次活动主要针对天津地区用户；</p>
                        <p>2、活动期间各个奖项奖品数量有限，领完即止；</p>
                        <p><strong>3、中奖者请于16年9月30日至10月9日期间，关注利郎轻商务公众号后，本人凭【我要领奖】菜单中的二维码到店（天津市和平区滨江道143号光明影院一楼）领取（二维码截图无效），逾期未领奖者将当成自动放弃中奖资格；</strong></p>
                        <p><strong>4、增加游戏次数方法：如果您是使用微信身份登陆，您可以点击右上角'…'图标，选择【发送给朋友】、【分享到朋友圈】、【分享到手机QQ】、【分享到QQ空间】即可获取游戏机会，每天四次。同时您也可以登陆后单击页面上【我要分享】按钮，让你的好友扫描，当有新用户通过您分享的链接玩游戏时，每吸引到一个新用户您都会增加一次游戏次数；</strong></p>
                        <p>5、店铺地址：天津市和平区滨江道143号光明影院一楼。如有疑问请咨询：022-83219627；</p>
                        <p>6、您可以微信搜索【利郎轻商务】公众号，关注后可第一时间获取最新资讯及游戏相关动态；</p>
                        <p>7、奖品图片仅供参考，具体请以实物为准；</p>
                        <p><strong>8.本活动最终解释权归利郎（中国）有限公司所有！</strong></p>
                    </div>
                </div>
                <div class="activity" onclick="javascript:window.location.href='EasyBusinessMap.aspx';">
                    <p class="title">店铺地址</p>
                    <p style="text-align: center; font-size: 0.9em; margin: -10px 0 5px 0;">(单击可进行导航)</p>
                    <div class="remark">
                        <p style="text-align: center;">
                            <img style="width: 90%; height: auto; margin-left: 3%;" src="../../res/img/EasyBusiness/storeaddr.jpg" />
                        </p>
                        <p style="margin-top: 8px; font-size: 14px; font-weight: bold; text-align: center;">地址：天津市和平区滨江道143号光明影院一楼</p>
                    </div>
                </div>
                <div class="activity">
                    <p class="title">扫码获取最新动态</p>
                    <div class="remark">
                        <p style="text-align: center;">
                            <img style="text-align: center; width: 60%; height: auto; margin-left: 3%;" src="../../res/img/EasyBusiness/qswcode.jpg" />
                        </p>
                        <p style="margin-top: 8px; font-size: 14px; font-weight: bold; text-align: center;">您可以扫描上方二维码关注【利郎轻商务】公众号，获取更多精彩资讯！</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="mask"></div>
    <div id="pdialog">
        <div id="getprize">
            <p class="title">--</p>
            <a href="javascript:;" id="getnow" onclick="javascript:ShowMyPrizeList();">马上领取</a>
            <a href="javascript:;" class="play-again" onclick="javascript:window.location.reload();">再玩一次</a>
        </div>
    </div>
    <!--提示层-->
    <div id="message">
        <div id="message-content">
            <p class="title">--</p>
            <p id="qsw_qrcode">
                <img src="../../res/img/EasyBusiness/qswcode.jpg" alt="" />
            </p>
            <p id="share-qrcode">
                <img src="" alt="" />
            </p>
            <a href="javascript:;" class="play-again" onclick="javascript:$('.mask').hide();$('#message').hide();">关 闭</a>
        </div>
    </div>

    <!--奖品展示页-->
    <div class="showprize" style="display: none;">
        <div id="close-btn">关闭</div>
        <ul class="pirze-list" id="prize1" style="display: none;">
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p1-1.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p1-2.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p1-3.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p1-4.jpg" alt="" />
            </li>
        </ul>
        <ul class="pirze-list" id="prize2" style="display: none;">
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p2-1.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p2-2.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p2-3.jpg" alt="" />
            </li>
        </ul>
        <ul class="pirze-list" id="prize3" style="display: none;">
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p3-1.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p3-2.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p3-3.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p3-4.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p3-5.jpg" alt="" />
            </li>
        </ul>
        <ul class="pirze-list" id="prize4" style="display: none;">
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p4-1.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p4-2.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p4-3.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p4-4.jpg" alt="" />
            </li>
        </ul>
        <ul class="pirze-list" id="prize5" style="display: none;">
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p5-1.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p5-2.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p5-3.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p5-4.jpg" alt="" />
            </li>
            <li class="prize-item">
                <img source="../../res/img/EasyBusiness/p5-5.jpg" alt="" />
            </li>
        </ul>
    </div>

    <script src="../../res/js/jquery.js" type="text/javascript"></script>
    <script src="../../res/js/EasyBusiness/wScratchPad.js" type="text/javascript"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type='text/javascript' src='../../res/js/EasyBusiness/fastclick.min.js'></script>
    <script type="text/javascript">
        var UID = "<%=UID%>", UTYPE = "<%=UTYPE%>", SharedKey = "<%=ShareKey%>", UserName = "<%=UserName%>", GameNums = "<%=GameNums%>", Intro = "<%=IntroKey%>";
        var gameid = "1", GameToken = "", prizeID = ""; prizeName = "", goon = true, isShow = false, isConsume = false;
        //WXJSAPI 参数        
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        window.onload = function () {
            FastClick.attach(document.body);
            var ua = window.navigator.userAgent.toLowerCase();
            if (UID == "" || typeof (UID) == "undefined") {
                $("#username").hide();
                $(".loader").fadeOut(500);
                if (ua.match(/MicroMessenger/i) == 'micromessenger' && window.location.href.indexOf("?OAuth=WeiXin") == -1 && window.location.href.indexOf("&OAuth=WeiXin") == -1 && confirm("检测到您是在微信中打开此游戏，是否直接使用微信身份登陆？")) {
                    window.location.href = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx60aada4e94aa0b73&redirect_uri=http://tm.lilanz.com/project/EasyBusiness/QSWOauthAndRedirect.aspx?rand=" + Intro + "&response_type=code&scope=snsapi_userinfo&state=" + window.location.href + "#wechat_redirect";
                    return;
                }
                //setTimeout(function () { alert("请先登陆！"); }, 500);
            } else {
                //alert(UTYPE);
                $("#username>span").text(UserName);
                $("#times").text(GameNums);
                $("#WXLogin").hide();
                $("#WBLogin").hide();
                $("#LogOut").show();
                $(".login-area").removeClass("tada");
                canplay();
            }

            GetWXJSApi();
            LoadPrizer10();
            $("#WXLogin").attr("href", "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx60aada4e94aa0b73&redirect_uri=http://tm.lilanz.com/project/EasyBusiness/QSWOauthAndRedirect.aspx?rand=" + Intro + "&response_type=code&scope=snsapi_userinfo&state=" + window.location.href + "#wechat_redirect");
            $("#WBLogin").attr("href", "https://api.weibo.com/oauth2/authorize?client_id=3836648073&redirect_uri=http://tm.lilanz.com/project/EasyBusiness/WeiBoOAuth.aspx?intro=" + Intro + "&response_type=code");
        }

        $(".awards.pl li").click(function () {
            var prizeid = $(this).attr("prize");
            if (prizeid == undefined || "") {
                alert("图片整理中...");
                return;
            }

            var prizeImgs = $("#prize" + prizeid + " li");
            for (var i = 0; i < prizeImgs.length; i++) {
                $("img", prizeImgs[i]).attr("src", $("img", prizeImgs[i]).attr("source"));
            }
            $("#prize" + prizeid).show();
            $(".showprize").fadeIn(250);
        });

        $("#close-btn").click(function () {
            $(".showprize").hide();
            $(".showprize ul").hide();
        });

        //登出
        function LogOut() {
            $(".mask").show();
            $.ajax({
                type: "POST",
                timeout: 4000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "nggkProcess.aspx",
                data: { ctrl: "LogOut" },
                success: function (msg) {
                    if (msg == "Successed")
                        window.location.href = "nggkGame.aspx";
                    else if (msg.indexOf("越权访问") > -1)
                        window.location.reload();
                    else
                        alert(msg);
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });
        }

        function GetQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            var r = window.location.search.substr(1).match(reg);
            if (r != null)
                return unescape(r[2]);
            else
                return "";
        }

        //向URL添加参数
        function addUrlPara(name, value) {
            var currentUrl = window.location.href.split('#')[0];
            if (/\?/g.test(currentUrl)) {
                if (/name=[-\w]{4,25}/g.test(currentUrl)) {
                    currentUrl = currentUrl.replace(/name=[-\w]{4,25}/g, name + "=" + value);
                } else {
                    currentUrl += "&" + name + "=" + value;
                }
            } else {
                currentUrl += "?" + name + "=" + value;
            }
            if (window.location.href.split('#')[1]) {
                window.location.href = currentUrl + '#' + window.location.href.split('#')[1];
            } else {
                window.location.href = currentUrl;
            }
        }

        //判断用户是否能玩
        function canplay() {
            $.ajax({
                type: "POST",
                timeout: 10000,
                async: true,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "nggkProcess.aspx",
                data: { ctrl: "IsCanPlay", gameid: gameid, userid: UID },
                success: function (msg) {
                    if (msg.indexOf("Successed:") > -1) {
                        msg = msg.replace("Successed:", "");
                        var arr = msg.split("|");
                        GameToken = arr[0];
                        prizeID = arr[1];
                        prizeName = arr[2];
                        $("#prize-name").text(prizeName);
                        //添加刮层效果
                        $("#scratchpad").wScratchPad({
                            size: 24,//擦除的半径大小
                            width: $("#scratchpad").width(),
                            height: $("#scratchpad").height(),
                            color: "#a9a9a7",
                            scratchMove: function (e, percent) {
                                if (percent > 0 && goon) {
                                    $("#prize-name").text(prizeName);
                                    goon = false;
                                    ConsumeToken();
                                }
                                if (percent > 40 && isConsume && prizeID != "0" && !isShow) {
                                    isShow = true;
                                    $("#getprize .title").text("恭喜您中了【" + prizeName + "】");
                                    $(".mask").show();
                                    $("#pdialog").show();
                                    return;
                                }
                            }
                        });
                        //准备好游戏数据
                        $(".loader").fadeOut(500);
                    } else if (msg.indexOf("Warn:") > -1)
                        //没有游戏次数了
                        EarnGameTimes();
                    else if (msg.indexOf("越权访问") > -1)
                        window.location.reload();
                    else
                        alert(msg);
                    $(".loader").fadeOut(500);
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("您的网络不给力,此次游戏数据失败！");
                }
            });
        }

        //获奖记录
        function MyPrizeList() {
            var openid = "<%=wxopenid%>";
            //if (openid != "" && openid != undefined && openid != null) {
            //    window.location.href = "nMyPrizeList.aspx";
            //} else {
            //    $("#message-content .title").text("请您关注【利郎轻商务】公众号后点击菜单【我的礼券】进行查看！");
            //    $("#share-qrcode").hide();
            //    $(".mask").hide();
            //    $("#message").show();
            //}

            $("#message-content .title").text("请您关注【利郎轻商务】公众号后点击菜单【我要领奖】进行查看！");
            $("#share-qrcode").hide();
            $(".mask").hide();
            $("#qsw_qrcode").show();
            $("#message").show();
        }

        //赚取游戏次数机会
        function EarnGameTimes() {
            $("#message-content .title").text("如果您是使用微信身份登陆，您可以点击右上角'…'图标，选择【发送给朋友】、【分享到朋友圈】、【分享到手机QQ】、【分享到QQ空间】即可获取游戏机会，一天最多四次。同时您也可以单击页面上【马上分享】按钮，让你的好友扫描，当有新用户通过您分享的链接玩游戏时，您将会获得游戏机会！");
            $("#share-qrcode").hide();
            $(".mask").hide();
            $("#message").show();
        }

        function ShowShareInfo() {
            var imgsrc = "";
            if (UID == "" || UID == undefined)
                imgsrc = "http://tm.lilanz.com/project/EasyBusiness/nggkGame.aspx";
            else
                imgsrc = "http://tm.lilanz.com/project/EasyBusiness/nggkGame.aspx?intro=" + SharedKey;
            $("#message-content .title").text("使用微博或微信登陆后，分享下方二维码给你的好友，赚取更多游戏机会！");
            $("#share-qrcode > img").attr("src", "http://tm.lilanz.com/WebBLL/WX2wCodeProject/GetQrCode.aspx?code=" + imgsrc);
            $("#share-qrcode").show();
            $("#qsw_qrcode").hide();
            $(".mask").hide();
            $("#message").show();
        }

        //消费游戏token方法
        function ConsumeToken() {
            $.ajax({
                type: "POST",
                timeout: 10000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "nggkProcess.aspx",
                data: { ctrl: "ConsumeGameToken", gametoken: GameToken, userid: UID, gameid: gameid },
                success: function (msg) {
                    if (msg.indexOf("Successed") > -1) {
                        //消费成功后打上成功标识才弹出提示
                        $("#times").text($("#times").text() - 1);
                        isConsume = true;
                    } else if (msg.indexOf("越权访问") > -1) {
                        window.location.reload();
                    }
                    else {
                        alert(msg);
                        return;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    isConsume = false;
                    alert("您的网络不给力,此次游戏数据失败！");
                }
            });
        }

        function GetWXJSApi() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['onMenuShareTimeline', 'onMenuShareQQ', 'onMenuShareAppMessage', 'onMenuShareQZone'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                var sharelink = "http://tm.lilanz.com/project/EasyBusiness/nggkGame.aspx?intro=" + SharedKey;
                var title = "庆祝利郎轻商务天津店隆重开业，一起来刮大奖吧！";
                //分享到朋友圈
                wx.onMenuShareTimeline({
                    title: title, // 分享标题
                    link: sharelink, // 分享链接
                    imgUrl: 'http://tm.lilanz.com/res/img/EasyBusiness/qswlogo.jpg', // 分享图标
                    success: function () {
                        // 用户确认分享后执行的回调函数
                        ShareFunc("1");
                    },
                    cancel: function () {
                        // 用户取消分享后执行的回调函数
                    }
                });
                //分享给QQ好友
                wx.onMenuShareQQ({
                    title: title, // 分享标题                    
                    link: sharelink, // 分享链接
                    imgUrl: 'http://tm.lilanz.com/res/img/EasyBusiness/qswlogo.jpg', // 分享图标
                    success: function () {
                        // 用户确认分享后执行的回调函数
                        ShareFunc("2");
                    },
                    cancel: function () {
                        // 用户取消分享后执行的回调函数
                    }
                });
                //分享给朋友
                wx.onMenuShareAppMessage({
                    title: title, // 分享标题                    
                    link: sharelink, // 分享链接
                    imgUrl: 'http://tm.lilanz.com/res/img/EasyBusiness/qswlogo.jpg', // 分享图标
                    type: 'link', // 分享类型,music、video或link，不填默认为link
                    dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                    success: function () {
                        // 用户确认分享后执行的回调函数
                        ShareFunc("0");
                    },
                    cancel: function () {
                        // 用户取消分享后执行的回调函数
                    }
                });
                //分享到QQ空间
                wx.onMenuShareQZone({
                    title: title, // 分享标题                    
                    link: sharelink, // 分享链接
                    imgUrl: 'http://tm.lilanz.com/res/img/EasyBusiness/qswlogo.jpg', // 分享图标
                    success: function () {
                        // 用户确认分享后执行的回调函数
                        ShareFunc("3");
                    },
                    cancel: function () {
                        // 用户取消分享后执行的回调函数
                    }
                });
            });
            wx.error(function (res) {
                //alert("JS注入失败！"+signatureVal);
            });
        }

        //分享回调函数
        function ShareFunc(sharedtype) {
            $.ajax({
                type: "POST",
                timeout: 10000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "nggkProcess.aspx",
                data: { ctrl: "ShareTo", sharedtype: sharedtype },
                success: function (msg) {
                    if (msg.indexOf("Successed") > -1) {
                        alert("分享成功！");
                    } else if (msg.indexOf("越权访问") > -1) {
                        //未登陆情况下
                        alert("对不起，您必须先登陆后分享才能赚取游戏次数！");
                        window.location.reload();
                    }
                    else {
                        alert(msg);
                        return;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    //isConsume = false;
                    alert("您的网络不给力,此次游戏数据失败！");
                }
            });
        }

        //取获奖名单
        function LoadPrizer10() {
            var liTemp = "<li><span class='name'>#username#</span><span class='prize'>#prizename#</span><span class='phone'>#time#</span></li>";
            $.ajax({
                type: "POST",
                timeout: 4000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "nggkProcess.aspx",
                data: { ctrl: "Prizer10" },
                success: function (msg) {
                    if (msg.indexOf("Error:") == -1 && msg != "") {
                        var htmlStr = "";
                        var obj = JSON.parse(msg);
                        $.each(obj.rows, function (j, el) {
                            htmlStr += liTemp.temp(el);
                        });

                        $("#prizer10").empty().append(htmlStr);
                    } else if (msg.indexOf("越权访问") > -1)
                        window.location.reload();
                    //else
                    //    alert("加载最新中奖者名单失败 " + msg);
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });
        }

        String.prototype.temp = function (obj) {
            return this.replace(/\#\w+\#/gi, function (matchs) {
                var returns = obj[matchs.replace(/\#/g, "")];
                return (returns + "") == undefined ? "" : returns;
            });
        }

        //查询获奖记录
        function ShowMyPrizeList() {
            if (UID == "" || UID == undefined || UID == "0") {
                alert("请先使用微信或新浪微博账号登陆！");
            } else {
                //window.location.href = "nMyPrizeList.aspx";
                if (UTYPE == "WeiBo")
                    window.location.href = "nMyPrizeList.aspx";
                else
                    MyPrizeList();
            }
        }
    </script>
</body>
</html>

