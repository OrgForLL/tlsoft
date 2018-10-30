<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>

<!DOCTYPE html>
<script runat="server"> 
    private string ConfigKeyValue = "7", ObjectID = "4", GameID = "6";//LILANZ利郎商务男装
    private List<string> wxConfig = new List<string>();//微信JS-SDK
    private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private string OAConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";

    public string openid = "", wxid = "", gamecounts = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);

            using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(OAConnStr))
            {
                string str_sql = @"select top 1 id,wxnick,wxheadimgurl headimg from wx_t_vipbinging where objectid=@objectid and wxopenid=@openid;";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@objectid", ObjectID));
                paras.Add(new SqlParameter("@openid", openid));
                DataTable dt;
                string errinfo = dal10.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        wxid = Convert.ToString(dt.Rows[0][0]);
                        string username = Convert.ToString(dt.Rows[0][1]);
                        string headimg = Convert.ToString(dt.Rows[0][2]);
                        dt.Clear(); dt.Dispose();

                        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr))
                        {
                            str_sql = @"if not exists(select top 1 1 from tm_t_TurnTable where wxid=@wxid and sskey=@configkey)
                                          insert into tm_t_TurnTable(wxid,gameid,gamecounts,usedcounts,sskey,originfrom)
                                          values(@wxid,@gameid,3,0,@configkey,'2017Valentine');
                                        select top 1 gamecounts-usedcounts from tm_t_TurnTable where wxid=@wxid and sskey=@configkey";
                            paras.Clear();
                            paras.Add(new SqlParameter("@wxid", wxid));
                            paras.Add(new SqlParameter("@gameid", GameID));
                            paras.Add(new SqlParameter("@configkey", ConfigKeyValue));
                            object scalar;
                            errinfo = dal62.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                            if (errinfo != "")
                                clsSharedHelper.WriteErrorInfo(errinfo);
                            else
                            {
                                Session["wxid"] = wxid;
                                gamecounts = Convert.ToString(scalar);
                                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
                            }
                        }//end using 62                                                
                    }
                    else
                        clsSharedHelper.WriteErrorInfo("读取不到您的用户信息！");
                }
                else
                    clsSharedHelper.WriteErrorInfo(errinfo);
            }//end using 10    
        }
    }    
