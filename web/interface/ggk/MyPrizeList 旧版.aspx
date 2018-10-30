<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html>
<!DOCTYPE html>
<script runat="server">
    public string userid = "";
    public string isRegister = "1";
    protected void Page_Load(object sender, EventArgs e)
    {
        userid = Convert.ToString(Session["TM_WXUserID"]);
        if (userid == null || userid == "" || userid == "0")
        {
            string gourl = HttpUtility.UrlEncode("http://tm.lilanz.com/supersalegames/TMOauthAndRedirect.aspx");
            string curURL = HttpUtility.UrlEncode(Request.Url.ToString());
            string OauthURL = @"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxc368c7744f66a3d7&redirect_uri={0}&response_type=code&scope=snsapi_userinfo&state={1}#wechat_redirect";
            OauthURL = string.Format(OauthURL, gourl, curURL);
            Response.Redirect(OauthURL);
            Response.End();
        }
        else
        {
            //接着判断用户是否登记过信息了
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM("server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456"))
            {
                string str_sql = "select * from tm_t_userinfo where userid=" + userid;
                DataTable dt = null;
                string errinfo = dal.ExecuteQuery(str_sql, out dt);
                if (errinfo == "" && dt.Rows.Count == 0)
                {
                    isRegister = "0";
                }
                else
                    isRegister = "1";
            }
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <title>我的礼券</title>
    <link href="css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
            color: #333;
        }

        body {
            font: 14px/1.5 Microsoft YaHei, Helvitica, Verdana, Arial, san-serif;
            background: rgb(249,249,249);
        }

        .card {
            width: 94%;
            max-width: 480px;
            height: 120px;
            margin: 1.3em auto;
            border: 1px solid #ccc;
            cursor: pointer;
            overflow: hidden;
        }

        .cardl {
            width: 80%;
            height: 120px;
            background: #ebeced;
            float: left;
            border-right: 1px dashed #333;
            box-sizing: border-box;
            padding: 5px 10px;
        }

        .cardr {
            width: 20%;
            height: 120px;
            background: #5cb85c;
            float: left;
        }

        .lr {
            margin: 0 auto;
            width: 20px;
            color: #fff;
            font-size: 1.5em;
            height: 120px;
            line-height: 40px;
            font-weight: bold;
        }

        .lcenter {
            width: 100%;
            text-align: center;
            font-size: 2.1em;
            font-weight: bold;
            height: 50px;
            line-height: 50px;
            vertical-align: middle;
            letter-spacing: 4px;
        }

        .ltop, .lbottom {
            height: 30px;
            width: 100%;
        }

        .ltop {
            font-size: 16px;
            font-weight: bold;
            letter-spacing: 1px;
        }

        .lbottom {
            vertical-align: text-bottom;
            text-align: center;
            font-size: 0.8em;
        }

        .cc {
            background: #f0ad4e;
        }

        .dd {
            background: #ccc;
        }

        .ee {
            background: #d9534f;
        }

        .searchbtn {
            text-align: center;
            width: 94%;
            max-width: 480px;
            margin: 0 auto;
            position: relative;
        }

            .searchbtn ul {
                list-style: none;
                font-size: 1em;
                margin: 15px auto 0px auto;
                background-color: #fff;
            }

                .searchbtn ul li {
                    float: left;
                    padding: 5px 15px;
                    border: 1px solid #333;
                    text-align: center;
                    font-weight: bold;
                    cursor: pointer;
                    width: 25%;
                    box-sizing: border-box;
                    transition: all 0.5s;
                }

                    .searchbtn ul li:not(:last-child) {
                        border-right: none;
                    }

        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }

        .selected {
            color: #fff;
            background-color: #808080;
        }

        .copyright {
            margin: 15px auto;
            text-align: center;
            font-size: 1em;
            color: #808080;
        }

        .infolab {
            text-align: center;
            font-size: 1.2em;
            color: rgb(223,25,42);
            font-weight: bold;
            display: none;
        }

        #info {
            width: 94%;
            max-width: 480px;
            margin: 10px auto;
            padding: 4px;
            background: #fff;
            border-radius: 5px;
            box-sizing: border-box;
            border: 1px solid #ccc;
            font-size: 1.1em;
        }

            #info .box {
                border: 1px dashed #ccc;
                border-radius: 5px;
                padding: 5px 10px;
                box-sizing: border-box;
            }

                #info .box p {
                    line-height: 24px;
                }

        .qrcontainer {
            position: fixed;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0);
            opacity: 0.6;
            z-index: 100;
            display: none;
        }

        .qrimg {
            position: fixed;
            left: 50%;
            top: 45%;
            width: 20em;
            height: 20em;
            background: #fff;
            z-index: 200;
            margin-top: -10em;
            margin-left: -10em;
            border: 1px solid #ccc;
            padding: 10px;
            box-sizing: border-box;
            display: none;
        }

        .closeqr {
            position: absolute;
            width: 34px;
            height: 34px;
            top: -17px;
            right: -17px;
            border-radius: 50%;
            background-color: #fff;
            border: 1px solid #808080;
            color: #808080;
        }

        #giftimg {
            width: 100%;
            height: auto;
        }

        .qrdesc {
            text-align: center;
            margin-top: 15px;
            color: #fff;
            background-color: #808080;
            padding: 5px 0px;
            font-size: 1.2em;
            border-radius: 4px;
        }

        .topinfo {
            width: 94%;
            margin: 10px auto 0 auto;
            font-size: 1em;
            font-weight: bold;
            color: rgb(223,25,42);
            text-align: center;
        }

        a {
            cursor: pointer;
        }

        /*animated*/
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

            .animated.hinge {
                -webkit-animation-duration: 2s;
                animation-duration: 2s;
            }

        @-webkit-keyframes flipInX {
            0% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,90deg);
                transform: perspective(400px) rotate3d(1,0,0,90deg);
                -webkit-transition-timing-function: ease-in;
                transition-timing-function: ease-in;
                opacity: 0;
            }

            40% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,-20deg);
                transform: perspective(400px) rotate3d(1,0,0,-20deg);
                -webkit-transition-timing-function: ease-in;
                transition-timing-function: ease-in;
            }

            60% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,10deg);
                transform: perspective(400px) rotate3d(1,0,0,10deg);
                opacity: 1;
            }

            80% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,-5deg);
                transform: perspective(400px) rotate3d(1,0,0,-5deg);
            }

            100% {
                -webkit-transform: perspective(400px);
                transform: perspective(400px);
            }
        }

        @keyframes flipInX {
            0% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,90deg);
                -ms-transform: perspective(400px) rotate3d(1,0,0,90deg);
                transform: perspective(400px) rotate3d(1,0,0,90deg);
                -webkit-transition-timing-function: ease-in;
                transition-timing-function: ease-in;
                opacity: 0;
            }

            40% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,-20deg);
                -ms-transform: perspective(400px) rotate3d(1,0,0,-20deg);
                transform: perspective(400px) rotate3d(1,0,0,-20deg);
                -webkit-transition-timing-function: ease-in;
                transition-timing-function: ease-in;
            }

            60% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,10deg);
                -ms-transform: perspective(400px) rotate3d(1,0,0,10deg);
                transform: perspective(400px) rotate3d(1,0,0,10deg);
                opacity: 1;
            }

            80% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,-5deg);
                -ms-transform: perspective(400px) rotate3d(1,0,0,-5deg);
                transform: perspective(400px) rotate3d(1,0,0,-5deg);
            }

            100% {
                -webkit-transform: perspective(400px);
                -ms-transform: perspective(400px);
                transform: perspective(400px);
            }
        }

        .flipInX {
            -webkit-backface-visibility: visible!important;
            -ms-backface-visibility: visible!important;
            backface-visibility: visible!important;
            -webkit-animation-name: flipInX;
            animation-name: flipInX;
        }

        @-webkit-keyframes flipOutX {
            0% {
                -webkit-transform: perspective(400px);
                transform: perspective(400px);
            }

            30% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,-20deg);
                transform: perspective(400px) rotate3d(1,0,0,-20deg);
                opacity: 1;
            }

            100% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,90deg);
                transform: perspective(400px) rotate3d(1,0,0,90deg);
                opacity: 0;
            }
        }

        @keyframes flipOutX {
            0% {
                -webkit-transform: perspective(400px);
                -ms-transform: perspective(400px);
                transform: perspective(400px);
            }

            30% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,-20deg);
                -ms-transform: perspective(400px) rotate3d(1,0,0,-20deg);
                transform: perspective(400px) rotate3d(1,0,0,-20deg);
                opacity: 1;
            }

            100% {
                -webkit-transform: perspective(400px) rotate3d(1,0,0,90deg);
                -ms-transform: perspective(400px) rotate3d(1,0,0,90deg);
                transform: perspective(400px) rotate3d(1,0,0,90deg);
                opacity: 0;
            }
        }

        .flipOutX {
            -webkit-animation-name: flipOutX;
            animation-name: flipOutX;
            -webkit-animation-duration: .75s;
            animation-duration: .75s;
            -webkit-backface-visibility: visible!important;
            -ms-backface-visibility: visible!important;
            backface-visibility: visible!important;
        }

        .return2game {
            width:94%;
            display: block;
            text-decoration: none;
            color: #fff;         
            background: rgb(223,25,42);
            padding: 8px 25px;
            letter-spacing: 2px;
            font-size: 1.2em;
            margin: 10px auto 0 auto;
            text-align: center;
            box-sizing:border-box;
            font-weight:bold;
        }
    </style>
