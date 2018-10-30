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

     .jxxf
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
        font-size:1.2em;
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
     text-align:center;
     width:20%;
     border-left-style:none;
     border-right-style:none;
     border-bottom:2px solid #D9D9D9;
     
    }
     .td2
    {
     height:50px;
     text-align:center;
     width:30%;
     border-left-style:none;
     border-right-style:none;
     border-bottom:2px solid #D9D9D9;
     
    }
         .td3
    {
     height:50px;
     text-align:center;
     width:30%;
     border-left-style:none;
     border-right-style:none;
     border-bottom:2px solid #D9D9D9;
     
    }
         .td4
    {
     height:50px;
     text-align:right;
     width:20%;
     border-left-style:none;
     border-bottom:2px solid #D9D9D9;
     
    }
     .td5
    {
     height:50px;
     text-align:center;
     width:20%;
     border-left-style:none;
     border-right-style:none;

     
    }
     .td6
    {
     height:50px;
     text-align:center;
     width:20%;
     border-left-style:none;
     border-right-style:none;

     
    }
         .td7
    {
     height:50px;
     text-align:center;
     width:30%;
     border-left-style:none;
     border-right-style:none;

     
    }
     .td8
    {
     height:50px;
     text-align:right;
     width:20%;
     border-left-style:none;

     
    }
    .td0
    {
     height:50px;
     text-align:center;
     width:10%;
     border-right-style:none;
     border-bottom:2px solid #D9D9D9;       
    }
    .td01
    {
     height:50px;
     text-align:center;
     width:10%;
     border-right-style:none;
     
    }   
     .td10
    {
     height:50px;
     text-align:center;
     width:100%;
    
      
    }
    </style>
    <script runat="server">
        
        TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
        string idlist = "";
        string tzid = "1";
        public string[] jf;
        public int i = 0;
        public StringBuilder STRB = new StringBuilder();
        // public StringBuilder STRB1 = new StringBuilder();
        protected void Page_Load(object sender, EventArgs e)
        {
            //获取微信id
            //string wxid = Context.Request["wxid"];
            string wxid = "1";
            IDataReader reader = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select top 3 isnull(a.xm,'') as xm,isnull(a.kh,'')as kh,convert(varchar(10),b.sj,120) as sj,isnull(b.sskje,'') sskje,isnull(a.wxid,'') as wxid from wx_t_wxyhxx a inner join [192.168.35.11].fxdb.dbo.zmd_t_lsdjb  b on a.kh=b.vip where a.wxid=" + wxid + " order by b.sj desc");
            while (reader.Read())
            {
                STRB.AppendFormat("{0}#{1}#{2}#{3}#{4}#", reader[0], reader[1], reader[2], reader[3], reader[4]);

            }
             jf=STRB.ToString().Split('#');
              i = jf.Length;
             if (i == 0) {
                 Response.Write("您还未绑定vip卡,或者您还没有消费记录!");
                 //Response.End();
             }
        }
    </script>
     <script language="javascript" type="text/javascript">
         function BUTTON2_onclick(wxid) {
             var wxid = wxid;
             var url = "wx_jxxf_2.aspx?wxid=" + wxid;
             window.location.href = url;
         }
     </script>
</head>
<body style="background-color:#efefef">
    <div data-role="page" >
        <div id="header" data-role="header">
            <h1>
                消&nbsp;费&nbsp;查&nbsp;询</h1>
        </div>
        <!-- /header -->
        <div class='test' data-role="content" class="ui-grid-b">

            <table class="jxxf" border="0" cellspacing="0" cellpadding="0" >
               <tr><td class="td1">姓名</td><td class="td2">卡号</td><td class="td3">时间</td><td class="td4">金额</td></tr>
               <tr><td class="td1"><%=jf[0] %></td><td class="td2"><%=jf[1] %></td><td class="td3"><%=jf[2] %></td><td class="td4"><%=jf[3] %></td></tr>
               <% 
                   if (i < 4){}else{
                   %>
                      <tr><td class="td1"><%=jf[5] %></td><td class="td2"><%=jf[6] %></td><td class="td3"><%=jf[7] %></td><td class="td4"><%=jf[8] %></td></tr>
                    <% 
                        if (i < 8) { }
                        else
                        {
                       %>
                     <tr><td class="td5"><%=jf[10] %></td><td class="td6"><%=jf[11] %></td><td class="td7"><%=jf[12] %></td><td class="td8"><%=jf[13] %></td></tr>
               <% 
                        }
                   } 
                   %>

            </table>
            <fieldset>
                <div class="div1">
                    <button type="submit" data-theme="b" id="BUTTON2" language="javascript" onclick="BUTTON2_onclick(<%=jf[4] %>)"
                        atomicselection="True">
                        查&nbsp;看&nbsp;全&nbsp;部</button></div>
            </fieldset>
            </div>

    </div>
    <!-- /page -->
</body>
</html>

