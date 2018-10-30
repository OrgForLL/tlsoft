<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResumeView.aspx.cs" Inherits="LilanzWXService.ResumeView" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>我的简历</title>    
	<link rel="stylesheet" href="css/PageStyle.css" />     
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes"/> 
    <META HTTP-EQUIV="pragma" CONTENT="no-cache">
    <META HTTP-EQUIV="Cache-Control" CONTENT="no-cache, must-revalidate">
    <META HTTP-EQUIV="expires" CONTENT="Wed, 26 Feb 1978 08:21:57 GMT">
     
	<script type="text/javascript" src="Scripts/wxBridge.js"></script> 
    <link rel="stylesheet" href="css/jquery.mobile-1.4.2.min.css">
    <script type="text/javascript" src="Scripts/jquery-1.8.3.min.js"></script>
    <script type="text/javascript" src="Scripts/jquery.mobile-1.4.2.min.js"></script>    
	<script type="text/javascript" src="Scripts/Waiting.js"></script>
	<script type="text/javascript" src="Scripts/JQSub.js"></script> 
     
</head>
<body style="background-color:White;font-size:16px;">
    <form id="form1" runat="server">  
          <div data-role="header" data-theme="a">
          <h1>个人简历</h1>
          </div>
        <div data-role="content">
<%--            <div style="position:relative;  height:36px; width: 100%; text-align: center; line-height:40px; vertical-align:bottom;
                                 font-weight:bold;  font-size: 24px; border-bottom:2px solid #3333C0 ">
                个人简历
            </div>--%>

            <div style="position:relative;top:5px;  font-size:18px; width:100%">
               <div class="radial2" style="position:relative; width: 100%; height:30px; vertical-align:middle ; font-weight:bold; line-height:30px;">
                   <img alt="" src="skins/ypgw.png" style=" position:relative;top:3px;" />应聘岗位</div>         
                   <div style="position:absolute; top:0px; right:10px; width:100px; text-align: right;">
                        <a data-transition="slidefade" href="http://tm.lilanz.com/hr/JobsForStudents.html"><img alt="" src="skins/go.png" style=" position:relative;top:3px;" />去看看</a>
                   </div>      
                   <div style="position:relative;">                   
                        <label for="postInformation">请选择岗位类型：<%=txtpostInformation %></label>
                        <asp:DropDownList ID="postInformation" runat="server" AutoPostBack="true"
                            onselectedindexchanged="postInformation_SelectedIndexChanged">
                        <asp:ListItem Value="" Text="点击此处进行选择"></asp:ListItem>
                        <asp:ListItem Value="业务采购方向培训生" Text="业务采购方向培训生"></asp:ListItem>
                        <asp:ListItem Value="成衣设计方向培训生" Text="成衣设计方向培训生"></asp:ListItem> 
                        <asp:ListItem Value="品质检测方向培训生" Text="品质检测方向培训生"></asp:ListItem> 
                        <asp:ListItem Value="面辅料设计方向培训生" Text="面辅料设计方向培训生"></asp:ListItem> 
                        <asp:ListItem Value="服装技术方向培训生" Text="服装技术方向培训生"></asp:ListItem> 
                        <asp:ListItem Value="IT方向培训生" Text="IT方向培训生"></asp:ListItem> 
                        <asp:ListItem Value="商品企划方向培训生" Text="商品企划方向培训生"></asp:ListItem> 
                        </asp:DropDownList>
                 </div>
            </div>
            <div style="position:relative;top:10px;  font-size:18px; width:100%">
               <div class="radial2" style="position:relative; width: 100%; height:30px; vertical-align:middle ; font-weight:bold; line-height:30px;">
                   <img alt="" src="skins/user.png" style=" position:relative;top:3px;" />基本信息</div>
                   <div style="position:absolute; top:0px; right:10px; width:100px; text-align: right;">
                        <a data-transition="slidefade" href="EditInformation.aspx"><img alt="" src="skins/gotoEdit.png" style=" position:relative;top:3px;" />编辑</a>
                   </div>
               <div style="position:relative;"><%=BaseInformation%></div>
            </div>
            <div style="position:relative;top:15px;  font-size:18px; width:100%">
               <div class="radial2" style="position:relative; width: 100%; height:30px; vertical-align:middle ; font-weight:bold;line-height:30px">
                   <img alt="" src="skins/work.png" style=" position:relative;top:3px;" />社会实践</div>
                   <div style="position:absolute; top:0px; right:10px; width:100px; text-align: right;">
                    <a href="WorkHistory.aspx" data-transition="slidefade"><img alt="" src="skins/gotoEdit.png" style=" position:relative;top:3px;" />编辑</a>
                   </div>
               <div style="position:relative;"><%=Experience%></div>
             </div>
            <div style="position:relative;top:25px; font-size:18px; width:100%">
               <div class="radial2" style="position:relative; width: 100%; height:30px; vertical-align:middle ; font-weight:bold;line-height:30px">
                   <img alt="" src="skins/Honour.png" style=" position:relative;top:3px;" />自我评价
               </div>
                <div style="position:absolute; top:0px; right:10px; width:100px; text-align: right;">
                    <a href="SeeMySelf.aspx" data-transition="slidefade"><img alt="" src="skins/gotoEdit.png" style=" position:relative;top:3px;" />编辑</a>
                </div>
                <div style="position:relative;"><%=SelfSee%></div>
             </div>
             <div style="position:relative;width:100%; height:40px;"></div>
        </div> 
    </form> 
</body>
</html>
 