</head>
<body>
    <div class="qrcontainer">
    </div>
    <div class="qrimg animated">
        <img id="giftimg" src="" alt="" />
        <div class="closeqr">
            <a class="closemodal" onclick="closeModal()">
                <svg class="" viewBox="0 0 24 24">
                    <path d="M19 6.41l-1.41-1.41-5.59 5.59-5.59-5.59-1.41 1.41 5.59 5.59-5.59 5.59 1.41 1.41 5.59-5.59 5.59 5.59 1.41-1.41-5.59-5.59z" />
                    <path d="M0 0h24v24h-24z" fill="none" />
                </svg>
            </a>
        </div>
        <div class="qrdesc">
            请持本二维码至礼品领取处兑奖            
        </div>
    </div>
    <div class="searchbtn floatfix">
        <ul class="floatfix">
            <li name="all" class="selected" onclick="switchbtn('all')">全部</li>
            <li name="wjh" onclick="switchbtn('wjh')">去激活</li>
            <li name="wlq" onclick="switchbtn('wlq')">去领取</li>
            <li name="ylq" onclick="switchbtn('ylq')">已领取</li>
        </ul>
    </div>
    <div class="topinfo">提示:礼品领取时间为:每天8:30 ～ 9:30</div>
    <div class="infolab"></div>
    <div class="card" style="opacity: 1; width: 120px; height: 40px; overflow: hidden; margin: 5px auto -7px auto; font-size: 1.1em;">
        <div class="cardl" style="width: 80px; height: 40px; line-height: 30px; vertical-align: middle; font-weight: bold; text-align: center; padding: 5px 0px;">礼券数</div>
        <div id="giftnums" class="cardr" style="background: #fff; width: 40px; height: 40px; line-height: 30px; vertical-align: middle; font-weight: bold; text-align: center; padding: 5px 0px; color: #333;">-</div>
    </div>
    <div class="container">
    </div>
    <div><a href="ggkGame.aspx" class="return2game">去 刮 奖</a></div>
    <div id="info">
        <div class="box">
            <strong>相关说明：</strong>
            <p><strong>每张礼券都必须激活后才能领取！</strong></p>
            <p>1.点击【去领取】的礼券将得到一个二维码，用户凭借此码去换取相应礼品；</p>
            <p>2.礼品领取时间为：2015.12.18-2016.1.30 每天8:30-9:30；</p>
            <p>3.礼品领完即止,先到先得；</p>
            <p>4.请在礼券的有效期内使用,否则将失效；</p>
            <p><strong>5.本活动最终解释权归举办方所有！</strong></p>
        </div>
    </div>
    <div class="copyright">
        &copy;2015 利郎信息技术部
    </div>
    <script src="js/jquery.js" type="text/javascript"></script>
    <script src="js/sweet-alert.min.js" type="text/javascript"></script>
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
        var userid = "<%=userid%>", isRegister = "<%=isRegister%>";
        function switchbtn(btnname) {
            $(".searchbtn ul li").removeClass("selected");
            switch (btnname) {
                case "all":
                    $(".searchbtn ul li[name='all']").addClass("selected");
                    getmygift(userid, "");
                    break;
                case "ylq":
                    $(".searchbtn ul li[name='ylq']").addClass("selected");
                    getmygift(userid, "11");
                    break;
                case "wlq":
                    $(".searchbtn ul li[name='wlq']").addClass("selected");
                    getmygift(userid, "01");
                    break;
                case "wjh":
                    $(".searchbtn ul li[name='wjh']").addClass("selected");
                    getmygift(userid, "00");
                    break;
            }
        }

        window.onload = function () {
            if (userid == "" || userid == "0") {
                alert("加载用户数据失败，请重新进入！");
                return;
            } else if (isRegister == "0") {
                swal({
                    title: "您还没登记领奖信息，无法查看礼券！",
                    text: '领奖信息只需登记一次',
                    type: "warning",
                    showCancelButton: false,
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "去登记",
                    closeOnConfirm: true
                }, function (isConfirm) {
                    if (isConfirm) {
                        window.location.href = "RegisterUserInfo.aspx";
                    }
                });
                return;
            }
            getmygift(userid, "");
        }

        function getmygift(userid, filter) {
            $(".infolab").text("正在加载数据,请稍候...").show();
            $.ajax({
                type: "POST",
                timeout: 2000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "ggkProcess.aspx",
                data: { ctrl: "GetMyGifts", userid: userid, filter: filter },
                success: function (msg) {
                    if (msg.indexOf("Successed") > -1) {
                        msg = msg.replace("Successed", "");
                        if (msg == "") {
                            $(".container").children().remove();
                            $(".infolab").text("您还没有相关礼券！");
                        } else {
                            var data = JSON.parse(msg);
                            var len = data.rows.length;
                            var htmlStr = "";
                            for (var i = 0; i < len; i++) {
                                var row = data.rows[i];
                                var getname = "", getcss = "cardr";
                                if (row.isvalid == "1") {
                                    if (row.isget == "False" && row.isactive == "False")
                                        getname = "去激活";
                                    else if (row.isget == "False" && row.isactive == "True") {
                                        getname = "去领取";
                                        getcss = "cardr cc"
                                    }
                                    else if (row.isget = "True" && row.isactive == "True") {
                                        getname = "已领取";
                                        getcss = "cardr ee";
                                    }
                                    else {
                                        getname = "已失效";
                                        getcss = "cardr dd";
                                    }
                                } else {
                                    getname = "已失效";
                                    getcss = "cardr dd";
                                }
                                htmlStr += "<div class='card' onclick=showGiftQRcode('" + row.gametoken + "','" + getname + "','" + row.gameid + "')><div class='cardl'><div class='ltop'>利郎2015福利会礼券</div><div class='lcenter'>" + row.prizename + "</div>";
                                htmlStr += "<div class='lbottom'>来源:<strong>" + row.gamename + "</strong> 时间:" + row.gametime + "<br />礼券有效期：" + row.validtime + "</div>";
                                htmlStr += "</div><div class='" + getcss + "'><div class='lr'>" + getname + "</div></div></div>";
                            }//end for
                            $(".container").children().remove();
                            $(".container").append(htmlStr);
                            $(".infolab").text("加载礼券成功！").fadeOut(1000);
                            //var obj = $(".container").children('[rel!=loaded]');
                            //obj.attr("rel", "loaded");
                            //obj.fadeInWithDelay();
                        }

                        $("#giftnums").text($(".container").children().length);
                    } else if (msg.indexOf("TimeOut:SESSION超时") > -1) {
                        window.location.reload();
                        return;
                    } else
                        alert(msg);
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("您的网络不给力，请重试！");
                }
            });
        }

        function showGiftQRcode(gametoken, getname, gameid) {
            window.location.href = "http://tm.lilanz.com/supersalegames/GiftDetail2.aspx?token=" + gametoken + "&gameid=" + gameid;
            //if (getname == "可领取") {
            //    $("#giftimg").attr("src", "http://tm.lilanz.com/WebBLL/WX2wCodeProject/GetQrCode.aspx?code=" + gametoken);
            //    $(".qrcontainer").show();
            //    $(".qrimg").show().removeClass("animated flipInX").addClass("animated flipInX");
            //} else if (getname == "未激活") {
            //    window.location.href = "http://tm.lilanz.com/supersalegames/GiftDetail.aspx?token=" + gametoken + "&gameid=" + gameid;
            //}
        }

        function closeModal() {
            $(".qrimg").removeClass("animated flipInX");
            $(".qrimg").fadeOut(500);
            $(".qrcontainer").fadeOut(300);
        }

        $(".qrcontainer").click(function () {
            $(".qrimg").removeClass("animated flipInX");
            $(".qrimg").fadeOut(500);
            $(".qrcontainer").fadeOut(300);
        });

        $.fn.fadeInWithDelay = function () {
            var delay = 0;
            return this.each(function () {
                $(this).delay(delay).animate({ opacity: 1 }, 200);
                delay += 100;
            });
        };
    </script>
</body>
</html>
