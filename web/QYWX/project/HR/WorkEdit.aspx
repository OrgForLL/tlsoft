<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WorkEdit.aspx.cs" Inherits="LilanzWXService.WorkEdit" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>编辑工作经历</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes"/> 
    <META HTTP-EQUIV="pragma" CONTENT="no-cache">
    <META HTTP-EQUIV="Cache-Control" CONTENT="no-cache, must-revalidate">
    <META HTTP-EQUIV="expires" CONTENT="Wed, 26 Feb 1978 08:21:57 GMT">
	<link rel="stylesheet" href="css/PageStyle.css" />  
</head>
<body>
    <form id="form1" runat="server">
  <%--        <div data-role="header"data-theme="a" data-position="fixed" >
          <div data-role="navbar">
            <ul>
              <li><a style="width:40%;" href="WorkHistory.aspx" data-role="button" data-direction="reverse" data-transition="slide"  data-icon="back" data-iconpos="left" ></a></li>    
              <li style=" text-align: center; vertical-align: middle;line-height:2.5em">编辑工作经历</li>
              <li><a style="width:40%; float:right" data-role="button" onclick="SaveWorkInfo()"; data-icon="check" data-iconpos="left" ></a></li>
             </ul>
            </div>
          </div>--%>
          <div data-role="header"data-theme="a" >
              <a href="WorkHistory.aspx" data-direction="reverse" data-role="button"  data-transition="slidefade" data-icon="back" data-iconpos="notext">返回</a>
              <h3>编辑工作经历</h3>
          </div>

          <div data-role="content"data-theme="a">    
            <div >
                <label for="tWorkTimeStart">时间从：</label>
              <input type="date" name="tWorkTimeStart" id="tWorkTimeStart" value="<%= tWorkTimeStart %>" /> 
              <label for="tWorkTimeEnd">到：</label>
              <input type="date" name="tWorkTimeEnd" id="tWorkTimeEnd" value="<%= tWorkTimeEnd %>" />
                公司：<asp:TextBox ID="tCompany"  runat="server"></asp:TextBox><br />
                职位：<asp:TextBox ID="tPosition" runat="server"></asp:TextBox><br /> 
             </div>
          </div>
       <asp:HiddenField ID="tmxid" runat="server" />

       <%--   <div data-role="footer"class="ui-btn" data-theme="a">
           <a data-role="button" onclick="SaveWorkInfo();"><img alt="保存数据" src="skins/save.png" style=" position:relative ;top:0.2em;" />保存</a>
           <a href="WorkHistory.aspx" data-direction="reverse" data-role="button"  data-transition="pop"><img alt="返回" src="skins/back.png" />返回</a>
          </div> --%>  
             
            <%-- <div data-role="navbar">
                <ul>
                    <li><a id="btnsave" data-role="button" onclick="SaveWorkInfo();" data-icon="check" data-iconpos="left" >保存</a></li>
                    <li><a href="WorkHistory.aspx" data-direction="reverse" data-role="button"  data-transition="slide"  data-icon="back" data-iconpos="left" >返回</a></li>
                   <%=myDel %>
                </ul>
            </div>    --%>
            <div data-role="footer"  data-theme="a" data-position="fixed"> 
             <div data-role="navbar" > 
                <ul>
                  <li><a id="btnsave" onclick="SaveWorkInfo();" data-icon="check" data-iconpos="left" >保存</a></li>                      
                  <%=myDel %>
                </ul>
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
