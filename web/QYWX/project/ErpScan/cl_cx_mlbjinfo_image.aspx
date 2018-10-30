<%@ Page Language="C#" Debug="true" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server"> 

    protected void Page_Load(object sender, EventArgs e)
    {

        string url = HttpUtility.UrlDecode(Request.QueryString["src"]);
        if (string.IsNullOrEmpty(url))
        {
            Response.Write("图片路径有问题");
            Response.End();
        }
        else
            DownloadFile(url);
    }

    public void DownloadFile(string URL)
    {
        try
        {

            System.Net.HttpWebRequest Myrq = (System.Net.HttpWebRequest)System.Net.HttpWebRequest.Create(URL);
            Myrq.Timeout = 5000;
            using (System.Net.HttpWebResponse myrp = (System.Net.HttpWebResponse)Myrq.GetResponse())
            {
                Stream s = myrp.GetResponseStream();
                System.Drawing.Image img;
                img = System.Drawing.Image.FromStream(s);
                Response.ContentType = "Image/PNG";//通知浏览器发送的数据是JPEG格式的图像
                img.Save(Response.OutputStream, System.Drawing.Imaging.ImageFormat.Png);
            }
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
            Response.End();
        }
    }

</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <title></title>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link rel="Stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="Stylesheet" href="../../res/css/ErpScan/bootstrap.css" />
    <link rel="Stylesheet" href="../../res/css/font-awesome.min.css" />
    <link href="../../res/css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>
    <style type="text/css">
        body {
            font-size: 14px;
            line-height: 20px;
        }
    </style>

    <style type="text/css">
        .row {
            padding-top: 10px;
        }

        th {
            text-align: center;
            vertical-align: middle;
        }

        td {
            word-break: break-all;
            text-align: center;
            vertical-align: middle;
        }
    </style>
</head>
<body>
    <img id="pic" runat="server" />
</body>
</html>
