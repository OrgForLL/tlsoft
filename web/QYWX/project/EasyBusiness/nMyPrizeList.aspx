<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server">
    public string UID = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        UID = Convert.ToString(Session["QSW_UID"]);
        string OAuth = Convert.ToString(Request.Params["OAuth"]);
        if (UID == "" || UID == "0" || UID == null)
        {
            if (OAuth == "WeiXin")
            {
                //当程序部署在微信环境下且未登陆时则自动鉴权登陆
                string gourl = HttpUtility.UrlEncode("http://tm.lilanz.com/project/EasyBusiness/QSWOauthAndRedirect.aspx?rand=");
                string curURL = HttpUtility.UrlEncode(Request.Url.ToString());
                string OauthURL = @"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx60aada4e94aa0b73&redirect_uri={0}&response_type=code&scope=snsapi_userinfo&state={1}#wechat_redirect";
                OauthURL = string.Format(OauthURL, gourl, curURL);
                Response.Redirect(OauthURL);
                Response.End();
            }
            else
                clsSharedHelper.WriteErrorInfo("用户身份超时！");
        }
    }
</script>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0">
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <meta name="format-detection" content="telephone=no" />
    <title>我的礼券</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        body {
            background-color: #eee;
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
        }

        .wrapper {            
            padding-bottom: 30px;
        }

        .stamp {
            margin: 0 auto;
            width: 94%;
            height: 140px;
            padding: 10px;
            position: relative;
            overflow: hidden;
            margin-top: 15px;
            box-sizing: border-box;
        }

            .stamp:before {
                content: '';
                position: absolute;
                top: 0;
                bottom: 0;
                left: 10px;
                right: 0;
                z-index: -1;
            }

            .stamp i {
                position: absolute;
                left: 20%;
                top: 45px;
                height: 190px;
                width: 390px;
                background-color: rgba(255,255,255,.15);
                transform: rotate(-30deg);
            }

            .stamp .par {
                float: left;
                height: 120px;
                padding: 0 10px;
                width: 60%;
                border-right: 2px dashed rgba(255,255,255,.3);
                text-align: left;
                box-sizing: border-box;
            }

                .stamp .par .gmid {
                    text-align: center;
                    height: 70px;
                    line-height: 70px;
                }

                .stamp .par p {
                    color: #fff;
                    height: 25px;
                    line-height: 25px;
                }

                .stamp .par span {
                    font-size: 2.1em;
                    color: #fff;
                    margin-right: 5px;
                    line-height: 2.4em;
                    font-weight: bold;
                }

                .stamp .par sub {
                    position: relative;
                    top: -5px;
                    color: rgba(255,255,255,.8);
                }

            .stamp .copy {
                display: inline-block;
                width: 40%;
                font-size: 1.4em;
                color: rgb(255,255,255);
                box-sizing: border-box;
                text-align: center;
                height: 120px;
                vertical-align: middle;
                position: relative;
            }

                .stamp .copy p {
                    font-size: 16px;
                    height: 36px;
                    line-height: 36px;
                }

                .stamp .copy .getnow {
                    background-color: #fff;
                    color: #333;
                    text-decoration: none;
                    padding: 5px;
                    display: block;
                    width: 60%;
                    border-radius: 4px;
                    font-size: 0.75em;
                    margin: 11px auto 0 auto;
                    height: 20px;
                    line-height: 20px;
                    position: relative;
                    z-index: 1000;
                }

        .stamp02 {
            background: #F39B00;
            background: radial-gradient(transparent 0, transparent 5px, #F39B00 5px);
            background-size: 15px 15px;
            background-position: 9px 3px;
        }

            .stamp02:before {
                background-color: #F39B00;
            }

        .stamp01 {
            background: #D24161;
            background: radial-gradient(transparent 0, transparent 5px, #D24161 5px);
            background-size: 15px 15px;
            background-position: 9px 3px;
        }

            .stamp01:before {
                background-color: #D24161;
            }

        .stamp03 {
            background: #7EAB1E;
            background: radial-gradient(transparent 0, transparent 5px, #7EAB1E 5px);
            background-size: 15px 15px;
            background-position: 9px 3px;
        }

            .stamp03:before {
                background-color: #7EAB1E;
            }

        .stamp04 {
            background: #7EAB1E;
            background: radial-gradient(transparent 0, transparent 5px, #50ADD3 5px);
            background-size: 15px 15px;
            background-position: 9px 3px;
        }

            .stamp04:before {
                background-color: #50ADD3;
            }

        .no-result {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%,-50%);
            -webkit-transform: translate(-50%,-50%);
            color: #888;
            font-size: 16px;
            display: none;
            white-space: nowrap;
        }
        .tips {
            padding:10px;
            background-color:#D24161;
            color:#fff;
            font-weight:bold;
            font-size:14px;
        }
        .copy {
            position:fixed;
            left:0;
            bottom:0;
            width:100%;
            height:30px;
            line-height:30px;
            color:#999;
            text-align:center;
        }
        .backgame {
            display:block;
            width:94%;
            text-align:center;
            text-decoration:none;
            padding:8px 0;
            color:#D24161;
            margin:15px auto 0 auto;
            font-size:16px;
        }
        .expire {
            filter: grayscale(100%);
            -webkit-filter: grayscale(100%);
            pointer-events:none;            
        }
    </style>
</head>
<body>    
    <div class="wrapper">
        <div class="tips">领奖说明：中奖者请于2016年9月30日至10月9日期间，微信玩家关注【利郎轻商务】公众号凭【找乐】-【最新活动】菜单中的二维码亲自到店(天津市和平区滨江道143号光明影院一楼)领取（二维码截图无效），逾期未领奖者将当成自动放弃中奖资格！</div>
        <div id="stamps">
        </div>
        <a class="backgame" href="nggkGame.aspx"><-- 返回游戏</a>
    </div>
    <div class="no-result">Sorry，您暂时还没有中奖记录！</div>
    <div class="copy">&copy;2016 利郎轻商务</div>
    <script src="../../res/js/jquery.js" type="text/javascript"></script>
    <script type="text/javascript">
        window.onload = function () {
            var userid = "<%=UID%>";
            if (userid == "" || userid == undefined || userid == null)
                alert("请先使用微博或微信登陆后再打开此页面！");
            else {
                var giftTemp = "<div class='stamp stamp01 #classname#'><div class='par'><p>庆祝利郎轻商务天津店开业</p><p class='gmid'><span>#prizename#</span><sub>礼券</sub></p><p>#prizedesc#</p></div><div class='copy'><p>2016.09.30</p><p>2016.10.09</p><a href='javascript:' onclick=\"getPrize('#gametoken#',this)\" class='getnow'>#isget#</a></div><i></i></div>";
                $.ajax({
                    type: "POST",
                    timeout: 10000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "nggkProcess.aspx",
                    data: { ctrl: "GetMyGifts", userid: userid, filter: "" },
                    success: function (msg) {
                        if (msg.indexOf("Successed") > -1) {
                            var htmlStr = "";
                            var obj = JSON.parse(msg.replace("Successed", ""));
                            for (var i = 0; i < obj.rows.length; i++) {
                                var row = obj.rows[i];
                                row.classname = row.isget == "True" ? "expire" : "";
                                row.isget = row.isget == "True" ? "已领取" : "马上领取";                                
                            }
                            $.each(obj.rows, function (j, el) {
                                htmlStr += giftTemp.temp(el);
                            });

                            $("#stamps").empty().append(htmlStr);
                        } else if (msg == "") {
                            $(".no-result").show();
                        } else
                            alert("获取个人中奖记录失败,请稍后重试！" + msg);
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                    }
                });
            }//end else
        }

        String.prototype.temp = function (obj) {
            return this.replace(/\#\w+\#/gi, function (matchs) {
                var returns = obj[matchs.replace(/\#/g, "")];
                return (returns + "") == undefined ? "" : returns;
            });
        }

        function getPrize(token,obj) {
            var url = "PrizeQRCode.aspx?OAuth=WeiXin&GameToken=" + token;
            var isget = $(obj).text();
            if (isget == "已领取")
                alert("对不起,该礼券已经使用过了！");
            else
                window.location.href = url;
        }
    </script>
</body>
</html>
