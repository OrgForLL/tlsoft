<%@ Page Language="C#" %>

<!DOCTYPE html>
<script runat="server">
    public string redic_url = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        redic_url = Convert.ToString(Request.Params["redic_url"]);
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <link type="text/css" rel="stylesheet" href="css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="css/animate.min.css" />
    <title></title>
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
        <div class="wxtitle">对不起，在利郎企业号中找不到您的信息！您可以尝试使用零售管理身份进入。</div>
        <a class="btn btn-success bounceIn animated" onclick="jump('retail')"><i class="fa fa-weixin"></i>利郎零售管理</a>        
        <div class="copyright">
            利郎信息技术部
        </div>
    </div>

    <script type="text/javascript">
        function jump(type) {           
            if (type == "retail") {
                var gourl = escape("<%=redic_url%>");
                gourl = "redirectwx.aspx?autoAuth=retail&redic_url=" + gourl;
                window.location.href = gourl;
            }
        }
    </script>
</body>
</html>
