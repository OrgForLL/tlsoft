<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html>
<script runat="server">    
    public string userid = "";
    public string gamenums = "0";
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
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM("server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456"))
            {
                string str_sql = @"select gamecount-nowcount from wx_t_vipbinging where id=" + userid;
                DataTable dt = null;
                string errinfo = dal.ExecuteQuery(str_sql, out dt);
                if (errinfo == "" && dt.Rows.Count > 0)
                    gamenums = dt.Rows[0][0].ToString();
                else
                    clsSharedHelper.WriteErrorInfo("查询用户游戏次数失败！" + errinfo);
            }
        }
    }

    public static void writeLog(string info)
    {
        try
        {
            clsLocalLoger.logDirectory = HttpContext.Current.Server.MapPath("logs/");
            if (System.IO.Directory.Exists(clsLocalLoger.logDirectory) == false)
            {
                System.IO.Directory.CreateDirectory(clsLocalLoger.logDirectory);
            }
            clsLocalLoger.WriteInfo(info);
        }
        catch (Exception ex)
        {

        }
    }
</script>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0">
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <meta name="format-detection" content="telephone=no" />
    <title>利郎2015福利会-刮刮卡</title>
    <link href="css/activity-style.css" rel="stylesheet" type="text/css">
    <link href="css/sweet-alert.css" rel="stylesheet" type="text/css">
    <style type="text/css">
        .info {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            text-align: center;
            background-color: rgba(51,51,51,0.6);
            z-index: 2000;
            font-size: 1.2em;
        }

        .Detail {
            text-align: center;
        }

        .main {
            margin-top: 10px;
        }

        .copyright {
            margin: 15px auto;
            text-align: center;
            font-size: 1em;
            color: #ccc;
        }

        #zjl {
            position: absolute;
            width: 100%;
            bottom: 0;
            margin: 0;
            box-sizing: border-box;
            display: none;
        }

        .gamenums {
            color: #ebebeb;
            font-size: 1.2em;
            text-align: center;
        }

        #gamenums {
            color: #f00;
            font-weight: bold;
            font-size: 1.4em;
        }

        .playagain {
            display: inline-block;
            text-decoration: none;
            width: 80px;
            margin: 10px auto 0 auto;
            padding: 5px 10px;
        }

            .playagain:last-child {
                margin-left: 10px;
            }

        .sweet-alert button.cancel {
            background-color: rgb(221, 107, 85);
        }

        .btn2 {
            display: inline-block;
            width: 48%;
        }

        /*获奖名单样式*/
        #titlebg {
            background: url(img/title-bg-brown2.png) no-repeat 0 0;
        }

        .example {
            overflow: hidden;
            height: 270px;
            text-align: center;
        }

        .container {
            text-align: center;
            list-style: none;
            overflow: hidden;
        }

            .container li {
                font-size: 1.1em;
                padding: 7px 0 5px 0;
                border-bottom: 1px dashed #808080;
            }

                .container li span {
                    display: inline-block;
                    white-space: nowrap;
                    text-overflow: ellipsis;
                    overflow: hidden;
                    width: 30%;
                    height: 100%;
                    line-height: 100%;
                }

        .cube3d {
            -webkit-transform: translateZ(0);
            -moz-transform: translateZ(0);
            -ms-transform: translateZ(0);
            -o-transform: translateZ(0);
            transform: translateZ(0);            
        }
    </style>
