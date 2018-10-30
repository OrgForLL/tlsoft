<%@ Page Language="C#" Debug="true" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head2" runat="server">
    <meta charset="utf-8">
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title></title>
    <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script src="http://code.jquery.com/mobile/1.3.1/jquery.mobile-1.3.1.min.js"></script>
    <link rel="stylesheet" href="http://code.jquery.com/mobile/1.3.1/jquery.mobile-1.3.1.min.css" />
    <style>

      .jfcx
    {
		table-layout:fixed;
        text-align:center;
        width:90% ;
		margin-left:auto;
		margin-right:auto;
		border:2px solid #D9D9D9;	

	    border-radius:20px;
		-moz-border-radius:20px;
        background-color:#FDFDF0;
    }
    .div1
    {
        width:80% ;
		margin-left:auto;
		margin-right:auto;

    }
    .tr1
    {
        border-top-color:#D9D9D9;
        border-bottom:2px solid #ff0000;      
    }
    .td1
    {
     height:50px;
     text-align:right;
     width:30%;
     border-right-style:none;
     border-bottom:2px solid #D9D9D9;
     
    }
     .td2
    {
     height:50px;
     text-align:left;
     width:70%;
     border-left-style:none;
     border-bottom:2px solid #D9D9D9;
     
    }
     .td3
    {
     height:50px;
     text-align:right;
     width:30%;
     border-left-style:none;

     
    }
     .td4
    {
     height:50px;
     text-align:left;
     width:70%;
     border-left-style:none;

     
    }
    </style>
    <script runat="server">
        
        TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
        string idlist = "";
        string tzid = "1";
        public string[] jf;
        public StringBuilder STRB = new StringBuilder();
        // public StringBuilder STRB1 = new StringBuilder();
        protected void Page_Load(object sender, EventArgs e)
        {
            //获取微信id
            //string wxid = Context.Request["wx"];
            string wxid = "123456";
            IDataReader reader = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select  isnull(a.zh,'') zh,isnull(b.xm,'') xm,isnull(a.level,0)level,isnull(a.jf,0)jf,isnull(a.bkrq,'')bkrq,isnull(a.je,'')je from wx_t_hyxx a inner join wx_t_wxyhxx b on a.wxid=b.wxid where b.wxid=" + wxid + " ");
            while (reader.Read())
            {
                STRB.AppendFormat("{0}#{1}#{2}#{3}#{4}#{5}", reader[0], reader[1], reader[2], reader[3], reader[4], reader[5]);
                
            }
             jf=STRB.ToString().Split('#');
             if(jf[0]==""){
                 Response.Write("您还未绑定vip卡!");
                 Response.End();
             }
            

        }
    </script>
<%--    <script language="javascript" type="text/javascript">
        function BUTTON2_onclick() {

        var browserName = navigator.appName; 
if (browserName=="Netscape") { 
window.open('', '_self', ''); 
window.close(); 
} 
else { 
if (browserName == "Microsoft Internet Explorer"){ 
window.opener = "whocares"; 
window.opener = null; 
window.open('', '_top'); 
window.close(); 
} 
} 

            //window.opener = null; 
            //window.close();
        }

    
    </script>--%>
</head>
<body style="background-color:#efefef">
    <div data-role="page" >
        <div id="header" data-role="header">
            <h1>
                积&nbsp;分&nbsp;查&nbsp;询</h1>
        </div>
        <!-- /header -->
        <div class='test' data-role="content" class="ui-grid-b">

            <table class="jfcx" border="0" cellspacing="0" cellpadding="0">
               <tr class="tr1"><td class="td1">姓名：</td><td class="td2"><%=jf[1] %></td></tr>
               <tr class="tr1"><td class="td1">卡号：</td><td class="td2"><%=jf[0] %></td></tr>
               <tr class="tr1"><td class="td1">等级：</td><td class="td2"><%=jf[2] %></td></tr>
               <tr class="tr1"><td class="td1">积分：</td><td class="td2"><%=jf[3] %></td></tr>
               <tr class="tr1"><td class="td1">办卡日期：</td><td class="td2"><%=jf[4] %></td></tr>
               <tr class="tr1"><td class="td3">金额：</td><td class="td4"><%=jf[5] %></td></tr>
            </table>

            </div>
<%--           <fieldset>
                <div class="div1">
                    <button type="submit" data-theme="b" id="BUTTON2" language="javascript" onclick="BUTTON2_onclick()"
                        atomicselection="True">
                        确定</button></div>
            </fieldset>--%>

        </div>

    </div>
    <!-- /page -->
</body>
</html>

