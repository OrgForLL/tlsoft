<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>

<!DOCTYPE html>
<script runat="server">
    public string redic_url = "";
    public string autoAuth = "";
    public string qyappid = "wxe46359cef7410a06";
    protected void Page_Load(object sender, EventArgs e)
    {
        redic_url = Convert.ToString(Request.Params["redic_url"]);
        autoAuth = Convert.ToString(Request.Params["autoAuth"]);
        
        //自动跳转鉴权
        if (autoAuth == "retail") {
            redic_url = HttpUtility.UrlEncode(redic_url);
            Response.Write("正在自动跳转鉴权.....");
            Response.Redirect("OauthAndRedirect.aspx?wxtype=" + autoAuth + "&redic_url=" + redic_url);
            Response.End();
        }
        else if (autoAuth == "enterprise") {
            redic_url = HttpUtility.UrlEncode(redic_url);
            Response.Write("正在自动跳转鉴权.....");
            string oauthurl = HttpUtility.UrlEncode("http://tm.lilanz.com/retail/wxarticles/OauthAndRedirect.aspx?wxtype=enterprise&redic_url=" + redic_url);
            string qyurl = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + qyappid + "&redirect_uri=" + oauthurl + "&response_type=code&scope=snsapi_base&state=1#wechat_redirect";
            Response.Redirect(qyurl);
            Response.End();
        }
    }            
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="css/animate.min.css" />
    <style type="text/css">
        * {
            margin: 0px;
            padding: 0px;
        }

        body {
            background: #ebebeb;
            font-family: "微软雅黑","Helvetica Neue",Helvetica,Arial,sans-serif;
            color: #333;
        }

        #buttons {
            position: absolute;
            width: 240px;
            height: 200px;
            left: 50%;
            top: 50%;
            margin-left: -120px;
            margin-top: -200px;
        }

            #buttons a {
                text-decoration: none;
            }

        .btn {
            display: block;
            padding: 10px 12px;
            font-size: 1.4em;
            font-weight: 400;
            text-align: center;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            border: 1px solid transparent;
            border-radius: 6px;
            color: #fff;
            cursor: pointer;
        }

            .btn i {
                margin-right: 10px;
            }

        .btn-success {
            background: #449d44;
            border-top: 3px solid #398439;
        }

            .btn-success:hover {
                background: #398439;
            }

        .btn-warning {
            background: #f0ad4e;
            border-top: 3px solid #ec971f;
        }

            .btn-warning:hover {
                background: #ec971f;
            }

        #buttons a:not(:last-child) {
            margin-bottom: 40px;
        }

        .wxtitle {
            text-align: center;
            font-size: 1.4em;
            margin-bottom: 20px;
        }

        .copyright {
            text-align: center;
        }
    </style>
</head>
<body>
    <div id="buttons">
        <div class="wxtitle">阅读本内容需要先进行身份验证，请选择对应的验证类型</div>
        <a class="btn btn-success bounceIn animated" onclick="jump('enterprise')"><i class="fa fa-weixin"></i>利郎企业号</a>
        <a class="btn btn-warning bounceIn animated" onclick="jump('retail')"><i class="fa fa-weixin"></i>利郎零售管理</a>
        <div class="copyright">
            利郎信息技术部
        </div>
    </div>

    <script type="text/javascript">
        var redic_url = "<%=redic_url%>";
        var autoAuth = "<%=autoAuth%>";

        function jump(type) {
            var gourl = encodeURI(redic_url);
            if (type =="retail") {
                //alert("攻城师们正在努力开发中，敬请期待....");
                window.location.href = "OauthAndRedirect.aspx?wxtype=" + type + "&redic_url=" + gourl;
            } else if (type == "enterprise") {
                //构造企业号的鉴权链接
                var qyappid = "<%=qyappid%>";
                gourl = escape("http://tm.lilanz.com/retail/wxarticles/articlelist.aspx?ssid=3");
                var oauthurl = escape("http://tm.lilanz.com/retail/wxarticles/OauthAndRedirect.aspx?wxtype=enterprise&redic_url=" + gourl);
                var qyurl = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + qyappid + "&redirect_uri=" + oauthurl + "&response_type=code&scope=snsapi_base&state=1#wechat_redirect";                
                window.location.href = qyurl;
            }
        }
        
        if (!(autoAuth == "" || autoAuth == null || autoAuth==undefined)) {
            jump(autoAuth);
        }
    </script>
</body>
</html>

