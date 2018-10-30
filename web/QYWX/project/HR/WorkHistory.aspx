<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WorkHistory.aspx.cs" Inherits="LilanzWXService.WorkHistory" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>工作经验</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes"/> 
    <META HTTP-EQUIV="pragma" CONTENT="no-cache">
    <META HTTP-EQUIV="Cache-Control" CONTENT="no-cache, must-revalidate">
    <META HTTP-EQUIV="expires" CONTENT="Wed, 26 Feb 1979 08:21:57 GMT">
	<link rel="stylesheet" href="css/PageStyle.css" />        
</head>
<body style=" background-color:White;margin:0px 0.5em 0px 0px; padding::0px 0.5em 0px 0px;">
    <form id="form1" runat="server">
        <div>
         <%-- <div data-role="header"data-theme="a" data-position="fixed">          
           <div data-role="navbar">
            <ul>
              <li><a style="width:40%;" onclick="gotoResumeView()" data-role="button" data-icon="home" data-iconpos="left" ></a></li>    
              <li style=" text-align: center; vertical-align: middle;line-height:2.5em">工作经历</li>
              <li><a style="width:40%; float:right" href="WorkEdit.aspx" data-role="button" data-transition="slide" data-icon="plus" data-iconpos="right" ></a></li>
             </ul>
            </div>
          </div>--%>
           <div data-role="header"data-theme="a" >
              <a data-direction="reverse" data-role="button" onclick="gotoResumeView()" data-transition="slidefade" data-icon="home" data-iconpos="notext">返回</a>
              <h3>编辑工作经历</h3>
          </div>

     <div data-role="content">
         <ul data-role="listview" data-inset="true">
           <%= workInfo %>
         </ul>
    </div>
        
          <%--  <div data-role="footer" class="ui-btn" data-theme="a">
                <div data-role="controlgroup" data-type="horizontal">
                    <a href="WorkEdit.aspx" data-role="button" data-transition="slide" ><img alt="添加记录" src="skins/save.png" />添加记录</a>
                    <a data-role="button"  data-transition="flow" onclick="gotoResumeView()" ><img alt="返回个人简历" src="skins/back.png" />返回个人简历</a>
                </div>
            </div>   --%>
             <div data-role="footer"  data-theme="a" data-position="fixed"> 
               <div data-role="navbar" > 
                 <ul>
                    <li><a id="addWork" href="WorkEdit.aspx" data-icon="plus" data-iconpos="left" >添加记录</a></li>
                 </ul>
               </div>                
            </div>    
        
            <asp:HiddenField ID="tmxid" runat="server" />
        </div> 
    </form>
</body>
</html>

