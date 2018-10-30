<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
            Data_Load();
    }
    private void Data_Load()
    {
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            DataTable dtScalar;
            string errInfo = "";
            string exeSQL = "SELECT PositionID,PositionName FROM rs_t_Position WHERE IsStopped = 0 AND PositionClassID=@id";
            if (Request.QueryString["cat"] != null)
            {
                List<SqlParameter> listSqlParameter = new List<SqlParameter>();
                listSqlParameter.Add(new SqlParameter("@id", Request.QueryString["cat"].ToString()));
                errInfo = dal.ExecuteQuerySecurity(exeSQL, listSqlParameter, out dtScalar);
            }
            else
            {
                List<SqlParameter> listSqlParameter = new List<SqlParameter>();
                exeSQL = "SELECT PositionID,PositionName FROM rs_t_Position WHERE IsStopped = 0 ";
                errInfo = dal.ExecuteQuerySecurity(exeSQL, listSqlParameter, out dtScalar);
            }
            Repeater1.DataSource = dtScalar;
            Repeater1.DataBind();
            Response.Write(errInfo);
        }
    }
</script>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=0.8">
    <title>招聘职位列表</title>
    <link rel="stylesheet" href="css/themes/default/jquery.mobile-1.4.3.min.css">
    <!--
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,700">
    -->
    <script src="js/jquery.min.js"></script>
    <script src="js/jquery.mobile-1.4.3.min.js"></script>
    <style>
	#jobcat, #jobcat li{
		 font-size:1.3em;
		 display:block;
		 margin-left:5px;
	}
	#jobcat a:link{
		text-decoration: none; 
	}
	#jobcat{margin-left:20px;
	margin-right:20px:}
	.detailContent{
		margin-top:20px;
	}
	.detailTitle{
		margin-bottom:10px;
	}
	</style>
    <script type="text/javascript">
	$(document).ready(function(e) {
        $("#close").click(function(e) {
            window.close();
        });
    });
	</script>
</head>
<body>
<div data-role="page" id="page1">
     <div data-role="header" >
		<h1>职位查询</h1>
        <a href="#"class="ui-btn ui-icon-delete ui-btn-icon-notext ui-corner-all" id="close">No text</a>
	</div>
    <div data-role="content">
		<!--
        <fieldset data-role="controlgroup" data-type="horizontal" data-mini="true">
            <legend>职位类别:</legend>
                <div id="jobcat">
                    <span><a href="?cat=1">设计开发类</a></span>
                    <span><a href="?cat=2">营销类</a></span>
                    <span><a href="?cat=3">技术研发类</a></span>
                    <span><a href="?cat=4">供应链管理类</a></span>
                    <span><a href="?cat=5">职能类</a></span>
                </div>
        </fieldset>
		-->		
        <ul data-role="listview" data-inset="true" data-filter="true" data-filter-placeholder="输入要查询职位名称">
            <li data-role="list-divider" role="heading">
                岗位信息
            </li>
         <asp:Repeater ID="Repeater1" runat="server">
         <ItemTemplate>
            <li data-theme="c">
                <a href="JobDetail.aspx?id=<%# DataBinder.Eval(Container.DataItem, "PositionID")%>" data-transition="slide">
                    <%# DataBinder.Eval(Container.DataItem, "PositionName")%>
                </a>
            </li>
          </ItemTemplate>
        </asp:Repeater>
        </ul>
    </div>
</div>
</body>
</html>
