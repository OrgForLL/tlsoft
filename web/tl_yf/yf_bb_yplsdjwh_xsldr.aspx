<%--
���ݸ�Ҫ������ά��EXCEL����
�汾�ţ�1.0.0.0
�޸����ڣ�20120906
�޸��ˣ�lins
--%> 

<%@ Page Language="VB" Debug="true" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@Import Namespace="System.Data"%>
<%@Import Namespace="System.IO"%>
<%@Import Namespace="System.Data.SqlClient"%>
<%@Import Namespace="System.Data.OleDb"%>
<html>
<head>
	<title>EXCEL���ݵ���</title>
	<base target="_self">
	<script  LANGUAGE="javascript">
		function  DateToStr(str)
		{   
			var d = new Date(str);
			var   yy = d.getFullYear();   
			var   mm = d.getMonth()+1;
			var   rr = d.getDate();   
			if   (mm < 10) {mm = "0" +mm};   
			if   (rr < 10) {rr = "0" +rr};   
			return yy + '-' + mm + '-' + rr;  
		}
        function MyDr()
		{
			if(MyForm.fileUpload.value.length==0)
			   {alert("����ѡ������Դ���ڽ��е��������");return false;}
			
			__doPostBack('lb1','');
		}
	</script>

</head>
<form  method="POST" id="MyForm" runat=server name="MyForm">
<script language="Vb" runat="server">
        Dim MyData As New Class_TLtools.MyData()
        Dim MySYS As New Class_TLtools.MyTools()
        'Dim MyLink = MyData.MyDataLink()
        'Dim TLConn As New Data.SqlClient.SqlConnection(MyLink)
        Dim TLConn
        Dim MySql As String
        Private Sub Page_Init(ByVal sender As System.Object, ByVal e As System.EventArgs)
            if request.form("TLsoft_onoff")="on" then
                session("userid")=request.form("TLsoft_userid")
                session("userssid")=request.form("TLsoft_tzid")
                session("zbid")=request.form("TLsoft_zbid")
                Session("username") = Request.Form("TLsoft_username")
            End If
            TLConn = MyData.MyConn() 'ȡ32�ϵ�tlsoft��session("zbid")
        End Sub
	</script>
<%	



    Dim bt,zt as string
    bt=trim(Request.QueryString("bt"))
    zt=trim(Request.Form("zt"))
%>
<BASE target="_self">
<meta http-equiv="Pragma" content="no-cache"> 
<table width=100% cellspacing=0 cellpadding=0>
	<tr><td height=80 class=TLbt align=center><b><u><%=bt%></u></b></td><td></td></tr>
</table>
<asp:LinkButton ID="lb1" Runat="server" OnClick="exl_dr_sql" AutoPostBack=true></asp:LinkButton>
<input type="hidden" name="zt">
<table border="0" cellPadding="0" cellSpacing="0" width="100%" >
	<tr height=30>	
		<td align="center" style="FONT-WEIGHT: bold; FONT-SIZE: 14px; COLOR: darkblue; FONT-FAMILY: ����">���鵼�������Դ�Ƿ���ȷ��</td>
	</tr>
	<tr height=30>	
		<td class="red14" align="center"><div style="width:500px; text-align:left;"><b>ע:<br />
        (1)Ʒ���ſ���ά������<br />
        (2)Ҫ�޸Ļ�������ɾ��ԭ�����������µ���<br />
        (3)����˳�����ţ���Ʒ���ţ�Ҫ�б�ͷ!<br />
        (4)һ���ϴ����ݲ��ܳ���200��</b></div></td>
	</tr>
</table>
<center>
<table border="0" cellPadding="0" cellSpacing="0" width="60%" >
	<tr height=50>	
		<td >&nbsp;</td>
		<td class="blue14" align="left"><b>��ȡ�ı���:</b></td>
		<td><input type="text" id="mytable" runat=server name="mytable" style="WIDTH: 280px;" value="Sheet1"></td>
		<td>&nbsp;</td>
	</tr>
	<tr height=50>	
		<td >&nbsp;</td>
		<td class="blue14" align="left"><b>ѡ���ļ�:</b></td>
		<td><input type="file" id="fileUpload" runat=server onkeydown="return false;" name="fileUpload" style="WIDTH: 280px;"></td>
		<td>&nbsp;</td>
	</tr>
	<tr height=25>	
		<td >&nbsp;</td>
		<td >&nbsp;</td>
		<td class="red" align="center"><%=tsxx%>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
