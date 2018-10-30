<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" %>
<%@ Import Namespace = "System.Data"%>
<script runat="server">
    TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
    protected void Page_Load(object sender, EventArgs e)
    {
        string comm = @"select  b.khdm,'发往：' + b.khmc AS KHMC,a.rq,a.djh,a.zdr,a.shr,a.shrq,a.qrr,a.qrrq,a.qsr,a.qsrq  from  
yx_t_kcdjb a inner join yx_t_khb b on a.khid=b.khid and a.djlx=111
inner join yx_t_kcdjspid c on a.id=c.id and c.spid='{0}'";
        string sphh = Request.Form["sn"].ToString().Substring(0, 9);
        comm = string.Format(comm, Request.Form["sn"].ToString());
		
        DataSet ds = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn(), comm);
		DataSet ds1 = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn("1900"), comm);
        DataSet ds2 = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn("86"), comm);
        ds.Merge(ds1,true);
        ds.Merge(ds2, true);
        RepeaterList.DataSource = ds.Tables[0].DefaultView;

        nrWebClass.LiLanzDAL dataHelper = new nrWebClass.LiLanzDAL();
        IDataReader datareader = dataHelper.ExecuteReader(
String.Format(@"select spmc,lsdj,sphh from yx_T_spdmb where sphh='{0}'", sphh));
        if (datareader.Read())
        {
            LabelSpInfor.Text = datareader[0].ToString()  + "<br />零售价格：" + datareader[1].ToString();
        }
        //Label1.Text = ds.Tables[0].Rows.Count.ToString();
        RepeaterList.DataBind();

        comm = "";
    }

</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
 <meta charset="utf-8">

    <!-- Need to get a proper redirect hooked up. Blech. -->
    
    <meta name="robots" content="noindex, follow">

    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>物流信息列表</title>
    <link rel="stylesheet"  href="css/themes/default/jquery.mobile-1.3.1.min.css">
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,700">
    <script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.3.1.min.js"></script>
    <script>
		$( document ).on( "pageshow", function(){
			//$( "p.message" ).hide().delay( 1500 ).show( "fast" );
		});
		$(document).ready(function () {
			$("#goBack").bind("click", function(){
				//history.go();
				alert("阿斯顿");
			});
		});
	</script>
</head>
<body>
<!-- Home -->
<div id="page1" data-role="page">
  <div data-role="header" data-theme="a">
      <a class="ui-btn-left" href="#page1" data-role="button" data-iconpos="left"
      data-icon="delete" id="goBack" onclick=" window.location.href='BarCodeSearch.html'">
          返回
      </a>
      <h3>
          物流信息列表
      </h3>
  </div>
  <div data-role="content">
  <form id="form1" runat="server">   
  <asp:Label ID="LabelSpInfor" runat="server" Text="Label"></asp:Label>
  <table data-role="table" id="table-column-toggle" data-mode="columntoggle" class="ui-responsive table-stroke">
       <thead>
         <tr>
           <th data-priority="2">日期</th>
           <th data-priority="3">单据号</th>
           <th>信息</th>
           <th data-priority="5"><abbr title="Rotten Tomato Rating">签收日期</abbr></th>
           <th data-priority="1">签收人</th>
         </tr>
       </thead>
       <tbody>
          <asp:Repeater ID="RepeaterList" runat="server">
          <ItemTemplate>
            <tr>
              <td><%#DataBinder.Eval(Container.DataItem, "rq")%></td>
              <td><%#DataBinder.Eval(Container.DataItem, "djh")%></td>
              <td><%#DataBinder.Eval(Container.DataItem, "KHMC")%></td>
              <td><%#DataBinder.Eval(Container.DataItem, "qsrq")%></td>
              <td><%#DataBinder.Eval(Container.DataItem, "qsr")%></td>
             </tr>
          </ItemTemplate>
          </asp:Repeater>
       </tbody>
     </table>
   </form>
   </div>
 </div>
</body>
</html>
