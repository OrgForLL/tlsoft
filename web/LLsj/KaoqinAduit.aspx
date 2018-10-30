<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" Debug="true" EnableViewState="false"  %>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.Common"%>
<script runat="server">
    TLBaseData._MyData sqlHelp = new TLBaseData._MyData();
    public int flow_currentNode;
    public String operateButton = "<a data-role=\"button\" href=\"#dialogPage\" class=\"ui-btn-right\" data-rel='dialog' data-transition=\"none\" data-icon=\"check\" >办理</a>";
    protected void Page_Load(object sender, EventArgs e)
    {
        //Random rnd1 = new Random();
        //WL(rnd1.Next(0, 999999) + 1000000); //随机数
        if (Session["userid"] == null)
        {
            Response.Write("error!");
            Response.End();
        }
        int tzid = 1;
        int zbid = 1;
        int flow_docID = int.Parse(Session["docid"].ToString());
        string username = Session["username"].ToString();
        int userid = int.Parse(Session["userid"].ToString());
        string xtlb = "Z";
        flow_currentNode = 0;
        int flowid = 0;
        int dxid = 0;
        string comm = "SELECT flowid,flowname,currentNode,nodebbid,dxid FROM dbo.f_flow_getFlowData({0})";
        comm = String.Format(comm, flow_docID);
        using (DbDataReader dr = (DbDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), comm))
        {
            if (dr.Read())
            {
                flow_currentNode = int.Parse(dr[2].ToString());
                flowid = int.Parse(dr[0].ToString());
            }
        }
        comm = "select currentUserid,dxid from fl_t_flowRelation where docID={0}";
        comm = String.Format(comm, flow_docID);
        using (DbDataReader dr = (DbDataReader)sqlHelp.MyDataRead(sqlHelp.GetConn(), comm))
        {
            if (dr.Read())
            {
                dxid = int.Parse(dr[1].ToString());
                if (userid != int.Parse(dr[0].ToString()))
                    operateButton = "";
            }
        }
        comm = @"select c.xm,c.xb,bm.bmmc,gw.mc as gwmc,a.id,a.ryid,a.rybh,a.rzrq,a.zqcqts,zccqts ,a.jbcqts ,a.kxqjts ,'@sbmc' sbmc,
                           a.qjlx1 ,a.qjlx2 ,a.qjlx3 ,a.qjlx4 ,a.qjlx5 ,a.qjlx6 ,a.qjlx7 ,a.qjlx8 ,a.qjlx9 ,
                           a.cd ,a.cdmin ,a.cdmax ,a.zt ,a.ztmin ,a.ztmax ,a.kg ,a.hjqjlx1 ,a.hjqjlx6 ,a.wxqjlx1 ,a.wxqjlx2 ,a.wxqjlx6,
                           bm.bmmc,
                        case when a.rzzt=0 then '在职' when a.rzzt=1 then '<font class=red>新入职</font>' when a.rzzt=2 then '<font class=red>变动前</font>' when a.rzzt=3 then '<font class=red>变动后</font>' end rzzt
 
                        from rs_t_yggzsbb b 
	                        inner join kq_t_kqybb a on b.id=a.sbid and b.ny=a.ny
	                        inner join rs_t_ryxxb c on a.ryid=c.id
	                        inner join rs_t_rygzdwzlb d on c.id=d.id	
	                        inner join rs_t_bmdmb bm on d.bmid=bm.id 
	                        inner join dm_t_gwdmb gw on d.gwid=gw.id
                        where b.id={0} and b.flowid={1}
                         and (d.rzzk in('01','99') )";
        comm = string.Format(comm, dxid, flowid);
        DataSet ds = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn(), comm);
        RepeaterList.DataSource = ds.Tables[0].DefaultView;
        RepeaterList.DataBind();
        //comm = "exec flow_up_getNextNode '" + flow_docID + "' ,'" + flow_currentNode + "' ,'" + tzid.ToString() + "' ,'" + zbid + "' ,'" + userid + "','" + username + "','" + xtlb + "'";
        comm = "exec flow_up_getNextNode '{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}'";
        comm = string.Format(comm, flow_docID, flow_currentNode, tzid, zbid, userid, username, xtlb);
 
        AduitNode.DataSource = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn(), comm);
        AduitNode.DataValueField = "NodeID";
        AduitNode.DataTextField = "nodeName";
        AduitNode.DataBind();
        if (AduitNode.Items.Count > 0)
        {
            AduitNode.Items[0].Selected = true;
            comm = "exec flow_up_getNodeUser '{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}'";
            comm = string.Format(comm, flow_docID, AduitNode.Items[0].Value, tzid, zbid, userid, username, xtlb);
            
            Auditer.DataSource = (DataSet)sqlHelp.MyDataSet(sqlHelp.GetConn(), comm);
            Auditer.DataValueField = "userid";
            Auditer.DataTextField = "username";
            Auditer.DataBind();
        }
        //Session["docid"] = null;
        //Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "Test", "alert('Hi');", true);
    }

