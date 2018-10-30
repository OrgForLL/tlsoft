<%@ Page Language="C#" Debug="true"%>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    public string erplink = "<a href=\"main.aspx?mycase=tzxz\" data-ajax=\"false\">移动ERP</a>";
    public string oaurl = "";
    public string qylList="";    
    protected void Page_Load(object sender, EventArgs e)
    {
        string qx = "0";
        if (Session["qx"]!=null)
            qx=Session["qx"].ToString();
       
        DataSet dataSet = null;        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(1))
        {
            string listModal=@"<li><a href='{0}' >{1}</a></li>";

            dal.ConnectionString = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft ";
            string str_sql = @"SELECT a.* FROM t_menu a 
                INNER JOIN t_user_qx b ON b.id_user={0} AND b.id_ssid=1 AND b.id_menu=a.id
                WHERE a.ssid=25723";
            dal.ExecuteQuery(string.Format(str_sql,Session["userid"] ), out dataSet);
            foreach(DataRow dr in dataSet.Tables[0].Rows)
                qylList += string.Format(listModal, dr["m_memo"], dr["m_name"]);

            if (qylList.Length == 0)
                qylList = string.Format(listModal, "", "IM权限未开通");

        }
        if (qx != "1")
        {
            erplink = "<a data-ajax=\"false\">移动ERP(未授权)</a>";
        }
        oaurl = string.Format("http://{0}:8100/LoginRedirest.aspx", Request.Url.Host);

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
<%--           <li><a href="">
                 移动供应链
            </a></li>--%>
            <%=qylList %>
            <li>
                <a href="<%=oaurl %>" >工作联系单(待办)</a>
            </li>
            <li><a href="http://tm.lilanz.com/oa/project/MyFabricScan/MyFabricScanForMobilePage.aspx" >
                 面料图片上传
            </a></li>
<%--            <li>
				<%=miylink%>
			</li>
               <li><a href="http://tm.lilanz.com/oa/project/ErpScan/Materials.aspx" >
                 商品中心/技术部调样接收与领用
            </a></li>
           <li><a href="http://tm.lilanz.com/oa/project/ErpScan/BQScan.aspx" >
                 样品配料信息
            </a></li>          <li><a href="http://tm.lilanz.com/oa/project/ErpScan/sphhinfo.aspx" >
                成衣标签信息
            </a></li>--%>

            <li><a href="http://tm.lilanz.com/oa/project/ErpScan/erpModulMenu.aspx?menulb=Z&menumb=yycj">样衣生产刷码
            </a></li>
			<li><a href="http://tm.lilanz.com/oa/project/ErpScan/ScanWqUniqueCode.aspx" >
                尾期不合格扫描
            </a></li>
            <li><a href="http://tm.lilanz.com/oa/project/ErpScan/yf_T_ScanSPLManage.aspx" >
                订货样交接
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
