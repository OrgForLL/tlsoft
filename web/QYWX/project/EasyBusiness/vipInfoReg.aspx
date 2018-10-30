<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">   
    public string cid = "";
    string DBConStr_tlsoft = "";
    string DBConStr = "";
    public string openid = "";
    private string ConfigKeyValue;
    public string msgCode = "0000";

    protected void Page_Load(object sender, EventArgs e)
    {
        ConfigKeyValue = clsConfig.GetConfigValue("CurrentConfigKey");
        System.Random Random = new System.Random();
        msgCode = Random.Next(1000, 9999).ToString();
        
        DBConStr = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;//62 wechattpromotion
        DBConStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");                   //23

        //鉴权
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);
            //输出访问日记
            clsWXHelper.WriteLog(string.Format("openid：{0} ，vipid：{1} 。访问功能页[{2}]", Convert.ToString(Session["openid"]), Convert.ToString(Session["vipid"]), "VIP注册"));
        }

        if (string.IsNullOrEmpty(openid))
        {
            clsSharedHelper.WriteErrorInfo("鉴权出错，请重新进入");
            return;
        }

        if (!IsPostBack)
        {
            DataTable dt; 
            string strSQLExists = @" SELECT TOP 1 ID FROM wx_t_vipBinging WHERE wxOpenid=@openid AND VipID>0";
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@openid", openid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
            {
                string errInfo = dal.ExecuteQuerySecurity(strSQLExists, para, out dt);
                if (errInfo == "" && dt.Rows.Count > 0)//已经注册自动跳到用户中心
                {
                    clsSharedHelper.DisponseDataTable(ref dt);
                    Response.Redirect("NewUserCenter.aspx");
                }
            }
            
        }
        
    }

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>会员注册</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        *{
            margin: 0;
            padding: 0;
        }
        body {
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            color: #fff;
        }
        .content
        {
            background-color:#000; 
            width:100%;
            height:100%;
            position:absolute;
            top:0;
            bottom:0;
        }
        input
        {
            -webkit-appearance:none;
            }
        .header 
        {
            width:100%;
            text-align:center; 
            height:50%;
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
        .main
        {
          width:100%;   
          height:50%;
        }
       
        .phone_div, .code_div
        {
          width:70%;
          background:rgba(0,0,0,0.4);
          height:50px;
          margin:0 auto;
          border-radius:24px;
          position:relative;
          border-bottom:1px solid #888;
          border-radius:0;
        }
         .moblile_txt, .code_txt
        {
            height:20px;
            line-height:20px;
            border:0 ;
            font-size:14px;
            width:100%;
            display:inline-block;
            background: transparent;
            color:#fff;
            position:absolute;
            top:15px;
            left:26px;
            z-index: 40;
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
              display:inline-block;
              height:30px;
              line-height:30px;
              font-size:12px;
              margin-left:0;
              width:75px;
              background-color: transparent;
              border:1px solid #d6d6d6;
              color:#ddd;
              -webkit-border-radius:5px;
              border-radius:5px;
              position:absolute;
              top:7.5px;
              right:0;
              z-index: 50;
        }

        .submit_div
        {
            height:50px;
            width:80%;
            background-image:url(../../res/img/EasyBusiness/usercenterbg.jpg);
            margin:0 auto;
            border-radius:24px;
            position:relative;
            margin-top:36px;
            z-index: 40;
        }
        
      
        .submit_btn
        {
            width: 100%;
            height: 50px;
            margin: 0 auto;
            margin-bottom: 28px;
            font-size:16px;
            line-height: 50px;
            font-weight: bold;      
            background:transparent;
            color: #fff;
            border:none;
        }
        .footer 
        {
            position:fixed;
            width:100%;
            text-align:center;
            bottom:8px;
        }
        .ts
        {
           position:absolute;
           background-color:Red;
           width:100%;
           text-align:center;   
           font-size:14px;
           display:none;
        }
         .tips
        {
            font-size:14px;
        }
        .info-wrap
        {
            width:100%;
            position:fixed;
            bottom:25px;
            text-align:center;
            z-index: 20;
        }
        
    </style>
</head>
<body >
    <div class="content">
        <div class="ts">提示信息</div>
        <div class="header">
            <img class="lllogo" src="../../res/img/EasyBusiness/lllogo.png">
        </div>
        <div class="main">
            <div class="phone_div">
                <i class="fa fa-mobile icon"></i>
                <input type="number" class="moblile_txt" placeholder="请输入手机号码" pattern="[0-9]*" />
                <input type="button" class="sendcode_btn" value="验证码" />
            </div>
            <div class="code_div">
                <i class="fa fa-lock icon"></i>
                <input type="number" class="code_txt" placeholder="请输入验证码" />
            </div>
            <div class="submit_div" ><input type="button"  class="submit_btn" value="提 交 验 证"/></div>
              <div class="info-wrap"> <p class="tips">温馨提示：长时间未收到短信验证码请咨询店长</p></div>
            <%--<div class="footer">
                <p>&copy;2017 利郎信息技术部</p>
            </div>--%>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function (e) {
            LeeJSUtils.stopOutOfPage(".content", true);
            $(".submit_div").click(function () {
                //提交资料
                var codeVal = $(".code_txt").val();
                if (codeVal == "<%=msgCode %>") {
                    setTimeout(function () {
                        $.ajax({
                            type: "POST",
                            cache: false,
                            timeout: 10 * 1000,
                            data: { phone: $(".moblile_txt").val(), code: codeVal },
                            contentType: "application/x-www-form-urlencoded; charset=utf-8",
                            url: "vipInfoRegCore.aspx?ctrl=registervip",
                            success: function (msg) {
                                // console.log(msg);
                                var rt = JSON.parse(msg);
                                if (rt.code == "200") {
                                    LeeJSUtils.showMessage("successed", "注册成功!");
                                    linktoWorldCup();
                                    window.location.href = "NewUserCenter.aspx";
                                } else {
                                    LeeJSUtils.showMessage("error", rt.errmsg);
                                    showts(rt.errmsg);
                                }
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                LeeJSUtils.showMessage("error", "糟糕,网络不通畅...");
                                showts("糟糕,网络不通畅...");
                            }
                        });
                    }, 50);
                } else {
                    LeeJSUtils.showMessage("error", "验证码错啦!");
                    showts("验证码错啦!");
                }
            });

            // 2018世界杯活动
            function linktoWorldCup () {
                var worldCupKey = localStorage.getItem('worldCupKey');
                if (worldCupKey) {
                    if (worldCupKey == '5') {
                        window.location.href = 'http://tm.lilanz.com/project/18worldcup/index.aspx';
                    } else {
                        window.location.href = 'http://tm.lilanz.com/vip2/project/18worldcup/index.aspx';
                    }
                    localStorage.removeItem('worldCupKey');
                }
            }

            $(".sendcode_btn").click(function () {
                if (sendSecond > 0) {
                    return false;
                }
                //调用发送短信接口
                var phone = $(".moblile_txt").val();
                if (phone.length != 11) {
                    LeeJSUtils.showMessage("error", "请输入11手机号码");
                    showts("请输入11手机号码");
                    return;
                }
                LeeJSUtils.showMessage("loading", "短信发送中..");
                $(".ts").hide();
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        cache: false,
                        timeout: 10 * 1000,
                        data: { phone: phone, code: "<%=msgCode %>" },
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        url: "vipInfoRegCore.aspx?ctrl=sendSMS",
                        success: function (msg) {
                            console.log(msg);
                            var rt = JSON.parse(msg);
                            if (rt.code == "200") {
                                LeeJSUtils.showMessage("successed", "发送成功!");
                                sendSecond = 30;
                                countDown = setInterval(beginCount, 999);
                            } else {
                                LeeJSUtils.showMessage("error", rt.errmsg);
                                showts(rt.errmsg);
                                sendSecond = 0;
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            LeeJSUtils.showMessage("error", "糟糕,网络不通畅...");
                        }
                    });
                }, 50);
            });
        });
        var countDown = null;
        var sendSecond = 0;

        function beginCount(s) {
            if (sendSecond <= 0) {
                $(".sendcode_btn").val("发送验证码");
                clearInterval(countDown);
            } else {
                sendSecond = sendSecond - 1;
                $(".sendcode_btn").val("("+sendSecond+")秒后重发");
            }
        }
        function showts(msg) {
            $(".ts").text(msg);
            $(".ts").show();
        }
    </script>
</body>
</html>
