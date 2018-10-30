<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<html>
<script runat="server"> 
    private string ConfigKeyValue = clsConfig.GetConfigValue("VIPConfigValue");
    public string wxNick = "";

    private string BrandName = clsConfig.GetConfigValue("BrandName"); //L2
    private string VIP_resPath = clsConfig.GetConfigValue("VIP_resPath"); //资源目录
    public string wxHeadimgurl = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        wxHeadimgurl = string.Concat(BrandName, "/img/initial_img.png");
            
        string strsql = "";
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            if (Convert.ToString(Session["vipid"]) != "" && Convert.ToString(Session["vipid"]) != "0")
            {
                Response.Redirect("UserCenter.aspx");
                return;
            }
            else
            {
                string wxDBConStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
                List<SqlParameter> para = new List<SqlParameter>();
                DataTable dt;
                /*取微信头像*/
                //clsSharedHelper.WriteInfo(openid);
                strsql = @"SELECT TOP 1 wxHeadimgurl,wxNick from wx_t_vipBinging  where wxopenid=@openid  ";
                para.Add(new SqlParameter("@openid", Convert.ToString(Session["openid"])));
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(wxDBConStr))
                {
                    string eScal = dal.ExecuteQuerySecurity(strsql, para, out dt);
                    para.Clear();
                    if (eScal == "")
                    {
                        if (dt.Rows.Count > 0)
                        { 
                            wxNick = Convert.ToString(dt.Rows[0]["wxNick"]);
                            wxHeadimgurl = Convert.ToString(dt.Rows[0]["wxHeadimgurl"]);

                            if (clsWXHelper.IsWxFaceImg(wxHeadimgurl))
                            {
                                wxHeadimgurl = clsWXHelper.GetMiniFace(wxHeadimgurl);
                            }
                            else
                            {
                                wxHeadimgurl = string.Concat(clsConfig.GetConfigValue("VIP_WebPath") , wxHeadimgurl); 
                            }
                        }
                        dt.Clear(); dt.Dispose();
                    }
                }
            }
        }
    }
