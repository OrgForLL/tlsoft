<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>

<!DOCTYPE html>
<script runat="server">
    public string AppSystemKey = "", CustomerID = "";
    private List<string> wxConfig;//微信JS-SDK  
    protected void Page_Load(object sender, EventArgs e)
    {
        string[] empstrs = { "", "", "", "" };
        wxConfig = new List<string>(empstrs);
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(3));
            CustomerID = Convert.ToString(Session["qy_customersid"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您需要开通全渠道系统！您可以前往【微信】-【利郎企业平台】-【用户中心】自助开通！");
            else
                wxConfig = clsWXHelper.GetJsApiConfig("1");
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
    <script type="text/javascript" src="../../res/js/remSuitable.min.js"></script>
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
            box-sizing: border-box;
        }

        ul {
            list-style: none;
        }

        a {
            text-decoration: none;
        }

        input {
            -webkit-appearance: none;
        }

        html {
            height: 100%;
        }

        body {
            height: 100%;
            color: #fff;
            background-color: #000;
            -webkit-tap-highlight-color: transparent;
            font-size: 0.112rem;
            font-family: -apple-system-font,Helvetica Neue,Helvetica,sans-serif;
        }

        .wrap-page, .page, .container {
            width: 100%;
            height: 100%;
        }

        .container {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            padding: 0 0.158rem 0.18rem 0.16rem;
        }

        .page .bg {
            width: 100%;
            height: 100%;
            display: block;
            position: relative;
            z-index: 200;
        }

        .floatfix {
            content: '';
            display: table;
            clear: both;
        }

        .progress .red, .progress .blue {
            width: 100%;
            position: absolute;
            top: 0;
            z-index: 100;
            transition: all 0.5s;
        }

        .progress .red {
            left: 0;
            transform: translate(-100%,0);
        }

        .progress .blue {
            right: 0;
            transform: translate(100%,0);
            z-index:101;
        }

        .container .static {
            margin-top: 0.6rem;
            margin-bottom: 0.1rem;
            z-index: 500;
            display: flex;
            align-items: flex-end;
            font-size: 0.2rem;
        }

        .static > div {
            width: 33.33%;
            text-align: center;
        }

        .left_red .red {
            font-size: 0.32rem;
            font-weight: bold;
            color: #f92635;
            padding-right: 0.1rem;
        }

        .right_blue .blue {
            font-size: 0.32rem;
            font-weight: bold;
            color: #33b6f4;
            padding-left: 0.1rem;
        }

        .mid_sums {
            color: #33b6f4;
            font-size: 0.22rem;
        }

            .mid_sums > span {
                font-weight:bold;
            }
            .mid_sums.red {
                color: #f92635;
            }

        /*main style*/
        .container .main {
            flex: 1;
            display: flex;
            z-index: 700;
            justify-content: space-between;
            align-items: stretch;
        }

        .main .team {
            width: 1.8rem;
            display: -webkit-flex;
            display: flex;
            flex-direction: column;
        }

        .main .board {
            width: 5.757rem;
            border: 0.015rem solid #384655;
            border-radius: 0.03rem;
            padding: 0.078rem;
            overflow:hidden;
            position:relative;
        }

        .board .content {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow-x:hidden;
            overflow-y:auto;
            -webkit-overflow-scrolling:touch;
            padding: 0.078rem;
        }

        .board .myspeech {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow:hidden;            
            -webkit-overflow-scrolling:touch;
            background-color: rgba(7,23,34,0.8);
            display:flex;
            flex-direction:column;
            display:none;                                    
        }
        .myspeech > a {
            position:absolute;
            top:0.1rem;
            right:0.1rem;
            width:0.28rem;  
            z-index:2000;          
        }
            .myspeech > a > img {
                width:100%;
            }
        .myspeech .input_wrap {
            background-color:#ffd800;
            display:flex;
            align-items:center;
        }
        .input_wrap > a {
            color:#fff;            
            font-weight:bold;
            height:100%;
            width:0.8rem;
            text-align:center;
            display:inline-block;
        }

        .myspeech .usual {
            flex:1;
            color:#fff;
            overflow-y:auto;
            -webkit-overflow-scrolling:touch;
            font-size:0.12rem;
        }
        .usual li {
            padding:0.12rem;
            border-bottom:1px solid rgba(255,255,255,0.2);
            font-size:0.18rem;
        }
        .myspeech .inp_mine {
            padding:0.1rem;
            flex:1;
            border-radius:0;
            border-color:#ddd;
            font-size:0.16rem;
        }

        .board .board_item {
            text-align: center;
            margin-bottom: 0.1rem;
        }

        .board_item .time {
            color: #ccc;
            font-size: 0.16rem;
        }

        .board_item .text {
            font-size: 0.2rem;
            font-weight: bold;
        }

        .board_item.blue {
            color: #33b6f4;
        }

        .board_item.red {
            color: #f92635;
        }

        .team .member {
            flex: 1;
            width: 100%;
            height: 20%;
            background-repeat: no-repeat;
            background-size: 100% 100%;
            background-position: center center;
            background-image: url(../../res/img/ryfight/p4_mem_bg.png);
            display: flex;
            align-items: center;
            justify-content: flex-start;
            font-size: 0.14rem;
            overflow:hidden;
            padding:0 0.12rem;
            position:relative;
        }
        .member > div {
            position:relative;
            z-index:100;
        }
        .member .m_mask {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 99;
            opacity: 0;
            -webkit-animation-duration: 0.4s;
            animation-duration: 0.4s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
            -webkit-transform: translate3d(100%,0,0);
            transform: translate3d(100%,0,0);
        }
        div.member.current {
            background-image:none;
        }
        .member.current .m_mask {
            -webkit-animation-name: fadeInRight;
            animation-name: fadeInRight;
        }
        .member .headimg {
            width: 0.468rem;
            height: 0.468rem;
            min-width:0.468rem;
            border: 0.015rem solid #c6cdd9;
            background-repeat: no-repeat;
            background-position: center center;
            background-color: #00536e;
            border-radius: 0.03rem;
            margin-right: 0.1rem;
            background-size:cover;
        }

        .member .name {
            font-size: 0.18rem;
            line-height:1.4;
        }
        .member p {
            white-space:nowrap;
        }

        .member.red .name {
            color: #f92635;
        }

        .member.blue .name {
            color: #33b6f4;
        }

        .container .btns {
            text-align: center;
            margin-top: 0.1rem;
            z-index: 500;
        }

        .btns .btn_item {
            text-align: center;
            display: inline-block;
            width: 1.218rem;
            height: 0.523rem;
            line-height: 0.44rem;
            background-repeat: no-repeat;
            background-position: center center;
            background-size: cover;
            font-size: 0.26rem;
            font-weight: bold;
            color: #fff;
            background-image: url(../../res/img/ryfight/p4_btn_bg.png);
        }

        .current .headimg {
            border-color: #ffd800;
        }

        .current .name {
            color: #ffd800 !important;
        }

        .mask {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0,0,0,.8);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 2000;
            flex-direction: column;
            display: none;
        }

            .mask > img {
                width: 1.4rem;
                margin-bottom: 0.4rem;
                animation: ani-screenTips-icon 1.6s ease-in-out 0.2s infinite forwards;
            }

        @-webkit-keyframes ani-screenTips-icon {
            0% {
                transform: rotate(0deg);
                -webkit-transform: rotate(0deg);
            }

            40%, 60% {
                transform: rotate(90deg);
                -webkit-transform: rotate(90deg);
            }

            100% {
                transform: rotate(0deg);
                -webkit-transform: rotate(0deg);
            }
        }

        @keyframes ani-screenTips-icon {
            0% {
                transform: rotate(0deg);
                -webkit-transform: rotate(0deg);
            }

            40%, 60% {
                transform: rotate(90deg);
                -webkit-transform: rotate(90deg);
            }

            100% {
                transform: rotate(0deg);
                -webkit-transform: rotate(0deg);
            }
        }

        .mask > p {
            font-size: 0.34rem;
            font-weight: bold;
        }

        @media (orientation: portrait) {
            .mask {
                display: flex;
            }

            .page {
                width: 100%;
                height: 30vh;
                position: absolute;
                top: 50%;
                left: 50%;
                -webkit-transform: translate(-50%,-50%);
                transform: translate(-50%,-50%);
            }

            .container {
                height: 100%;
            }
        }

        .red_sum, .blue_sum {
            display: inline-block;
            vertical-align: bottom;
            zoom:0.8;
        }
        .red_sum i,.blue_sum i {
            width: 15px;
            height: 23px;
            display: inline-block;
            background: url(../../res/img/ryfight/number.png) no-repeat;
            background-position: 0 0;
            text-indent: -999em;                       
        }

        .left_red, .right_blue {
            white-space:nowrap;
        }

        @-webkit-keyframes fadeInRight {
            0% {
                opacity: 0;
                -webkit-transform: translate3d(100%,0,0);
                transform: translate3d(100%,0,0);
            }

            100% {
                opacity: 1;
                -webkit-transform: none;
                transform: none;
            }
        }
        input {
            -webkit-appearance:none;
            outline:none;            
        }
        @keyframes fadeInRight {
            0% {
                opacity: 0;
                -webkit-transform: translate3d(100%,0,0);
                transform: translate3d(100%,0,0);
            }

            100% {
                opacity: 1;
                -webkit-transform: none;
                transform: none;
            }
        }
    </style>
    <style type="text/css">
        #myLoading {
            display: none;
        }

        .load_toast_mask, .load_toast_container,.leetip_wrap {
            position: fixed;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            z-index: 9999;
        }

        .leetip_wrap {
            z-index:1999;
            background-color: rgba(0,0,0,.6);
            display:flex;
            justify-content:center;
            align-items:center;
            display:none;
        }

            .leetip_wrap .leetip {
                width: 5.08rem;
                height: 3.1rem;
                background-repeat: no-repeat;
                background-size: cover;
                background-position: center center; 
                display:flex;
                flex-direction:column;
                align-content:space-between;               
            }
        .tiptext {
            flex:1;
            margin-top:0.64rem;
            font-size:0.22rem;
            font-weight:bold;
            padding:0.14rem 0.36rem;
            display:flex;
            align-items:center;
            justify-content:center;
        }
        .tipbtn {
            display: flex;
            justify-content: space-around;
        }
        .tip_btn {
            width:1.2rem;
            display:inline-block;
            margin-bottom:0.12rem;
            display:none;
        }
            .tip_btn > img {
                width:100%;
            }

        .tipbtn.yes .confirm {
            display:inline-block;
        }

        .tipbtn.no .cancle {
            display:inline-block;
        }

        .load_toast_mask {
            z-index: 9998;
            background-color: rgba(37,38,45,.4);
        }

        .load_toast_container {
            -webkit-transform: translate(100%,100%);
            transform: translate(100%,100%);
        }

        .lee_toast {
            position: absolute;
            top: -50%;
            left: -50%;
            width: auto;
            display: -webkit-box;
            display: flex;
            -webkit-box-align: center;
            align-items: center;
            padding: 13px 16px;
            color: #ccc;
            background-color: rgba(37,38,45,.9);
            border-radius: 4px;
            -webkit-transform: translate(-50%,-50%);
            transform: translate(-50%,-50%);
        }

        .load_img img {
            width: 24px;
            height: 24px;
            display: block;
            margin-right: 10px;
        }

        .load_text {
            max-width: 40vw;
            max-height: 200px;
            overflow: hidden;
            font-size: 0.2rem;
        }
    </style>