</script>
<html>
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta content="yes" name="apple-mobile-web-app-capable">
    <meta content="yes" name="apple-touch-fullscreen">
    <meta content="telephone=no,email=no" name="format-detection">
    <script src="http://g.tbcdn.cn/mtb/lib-flexible/0.3.4/??flexible_css.js,flexible.js"></script>
    <link type="text/css" rel="stylesheet" href="css/swiper.min.css" />
    <link type="text/css" rel="stylesheet" href="css/animate.min.css" />
    <title>2017这一刻去爱吧</title>
    <script type="text/javascript" src="js/resLoader.js"></script>
    <script>
        var _hmt = _hmt || [];
        (function () {
            var hm = document.createElement("script");
            hm.src = "https://hm.baidu.com/hm.js?f274c2a4c37455fe3bba3b7477d74d26";
            var s = document.getElementsByTagName("script")[0];
            s.parentNode.insertBefore(hm, s);
        })();
    </script>
    <style>
        #resLoaderMask {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #fff;
            z-index: 9999;
        }

        .center-translate {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%,-50%);
            -webkit-transform: translate(-50%,-50%);
        }

        .load_heart {
            width: 2rem;
        }

        .load_txt {
            letter-spacing: 1px;
            color: #e72265;
            font-size: 0.24rem;
            margin-top: 0.26rem;
        }
    </style>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        html, body {
            height: 100%;
        }

        body {
            overflow-x: hidden;
            max-width: 12rem;
            margin: 0 auto;
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
        }

        .container, .swiper-container, .swiper-slide {
            width: 100%;
            height: 100%;
            position: relative;
            overflow: hidden;
        }

        #spage1 {
            background-image: url(img/00.jpg);
            /*background-position:center center;*/
            background-size: cover;
            background-repeat: no-repeat;
        }

        #spage2, #spage3 {
            background-image: url(img/10.jpg);
            background-size: cover;
            background-repeat: no-repeat;
            text-align: center;
        }

        .swiper-pagination-bullet-active {
            background: #eb2020;
        }

        .p0_heart {
            width: 4.533rem;
            /*position: absolute;
            top: 2.16rem;
            left: 2.667rem;*/
        }

        .p0_title0 {
            width: 8.213rem;
            /*position: absolute;
            top: 6.8rem;
            left: 1.013rem;*/
        }

        .p0_title1 {
            width: 6.8rem;
            /*position: absolute;
            top: 8.67rem;
            left: 1.787rem;*/
        }

        .join_btn {
            width: 1.48rem;
            position: absolute;
            left: 50%;
            margin-left: -0.74rem;
            top: 11.2rem;
            text-align: center;
        }

        .p0_dot1, .p0_dot2 {
            display: block;
            margin: 0 auto;
            width: 0.267rem;
        }

        .p0_dot2 {
            margin-top: 0.267rem;
        }

        .p0_jbtn {
            width: 1.48rem;
            margin-top: 0.467rem;
        }

        .logo {
            width: 1.267rem;
            position: absolute;
            top: 0;
            right: 0.26rem;
            z-index: 2000;
        }

        .flower_container {
            margin: 0.733rem auto 0.373rem auto;
            text-align: center;
        }

        .flower.f0 {
            width: 3.12rem;
            position: relative;
            top: 0;
            left: 0.8rem;
        }

        .flower.f1 {
            width: 1.467rem;
            position: relative;
            top: 0;
        }

        .flower.f2 {
            width: 2.747rem;
            position: relative;
            right: 1.1rem;
            top: 0.1rem;
        }

        .f0.selected {
            top: -0.6rem;
            transition: 0.4s ease-out;
        }

        .f1.selected {
            top: -0.5rem;
            transition: 0.4s ease-out;
        }

        .f2.selected {
            top: -0.5rem;
            transition: 0.4s ease-out;
        }

        .game_rule {
            width: 4.28rem;
            margin-bottom: 0.2rem;
        }

        .prie_pic {
            width: 8.16rem;
        }

        .prize_list {
            width: 8.16rem;
            margin: 0 auto;
        }

            .prize_list > p {
                color: #e72265;
                text-align: left;
                font-size: 0.38rem;
                line-height: 1.6;
                font-weight: bold;
            }

            .prize_list .title {
                font-size: 0.42rem;
                margin-bottom: 0.13rem;
            }

        .bgm_btn {
            width: 0.8rem;
            height: 0.8rem;
            background-repeat: no-repeat;
            background-image: url(img/bgm_icon.png);
            background-size: cover;
            background-position: 0 0;
            position: fixed;
            top: 0.26rem;
            left: 0.4rem;
            z-index: 100;
        }

            .bgm_btn.animation {
                -webkit-animation: myrotate 5s linear 0s infinite normal;
            }

            .bgm_btn.stop {
                background-position: 0 -0.8rem;
            }

        @-webkit-keyframes myrotate /*Safari and Chrome*/
        {
            0% {
                -webkit-transform: rotate(0deg);
            }

            25% {
                -webkit-transform: rotate(-90deg);
            }

            50% {
                -webkit-transform: rotate(-180deg);
            }

            75% {
                -webkit-transform: rotate(-270deg);
            }

            100% {
                -webkit-transform: rotate(-360deg);
            }
        }

        #tip {
            color: red;
            font-size: 0.34rem;
            letter-spacing: 2px;
            font-weight: bold;
            margin-bottom: 0.2rem;
            visibility: hidden;
        }

        .hot {
            display: block;
            background-color: transparent;
            position: absolute;
        }

            .hot.f0 {
                top: 1.16rem;
                left: 2rem;
                width: 2.5rem;
                height: 4.8rem;
            }

            .hot.f1 {
                top: 0.8rem;
                left: 4.453rem;
                width: 1.347rem;
                height: 5.8rem;
            }

            .hot.f2 {
                top: 1.38rem;
                left: 5.7rem;
                width: 1.9rem;
                height: 4rem;
            }

        /*messagemask style*/
        .message_mask {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 5001;
            color: #fff;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: rgba(0,0,0,.4);
            display: none;
        }

        .message_wrap {
            width: 80%;
            background-color: rgba(255,255,255,0.94);
            border-radius: 0.1rem;
            text-align: center;
            font-size: 0.42rem;
            position: relative;
        }

        .message_head {
            border-top-left-radius: 0.1rem;
            border-top-right-radius: 0.1rem;
            background-color: #e5004f;
            color: #fff;
            text-align: center;
            padding: 0.13rem 0;
        }

        #message {
            width: 100%;
            max-height: 4.62rem;
            color: #333;
            padding: 0.32rem;
            font-size: 0.38rem;
            text-align: left;
            line-height: 1.4;
            overflow: hidden;
            box-sizing: border-box;
            z-index: 101;
            position: relative;
            background: #fff;
            border-bottom-left-radius: 0.1rem;
            border-bottom-right-radius: 0.1rem;
        }

        .message_btn {
            font-size: 0;
            height: 1rem;
            line-height: 1rem;
            border-top: 0.013rem solid #ddd;
            font-weight: bold;
            white-space: nowrap;
        }

            .message_btn > a {
                color: #333;
                width: 50%;
                display: none;
                text-align: center;
                font-size: 0.36rem;
                text-decoration: none;
            }

        .f_icon {
            position: absolute;
            width: 2rem;
            top: -1rem;
            right: 0;
            z-index: 100;
        }

        #cancle {
            color: #999;
            border-right: 0.013rem solid #ddd;
        }

        .btn_wrap {
            display: flex;
            flex-direction: column;
            justify-content: space-around;
            height: 60%;
            margin-top: 30%;
        }

            .btn_wrap > a {
                display: block;
                background-color: rgba(255,255,255,.6);
                border-radius: 4px;
                height: 2.2rem;
                line-height: 2.2rem;
                text-align: center;
                width: 90%;
                margin: 0 auto;
                box-shadow:0px 3px 0 #f2b1c5;
            }

        #spage3 .btn1, #spage3 .btn2 {
            width: 4.957rem;
            vertical-align: middle;
        }

        .copyright {
            position: absolute;
            left: 0;
            width: 100%;
            bottom: 0;
            line-height: 0.62rem;
            text-align: center;
            color: #d06076;
            font-weight: bold;
        }

        .no_awards {
            position: fixed;
            z-index: 2500;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #000;
            display: none;
        }

            .no_awards > img {
                width: 100%;
            }

        .gametimes {
            color: #e72265;
            position: absolute;
            top: 0.24rem;
            right: 0.24rem;
            font-size: 0.34rem;
        }

        .no_awards .btn_close {
            position: absolute;
            top: 0.24rem;
            right: 0.28rem;
            width: 1.1rem;
        }
    </style>
    <style>
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

        @-webkit-keyframes heartbeat {
            0% {
                -webkit-transform: scale(0.9);
            }

            9% {
                -webkit-transform: scale(1.2);
            }

            18% {
                -webkit-transform: scale(0.9);
            }

            25% {
                -webkit-transform: scale(1);
            }

            100% {
                -webkit-transform: scale(1);
            }
        }

        @keyframes heartbeat {
            0% {
                transform: scale(0.9);
            }

            9% {
                transform: scale(1.2);
            }

            18% {
                transform: scale(0.9);
            }

            25% {
                transform: scale(1);
            }

            100% {
                transform: scale(1);
            }
        }

        .heartbeat {
            -webkit-animation: heartbeat ease-in-out 0.8s infinite alternate;
            animation: heartbeat ease-in-out 0.8s infinite alternate;
        }
    </style>
