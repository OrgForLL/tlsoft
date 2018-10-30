<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditInformation.aspx.cs" Inherits="LilanzWXService.EditInformation" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>完善个人信息</title>  
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

<body style="margin:0px; padding:0px">
       
    <form id="form1" runat="server" method="post">  
         <%-- <div data-role="header" data-theme="a">
          <h1>编辑个人信息</h1>
          </div>--%>
      <div data-role="header"data-theme="a"  data-position="fixed">
         <%-- <div data-role="navbar" >
            <ul>
              <li><a style="border-radius:10px;border:1px solid #666666; width:70%;" href="ResumeView.aspx" data-direction="reverse" data-role="button"  data-transition="slide"  >
              <img alt="返回" src="skins/back.png" />返回</a></li>    
              <li style=" text-align: center; vertical-align: middle;line-height:2.5em">编辑个人信息</li>
              <li><a style="border-radius:10px;border:1px solid #666666; width:70%; float:right" data-role="button" onclick="SaveBaseInfo();"><img alt="保存数据" src="skins/save.png" />保存</a></li>
             </ul>
            </div>--%>
           <h3>完善个人信息</h3>
           <a href="ResumeView.aspx" data-direction="reverse" data-role="button"  data-transition="slidefade" data-icon="home" data-iconpos="notext">返回</a>
          </div>

          <div data-role="content" data-theme="a" style=" z-index:2;">
           
            <label for="Name">姓名：</label> 
            <asp:TextBox ID="Name" Width="100%" runat="server" MaxLength="50"></asp:TextBox>

            <fieldset data-role="controlgroup" data-type="horizontal">
            <legend>请选择您的性别：</legend>
            <label for="male">男性</label>
            <input type="radio" name="sex" id="male" value="男" <%= strmale %> />
            <label for="female">女性</label>
            <input type="radio" name="sex" id="female" value="女" <%= strfemale %> />	
            </fieldset>
                                         
              <label for="birthday">出生日期：</label>
              <input type="date" name="birthday" id="birthday" value="<%= strbirthday %>" /> 
          
            <label for="phoneNum">电话号码：</label>           
            <asp:TextBox ID="phoneNum" style=" width:100%;" runat="server" MaxLength="50"></asp:TextBox>
         
             <label for="Diploma">学历：</label>
             <asp:DropDownList ID="Diploma" runat="server">
                <asp:ListItem Value="05" Text="大专"></asp:ListItem>
                <asp:ListItem Value="03" Text="本科"></asp:ListItem> 
                <asp:ListItem Value="02" Text="硕士"></asp:ListItem> 
                <asp:ListItem Value="99" Text="其他"></asp:ListItem> 
             </asp:DropDownList>
              
            <label for="School">学校：</label>   
            <asp:TextBox ID="School" style=" width:100%;" runat="server" MaxLength="50"></asp:TextBox>

             
            <label for="Major">专业：</label> 
            <asp:TextBox ID="Major" style=" width:100%;" runat="server" MaxLength="50"></asp:TextBox>
         
        </div> 

         <div data-role="footer"  data-theme="a" data-position="fixed"> 
             <div data-role="navbar" > 
                <ul>
                  <li><a id="btnsave" onclick="SaveBaseInfo();" data-icon="check" data-iconpos="left" >保存</a></li>                      
                  <li><a href="ResumeView.aspx" data-direction="reverse" data-transition="slidefade" data-icon="back" data-iconpos="left" >返回</a></li>
                </ul>
                 <%--<a id="btnsave" data-role="button" onclick="SaveBaseInfo();" data-icon="check" data-iconpos="left" >保存</a>
                 <a href="ResumeView.aspx" data-direction="reverse" data-role="button"  data-transition="slidefade" data-icon="back" data-iconpos="left" >返回</a>--%>
            </div> 
          </div>    
        
        <div id="divWaiting" style=" display:none; position:absolute; width:300px;height:100px;border:1px solid #c0c0c0; left:10px;top:100px; background-image:url('skins/waitbak.png'); z-index:999; ">
            <img src="skins/wait.gif" alt="请稍候.." style=" position:absolute; left:71px; top:15px;" />
            <div id="divWaitInfo" style=" position:absolute; left:0px; top:50px; width:100%; font-size:14px; height:50px; line-height:24px; text-align:center; vertical-align:middle">
            执行中,请稍候...
            </div>
        </div>  
   </form>

           
</body>
</html>