</head>
<body>
    <div class="mask">
        <img src="../../res/img/ryfight/mobile_icon.png" />
        <p>为了更好的体验，请使用横屏浏览！</p>
    </div>
    <div class="wrap-page">
        <div class="page" id="fighting">
            <img class="bg" src="../../res/img/ryfight/p4_bg1.png" />
            <div class="container">
                <div class="progress" style="position: relative;">
                    <img class="red" src="../../res/img/ryfight/p4_pro_red.jpg" />
                    <img class="blue" src="../../res/img/ryfight/p4_pro_blue.jpg" />
                </div>
                <div class="static">
                    <div class="left_red">
                        <span class="red">红 队</span>
                        <span>总金额：<span class="red_sum"></span>元</span>
                    </div>
                    <div class="mid_sums"><span>利郎至尊荣耀</span></div>
                    <div class="right_blue">
                        <span>总金额：<span class="blue_sum"></span>元</span>
                        <span class="blue">蓝 队</span>
                    </div>
                </div>
                <div class="main">
                    <!--红队-->
                    <div class="team red"></div>
                    <!--战斗面板-->
                    <div class="board" id="battleBoard">
                        <div class="content"></div>
                        <div class="myspeech">
                            <a href="javascript:hideSpeech();"><img src="../../res/img/ryfight/btn_close.png" /></a>
                            <ul class="usual">
                                <li>同志们，一起拿下这局.</li>
                                <li>不吃饭不睡觉，打起精神赚钞票!</li>
                                <li>失败与挫折只是暂时的，成功已不会太遥远!</li>
                                <li>付出一定会有回报.</li>
                                <li>拧成一股绳，搏尽一份力，狠下一条心，赢下这一局。</li>
                                <li>相信就是强大，怀疑只会抑制能力，而信仰就是力量。</li>
                                <li>拥有梦想只是一种智力，实现梦想才是一种能力，我想看看你们的能力。</li>
                            </ul>
                            <div class="input_wrap">
                                <input type="text" class="inp_mine" placeholder="我要发言.." />                                
                            </div>
                        </div>
                    </div>
                    <!--蓝队-->
                    <div class="team blue"></div>
                </div>
                <div class="btns">
                    <a href="javascript:sendMyVoice();" class="btn_item send" style="margin-right: 0.078rem;display:none;">发 送</a>
                    <a href="javascript:showSpeech();" class="btn_item communi" style="margin-right: 0.078rem;">沟 通</a>
                    <a href="javascript:WeixinJSBridge.call('closeWindow');" class="btn_item leave">关 闭</a>                    
                </div>
            </div>
        </div>
    </div>
    <!--加载提示-->
    <div class="load_toast" id="myLoading">
        <div class="load_toast_mask"></div>
        <div class="load_toast_container">
            <div class="lee_toast">
                <div class="load_img">
                    <img src="../../res/img/my_loading.gif" />
                </div>
                <div class="load_text">加载中...</div>
            </div>
        </div>
    </div>
    <!--系统提示框-->
    <div class="leetip_wrap">
        <div class="leetip" style="background-image:url(../../res/img/ryfight/tipbg.jpg)">
            <div class="tiptext">
                确定退出游戏？？
            </div>
            <div class="tipbtn" style="text-align:center;">
                <a href="javascript:;" class="tip_btn confirm"><img src="../../res/img/ryfight/tip_confirm.jpg" /></a>
                <a href="javascript:;" class="tip_btn cancle"><img src="../../res/img/ryfight/tip_cancle.jpg" /></a>
            </div>
        </div>
    </div>
    <!--背景音乐-->
    <div id="bgsound_wrap" style="display:none;"></div>
    <script type="text/html" id="tpl_memItem">
        <div class="member animated {{role}}" data-cid="{{cid}}">
            <div class="headimg" style="background-image:url({{avatar}})"></div>
            <div class="infos">
                <p class="name">{{cname}}</p>
                <p class="sales">金额：{{amount}}</p>
            </div>
            <img src="../../res/img/ryfight/p4_mem_bg2.png" class="m_mask" />
        </div>
    </script>
    <script type="text/html" id="tpl_boardItem">
        <div class="board_item {{color}}">
            <p class="time">{{createtime}}</p>
            <p class="text">{{content}}</p>
        </div>
    </script>
    
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/fastclick.min.js'></script>
    <script type='text/javascript' src='../../res/js/LeeJSUtils.min.js'></script>
    <script type='text/javascript' src='../../res/js/template.js'></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type='text/javascript' src='../../res/js/ryfight/animateBackground-plugin.js'></script>    

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        var userinfo = null;
        var uid = "<%=CustomerID%>";
        var gameStatus = { sign_0: "组队中", sign_1: "匹配队友中", battle_0: "战斗准备中", battle_1: "战斗中", battle_2: "战斗结算中", battle_3: "战斗结束" };
        var $board = $(".board .content"), refreshtime = "";//最后更新时间
        var redSum = 0, blueSum = 0;
        //检查用户状态
        function checkUserInfo() {            
            showLoading("检查用户状态..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 5 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { cid: uid },
                    url: "supremeglory.ashx?ctrl=inituser"
                }).done(function (msg) {
                    console.log(msg);
                    var res = JSON.parse(msg);
                    if (res.code == "200") {
                        userinfo = res.info;
                        $("#myLoading").hide();
                        if (userinfo.status == "") {
                            //showLoading("游戏不存在或已结束，即将进入首页！");
                            //setTimeout(function () {
                            //    window.location.href = "main.aspx?cid=" + uid;
                            //}, 2000);
                            LeeAlert("游戏不存在或已结束，点击确定后进入首页！", function () {
                                window.location.href = "main.aspx";
                            });
                        } else if (userinfo.status == "battle_0" || userinfo.status == "battle_1") {
                            $("#myLoading").hide();
                            init();
                        } else {                            
                            if (userinfo.status == "battle_2")
                                //showLoading("尊敬的玩家，您最近参与的一局游戏正在结算中，结算完成后会推送一条微信通知给您，请留意！");                               
                                LeeAlert("尊敬的玩家，您最近参与的一局游戏正在结算中，结算完成后会推送一条微信通知给您，请留意！");
                            else
                                //showLoading("尊敬的玩家，您正处于【" + gameStatus[userinfo.status] + "】状态，即将进入相应的界面..");
                                LeeAlert("尊敬的玩家，您正处于【" + gameStatus[userinfo.status] + "】状态，点击确定后进入相应的界面..", function () {
                                    if (userinfo.status == "sign_0") {
                                        if (userinfo.stype == "1")
                                            window.location.href = "matching1.aspx";//单人组队
                                        else if (userinfo.stype == "2")
                                            window.location.href = "matching5.aspx";//多人组队
                                    } else if (userinfo.status == "sign_1") {
                                        window.location.href = "matching1.aspx";//匹配中
                                    }
                                });
                        }                          
                    } else
                        showLoading("加载用户信息失败！" + res.msg);
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    showLoading("【checkUserInfos】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                });
            }, 50);
        }

        //初始化
        function init() {
            BindEvents();
            $(".progress .red").css("transform", "translate(-50%,0)");
            $(".progress .blue").css("transform", "translate(50%,0)");
        }

        //轮询信息
        var boardTimer, isBoarding = false, cacheMsgList = [];
        function boardInterval() {
            if (!isBoarding) {
                isBoarding = true;
                $.ajax({
                    type: "POST",
                    timeout: 5 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { cid: uid, bid: userinfo.bid, refreshtime: refreshtime },
                    url: "supremeglory.ashx?ctrl=battleinfo"
                }).done(function (msg) {
                    //console.log(msg);
                    var res = JSON.parse(msg);
                    if (res.code == "200") {
                        try {
                            userinfo.status = res.info.status;
                            checkInterval();
                            //更新最后记录时间
                            refreshtime = res.info.refreshtime;

                            //更新队伍信息
                            if (res.info.persons.length > 0) {
                                var redTeam = "", blueTeam = "";
                                var team = res.info.persons;
                                for (var i = 0; i < team.length; i++) {
                                    if (team[i].fightingparty == "r") {
                                        team[i].role = "red";
                                        redTeam += template("tpl_memItem", team[i]);
                                    } else if (team[i].fightingparty == "b") {
                                        team[i].role = "blue";
                                        blueTeam += template("tpl_memItem", team[i]);
                                    }
                                }//end for
                                $(".main .team.red").empty().html(redTeam);
                                $(".main .team.blue").empty().html(blueTeam);
                                //更新一下金额
                                var rje = parseInt(res.info.rje), bje = parseInt(res.info.bje);
                                redSum = rje; blueSum = bje;
                                var instance = Math.abs(rje - bje);
                                showNum(parseInt(rje), ".red_sum");
                                showNum(parseInt(bje), ".blue_sum");
                                if (rje > bje) {
                                    $(".static .mid_sums").addClass("red").html("-- 红队领先了<span>" + instance + "</span>元 --");
                                } else if (rje < bje) {
                                    $(".static .mid_sums").addClass("blue").html("-- 蓝队领先了<span>" + instance + "</span>元 --");
                                } else
                                    $(".static .mid_sums").addClass("blue").html("-- <span>双方持平</span> --");
                            }

                            //如果有消息则先关掉计时器，等全部输出完毕后再打开
                            if (res.info.msglist.length > 0) {
                                isBoarding = true;
                                cacheMsgList = res.info.msglist;
                                outBoardInfos();
                                return;
                            }
                        } catch (e) { console.log(e); }
                    } else if (res.code == "201") {
                        //出错则不再轮询
                        showLoading(res.msg);
                        clearInterval(boardInterval);
                    } else
                        console.log("boardInterval is error" + res.msg);

                    isBoarding = false;
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    isBoarding = false;
                });
            }
        }        

        function startLongPullInfo() {
            boardInterval();
            clearInterval(boardTimer);
            boardTimer = setInterval(boardInterval, 4000);
        }

        //只要不是battle_0且也不是battle_1 都全部跳转到首页去
        function checkInterval() {
            if (userinfo.status != "battle_0" && userinfo.status != "battle_1") {
                clearInterval(boardTimer);
                showLoading("对不起，当前游戏状态已发生变化！即将进入首页！");
                setTimeout(function () {
                    window.location.href = "main.aspx";
                }, 2000);
            }
        }

        //向中间面板输出信息
        //var maxInterval = 500, minInterval = 50;
        function outBoardInfos(xh) {
            setTimeout(function () {
                xh = xh || 0;
                cacheMsgList[xh].color = cacheMsgList[xh].fightingparty == "r" ? "red" : "blue";
                cacheMsgList[xh].content = unescape(cacheMsgList[xh].content);
                $board.append(template("tpl_boardItem", cacheMsgList[xh]));                
                $board.animate({ scrollTop: $board[0].scrollHeight - $board.height() }, 200);
                var cid = cacheMsgList[xh].cid;
                $(".team .member[data-cid='" + cid + "']").addClass("current");
                //showNum(RandomNumBoth(1,200000), ".red_sum");
                //showNum(RandomNumBoth(1,400000), ".blue_sum");
                if (xh == cacheMsgList.length - 1) {
                    cacheMsgList.length = 0;
                    setTimeout(function () {
                        isBoarding = false;
                    }, 2000);
                }
                else
                    outBoardInfos(xh + 1);
            }, 400);
        }

        function showNum(n, site) {
            var it = $(site + " i");
            var len = String(n).length;
            for (var i = 0; i < len; i++) {
                if (it.length <= i) {
                    $(site).append("<i></i>");
                }
                var num = String(n).charAt(i);
                var y = -parseInt(num) * 30; //y轴位置
                var obj = $(site + " i").eq(i);
                obj.animate({ //滚动动画
                    backgroundPosition: '(0 ' + String(y) + 'px)'
                }, 'slow', 'swing', function () {                    
                    if (redSum > 0 || blueSum > 0) {
                        //更新进度条
                        var rPer = (redSum / (redSum + blueSum) * 100).toFixed(0);
                        $(".progress .blue").css("transform", "translate(" + rPer + "%,0)");
                    }
                }
                );
            }
        }

        function showLoading(text) {
            $(".load_toast .load_text").text(text);
            $("#myLoading").show();
        }        

        //发言
        function sendMyVoice() {
            var content = escape($(".inp_mine").val().trim());
            if (content == "") {
                //alert("请输入想说的话！");
                LeeAlert("请输入想说的话！", function () { $(".leetip_wrap").hide(); });
                return;
            }
            showLoading("正在发送..");            
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 5 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { cid: uid, bid:userinfo.bid, content:content },
                    url: "supremeglory.ashx?ctrl=savemsg"
                }).done(function (msg) {
                    console.log(msg);
                    var res = JSON.parse(msg);
                    if (res.code == "200") {
                        showLoading("发送成功！");
                        setTimeout(function () {
                            $("#myLoading").hide();
                            hideSpeech();
                        }, 500);
                    } else
                        showLoading("发送失败！请稍后重试！" + res.msg);
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    showLoading("【sendMyVoice】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                });
            }, 100);
        }

        function BindEvents() {
            $(".progress").on("webkitTransitionEnd", ".blue", function () {
                if ($(".progress").attr("isfirst") != "0") {
                    setTimeout(function () {
                        $(".progress .red").css("transform", "translate(0,0)");
                        startLongPullInfo();
                        $(".progress").attr("isfirst", "0");
                    }, 200);
                }
            });

            $(".team").on("webkitAnimationEnd", ".member", function () {
                $(this).removeClass("current");
            });

            $(".usual").on("click", "li", function () {                
                $(".inp_mine").val($(this).text());
            });            
        }

        function RandomNumBoth(Min, Max) {
            var Range = Max - Min;
            var Rand = Math.random();
            var num = Min + Math.round(Rand * Range); //四舍五入
            return num;
        }

        function loadMusic() {
            var ele = document.createElement("audio");
            ele.id = "bgmusic";
            ele.loop = "true";
            ele.src = "../../res/sounds/ryfight/29.mp3";
            document.getElementById("bgsound_wrap").appendChild(ele);
            ele.onload = function () {
                var music = document.getElementById("bgmusic");
                music.play();
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
                jsApiList: ['onMenuShareTimeline', 'onMenuShareAppMessage'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                var sharelink = window.location.href.indexOf("/qywx/") > -1 ? "http://tm.lilanz.com/qywx/project/ryfight/advertise.aspx" : "http://tm.lilanz.com/oa/project/ryfight/advertise.aspx";
                var imgurl = "http://tm.lilanz.com/qywx/res/img/ryfight/thumb.jpg";
                var title = "利郎至尊荣耀";
                var desc = "利郎员工福利来啦，至尊荣耀等你来玩！";
                //分享到朋友圈
                wx.onMenuShareTimeline({
                    title: desc, // 分享标题                    
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
            });
            wx.error(function (res) { });
        }

        $(document).ready(function () {
            GetWXJSApi();
            loadMusic();
        });

        function hideSpeech() {
            $(".board .myspeech").hide();
            $(".btn_item.communi").show();
            $(".btn_item.send").hide();
        }
        function showSpeech() {
            $(".inp_mine").val("");
            $(".board .myspeech").css("display", "flex");
            $(".btn_item.communi").hide();
            $(".btn_item.send").show();
        }

        window.onload = function () {
            checkUserInfo();
            var ua = navigator.userAgent.toLowerCase();
            if (ua.match(/MicroMessenger/i) == "micromessenger") {
                document.addEventListener("WeixinJSBridgeReady", function () {
                    document.getElementById("bgmusic").play();                    
                }, false);
            } else {
                $(window).on("touchstart", function () {
                    $("#bgmusic").trigger("load").trigger("play");
                    $(this).off("touchstart");
                });
            }
        }

        function LeeAlert(text, yescb, nocb) {
            $(".leetip .tiptext").text(text);
            var btns = $(".leetip .tipbtn");
            btns.removeClass("yes no");
            if (typeof (yescb) === 'function') {
                btns.addClass("yes");
                $(".tip_btn.confirm").unbind("click").click(yescb);
            }

            if (typeof (nocb) === 'function') {
                btns.addClass("no");
                $(".tip_btn.cancle").unbind("click").click(nocb);
            }

            $(".leetip_wrap").css("display","flex");
        }
    </script>
</body>
</html>

