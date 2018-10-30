<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    nrWebClass.LiLanzDAL sqlhelper = new nrWebClass.LiLanzDAL();
    protected void Page_Load(object sender, EventArgs e)
    {
        DataTable ds = sqlhelper.ExecuteDataTable(String.Format(@"select t1.id tempid,t1.ItemName,t2.creator,t2.created,t2.dxid,t2.docID,t2.currentUserid,t2.flag,t2.currentNode node from fl_t_MobileView as t1
inner join fl_t_flowRelation as t2 on t1.FlowID=t2.flowid
where t2.currentUserid={0} and t2.flag>1 and t2.created>='2014-01-01'  ", Session["userid"]));
        Repeater1.DataSource = ds;
        Repeater1.DataBind();
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>审批列表</title>
    <link rel="stylesheet" href="css/themes/default/jquery.mobile-1.4.2.min.css" />
	<script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.4.2.min.js"></script>
    <script>
	function ColseWin(){
		var opened=window.open('about:blank','_self');
		opened.opener=null;
		opened.close();
	}
	</script>
</head>
<body>
    <div data-role="page" id="page1">
		<div data-theme="c" data-role="header" data-mini="true">
			<a  data-ajax="false" href="menu.aspx" class="ui-btn-left" data-icon="delete">
				关闭
			</a>
			<h3>
				单据审批
			</h3>
		</div>
		<div data-role="content">
			<ul data-role="listview">
              <asp:Repeater ID="Repeater1" runat="server">
                 <ItemTemplate>
                 <li>
                  <a href="<%#Eval("flag").ToString()=="3"?"appproval.aspx":"ApprovalEnd.aspx"%>?id=<%#Eval("dxid")%>&docid=<%#Eval("docID")%>&tempid=<%#Eval("tempid")%>&node=<%#Eval("node")%>" data-ajax="false">
                  <span><%#Eval("ItemName")%></span>
                  <p><%#Eval("creator")%></p>
                  <p class="ui-li-aside"><%#Eval("created")%></p>
                  </a>
                </li>
                </ItemTemplate>
              </asp:Repeater>
            </ul>
	    </div>
	<div data-theme="c" data-role="footer" data-position="fixed">
        <h3>
            协同移动办公
        </h3>
    </div>
	
	</div>

</body>
</html>
