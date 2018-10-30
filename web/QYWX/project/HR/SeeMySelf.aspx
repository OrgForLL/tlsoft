<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SeeMySelf.aspx.cs" Inherits="LilanzWXService.SeeMySelf" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>自我评价</title>  
	<script type="text/javascript" src="Scripts/wxBridge.js"></script>   
    <META HTTP-EQUIV="pragma" CONTENT="no-cache">
    <META HTTP-EQUIV="Cache-Control" CONTENT="no-cache, must-revalidate">
    <META HTTP-EQUIV="expires" CONTENT="Wed, 26 Feb 1978 08:21:57 GMT">

<%--     <script type="text/javascript">
         function SaveGoodAndWeak() {
             var goodPoint = escape($("#goodPoint").val()); 
             var weakPoint = escape($("#weakPoint").val()); 

             ShowWaiting("正在保存信息...");
             $.ajax({
                 type: "post",
                 url: "WXHRHandler.ashx",
                 data: "Act=SaveGoodAndWeak&goodPoint=" + goodPoint + "&weakPoint=" + weakPoint,
                 success: function (result) {
                     HideWaiting();
                     if (result.err == "") {
                         alert(result.msg);
                         gotoResumeView();
                     } else { alert(result.err); }
                 }
             });
         }

         function gotoResumeView() {
             location.href = "ResumeView.aspx";
         }          
     </script>--%>
</head> 
<body style="margin:0px; padding:0px">
    <form id="form1" runat="server" method="post"> 

      <%--   <div data-role="header"data-theme="a" data-position="fixed" >
          <div data-role="navbar" >
            <ul>
             <li><a  style="border-radius:10px; border:1px solid #666666; width:70%;" href="ResumeView.aspx" data-direction="reverse" data-role="button"  data-transition="slide" >
              <img alt="返回" src="skins/back.png" />返回</a></li>    
              <li style=" text-align: center; vertical-align: middle;line-height:2.5em">自我评价</li>
              <li><a  style="border-radius:10px;border:1px solid #666666; width:70%; float:right" data-role="button" onclick="SaveGoodAndWeak();" ><img alt="保存数据" src="skins/save.png" />保存</a></li>
             </ul>
            </div>
          </div>
            </div>--%>
          <div data-role="header"data-theme="a" >
              <a href="ResumeView.aspx" data-direction="reverse" data-role="button"  data-transition="slidefade" data-icon="back" data-iconpos="notext">返回</a>
              <h3>自我评价</h3>
          </div>

            <div data-role="fieldcontain">
              <label for="goodPoint" style="font-size: x-large">优点：</label> 
            <asp:TextBox ID="goodPoint" Width="100%" TextMode="MultiLine" runat="server" MaxLength="300"></asp:TextBox>
               <label for="weakPoint" style="font-size: x-large">不足：</label> 
            <asp:TextBox ID="weakPoint" Width="100%" TextMode="MultiLine" runat="server" MaxLength="300"></asp:TextBox>
            </div>
           <%-- <div data-role="footer"  class="ui-btn" data-position="fixed" data-theme="a">
              <div data-role="navbar">
                <ul>
                    <li><a id="btnsave" data-role="button" onclick="SaveGoodAndWeak();" ><img alt="保存数据" src="skins/save.png" />保存数据</a></li>
                    <li><a href="ResumeView.aspx" data-direction="reverse" data-role="button"  data-transition="slidefade" ><img alt="返回个人简历" src="skins/back.png" />返回个人简历</a></li>
                </ul>
              </div>
            </div> --%>
             <div data-role="footer"  data-theme="a" data-position="fixed"> 
              <div data-role="navbar" > 
                <ul>
                  <li><a  data-role="button" onclick="SaveGoodAndWeak();" data-icon="check" data-iconpos="notext">保存数据</a></li>    
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