</head>
<body>
    <!--加载提示层-->
    <div id="resLoaderMask">
        <img class="logo" src="img/qswlogo.jpg" />
        <div class="center-translate" style="text-align: center;">
            <img class="load_heart heartbeat" src="img/heart0.png" />
            <p class="load_txt">正在加载资源（<span id="res_current"></span> / <span id="res_total"></span>）</p>
        </div>
    </div>

    <script type="text/javascript">
        var naArr = ["na00", "na01", "na02", "na03", "na04", "na05", "na06", "na07", "na08", "na09", "na10", "na11", "na12"];
        var naPic = "img/" + naArr[Math.floor((Math.random() * naArr.length))] + ".jpg";
        var loader = new resLoader({
            resources: ["img/00.jpg", "img/10.jpg", "img/btn1.png", "img/btn2.png",
                "img/flower_icon.png",
                "img/flower0_0.png",
                "img/flower0_1.png",
                "img/flower1_0.png",
                "img/flower1_1.png",
                "img/flower2_0.png",
                "img/flower2_1.png",
                "img/heart0.png",
                "img/jointxt.png",
                "img/prize_pic.png",
                "img/qswlogo.jpg",
                "img/title.png",
                "img/title0.png",
                "img/title1.png",
                "img/txts.png", naPic],
            onStart: function (total) {
                document.getElementById("res_total").textContent = total;
            },
            onProgress: function (current, total) {
                document.getElementById("res_current").textContent = current;
            },
            onComplete: function (total) {
                $(".sentence").attr("src", naPic);
            }
        });

        loader.start();
    </script>

    <div class="container">
        <div class="swiper-container">
            <div class="bgm_btn animation"></div>
            <div class="swiper-wrapper">
                <div class="swiper-slide" id="spage1">
                    <img class="logo" src="img/qswlogo.jpg" />
                    <div style="position: absolute; top: 2.16rem; width: 100%; text-align: center;">
                        <img class="p0_heart ani" swiper-animate-effect="bounceInUp" swiper-animate-duration="0.8s" swiper-animate-delay="0.2s" src="img/heart0.png" />
                    </div>
                    <div style="position: absolute; top: 6.8rem; width: 100%; text-align: center;">
                        <img class="p0_title0 ani" swiper-animate-effect="bounceInUp" swiper-animate-duration="1s" swiper-animate-delay="0.4s" src="img/title0.png" />
                    </div>
                    <div style="position: absolute; top: 8.67rem; width: 100%; text-align: center;">
                        <img class="p0_title1 ani" swiper-animate-effect="bounceInUp" swiper-animate-duration="1s" swiper-animate-delay="0.6s" src="img/title1.png" />
                    </div>
                    <div class="join_btn ani" swiper-animate-effect="flipInX" swiper-animate-duration="1.5s" swiper-animate-delay="1.4s">
                        <img class="p0_dot1" src="img/dot.png" />
                        <img class="p0_dot2" src="img/dot.png" />
                        <img class="p0_jbtn" src="img/jointxt.png" />
                    </div>
                </div>
                <div class="swiper-slide" id="spage2">
                    <p class="gametimes">您还有 <span style="font-weight: bold; color: red;"><%=gamecounts %></span> 次抽取机会</p>
                    <div class="flower_container">
                        <img class="flower f0 ani" swiper-animate-effect="bounceIn" swiper-animate-duration="0.8s" swiper-animate-delay="0.2s" src="img/flower0_0.png" />
                        <img class="flower f1 ani" swiper-animate-effect="bounceIn" swiper-animate-duration="0.8s" swiper-animate-delay="0.4s" src="img/flower1_0.png" />
                        <img class="flower f2 ani" swiper-animate-effect="bounceIn" swiper-animate-duration="0.8s" swiper-animate-delay="0.6s" src="img/flower2_0.png" />
                        <a href="javascript:" class="hot f0" data-area="f0"></a>
                        <a href="javascript:" class="hot f1" data-area="f1"></a>
                        <a href="javascript:" class="hot f2" data-area="f2"></a>
                    </div>
                    <p id="tip" class="animated infinite tada">- 点击花束抽取 -</p>
                    <img class="game_rule ani" src="img/txts.png" swiper-animate-effect="fadeInUp" swiper-animate-duration="1s" swiper-animate-delay="1.2s" />
                    <div class="prize_list ani" swiper-animate-effect="fadeInUp" swiper-animate-duration="1s" swiper-animate-delay="1.4s">
                        <p class="title">【活动奖品】</p>
                        <img class="prie_pic" src="img/prize_pic.png" />
                        <p>领取时间：2017年2月13日-2月28日</p>
                        <p>领礼地址：所在地利郎轻商务门店领取即可（配饰品不参与活动）</p>
                    </div>
                </div>
                <div class="swiper-slide" id="spage3">
                    <img class="logo" src="img/qswlogo.jpg" />
                    <div class="btn_wrap">
                        <a href="http://tm.lilanz.com/project/easybusiness/storelists.aspx">
                            <img class="btn1" src="img/btn1.png" />
                        </a>
                        <a href="newMyPrizes.aspx">
                            <img class="btn2" src="img/btn2.png" />
                        </a>
                    </div>
                    <p class="copyright">&copy;2017 利郎信息技术部</p>
                </div>
            </div>
            <!-- 分页器 -->
            <div class="swiper-pagination"></div>
        </div>
    </div>
    <!--未中奖提示语-->
    <div class="no_awards">
        <img class="sentence" src="img/na00.jpg" />
        <img class="btn_close" src="img/close_icon.png" onclick="javascript:closeSentence();" />
    </div>
    <!--提示层-->
    <div class="message_mask">
        <div class="message_wrap">
            <div class="message_head">系统提示</div>
            <p class="text" id="message">--</p>
            <div class="message_btn">
                <a href="javascript:" id="cancle">取 消</a>
                <a href="javascript:" id="confirm">确 定</a>
            </div>
            <img class="f_icon" src="img/flower_icon.png" />
        </div>
    </div>

    <!--背景音乐-->
    <div id="bgsound_wrap" style="display: none;">
        <audio id="bgmusic" loop="loop" src="bgsound.mp3"></audio>
    </div>

    <script type="text/javascript" src="js/jquery.js"></script>
    <script type="text/javascript" src="js/swiper-3.4.0.jquery.min.js"></script>
    <script type="text/javascript" src="js/swiper.animate.min.js"></script>
    <script type="text/javascript" src="js/fastclick.min.js"></script>
    <script src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript">
        var wxid = "<%=wxid%>", openid = "<%=openid%>", gamecounts = parseInt("<%=gamecounts%>");
        var gametoken = "", prizeid = "", prizename = "";
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        document.addEventListener("WeixinJSBridgeReady", function () {
            document.getElementById("bgmusic").play();
        }, false);

        $(document).ready(function () {
            var mySwiper = new Swiper('.swiper-container', {
                direction: 'vertical',
                loop: false,
                // 如果需要分页器
                pagination: '.swiper-pagination',
                onInit: function (swiper) {
                    swiperAnimateCache(swiper);
                    swiperAnimate(swiper);
                },
                onSlideChangeEnd: function (swiper) {
                    swiperAnimateCache(swiper);
                    swiperAnimate(swiper);
                    if ($(".flower.f0").hasClass("ani"))
                        $("#tip").css("visibility", "hidden");
                }
            })

            BindEvents();
            FastClick.attach(document.body);
            GetWXJSApi();
        });

        window.onload = function () {
            setTimeout(function () {
                document.getElementById("resLoaderMask").style.display = "none";
            }, 100);
            initData();
        }

        var hasChoose = false, isPlaying = false;
        function BindEvents() {
            $(".bgm_btn").click(function () {
                var music = document.getElementById("bgmusic");
                if ($(this).hasClass("stop")) {
                    $(this).removeClass("stop").addClass("animation");
                    music.play();
                } else {
                    $(this).addClass("stop").removeClass("animation");
                    music.pause();
                }
            });

            $(".game_rule").on("webkitAnimationEnd", function () {
                $("#tip").css("visibility", "visible");
                //if (gamecounts > 0) {
                //    $("#tip").css("visibility", "visible");
                //}
            });

            $(".p0_heart").on("webkitAnimationEnd", function () {
                $(this).removeClass("bounceIn animated").addClass("heartbeat");
            });

            $(".flower").on("webkitTransitionEnd", function () {
                setTimeout(function () {
                    if (hasChoose) {
                        if (prizeid == "0" && prizeid != "") {
                            showMessage("<p>很遗憾，没有抽中奖品~~</p><p style='color:#e72265;'>此刻您可以将此话截图发送给你喜欢的人。</p>", null);
                            $(".no_awards").show();
                        } else if (parseInt(prizeid) > 0) {
                            showMessage("恭喜您获得了【利郎轻商务精美卡包】一个", function () {
                                window.location.href = "newMyPrizes.aspx";
                            });

                            if (gamecounts <= 0)
                                $("#tip").css("visibility", "hidden");
                        }
                    }
                }, 100);
            });

            //点击热点区
            $(".hot").click(function () {
                if (!hasChoose && gametoken != "") {
                    var flowerNo = $(this).attr("data-area");
                    consumeToken(flowerNo);
                } else if (gamecounts <= 0) {
                    showMessage("<p style='color:#e72265;'>此刻您可以将此话截图发送给你喜欢的人。</p>", null);
                    naPic = "img/" + naArr[Math.floor((Math.random() * naArr.length))] + ".jpg";
                    $(".sentence").attr("src", naPic);
                    $(".no_awards").show();
                }
            });
        }

        function reGame() {
            if (gamecounts > 0 && hasChoose) {
                var selectFlower = $(".flower.selected");
                var isrc = selectFlower.attr("src");
                selectFlower.attr("src", isrc.substring(0, isrc.indexOf("_")) + "_0.png");
                $(".flower_container .flower").removeClass("selected");
                initData();
            } else if (gamecounts <= 0) {
                if (hasChoose) {
                    prizeid = ""; prizename = ""; gametoken = "";
                    $("#spage2 .ani").removeClass("ani");
                    //showMessage("对不起，您已经没有抽取机会了，感谢您对利郎轻商务的支持！！", null);
                }
            }
        }

        function closeSentence() {
            reGame();
            $('.no_awards').hide();
        }

        //初始化数据
        function initData() {
            $.ajax({
                type: "POST",
                timeout: 5 * 1000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "roseGameCore.aspx",
                data: { ctrl: "GetGameData" },
                success: function (msg) {
                    if (msg.indexOf("Successed:") > -1) {
                        var data = msg.replace("Successed:", "").split("|");
                        gametoken = data[0];
                        prizeid = data[1];
                        prizename = data[2];
                        //没有中奖时的prizeid=0
                        hasChoose = false;
                        naPic = "img/" + naArr[Math.floor((Math.random() * naArr.length))] + ".jpg";
                        $(".sentence").attr("src", naPic);
                    } else if (msg.indexOf("您已经没有抽取的机会了") > -1)
                        showMessage(msg.replace("Error:", "") + "，感谢您对利郎轻商务的支持！", null);
                    else
                        showMessage(msg.replace("Error:", ""));
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("您的网络真不给力，请稍后重试！");
                }
            });
        }

        //消费TOKEN
        function consumeToken(flowerNo) {
            if (isPlaying)
                return;
            else {
                isPlaying = true;
                $.ajax({
                    type: "POST",
                    timeout: 5 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "roseGameCore.aspx",
                    data: { ctrl: "ConsumeGameToken", gametoken: gametoken },
                    success: function (msg) {
                        if (msg.indexOf("Successed") > -1) {
                            hasChoose = true;
                            $(".gametimes>span").text(--gamecounts);

                            $(".flower." + flowerNo).addClass("selected");
                            var isrc = $(".flower." + flowerNo).attr("src");
                            $(".flower." + flowerNo).attr("src", isrc.substring(0, isrc.indexOf("_")) + "_1.png");
                            //if (gamecounts > 0) {
                            //    $("#spage2 .ani").removeClass("ani");
                            //}
                        } else
                            showMessage(msg.replace("Error:", ""));

                        isPlaying = false;
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        isPlaying = false;
                        alert("您的网络真不给力，请稍后重试！");
                    }
                });
            }
        }

        //微信JS-SDK
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
                var sharelink = window.location.href;
                var imgurl = "http://tm.lilanz.com/project/easybusiness/2017valentine/img/thumb.jpg";
                var title = "我有句情话想对你说";
                var desc = "爱情千回百转，一句可知心中情。点击阅读原文，抽取属于你的情话。";
                //分享到朋友圈
                wx.onMenuShareTimeline({
                    title: title, // 分享标题
                    link: sharelink, // 分享链接                        
                    imgUrl: imgurl, // 分享图标
                    success: function () {
                    },
                    cancel: function () {
                    }
                });

                //分享给QQ好友
                wx.onMenuShareQQ({
                    title: title, // 分享标题   
                    desc: desc,
                    link: sharelink, // 分享链接
                    imgUrl: imgurl, // 分享图标
                    success: function () {
                    },
                    cancel: function () {
                    }
                });

                //分享给朋友
                wx.onMenuShareAppMessage({
                    title: title, // 分享标题   
                    desc: desc,
                    link: sharelink, // 分享链接
                    imgUrl: imgurl, // 分享图标
                    type: 'link', // 分享类型,music、video或link，不填默认为link
                    dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                    success: function () {
                    },
                    cancel: function () {
                    }
                });
                //分享到QQ空间
                wx.onMenuShareQZone({
                    title: title, // 分享标题   
                    desc: desc,
                    link: sharelink, // 分享链接
                    imgUrl: imgurl, // 分享图标
                    success: function () {
                    },
                    cancel: function () {
                    }
                });
            });
            wx.error(function (res) { });
        }

        //提示函数
        function showMessage(text, cb1, cb2) {
            $("#message").html(text);
            //null
            if (!cb1 && typeof (cb1) != "undefined" && cb1 != 0) {
                $("#confirm").css("display", "inline-block");
                $(" .message_btn>a").css("width", "100%");
                $("#confirm").unbind("click").click(function () {
                    $(".message_mask").css("display", "none");
                });
            } else if (typeof (cb1) == "function") {
                $("#confirm").css("display", "inline-block");
                $("#confirm").unbind("click").click(cb1);
                $(" .message_btn>a").css("width", "100%");
            } else if (typeof (cb1) == "function") {
                $("#confirm").css("display", "inline-block");
                $("#confirm").unbind("click").click(cb1);
                $(" .message_btn>a").css("width", "100%");
            } else
                $("#confirm").css("display", "none");

            //null
            if (!cb2 && typeof (cb2) != "undefined" && cb2 != 0) {
                $("#cancle").css("display", "inline-block");
                $(" .message_btn>a").css("width", "50%");
                $("#cancle").unbind("click").click(function () {
                    $(".message_mask").css("display", "none");
                });
            } else if (typeof (cb2) == "function") {
                $("#cancle").css("display", "inline-block");
                $(" .message_btn>a").css("width", "50%");
                $("#cancle").unbind("click").click(cb2);
            } else
                $("#cancle").css("display", "none");

            if ($("#confirm").css("display") == "none" && $("#confirm").css("display") == "none")
                $(".message_btn").hide();
            else
                $(".message_btn").show();

            $(".message_mask").show();//为了兼容旧手机
            $(".message_mask").css("display", "flex");
        }
    </script>
</body>
</html>
