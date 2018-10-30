<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InfoDemo.aspx.cs" Inherits="LilanzWXHR.InfoDemo" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>效果模拟</title>
	<link rel="stylesheet" href="css/phoneStyle.css" /> 
</head>
<body>
    <form id="form1" runat="server">
        <div style=" position:absolute;left:0px; height:615px; width:314px;">                
            <img style="position:absolute;" src="skins/iphone/phone.png" alt="效果" />        
            <div class="phoneDemoDisplay" style="<%=BodyStyle %>">
                <asp:Label ID="lblInfo" runat="server" Text=""></asp:Label>
            </div>
        </div> 
    </form>
</body>
</html>
