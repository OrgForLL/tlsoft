<%@ Page Language="C#"%>

<script runat="server">
   
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxe46359cef7410a06&redirect_uri=http://tm.lilanz.com/OA/project/OfficeDaily/canteenConsume.aspx?c=8&response_type=code&scope=SCOPE&state=STATE&connect_redirect=1#wechat_redirect");
    }
    
</script>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>餐厅刷卡</title>
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0">
    <style type="text/css">
*{margin:0;
padding:0;
}
.container{
	background-color:#FFF;
	display:block;
	height:100%;
	padding-top:36px}
.msg{ margin-bottom:30px;
text-align:center}
div{display:block}
.msg-text{text-align:center; 
margin-bottom:25px}
.msg-btn{text-align:center;
margin:15px;}
.btn{text-decoration:none;
font-size:18px;
box-sizing:border-box;
padding-left:18px;
padding-right:18px;
background-color:#04be02;
color:#fff;
display:block;
line-height:2.3;
border-radius: 10px;
}
</style>

</head>
<body>
    <form id="form1" runat="server">
    <div class="container">
        <div class="msg">
     
        </div>
        <div class="msg-text">
            <h2>
                <asp:Label ID="LabelUser" runat="server" Text=""></asp:Label></h2>
            <p></p>
        </div>
        <div class="msg-btn">
            <a href="javascript:WeixinJSBridge.call('closeWindow')" class="btn">关闭</a>
        </div>
    </div>
    </form>
</body>
</html>
