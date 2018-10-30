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

        .title {
            height: 0.9rem;
            position: relative;
        }

            .title img {
                width: 100%;
                height: 100%;
            }

        .bottom {
            flex: 1;
            display: flex;
            display: -webkit-flex;
            height: 80%;
        }

            .bottom .right {
                width: 3.6rem;
                height: 100%;
                background-repeat: no-repeat;
                background-position: center;
                background-size: 100% 100%;
                padding: 0.02rem 0.114rem 0.112rem 0.118rem;
                display: flex;
                display: -webkit-flex;
                flex-direction: column;
            }

            .bottom .left {
                flex: 1;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
            }

        .left .title {
            text-align: center;
            font-size: 0.45rem;
            font-weight: bold;
            line-height: 0.9rem;
        }

        .title > p {
            position: absolute;
            top: 0.225rem;
            right: 1.2rem;
            font-size: 0.2rem;
        }

            .title > p .money {
                color: #ffcf00;
                margin-right: 0.15rem;
            }

            .title > p .points {
                color: #e80000;
            }

        .left .match {
            width: 100%;
            height: 2.1rem;
            background-repeat: no-repeat;
            background-position: center;
            background-size: 100% 100%;
            display: flex;
            display: -webkit-flex;
            align-items: center;
            justify-content: center;
            padding-top: 0.14rem;
            margin-top: -0.4rem;
        }

        .user_item {
            width: 0.7rem;
            display: inline-block;
            margin-right: 0.08rem;
            margin-bottom: 0.08rem;
            text-align: center;
        }

            .user_item .headimg {
                width: 0.7rem;
                height: 0.7rem;
                background-repeat: no-repeat;
                background-size: cover;
                background-position: center center;
                margin-bottom: 0.1rem;
            }

            .user_item .infos {
                overflow: hidden;
            }

        .class .class_icon {
            width: 0.18rem;
        }

        .user_item p.name {
            font-size: 0.16rem;
        }

        .user_item p {
            white-space: nowrap;
            font-size: 0.14rem;
            line-height: 1.2;
            color: #fff;
        }

        .btns {
            text-align: center;
            margin-bottom: 0.2rem;
        }

            .btns .btn_item {
                text-align: center;
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
                display: none;
            }

        .right img {
            width: 100%;
        }

        .right .table_head {
            background-repeat: no-repeat;
            background-position: center center;
            background-size: 100% 100%;
            width: 100%;
            height: 0.6rem;
        }

        .table_head ul {
            width: 100%;
        }

            .table_head ul li {
                float: left;
                width: 33%;
                text-align: center;
                font-size: 0.22rem;
                line-height: 0.6rem;
            }

                .table_head ul li.selected {
                    color: #ffcf00;
                    font-weight: bold;
                }

        .right .friends {
            width: 100%;
            flex: 1;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .friends li {
            padding: 0.1rem 0.187rem;
            display: flex;
            align-items: center;
            border-bottom: 0.015rem solid #133750;
            font-size: 0.16rem;
            white-space: nowrap;
            position: relative;
        }

            .friends li .gamestatus {
                position: absolute;
                right: 0.1rem;
                bottom: 0.1rem;
                background-color: rgb(21,160,91);
                padding: 0.02rem 0.06rem;
            }

                .friends li .gamestatus.sign_0 {
                    background-color: rgb(255,210,0);
                }

                .friends li .gamestatus.battle_2 {
                    background-color: rgb(222,82,70);
                }

        .friends .headimg {
            width: 0.525rem;
            min-width: 0.525rem;
            height: 0.525rem;
            border: 0.015rem solid #93a2af;
            background-color: #00536e;
            border-radius: 0.04rem;
            margin-right: 0.18rem;
            background-size: cover;
        }

        .user_infos .name {
            font-size: 0.23rem;
        }

            .user_infos .name > span {
                font-size: 0.16rem;
                color: #ffcf00;
            }

        .right .btns {
            height: 0.6rem;
            background-color: #111927;
            margin-bottom: 0;
            border-bottom-left-radius: 0.04rem;
            border-bottom-right-radius: 0.04rem;
        }

        .right .btns {
            display: flex;
            align-items: center;
            justify-content: center;
            padding-top: 0.08rem;
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

        @media (orientation: portrait) {
            .mask {
                display: flex;
            }

            .container {
                width: 100%;
                height: 30vh;
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

        .load_toast_mask, .load_toast_container, .leetip_wrap {
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
            z-index: 1999;
            background-color: rgba(0,0,0,.6);
            display: flex;
            justify-content: center;
            align-items: center;
            color: #fff;
            display: none;
        }

            .leetip_wrap .leetip {
                width: 5.08rem;
                height: 3.1rem;
                background-repeat: no-repeat;
                background-size: cover;
                background-position: center center;
                display: flex;
                flex-direction: column;
                align-content: space-between;
            }

        .tiptext {
            flex: 1;
            margin-top: 0.64rem;
            font-size: 0.22rem;
            font-weight: bold;
            padding: 0.14rem 0.36rem;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .tipbtn {
            display: flex;
            justify-content: space-around;
        }

        .tip_btn {
            width: 1.2rem;
            display: inline-block;
            margin-bottom: 0.12rem;
            display: none;
        }

            .tip_btn > img {
                width: 100%;
            }

        .tipbtn.yes .confirm {
            display: inline-block;
        }

        .tipbtn.no .cancle {
            display: inline-block;
        }
    </style>
</head>
<body>
    <div class="mask">
        <img src="../../res/img/ryfight/mobile_icon.png" />
        <p>为了更好的体验，请使用横屏浏览！</p>
    </div>
    <div class="wrap-page">
        <div class="page" id="multi">
            <div class="container" style="background-image: url(../../res/img/ryfight/p3_bg.jpg)">
                <div class="title">
                    <img src="../../res/img/ryfight/p3_title.png" />
                    <p></p>
                </div>
                <div class="bottom">
                    <div class="left">
                        <div class="title">--</div>
                        <div class="match" style="background-image: url(../../res/img/ryfight/p3_lc_m.png)">
                            <ul></ul>
                        </div>
                        <div class="btns">
                            <a href="javascript:startMatching();" class="btn_item" data-btn="match">开始匹配</a>
                            <a href="javascript:unTeaming();" class="btn_item" data-btn="unteam">退出房间</a>
                        </div>
                    </div>
                    <div class="right" style="background-image: url(../../res/img/ryfight/p3_rc.png)">
                        <div class="table_head" style="background-image: url(../../res/img/ryfight/p3_rc_headbg.png)">
                            <ul class="floatfix">
                                <li class="selected" data-type="mdid">店铺</li>
                                <li data-type="khid">贸易公司</li>
                                <li data-type="refresh">刷 新</li>
                            </ul>
                        </div>
                        <div class="friends" id="friends_list">
                            <ul data-type="mdid"></ul>
                            <ul data-type="khid"></ul>
                        </div>
                    </div>
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
        <div class="leetip" style="background-image: url(../../res/img/ryfight/tipbg.jpg)">
            <div class="tiptext">
                确定退出游戏？？
            </div>
            <div class="tipbtn" style="text-align: center;">
                <a href="javascript:;" class="tip_btn confirm">
                    <img src="../../res/img/ryfight/tip_confirm.jpg" /></a>
                <a href="javascript:;" class="tip_btn cancle">
                    <img src="../../res/img/ryfight/tip_cancle.jpg" /></a>
            </div>
        </div>
    </div>

    <!--背景音乐-->
    <div id="bgsound_wrap" style="display: none;"></div>

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

    <script type="text/html" id="tpl_friendItem">
        <li data-cid="{{cid}}">
            <div class="headimg" style="background-image: url({{avatar}})"></div>
            <div class="user_infos">
                <p class="name">{{cname}} <span>（{{danname}}）</span></p>
                <p class="store">门店：{{mdmc}}</p>
            </div>
            <p class="gamestatus {{status}}">{{statusText}}</p>
        </li>
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/fastclick.min.js'></script>
    <script type='text/javascript' src='../../res/js/template.js'></script>
    <script type='text/javascript' src='../../res/js/LeeJSUtils.min.js'></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>

    <script type="text/ecmascript">
        //玩家信息
        var uid = "<%=CustomerID%>";
        var userinfo = null, p_sid = LeeJSUtils.GetQueryParams("sid");
        var gameStatus = { sign_0: "组队中", sign_1: "匹配队友中", battle_0: "战斗准备中", battle_1: "战斗中" };
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        function checkUserInfo() {
            showLoading("加载用户信息..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 10 * 1000,
                    async: false,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { cid: uid },
                    url: "supremeglory.ashx?ctrl=inituser"
                }).done(function (msg) {
                    var res = JSON.parse(msg);
                    if (res.code == "200") {
                        userinfo = res.info;
                        GetWXJSApi();
                        getFriendsList("mdid");
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
            if (userinfo === null)
                return;
            if (userinfo.status != "") {
                if (userinfo.status == "sign_0") {
                    processS0();
                } else if (userinfo.status == "sign_1") {
                    //处于匹配中
                    processS1();
                } else if (userinfo.status == "battle_0" || userinfo.status == "battle_1") {
                    //showLoading("尊敬的玩家，您正处于【" + gameStatus[userinfo.status] + "】状态，即将进入相应的界面..");
                    //setTimeout(function () {
                    //    window.location.href = "fighting.aspx?cid=" + uid;//战斗中
                    //}, 2000);
                    LeeAlert("尊敬的玩家，您正处于【" + gameStatus[userinfo.status] + "】状态，即将进入相应的界面..", function () {
                        window.location.href = "fighting.aspx";//战斗中
                    });
                } else if (userInfo.status == "battle_2") {
                    //showLoading("尊敬的玩家，您最近参与的一局游戏正在结算中，结算完成后会推送一条微信通知给您，请留意！");
                    //setTimeout(function () {
                    //    window.location.href = "main.aspx?cid=" + uid;
                    //}, 2000);
                    LeeAlert("尊敬的玩家，您最近参与的一局游戏正在结算中，结算完成后会推送一条微信通知给您，请留意！点击【确定】后进入首页..", function () {
                        window.location.href = "main.aspx";
                    });
                } else {
                    //alert("尊敬的玩家，您正处于" + gameStatus[userInfo.status] + "状态");
                    LeeAlert("尊敬的玩家，您正处于" + gameStatus[userInfo.status] + "状态");
                    return;
                }
            } else {
                //判断有没有传入SID 有则代表被邀请进来的                
                if (p_sid == "") {
                    createGameRoom();
                } else {
                    //传入FID自己再查一次                    
                    var fid = LeeJSUtils.GetQueryParams("fid");
                    if (fid != "" && parseInt(fid) > 0) {
                        handleInvite(p_sid, fid);
                    } else {
                        LeeAlert("来自好友至尊荣耀的邀请，是否同意加入？？", function () {
                            $(".leetip_wrap").hide();
                            addTeam(p_sid);
                        }, function () {
                            window.location.href = "main.aspx";
                        });
                    }
                }
            }
        }

        function handleInvite(roomid, friendid) {
            var fname = "", msg = "";
            $.ajax({
                type: "POST",
                timeout: 4 * 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                data: { fid: friendid },
                url: "supremeglory.ashx?ctrl=getfname"
            }).done(function (msg) {
                var res = JSON.parse(msg);
                if (res.code == "200") {
                    fname = res.info.cname;
                    msg = "接受来自好友【" + fname + "】的至尊荣耀邀请吗？【" + roomid + "】";
                } else
                    msg = "是否同意加入房间【" + roomid + "】？";

                LeeAlert(msg, function () {
                    $(".leetip_wrap").hide();
                    addTeam(roomid);
                }, function () {
                    window.location.href = "main.aspx";
                });
            }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                msg = "是否同意加入房间【" + roomid + "】？？";
                LeeAlert(msg, function () {
                    $(".leetip_wrap").hide();
                    addTeam(roomid);
                }, function () {
                    window.location.href = "main.aspx";
                });
            });
        }

        //处理组队状态        
        function processS0() {
            if (userinfo.stype == "1")
                window.location.replace("matching1.aspx");
            else if (userinfo.stype == "2") {
                $(".left .btn_item").hide();
                $(".bottom .left .title").empty().append("组队中，可以邀请好友<dot>...</dot>");
                $(".btn_item[data-btn='unteam']").css("display", "inline-block");
                if (userinfo.homeOwner == "1") {
                    $(".btn_item[data-btn='match']").css("display", "inline-block");
                }

                startLongPullTeam();
            }
        }

        //处理匹配状态
        function processS1() {
            showLoading("尊敬的玩家您已经在匹配队伍中..");
            setTimeout(function () {
                window.location.href = "matching1.aspx";
            }, 1000);
        }

        function startLongPullTeam() {
            teamInterval();
            clearInterval(teamTimer);
            teamTimer = setInterval(teamInterval, 2500);
        }

        //组队轮询
        var teamTimer, isTeaming = false;
        function teamInterval() {
            if (!isTeaming) {
                isTeaming = true;
                $.ajax({
                    type: "POST",
                    timeout: 10 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { cid: uid, sid: userinfo.sid },
                    url: "supremeglory.ashx?ctrl=getSign"
                }).done(function (msg) {
                    console.log(msg);
                    var res = JSON.parse(msg);
                    if (res.code == "200") {
                        //人数变化时才更新DOM
                        try {
                            var len = $(".match ul .user_item.u1").length;
                            if (res.info.rows.length > 0 && len != res.info.rows.length) {
                                var html = "";
                                for (var i = 0; i < res.info.rows.length; i++) {
                                    html += template("tpl_userItem", res.info.rows[i]);
                                }
                                for (var j = 0; j < 5 - res.info.rows.length; j++) {
                                    html += template("tpl_userItem0", {});
                                }
                                $(".match ul").empty().html(html);
                            }
                        } catch (e) { }

                        userinfo.status = res.info.status;
                        userinfo.stype = res.info.stype;
                        checkGameStatus();
                    } else if (res.code == "201") {
                        showLoading(res.msg);
                        clearInterval(teamTimer);
                        setTimeout(function () {
                            window.location.replace("main.aspx");
                        }, 1500);
                    } else
                        console.log("teamInterval is error" + res.msg);

                    isTeaming = false;
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    isTeaming = false;
                });
            }
        }

        //{ sign_0: "组队中", sign_1: "匹配队友中", battle_0: "战斗准备中", battle_1: "战斗中", battle_2: "战斗结算中", battle_3: "战斗结束" };
        function checkGameStatus() {
            $("#myLoadding").hide();
            switch (userinfo.status) {
                case "":
                    clearInterval(teamTimer);
                    //showLoading("对不起，房主已经解散队伍..");
                    //setTimeout(function () {
                    //    window.location.replace("main.aspx");
                    //}, 2500);
                    LeeAlert("【游戏状态变化】对不起，房主已经解散队伍..", function () {
                        window.location.replace("main.aspx");
                    });
                    break;
                case "sign_1":
                    clearInterval(teamTimer);
                    //showLoading("开始进入匹配中..");
                    //setTimeout(function () {
                    //    window.location.replace("matching1.aspx");
                    //}, 1500);
                    LeeAlert("【游戏状态变化】开始进入匹配中..", function () {
                        window.location.replace("matching1.aspx");
                    });                    
                    break;
                case "battle_0":
                    clearInterval(teamTimer);
                    //showLoading("开始战斗..");
                    //setTimeout(function () {
                    //    window.location.replace("fighting.aspx");
                    //}, 2500);
                    LeeAlert("【游戏状态变化】开始战斗..", function () {
                        window.location.replace("fighting.aspx");
                    });
                    break;
                case "battle_1":
                    clearInterval(teamTimer);
                    //showLoading("开始战斗..");
                    //setTimeout(function () {
                    //    window.location.replace("fighting.aspx");
                    //}, 2500);
                    LeeAlert("【游戏状态变化】开始战斗..", function () {
                        window.location.replace("fighting.aspx");
                    });                    
                    break;
                case "battle_2":
                    clearInterval(teamTimer);
                    //showLoading("战斗结算中，这需要点时间，请耐心等待,结算完成后会推送一条微信消息给您，敬请留意..");
                    //setTimeout(function () {
                    //    window.location.replace("main.aspx");
                    //}, 2500);
                    LeeAlert("【游戏状态变化】战斗结算中，这需要点时间，请耐心等待,结算完成后会推送一条微信消息给您，敬请留意..", function () {
                        window.location.replace("main.aspx");
                    });
                    break;
            }
        }

        //好友组队
        function addTeam(p_sid) {
            showLoading("正在进入房间..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 5 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { cid: uid, ryid: userinfo.ryid, signtype: 2, sid: p_sid },
                    url: "supremeglory.ashx?ctrl=signup"
                }).done(function (msg) {
                    var res = JSON.parse(msg);
                    if (res.code == "200") {
                        userinfo.status = "sign_0";
                        userinfo.homeOwner = "0";
                        userinfo.stype = "2";
                        userinfo.sid = p_sid;
                        //开始轮询组队接口
                        processS0();
                        $("#myLoading").hide();
                    } else {
                        showLoading("加入房间失败！" + res.msg);
                        setTimeout(function () {
                            //window.location.href = "main.aspx";
                        }, 2000);
                    }
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    showLoading("【addTeam】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                });
            }, 50);
        }

        //创建房间 即创建组队
        function createGameRoom() {
            showLoading("正在创建游戏房间..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 10 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { cid: uid, ryid: userinfo.ryid, signtype: 2 },
                    url: "supremeglory.ashx?ctrl=signup"
                }).done(function (msg) {
                    var res = JSON.parse(msg);
                    if (res.code == "200") {
                        userinfo.status = "sign_0";
                        userinfo.homeOwner = "1";
                        userinfo.stype = "2";
                        userinfo.sid = res.info.sid;
                        //开始轮询组队接口
                        processS0();
                        $("#myLoading").hide();
                    } else
                        showLoading("创建房间失败！" + res.msg);
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    showLoading("【createGameRoom】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                });
            }, 50);
        }

        //开始匹配
        function startMatching() {
            showLoading("正在处理，请稍候..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 5 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { sid: userinfo.sid, cid: userinfo.cid },
                    url: "supremeglory.ashx?ctrl=matchteammate"
                }).done(function (msg) {
                    var res = JSON.parse(msg);
                    if (res.code == "200") {
                        clearInterval(teamTimer);
                        showLoading("开始匹配中..");
                        window.location.replace("matching1.aspx");
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

        //退出房间
        function unTeaming() {
            showLoading("正在退出房间..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 5 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { cid: uid, sid: userinfo.sid },
                    url: "supremeglory.ashx?ctrl=cancelsign"
                }).done(function (msg) {
                    var res = JSON.parse(msg);
                    if (res.code == "200") {
                        clearInterval(teamTimer);
                        userinfo.status = "";
                        userinfo.homeOwner = "0";
                        userinfo.stype = "0";
                        $("#myLoading").hide();
                        LeeAlert("退出房间成功！", function () {
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

        //加载好友
        function getFriendsList(rtype) {
            var isload = $(".friends ul[data-type='" + rtype + "']").attr("data-isload");
            if (isload == "1") {
                $(".friends ul").hide();
                $(".friends ul[data-type='" + rtype + "']").show();
            }
            else {
                $.ajax({
                    type: "POST",
                    timeout: 5 * 1000,
                    async: false,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { cid: uid, rtype: rtype },
                    url: "supremeglory.ashx?ctrl=rankinglist"
                }).done(function (msg) {
                    console.log(msg);
                    var res = JSON.parse(msg);
                    if (res.code == "200") {
                        var html = "";
                        for (var i = 0; i < res.info.length; i++) {
                            //自己不显示
                            if (res.info[i].cid == userinfo.cid)
                                continue;
                            switch (res.info[i].status) {
                                case "":
                                    res.info[i].statusText = "空闲";
                                    break;
                                case "sign_0":
                                    res.info[i].statusText = "组队中";
                                    break;
                                case "battle_2":
                                    res.info[i].statusText = "战斗中";
                                    break;
                            }
                            html += template("tpl_friendItem", res.info[i]);
                        }//end for                                
                        $(".friends ul[data-type='" + rtype + "']").empty().html(html);
                        if (res.info.length > 0)
                            $(".friends ul[data-type='" + rtype + "']").attr("data-isload", "1").show();
                    } else
                        showLoading("加载好友列表失败！" + res.msg);
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    showLoading("【getFriendsList】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                });
            }
        }

        //邀请好友 只有空闲状态的才能邀请
        var hasInvite = {};
        function inviteMyFriends(fid) {
            if (hasInvite[fid] == "1") {
                //showLoading("对不起，您已经邀请过该好友！");
                //setTimeout(function () {
                //    $("#myLoading").fadeOut(400);
                //}, 1500);
                $("#myLoading").fadeOut(400);
                LeeAlert("对不起，您已经邀请过该好友！", function () {
                    $(".leetip_wrap").hide();
                });
                return;
            }
            showLoading("正在发送邀请..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 5 * 1000,
                    async: false,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { fid: fid, sid: userinfo.sid, cid: userinfo.cid },
                    url: "supremeglory.ashx?ctrl=invitingfriends"
                }).done(function (msg) {
                    console.log(msg);
                    var res = JSON.parse(msg);
                    $("#myLoading").hide();
                    if (res.code == "200") {
                        hasInvite[fid] = "1";
                        //showLoading("邀请成功！等待对方接受..");
                        //setTimeout(function () {
                        //    $("#myLoading").fadeOut(400);
                        //}, 1500);                        
                        LeeAlert("邀请成功！等待对方接受..", function () {
                            $(".leetip_wrap").hide();
                        });
                    } else {
                        //showLoading("邀请好友失败！请稍后重试.." + res.msg);
                        //setTimeout(function () {
                        //    $("#myLoading").fadeOut(400);
                        //}, 1500);
                        LeeAlert("邀请好友失败！请稍后重试.." + res.msg, function () {
                            $(".leetip_wrap").hide();
                        });
                    }
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    showLoading("【inviteMyFriends】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                });
            }, 100);
        }

        //刷新好友列表
        function reFriendList(rtype) {
            showLoading("正在刷新好友列表..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 5 * 1000,
                    async: false,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { cid: uid, rtype: rtype },
                    url: "supremeglory.ashx?ctrl=rankinglist"
                }).done(function (msg) {
                    var res = JSON.parse(msg);
                    if (res.code == "200") {
                        var html = "";
                        for (var i = 0; i < res.info.length; i++) {
                            //自己不显示
                            if (res.info[i].cid == userinfo.cid)
                                continue;
                            switch (res.info[i].status) {
                                case "":
                                    res.info[i].statusText = "空闲";
                                    break;
                                case "sign_0":
                                    res.info[i].statusText = "组队中";
                                    break;
                                case "battle_2":
                                    res.info[i].statusText = "战斗中";
                                    break;
                            }
                            html += template("tpl_friendItem", res.info[i]);
                        }//end for                                
                        $(".friends ul[data-type='" + rtype + "']").empty().html(html);
                        if (res.info.length > 0)
                            $(".friends ul[data-type='" + rtype + "']").attr("data-isload", "1").show();

                        $("#myLoading").hide();
                    } else {
                        showLoading("刷新好友列表失败！" + res.msg);
                        setTimeout(function () { $("#myLoading").hide(); }, 2000);
                    }
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    showLoading("【getFriendsList】" + XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                });
            }, 100);
        }

        function showLoading(text) {
            $(".load_toast .load_text").text(text);
            $("#myLoading").show();
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

        function BindEvents() {
            $(".right").on("click", ".table_head li", function () {
                var rtype = $(this).attr("data-type");
                if (rtype == "refresh") {
                    var cur = $(this).parent().find("li.selected").attr("data-type");
                    reFriendList(cur);
                } else {
                    $(this).parent().find("li").removeClass("selected");
                    $(this).addClass("selected");
                    getFriendsList(rtype);
                }
            });

            $(".friends").on("click", "ul li", function () {
                var name = $(this).find(".name").text();
                //if (confirm("确认邀请【" + name + "】？？")) {
                //    var fid = $(this).attr("data-cid");
                //    if (fid == userinfo.cid) {
                //        showLoading("对不起，不能邀请自己！");
                //        setTimeout(function () {
                //            $("#myLoading").fadeOut(400);
                //        }, 1000);
                //        return;
                //    }
                //    inviteMyFriends(fid);
                //}
                var fid = $(this).attr("data-cid");
                LeeAlert("确认邀请【" + name + "】？？", function () {
                    $(".leetip_wrap").hide();                    
                    if (fid == userinfo.cid) {
                        showLoading("对不起，不能邀请自己！");
                        setTimeout(function () {
                            $("#myLoading").fadeOut(400);
                        }, 1000);
                        return;
                    }
                    inviteMyFriends(fid);
                }, function () {
                    $(".leetip_wrap").hide();
                })
            })
        }

        function loadMusic() {
            var ele = document.createElement("audio");
            ele.id = "bgmusic";
            ele.loop = "true";
            ele.src = "../../res/sounds/ryfight/23.mp3";
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
                var sharelink = window.location.origin + window.location.pathname + "?sid=" + userinfo.sid + "&fid=" + userinfo.cid;
                var imgurl = "http://tm.lilanz.com/qywx/res/img/ryfight/thumb.jpg";
                var title = "利郎至尊荣耀";
                var desc = "我开了一局【利郎-至尊荣耀】，等你来组队。";
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
            if (uid == "")
                showLoading("没有cid！");
            else {
                BindEvents();
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

            LeeJSUtils.stopOutOfPage(".friends", true);
        }
    </script>
</body>
</html>

