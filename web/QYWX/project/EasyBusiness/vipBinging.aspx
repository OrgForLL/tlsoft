<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" Debug="true" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    public string cid = "";
    public string openid = "";
    private  string ConfigKeyValue = "";
    string DBConStr_tlsoft = "";
    string DBConStr = "";
    public string sid = "0";
    public string wxNick = "";
    public string msgCode = "0000";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        ConfigKeyValue = clsConfig.GetConfigValue("CurrentConfigKey");

        System.Random Random = new System.Random();
        msgCode = Random.Next(1000, 9999).ToString();
        
        string sql = "";
        DataTable dt;

        List<SqlParameter> para = new List<SqlParameter>();
        DBConStr_tlsoft = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
        DBConStr = clsConfig.GetConfigValue("OAConnStr");
        /*鉴权*/
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            if (Convert.ToString(Session["vipid"]) != "" && Convert.ToString(Session["vipid"]) != "0")
            {
                Response.Redirect("newusercenter.aspx");
                return;
            }
            
            openid = Convert.ToString(Session["openid"]);
            string sqlcomm = @"SELECT TOP 1 ISNULL(VipID,0) FROM wx_t_vipBinging WHERE wxOpenid=@openid";
            para.Add(new SqlParameter("@openid", openid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                string errInfo = dal.ExecuteQuerySecurity(sqlcomm, para, out dt);
                para.Clear();
                if (errInfo == "" && dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0)
                {
                    clsSharedHelper.DisponseDataTable(ref dt);
                    Response.Redirect("newusercenter.aspx");
                }
            }

            /*注册*/
            if (Convert.ToString(openid) != "")
            {
                sql = @"select wxNick from wx_t_vipBinging  where wxopenid=@openid ";
                para.Add(new SqlParameter("@openid", openid));
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
                {
                    string errInfo = dal.ExecuteQuerySecurity(sql, para, out dt);
                    para.Clear();
                    if (errInfo == "")
                    {
                        wxNick = Convert.ToString(dt.Rows[0]["wxNick"]);
                        clsSharedHelper.DisponseDataTable(ref dt);
                    }
                }
            }
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>利郎会员身份认证</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
`   <style type="text/css">
        .ts
        {
           position:absolute;
           background-color:Red;
           width:100%;
           text-align:center;   
           font-size:14px;
           color:#fff;
           display:none;
        }
        *
        {
            box-sizing:border-box;
            -webkit-box-sizing:border-box; /* Safari */
        }
         body {
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            color: #fff;
        }
        p
        {
            line-height:1;
         }
        .content
        {
            background-color:#000;
            width:100%;
            height:100%;
            position:absolute;
            top:0;
            bottom:0;
            left:0;
        }
        input
        {
            -webkit-appearance:none;
            }
        .header 
        {
            width:100%;
            text-align:center; 
            height:40%;
            display: -webkit-box;
            display: -webkit-flex;
            display: flex;
            -webkit-align-items:center;
            -webkit-justify-content:center;
            align-items:center;
            justify-content:center;
        }
        .lllogo
        {
            width: 55%;
        }
        .divContent
        {
          width:100%;   
         
          color:#fff;
          position:absolute;
          bottom:120px;
        }
        .mod_input qb_mb10, .mod_input, .code_input
        {
            width:70%;
            height:50px;
            margin:0 auto;
            position:relative;
            border-bottom: 1px solid #555;
            line-height: 50px;
            
        }
        #wx, #VipNo, .code_txt
        {   
           border-radius:0;
           background: transparent;
           border:none;
           font-size:14px;
           position:absolute;
           top:15px;
           left:26px;
           right:0;
           height:20px;
           line-height:20px;
           color:#fff;

        }
        .icon
        {
            position:absolute;
            font-size:18px;
            top:16px;

          }
          .fa-mobile
        {
            font-size:22px;
        }
        .sendcode_btn
        {
          height:30px;
          line-height:30px;
          width: 75px;
          font-size:12px;
          background-color: transparent;
          border:1px solid #d6d6d6;
          color:#ddd;
          font-weight:bold;
          -webkit-border-radius:5px;
          border-radius: 5px;
          position:absolute;
          top:7.5px;
          right:0;
          text-align:center;
          padding:0;
        }
        .submitDiv
        {
            height:45px;
            width:75%;
            background-image:url(../../res/img/EasyBusiness/usercenterbg.jpg);
            margin:0 auto;
            border-radius:26px;
            position:relative;
            margin-top:30px;
            text-align:center;
            -webkit-tap-highlight-color: rgba(0,0,0,0);
        }
        .mod_btn
        {
            font-size:16px;
            line-height: 45px;
            font-weight: bold;      
            color: #ededed;
            text-decoration:none;
        }
        .registered
        {
            text-align:center;
            margin-top:25px;
        }
        .registered a
        {
            text-decoration:none;
            color:#ddd;
            font-size:15px;
        }
        .info-wrap
        {
            position:absolute;
            color:#888;
            bottom:10px;
            width:100%;
            margin: 0 auto;
            text-align:center;
        }
        .line
        {
            border-top:1px solid #333;
            width:20%;
            height:1px;
            display:inline-block;
        }
        .tips
        {
            font-size:14px;
          
        }
        .userinfo
        {
            width:70%;
            margin:0 auto;
            margin-bottom:40px;
            text-align:center;
        }
        .avatar
        {
            width:65px;
            height:65px;
            border-radius:50%;
            background-image:url(../../res/img/headImg.jpg);
            background-size:cover;
            background-position:center;
            margin: 0 auto;
            margin-bottom:10px;
        }
        .username
        {
            font-weight:bold;
        }

    </style>
</head>
<body>
    <div class="content">
        <div class="ts">提示信息</div>
        <div class="divContent">
             <form id="form1" runat="server">
                <div class="userinfo">
                    <div class="avatar"></div>
                    <span class="username"></span>
                </div>
                <div class="mod_input ">
                    <i class="fa fa-mobile icon"></i>
                    <input type="text" name="VipNo" class="flex_box" id="VipNo" runat="server"
                        placeholder="请输入vip卡号"  />
                    <input type="button" class="sendcode_btn" value="验证码" />
                </div>
                <div class="code_input">
                    <i class="fa fa-user icon"></i>
                    <input type="number" class="code_txt" placeholder="请输入验证码" pattern="[0-9]*" />
                </div>
                <div>
                    <asp:Label ID="Info" runat="server" Text=""></asp:Label>
                </div>

                <div class="submitDiv">
                    <a href="javascript:" id="Bind" class="mod_btn">关联线下会员卡</a>
                </div>
                <div class="registered">
                    <a  href="vipInfoReg.aspx" class="btn">会员注册</a>
                </div>
            </form>
        </div>
        <div class="info-wrap">
            <p>
                <span class="line"></span>
                <span >请用手机关联线下VIP客户</span>
                <span class="line"></span>
            </p>
            <p class="tips">手机号码有误请联系店员修改</br>长时间未收到短信验证码请咨询店长</p>
        </div>
    </div>
</body>
<script type="text/javascript" src="../../res/js/jquery.js"></script>
<script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
   
<script type="text/javascript">
    var countDown = null;
    var sendSecond = 0;
    function beginCount(s) {
        if (sendSecond <= 0) {
            $(".sendcode_btn").val("发送验证码");
            clearInterval(countDown);
        } else {
            sendSecond = sendSecond - 1;
            $(".sendcode_btn").val("(" + sendSecond + ")秒后重发");
        }
    }
    $(document).ready(function (e) {
        LeeJSUtils.stopOutOfPage(".content", true);
        $(".username").text("<%=wxNick %>");

        //发送验证码
        $(".sendcode_btn").click(function () {
            if (sendSecond > 0) {
                return false;
            }
            //调用发送短信接口
            var kh = $("#VipNo").val();
//            if (phone.length != 11) {
//                LeeJSUtils.showMessage("error", "请输入11手机号码");
//                showMsg("请输入11手机号码");
//                return;
//            }
            LeeJSUtils.showMessage("loading", "短信发送中..");
            clearMsg();
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    cache: false,
                    timeout: 10 * 1000,
                    data: { kh: kh, code: "<%=msgCode %>" },
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "vipInfoRegCore.aspx?ctrl=senbindcode",
                    success: function (msg) {
                        console.log(msg);
                        var rt = JSON.parse(msg);
                        if (rt.code == "200") {
                            LeeJSUtils.showMessage("successed", "验证码已通过短信发送到【" + rt.info + "】");
                            sendSecond = 30;
                            countDown = setInterval(beginCount, 999);
                        } else {
                            LeeJSUtils.showMessage("error", rt.errmsg);
                            showMsg(rt.errmsg);
                            sendSecond = 0;
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "糟糕,网络不通畅...");
                    }
                });
            }, 50);
        });

        //提交验证
        $(".submitDiv").click(function () {
            $(".submitDiv").css("background-color", "#111");
            //提交资料
            var codeVal = $(".code_txt").val();
            if (codeVal == "<%=msgCode %>") {
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        cache: false,
                        timeout: 10 * 1000,
                        data: { kh: $("#VipNo").val(), code: codeVal },
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        url: "vipInfoRegCore.aspx?ctrl=bindvip",
                        success: function (msg) {
                            console.log(msg);
                            var rt = JSON.parse(msg);
                            if (rt.code == "200") {
                                LeeJSUtils.showMessage("successed", "绑定成功!");
                                linktoWorldCup();
                            } else {
                                LeeJSUtils.showMessage("error", rt.errmsg);
                                showMsg(rt.errmsg);
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            LeeJSUtils.showMessage("error", "糟糕,网络不通畅...");
                            showMsg("糟糕,网络不通畅...");
                        }
                    });
                }, 50);
            } else {
                LeeJSUtils.showMessage("error", "验证码错啦!");
                showMsg("验证码错啦!");
            }
            $(".submitDiv").css("background-color", "#333");
        });

        // 2018世界杯活动
        function linktoWorldCup () {
            var worldCupKey = localStorage.getItem('worldCupKey');
            if (worldCupKey) {
                localStorage.removeItem('worldCupKey');
                if (worldCupKey == '5') {
                    window.location.href = 'http://tm.lilanz.com/project/18worldcup/index.aspx';
                } else {
                    window.location.href = 'http://tm.lilanz.com/vip2/project/18worldcup/index.aspx';
                }
            } else {
                window.location.href = "NewUserCenter.aspx";
            }
        }

    });
    function showMsg(msg) {
        $(".tips").text(msg);
        $(".tips").show();
    }
    function clearMsg() {
        $(".tips").text("");
        $(".tips").hide();
    }
</script>
</html>
