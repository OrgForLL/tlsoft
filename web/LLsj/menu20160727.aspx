<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    public string erplink = "<a href=\"main.aspx?mycase=tzxz\" data-ajax=\"false\">移动ERP</a>";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (int.Parse(Session["qx"].ToString()) != 1)
            erplink = "<a data-ajax=\"false\">移动ERP(未授权)</a>";
            
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8">
    <!-- Need to get a proper redirect hooked up. Blech. -->
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>主菜单</title>
    <link rel="stylesheet" href="css/themes/default/jquery.mobile-1.4.2.min.css" />
	<script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.4.2.min.js"></script>
     <style>
	li a{
		height:3em;
	}
	</style>
</head>
<body>
<div data-role="page" id="page1">
    <div data-theme="c" data-role="header" data-mini="true">
        <h3>
            主菜单
        </h3>
	</div>
    
    <div data-role="navbar" data-theme='a'>
        <ul>
            <li ><a href="approvalList.aspx" data-ajax="false">
                OA单据审批 
            </a></li>
            <li><a href="" data-ajax="false">
                订货会会务管理[建设中] 
            </a></li>

            <li>
              <%=erplink%>
            </li>
           <li><a href="" >
                 移动供应链
            </a></li>


            <li><a href="" >
               
            </a></li>
            <li><a href="" >
                 
            </a></li>

        </ul>
    </div><!-- /navbar -->
    <div data-theme="c" data-role="footer" data-position="fixed">
        <h3>
            协同移动办公
        </h3>
    </div>
</div>
</body>
</html>
