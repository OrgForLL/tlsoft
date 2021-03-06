﻿<%@ Page Language="C#" %>
<%@ Register src="ApprovalContent.ascx" tagname="ApprovalContent" tagprefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        docid.Value = Request.QueryString["docid"].ToString();
        nodeid.Value = Request.QueryString["node"].ToString();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <!-- Need to get a proper redirect hooked up. Blech. -->
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>单据终审</title>
    <link rel="stylesheet" href="css/themes/default/jquery.mobile-1.4.2.min.css" />
	<script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.4.2.min.js"></script>
       <script>
        $(document).ready(function () {           
            
        });
		var _ReturnUsers = new Array();
		function ReturnBack(){
			$(':mobile-pagecontainer').pagecontainer('change', 'ReturnBack.html', { role: 'dialog',transition: 'none' } );
			$("#btnReturnDone").bind("click", ReturnDone);
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
</head>
<body>
     <!-- Home -->
	<div data-role="page" id="page1">
		<div data-theme="c" data-role="header" data-mini="true">
			<div data-role="controlgroup" data-type="horizontal" class="ui-mini ui-btn-right">
            <a data-role="button" href="#dialogPage" data-rel='dialog' data-transition="none">终审</a>
            <a href="javascript:ReturnBack()"  data-role="button" >退办</a>
            </div>
			<a  href="approvalList.aspx" data-ajax="false" class="ui-btn-left" data-icon="delete">
				返回
			</a>
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
	<div data-role="page" id="dialogPage" data-mini="true" href="KaoqinAduit.html">
        <div data-role="header" data-theme="c">
            <h2>终审</h2>
        </div>
        <div id="showInfo" data-role="content">
            <form  method="post" id="form1" action="AuditSend.aspx">
              <input id="action" name="action" type="hidden" value="send" />
              <input id="docid" name="docid" type="hidden" value="" runat="server" />
              <input id="nodeid" name="nodeid" type="hidden" value="0" runat="server"/>
              <input id="IsEnd" name="IsEnd" type="hidden" value="1" />
              <input id="AduitNode" name="AduitNode" type="hidden" value="0" />
              <input id="Auditer" name="Auditer" type="hidden" value="0" />
            <ul data-role="listview" data-inset="true">
                <li data-role="fieldcontain">
                    <label for="textNote">审批意见:</label>
                    <textarea cols="40" rows="8" name="textNote" id="textNote"></textarea>
                </li>
                <li class="ui-body ui-body-a">
                    <fieldset class="ui-grid-a">
                        <div class="ui-block-a">
                        <a href="#page1" data-role="button"> 取消 </a></div>
                        <div class="ui-block-b">
                        <button type="submit" data-theme="d"> 完成 </button>
                        </div>
                    </fieldset>
                </li>
            </ul>
            </form>
        </div>
    </div>
</body>
</html>
