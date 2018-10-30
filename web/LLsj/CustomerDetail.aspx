<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    public string khid="0";
    protected void Page_Load(object sender, EventArgs e)
    {
        khid = Request.QueryString["khid"].ToString();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title></title>
    <link rel="stylesheet" href="http://code.jquery.com/mobile/1.3.1/jquery.mobile-1.3.1.min.css" />
	<script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script src="http://code.jquery.com/mobile/1.3.1/jquery.mobile-1.3.1.min.js"></script>
    <script type="text/javascript">
        var Customer;
        var khid = "0";
        $(document).ready(function () {
            //$.mobile.ajaxLinksEnabled = false;

            $.getJSON("CustomerListJson.aspx?khid=<%=khid%>", null, function (obj) {
                var custlist = $("#CustList");
                Customer = obj.rows;
                for (var i = 0; i < obj.rows.length; i++) {

                    custlist.append("<li><a onclick='LoadUserInfo(" + i + ")' href='#dialogPage' data-rel='dialog'>" + obj.rows[i].mdmc + "</a></li>");
                }
                $("#CustList").listview({ inset: true, icon: "star", filter: true, filterPlaceholder: "输入要查找的专卖店" });
            });

        });
        function LoadUserInfo(id) {
            khid = Customer[id].khid;
            $("#UserInfo").html("专卖店: " + Customer[id].mdmc + "<br /> 用户名: "
            + Customer[id].mdid + " <br />密码: " + Customer[id].pwd);
			
			$("#times").html('<div id="timeDetail"><h4>查看订货时间</h4><p id="timeList" style="font-size:12px"> 查询订货时间</p><a  href="javascript:InitTimes()">初始化 </a></div>');
			
			$("#timeDetail").collapsible({collapsed:true});
			
			$("#timeDetail").bind('expand', GetTimes); 
        }
		function GetTimes(){
			$.getJSON("CustomerTimeJson.aspx?khid="+khid, null, function (obj) {
				$("#timeList").html("");
				var HtmlString = "<table>";
				for (var i = 0; i < obj.rows.length; i++) {
					HtmlString += "<tr><td>" + obj.rows[i].mc + "</td><td>" + obj.rows[i].startday + "</td></tr>";
				}
				HtmlString += "</table>";
				$("#timeList").html(HtmlString);
			});
		}
        function InitTimes() {
			$.ajax({type: 'GET', 
				   url: "CustomerInit.aspx?khid="+khid ,
				   success: function(data){
					   //alert(data);
					   if(data== "ok")
					       GetTimes();
					   else
					       alert("there are something wrong!");
				   } 
			});
			
        }
	</script>
</head>
<body>

    <form id="form1" runat="server">

<!-- Home -->
<div data-role="page">
  <div data-role="header">
    <a data-role="button" href="javascript:history.go(-1)" class="ui-btn-left">返回 </a>
    <h1>客户信息检索</h1>
  </div>
  <div data-role="content">
    <ul id="CustList">
    </ul>
  </div>
</div>
<!--对话框-->
<div data-role="page" id="dialogPage">
  <div data-role="header">
    <h2>用户信息</h2>
  </div>
  <div data-role="content">
     <div id="UserInfo"></div>
     <div id="times">  
     </div>
  </div>
</div>
<!--对话框结束-->
    </form>
</body>
</html>
