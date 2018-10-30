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
            string wxid = Context.Request["wxid"];
            IDataReader reader = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select top 20 isnull(a.xm,'') as xm,isnull(a.kh,'')as kh,convert(varchar(10),b.sj,120) as sj,isnull(b.sskje,'') sskje from wx_t_wxyhxx a inner join [192.168.35.11].fxdb.dbo.zmd_t_lsdjb  b on a.kh=b.vip where a.wxid=" + wxid + " order by b.sj desc");
            while (reader.Read())
            {
                STRB.AppendFormat("{0}#{1}#{2}#{3}#", reader[0], reader[1], reader[2], reader[3]);

            }
             jf=STRB.ToString().Split('#');
              i = jf.Length;
             if (i == 0) {
                 Response.Write("您还未绑定vip卡,或者您还没有消费记录!");
                 //Response.End();
             }
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
               <% 
                   for (int j = 0; j <= i-9; j=j+4)
                   {
                   %>
               <tr><td class="td1"><%=jf[j]%></td><td class="td2"><%=jf[j+1]%></td><td class="td3"><%=jf[j+2]%></td><td class="td4"><%=jf[j+3]%></td></tr>
               <%
                   }
                   for (int k = i - 5; k < i-4; k=k+4)
                   {
                        %>

                     <tr><td class="td5"><%=jf[k]%></td><td class="td6"><%=jf[k+1]%></td><td class="td7"><%=jf[k+2]%></td><td class="td8"><%=jf[k+3]%></td></tr>
               <%} %>

            </table>
            </div>


        </div>

    </div>
    <!-- /page -->
</body>
</html>

