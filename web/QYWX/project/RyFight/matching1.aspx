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
    <meta name="x5-page-mode" content="app">
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
        }

        .wrap-page, .page, .container {
            width: 100%;
            height: 100%;
        }

        .floatfix {
            content: '';
            display: table;
            clear: both;
        }

        .container {
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center center;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .top_banner {
            position: relative;
            width: 100%;
            height: 0.92rem;
            background-image: url(../../res/img/ryfight/p2_topbanner.png);
            background-size: auto 100%;
            display: -webkit-flex;
            display: flex;
            align-items: center;
            justify-content: center;
            padding-bottom: 0.12rem;
        }

        .matching_txt {
            font-size: 0.38rem;
            text-align: center;
            letter-spacing: 2px;
        }

        /*center_wrap style*/
        .center_wrap {
            text-align: center;
            font-size: 0;
            white-space: nowrap;
        }

            .center_wrap > div {
                display: inline-block;
                vertical-align: top;
                font-size: 0.112rem;
            }

        .left {
            margin-right: -0.112rem;
        }

        .right {
            margin-left: -0.112rem;
        }

            .left, .left > img, .right, .right > img {
                width: 1.575rem;
            }

        .mid, .mid > img {
            width: 5.221rem;
            position: relative;
        }

            .mid .user_wrap {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 0.375rem 0;
            }

        .user_wrap > ul {
            height: 100%;
            overflow-y: auto;
            font-size: 0;
        }

        .user_item {
            width: 0.7rem;
            display: inline-block;
            margin-right: 0.14rem;
            margin-bottom: 0.1rem;
        }

            .user_item img {
                width: 100%;
            }

            .user_item .infos {
                overflow: hidden;
            }

        .class .class_icon {
            width: 0.18rem;
        }

        .user_item p {
            white-space: nowrap;
            font-size: 0.12rem;
            color: #fff;
        }

        .user_item .headimg {
            width: 0.7rem;
            height: 0.7rem;
            background-repeat: no-repeat;
            background-size: cover;
            background-position: center center;
        }

        .user_item p.name {
            font-size: 0.16rem;
        }

        .btns {
            text-align: center;
            margin-bottom: 0.15rem;
        }

            .btns .btn_item {
                display: inline-block;
                width: 1.65rem;
                height: 0.5rem;
                line-height: 0.42rem;
                background-repeat: no-repeat;
                background-position: center center;
                background-size: cover;
                font-size: 0.24rem;
                font-weight: bold;
                color: #990000;
                background-image: url(../../res/img/ryfight/p2_btn.png);
                display:none;
            }

        dot {
            display: inline-block;
            height: 1em;
            line-height: 1;
            vertical-align: -.25em;
            overflow: hidden;
            text-align: left;
        }

            dot::before {
                display: block;
                content: '...\A..\A.';
                white-space: pre-wrap;
                animation: dot 3s infinite step-start both;
            }

        @keyframes dot {
            33% {
                transform: translateY(-2em);
            }

            66% {
                transform: translateY(-1em);
            }
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

            .container {
                width: 100%;
                height: auto;
                position: absolute;
                top: 50%;
                left: 50%;
                -webkit-transform: translate(-50%,-50%);
                transform: translate(-50%,-50%);
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
        .leetip_wrap {
            z-index:1999;
            background-color: rgba(0,0,0,.6);
            display:flex;
            justify-content:center;
            align-items:center;
            color:#fff;
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
    </style>
</head>
<body>
    <div class="mask">
        <img src="../../res/img/ryfight/mobile_icon.png" />
        <p>为了更好的体验，请使用横屏浏览！</p>
    </div>
    <div class="wrap-page">
        <div class="page" id="single">
            <div class="container" style="background-image: url(../../res/img/ryfight/p2_bg.jpg)">
                <div class="top_banner">
                    <p class="matching_txt">--</p>
                </div>
                <div class="center_wrap">
                    <div class="left">
                        <img src="../../res/img/ryfight/p2_left_angle.png" />
                    </div>
                    <div class="mid" style="z-index: 202;">
                        <img src="../../res/img/ryfight/p2_center_bg.png" />
                        <div class="user_wrap">
                            <ul></ul>
                        </div>
                    </div>
                    <div class="right">
                        <img src="../../res/img/ryfight/p2_right_angle.png" />
                    </div>
                </div>
                <div class="btns">
                    <a href="javascript:;" class="btn_item" data-btn="match">开始匹配</a>
                    <a href="javascript:;" class="btn_item" data-btn="unmatch">取消匹配</a>
                    <a href="javascript:;" class="btn_item" data-btn="unteam">退出房间</a>
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
    <!--背景音乐-->
    <div id="bgsound_wrap" style="display:none;"></div>
    <!--系统提示框-->
    <div class="leetip_wrap">
        <div class="leetip" style="background-image:url(../../res/img/ryfight/tipbg.jpg)">
            <div class="tiptext">
                --                
            </div>
            <div class="tipbtn" style="text-align:center;">
                <a href="javascript:;" class="tip_btn confirm"><img src="../../res/img/ryfight/tip_confirm.jpg" /></a>
                <a href="javascript:;" class="tip_btn cancle"><img src="../../res/img/ryfight/tip_cancle.jpg" /></a>
            </div>
        </div>
    </div>
    <script type="text/html" id="tpl_userItem">
        <li class="user_item u1">
            <div class="headimg" style="background-image: url({{avatar}})"></div>
            <div class="infos">
                <p class="name">{{cname}}</p>                
                <p class="class">
                    {{if icon != ""}}
                    <img class="class_icon" src="../../res/img/ryfight/class{{icon}}.png" />{{danname}}
                    {{else}}
                    --
                    {{/if}}
                </p>                
            </div>
        </li>
    </script>

    <script type="text/html" id="tpl_userItem0">
        <li class="user_item u0">
            <div class="headimg" style="background-image: url(../../res/img/ryfight/headimg_0.png)"></div>
            <div class="infos">
                <p class="name">--</p>
                <p class="class">--</p>
            </div>
        </li>
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/fastclick.min.js'></script>
    <script type='text/javascript' src='../../res/js/template.js'></script>
    <script type='text/javascript' src='../../res/js/LeeJSUtils.min.js'></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        $(function () {
            var uid = "<%=CustomerID%>";
            //玩家信息            
            var userInfo = null;            
            var gameStatus = { sign_0: "组队中", sign_1: "匹配队友中", battle_0: "战斗准备中", battle_1: "战斗中" };

            function bindEvents() {
                $(".btn_item[data-btn='match']").click(startMatching);
                $(".btn_item[data-btn='unmatch']").click(unMatching);
                $(".btn_item[data-btn='unteam']").click(unTeaming);
            }

            function checkUserInfo() {
                showLoading("加载用户信息..");
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        timeout: 10 * 1000,                        
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { cid: uid },
                        url: "supremeglory.ashx?ctrl=inituser"
                    }).done(function (msg) {
                        var res = JSON.parse(msg);
                        if (res.code == "200") {
                            userInfo = res.info;
                            window.userinfo = userInfo;
                            bindEvents();//绑定事件
                            processUserStatus();                            
                        } else
                            showLoading("加载用户信息失败！" + res.msg);
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        showLoading("【checkUserInfo】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    });
                }, 50);
            }

            //处理玩家相应的状态
            function processUserStatus() {
                $("#myLoading").hide();
                if (userInfo === null)
                    return;
                if (userInfo.status != "") {
                    if (userInfo.status == "sign_0") {
                        processS0();
                    } else if (userInfo.status == "sign_1") {
                        processS1();
                        return;
                    } else if (userInfo.status == "battle_0" || userInfo.status == "battle_1") {                        
                        LeeAlert("尊敬的玩家，您正处于【" + gameStatus[userInfo.status] + "】状态，即将进入相应的界面..", function () {
                            window.location.href = "fighting.aspx";//战斗中
                        });
                    } else if (userInfo.status == "battle_2") {
                        showLoading("尊敬的玩家，您最近参与的一局游戏正在结算中，结算完成后会推送一条微信通知给您，请留意！");
                        LeeAlert("尊敬的玩家，您最近参与的一局游戏正在结算中，结算完成后会推送一条微信通知给您，请留意！", function () {
                            window.location.href = "main.aspx";
                        });
                    } else {                        
                        LeeAlert("尊敬的玩家，您正处于" + gameStatus[userInfo.status] + "状态");
                        return;
                    }
                } else
                    //查检状态通过 创建房间即报名动作
                    createGameRoom();

                var html = "";
                html += template("tpl_userItem", { cname: userInfo.cname, avatar: userInfo.headimg, danname: userInfo.danname, icon:"" });
                for (var i = 0; i <= 8; i++) {
                    html += template("tpl_userItem0", {});
                    if (i == 3)
                        html += "<br />";
                }//end for
                $(".mid .user_wrap ul").empty().html(html);
            }

            //处理组队状态
            function processS0() {
                //如果是多人组队状态则跳转到多人界面
                if (userInfo.stype == "2") {
                    window.location.replace("matching5.aspx");
                } else {
                    $(".top_banner .matching_txt").empty().append("房间创建成功");
                    $(".btn_item").hide();
                    $(".btn_item[data-btn='unteam']").css("display", "inline-block");
                    if (userInfo.homeOwner == "1") {                        
                        $(".btn_item[data-btn='match']").css("display", "inline-block");
                    }
                }
            }

            //处理匹配状态
            function processS1() {
                //处于匹配中，开始轮询                       
                if (userInfo.homeOwner == "1") {
                    $(".btn_item").hide();
                    $(".btn_item[data-btn='unmatch']").css("display", "inline-block");
                }
                $(".top_banner .matching_txt").empty().append("正在匹配<dot>...</dot>");
                startLongPullMatch();

                LeeAlert("尊敬的玩家，您正处于匹配中，您可以关闭此页面，匹配成功后系统会推送一条消息给您！", function () {
                    $(".leetip_wrap").hide();
                });
            }

            //开始匹配
            function startMatching() {
                showLoading("开始匹配，请稍候..");
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        timeout: 10 * 1000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { sid: userInfo.sid, cid: userInfo.cid },
                        url: "supremeglory.ashx?ctrl=matchteammate"
                    }).done(function (msg) {
                        var res = JSON.parse(msg);
                        if (res.code == "200") {
                            userInfo.status = "sign_1";
                            userInfo.homeOwner = "1";
                            userInfo.stype = "1";                            
                            processS1();
                            $("#myLoading").hide();
                            //showLoading("<p style='text-align:center;font-weight:bold;font-size:0.26rem;'>- 温馨提示 -</p><p style='text-align:center;'>正在匹配中</p>您可以离开此页面，匹配成功后系统会推送一条通知给您。");
                            LeeAlert("开始进入匹配，您可以离开此页面，匹配成功后系统会推送一条通知给您。", function () {
                                $(".leetip_wrap").hide();
                            });                            
                        } else if (res.code == "201") {
                            showLoading(res.msg);                            
                            setTimeout(function () {
                                window.location.replace("main.aspx");
                            }, 1500);
                        } else
                            showLoading("匹配失败！" + res.msg);
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        showLoading("【startMatching】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    });
                }, 100);
            }

            //创建房间
            function createGameRoom() {
                showLoading("正在创建游戏房间..");
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        timeout: 10 * 1000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { cid: uid, ryid: userInfo.ryid, signtype: 1 },
                        url: "supremeglory.ashx?ctrl=signup"
                    }).done(function (msg) {
                        var res = JSON.parse(msg);
                        if (res.code == "200") {
                            userInfo.status = "sign_0";
                            userInfo.homeOwner = "1";
                            userInfo.stype = "1";
                            userInfo.sid = res.info.sid;
                            processS0();
                            $("#myLoading").hide();
                        } else
                            showLoading("创建房间失败！" + res.msg);
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        showLoading("【createGameRoom】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    });
                }, 100);
            }

            function showLoading(text) {
                $(".load_toast .load_text").html(text);
                $("#myLoading").show();
            }

            function startLongPullMatch() {
                matchInterval();
                clearInterval(matchingTimer);
                matchingTimer = setInterval(matchInterval, 2500);
            }

            //匹配轮询
            var matchingTimer, isMatching = false;
            function matchInterval() {
                if (!isMatching) {
                    isMatching = true;
                    $.ajax({
                        type: "POST",
                        timeout: 10 * 1000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { cid: uid, sid: userInfo.sid },
                        url: "supremeglory.ashx?ctrl=getmatching"
                    }).done(function (msg) {
                        console.log(msg);
                        var res = JSON.parse(msg);
                        if (res.code == "200") {
                            try {
                                //人数变化时才更新DOM
                                var len = $(".user_wrap ul .user_item.u1").length;
                                if (res.info.rows.length > 0 && len != res.info.rows.length) {
                                    var html = "";
                                    for (var i = 0; i < res.info.rows.length; i++) {
                                        html += template("tpl_userItem", res.info.rows[i]);
                                    }
                                    for (var j = 0; j < 10 - res.info.rows.length; j++) {
                                        html += template("tpl_userItem0", {});
                                    }
                                    $(".mid .user_wrap ul").empty().html(html);
                                    $(".user_item:nth-child(5)").after("<br></br>");
                                }
                            } catch (e) { }
                            //还要判断从匹配状态切换成战斗成功的状态
                            userInfo.status = res.info.status;
                            userInfo.stype = res.info.stype;
                            checkGameStatus();
                        } else if (res.code == "201") {
                            showLoading(res.msg);
                            clearInterval(matchingTimer);
                            setTimeout(function () {
                                window.location.replace("main.aspx");
                            }, 1500);
                        } else
                            console.log("matchInterval is error" + res.msg);

                        isMatching = false;
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        isMatching = false;
                    });
                }
            }

            function checkGameStatus() {
                switch (userinfo.status) {
                    case "":
                        clearInterval(matchingTimer);
                        //showLoading("对不起，房主已经解散队伍..");
                        //setTimeout(function () {
                        //    window.location.replace("main.aspx?cid=" + uid);
                        //}, 2500);
                        LeeAlert("对不起，房主已经解散队伍..", function () { window.location.replace("main.aspx"); });
                        break;
                    case "sign_0":
                        clearInterval(matchingTimer);
                        //showLoading("对不起，房主已经取消匹配..");
                        //setTimeout(function () {                            
                        //    processS0();
                        //}, 2500);
                        LeeAlert("对不起，房主已经取消匹配..", function () {
                            $(".leetip_wrap").hide();
                            processS0();
                        });
                        break;
                    case "battle_0":
                        clearInterval(matchingTimer);
                        //showLoading("匹配成功，准备进入战斗画面..");
                        //setTimeout(function () {
                        //    window.location.replace("fighting.aspx?cid=" + uid);
                        //}, 2500);
                        LeeAlert("匹配成功，点击【确定】进入战斗画面..", function () {
                            window.location.replace("fighting.aspx");
                        });
                        break;
                    case "battle_1":
                        //clearInterval(matchingTimer);
                        //showLoading("匹配成功，准备进入战斗画面..");
                        //setTimeout(function () {
                        //    window.location.replace("fighting.aspx?cid=" + uid);
                        //}, 2500);
                        LeeAlert("匹配成功，准备进入战斗画面..", function () {
                            window.location.replace("fighting.aspx");
                        })
                        break;
                    case "battle_2":
                        clearInterval(matchingTimer);
                        //showLoading("战斗结算中，这需要点时间，请耐心等待,结算完成后会推送一条微信消息给您，敬请留意..");
                        //setTimeout(function () {
                        //    window.location.replace("main.aspx?cid=" + uid);
                        //}, 2500);
                        LeeAlert("战斗结算中，这需要点时间，请耐心等待,结算完成后会推送一条微信消息给您，敬请留意..", function () {
                            window.location.replace("main.aspx");
                        });
                        break;
                }
            }

            //取消匹配
            function unMatching() {
                showLoading("正在取消匹配..");
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        timeout: 10 * 1000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { cid: uid, sid:userInfo.sid },
                        url: "supremeglory.ashx?ctrl=cancelsign"
                    }).done(function (msg) {
                        var res = JSON.parse(msg);
                        if (res.code == "200") {
                            clearInterval(matchingTimer);
                            //alert("取消匹配成功！");
                            $("#myLoading").hide();
                            $(".top_banner .matching_txt").empty().append("取消匹配");
                            LeeAlert("取消匹配成功！", function () {
                                $(".leetip_wrap").hide();
                                userInfo.status = "sign_0";
                                processS0();
                            });                           
                        } else
                            showLoading("取消匹配失败！" + res.msg);
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        showLoading("【unMatching】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    });
                }, 50);
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

                $(".leetip_wrap").css("display", "flex");
            }
            window.LeeAlert = LeeAlert;
            //退出房间
            function unTeaming() {
                showLoading("正在退出房间..");
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        timeout: 10 * 1000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { cid: uid, sid: userInfo.sid },
                        url: "supremeglory.ashx?ctrl=cancelsign"
                    }).done(function (msg) {
                        var res = JSON.parse(msg);
                        if (res.code == "200") {                            
                            clearInterval(matchingTimer);
                            //alert("退出房间成功！");
                            $("#myLoading").hide();
                            LeeAlert("退出房间成功！", function () {
                                userInfo.status = "";
                                userInfo.homeOwner = "0";
                                userInfo.stype = "0";
                                window.location.replace("main.aspx");
                            });                         
                        } else
                            showLoading("退出房间失败！" + res.msg);
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        showLoading("【unTeaming】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    });
                }, 50);
            }

            function loadMusic() {
                var ele = document.createElement("audio");
                ele.id = "bgmusic";
                ele.loop = "true";
                ele.src = "../../res/sounds/ryfight/31.mp3";
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
            GetWXJSApi();
            
            if (uid == "") {
                showLoading("没有cid！");
            } else {
                checkUserInfo();
                loadMusic();
            }
        });

        window.onload = function () {
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
    </script>
</body>
</html>

