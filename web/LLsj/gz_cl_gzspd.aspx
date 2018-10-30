<html>
<head>
	<title>贸易公司工资审批单</title>
</head>
<script src='../Scripts/jquery.js'></script>
<script language="javascript">
    function test() {
        var sql = " ";
        $.ajax({
            type: "get",
            async: false,
            url: "../LLsj/ajax/Mobile_deal.ashx?sql=" + sql + "&bid=160382&ver=" + Math.round(Math.random() * 10000),
            success: function (msg) {
                alert(msg);
                window.returnValue = 'ok';
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert(XMLHttpRequest.responseText.toString());
            }
        });

    }

	function sb()
	{
	    var ny = Form1.zb_nd.value + "" + Form1.zb_yf.value;
	    var flowid = "329";
	    if (!checkMx()) return;
	    var str_sql = "declare @id int;";
	    str_sql += " insert into rs_t_yggzsbb(tzid,ny,flowid,zdr,zdrq) ";
	    str_sql += "values(" + Form1.tzid.value + ",'" + ny + "'," + flowid + ",'" + Form1.username.value + "',getdate()) ";
	    str_sql += "SET @id=SCOPE_IDENTITY() ; "
	    var maxR = Number(Form1.jls.value) -1;
	    var bmid = "";
	    for (var m = 0; m <= maxR; m++) {
	        try {
	            if (!Form1("mx_xz:" + m + "-").checked) continue;
	            bmid = MyForm("mytext_" + m + "_bmid").value;
	            str_sql += " insert into rs_t_yggzsbmx(id,dxid) values(@id," + bmid + ") ; ";
	            str_sql += " update a SET sbid=@id from rs_t_yggzb a inner join rs_t_rygzdwzlb b on a.ryid=b.id and a.tzid=b.tzid inner join dm_t_gwdmb gw on b.gwid=gw.id ";
	            str_sql += "inner join rs_t_bmdmb bm on b.bmid=bm.id and a.tzid=bm.tzid inner join rs_T_bmdmb cjbm on bm.ccid+'-' like cjbm.ccid+'-%' ";
	            str_sql += "where a.tzid=" + Form1.tzid.value + " and a.ny='" + ny + "' and cjbm.id=" + bmid + " and isnull(a.sbid,0)=0 and a.faid='" + faid + "' ; " //and isnull(gw.gzkzx,0)="+gwkzx+" ;
	        } catch (e) { }
	    }
	    str_sql += " EXEC flow_up_start " + Form1.tzid.value + " ," + Form1.tzid.value + ",@id ,'' ," + flowid + " ," + Form1.userid.value + " ,'" + Form1.username.value + "',''";
	    //str_sql += " SELECT @id as id;";
	    $.ajax({
	        type: "POST",
	        async: false,
	        url: "../LLsj/ajax/Mobile_deal.ashx?sql=" + str_sql + "&bid=&ver=" + Math.round(Math.random() * 10000),
	        success: function (msg) {
	            alert(msg);
	            window.returnValue = 'ok';
	        },
	        error: function (XMLHttpRequest, textStatus, errorThrown) {
	            alert(XMLHttpRequest.responseText.toString());
	        }
	    });
        /*
	    var winRtn = openAjax(str_sql, 'bbupdateID', MyForm.MyBBbid.value, '');
	    if (!isNaN(winRtn) && Number(winRtn) > 0) {
	        alert("申报成功！");
	        mywait.style.visibility = "visible";
	        MyForm.submit();
	    } else {
	        alert("申报失败！");
	    }
        */
	}
	function checkMx() {
	    var maxR = Number(Form1.jls.value);
	    var isTrue = false;
	    for (var m = 0; m <= maxR; m++) {
	        try {
	            if (Form1("mx_xz:" + m + "-").checked) { isTrue = true; break; }
	        } catch (e) { }
	    }
	    if (!isTrue) alert("未选择人员！");
	    return isTrue;
	}

	
    function selectall()
	{
		var maxjls=parseInt(Form1.hi_jls.value)+1;
		
			for (var j = 0; j < maxjls; j ++)
		 { 	
			 Form1("mx_xz:"+j+"-").checked=false;
		 } 	
	}
		
