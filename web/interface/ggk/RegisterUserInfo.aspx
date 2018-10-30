<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    public string userid = "";
    public string djxm = "", djdh = "", djsfz = "";
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
        else { 
            //查询用户的登记信息
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM("server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456"))
            {
               string str_sql = @"select top 1 lp.dpxm,lp.dh,lp.sfz
                                from wx_t_vipbinging wx 
                                inner join [192.168.35.10].tlsoft.dbo.yx_t_xsdp lp on lp.wxopenid=wx.wxopenid
                                where wx.id=@userid order by lp.djrq desc";
               List<SqlParameter> para = new List<SqlParameter>();
               para.Add(new SqlParameter("@userid", userid));
               DataTable dt = null;
               string errinfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
               if (errinfo == "" && dt.Rows.Count > 0) {
                   djxm = dt.Rows[0]["dpxm"].ToString().Trim();
                   djdh = dt.Rows[0]["dh"].ToString().Trim();
                   djsfz = dt.Rows[0]["sfz"].ToString().Trim();
               }
            }   
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <title></title>
    <link href="css/activity-style.css" rel="stylesheet" type="text/css" />
    <link href="css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .btn2 {
            display: inline-block;
            width: 48%;
        }
    </style>
</head>
<body class="activity-scratch-card-winning">
    <div class="container">
        <div id="zjl" class="boxcontent boxwhite">
            <div class="box">
                <div class="title-red">
                    <span>领奖信息登记
                    </span>
                </div>
                <div class="Detail" style="padding-top: 0;">
                    <p class="red"></p>
                    <p>
                        <input name="" class="px" id="username" type="text" value="" placeholder="请输入您的姓名" />
                    </p>
                    <p>
                        <input name="" class="px" id="idcard" type="text" value="" placeholder="请输入您的身份证号码" />
                    </p>
                    <p>
                        <input name="" class="px" id="tel" value="" type="text" placeholder="请输入您的手机号码" />
                    </p>
                    <p>
                        <input class="pxbtn btn2" name="提 交" id="save-btn" type="button" value="提交" />
                        <input class="pxbtn btn2" style="background-image:linear-gradient( #ccc, #808080);border:1px solid #ccc;border-bottom:none;" name="返回" id="cancelsave" type="button" value="返回游戏" />
                    </p>
                    <p style="margin-top:10px;font-size:1.1em;font-weight:bold;color:#f00;text-align:center;">1、对于您的信息，我们将完全保密！</p>
                    <p style="margin-top:10px;font-size:1.1em;font-weight:bold;color:#f00;text-align:center;">2、如果您在领票时已经登记过信息，请您核对无误后直接点击【提交】即可。</p>
                </div>
            </div>
        </div>
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
        var userid = "<%=userid%>", djxm = "<%=djxm%>", djdh = "<%=djdh%>", djsfz = "<%=djsfz%>";
        window.onload = function () {
            if (userid == "" || userid == "0") {
                $("#save-btn").hide();
                swal("身份验证失败，请重试！", "", "error");
            } else if (djdh != "" && djdh != null) {
                $("#username").val(djxm);
                $("#idcard").val(djsfz);
                $("#tel").val(djdh);
                //swal("您已经在领票中登记过信息", "核对后如果无错误直接点【提交】即可！", "success");
            }
        }

        //提交用户登记信息
        $("#save-btn").bind("click", function () {
            $("#save-btn").attr("disabled", "disabled");
            var PATTERN_CHINAMOBILE = /^1(3[4-9]|5[0123789]|8[23478]|4[7]|7[78])\d{8}$/;//移动
            var PATTERN_CHINAUNICOM = /^1(3[0-2]|5[56]|8[56]|4[5]|7[6])\d{8}$/;//联通
            var PATTERN_CHINATELECOM = /^1(3[3])|(8[019])\d{8}$/;//电信

            var username = $("#username").val();
            var cardno = $("#idcard").val();
            var tel = $("#tel").val();
            if (username == "") {
                swal({ title: "姓名不能为空！", text: "", type: "warning", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "哦，知道了", closeOnConfirm: true });                
                $("#save-btn").removeAttr("disabled");
            } else if (cardno == "") {
                swal({ title: "身份证号码不能为空！", text: "", type: "warning", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "哦，知道了", closeOnConfirm: true });
                $("#save-btn").removeAttr("disabled");
            } else if (tel == "") {
                swal({ title: "手机号码不能为空！", text: "", type: "warning", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "哦，知道了", closeOnConfirm: true });                
                $("#save-btn").removeAttr("disabled");
            } else if (!validateIdCard(cardno)) {
                swal({ title: "请输入正确的身份证号码！", text: "", type: "warning", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "哦，知道了", closeOnConfirm: true });               
                $("#idcard").focus();
                $("#save-btn").removeAttr("disabled");
            } else if (!(PATTERN_CHINAMOBILE.test(tel) || PATTERN_CHINAUNICOM.test(tel) || PATTERN_CHINATELECOM.test(tel))) {
                swal({ title: "请输入正确的手机号码！", text: "", type: "warning", showCancelButton: false, confirmButtonColor: "#DD6B55", confirmButtonText: "哦，知道了", closeOnConfirm: true });                
                $("#tel").focus();
                $("#save-btn").removeAttr("disabled");
            } else {
                $.ajax({
                    type: "POST",
                    timeout: 10000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "ggkProcess.aspx",
                    data: { ctrl: "RegisterUserInfo", userid: userid, idcard: cardno, phone: tel, username: username },
                    success: function (msg) {
                        if (msg.indexOf("Successed") > -1) {
                            swal({
                                title: "登记用户信息成功！",
                                text: "1.点击确定查看我的礼券 2.活动期间：12.18-1.30 每天8:30-9:30 您可以凭二维码或身份证前往利郎总部领取礼品。",
                                type: "success",
                                confirmButtonColor: "rgb(89, 167, 20)",
                                showCancelButton: false,
                                confirmButtonText: "确定",
                                closeOnConfirm: true
                            }, function () {
                                window.location.href = "myprizelist.aspx";
                            });
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

        $("#cancelsave").click(function () {
            window.location.href = "ggkgame.aspx";
        });
    </script>
</body>
</html>
