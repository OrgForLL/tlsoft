<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
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
            return;
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
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <title></title>
    <link href="css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }

        body {
            font-family: "微软雅黑";
            background: #eceef1;
            color: #333;
        }

        .container {
            margin-top: 90px;
            margin-bottom: 20px;
        }

        .pagetitle {
            background: #fff;
            /*background-image: linear-gradient(to bottom,#e9e9e9 0,#e0e0e0 100%);
            background-image: -webkit-gradient(linear,left top,left bottom,from(#e9e9e9),to(#e0e0e0));
            background-image: -webkit-linear-gradient(top,#e9e9e9 0,#e0e0e0 100%);*/
            height: 70px;
            text-align: center;
            line-height: 70px;
            font-size: 1.5em;
            font-weight: bold;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 100;
            border-bottom:1px solid #d9dadc;
        }

        .card {
            width: 94%;
            margin: 0 auto;
            padding: 10px 0 12px 0;
            /*background: #5cb85c;*/
            background: #454243;
            box-sizing: border-box;
            border-radius: 5px;
            margin-top: 20px;
            max-width: 420px;
            cursor: pointer;
        }

        .stitle {
            text-align: center;
            font-size: 16px;
            color: #fff;
            letter-spacing: 1px;
        }

        hr {
            width: 50%;
            border-bottom: 2px solid #fff;
            margin: 8px auto;
        }

        .prizename {
            font-weight: bold;
            font-size: 2.1em;
            text-align: center;
            color: #fff;
            padding: 10px;
            letter-spacing: 4px;
            text-shadow: 1px 1px 1px #555;
        }

        .status {
            width: 84px;
            text-align: center;
            font-size: 1em;
            margin: 0 auto;
            border: 1px solid #fff;
            border-radius: 4px;
            padding: 5px 0;
            color: #333;
            letter-spacing: 2px;
            background-color: #fff;
            font-weight: bold;
        }

        .cc {
            background: #5cb85c;
        }

        .dd {
            background: #ccc;
        }

        .ee {
            background: #d9534f;
        }

        .effect2 {
            position: relative;
        }

            .effect2:before, .effect2:after {
                z-index: -1;
                position: absolute;
                content: "";
                bottom: 15px;
                left: 10px;
                width: 50%;
                top: 80%;
                max-width: 300px;
                background: #777;
                -webkit-box-shadow: 0 15px 10px #777;
                -moz-box-shadow: 0 15px 10px #777;
                box-shadow: 0 15px 10px #777;
                -webkit-transform: rotate(-3deg);
                -moz-transform: rotate(-3deg);
                -o-transform: rotate(-3deg);
                -ms-transform: rotate(-3deg);
                transform: rotate(-3deg);
            }

            .effect2:after {
                -webkit-transform: rotate(3deg);
                -moz-transform: rotate(3deg);
                -o-transform: rotate(3deg);
                -ms-transform: rotate(3deg);
                transform: rotate(3deg);
                right: 10px;
                left: auto;
            }

        .effect4 {
            position: relative;
        }

            .effect4:after {
                z-index: -1;
                position: absolute;
                content: "";
                bottom: 15px;
                right: 10px;
                left: auto;
                width: 50%;
                top: 80%;
                max-width: 300px;
                background: #777;
                -webkit-box-shadow: 0 15px 10px #777;
                -moz-box-shadow: 0 15px 10px #777;
                box-shadow: 0 15px 10px #777;
                -webkit-transform: rotate(3deg);
                -moz-transform: rotate(3deg);
                -o-transform: rotate(3deg);
                -ms-transform: rotate(3deg);
                transform: rotate(3deg);
            }


        .giftdetail {
            text-align: center;
            margin-top: 15px;
            padding: 4px 0;
            font-size: 0.8em;
            background: rgba(52,52,52,0.2);
            color: #fff;
        }

        .infos {
            width: 94%;
            margin: 20px auto 0 auto;
            padding: 10px;
            border: 1px solid #e2e2e2;
            box-sizing: border-box;
            border-radius: 5px;
            background: #fff;
            max-width: 420px;
        }

        .copyright {
            margin: 15px auto 0 auto;
            text-align: center;
            font-size: 1em;
            color: #808080;
        }

        .infolab {
            text-align: center;
            font-size: 1.2em;
            color: #333;
            font-weight: bold;
            margin-bottom: -10px;
            margin-top: 10px;            
        }

        /*animated*/
        .animated {
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

        .topinfo {
            width: 94%;
            margin: -5px auto -5px auto;
            font-size: 1em;
            font-weight: bold;
            color: rgb(223,25,42);
            text-align: center;
        }

        .return2game {
            width: 94%;
            display: block;
            text-decoration: none;
            color: #fff;
            padding: 8px 25px;
            letter-spacing: 2px;
            font-size: 1.2em;
            margin: 20px auto 0 auto;
            border-radius: 2px;
            text-align: center;
            box-sizing: border-box;
            font-weight: bold;
            max-width: 420px;
            background-image: linear-gradient(to bottom,#5cb85c 0,#419641 100%);
            background-image: -webkit-gradient(linear,left top,left bottom,from(#5cb85c),to(#419641));
            background-image: -webkit-linear-gradient(top,#5cb85c 0,#419641 100%);
        }

        @-webkit-keyframes shake {
            0%,10%,20%,30%,40%,100% {
                -webkit-transform: translate3d(0,0,0);
                transform: translate3d(0,0,0);
            }

            50%,70%,90% {
                -webkit-transform: translate3d(-10px,0,0);
                transform: translate3d(-10px,0,0);
            }

            60%,80% {
                -webkit-transform: translate3d(10px,0,0);
                transform: translate3d(10px,0,0);
            }
        }

        @keyframes shake {
            0%,10%,20%,30%,40%,100% {
                -webkit-transform: translate3d(0,0,0);
                -ms-transform: translate3d(0,0,0);
                transform: translate3d(0,0,0);
            }

            50%,70%,90% {
                -webkit-transform: translate3d(-10px,0,0);
                -ms-transform: translate3d(-10px,0,0);
                transform: translate3d(-10px,0,0);
            }

            60%,80% {
                -webkit-transform: translate3d(10px,0,0);
                -ms-transform: translate3d(10px,0,0);
                transform: translate3d(10px,0,0);
            }
        }

        .shake {
            -webkit-animation-name: shake;
            animation-name: shake;
            -webkit-animation-iteration-count: infinite;
            animation-iteration-count: infinite;
            -webkit-animation-duration:1s;
            animation-duration:1s;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="pagetitle">
            我 的 礼 券                 
        </div>
        <div class="topinfo">本次活动已结束，请您继续关注利郎！</div>
        <div class="infolab">正在加载数据，请稍候...</div>
        <div id="gifts">
        </div>
        <div><a href="ggkGame.aspx" class="return2game">去 刮 奖</a></div>
        <div class="infos">
            <p style="font-size: 1.2em; line-height: 30px; text-align: center; font-weight: bold;">- 相关说明 -</p>
            <p><strong>每张礼券都必须激活后才能领取！</strong></p>
            <p>1.单击【点击领取】的礼券将得到一个二维码，用户凭借此码去换取相应礼品；</p>
            <p>2.礼品领取时间为：2015.12.18-2016.1.30 每天8:30-9:30；</p>
            <p>3.礼品领完即止,先到先得；</p>
            <p>4.请在礼券的有效期内使用,否则将失效；</p>
            <p>5.请持本人身份证或中奖微信号到利郎总部领奖处领奖；</p>
            <p><strong>6.本活动最终解释权归举办方所有！</strong></p>
        </div>
        <div class="copyright">&copy;2015 利郎信息技术部</div>
    </div>
    <script src="js/jquery.js" type="text/javascript"></script>
    <script src="js/sweet-alert.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        var userid = "<%=userid%>", isRegister = "<%=isRegister%>";
        window.onload = function () {
            //if (userid == "" || userid == "0") {
            //    //alert("加载用户数据失败，请重新进入！");
            //    swal({
            //        title: "您的网络好像出了点问题,请重新进入！",
            //        text: '',
            //        type: "error",
            //        showCancelButton: false,
            //        confirmButtonColor: "#DD6B55",
            //        confirmButtonText: "-确 定-",
            //        closeOnConfirm: true
            //    });
            //    return;
            //} else if (isRegister == "0") {
            //    swal({
            //        title: "您还没登记领奖信息，无法查看礼券！",
            //        text: '领奖信息只需登记一次',
            //        type: "warning",
            //        showCancelButton: false,
            //        confirmButtonColor: "#DD6B55",
            //        confirmButtonText: "去登记",
            //        closeOnConfirm: true
            //    }, function (isConfirm) {
            //        if (isConfirm) {
            //            window.location.href = "RegisterUserInfo.aspx";
            //        }
            //    });
            //    return;
            //}

            //$(".infolab").text("正在加载数据,请稍候...").show();
            //getmygift(userid, "");
        }


        function getmygift(userid, filter) {
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
                            //$(".container").children().remove();
                            $(".infolab").text("您还没有相关礼券！").show();
                        } else {
                            var data = JSON.parse(msg);
                            var len = data.rows.length;
                            var htmlStr = "";
                            for (var i = 0; i < len; i++) {
                                var row = data.rows[i];
                                var getname = "", getcss = "", aniname = "";
                                if (row.isvalid == "1") {
                                    if (row.isget == "False" && row.isactive == "False")
                                        getname = "点击激活";
                                    else if (row.isget == "False" && row.isactive == "True") {
                                        getname = "点击领取";
                                        aniname = " animated shake";
                                        getcss = " cc"
                                    }
                                    else if (row.isget = "True" && row.isactive == "True") {
                                        getname = "已领取";
                                        getcss = " ee";
                                    }
                                    else {
                                        getname = "过期失效";
                                        getcss = " dd";
                                    }
                                } else {
                                    getname = "过期失效";
                                    getcss = " dd";
                                }

                                htmlStr += "<div class='card effect4" + getcss + "' onclick=showGiftQRcode('" + row.gametoken + "','" + row.gameid + "')><p class='stitle'>利郎2015福利会礼券</p>";
                                htmlStr += "<p class='prizename'>" + row.prizename + "</p><p class='status " + aniname + "'>" + getname + "</p>";
                                htmlStr += "<div class='giftdetail'><p>来源:<strong>" + row.gamename + "</strong> 时间:" + row.gametime + "</p><p>礼券有效期:" + row.validtime + "</p></div></div>";
                            }//end for
                            $("#gifts").children().remove();
                            $("#gifts").append(htmlStr);
                            $(".infolab").text("加载礼券成功！").fadeOut(1000);
                        }
                    } else if (msg.indexOf("TimeOut:SESSION超时") > -1) {
                        window.location.reload();
                        return;
                    } else
                        alert(msg);
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    swal({
                        title: "您的网络好像出了点问题,请重新进入！",
                        text: '',
                        type: "error",
                        showCancelButton: false,
                        confirmButtonColor: "#DD6B55",
                        confirmButtonText: "-确 定-",
                        closeOnConfirm: true
                    });
                }
            });
        }


        function showGiftQRcode(gametoken, gameid) {
            window.location.href = "GiftDetail2.aspx?token=" + gametoken + "&gameid=" + gameid;
        }
    </script>

    <script>
        var _hmt = _hmt || [];
        (function () {
            var hm = document.createElement("script");
            hm.src = "//hm.baidu.com/hm.js?f274c2a4c37455fe3bba3b7477d74d26";
            var s = document.getElementsByTagName("script")[0];
            s.parentNode.insertBefore(hm, s);
        })();
    </script>
</body>
</html>
