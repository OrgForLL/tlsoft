Imports System
Imports System.Data.SqlClient
Imports System.Runtime.CompilerServices
Imports Microsoft.VisualBasic
Imports Microsoft.VisualBasic.CompilerServices


Public Class lldll
        ' Token: 0x02000004 RID: 4
        Public Sub New()
            Me.lbdll = New lbdll()
        End Sub

        Public Function ll_tree_jgvip(MyLink As Object, MyConn As Object, MyTarget As Object) As Object
            Dim o As Object = ""
            o = ObjectType.AddObj(o, "<table border=0 width=100% height=1 cellspacing=0 cellpadding=0 >")
            o = ObjectType.AddObj(o, "<tr><td height=34></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=22 class=blk align=left valign=bottom>&nbsp;" & ChrW(36873) & ChrW(25321) & ChrW(31867) & ChrW(21035) & ":</td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=1 bgcolor=silver></td></tr><tr><td height=1 bgcolor=#ffffff></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td valign=top height=502>")
            o = ObjectType.AddObj(o, "<div id='DivDetail' style='OVERFLOW:  scroll; HEIGHT: 100%'>")
            o = ObjectType.AddObj(o, "<table cellSpacing=0 cellPadding=0 width=100%>")
            Dim sqlConnection As SqlConnection = New SqlConnection(StringType.FromObject(MyLink))
            Dim value As Object = "select count(*) as jls from t_menu where lb='97'and left(m_dm,3)='100' and right(m_dm,3)<>'000' "
            Dim objectValue As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            LateBinding.LateCall(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing)
            Dim o2 As Object = StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"jls"}, Nothing, Nothing))
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            value = "select * from t_menu where lb='97'and left(m_dm,3)='100' and right(m_dm,3)<>'000'   order by m_dm"
            objectValue = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            Dim obj As Object = 0
            While BooleanType.FromObject(LateBinding.LateGet(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                obj = ObjectType.AddObj(obj, 1)
                Dim o3 As Object = StringType.FromObject(obj)
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td height=22 class=fu language='JScript' onMouseUp='popmenu (Aux"), o3), ",img"), o3), ","), o2), ");'><table width=100% cellspacing=0 cellpadding=0 class=blk >")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=2 align=center><img id='img"), o3), "' src='../llmis/images/line_01.gif'></td><td width=3></td><td align=left valign=bottom>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<a  class=blk href='"), MyTarget), "?myssid="), Strings.Trim(StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_asp"}, Nothing, Nothing)))), "&myssmc="), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_name"}, Nothing, Nothing)), "'>"), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_name"}, Nothing, Nothing)), "</a></td></tr></table></td></tr>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td id='Aux"), o3), "' style='Display:none;'><table width=100% cellspacing=0 cellpadding=0 >")
                Dim o4 As Object = Strings.Trim(StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_asp"}, Nothing, Nothing)))
                Dim value2 As Object = ObjectType.AddObj(ObjectType.AddObj("select * from  yx_t_spkh  where ssid='", o4), "' order by khdm")
                Dim objectValue2 As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(sqlConnection, StringType.FromObject(value2)))
                While BooleanType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                    o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=40 height=19 align=right><img src='../llmis/images/line_03.gif'></td><td valign=bottom><a  class=gray href='"), MyTarget), "?myssid="), StringType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"khid"}, Nothing, Nothing))), "&myssmc="), LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"khmc"}, Nothing, Nothing)), "'>"), Strings.Left(StringType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"khmc"}, Nothing, Nothing)), 10)), "</a></td></tr>")
                End While
                sqlConnection.Close()
                o = ObjectType.AddObj(o, "</table></td></tr>")
            End While
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            Return ObjectType.AddObj(o, "</table></div></td></tr></table>")
        End Function

        Public Function yx_wh_khgxbgl(MyLink As Object, MyConn As Object, MyTarget As Object, khid As Object) As Object
            Dim o As Object = ""
            o = ObjectType.AddObj(o, "<table border=0 width=100% height=1 cellspacing=0 cellpadding=0 >")
            o = ObjectType.AddObj(o, "<tr><td height=34></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=22 class=blk align=left valign=bottom>&nbsp;" & ChrW(36873) & ChrW(25321) & ChrW(31867) & ChrW(21035) & ":</td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=1 bgcolor=silver></td></tr><tr><td height=1 bgcolor=#ffffff></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td valign=top height=545>")
            o = ObjectType.AddObj(o, "<div id='DivDetail' style='OVERFLOW:  scroll; HEIGHT: 100%'>")
            o = ObjectType.AddObj(o, "<table cellSpacing=0 cellPadding=0 width=100%>")
            Dim sqlConnection As SqlConnection = New SqlConnection(StringType.FromObject(MyLink))
            Dim value As Object = "select count(*) as jls from t_menu where lb='97'and left(m_dm,3)='100' and right(m_dm,3)<>'000' "
            Dim objectValue As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            LateBinding.LateCall(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing)
            Dim o2 As Object = StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"jls"}, Nothing, Nothing))
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            value = "select * from t_menu where lb='97'and left(m_dm,3)='100' and right(m_dm,3)<>'000'   order by m_dm"
            objectValue = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            Dim obj As Object = 0
            While BooleanType.FromObject(LateBinding.LateGet(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                obj = ObjectType.AddObj(obj, 1)
                Dim o3 As Object = StringType.FromObject(obj)
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td height=22 class=fu language='JScript' onMouseUp='popmenu (Aux"), o3), ",img"), o3), ","), o2), ");'><table width=100% cellspacing=0 cellpadding=0 class=blk >")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=2 align=center><img id='img"), o3), "' src='../llmis/images/line_01.gif'></td><td width=3></td><td align=left valign=bottom>")
                o = ObjectType.AddObj(ObjectType.AddObj(o, LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_name"}, Nothing, Nothing)), "</td></tr></table></td></tr>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td id='Aux"), o3), "' style='Display:none;'><table width=100% cellspacing=0 cellpadding=0 >")
                Dim o4 As Object = Strings.Trim(StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_asp"}, Nothing, Nothing)))
                Dim value2 As Object = ObjectType.AddObj(ObjectType.AddObj("select * from  yx_t_spkh  where ssid='", o4), "' order by khdm")
                Dim objectValue2 As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(sqlConnection, StringType.FromObject(value2)))
                While BooleanType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                    o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=40 height=19 align=right><img src='../llmis/images/line_03.gif'></td><td valign=bottom><a  class=gray href='"), MyTarget), "?ssid="), StringType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"khid"}, Nothing, Nothing))), "&khid="), khid), "'>"), Strings.Left(StringType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"khmc"}, Nothing, Nothing)), 15)), "</a></td></tr>")
                End While
                sqlConnection.Close()
                o = ObjectType.AddObj(o, "</table></td></tr>")
            End While
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            Return ObjectType.AddObj(o, "</table></div></td></tr></table>")
        End Function

        Public Function ll_tree_ghs(MyLink As Object, MyConn As Object, MyTarget As Object) As Object
            Dim o As Object = ""
            o = ObjectType.AddObj(o, "<table border=0 width=100% height=1 cellspacing=0 cellpadding=0 >")
            o = ObjectType.AddObj(o, "<tr><td height=34></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=22 class=blk align=left valign=bottom>&nbsp;" & ChrW(36873) & ChrW(25321) & ChrW(31867) & ChrW(21035) & ":</td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=1 bgcolor=silver></td></tr><tr><td height=1 bgcolor=#ffffff></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td valign=top height=502>")
            o = ObjectType.AddObj(o, "<div id='DivDetail' style='OVERFLOW:  scroll; HEIGHT: 100%'>")
            o = ObjectType.AddObj(o, "<table cellSpacing=0 cellPadding=0 width=100%>")
            Dim value As Object = "select count(*) as jls from t_menu where lb='97'and left(m_dm,3)='200' and right(m_dm,3)<>'000' "
            Dim objectValue As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            LateBinding.LateCall(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing)
            Dim o2 As Object = StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"jls"}, Nothing, Nothing))
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            value = "select * from t_menu where lb='97'and left(m_dm,3)='200' and right(m_dm,3)<>'000'   order by m_dm"
            objectValue = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            Dim obj As Object = 0
            While BooleanType.FromObject(LateBinding.LateGet(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                obj = ObjectType.AddObj(obj, 1)
                Dim o3 As Object = StringType.FromObject(obj)
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td height=22 class=fu language='JScript' onMouseUp='popmenu (Aux"), o3), ",img"), o3), ","), o2), ");'><table width=100% cellspacing=0 cellpadding=0 class=blk >")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=2 align=center><img id='img"), o3), "' src='images/line_01.gif'></td><td width=3></td><td align=left valign=bottom>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<a  class=blk href='"), MyTarget), "?ghslb="), Strings.Trim(StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_asp"}, Nothing, Nothing)))), "&ghslbmc="), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_name"}, Nothing, Nothing)), "'>"), "("), Strings.Trim(StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_asp"}, Nothing, Nothing)))), ")"), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_name"}, Nothing, Nothing)), "</a></td></tr></table></td></tr>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td id='Aux"), o3), "' style='Display:none;'><table width=100% cellspacing=0 cellpadding=0 >")
                o = ObjectType.AddObj(o, "</table></td></tr>")
            End While
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            Return ObjectType.AddObj(o, "</table></div></td></tr></table>")
        End Function

        Public Function ll_tree_ghsuser(MyLink As Object, MyConn As Object, MyTarget As Object) As Object
            Dim o As Object = ""
            o = ObjectType.AddObj(o, "<table border=0 width=100% height=1 cellspacing=0 cellpadding=0 >")
            o = ObjectType.AddObj(o, "<tr><td height=34></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=22 class=blk align=left valign=bottom>&nbsp;" & ChrW(36873) & ChrW(25321) & ChrW(31867) & ChrW(21035) & ":</td></tr>")
            o = ObjectType.AddObj(o, "<tr><td height=1 bgcolor=silver></td></tr><tr><td height=1 bgcolor=#ffffff></td></tr>")
            o = ObjectType.AddObj(o, "<tr><td valign=top height=502>")
            o = ObjectType.AddObj(o, "<div id='DivDetail' style='OVERFLOW:  scroll; HEIGHT: 100%'>")
            o = ObjectType.AddObj(o, "<table cellSpacing=0 cellPadding=0 width=100%>")
            Dim sqlConnection As SqlConnection = New SqlConnection(StringType.FromObject(MyLink))
            Dim value As Object = "select count(*) as jls from t_menu where lb='97'and left(m_dm,3)='200' and right(m_dm,3)<>'000' and m_asp<>'%' "
            Dim objectValue As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            LateBinding.LateCall(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing)
            Dim o2 As Object = StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"jls"}, Nothing, Nothing))
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            value = "select * from t_menu where lb='97'and left(m_dm,3)='200' and right(m_dm,3)<>'000'  and m_asp<>'%'  order by m_dm"
            objectValue = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(RuntimeHelpers.GetObjectValue(MyConn), StringType.FromObject(value)))
            Dim obj As Object = 0
            While BooleanType.FromObject(LateBinding.LateGet(objectValue, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                obj = ObjectType.AddObj(obj, 1)
                Dim o3 As Object = StringType.FromObject(obj)
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td height=22 class=fu language='JScript' onMouseUp='popmenu (Aux"), o3), ",img"), o3), ","), o2), ");'><table width=100% cellspacing=0 cellpadding=0 class=blk >")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=2 align=center><img id='img"), o3), "' src='images/line_01.gif'></td><td width=3></td><td align=left valign=bottom>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<a  class=blk href='"), MyTarget), "?ghslb="), Strings.Trim(StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_asp"}, Nothing, Nothing)))), "&ghslbmc="), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_name"}, Nothing, Nothing)), "'>"), "("), Strings.Trim(StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_asp"}, Nothing, Nothing)))), ")"), LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_name"}, Nothing, Nothing)), "</a></td></tr></table></td></tr>")
                o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td id='Aux"), o3), "' style='Display:none;'><table width=100% cellspacing=0 cellpadding=0 >")
                Dim o4 As Object = Strings.Trim(StringType.FromObject(LateBinding.LateGet(objectValue, Nothing, "item", New Object() {"m_asp"}, Nothing, Nothing)))
                Dim value2 As Object = ObjectType.AddObj(ObjectType.AddObj("select * from  yx_t_spghs  where ghslb='", o4), "' order by ghsdm")
                Dim objectValue2 As Object = RuntimeHelpers.GetObjectValue(Me.lbdll.CreateDataReader(sqlConnection, StringType.FromObject(value2)))
                While BooleanType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "read", New Object(-1) {}, Nothing, Nothing))
                    o = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(o, "<tr><td width=40 height=19 align=right><img src='images/line_03.gif'></td><td valign=bottom><a  class=gray href='"), MyTarget), "?gcid="), StringType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"ghsid"}, Nothing, Nothing))), "&gcmc="), LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"ghsmc"}, Nothing, Nothing)), "'>"), Strings.Left(StringType.FromObject(LateBinding.LateGet(objectValue2, Nothing, "item", New Object() {"ghsmc"}, Nothing, Nothing)), 10)), "</a></td></tr>")
                End While
                sqlConnection.Close()
                o = ObjectType.AddObj(o, "</table></td></tr>")
            End While
            LateBinding.LateCall(MyConn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            Return ObjectType.AddObj(o, "</table></div></td></tr></table>")
        End Function

        Public lbdll As lbdll
    End Class

