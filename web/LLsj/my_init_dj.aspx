<%@ Page Language="VB" debug=true%>
<%@Import Namespace="System.Data"%>
<%@Import Namespace="System.Data.SqlClient"%>

<!--#include file="../mycss/inc_mycss.inc" -->
<LINK href="../mycss/my_style.css" type="text/css" rel="stylesheet">
<SCRIPT src="../Tltools/calendar.js" type="text/javascript"></script>

<body leftmargin="0" topmargin="0" oncontextmenu="self.event.returnValue=false" scroll=no onLoad="javascript:document.all.message.style.display='none'">
<input type=hidden name="TLsoft_onoff" value='<%=request.form("TLsoft_onoff")%>'  > 
<input type=hidden name="TLsoft_userid" value='<%=Request.Form("TLsoft_userid")%>' > 
<input type=hidden name="TLsoft_username" value='<%=Server.HtmlDecode(Request.Form("TLsoft_username"))%>' > 
<input type=hidden name="TLsoft_tzid"   value='<%=Request.Form("TLsoft_tzid")%>' > 
<input type=hidden name="TLsoft_zbid"   value='<%=Request.Form("TLsoft_zbid")%>' > 
<script language="JavaScript">
	if (MyForm.TLsoft_onoff.value==''){
		MyForm.TLsoft_userid.value='<%=session("userid")%>';
		MyForm.TLsoft_username.value='<%=session("username")%>';
		MyForm.TLsoft_tzid.value='<%=session("userssid")%>';
		MyForm.TLsoft_zbid.value='<%=session("zbid")%>';
		MyForm.TLsoft_onoff.value='on';
    }
    function flowSession() {
        this.tzid = '<%=session("userssid")%>';
        this.dxtzid = '<%=session("userssid")%>';
        this.zbid = '<%=session("zbid")%>';
        this.userid = '<%=session("userid")%>';
        this.username = '<%=session("username")%>';

    }
</script>
<script language="Vb" runat="server">
    Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs)
         if request.form("TLsoft_onoff")="on" then 
		    session("userid")=request.form("TLsoft_userid")
		    session("username")=Server.HtmlDecode(request.form("TLsoft_username"))
		    session("userssid")=request.form("TLsoft_tzid")
		    session("zbid")=request.form("TLsoft_zbid")
	    end if 
        '20110622 ke 制单人不丢失
	    Try
	        if trim(session("username")).toString()="" then
	            dim userdr=lbdll.CreateDataReader(tlconn,"select cname from t_user where id='"+session("userid").toString()+"';")
	            if userdr.read() then
	    		    session("username")=trim(userdr.item("cname"))
		        end if
		        tlconn.close()
		        userdr.dispose()
	        end if
	    Catch ex As Exception
		End Try
    End Sub
</script>
<%	if request.form("TLsoft_onoff")="on" then 
		session("userid")=request.form("TLsoft_userid")
		session("username")=Server.HtmlDecode(request.form("TLsoft_username"))
		session("userssid")=request.form("TLsoft_tzid")
		session("zbid")=request.form("TLsoft_zbid")
	end if 
	
	if len(session("userid"))=0 or len(session("userssid"))=0  then 
        Session("_sys_message") = "抱歉！您无有效权限或使用时间超时。"
        response.Redirect("../TLinc/SysMessageBox.aspx")
		'response.write("<br><br><br><br><center>抱歉！您无有效权限或使用时间超时。")
		return
	end if	
%>

<script  LANGUAGE="javascript">
	function document.body.oncontextmenu()
	{
		window.event.returnValue=false;
	}

	function document.body.ondragstart()
	{
		return false;
	}

	function document.body.onkeydown()
	{
		mybody__KeyDown();	
		if (event.altKey && (event.keyCode==37 || event.keyCode==39)) event.returnValue = false;	
		if (event.keyCode==27 || event.keyCode==8 && event.srcElement.type!='text') event.returnValue = false;	
		if (event.keyCode==114 || event.keyCode==116 || event.keyCode==117 || event.keyCode==122)	{event.keyCode = 0;event.returnValue = false;}	
		if (event.ctrlKey && (event.keyCode==82 || event.keyCode==78)) event.returnValue = false;	
		if (event.altKey && event.keyCode==115)	{window.showModelessDialog('about:blank','','dialogWidth:1px;dialogheight:1px');return false;}
	}

	function mybody__KeyDown()
	{	
		if (event.keyCode == 13 && event.srcElement.tabIndex > 0) event.keyCode = 9;	
		var name = event.srcElement.name;	
		if (event.srcElement.type == 'text')	
		{	
			if 	(name.indexOf(":") == -1 ) return;
			if (event.keyCode == 38)		
			{		
				var intRow = parseInt(name.match(/:(\d+?)-/)[1]);
				if (intRow > 0)
				{var stringName = name.replace(intRow.toString(),(intRow-1).toString());MyForm(stringName).focus();}
			}
			if (event.keyCode == 40)
			{
				var intRow = parseInt(name.match(/:(\d+?)-/)[1]);
				if (intRow < MyForm.maxjls.value)
				{
					var stringName = name.replace(intRow.toString(),(intRow+1).toString());
					if (TableDetail.rows(intRow+1).cells(0).childNodes[0].value.length==0 && TableDetail.rows(intRow+1).cells(0).childNodes[0].readOnly==false)
					{
						TableDetail.rows(intRow+1).cells(0).childNodes[0].focus();
					}
					else
					{
						MyForm(stringName).focus();
					}
				}
				else addRow();
			}
		}
	}
	
	function addRow(name)
	{
		var i = TableDetail.rows.length;
		var j = TableDetail.rows(0).cells.length;	
		var newRow = TableDetail.insertRow(-1);
		for (var k = 0; k < j; k++)
		{	var newCell = newRow.insertCell(k);
	    	//newCell.style = TableDetail.rows(0).cells(k).style;
			var s = TableDetail.rows(0).cells(k).children.length;
			if (s==0) continue;
			var strHtml = TableDetail.rows(0).cells(k).innerHTML;
			strHtml = strHtml.replace(':0-',':'+i.toString()+'-');
			newCell.innerHTML = strHtml;
			TableDetail.rows(i).cells(k).childNodes[0].innerText="";
			TableDetail.rows(i).cells(k).style.display=TableDetail.rows(0).cells[k].style["display"];
		}	
		MyForm.maxjls.value =i ;
		TableDetail.rows(i).cells(0).childNodes[0].focus();
	}	
	
	
	function CheckValue(name)
	{
		if (event.srcElement.name == name || event.srcElement.name.indexOf(name) == event.srcElement.name.length-name.length)	
		{
			if (String.fromCharCode(event.keyCode).search(/^[0-9-.]$/) == -1) event.returnValue = false;
		}
	}

	function KeyDown(name,value)
	{
		if (event.keyCode == 123) MyDmxz(name,value);
	}

</script>
<div id="mywait" style="position:absolute; top:180; left:20; z-index:10; visibility:hidden">
<table width=100% border=0 cellspacing=0 cellpadding=0>
	<tr><td width=30%></td><td bgcolor=#9F9F9F>
		<table width=100% height=100 border=0 cellspacing=1 cellpadding=0>
		<tr><td height=20 align=center bgcolor=#cfcfcf></td></tr>
		<tr><td height=80 class=kfs align=center bgcolor=#e8e8e8>正在处理，请稍候...</td></tr>
		</table>
	</td><td width=30%></td></tr>
</table>
</div>

