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
    private const string ConfigKeyValue = "5";
    public string msgCode = "0000";

    protected void Page_Load(object sender, EventArgs e)
    {

        System.Random Random = new System.Random();
        msgCode = Random.Next(1000, 9999).ToString();
        
        DBConStr = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;//62 wechattpromotion
        DBConStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");                   //23

        //鉴权
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);
            //输出访问日记
            clsWXHelper.WriteLog(string.Format("openid：{0} ，vipid：{1} 。访问功能页[{2}]", Convert.ToString(Session["openid"]), Convert.ToString(Session["vipid"])
                    , "VIP注册"));

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
                    Response.Redirect("UserCenter.aspx");
                }
            }
        }
        
    }

</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>会员注册</title>
    
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
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
            background-image:url(../../res/img/vipweixin/loginbg.jpg); 
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
            display:flex;
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
          width:80%;
          background:rgba(0,0,0,0.4);
          height:50px;
          margin:0 auto;
          border-radius:24px;
          position:relative;
        }
         .moblile_txt, .code_txt
        {
            height:40px;
            line-height:40px;
            border:0 ;
            font-size:14px;
            width:100%;
            display:inline;
            background: transparent;
            margin-left:15px;
            margin-top:5px;
            color:#fff;
        }
        .sendcode_btn
        {
          display:inline;
          height:35px;
          line-height:35px;
          vertical-align:middle;
          font-size:12px;
          margin-left:0;
          width:75px;
          background-color: transparent;
          border:1px solid #d6d6d6;
          color:#ddd;
          -webkit-border-radius:5px;
          border-radius：5px;
          position:absolute;
          top:7.5px;
          right:15px;
        }
        .code_div
        {
          margin-top:16px;
        }
        .submit_div
        {
            height:50px;
            width:80%;
            background:rgba(255,255,255,0.3);
            margin:0 auto;
            border-radius:24px;
            position:relative;
            margin-top:16px;
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
            color: #ededed;
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
    </style>
</head>
<body >
    <div class="content">
          <div class="ts">提示信息</div>
        <div class="header">
            <img class="lllogo" src="../../res/img/vipweixin/lllogo.png">
        </div>
        <div class="main">
            <div class="phone_div">
                <input type="number" class="moblile_txt" placeholder="请输入手机号码" pattern="[0-9]*" />
                <input type="button" class="sendcode_btn" value="发送验证码" />
            </div>
            <div class="code_div"><input type="number" class="code_txt" placeholder="请输入验证码" /></div>
            <div class="submit_div" ><input type="button"  class="submit_btn" value="提 交 验 证"/></div>
            <div class="footer">
                <p>&copy;2017 利郎信息技术部</p>
            </div>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function (e) {
            LeeJSUtils.stopOutOfPage(".content", true);
            //            alert("<%=msgCode %>");
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
                            url: "vipInfoRegCoreV1.aspx?ctrl=registervip",
                            success: function (msg) {
                                console.log(msg);
                                var rt = JSON.parse(msg);
                                if (rt.code == "200") {
                                    LeeJSUtils.showMessage("successed", "注册成功!");
                                    window.location.href = "UserCenter.aspx";
                                } else {
                                    LeeJSUtils.showMessage("error", rt.errmsg);
                                    showts(rt.errmsg);
                                }
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                LeeJSUtils.showMessage("error", "糟糕,网络不通畅...");
                            }
                        });
                    }, 50);
                } else {
                    LeeJSUtils.showMessage("error", "验证码错啦!");
                }
            });

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
                        url: "vipInfoRegCoreV1.aspx?ctrl=sendSMS",
                        success: function (msg) {
                          //  console.log(msg);
                            var rt = JSON.parse(msg);
                            if (rt.code == "200") {
                                LeeJSUtils.showMessage("successed", "发送成功!");
                                sendSecond = 30;
                                countDown = setInterval(beginCount, 999);
                            } else {
                                LeeJSUtils.showMessage("error", rt.errmsg);
                                showts(rt.errmsg);
                                sendSecond = 30;
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
