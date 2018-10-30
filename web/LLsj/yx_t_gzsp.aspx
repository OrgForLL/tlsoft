<%@ Page Language="vb" %>
<%@Import Namespace="System.Data"%>
<%@Import Namespace="System.Data.SqlClient"%>
<!--#include file="../mycss/inc_mycss.inc" -->

<html>
<head>
    <meta charset="utf-8">
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
	<title>贸易公司工资审批</title>
    <link rel="stylesheet"  href="css/themes/default/jquery.mobile-1.3.1.min.css">
    <link rel="stylesheet" href="demos/_assets/css/jqm-demos.css">
    <link rel="shortcut icon" href="demos/_assets/favicon.ico">
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,700">
    <script src="js/jquery.js"></script>
    <script src="demos/_assets/js/index.js"></script>
    <script src="js/jquery.mobile-1.3.1.min.js"></script>
    <script type="text/javascript">
        //$( document ).on( "pageshow", function(){
        //	$( "p.message" ).hide().delay( 1500 ).show( "fast" );
        //});
        $(document).bind('mobileinit', function () {
            $.mobile.defaultPageTransition = 'none';
            $.mobile.page.prototype.options.domCache = true;
        });
	</script>
    <style type="text/css">
	    table td, th{
		    padding:4px;
	    }
	    .ui-dialog-contain {
	        width: 92.5%;
	        max-width: 500px;
	        margin: 10% auto 10px auto;
	        padding: 0;
	        position: relative;
	        top: -15px;
	        background-color:#FFF;
	    }
	    #page1{background-color:#00F}
	</style>
	<LINK href="../mycss/my_style.css" type="text/css" rel="stylesheet">

	<script  LANGUAGE="javascript">
		function mysubmitjs() 
		{ 
			MyForm.myxz.value="list";
			MyForm.zt.value = "js";
			mywait.style.visibility="visible";
			document.MyForm.submit();

        }
        function win_mx(url) {
            location.href = url;
            /*
            var win_mx = window.open(url, "", "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,fullscreen=no,width=" + ScreenWidth + ",height=" + ScreenHeight + ",top=0,left=0");
            win_mx.focus();
            window.opener = null;
            window.parent.close();
            window.close();
            return false;
            */
        }

	</script>
</head>

<body leftmargin="0" topmargin="0" oncontextmenu=self.event.returnValue=false scroll="no">
    <div id="mywait" style="position:absolute; top:180; left:20; z-index:10; visibility:hidden">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
	        <tr><td width="30%"></td><td bgcolor="#9F9F9F">
		        <table width="100%" height="100" border="0" cellspacing="1" cellpadding="0">
		        <tr><td height="20" align="center" bgcolor="#cfcfcf"></td></tr>
		        <tr><td height="80" class="kfs" align="center" bgcolor="#e8e8e8">正在处理，请稍候...</td></tr>
		        </table>
	        </td><td width="30%"></td></tr>
        </table>
    </div>
<%
    Dim myxz, zt, tsxx, str_sql, userid, zbid, ny, flowid
    Dim myselected, mydrd, myds, tzid, str_tj
    Dim i, jls As Integer
    
    userid = Session("userid")
    zbid = Session("zbid")
    tzid = Session("userssid")
    ny = Trim(Request.Form("ny"))
    myxz = Trim(Request.Form("myxz"))
    flowid = "329"
    If Len(myxz) = 0 Then myxz = "list"
    zt = Trim(Request.Form("zt"))
%>	
    <div data-role="page" id="page1">
		<div data-theme="a" data-role="header" data-mini="true">
			<h3>
				贸易公司工资审批
			</h3>
		</div>

    <table width="75%"   cellspacing="0" cellpadding="0">
    <form method="POST" id="MyForm" name="MyForm">
    <input type=hidden name="myxz" value="<%=myxz%>">
    <input type=hidden name="zt">
    <table>
	    <tr valign="center" >
		    <th width="40"  align="right" >年月:</th>
		    <td width="90"  align="left"  ><input type="text" class="blk"  name="ny" style="width:90" value="<%=ny %>" /></td>
		    <td width="54"  ><input type="button" class="blk" value=" 计算 " name="Submitjs" onclick='javascript:mysubmitjs()' /></td>
		    <!--<td width="54" valign="bottom"><input type="button" class="blk" value=" 关闭 " name="Close" onclick='javascript:window.parent.close()' /></td>-->
	    </tr>
    </table>

    <table width="600" height="580"  cellspacing="0" cellpadding="0">

        <div data-role="content">
			<div data-role="controlgroup" data-mini="true" >
                <table  border="1" cellspacing="0" style="border-collapse: collapse; font-size:12px;" bordercolor="#000000" cellpadding="0" >
                    <tr align="center" class="blk" height="20">
			            <th width="60" align="center">年月</th>
			            <th width="70" align="center">日期</th>
			            <th width="60" align="center">审核状态</th>
                        <th width="70" align="center">审核日期</th>
                        <th width="50" align="center">审核人</th>
                        <th width="60" align="center">制单人</th>
                        <th width="70" align="center">当前审核人</th>
                        <th width="65" align="center">当前流程</th>
			            <th width="11" align="center">&nbsp;</th>
                    </tr>
    <%	if zt="js" then
            str_tj=""
            If Len(ny) > 0 Then
                str_tj += " and ny='" + ny + "' "
            End If
            str_sql = " select a.id,a.zdr,convert(varchar(10),a.zdrq,120) zdrq,a.shr,a.shrq,case a.shbs when 0 then '未申报' when 1 then '已审毕' when 3 then '办理中' end as shzt,a.ny,flow.currentNodeName,flow.currentUserName  "
            str_sql += " from rs_t_yggzsbb a "
            str_sql += " left outer join fl_t_flowRelation flow on a.id=flow.dxid and flow.flowid =" + flowid + " and flow.currentuserid= " + userid
            str_sql += " where a.flowid= " + flowid + str_tj + " order by id desc "

            'Response.Write(str_sql)
            'Response.end
            'mydrd = lbdll.CreateDataReader(myconn, str_sql)
            myds = lbdll.CreateDataSet(myconn, str_sql)
            jls = myds.tables(0).Rows.Count
            If jls = 0 Then Return
            For i = 0 To jls - 1
                mydrd = myds.tables(0).Rows(i)

        %>
            <tr align="left" class="blk" >
			    <td width="60" align="center"><a class="link" onclick='return win_mx(this.href);'  href="../llsj/gz_cl_gzspd_sp.aspx?MyDJid=<%=lbdll.myempty(mydrd.item("id").ToString())%>&menuid=20169"><%= mydrd.item("ny")%></a></td>
                <td width="70" align="center"><%= lbdll.myempty(mydrd.item("zdrq").ToString())%></td>
                <td width="60" align="center"><%= lbdll.myempty(mydrd.item("shzt").ToString())%></td>
                <td width="70" align="center"><%= lbdll.myempty(mydrd.item("shrq").ToString())%></td>
                <td width="50" align="center"><%= lbdll.myempty(mydrd.item("shr").ToString())%></td>
                <td width="60" align="center"><%= lbdll.myempty(mydrd.item("zdr").ToString())%></td>
                <td width="70" align="center"><%= lbdll.myempty(mydrd.item("currentUserName").ToString())%></td>
                <td width="65" align="center"><%= lbdll.myempty(mydrd.item("currentNodeName").ToString())%></td>
                <td width="11">&nbsp;</td>
            </tr>
            <% 
            Next
            myds.dispose()
            myconn.Close()
         End If %>      
        </table>
	    </div>
        <br>
    </table>
    </form>               
    <br />
    </div>
</body>
</html>