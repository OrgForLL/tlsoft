<%@ Page Title="" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>


<script runat="server">


    public string QrCodeValue = "";       //QrCodeValue
    public string testUrl = "";
    protected void Page_PreRender(object sender, EventArgs e)
    {
        //BindKey = this.Master.AppSystemKey;
        //if (BindKey == "")
        //{
        //    clsSharedHelper.WriteErrorInfo("您还未激活全渠道系统的使用权限！");
        //}
        //else
        //{
        
        //请注意：文件部署在正式环境和测试环境所生成的二维码路径是不一样的。    
        //GetQrCode.aspx 后缀参数在测试环境中 域名后面还需要加入 %2fQYWX ，在正式环境中则不要
        string myUrl = Request.Url.AbsoluteUri;
        if (myUrl.ToLower().Contains("tm.lilanz.com/qywx/"))    //如果这个路径是测试系统，则输出附加QYWX，使扫描结果指向231；否则不附加QYWX，扫描结果直接到15下的VIP
        {
            testUrl = "%2fQYWX";
        }
        else
        {
            testUrl = "%2fOA";                
        }

        QrCodeValue = Guid.NewGuid().ToString().Replace("-", ""); 
                   
        //}
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        Master.IsTestMode = true;
    }
</script>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }

        body {
            font-family: Helvetica,Arial,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            color: #333;
            background-color: #f0f0f0;
        }

        .qrcode {
            position: fixed;
            left: 0;
            right: 0;
            top: 0;
            bottom: 0;
            background: #2d3132;
        }

        .qrcon {
            background: #fff;
            border-radius: 4px;
            width: 80%;
            padding: 20px;
            max-width: 480px;
            box-sizing: border-box;
            overflow: hidden;
        }

        .center-translate {
            position: absolute;
            top: 50%;
            left: 50%;
            -webkit-transform: translate(-50%, -50%);
            transform: translate(-50%, -50%);
        }

        .qrcon .headimg {
            float: left;
            border-radius: 6px;
        }

        .qrcon .wxnick {
            letter-spacing: 0px;
            font-weight: bold;
            margin-left: 74px;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
        }

        .qrcon img {
            width: 96%;
            height: auto;
            max-width: 240px;
        }

        .area {
            font-size: 14px;
            color: #808080;
            font-weight: normal;
            line-height: 40px;
        }

        .qrtxt {
            margin-top: 100px;
            width: 100%;
            text-align: center;
            position: absolute;
            left: 0;
            bottom: 10px;
            color: #808080;
        }

        .headimg 
        {            
            margin: 0 auto;
            width: 60px;
            height: 60px;
            border: 2px solid #ebebeb;
            border-radius: 50%;
            -webkit-border-radius: 50%;
            background-size: cover;                        
            background-position: 50% 50%;
            background-repeat: no-repeat;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="container">
        <div class="qrcode">
            <div class="qrcon center-translate">               
                <p class="wxnick area">Step1：请使用微信[扫一扫]扫描以下二维码</p>
                <p style="text-align: center; margin: 10px 0 30px 0;">
                    <img alt="二维码" src="GetQrCode.aspx?code=http%3a%2f%2ftm.lilanz.com<%= testUrl %>%2fproject%2fStoreSaler%2fllchatpcStep2.aspx%3fc%3d<%= QrCodeValue  %>" />
                </p>
                <div class="qrtxt">
                    <br />
                    Step2：扫码认证成功后，请<a href="llchat_pc.html?QrCodeValue=<%= QrCodeValue  %>">点击此处进行登录</a>！
                </div>
            </div>
        </div>
    </div>

</asp:Content>