</script>	
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
<form id="Form1" method="post" runat="server">
<input id="jls" type="hidden" name="jls" value = "<%=jls %>" />
<input id="tzid" type="hidden" name="tzid" value = "<%=tzid %>" />
<input id="zbid" type="hidden" name="zbid" value = "<%=zbid %>" />
<input id="userid" type="hidden" name="userid" value = "<%=userid %>" />
<input id="username" type="hidden" name="username" value = "<%=username %>" />
<!--#include file="../mycss/my_init_dj.aspx" -->

    <table width="100%" height="1" cellspacing="0" cellpadding="0" border="0" ID="Table1">
	    <tr>
		    <td>&nbsp;</td>
            <td width="54" align="right"><input type="button" id="Btn_save" class="blk" value=" 申报 " onclick="javascript:sb()" tabIndex="98" /></td>
		    <!--<td width="54" align="right"><asp:Button id="Btn_save" class="blk" runat="server" Text=" 申报 " OnClick="top_butt_save" tabIndex="98"></asp:Button></td>-->
		    <td width="54" ><input type="button" class="blk" value=" 关闭 " name="Close" onclick='javascript:window.close()' /></td>
		    <td width="15"></td>
	    </tr>
    </table>
    <table style="WIDTH: 100%" cellspacing="0" cellpadding="0" border="0">
	    <tr><td class="kfs18" align="center"><b><u>贸易公司工资审批单</u></b></td></tr>
    </table>
	<table border="0" cellspacing="0" cellpadding="0" ID="Table9">
		<tr align="left"><td bgcolor="#ffffff">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr height="25" align="left">
					<td class="blk" align="right" width="40">年度:</td>
					<td class="blk" align="left" width="40"><input type="text" id="zb_nd" name="zb_nd" "readonly" class="myzb_u" size="10" value="<%=Request.QueryString("cxnd")%>" /></td>
					<td class="blk" align="right" width="50">月份:</td>
					<td class="blk" align="left" width="30"><input type="text" id="zb_yf" name="zb_yf" "readonly" class="myzb_u"  size="60" tabindex="2" value="<%=Request.QueryString("cxyf")%>" /></td>
					<td class="blk" align="right" width="80">客户名称：</td>
                    <td class="blk" align="left" width="180"><input type="text" id="zb_khmc" name="zb_khmc" "readonly" class="myzb_u" size="10" value="<%=Request.QueryString("khmc")%>" /></td>
                    
				</tr>
			</table>
		</td></tr>
	</table>
