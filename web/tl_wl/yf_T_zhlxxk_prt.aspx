<%@ Page Language="VB" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!--#include file="../mycss/inc_mycss.inc" -->
<html>
<head>  
    <title runat="server" >打印</title>
    <meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
    <link href="../mycss/my_style.css" type="text/css" rel="stylesheet">
    <script language="vb" runat="server">
        Sub Page_Load(sender As Object, e As EventArgs)

            Response.Write("<div id='message' style='position:absolute; top:180; left:20; z-index:10;'><table width=100% border=0 cellspacing=0 cellpadding=0><tr><td width=30%></td><td bgcolor=#9F9F9F><table width=100% height=100 border=0 cellspacing=1 cellpadding=0><tr><td height=20 align=center bgcolor=#cfcfcf></td></tr><tr><td height=80 class=blk align=center bgcolor=#e8e8e8>正在处理，请稍候...</td></tr></table></td><td width=30%></td></tr></table></div>")
        End Sub
    </script>
    <style type="text/css">
        td {
            font-size: 12px;
        }
    </style>
    <style media="print">
        .PageNext {
            page-break-after: always;
        }
    </style>
</head>
<body leftmargin="0" topmargin="0" oncontextmenu="" self.event.returnvalue="false" onload="javascript:document.all.message.style.display='none'">
    <%
        'mylink = "server=192.168.35.10;uid=lllogin;pwd=rw1894tla;database=tlsoft"
        'myconn = New Data.SqlClient.SqlConnection(mylink)
        Dim MyDJid, csxmmx As String
        Dim str_sql, tzid, zbid, gzid As String
        Dim jls As Integer
        Dim myds, mydss As DataSet
        Dim mydr, mydrr As DataRow
        Dim m As Integer
        MyDJid = Request.QueryString("MyDJid")
        tzid = Session("userssid")
        zbid = Session("zbid")

        '显示主表
        str_sql = "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SET NOCOUNT ON;  "
        str_sql += " select bj.yphh chmc,bj.ddbh sphh,bj.cf as cfbl,wt.cysl,gz.syr,bj.bz,wt.csxm as csxmmx, "
        str_sql += "        case wt.csxm when 18291 then '梭织全项' when 18292 then '针织全项' when 18293 then '里料全项' when 18298 then '面料水洗' "
        str_sql += " when 18295 then 'GB 18401' when 584 then '专项测试' end as csxm ,gz.id gzid,"
        str_sql += " CASE gz.gzlx WHEN '9011' THEN '米样检测信息卡' when '9021' then '纱线类检测信息卡' ELSE '综合类检测信息卡' END AS gzlxmc,gz.gzlx,"
        str_sql += " bj.ypmc sxmc"
        str_sql += " from yf_t_bjdlb bj  "
        str_sql += " inner join cl_T_sygzb gz on bj.id=gz.lymxid inner join yf_t_wtjyxy wt on wt.sygzid=gz.id "
        'str_sql += " left outer join zw_T_htdddjb b on wt.htddid=b.id "
        'str_sql += " left outer join yx_T_khb kh on bj.khid=kh.khid   "
        'str_sql += " left outer join wl_T_flkfjh fl on wt.zlid=fl.id "
        'str_sql += " left outer join yx_t_spdmb sp on wt.sphh=sp.sphh "
        'str_sql += " left join cl_T_jhdjb jb on jb.id=gz.lymxid and jb.djlx=518 "
        'str_sql += " left join yf_t_ghsmlsyb ml on bj.lydjid=ml.id "
        'str_sql += " left outer join cl_T_chdmb cl on ml.mlbh=cl.chmc "
        str_sql += " where bj.id='" + MyDJid + "' "
        'Response.Write(str_sql)
        'Response.End()
        myds = lbdll.CreateDataSet(myconn, str_sql)
        jls = myds.Tables(0).Rows.Count
        For m = 0 To jls - 1

            mydr = myds.Tables(0).Rows(m)
            csxmmx = mydr.Item("csxmmx").ToString
            gzid = mydr.Item("gzid").ToString

            str_sql = " declare @xyid int ; select  @xyid=a.id from yf_t_wtjyxy a inner join cl_T_sygzb gz on a.sygzid=gz.id  where gz.id='" + gzid + "'"
            str_sql += " select a=stuff((select ','+a.mc from yf_t_wtjyxymx xy left join ghs_t_xtdm a on a.id=xy.xmid and  A.djlx1=9208 and A.ssid='" + csxmmx + "' "
            str_sql += "where xy.id=@xyid and xy.xz='1' order by case when isnull(a.cs,'')='' then '99' else a.cs end for xml path('')),1,1,'')"
            Dim a As String
            'Response.Write(str_sql)
            mydss = lbdll.CreateDataSet(myconn, str_sql)

            If mydss.Tables(0).Rows.Count > 0 Then

                mydrr = mydss.Tables(0).Rows(0)
                a = mydrr.Item("a").ToString

            End If
    %>
    <table style="width: 6cm; height: 8cm" cellspacing="0" cellpadding="0" border="0">
        <tr height="25" valign="middle" align="center">
            <td height="25" colspan="2" style="font-weight: bold; font-size: 14pt; width: 100%; text-decoration: underline">利郎(中国)有限公司
            </td>
        </tr>
        <tr height="20" align="center">
            <td height="20" colspan="2" style="font-weight: bold; font-size: 12pt; width: 100%; text-decoration: underline">
                <%=mydr.Item("gzlxmc")%>
            </td>
        </tr>
        <tr height="18">
            <td width="80" align="right">材料名称:
            </td>
            <td>
                <%=mydr.Item("chmc")%>
            </td>
        </tr>
        <%
            If mydr.Item("gzlx").ToString().Equals("9021") Then
        %>
        <tr height="18">
            <td width="80" align="right">纱线名称:
            </td>
            <td>
                <%=mydr.Item("sxmc")%>
            </td>
        </tr>
        <%End If
        %>
        <tr height="18">
            <td width="80" align="right">货&nbsp;&nbsp;号:
            </td>
            <td>
                <%=mydr.Item("sphh")%>
            </td>
        </tr>
        <tr height="18">
            <td width="80" align="right">成&nbsp;&nbsp;分:
            </td>
            <td>
                <%=mydr.Item("cfbl")%>
            </td>
        </tr>
        <tr height="18">
            <td width="80" align="right">总采购量:
            </td>
            <td>
                <%=mydr.Item("cysl")%>
            </td>
        </tr>
        <tr height="18">
            <td width="80" align="right">送样人:
            </td>
            <td>
                <%=mydr.Item("syr")%>
            </td>
        </tr>
        <tr height="18">
            <td width="80" align="right">备注:
            </td>
            <td>
                <%=mydr.Item("bz")%>
            </td>
        </tr>
        <tr height="18">
            <td width="80" align="right">测试项目:
            </td>
            <td>
                <%=a%>
            </td>
        </tr>
    </table>
    <%
            Next
            myds.Dispose()
            myconn.Close()
    %>
    </center>
</body>
</html>
