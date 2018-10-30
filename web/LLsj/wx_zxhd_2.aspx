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
    .rdiv
    {
        text-align:right; width:100%; height:50px;
    }
    .img
    {
        width:80px ;height:50px;
    }
    .div
    {
        width:10% ;
    }
        .div1
    {
        width:80% ;
		margin-left:auto;
		margin-right:auto;

    }
                .more
    {
        text-align:center;		
    }
    </style>
    <script runat="server">
        TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
        string UpFilePath = "../photo/zxhd/";
        string idlist = "";
        string tzid = "1";
        public StringBuilder STRB = new StringBuilder();
       // public StringBuilder STRB1 = new StringBuilder();
        // public StringBuilder STRB1 = new StringBuilder();
        protected void Page_Load(object sender, EventArgs e)
        {

            // string strSQL = string.Format(@"select top 5 isnull(hdnr,''),isnull(tp,'') from t_zxhd  order by zdrq", new object[] { });
            IDataReader reader = (IDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), "select top 20  isnull(hdnr,'') as hdnr,isnull(tp,'') as tp,id from t_zxhd  order by zdrq");
            while (reader.Read())
            {
                STRB.AppendFormat("<li onclick=\"BUTTON1_onclick({2})\">{0}<img class=img src=\"" + UpFilePath + "{1}\" ></li>", reader[0], reader[1],reader[2]);
                //STRB1.AppendFormat("{0}", reader[0]);
                // STRB1.AppendFormat("<li>{0}</li>", reader[0]);
            }
            // DataSet ds = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn(tzid), strSQL);

        }
    </script>
    <script language="javascript" type="text/javascript">
        function BUTTON2_onclick() {
            //alert('123');
            //alert(STRB1.toString());
            window.location.href = 'wx_zxhd_1.aspx';
            //history.go(-1);
        }
        function BUTTON1_onclick(id) {
            var hdid = id;
            var url = "wx_zxhd_3.aspx?id=" + hdid;
            window.location.href = url;
            //history.go(-1);
        }
    
    </script>
</head>
<body style="background-color:Gray">
    <div data-role="page" >
        <div id="header" data-role="header">
            <h1>
                最新活动</h1>
        </div>
        <!-- /header -->
        <div class='test' data-role="content" class="ui-grid-b">

            <div class="div1">
            <ul data-role="listview" data-split-icon="gear" data-split-theme="d">
                <%=STRB.ToString()%>
                </ul>

            </div>
            <br/>
           <fieldset>
                <div class="div1">
                    <button type="submit" data-theme="b" id="BUTTON2" language="javascript" onclick="BUTTON2_onclick()"
                        atomicselection="True">
                        返回</button></div>
            </fieldset>

        </div>
        <div data-role="footer">
            <h2>
                LILANZ</h2>
        </div>
    </div>
    <!-- /page -->
</body>
</html>
<%--<html>
<head>
	<title>利郎最新活动</title>
    <script runat="server">
   
    protected void Page_Load(object sender, EventArgs e)
    {
       // string strSQL = string.Format(@"insert into  t_zxhd(zdrq,zdr,hdnr,bz,tp) values('1999-01-01','才','123','1','') ", new object[] { });
       // DataSet ds = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn(tzid), strSQL);
        string strSQL = string.Format(@"select top 5 isnull(hdnr,''),isnull(tp,'') from t_zxhd  order by zdrq", new object[] {  });
        DataSet ds = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn(tzid), strSQL);
       /* if (ds.Tables.Count > 0)
        {
            //int x=123;
            Response.Write("没有最新活动");
            Response.End();
        }*/
            
        DataTable dt = ds.Tables[0];
        foreach (DataRow dr in dt.Rows)
        {

            HtmlTableRow htmltr = new HtmlTableRow();
            foreach (DataColumn dc in dt.Columns)
            {
                string dcvalue = dr[dc].ToString();
                HtmlTableCell htmltc = new HtmlTableCell();
                htmltc.InnerText = dcvalue;
                htmltr.Cells.Add(htmltc);
            }
            HtmlTableCell htmltx = new HtmlTableCell();
            htmltr.Cells.Add(htmltx);
            this.htmltb.Rows.Add(htmltr);
        }
   
    }

    
    
</script>
</head>

<script language="javascript">

</script>
<body leftmargin="0" topmargin="0" style="scrollbar:yes" oncontextmenu=self.event.returnValue=false >
 <div id="main"  >
        <form id="form1" runat="server">
    <div id="top" align="center">
         <table  backgroundcolor="gray" align="center" id = "Table1" runat="server">
      <tr  align="center" >
        <th  width="100%">利郎最新活动:</th>
      </tr> 
    </table>   
    </div>
    </form>
    <div  id="center">
    <table   align="center" id = "htmltb" runat="server">
      <tr  align="center" >
        <th  width="70%" ></th>
        <th  width="30%" ></th>
      </tr> 
    </table>
    </div>
    <div id="bottom"></div>
 </div>

</body>
</html>--%>