</script>
<!DOCTYPE html><html>
<head>
    <meta charset="utf-8">
    <!-- Need to get a proper redirect hooked up. Blech. -->
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>考勤审批</title>
    <link rel="stylesheet"  href="css/themes/default/jquery.mobile-1.3.1.min.css">
    <script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.3.1.min.js"></script>
    <script>
		//$( document ).on( "pageshow", function(){
		//	$( "p.message" ).hide().delay( 1500 ).show( "fast" );
		//});
		$(document).bind('mobileinit', function() {
			//$.mobile.defaultPageTransition = 'none';
			//$.mobile.page.prototype.options.domCache= false;

		});
		$(document).ready(function(){
			$("#OkGo").bind("click", function(){
			    //alert($("#AduitNode").val());
				//alert($("#Auditer").val());
			    $("#action").val("send");
				//$("#message").html("办理成功!");
				//$("#popupBasic").popup( "open", {default: "none"} );
				$("#form1").submit();
			});
        })
		function ColseWin(){
            var opened=window.open('about:blank','_self');
			opened.opener=null;
			opened.close();
		}
		function OkGo_onclick() {

		}

    </script>
    <style>
	table td, th{
		padding:4px;
	}
	.ui-dialog-contain {
	width: 92.5%;
	max-width: 500px;
	margin: 10% auto 15px auto;
	padding: 0;
	position: relative;
	top: -15px;
	background-color:#FFF;
	}
	#showInfo{font-size:12px}
	</style>
</head>
<body>

	<!-- Home -->
	<div data-role="page" id="page1">
		<div data-theme="a" data-role="header" data-mini="true">
            <%=operateButton%>
			<a data-role="button" href="javascript:ColseWin()" class="ui-btn-left" data-icon="delete">
				关闭
			</a>
			<h3>
				考勤审批
			</h3>
		</div>
		<div data-role="content">
			<div data-role="controlgroup" data-mini="true" >
				<table  border="1" cellspacing="0" style="border-collapse: collapse; font-size:12px;" bordercolor="#000000" cellpadding="0" >
				 <tr>
					<th width="50">部门</th>
					<th width="50">姓名</th>
				    <th width="70">入职日期</th>
					<th width="50">计薪天数</th>
					<th width="50">请假</th>
					<th width="50">迟到次数</th>
				  </tr>
                  <asp:Repeater ID="RepeaterList" runat="server">
                  <ItemTemplate>
                    <tr>
                      <td><%#DataBinder.Eval(Container.DataItem, "bmmc")%></td>
                      <td><%#DataBinder.Eval(Container.DataItem, "xm")%></td>
                      <td><%#DataBinder.Eval(Container.DataItem, "rzrq", "{0:yyyy-mm-dd}")%></td>
                      <td><%#DataBinder.Eval(Container.DataItem, "zqcqts")%></td>
                      <td><%#DataBinder.Eval(Container.DataItem, "kxqjts")%></td>
                      <td><%#DataBinder.Eval(Container.DataItem, "cdmin")%></td>
                     </tr>
                  </ItemTemplate>
                  </asp:Repeater>
				</table>
		    </div>
	    </div>
	<div data-theme="a" data-role="footer" data-position="fixed" data-mini="true">
        <h5>
            协同移动办公
        </h5>
    </div>
	</div>
	<!--对话框-->
	<div data-role="page" id="dialogPage" data-mini="true" data-corners="false" data-transition="none">
	  <div data-role="header">
		<h2>审批</h2>
	  </div>
      <form  method="post" id="form1" action="AuditSend.aspx">
      <input id="action" name="action" type="hidden" />
      <input id="docid" name="docid" type="hidden" />
      <input id="nodeid" name="nodeid" type="hidden" value="<%=flow_currentNode%>" />
	  <div id="showInfo" data-role="content">
		<ul data-role="listview" data-inset="true">
			<li data-role="fieldcontain">
				<label for="AduitNode" class="select" style="font-size:12px">下一个节点:</label>
				<select name="AduitNode" id="AduitNode" runat="server">
					<option value="1234">人力资源终审</option>
				</select>
			</li>
			<li data-role="fieldcontain">
				<fieldset data-role="controlgroup" data-type="horizontal" data-mini="true" style="font-size:12px">
					<legend style="font-size:12px">审批方式:</legend>
						<input type="radio" name="radio-choice-b" id="radio-choice-c" value="list" checked="checked">
						<label for="radio-choice-c">单人</label>
						<input type="radio" name="radio-choice-b" id="radio-choice-d" value="grid">
						<label for="radio-choice-d">多人</label>
				</fieldset>
			</li>
			<li>
				<label for="Auditer" class="select" style="font-size:12px">请选择下一节点办理人:</label>
				<select name="Auditer" id="Auditer"  data-native-menu="false" data-icon="grid" data-iconpos="left" runat="server">
				</select>
			</li>	
			<li data-role="fieldcontain">
				<label for="textarea2">审批意见:</label>
			<textarea cols="40" rows="8" name="textNote" id="textNote"></textarea>
			</li>
			<li class="ui-body ui-body-b">
				<fieldset class="ui-grid-a">
						<div class="ui-block-a">
                        <a href="javascript:ColseWin()"  data-role="button" data-rel="popup"> 取消 </a></div>
						<div class="ui-block-b">
                        <button type="button" data-theme="d" id="OkGo" onclick="return OkGo_onclick()"> 完成 </button>
                        </div>
				</fieldset>
			</li>
		</ul>
	  </div>
      </form>
      
	</div>
	<!--对话框结束-->

</body>
</html>
