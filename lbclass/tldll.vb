Imports System
Imports System.Data.SqlClient
Imports System.Runtime.CompilerServices
Imports Microsoft.VisualBasic
Imports Microsoft.VisualBasic.CompilerServices


Public Class tldll
        ' Token: 0x02000003 RID: 3
        Public Sub New()
            Me.lbdll = New lbdll()
        End Sub

        Public Function Tl_xt_userqx(MyLink As Object, MyConn As Object, SqlBm As Object, MyTarget As Object, tzid As Object, ssid As Object) As Object
            Dim o As Object = ""
            o = ObjectType.AddObj(o, "<table border=0 width=100% height=1 cellspacing=0 cellpadding=0 >")
            o = ObjectType.AddObj(o, "<tr><td height=49></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=22 class=blk align=left valign=bottom>&nbsp;" & ChrW(35831) & ChrW(36873) & ChrW(25321) & ":</td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=1 bgcolor=silver></td></tr><tr><td height=1 bgcolor=#ffffff></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td valign=top height=545>")
            o = ObjectType.AddObj(o, "<div id='DivDetail' style='OVERFLOW:  scroll; HEIGHT: 100%'>")
            o = ObjectType.AddObj(o, "<table cellSpacing=0 cellPadding=0 width=100%>")
            Dim sqlConnection As SqlConnection = New SqlConnection(StringType.FromObject(MyLink))
            Dim value As Object = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj("select count(*) as jls from ", SqlBm), " where tzid="), tzid), " and ssid="), ssid)
            Dim objectValue As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            LateBinding.LateCall(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing)
            Dim o2 As Object = StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"jls"}, Nothing, Nothing))
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            value = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj("select * from ", SqlBm), " where tzid="), tzid), " and ssid="), ssid), " order by dm")
            objectValue = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            Dim obj As Object = 0
            While BooleanType.FromObject(LateBinding.LateGet(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                obj = ObjectType.AddObj(obj, 1)
                Dim o3 As Object = StringType.FromObject(obj)
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td height=22 class=fu language='JScript' onMouseUp='popmenu (Aux"), o3), ",img"), o3), ","), o2), ");'><table width=100% cellspacing=0 cellpadding=0 class=blk >")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=2 align=center><img id='img"), o3), "' src='../tlerp/images/line_01.gif'></td><td width=3></td><td align=left valign=bottom>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<a  class=gray href='"), MyTarget), "?ssid="), StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"id"}, Nothing, Nothing))), "&khid="), tzid), "&mj="), StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"mj"}, Nothing, Nothing))), "'>"), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"mc"}, Nothing, Nothing)), "</a></td></tr></table></td></tr>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td id='Aux"), o3), "' style='Display:none;'><table width=100% cellspacing=0 cellpadding=0 >")
                Dim o4 As Object = Strings.Trim(StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"id"}, Nothing, Nothing)))
                Dim value2 As Object = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj("select * from  ", SqlBm), "  where tzid="), tzid), " and ssid='"), o4), "' order by dm")
                Dim objectValue2 As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(sqlConnection, StringType.FromObject(value2)))
                While BooleanType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                    o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=40 height=19 align=right><img src='../tlerp/images/line_03.gif'></td><td valign=bottom><a  class=gray href='"), MyTarget), "?ssid="), StringType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"id"}, Nothing, Nothing))), "&khid="), tzid), "&mj="), StringType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"mj"}, Nothing, Nothing))), "'>"), LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"mc"}, Nothing, Nothing)), "</a></td></tr>")
                End While
                sqlConnection.Close()
                o = ObjectType.AddObj(o, "</table></td></tr>")
            End While
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            Return ObjectType.AddObj(o, "</table></div></td></tr></table>")
        End Function

        Public Function xt_cl_shgwczysd(MyConn As Object, MyTarget As Object, tzid As Object) As Object
            Dim o As Object = ""
            o = ObjectType.AddObj(o, "<table border=0 width=100% height=1 cellspacing=0 cellpadding=0 >")
            o = ObjectType.AddObj(o, "<tr><td height=4></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=22 class=blk align=left valign=bottom>&nbsp;" & ChrW(36873) & ChrW(25321) & ChrW(23457) & ChrW(26680) & ChrW(23703) & ChrW(20301) & ":</td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=1 bgcolor=silver></td></tr><tr><td height=1 bgcolor=#ffffff></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td valign=top height=545>")
            o = ObjectType.AddObj(o, "<div id='DivDetail' style='OVERFLOW:  scroll; HEIGHT: 100%'>")
            o = ObjectType.AddObj(o, "<table cellSpacing=0 cellPadding=0 width=100%>")
            Dim value As Object = ObjectType.AddObj(ObjectType.AddObj("select * from xt_t_shgw where tzid=", tzid), " order by dm")
            Dim objectValue As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            While BooleanType.FromObject(LateBinding.LateGet(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                o = ObjectType.AddObj(o, "<tr><td height=22 class=fu ><table width=100% cellspacing=0 cellpadding=0 class=blk >")
                o = ObjectType.AddObj(o, "<tr><td width=2 align=center>&nbsp;" & ChrW(9671) & "&nbsp;</td><td width=3></td><td align=left valign=bottom>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<a  class=gray onclick='javascript:myxz("), StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"id"}, Nothing, Nothing))), ")'>"), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"mc"}, Nothing, Nothing)), "</a></td></tr></table></td></tr>")
            End While
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            Return ObjectType.AddObj(o, "</table></div></td></tr></table>")
        End Function

        Public Function xt_cl_djshgwsd(MyConn As Object, MyTarget As Object, djlxfl As Object) As Object
            Dim o As Object = ""
            o = ObjectType.AddObj(o, "<table border=0 width=100% height=1 cellspacing=0 cellpadding=0 >")
            o = ObjectType.AddObj(o, "<tr><td height=4></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=22 class=blk align=left valign=bottom>&nbsp;" & ChrW(36873) & ChrW(25321) & ChrW(21333) & ChrW(25454) & ChrW(31867) & ChrW(22411) & ":</td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=1 bgcolor=silver></td></tr><tr><td height=1 bgcolor=#ffffff></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td valign=top height=545>")
            o = ObjectType.AddObj(o, "<div id='DivDetail' style='OVERFLOW:  scroll; HEIGHT: 100%'>")
            o = ObjectType.AddObj(o, "<table cellSpacing=0 cellPadding=0 width=100%>")
            Dim value As Object = ObjectType.AddObj(ObjectType.AddObj("select dm,mc=convert(varchar,dm)+mc from t_djlxb where ty=0 and djlxfl like '", djlxfl), "%' order by dm")
            Dim objectValue As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            While BooleanType.FromObject(LateBinding.LateGet(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                o = ObjectType.AddObj(o, "<tr><td height=22 class=fu><table width=100% cellspacing=0 cellpadding=0 class=blk >")
                o = ObjectType.AddObj(o, "<tr><td width=2 align=center>&nbsp;" & ChrW(9671) & "&nbsp;</td><td width=3></td><td align=left valign=bottom>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<a  class=gray onclick='javascript:myxz("), StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"dm"}, Nothing, Nothing))), ")'>"), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"mc"}, Nothing, Nothing)), "</a></td></tr></table></td></tr>")
            End While
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            Return ObjectType.AddObj(o, "</table></div></td></tr></table>")
        End Function

        Public Function xt_dmF_djlb(MyConn As Object, MyTarget As Object) As Object
            Dim o As Object = ""
            o = ObjectType.AddObj(o, "<table border=0 width=100% height=1 cellspacing=0 cellpadding=0 >")
            o = ObjectType.AddObj(o, "<tr><td height=34></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=22 class=blk align=left valign=bottom>&nbsp;" & ChrW(36873) & ChrW(25321) & ChrW(21333) & ChrW(25454) & ChrW(31867) & ChrW(22411) & ":</td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=1 bgcolor=silver></td></tr><tr><td height=1 bgcolor=#ffffff></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td valign=top height=545>")
            o = ObjectType.AddObj(o, "<div id='DivDetail' style='OVERFLOW:  scroll; HEIGHT: 100%'>")
            o = ObjectType.AddObj(o, "<table cellSpacing=0 cellPadding=0 width=100%>")
            Dim value As Object = "select * from t_djlxb order by dm"
            Dim objectValue As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            While BooleanType.FromObject(LateBinding.LateGet(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                o = ObjectType.AddObj(o, "<tr><td height=22 class=fu><table width=100% cellspacing=0 cellpadding=0 class=blk >")
                o = ObjectType.AddObj(o, "<tr><td width=2 align=center>&nbsp;" & ChrW(9671) & "&nbsp;</td><td width=3></td><td align=left valign=bottom>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<a  class=gray href='"), MyTarget), "?dmssid="), StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"dm"}, Nothing, Nothing))), "'>"), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"mc"}, Nothing, Nothing)), "</a></td></tr></table></td></tr>")
            End While
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            Return ObjectType.AddObj(o, "</table></div></td></tr></table>")
        End Function

        Public Function xt_dmF_kh(mylink As Object, MyConn As Object, MyTarget As Object, tzid As Object, ssid As Object) As Object
            Dim o As Object = ""
            o = ObjectType.AddObj(o, "<table border=0 width=100% height=1 cellspacing=0 cellpadding=0 >")
            o = ObjectType.AddObj(o, "<tr><td height=34></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=22 class=blk align=left valign=bottom>&nbsp;" & ChrW(36873) & ChrW(25321) & ChrW(31867) & ChrW(21035) & ":</td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=1 bgcolor=silver></td></tr><tr><td height=1 bgcolor=#ffffff></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td valign=top height=545>")
            o = ObjectType.AddObj(o, "<div id='DivDetail' style='OVERFLOW:  scroll; HEIGHT: 100%'>")
            o = ObjectType.AddObj(o, "<table cellSpacing=0 cellPadding=0 width=100%>")
            Dim sqlConnection As SqlConnection = New SqlConnection(StringType.FromObject(mylink))
            Dim value As Object = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj("select count(*) as jls from t_xtdm where tzid=", tzid), " and ssid="), ssid)
            Dim objectValue As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            LateBinding.LateCall(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing)
            Dim o2 As Object = StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"jls"}, Nothing, Nothing))
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            value = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj("select id,mc,cs from t_xtdm where tzid=", tzid), " and ssid="), ssid), " order by dm")
            objectValue = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            Dim obj As Object = 0
            While BooleanType.FromObject(LateBinding.LateGet(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                obj = ObjectType.AddObj(obj, 1)
                Dim o3 As Object = StringType.FromObject(obj)
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td height=22 class=fu language='JScript' onMouseUp='popmenu (Aux"), o3), ",img"), o3), ","), o2), ");'><table width=100% cellspacing=0 cellpadding=0 class=blk >")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=2 align=center><img id='img"), o3), "' src='../tlerp/images/line_01.gif'></td><td width=3></td><td align=left valign=bottom>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<a  class=gray href='"), MyTarget), "?myssid="), tzid), "&mykhfl="), StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"cs"}, Nothing, Nothing))), "&myssmc="), StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"mc"}, Nothing, Nothing))), "'>"), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"mc"}, Nothing, Nothing)), "</a></td></tr></table></td></tr>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td id='Aux"), o3), "' style='Display:none;'><table width=100% cellspacing=0 cellpadding=0 >")
                Dim o4 As Object = Strings.Trim(StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"cs"}, Nothing, Nothing)))
                Dim value2 As Object = ObjectType.AddObj(ObjectType.AddObj("select khid,khmc from  yx_t_khb  where khfl='", o4), "' order by khdm")
                Dim objectValue2 As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(sqlConnection, StringType.FromObject(value2)))
                While BooleanType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                    o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=40 height=19 align=right><img src='../tlerp/images/line_03.gif'></td><td valign=bottom><a  class=gray href='"), MyTarget), "?mykhfl=0&myssid="), StringType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"khid"}, Nothing, Nothing))), "&myssmc="), StringType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"khmc"}, Nothing, Nothing))), "'>"), LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"khmc"}, Nothing, Nothing)), "</a></td></tr>")
                End While
                sqlConnection.Close()
                o = ObjectType.AddObj(o, "</table></td></tr>")
            End While
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            Return ObjectType.AddObj(o, "</table></div></td></tr></table>")
        End Function

        Public Function TL_xt_khgxbgl(MyLink As Object, MyConn As Object, MyTarget As Object, tzid As Object, ssid As Object, khid As Object) As Object
            Dim o As Object = ""
            o = ObjectType.AddObj(o, "<table border=0 width=100% height=1 cellspacing=0 cellpadding=0 >")
            o = ObjectType.AddObj(o, "<tr><td height=34></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=22 class=blk align=left valign=bottom>&nbsp;" & ChrW(36873) & ChrW(25321) & ChrW(31867) & ChrW(21035) & ":</td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=1 bgcolor=silver></td></tr><tr><td height=1 bgcolor=#ffffff></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td valign=top height=545>")
            o = ObjectType.AddObj(o, "<div id='DivDetail' style='OVERFLOW:  scroll; HEIGHT: 100%'>")
            o = ObjectType.AddObj(o, "<table cellSpacing=0 cellPadding=0 width=100%>")
            Dim sqlConnection As SqlConnection = New SqlConnection(StringType.FromObject(MyLink))
            Dim value As Object = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj("select count(*) as jls from t_xtdm where tzid=", tzid), " and ssid="), ssid)
            Dim objectValue As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            LateBinding.LateCall(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing)
            Dim o2 As Object = StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"jls"}, Nothing, Nothing))
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            value = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj("select id,mc from t_xtdm where tzid=", tzid), " and ssid="), ssid), " order by dm")
            objectValue = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            Dim obj As Object = 0
            While BooleanType.FromObject(LateBinding.LateGet(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                obj = ObjectType.AddObj(obj, 1)
                Dim o3 As Object = StringType.FromObject(obj)
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td height=22 class=fu language='JScript' onMouseUp='popmenu (Aux"), o3), ",img"), o3), ","), o2), ");'><table width=100% cellspacing=0 cellpadding=0 class=blk >")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=2 align=center><img id='img"), o3), "' src='../tlerp/images/line_01.gif'></td><td width=3></td><td align=left valign=bottom>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<a  class=gray href='"), MyTarget), "?ssid="), tzid), "&khid="), khid), "'>"), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"mc"}, Nothing, Nothing)), "</a></td></tr></table></td></tr>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td id='Aux"), o3), "' style='Display:none;'><table width=100% cellspacing=0 cellpadding=0 >")
                Dim o4 As Object = Strings.Trim(StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"id"}, Nothing, Nothing)))
                Dim value2 As Object = ObjectType.AddObj(ObjectType.AddObj("select khid,khmc from  yx_t_khb  where khfl='", o4), "' order by khdm")
                Dim objectValue2 As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(sqlConnection, StringType.FromObject(value2)))
                While BooleanType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                    o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=40 height=19 align=right><img src='../tlerp/images/line_03.gif'></td><td valign=bottom><a  class=gray href='"), MyTarget), "?ssid="), StringType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"khid"}, Nothing, Nothing))), "&khid="), khid), "'>"), LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"khmc"}, Nothing, Nothing)), "</a></td></tr>")
                End While
                sqlConnection.Close()
                o = ObjectType.AddObj(o, "</table></td></tr>")
            End While
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            Return ObjectType.AddObj(o, "</table></div></td></tr></table>")
        End Function

        Public lbdll As lbdll
    End Class