<center>
	<table border="1" cellspacing="0" cellpadding="0"  bordercolordark="white" width=100%  bordercolor="silver" ID="Table2" background="../img/bg_table.jpg">
		<tr align="center" class="lmzt">
			<td width="28"><a href="#" class=link onClick="javascript:selectall()">选中</a></td>
			<td width="60">员工</td>
			<td width="70">员工状态</td>
			<td width="70">所属岗位</td>
			<td width="70">基本工资</td>
			<td width="70">岗位补贴</td>
			<td width="70">地区津贴</td>
			<td width="70">绩效工资</td>
			<td width="70">绩效评定</td>
			<td width="70">其他补贴</td>
            <td width="70">销售提成</td>
            <td width="70">任务提成</td>
            <td width="70">话费津贴</td>
            <td width="70">应发工资</td>
            <td width="70">考勤</td>
            <td width="70">代扣</td>
            <td width="70">其他</td>
            <td width="70">实发工资</td>
            <td width="70">其中特卖</td>
			<td width="15">&nbsp;</td>
		</tr>
	</table>
	<div id="mx" style="OVERFLOW: scroll; HEIGHT: 428px">
	<table border="1" cellspacing="0" cellpadding="0" bordercolordark="white"  bordercolor="silver" width=100%>
		<%		
		    If jls = 0 Then Return
		    For i = 0 To jls - 1
		        mydr = myds.tables(0).Rows(i)
		%>
		<tr class="blk" >
			<td width=28 align="center"><input type="checkbox" class="mybutt_text"   id="mx_xz:<%=cstr(i)%>-" name="mx_xz:<%=cstr(i)%>-" tabIndex="1" /></td>
			<td width=60><input type="text" name="mx_rymc:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("rymc"))%>" /></td>
            <td width=70><input type="text" name="mx_ryzt:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("ryzt"))%>" /></td>
            <td width=70><input type="text" name="mx_gwmc:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("gwmc"))%>" /></td>
            <td width=70><input type="text" name="mx_jcgz:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("jcgz"))%>" /></td>
            <td width=70><input type="text" name="mx_gwbt:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("gwbt"))%>" /></td>
            <td width=70><input type="text" name="mx_dqbt:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("dqbt"))%>" /></td>
            <td width=70><input type="text" name="mx_jxgz:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("jxgz"))%>" /></td>
            <td width=70><input type="text" name="mx_jxpd:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("jxpd"))%>" /></td>
            <td width=70><input type="text" name="mx_qtjt2:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("qtjt2"))%>" /></td>
            <td width=70><input type="text" name="mx_xstc:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("xstc"))%>" /></td>
            <td width=70><input type="text" name="mx_rwtc:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("rwtc"))%>" /></td>
            <td width=70><input type="text" name="mx_rwtc:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("rwtc"))%>" /></td>
            <td width=70><input type="text" name="mx_yfgz:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("yfgz"))%>" /></td>
            <td width=70><input type="text" name="mx_kqje:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("kqje"))%>" /></td>
            <td width=70><input type="text" name="mx_dkje:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("dkje"))%>" /></td>
            <td width=70><input type="text" name="mx_qtje:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("qtje"))%>" /></td>
            <td width=70><input type="text" name="mx_qtje:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("qtje"))%>" /></td>
            <td width=70><input type="text" name="mx_tmtc:<%=cstr(i)%>-" "readonly" class="mytext_hh" value="<%=(mydr.item("tmtc"))%>" /></td>
            <td width="15">&nbsp;</td>
            <input type=hidden   name="mx_bmid:<%=cstr(i)%>-" class=mytext_je  readonly value="<%=lbdll.myempty_cmxg(mydr.item("bmid"))%>">
		</tr>
		<%
		Next
		myds.dispose()
		myconn.close()
		%>     
	</table>
	</div>

