<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html>
<script runat="server">
    public string UID = "", GameToken = "";
    private string WXDBConStr = "server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456";    
    protected void Page_Load(object sender, EventArgs e)
    {
        UID = Convert.ToString(Session["QSW_UID"]);
        string OAuth = Convert.ToString(Request.Params["OAuth"]);
        GameToken = Convert.ToString(Request.Params["GameToken"]);
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
        else {
            //验证TOKEN的合法性
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConStr)) {
                string str_sql = "select top 1 1 from wx_t_gamerecords where gameid=1 and sskey=7 and prizeid<>0 and userid=" + UID + " and gametoken='" + GameToken + "'";
                DataTable dt = null;
                string errinfo = dal62.ExecuteQuery(str_sql,out dt);
                if (errinfo == ""&&dt.Rows.Count==0) {
                    GameToken = "";
                    clsSharedHelper.WriteErrorInfo("TOKEN无效！");
                }
            }     
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
    <title>领取奖品</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        body {
            background-color: #f5c24d;
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            height:100%;
        }
        .wrapper {
            position:absolute;
            top:0;
            left:0;
            right:0;
            bottom:0px;  
            overflow:hidden;          
        }
        .wrapper .top>img,.wrapper .bottom>img{
            width:100%;
            height:auto;
        }
        .wrapper .bottom {
            position:absolute;
            left:0;
            bottom:-5px;
        }
        .wrapper .qrcode {
            position:absolute;
            text-align:center;
            z-index:100;
            top:40%;
            left:50%;
            transform:translate(-50%,-50%);
            -webkit-transform:translate(-50%,-50%);            
        }
        .qrcode img {
            width:140px;
            height:140px;
            padding:10px;
            background-color:#fff;
        }
    </style>
</head>
<body>
    <div class="wrapper">
        <div class="top"><img src="../../res/img/EasyBusiness/bg-top.jpg" alt="" /></div>
        <div class="qrcode">            
        </div>
        <div class="bottom"><img src="../../res/img/EasyBusiness/bg-bot.jpg" alt="" /></div>
    </div>
    <script src="../../res/js/jquery.js" type="text/javascript"></script>
    <script type="text/javascript">
        var token = "<%=GameToken%>";
        window.onload = function () {
            if (token != "" && token != undefined) {
                var imgsrc = "http://tm.lilanz.com/WebBLL/WX2wCodeProject/GetQrCode.aspx?code=" + token;
                $(".qrcode").append("<img src='" + imgsrc + "' />");
            } else
                alert("网络好像出了点问题，请稍后重试！");
        }
    </script>
</body>
</html>