</script>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>     
    <style type="text/css">   
        @import url(<%= VIP_resPath %>/css/font-awesome.min.css);  
    </style>  
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        .wrap-page {
            max-width: 600px;
            margin: 0 auto;
            padding-top:82px;
        }

        body {
            background-color: #272b2e;
            font-family: Helvetica,Arial,STHeiTi,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            color: #fff;
        }

        .logo {
            text-align: center;
            margin-bottom: 20px;
            box-shadow: 0 0 3px #161A1C;
            box-sizing: border-box;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 60px;
            background-color:#2B2F32;
            z-index:1000;
        }

        .logodiv {
            height:22px;            
            padding-top:19px;
        }
            .logodiv img {
                height:100%;
                width:auto;                
            }

        .btns {
            width: 96%;
            margin: 0 auto;
            border-radius: 4px;
            padding: 0 30px 25px 30px;
            box-sizing: border-box;
        }

        .btn-item {
            text-align: center;
            width: 100%;
            height: 50px;
            border: 1px solid #161A1C;
            box-shadow: 0 1px 1px #2B2F32 inset;
            margin: 0 auto;
            margin-bottom: 28px;
            font-size: 1.15em;
            line-height: 50px;
            border-radius: 4px;
            font-weight: bold;
            letter-spacing: 2px;
            background: rgba(0,0,0,.2);
            color:#ededed;
        }

            .btn-item:hover {
                background: rgba(0,0,0,.5);
            }

        .hints {
            text-align: left;
            margin-top:-10px;
        }

        .title {
            font-weight: bold;
            font-size: 1.3em;
            text-align:center;
            position:relative;
            height:40px;
        }
        .line {
            width:100%;
            height:20px;
            border-bottom:1px solid #fff;
            position:absolute;
            top:0;
            left:0;
        }
        .hh {
            position:relative;
            height:40px;
            line-height:40px;
            background-color:#272b2e;
            width:86px;
            margin:0 auto;
        }
        .remark {
            font-size: 1.1em;
            text-indent: 1.2em;
            margin-top: 10px;
        }

        .headimg {
            width: 70px;
            height: 70px;
            padding: 5px;
            margin-bottom: 20px;
            border-radius: 5px;
            margin: 0 auto 15px auto;
            box-shadow: 0 0 4px rgba(0,0,0,.4);
        }

        #userimg {
            width: 100%;
            height: 100%;
            background-size: cover;
            background-position: 50% 50%;
            background-repeat: no-repeat;
            border-radius: 4px;
        }

        #nickname {
            font-weight: bold;
            font-size: 1.4em;
            text-align: center;
            margin-bottom: 30px;
            letter-spacing: 2px;
        }

        /*animation css*/
        .animated {
            -webkit-animation-duration: 1.5s;
            animation-duration: 1.5s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

        @-webkit-keyframes bounceIn {
            0%,100%,20%,40%,60%,80% {
                -webkit-transition-timing-function: cubic-bezier(0.215,.61,.355,1);
                transition-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: scale3d(.3,.3,.3);
                transform: scale3d(.3,.3,.3);
            }

            20% {
                -webkit-transform: scale3d(1.1,1.1,1.1);
                transform: scale3d(1.1,1.1,1.1);
            }

            40% {
                -webkit-transform: scale3d(.9,.9,.9);
                transform: scale3d(.9,.9,.9);
            }

            60% {
                opacity: 1;
                -webkit-transform: scale3d(1.03,1.03,1.03);
                transform: scale3d(1.03,1.03,1.03);
            }

            80% {
                -webkit-transform: scale3d(.97,.97,.97);
                transform: scale3d(.97,.97,.97);
            }

            100% {
                opacity: 1;
                -webkit-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        @keyframes bounceIn {
            0%,100%,20%,40%,60%,80% {
                -webkit-transition-timing-function: cubic-bezier(0.215,.61,.355,1);
                transition-timing-function: cubic-bezier(0.215,.61,.355,1);
            }

            0% {
                opacity: 0;
                -webkit-transform: scale3d(.3,.3,.3);
                -ms-transform: scale3d(.3,.3,.3);
                transform: scale3d(.3,.3,.3);
            }

            20% {
                -webkit-transform: scale3d(1.1,1.1,1.1);
                -ms-transform: scale3d(1.1,1.1,1.1);
                transform: scale3d(1.1,1.1,1.1);
            }

            40% {
                -webkit-transform: scale3d(.9,.9,.9);
                -ms-transform: scale3d(.9,.9,.9);
                transform: scale3d(.9,.9,.9);
            }

            60% {
                opacity: 1;
                -webkit-transform: scale3d(1.03,1.03,1.03);
                -ms-transform: scale3d(1.03,1.03,1.03);
                transform: scale3d(1.03,1.03,1.03);
            }

            80% {
                -webkit-transform: scale3d(.97,.97,.97);
                -ms-transform: scale3d(.97,.97,.97);
                transform: scale3d(.97,.97,.97);
            }

            100% {
                opacity: 1;
                -webkit-transform: scale3d(1,1,1);
                -ms-transform: scale3d(1,1,1);
                transform: scale3d(1,1,1);
            }
        }

        .bounceIn {
            -webkit-animation-name: bounceIn;
            animation-name: bounceIn;
            -webkit-animation-duration: .75s;
            animation-duration: .75s;
        }

        .delay {
            animation-delay:0.3s;
            -webkit-animation-delay:0.3s;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="logo">
            <div class="logodiv"><img src="<%= VIP_resPath %>/img/L2VIP/lllogo6.png" alt="" /></div>
        </div>
        <div class="headimg">
            <div id="userimg" style="background-image: url('<%=wxHeadimgurl %>');"></div>
        </div>
        <p id="nickname"><%=wxNick %></p>
        <div class="btns">
            <div class="btn-item animated bounceIn" onclick="window.location.href='vipBinging_v2.aspx?cid=3'">我已经是会员</div>
            <div class="btn-item animated bounceIn delay" onclick="window.location.href='vipInfoReg.aspx?cid=3'">申请成为会员</div>
            <div class="hints">
                <div class="title">
                    <div class="line"></div>
                    <p class="hh">温馨提示</p>
                </div>
                <p class="remark">1、如果您已经是L2会员，请点击第一个按钮，关联您的线下会员卡。</p>
                <p class="remark">2、如果您还不是L2会员，请点击第二个按钮，一分钟成为L2尊贵会员,赶快行动吧！</p>
            </div>
        </div>
    </div>
    <script type="text/javascript" src="<%= VIP_resPath %>/js/jquery.js"></script>
    <script type="text/javascript" src="<%= VIP_resPath %>/js/StoreSaler/fastclick.min.js"></script>
    <script type="text/javascript">
        $(function () {
            FastClick.attach(document.body);
        });
    </script>
</body>
</html>