<%lbdll.close(myconn)%>
</center>
<script type = "text/vbscript" language = "vb" runat = "server" >
    Dim max_cmjls, j, tzid, zbid, userid, username, mydscm, jls, i, mydrd, parentsql, childsql
    Dim str_sql, myds, mydr, mydss, mydrr
    Dim relation As DataRelation
    Dim parentCol, childCol As DataColumn
    Dim childr(), thechildrow As DataRow
    Dim cm(93), cmxg(30)
    Dim cxnd, cxyf, khid, khmc, MyBBmenuid, flowid
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
        MyBBmenuid = Request.QueryString("MyBBmenuid")
        Response.Write("<div id='message' style='position:absolute; top:180; left:20; z-index:10;'><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td width=30%></td><td bgcolor=#9F9F9F><table width=100% height=100 border=0 cellspacing=1 cellpadding=0><tr><td height=20 align=center bgcolor=#cfcfcf></td></tr><tr><td height=80 bordercolor=Red align=center bgcolor=#e8e8e8>正在处理，请稍候...</td></tr></table></td><td width=30%></td></tr></table></div>")
        MyDataLoad()
    End Sub

    Sub load_data_zb(ByVal id As String)
        MyDataLoad()

    End Sub

    Sub MyDataLoad()
        str_sql = " select distinct '' xz,a.*,case when a.tqsf=0 then 0 else ((a.hj-a.tqsf)/a.tqsf)*100 end as zzlv "
        str_sql += " from( "
        str_sql += "   select a.ryid,a.rymc,f.id as gwid,a.zcid,a.tcid,a.rwid,a.tmid,a.tmtc,f.mc as gwmc,'' bmmc,c.bmid, "
        str_sql += " 	  a.khid,b.khdm,b.khmc,a.ny,a.jcgz,a.jxgz,a.qtjt2, "
        str_sql += "      a.gwbt,a.dqbt,a.dkje,a.qtje,a.xstc,a.rwtc,a.kqje,a.hfbt,a.jxpd, "
        str_sql += "      a.jcgz+a.jxgz+a.qtjt2+a.gwbt+a.dqbt+a.kqje+a.xstc+a.rwtc+a.hfbt+a.dkje+a.qtje+a.jxpd as hj, "
        str_sql += "      a.jcgz+a.jxgz+a.qtjt2+a.gwbt+a.dqbt+a.xstc+a.rwtc+a.hfbt+a.jxpd as yfgz,tq.tqsf,d.byxx, "
        str_sql += "     ''''+c.yhkh yhkh,c.khh,f.kzx, case when a.ryzt=0 then '<font class=red>离职</font>' when a.ryzt=1 then '<font class=red>新入职</font>' else '在职' end as ryzt "
        str_sql += "   from rs_t_yxrygzb a "
        str_sql += "   inner join yx_t_khb b on a.khid=b.khid "
        str_sql += "   inner join rs_t_rydwzl c on a.ryid=c.id "
        str_sql += "   inner join rs_t_ryjbzl d on c.id=d.id "
        str_sql += "   left outer join rs_t_gwdmb f on a.gwid=f.id "
        str_sql += "   left outer join "
        str_sql += "   ("
        str_sql += "     select a.ryid,sum(a.jcgz+a.jxgz+a.qtjt2+a.gwbt+a.dqbt+a.xstc+a.rwtc+a.hfbt+a.kqje+a.dkje+a.qtje+a.jxpd) as tqsf "
        str_sql += "      from rs_t_yxrygzb a where a.ny=cast((" + cxnd + "-1) as varchar(4))+'" + cxyf + "' group by a.ryid "
        str_sql += "   ) tq on a.ryid=tq.ryid "
        str_sql += "      where a.khid=" + khid + " and a.ny='" + cxnd + cxyf + "' "
        str_sql += " ) as a "
        'response.write("<textarea>"+str_sql+"</textarea>")
        myds = lbdll.CreateDataSet(myconn, str_sql)
        jls = myds.tables(0).Rows.Count
        'Response.Write(jls)
        'Response.End
        'hi_jls.value = jls - 1
    End Sub


    Sub top_butt_save(ByVal S As Object, ByVal E As EventArgs)
        'btn_save.visible=false
        Dim xz_yes, bmid
        Dim faid As Integer 
        Dim ny As String
        faid = 0
        ny = cxnd + cxyf 
        str_sql = " declare @id int;"
        str_sql += " insert into rs_t_yggzsbb(tzid,ny,flowid,zdr,zdrq) "
        str_sql += " values(" + tzid + ",'" + cxnd + cxyf + "'," + flowid + ",'" + username + "',getdate()) "
        str_sql += " SET @id=SCOPE_IDENTITY() ; "
        For i = 0 To jls - 1
            xz_yes = Trim(Request.Form("mx_xz:" + CStr(i) + "-"))
            If xz_yes = "on" Then
                Try
                    bmid = Trim(Request.Form("bmid:" + CStr(i) + "-"))
                    str_sql += "My_I rs_t_yggzsbmx(id,dxid) values(@id," + bmid + ") ; "
                    str_sql += "My_U a SET sbid=@id from rs_t_yggzb a inner join rs_t_rygzdwzlb b on a.ryid=b.id and a.tzid=b.tzid inner join dm_t_gwdmb gw on b.gwid=gw.id "
                    str_sql += "inner join rs_t_bmdmb bm on b.bmid=bm.id and a.tzid=bm.tzid inner join rs_T_bmdmb cjbm on bm.ccid+'-' like cjbm.ccid+'-%' "
                    str_sql += "where a.tzid=" + tzid + " and a.ny='" + ny + "' and cjbm.id=" + bmid + " and isnull(a.sbid,0)=0 and a.faid='" + faid + "' ; "
                Catch ex As Exception

                End Try
            End If
        Next
        str_sql += " EXEC flow_up_start " + tzid + " ," + tzid + ",@id ,'' ," + flowid + " ," + userid + " ,'" + username + "',''"
        str_sql += " SELECT @id ;"
        lbdll.ExecuteSqlTrans(myconn, str_sql)
        Btn_save.Visible = True
        lbdll.mylog(myconn, CStr(Request.ServerVariables("remote_addr")), CStr(Request.ServerVariables("url")), Session("user"), "tzid-" + tzid + "贸易公司工资审批单申报成功：" + khmc + cxnd + cxyf )
        myconn.Close()
        Response.Write("<textarea>"+str_sql+"</textarea>")
        response.end

    End Sub

</script> 

</form>
</body>
</html>