</head>
<body data-role="page" class="activity-scratch-card-winning">
    <div class="info">
        <div id="zjl" class="boxcontent boxwhite">
            <div class="box">
                <div class="title-red">
                    <span>领奖信息登记
                    </span>
                </div>
                <div class="Detail" style="padding-top: 0;">
                    <p class="red"></p>
                    <p>
                        <input name="" class="px" id="username" type="text" value="" placeholder="请输入您的姓名">
                    </p>
                    <p>
                        <input name="" class="px" id="idcard" type="text" value="" placeholder="请输入您的身份证号码">
                    </p>
                    <p>
                        <input name="" class="px" id="tel" value="" type="text" placeholder="请输入您的手机号码">
                    </p>
                    <p>
                        <input class="pxbtn" name="提 交" id="save-btn" type="button" value="提交">
                        <%--<input class="pxbtn btn2" style="background-image: linear-gradient( #ccc, #808080); border: 1px solid #ccc; border-bottom: none;" name="待会登记" id="cancelsave" type="button" value="待会登记">--%>
                    </p>
                </div>
            </div>
        </div>
    </div>
    <div class="main">
        <div class="cover cube3d">
            <img src="img/activity-scratch-card-bannerbg2.png">
            <div id="prize">
            </div>
            <div id="scratchpad">
            </div>
        </div>
        <div class="content">
            <div class="gamenums">亲爱的用户您当天还有 <span id="gamenums"><%=gamenums %></span> 次刮奖机会</div>
            <div style="text-align: center;">
                <a href="#" onclick="playagain()" class="pxbtn playagain" id="againbtn">再玩一次</a>
                <a href="#" onclick="javascript:window.location.href='MyPrizeList.aspx';" class="pxbtn playagain">我的礼券</a>
            </div>
            <div class="boxcontent boxwhite">
                <div class="box">
                    <div class="title-brown">
                        <span>奖项设置：
                        </span>
                    </div>
                    <div class="Detail">
                        <p>
                            一等奖： 价值500元左右精美礼品。
                        </p>
                        <p>
                            二等奖： 价值99元左右精美礼品。
                        </p>
                        <p>
                            三等奖： 精美礼品一份。
                        </p>
                        <p>
                            纪念奖： 限量福利券2张
                        </p>
                    </div>
                </div>
            </div>

            <div class="boxcontent boxwhite">
                <div class="box">
                    <div class="title-brown" id="titlebg">
                        获奖名单(最新100名)：
                    </div>
                    <div class="Detail" style="text-align: left;">
                        <div class="smartmarquee example">
                            <ul class="container" id="queeul">
                                <li>正在加载...
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <div class="boxcontent boxwhite">
                <div class="box">
                    <div class="title-brown">
                        游戏规则：
                    </div>
                    <div class="Detail" style="text-align: left;">
                        <p>
                            1.每天礼品数量有限，先到先得，领完即止；
                        </p>
                        <p>
                            2.可以通过扫描相关活动二维码来获取游戏机会；
                        </p>
                        <p>
                            3.每个微信用户每天可以通过不同方式获取游戏机会,详情请点击【获取机会】按钮查看；
                        </p>
                        <p>
                            4.活动期间:2015.12.18-2016.1.30，每天<strong>8:30-9:30</strong>可以凭【LILANZ利郎商务男装】公众号菜单【我的礼券】中的相关信息或身份证到现场领取礼品；
                        </p>
                        <p>
                            5.请持本人身份证到利郎总部领奖处领奖；
                        </p>
                        <p>
                            <strong>6.本活动最终解释权归举办方所有！</strong>
                        </p>
                    </div>
                </div>
            </div>
        </div>
        <div style="clear: both;">
        </div>
    </div>
    <div class="copyright">&copy;2015 利郎信息技术部</div>
    <script src="js/jquery.js" type="text/javascript"></script>
    <script src="js/wScratchPad.js" type="text/javascript"></script>
    <script src="js/sweet-alert.min.js" type="text/javascript"></script>
    <script src="js/jquery.smartmarquee.js" type="text/javascript"></script>
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
        var gametoken = "", userid = "<%=userid%>", prizeID = "", prizeName = "", gameid = "1";
        var goon = true, isResgister = true, isShow = false, isConsume = false;
        window.onload = function () {
            if (userid == "" || userid == "0") {
                swal({ title: "用户信息为空！", text: "-请尝试重新进入！-", type: "error", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "确定", closeOnConfirm: true });
                //alert("用户信息为空！");
                return;
            }
            if ($("#gamenums").text() == "0")
                $("#againbtn").text("获取机会");
            //canplay();
            //loadPrizer100();
            swal({
                title: "本次活动已结束！",
                text: "请您继续关注利郎，利郎有您更精彩！",
                type: "warning",
                showCancelButton: false,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "确定",
                closeOnConfirm: true
            });
        }

        //判断用户是否能玩
        function canplay() {
            $.ajax({
                type: "POST",
                timeout: 10000,
                async: true,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "ggkProcess.aspx",
                data: { ctrl: "IsCanPlay", gameid: gameid, userid: userid },
                success: function (msg) {
                    if (msg.indexOf("Successed:") > -1) {
                        msg = msg.replace("Successed:", "");
                        var arr = msg.split("|");
                        gametoken = arr[0];
                        prizeID = arr[1];
                        prizeName = arr[2];
                        //添加刮层效果
                        $("#scratchpad").wScratchPad({
                            size: 20,//擦除的半径大小
                            width: 150,
                            height: 80,
                            color: "#a9a9a7",
                            scratchMove: function (e, percent) {
                                if (percent > 0 && goon) {
                                    $("#prize").html(prizeName);
                                    goon = false;
                                    ConsumeToken();
                                }
                                if (percent > 40 && isConsume) {
                                    //谢谢参与
                                    if (!isShow && prizeID == "0") {
                                        isShow = true;
                                        swal({
                                            title: "很遗憾,您没有刮中礼品.",
                                            text: "可以获取更多机会再来试试手气~~",
                                            type: "warning",
                                            showCancelButton: false,
                                            confirmButtonColor: "#DD6B55",
                                            confirmButtonText: "确定",
                                            closeOnConfirm: true
                                        });
                                        return;
                                    }

                                    if (!isShow && prizeID != "0") {
                                        isShow = true;
                                        if (isResgister) {
                                            swal({
                                                title: "中奖啦~",
                                                text: "恭喜您刮中了【" + prizeName + "】,点击查看礼券激活后即可兑换礼品！",
                                                confirmButtonColor: "rgb(89, 167, 20)",
                                                confirmButtonText: "再玩一次",
                                                showCancelButton: true,
                                                cancelButtonText: "查看礼券",
                                                closeOnConfirm: false,
                                                closeOnCancel: false
                                            },
                                                function (isConfirm) {
                                                    if (isConfirm) {
                                                        window.location.reload();
                                                    } else {
                                                        window.location.href = "MyPrizeList.aspx";
                                                    }
                                                });
                                        } else {
                                            $(".info").show();
                                            $("#zjl").fadeIn(500);
                                            swal({
                                                title: "中奖啦~",
                                                text: "恭喜您刮中了【" + prizeName + "】，请登记或核对您的领奖信息！",
                                                showCancelButton: false,
                                                confirmButtonColor: "rgb(89, 167, 20)",
                                                confirmButtonText: "- 确 定 -",
                                                closeOnConfirm: true
                                            });
                                        }
                                    }
                                }
                            }
                        });
                        $(".info").hide();
                    } else {
                        if (msg.indexOf("TimeOut:SESSION超时") > -1) {
                            window.location.reload();
                            return;
                        } else if (msg.indexOf("Warn:") > -1) {
                            swal({
                                title: "没有游戏次数啦~",
                                text: "可以点击【获取机会】按钮查看游戏机会的获取方法",
                                type: "warning",
                                showCancelButton: false,
                                confirmButtonColor: "#DD6B55",
                                confirmButtonText: "确定",
                                closeOnConfirm: true
                            });
                            $(".info").hide();
                        }
                        else
                            swal({
                                title: "出错了",
                                text: msg.replace("Error:", ""), type: "error",
                                showCancelButton: false,
                                confirmButtonColor: "#DD6B55",
                                confirmButtonText: "确定",
                                closeOnConfirm: true
                            });
                        return;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    swal("您的网络不给力,此次游戏数据失败！", "", "error");
                }
            });
        }

        function playagain() {
            if ($("#gamenums").text() == "0")
                window.location.href = "introduction.html";
            else
                window.location.reload();
        }

        //消费游戏token方法
        function ConsumeToken() {
            $.ajax({
                type: "POST",
                timeout: 10000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "ggkProcess.aspx",
                data: { ctrl: "ConsumeGameToken", gametoken: gametoken, userid: userid, gameid: gameid },
                success: function (msg) {
                    if (msg.indexOf("Successed") > -1) {
                        //消费成功后打上成功标识才弹出提示
                        $("#gamenums").text($("#gamenums").text() - 1);
                        isConsume = true;
                        if ($("#gamenums").text() == "0") {
                            $("#againbtn").text("获取机会");
                        }
                        //判断用户的登记情况
                        if (msg.indexOf("未登记") > -1)
                            isResgister = false;
                        else if (msg.indexOf("领票时已经登记过信息") > -1) {
                            var _arr = msg.split("|");
                            $("#username").val(_arr[1]);
                            $("#tel").val(_arr[2]);
                            $("#idcard").val(_arr[3]);
                            isResgister = false;
                        }
                    } else if (msg.indexOf("TimeOut:SESSION超时") > -1) {
                        window.location.reload();
                        return;
                    } else {
                        isConsume = false;
                        swal({ title: "出错了", text: msg.replace("Error:", ""), type: "error", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "确定", closeOnConfirm: true });
                        //alert(msg);
                        return;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    isConsume = false;
                    swal("您的网络不给力,此次游戏数据失败！", "", "error");
                }
            });
        }

        $("#cancelsave").bind("click", function () {
            $(".info").hide();
            $("#zjl").hide();
        });

        //提交用户登记信息
        $("#save-btn").bind("click", function () {
            $("#save-btn").attr("disabled", "disabled");
            var PATTERN_CHINAMOBILE = /^1(3[4-9]|5[0123789]|8[23478]|4[7]|7[8])\d{8}$/;//移动
            var PATTERN_CHINAUNICOM = /^1(3[0-2]|5[56]|8[56]|4[5]|7[6])\d{8}$/;//联通
            var PATTERN_CHINATELECOM = /^1(3[3])|(8[019])\d{8}$/;//电信

            var username = $("#username").val();
            var cardno = $("#idcard").val();
            var tel = $("#tel").val();
            if (username == "") {
                swal({ title: "姓名不能为空！", text: "", type: "warning", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "哦，知道了", closeOnConfirm: true });
                //alert("姓名不能为空！");
                $("#save-btn").removeAttr("disabled");
            } else if (cardno == "") {
                swal({ title: "身份证号码不能为空！", text: "", type: "warning", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "哦，知道了", closeOnConfirm: true });
                //alert("身份证号码不能为空！");
                $("#save-btn").removeAttr("disabled");
            } else if (tel == "") {
                swal({ title: "手机号码不能为空！", text: "", type: "warning", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "哦，知道了", closeOnConfirm: true });
                //alert("电话号码不能为空！");
                $("#save-btn").removeAttr("disabled");
            } else if (!validateIdCard(cardno)) {
                swal({ title: "身份证号码有误！", text: "", type: "warning", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "哦，知道了", closeOnConfirm: true });
                //alert("身份证号码有误！");
                $("#idcard").focus();
                $("#save-btn").removeAttr("disabled");
            } else if (!(PATTERN_CHINAMOBILE.test(tel) || PATTERN_CHINAUNICOM.test(tel) || PATTERN_CHINATELECOM.test(tel))) {
                swal({ title: "手机号码有误！", text: "", type: "warning", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "哦，知道了", closeOnConfirm: true });
                //alert("手机号码有误！");
                $("#tel").focus();
                $("#save-btn").removeAttr("disabled");
            } else {
                $.ajax({
                    type: "POST",
                    timeout: 10000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "ggkProcess.aspx",
                    data: { ctrl: "RegisterUserInfo", gameid: gameid, userid: userid, idcard: cardno, phone: tel, username: username },
                    success: function (msg) {
                        if (msg.indexOf("Successed") > -1) {
                            swal({
                                title: "登记用户信息成功！",
                                text: "提示:礼券激活成功后才能兑奖", type: "success",
                                confirmButtonColor: "rgb(89, 167, 20)",
                                showCancelButton: false,
                                confirmButtonText: "马上激活",
                                closeOnConfirm: true
                            }, function (isConfirm) {
                                window.location.href = "http://tm.lilanz.com/supersalegames/GiftDetail2.aspx?token=" + gametoken + "&gameid=" + gameid;
                            });
                            $(".info").hide();
                            $("#zjl").hide();
                            $("#save-btn").removeAttr("disabled");
                        } else if (msg.indexOf("TimeOut:SESSION超时") > -1) {
                            window.location.reload();
                            return;
                        } else {
                            swal({
                                title: "出错了",
                                text: msg.replace("Error:", ""), type: "error",
                                showCancelButton: false,
                                confirmButtonColor: "#DD6B55",
                                confirmButtonText: "确定",
                                closeOnConfirm: true
                            });
                            //$("#zjl").hide();
                            $("#save-btn").removeAttr("disabled");
                            return;
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        swal("您的网络不给力,此次游戏数据失败！", "", "error");
                        $("#save-btn").removeAttr("disabled");
                    }
                });
            }
        });

        function validateIdCard(idCard) {
            //15位和18位身份证号码的正则表达式
            var regIdCard = /^(^[1-9]\d{7}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}$)|(^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])((\d{4})|\d{3}[Xx])$)$/;
            //如果通过该验证，说明身份证格式正确，但准确性还需计算
            if (regIdCard.test(idCard)) {
                if (idCard.length == 18) {
                    var idCardWi = new Array(7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2); //将前17位加权因子保存在数组里
                    var idCardY = new Array(1, 0, 10, 9, 8, 7, 6, 5, 4, 3, 2); //这是除以11后，可能产生的11位余数、验证码，也保存成数组
                    var idCardWiSum = 0; //用来保存前17位各自乖以加权因子后的总和
                    for (var i = 0; i < 17; i++) {
                        idCardWiSum += idCard.substring(i, i + 1) * idCardWi[i];
                    }

                    var idCardMod = idCardWiSum % 11;//计算出校验码所在数组的位置
                    var idCardLast = idCard.substring(17);//得到最后一位身份证号码

                    //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
                    if (idCardMod == 2) {
                        if (idCardLast == "X" || idCardLast == "x") {
                            return true
                        } else {
                            return false;
                        }
                    } else {
                        //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
                        if (idCardLast == idCardY[idCardMod]) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                }
            } else {
                return false;
            }
        }

        function loadPrizer100() {
            $.ajax({
                type: "POST",
                timeout: 4000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "ggkProcess.aspx",
                data: { ctrl: "Prizer100" },
                success: function (msg) {
                    if (msg.indexOf("Error:") == -1) {
                        $("#queeul").children().remove();
                        $("#queeul").append(msg);
                        $(".example").smartmarquee({
                            duration: 400,
                            loop: true,
                            interval: 1500,
                            axis: "vertical"
                        });
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });
        }
    </script>

</body>

</html>