</table>
<table border="0" cellPadding="0" cellSpacing="0" width="100%" >
	<tr height=60>	
		<td >&nbsp;</td>
		<td width=10 valign=bottom><IMG alt="����" src="../TLinc/img/btn_dr2.gif" id="My_up" onclick="MyDr()" onmouseover='src="../TLinc/img/btn_dr1.gif"' onmouseout='src="../TLinc/img/btn_dr2.gif"'></td>
		<td width=20>&nbsp;</td>
		<td width=10 valign=bottom><IMG alt="�ر�" src="../TLinc/img/btn_close2.gif" onclick="javascript:window.returnValue='yes';window.close();" onmouseover='src="../TLinc/img/btn_close1.gif"' onmouseout='src="../TLinc/img/btn_close2.gif"'></td>
		<td>&nbsp;</td>
	</tr>
</table>
</center>
</form>
<script language="vb" runat="server">
    dim tsxx,tzid,myselected,str_sql as string
    dim myconn,mydr
    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        tzid = 1
        myconn = New Data.SqlClient.SqlConnection("server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft ")
    End Sub
    Private Sub exl_dr_sql(ByVal sender As System.Object, ByVal e As System.EventArgs)
        Dim str_Path, strExt, str_Name, str_NewName As String
        'Dim intExt, intName As Integer
        If fileUpload.PostedFile.ContentLength > 0 Then
            str_Path = fileUpload.PostedFile.FileName
            'intExt = str_Path.LastIndexOf(".")
            'strExt = str_Path.Substring(intExt)
            strExt = Path.GetExtension(fileUpload.PostedFile.FileName).ToUpper()
            'intName = str_Path.LastIndexOf("\")
            'ȡ���ļ�������
            'str_Name = str_Path.Substring(intName,intExt-intName)
            str_Name = Path.GetFileNameWithoutExtension(fileUpload.PostedFile.FileName).ToUpper()
            If UCase(strExt) = ".XLS" Then
                '����ʱ���ļ�����
                str_NewName = str_Name + DateTime.Now.ToString("yyyyMMddhhmmss") + fileUpload.PostedFile.ContentLength.ToString() + strExt
                Try
                    '�ϴ��ļ�
                    fileUpload.PostedFile.SaveAs(Server.MapPath("\techdata\" + str_NewName))
                    '���ݵ������ ������ɾ���ļ�
                    data_op(Server.MapPath("\techdata\" + str_NewName), "[" + Trim(mytable.Value) + "$]")
                Catch ex As Exception
                    tsxx = "���ݵ���ʧ�ܣ���ȷ�ϱ����Ƿ���ȷ!ȷ��EXCEL������ݸ�ʽ����ȷ�ģ�" + ex.Message
                Finally
                    'ɾ������
                    File.Delete(Server.MapPath("\techdata\" + str_NewName))
                End Try
            Else
                tsxx = "ѡ����ļ�����EXCEL�ļ��������ԣ�"
            End If
            If Len(tsxx) = 0 Then tsxx = "�ļ��ϴ��ɹ���<br />"
        End If
    End Sub
    Private function get_oledbDataSet(str_NewPath as string,tablename as string) as DataSet
        Dim OleDbConn As New OleDb.OleDbConnection("Provider=microsoft.ace.oledb.12.0; Data Source=" + str_NewPath + "; Extended Properties=Excel 8.0;")
        'Dim OleDbConn As New OleDb.OleDbConnection("Provider=Microsoft.Jet.OleDb.4.0; Data Source=" + str_NewPath + "; Extended Properties=Excel 8.0;")
        Dim oleda As New OleDb.OleDbDataAdapter
        dim oleds = new DataSet()
        str_sql = "select * from "+tablename
        OleDbConn.Open()
        oleda.SelectCommand = New OleDb.OleDbCommand(str_sql, OleDbConn)
        oleda.Fill(oleds)
        OleDbConn.Dispose()
        return oleds
    End Function
    Private Sub data_op(ByVal str_NewPath As String, ByVal tablename As String)
        Dim myds As DataSet = get_oledbDataSet(str_NewPath, tablename)

        Dim dataRow11 As DataRow
        Dim MySql As String = ""
        Dim htmlresult As String = ""
        Dim strSQL As String = ""
        Dim yphh As String = ""
        Dim sphh As String = ""
        Dim spkh As String = ""
        Dim ypkh As String = ""
        Dim zp As String = ""
        Dim mytestds As System.Data.DataSet

        '���������
        If myds.Tables(0).Rows.Count > 200 Then
            Throw New Exception("���ݲ��ܳ���200��")
            Return
        End If

        Dim yphhlist As IList(Of String) = New List(Of String)
        Dim sphhlist As IList(Of String) = New List(Of String)

        For Each dataRow11 In myds.Tables(0).Rows



            yphh = IIf(IsDBNull(dataRow11("��Ʒ����")), "", dataRow11("��Ʒ����").ToString().Trim().ToUpper())

            sphh = IIf(IsDBNull(dataRow11("��Ʒ����")), "", dataRow11("��Ʒ����").ToString().Trim().ToUpper())
            spkh = ""

            zp = "0"



            If yphh <> "" And sphh <> "" Then
                '��ֹ�ظ�����Ʒ����
                If yphhlist.Contains(yphh) Then
                    Continue For
                Else
                    yphhlist.Add(yphh)
                End If
                '��ֹ�ظ�����Ʒ����
                If sphhlist.Contains(sphh) Then
                    Continue For
                Else
                    sphhlist.Add(sphh)
                End If

                '��鵱ǰ��Ʒ�����Ƿ��Ѿ�ʹ��
                strSQL = "select yphh from yx_t_ypdmb where yphh <> '" + yphh + "' and sphh='" + sphh + "' and tzid='" + tzid + "'"
                mytestds = MyData.MyDataSet(myconn, strSQL)
                If mytestds.Tables(0).Rows.Count > 0 Then
                    htmlresult += "��Ʒ���š�" + sphh + "���Ѿ�����Ʒ����Ϊ��" + mytestds.Tables(0).Rows(0)("yphh").ToString + "���Ĳ�Ʒʹ��<br />"
                Else
                    '��ѯ����Ʒ���ŵ�psbs�Ƿ�Ϊ1
                    strSQL = "select a.psbs,d.gjz,a.ypkh from yx_t_ypdmb a inner join yx_t_splb d on a.splbid=d.id where a.yphh = '" + yphh + "' and a.tzid='" + tzid + "'"
                    mytestds = MyData.MyDataSet(myconn, strSQL)
                    If mytestds.Tables(0).Rows.Count > 0 Then
                        If Convert.ToBoolean(mytestds.Tables(0).Rows(0)("psbs")) Then
                            If sphh.Length > 0 Then

                                ypkh = mytestds.Tables(0).Rows(0)("ypkh").ToString()
                                spkh = sphh.Substring(ypkh.Length)

                                'linwy��ypkh�ĳ���Ϊȡ��Ʒ��ų���
                                'Dim gjz As Int32 = 0
                                'Int32.TryParse(mytestds.Tables(0).Rows(0)("gjz").ToString(), gjz)
                                'If gjz <= sphh.Length Then
                                '    spkh = sphh.Substring(0, gjz)
                                'End If

                                MySql += "update yx_t_ypdmb set spkh='" + spkh + "',sphh='" + sphh + "',xgr='" + Session("username") + "',xgrq=getdate() where yphh='" + yphh + "' and tzid='" + tzid + "';"
                                '����Ƿ�����yx_t_spdmb
                                strSQL = "select sphh from yx_t_spdmb where tzid=" + tzid + " and sphh='" + sphh + "'"
                                mytestds = MyData.MyDataSet(myconn, strSQL)
                                If mytestds.Tables(0).Rows.Count = 0 Then
                                    MySql += "insert into yx_t_spdmb (spkh,zp,box,tzid,splbid,yphh,sphh,spmc,dw,tml,cbdj,ccdj,lsdj,bz,jdrq,kfbh,xlid,ysid,cbhs,xshs,userid,spdlid,sjdj,tydddj,fg) "
                                    MySql += "select '" + spkh + "','" + zp + "',box,tzid,splbid,yphh,'" + sphh + "',ypmc,ypdw,tml,0,0,lsdj,'',getdate(),kfbh,0,0,0,0," + Session("userid") + ",spdlid,sjdj,tydddj,fg from yx_T_ypdmb where yphh='" + yphh + "';"
                                Else
                                    MySql += "update yx_T_spdmb set yx_T_spdmb.spkh='" + spkh + "',yx_T_spdmb.sphh='" + sphh + "',yx_T_spdmb.lsdj=yp.lsdj,yx_T_spdmb.tml=yp.tml,yx_T_spdmb.box=yp.box,yx_T_spdmb.zp='" + zp + "' from yx_T_ypdmb yp where yp.yphh='" + yphh + "' and yp.yphh=yx_T_spdmb.yphh and yx_T_spdmb.yphh='" + yphh + "' ;"
                                End If
                                MySql += "update yf_t_bom set sphh='" + sphh + "' where tzid='" + tzid + "' and yphh='" + yphh + "' ;"
                                MySql += "update yx_t_dddjmx set sphh='" + sphh + "' where yphh='" + yphh + "' ;"
                                MySql += "update yx_t_dddjmx set dj=b.lsdj FROM yx_t_dddjmx AS a inner join yx_v_ypdmb AS b ON a.yphh=b.yphh and a.dj<>b.lsdj and a.sphh='" + sphh + "' and id in (select id from yx_t_dddjb where  (djlx=203 or djlx=201) )"
                                MySql += "update yx_t_dddjmx set dj=a.lsdj,je=(sl*a.lsdj) FROM"
                                MySql += "(select a.mxid,b.sphh,b.lsdj from yx_v_dddjmx a ,yx_v_ypdmb b where (a.djlx=203 or a.djlx=201)"
                                MySql += "and a.sphh='" + sphh + "' and a.sphh=b.sphh and a.dj<>b.lsdj ) a where a.sphh=yx_t_dddjmx.sphh and a.mxid=yx_t_dddjmx.mxid;"
                                MySql += "update yx_t_spshb set sphh='" + sphh + "' where tzid=" + tzid + " and yphh='" + yphh + "' ;"
                                MySql += "update yx_t_cgjgsbmx set sphh='" + sphh + "' where  yphh='" + yphh + "';"
                                '����sku bx
                                MySql += " update a set a.bx=right(a.sphh,len(c.bx)),a.sku= left(a.sphh,len(a.sphh)-LEN(c.bx)) from yx_t_spdmb a inner join yx_t_ypdmb c on a.sphh=c.sphh where a.sphh='" + sphh + "';"

                            End If
                        Else
                            htmlresult += "��Ʒ���š�" + yphh + "�����δͨ��<br />"
                        End If
                    Else
                        htmlresult += "��Ʒ���š�" + yphh + "���Ҳ���<br />"
                    End If
                End If
            Else
                'htmlresult += "��Ʒ���ź���Ʒ���Ų���Ϊ��<br />"
            End If
        Next
        If Len(MySql) > 0 Then
            'If MyData.MyDataTrans(myconn, MySql) = 0 Then
            'tsxx = "��Ʒ����Excel����ʧ�ܣ�" + MySql
            'Else
            '   tsxx = "��Ʒ����Excel���³ɹ���" + htmlresult
            'End If
        Else
            tsxx = "Դ�ļ��Ƿ������ݣ�"
        End If
    End Sub

</script>
