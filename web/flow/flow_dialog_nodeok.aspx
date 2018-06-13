<%@ Page Language="VB" Debug="true"%>
<%@ Import Namespace="QXTMSG" %>
<%@ Import Namespace="ImApiDotNet"%>
 
<html >
<head>
    <title>完成流程环节的办理</title>
    <META HTTP-EQUIV="pragma" CONTENT="no-cache">
    <base target="_self" />
    <style>
		body{margin:0px;padding:0px;background-color:#ECE9D8;}
		.operateBtn{width:75px;height:30px;}
		.dialog_title{width:100%;font-size:10pt;color:#3E3C20;background-color:#fff;text-indent:30px;margin:0px;line-height:22px;}
		hr{width:99%;height:1px;margin:0px;padding:0px;background-color:#fff;padding:0px 0px 0px 0px;margin:0px 0px 0px 0px;}
	</style>
 
</head>
<body> 
<form method="POST" id="MyForm" name="MyForm">


<%
    Dim MyData As New Class_TLtools.MyData()
    Dim MyConn As System.Data.SqlClient.SqlConnection = New Data.SqlClient.SqlConnection
    'Dim MyConn = MyData.MyConn(1)
    MyConn.ConnectionString = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft "
    Dim str_sql As String
    'str_sql = "SET XACT_ABORT ON ;DECLARE @result int ; EXEC @result=flow_up_sendNextSingle 2793302,2810,'10','','陈江淮','6404','1','1','Z','' ; SELECT @result ; ;SET XACT_ABORT OFF ;"
    If len(str_sql)>0 Then
        str_sql = "SET XACT_ABORT ON ;" + str_sql + ";SET XACT_ABORT OFF ;"
        Dim errorString As String
        Dim bject As Object = MyData.MyDataTransID(MyConn, str_sql, errorString)
        If MyData.MyDataTransID(MyConn,str_sql)="1" then
            Response.Write("<script language=""javascript"">alert(""办理成功！"");window.returnValue='ok';window.close();</script>")
        else
            'response.write("<textarea>"+str_sql+MyConn.connectionstring+"</textarea>")
            response.write("<script language=""javascript"">alert(""办理失败！"");</script>")
        end if
    End If
    'Dim menufullname As String
    'str_sql = "select c.m_name+'/'+b.m_name+'/'+a.m_name from t_menu a inner join t_menu b on a.ssid=b.id inner join t_menu c on b.ssid=c.id where a.id='" + TLSoft_menuid + "'"
    'menufullname = MyData.MyDataTransID(MyConn, str_sql)

    ''获取bqq提示信息20120806 ke 额外bqq提醒
    'Dim tsxx As String
    'str_sql = "select isnull(tsxx,'') as tsxx from fl_t_flowRelation where docid=" + flow_docID + ";"
    'tsxx = MyData.MyDataTransID(MyConn, str_sql)
    'If Len(tsxx) > 0 Then
    '    '发送RTX 最后一个参数代表按钮的类型:1/办理|2/退办|3/终审|4/弃审|5/取消申报|
    '    str_sql = "exec flow_up_getNodeUserRTX " + flow_docID + "," + flow_nextNode + ",'" + flow_nextNodeUser + "',1," + flow_currentNode + ";"
    '    rtx_Number = MyData.MyDataTransID(MyConn, str_sql)
    '    If Len(rtx_Number) > 0 And Len(tsxx) > 0 Then
    '        rtx_sendText = tsxx
    '        rtx_sendText += System.Environment.NewLine + "套账：" + TLsoft_khmc + System.Environment.NewLine
    '        RTXHelper.SendRTXMSG(rtx_Number, Server.UrlEncode("【流程审批提醒】"), Server.UrlEncode(rtx_sendText))
    '    End If
    'Else
    '    '发送RTX

    '    str_sql = "exec flow_up_getNodeUserRTX " + flow_docID + "," + flow_nextNode + ",'" + flow_nextNodeUser + "';"
    '    rtx_Number = MyData.MyDataTransID(MyConn, str_sql)


    '    If Len(rtx_Number) > 0 Then
    '        rtx_sendText = "【" + flow_flowName + "】已发送到 〖" + Trim(Request.Form("flow_nextNodeText")) + "〗,请您及时处理！"
    '        rtx_sendText += System.Environment.NewLine + "套账：" + TLsoft_khmc + System.Environment.NewLine + "菜单：" + menufullname
    '        RTXHelper.SendRTXMSG(rtx_Number, Server.UrlEncode("【流程审批提醒】"), Server.UrlEncode(rtx_sendText))
    '    End If
    'End If
    ''20170701 柯 APP消息通知
    'str_sql = "exec flow_up_getNodeUserApp " + flow_docID + "," + flow_nextNode + ",'" + flow_nextNodeUser + "';"
    'phone_Number = MyData.MyDataTransID(MyConn, str_sql)
    'If Len(phone_Number) > 0 Then
    '    Try
    '        rtx_sendText = "【" + flow_flowName + "】已发送到 〖" + Trim(Request.Form("flow_nextNodeText")) + "〗,请您及时处理！"
    '        rtx_sendText += "  套账：" + TLsoft_khmc
    '        Dim flowPar As String = tzid + "|" + flow_docID + "|" + flow_dxid + "|" + flow_id
    '        tsxx = ""
    '        Dim appuserid, complx As String
    '        appuserid = Split(phone_Number, "|")(0)
    '        complx = Split(phone_Number, "|")(1)
    '        AppNoticeHelper.sendFlowNotice(appuserid, username, menufullname, rtx_sendText, complx, flowPar, tsxx)
    '        'KPay.Common.LogHelper.Error("flowNodeOk", "提示信息：" + tsxx + " sql=" + str_sql + "参数：userid=" + userid + "&username=" + username + "&menufullname=" + menufullname + "&rtx_sendText=" + rtx_sendText + "&flowPar=" + flowPar)
    '    Catch ex As Exception
    '        'KPay.Common.LogHelper.Error("flowNodeOk", "提示信息：" + tsxx + " sql=" + str_sql + "参数：userid=" + userid + "&username=" + username + "&menufullname=" + menufullname + "&rtx_sendText=" + rtx_sendText + "&flowPar=" + flowPar)
    '    End Try
    'End If

    'End Select

%>


</form>
</body>
</html>