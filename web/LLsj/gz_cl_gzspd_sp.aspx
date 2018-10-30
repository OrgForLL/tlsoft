<html>
<head>
    <meta charset="utf-8">
    <meta name="robots" content="noindex, follow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet"  href="css/themes/default/jquery.mobile-1.3.1.min.css">
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,700">
    <script src="js/jquery.js"></script>
    <script src="js/jquery.mobile-1.3.1.min.js"></script>
	<title>贸易公司工资审批单</title>
</head>
<script src='../Scripts/jquery.js' type="text/javascript"></script>
<script language="javascript" type="text/javascript">
    function test() {
        var sql = " ";
        $.ajax({
            type: "get",
            async: false,
            url: "../LLsj/ajax/Mobile_deal.ashx?sql=" + sql + "&bid=160382&ver=" + Math.round(Math.random() * 10000),
            success: function (msg) {
                window.returnValue = 'ok';
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert(XMLHttpRequest.responseText.toString());
            }
        });

    }		
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
<body>
<style>
<!--
.mybutt_text { background-color:#d4d0c8;color: #000000; font-size:9pt; border-width: 0;height:18;width:28}
.mytext_yg   {color: #222222; background-color: #eeeeee; border:0; solid:#ffffff;border-style:solid; font-size: 9pt;height:16;width:60;text-align : center;}
.mytext_hh   {color: #222222; background-color: #eeeeee; border:0; solid:#ffffff;border-style:solid; font-size: 9pt;height:16;width:70;text-align : center;}
.mytext_pm   {color: #222222; background-color: #eeeeee; border:0; background-color: #eeeeee;  solid:#ffffff;border-style:solid; font-size: 9pt;height:16;width:180;text-align : left;}
.mytext_shdm   {color: #222222;background-color: #eeeeee; border:0; solid:#ffffff;border-style:solid;font-size: 9pt;height:16;width:80;text-align : center;}
.mytext_splb   {color: #222222; border:0; background-color: #eeeeee;  solid:#ffffff;border-style:solid;font-size: 9pt;height:16;width:60;text-align : center;}
.mytext_dj   {color: #222222; border:0; background-color: #eeeeee;  solid:#ffffff;border-style:solid;font-size: 9pt;height:16;width:80;text-align : right;}
.mytext_mx   {color: #222222; border:0; background-color: #eeeeee;  solid:#ffffff;border-style:solid;font-size: 9pt;height:16;width:80;text-align : right;}
.mytext_je   {color: #222222; border:0; background-color: #eeeeee;  solid:#ffffff;border-style:solid; font-size: 9pt;height:16;width:90;text-align : right;}
.mytext_cm   {color: #222222; border:0; solid:#ffffff;border-style:solid;font-size: 9pt;height:16;width:80;text-align : right;}
.text_sl   {color: #222222; border:0; solid:#ffffff;border-style:solid;font-size: 9pt;height:16;width:70;text-align : right;}
.text_slwh   {color: #222222; border:0; solid:#ffffff;border-style:solid;font-size: 9pt;height:16;width:70;text-align : right;background-color: #ffffcc;}
--></style>
<form id="MyForm" method="post" >
<input id="jls" type="hidden" name="jls" value = "<%=jls %>" />
<input id="tzid" type="hidden" name="tzid" value = "<%=tzid %>" />
<input id="zbid" type="hidden" name="zbid" value = "<%=zbid %>" />
<input id="userid" type="hidden" name="userid" value = "<%=userid %>" />
<input id="username" type="hidden" name="username" value = "<%=username %>" />
<input id="flowid" type="hidden" name="flowid" value = "<%=flowid %>" />
<input id="MyDJid" type="hidden" name="MyDJid" value = "<%=MyDJid %>" />
<input id="flowdxid" type="hidden" name="flowdxid" value = "<%=MyDJid %>" />
<input id="flowdocid" type="hidden" name="flowdocid" value = "<%=flowdocid %>" />
<input id="flowflag" type="hidden" name="flowflag" value = "<%=flowflag %>" />
<input id="flowuserid" type="hidden" name="flowuserid" value = "<%=flowuserid %>" />
<input id="TLsoft_menuid" type="hidden" name="TLsoft_menuid" value = "<%=TLsoft_menuid %>" />
<input id="ppdm" type="hidden" name="ppdm" value = "<%="zpp" %>" />
<input id="MySession" type="hidden" name="MySession" value = "<%=userid+"|"+tzid+"|"+zbid+"|"+xtlb+"|"+username+"|"+ khmc +"|"+username+"|"+TLsoft_menuid+"|0"%>" />
<!--#include file="my_init_dj.aspx" -->


    <div data-role="page" id="page1">
        <table width="100%" height="1" cellspacing="0" cellpadding="0" border="0" ID="Table1">
	        <tr>
		        <td>&nbsp;</td>
                <td width="10" id="mytd_button_取消申报" valign="bottom" ><input id="mybb_button_取消申报" class="blk" onclick="flow_clear()"  value=" 取消申报 " type="button" /></td>
                <td width="10" id="mytd_button_办理"     valign="bottom" ><input id="mybb_button_办理"     class="blk" onclick="flow_send()"   value=" 办理 "     type="button" /></td>
                <td width="10" id="mytd_button_退办"     valign="bottom" ><input id="mybb_button_退办"     class="blk" onclick="flow_return()" value=" 退办 "     type="button" /></td>
                <td width="10" id="mytd_button_终审"     valign="bottom" ><input id="mybb_button_终审"     class="blk" onclick="flow_end()"    value=" 终审 "     type="button" /></td>
                <td width="10" id="mytd_button_弃审"     valign="bottom" ><input id="mybb_button_弃审"     class="blk" onclick="flow_cancel()" value=" 弃审 "     type="button" /></td>
		        <td width="54" ><input type="button" class="blk" value=" 关闭 " name="Close" onclick='javascript:window.close()' /></td>
		        <td width="15"></td>
	        </tr>
        </table>
		<div data-theme="a" data-role="header" data-mini="true">
			<h3>
				贸易公司工资审批
			</h3>
		</div>
	    <div data-role="content">
			<div data-role="controlgroup" data-mini="true" >
                <table  border="1" cellspacing="0" style="border-collapse: collapse; font-size:12px;" bordercolor="#000000" cellpadding="0" >
		        <%		
		            mydr = myds.tables(0).Rows(0)
		        %>
		        <tr class="blk" >
			        <td width="200">年月:<%=(mydr.item("ny"))%></td>
                </tr>
                <tr class="blk" >
                    <td width="200">日期:<%=(mydr.item("zdrq"))%></td>
                </tr>
                <tr class="blk" >
                    <td width="200">审核状态:<%=(mydr.item("shzt"))%></td>
                </tr>
                <tr class="blk" >
                    <td width="200">审核日期:<%=(mydr.item("shrq"))%></td>
                </tr>
                <tr class="blk" >
                    <td width="200">审核人:<%=(mydr.item("shr"))%></td>
                </tr>
                <tr class="blk" >
                    <td width="200">制单人:<%=(mydr.item("zdr"))%></td>
		        </tr>
		        <%
		            myds.dispose()
		            myconn.Close()
		        %>     
	            </table>
            </div>
	    </div>
    </div>

    <%lbdll.close(myconn)%>
    <script type = "text/vbscript" language = "vb" runat = "server" >
        Dim max_cmjls, j, tzid, zbid, userid, username, mydscm, jls, i, mydrd, parentsql, childsql
        Dim str_sql, myds, mydr, mydss, mydrr
        Dim cxnd, cxyf, khid, khmc, MyBBmenuid, flowid, MyDJid, flowflag, flowuserid, TLsoft_menuid, xtlb
        Dim mysql As String
        Dim flowdocid As String
        Sub page_load(ByVal S As Object, ByVal E As EventArgs)
            tzid = Session("userssid")
            zbid = Session("zbid")
            userid = Session("userid")
            username = Session("username")
            flowid = "329" 'Request.QueryString("flowid")
            cxnd = Request.QueryString("cxnd")
            cxyf = Request.QueryString("cxyf")
            khid = Request.QueryString("khid")
            khmc = Request.QueryString("khmc")
            MyDJid = Request.QueryString("MyDJid")
            MyBBmenuid = Request.QueryString("MyBBmenuid")
            TLsoft_menuid = Request.QueryString("menuid")
            Response.Write("<div id='message' style='position:absolute; top:180; left:20; z-index:10;'><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td width=30%></td><td bgcolor=#9F9F9F><table width=100% height=100 border=0 cellspacing=1 cellpadding=0><tr><td height=20 align=center bgcolor=#cfcfcf></td></tr><tr><td height=80 bordercolor=Red align=center bgcolor=#e8e8e8>正在处理，请稍候...</td></tr></table></td><td width=30%></td></tr></table></div>")
            mysql = "SELECT docid,dxid,flag,userid FROM fl_t_flowRelation Where flowid=" + flowid + " and dxid=" + MyDJid
            mydr = lbdll.CreateDataReader(myconn, mysql)
            If mydr.read() Then
                flowdocid = mydr.item("docid")
                flowflag = mydr.item("flag")
                flowuserid = mydr.item("userid")
            Else
                flowdocid = "0"
                flowflag = "0"
                flowuserid = "0"
            End If
            myconn.Close()
            '获取系统类别
            mysql = "SELECT khlbdm,khmc FROM yx_T_khb Where khid=" + tzid
            mydr = lbdll.CreateDataReader(myconn, mysql)
            If mydr.read() Then
                xtlb = mydr.item("khlbdm")
                khmc = mydr.item("khmc")
            Else
                xtlb = "Z"
                khmc = "lILANZ"
            End If
            myconn.Close()
            MyDataLoad()
        End Sub

        Sub MyDataLoad()
            str_sql = " select id,ny,zdr,zdrq,shr,shrq,case shbs when 0 then '未申报' when 1 then '已审毕' when 3 then '办理中' end as shzt "
            str_sql += " from rs_t_yggzsbb where flowid=" + flowid + " and id=" + MyDJid + " order by id desc"
            myds = lbdll.CreateDataSet(myconn, str_sql)
            jls = myds.tables(0).Rows.Count
        End Sub

    </script> 
    <script src='../llsj_flow/bbjs/flow.js' type="text/javascript"></script>
</form>
</body>
</html>
