<%@ Page Language="C#" Debug="true"%>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Register src="ApprovalContent.ascx" tagname="ApprovalContent" tagprefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
        
    nrWebClass.LiLanzDAL sqlhelper = new nrWebClass.LiLanzDAL();
    public int flow_currentNode = 0;
    protected void Page_Load(object sender, EventArgs e)
    {
        string tzid = Session["userssid"].ToString();
        string zbid = Session["zbid"].ToString();
        int flow_docID = int.Parse(Request.QueryString["docid"].ToString());
        string username = Session["username"].ToString();
        int userid = int.Parse(Session["userid"].ToString());
        string xtlb = Session["xtlb"].ToString();
        int flowid = 0;
        int dxid = 0;
        docid.Value = flow_docID.ToString();
        
        string comm = "SELECT flowid,flowname,currentNode,nodebbid,dxid FROM dbo.f_flow_getFlowData({0})";
        comm = String.Format(comm, flow_docID);
        using (IDataReader dr = sqlhelper.ExecuteReader(comm))
        {
            if (dr.Read())
            {
                flow_currentNode = int.Parse(dr[2].ToString());
                flowid = int.Parse(dr[0].ToString());
            }
        }
        //
        /*
        comm = "select currentUserid,dxid from fl_t_flowRelation where docID={0}";
        comm = String.Format(comm, flow_docID);
        using (dr = sqlhelper.ExecuteReader(comm))
        {
            if (dr.Read())
            {
                dxid = int.Parse(dr[1].ToString());
                //if (userid != int.Parse(dr[0].ToString()))
                //    operateButton = "";
            }
        }
        */
        comm = "exec flow_up_getNextNode '{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}'";
        comm = string.Format(comm, flow_docID, flow_currentNode, tzid, zbid, userid, username, xtlb);
        AduitNode.DataSource = sqlhelper.ExecuteDataTable(comm);
        AduitNode.DataValueField = "NodeID";
        AduitNode.DataTextField = "nodeName";
        AduitNode.DataBind();
        if (AduitNode.Items.Count > 0)
        {
            AduitNode.Items[0].Selected = true;
            comm = "exec flow_up_getNodeUser '{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}'";
            comm = string.Format(comm, flow_docID, AduitNode.Items[0].Value, tzid, zbid, userid, username, xtlb);

            Auditer.DataSource = sqlhelper.ExecuteDataTable(comm);
            Auditer.DataValueField = "userid";
            Auditer.DataTextField = "username";
            Auditer.DataBind();
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
     <meta charset="utf-8">
    <!-- Need to get a proper redirect hooked up. Blech. -->
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>审批</title>
    <link rel="stylesheet" href="css/themes/default/jquery.mobile-1.4.2.min.css" />
	<script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.4.2.min.js"></script>
    <script>
        $(document).bind('mobileinit', function () {
			//$.mobile.ajaxEnabled = false;
        });
        $(document).ready(function () {
            $("#OkGo").bind("click", function () {
				if($("#Auditer").val() == null){	
					$( "#msg p" ).html("请选择下一节点审批人.");
					$( "#msg" ).popup( "open" );
					return;
				}
				$("#form1").submit();
            });
			$("#AduitNode").change(function(e) {
			    $("#Auditer").empty();
			    $.getJSON("NextAduiter.ashx?nodeid=" + $("#Auditer").val() + "&docid=" + $("#docid").val(),
                    function(data){
					$.each(data, function(i,item){
						$("#Auditer").append("<option value='"+item.userid+"'>"
						+item.username+"</option>");
					});
					$("#Auditer").selectmenu( "refresh" );
				});
            });
        });
		var _ReturnUsers = new Array();
		function ReturnBack(){
			$(':mobile-pagecontainer').pagecontainer('change', 'ReturnBack.html', { role: 'dialog',transition: 'none' } );
			$.getJSON("NodeReturn.ashx?nodeid=" + $("#nodeid").val() + "&docid=" + $("#docid").val(),
				function(data){
					
					$("#radio-group").html("");
					$.each(data.nodes, function(i,item){
						$("#radio-group").append('<input type="radio" name="ReturnNodes" id="ReturnNodes-'+
						item.nodeid+'" value="'+
						item.nodeid+'"><label for="ReturnNodes-'+item.nodeid+'">'
						+item.nodename+'</label>');
					});
					$.each(data.users, function(i,item){
						_ReturnUsers[item.nodeid] = item;
					});
					
					$("input[name=ReturnNodes]").eq(0).attr("checked" ,"checked");
					$("#radio-group").enhanceWithin().controlgroup("refresh");
					ReturnNodechange();
					$("input[name=ReturnNodes]").click(function(){
						ReturnNodechange();
					});
			 });
			
		}
		function ReturnNodechange(){
			$("#ReturnUserid").empty();
			var item = _ReturnUsers[$("input[name=ReturnNodes]:checked").val()]
			$("#ReturnUserid").append("<option value='"+item.userid+"'>"
		    +item.username+"</option>");
			$("#ReturnUserid").selectmenu( "refresh" );
		}
		function ReturnDone() {
		    var _url = "NodeReturnTo.ashx?nodeid=" + $("input[name=ReturnNodes]:checked").val()
            + "&docid=" + $("#docid").val() + "&userid=" + $("#ReturnUserid").val() + "&note="+
            $("#ReturntextNote").val();
		    $.mobile.loading("show", {theme: "z",html: ""});
		    $.ajax({
		        type: "POST",
		        url: _url,
		        success: function (msg) {
		            if (msg == 'done') {
		                $.mobile.changePage("approvalList.aspx", "slidedown", true, true);
		            } else {
		            }
		        },
		        ajaxComplete: function (ev) {
		            $.mobile.loading('hide');
		        }
		    }); 
		}
	</script>
    <style>
	table td, th{
		padding:4px;
	}
	</style>
</head>
<body>
    <!-- Home -->
	<div data-role="page" id="page1">
		<div data-theme="c" data-role="header" data-mini="true">		
			<a data-role="button" href="#page1" class="ui-btn-left">返回</a>
            <div data-role="controlgroup" data-type="horizontal" class="ui-mini ui-btn-right">
            <a data-role="button" href="#dialogPage" data-rel='dialog' data-transition="none">办理</a>
            <a href="javascript:ReturnBack()"  data-role="button" >退办</a>
            </div>
			<h3>
				单据审批
			</h3>
		</div>
		<uc1:ApprovalContent ID="ApprovalContent1" runat="server" />
	<div data-theme="c" data-role="footer" data-position="fixed">
        <h3>
            协同移动办公
        </h3>
    </div>
	
	</div>
	<!--对话框-->
	<div data-role="page" id="dialogPage" data-mini="true" >
	  <div data-role="header" data-theme="c">
		<h2>审批</h2>
	  </div>
      <form  method="post" id="form1" action="AuditSend.aspx">
      <input id="action" name="action" type="hidden" value="send" />
      <input id="docid" name="docid" type="hidden" value="" runat="server" />
      <input id="nodeid" name="nodeid" type="hidden" value="<%=flow_currentNode%>" />
	  <div id="showInfo" data-role="content">
		<ul data-role="listview" data-inset="true">
			<li data-role="fieldcontain">
				<label for="AduitNode" class="select" style="font-size:12px">下一个节点:</label>
				<select name="AduitNode" id="AduitNode" runat="server">
				</select>
			</li>
			<li data-role="fieldcontain">
				<fieldset data-role="controlgroup" data-type="horizontal" data-mini="true">
					<legend>审批方式:</legend>
						<input type="radio" name="radio-choice-b" id="radio-choice-c" value="list" checked="checked">
						<label for="radio-choice-c">单人</label>
						<input type="radio" name="radio-choice-b" id="radio-choice-d" value="grid">
						<label for="radio-choice-d">多人</label>
				</fieldset>
			</li>
			<li>
				<label for="Auditer" class="select" style="font-size:12px">请选择下一节点办理人:</label>
				<select name="Auditer" id="Auditer" data-native-menu="false" data-icon="grid" data-iconpos="left" runat="server">
				</select>
			</li>	
			<li data-role="fieldcontain">
				<label for="textNote">审批意见:</label>
			<textarea cols="40" rows="8" name="textNote" id="textNote"></textarea>
			</li>
			<li class="ui-body ui-body-a">
				<fieldset class="ui-grid-a">
				    <div class="ui-block-a">
                        <a href="#page1" data-role="button"> 取消 </a>
                    </div>
					<div class="ui-block-b">
                        <button type="button" data-theme="d" id="OkGo"> 完成 </button>
                    </div>
				</fieldset>
			</li>
		</ul>
	  </div>
       </form>
         <div data-role="popup" id="msg" class="ui-content" style="max-width:280px" data-dismissible="false">
        	<a href="#" data-rel="back" class="ui-btn ui-corner-all ui-shadow ui-btn-a ui-icon-delete ui-btn-icon-notext ui-btn-right">Close</a>
          	<p></p>
        </div>
	</div>
	<!--对话框结束-->
</body>
</html>
