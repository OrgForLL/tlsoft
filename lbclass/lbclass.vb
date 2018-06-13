Imports System
Imports System.Data
Imports System.Data.Odbc
Imports System.Data.SqlClient
Imports System.IO
Imports System.Runtime.CompilerServices
Imports System.Web
Imports Microsoft.VisualBasic
Imports Microsoft.VisualBasic.CompilerServices

Public Class lbdll
        ' Token: 0x02000002 RID: 2
        Public Sub New()
            Me.myconn = New SqlConnection(StringType.FromObject(HttpContext.Current.Application("_erp_ConnString_TlA")))
            Me.ZbSer = "[192.168.35.10].tlsoft.dbo."
        End Sub

        Public Function MyEnd() As Object
            Dim obj As Object = 1
            If DoubleType.FromString(DateAndTime.Today.Year.ToString()) > 2100.0 Then
                obj = (ObjectType.ObjTst(obj, 0, False) = 0)
            End If
            Return obj
        End Function

        Public Function MyDataLink(tzid As String) As Object
            Me.mysql = String.Concat(New String() {"if exists (select 1 from yx_t_khb where khid = ", tzid, " and khid = zbid) ", "select DBServer,DBName from yx_t_khb where khid = ", tzid, " else ", "select DBServer,DBName from yx_t_khb where (select ccid + '-' from yx_t_khb where khid = ", tzid, ") like ccid + '-%' and jb = 1"})
            Me.mydrd = RuntimeHelpers.GetObjectValue(Me.CreateDataReader(Me.myconn, StringType.FromObject(Me.mysql)))
            If BooleanType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Read", New Object(-1) {}, Nothing, Nothing)) Then
                Me.mystr = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj("server=" + Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"DBServer"}, Nothing, Nothing))) + ";uid=", HttpContext.Current.Application("_erp_DBConn_User")), ";pwd="), HttpContext.Current.Application("_erp_DBConn_Pwd")), ";database="), Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"DBName"}, Nothing, Nothing))))
            Else
                Me.mystr = ""
            End If
            Me.myconn.Close()
            Return Me.mystr
        End Function

        Public Function QUERYDB() As Object
            Dim result As Object
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                result = "MyEndTime2005"
            Else
                result = "[192.168.35.10].tlsoft.dbo."
            End If
            Return result
        End Function

        Public Function ERPQUERY() As Object
            Dim result As Object
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                result = "MyEndTime2005"
            Else
                result = "ERPQUERY.dbo."
            End If
            Return result
        End Function

        Public Function ZbServer(tzid As String) As Object
            Dim result As Object
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                result = "MyEndTime2005"
            Else
                Me.mystr = ""
                Me.mysql = String.Concat(New String() {"if exists (select 1 from yx_t_khb where khid = ", tzid, " and khid = zbid) select DBServer,DBName from yx_t_khb where khid = ", tzid, " else select DBServer,DBName from yx_t_khb where (select ccid + '-' from yx_t_khb where khid = ", tzid, ") like ccid + '-%' and jb = 1"})
                Me.mydrd = RuntimeHelpers.GetObjectValue(Me.CreateDataReader(Me.myconn, StringType.FromObject(Me.mysql)))
                If BooleanType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Read", New Object(-1) {}, Nothing, Nothing)) Then
                    Me.mystr = String.Concat(New String() {"[", Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"DBServer"}, Nothing, Nothing))), "].", Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"DBName"}, Nothing, Nothing))), ".dbo."})
                End If
                Me.myconn.Close()
                If ObjectType.ObjTst(Me.mystr, Me.ZbSer, False) = 0 Then
                    Me.mystr = ""
                Else
                    Me.mystr = RuntimeHelpers.GetObjectValue(Me.ZbSer)
                End If
                result = Me.mystr
            End If
            Return result
        End Function

        Public Function SSServer(tzid As String) As Object
            Dim result As Object
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                result = "MyEndTime2005"
            Else
                Me.mystr = ""
                Me.mysql = "select ssid,jb from yx_t_khb where khid = " + tzid
                Me.mydrd = RuntimeHelpers.GetObjectValue(Me.CreateDataReader(Me.myconn, StringType.FromObject(Me.mysql)))
                If BooleanType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Read", New Object(-1) {}, Nothing, Nothing)) Then
                    If ObjectType.ObjTst(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"jb"}, Nothing, Nothing), 1, False) = 0 Then
                        Me.mystr = RuntimeHelpers.GetObjectValue(Me.JHServer(tzid, Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "item", New Object() {"ssid"}, Nothing, Nothing)))))
                    End If
                End If
                Me.myconn.Close()
                result = Me.mystr
            End If
            Return result
        End Function

        Public Function SSConn(tzid As String) As Object
            Me.mysql = String.Concat(New String() {"if exists (select 1 from yx_t_khb where khid = ", tzid, " and khid = zbid) ", "select DBServer,DBName from yx_t_khb where khid = ", tzid, " else ", "select DBServer,DBName from yx_t_khb where (select ccid + '-' from yx_t_khb where khid = (select ssid from yx_t_khb where khid=", tzid, ") ) like ccid + '-%' and jb = 1"})
            Me.mydrd = RuntimeHelpers.GetObjectValue(Me.CreateDataReader(Me.myconn, StringType.FromObject(Me.mysql)))
            If BooleanType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Read", New Object(-1) {}, Nothing, Nothing)) Then
                Me.mystr = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj("server=" + Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"DBServer"}, Nothing, Nothing))) + ";uid=", HttpContext.Current.Application("_erp_DBConn_User")), ";pwd="), HttpContext.Current.Application("_erp_DBConn_Pwd")), ";database="), Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"DBName"}, Nothing, Nothing))))
            Else
                Me.mystr = ""
            End If
            Me.myconn.Close()
            If ObjectType.ObjTst(Me.mystr, "", False) <> 0 Then
                Me.myconn = New SqlConnection(StringType.FromObject(Me.mystr))
            End If
            Return Me.myconn
        End Function

        Public Function JHServer(tzid As String, khid As String) As Object
            Me.mysql = String.Concat(New String() {"if exists (select 1 from yx_t_khb where khid = ", tzid, " and khid = zbid) select DBServer,DBName from yx_t_khb where khid = ", tzid, " else select DBServer,DBName from yx_t_khb where (select ccid + '-' from yx_t_khb where khid = ", tzid, ") like ccid + '-%' and jb = 1"})
            Me.mydrd = RuntimeHelpers.GetObjectValue(Me.CreateDataReader(Me.myconn, StringType.FromObject(Me.mysql)))
            If BooleanType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Read", New Object(-1) {}, Nothing, Nothing)) Then
                Me.mystr = String.Concat(New String() {"[", Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"DBServer"}, Nothing, Nothing))), "].", Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"DBName"}, Nothing, Nothing))), ".dbo."})
            Else
                Me.mystr = "MyEndTime2005"
            End If
            Me.myconn.Close()
            Me.mysql = String.Concat(New String() {"if exists (select 1 from yx_t_khb where khid = ", khid, " and khid = zbid) select DBServer,DBName from yx_t_khb where khid = ", khid, " else select DBServer,DBName from yx_t_khb where (select ccid + '-' from yx_t_khb where khid = ", khid, ") like ccid + '-%' and jb = 1"})
            Me.mydrd = RuntimeHelpers.GetObjectValue(Me.CreateDataReader(Me.myconn, StringType.FromObject(Me.mysql)))
            Dim o As Object
            Dim obj As Object
            If BooleanType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Read", New Object(-1) {}, Nothing, Nothing)) Then
                o = Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"DBServer"}, Nothing, Nothing)))
                obj = String.Concat(New String() {"[", Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"DBServer"}, Nothing, Nothing))), "].", Strings.Trim(StringType.FromObject(LateBinding.LateGet(Me.mydrd, Nothing, "Item", New Object() {"DBName"}, Nothing, Nothing))), ".dbo."})
            Else
                obj = "MyEndTime2005"
            End If
            Me.myconn.Close()
            If ObjectType.ObjTst(obj, Me.mystr, False) = 0 Then
                obj = ""
            Else
                If BooleanType.FromObject(ObjectType.BitAndObj(ObjectType.BitAndObj(ObjectType.ObjTst(obj, Me.ZbSer, False) <> 0, ObjectType.ObjTst(obj, "", False) <> 0), ObjectType.ObjTst(obj, "MyEndTime2005", False) <> 0)) Then
                    Me.mysql = ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj("IF Not EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = '", o), "') "), "Begin EXEC master.dbo.sp_addlinkedserver @server = '"), o), "', @srvproduct='SQL Server'; "), "EXEC sp_addlinkedsrvlogin '"), o), "', 'false', Null, "), HttpContext.Current.Application("_erp_DBConn_User")), ", "), HttpContext.Current.Application("_erp_DBConn_Pwd")), "; End")
                    Me.ExecuteSqlTrans(Me.myconn, StringType.FromObject(Me.mysql))
                End If
                If StringType.StrCmp(Strings.Left(StringType.FromObject(Me.mystr), Strings.InStr(StringType.FromObject(Me.mystr), "].", CompareMethod.Binary)), Strings.Left(StringType.FromObject(obj), Strings.InStr(StringType.FromObject(obj), "].", CompareMethod.Binary)), False) = 0 Then
                    ' The following expression was wrapped in a checked-expression
                    obj = Strings.Right(StringType.FromObject(obj), Strings.Len(RuntimeHelpers.GetObjectValue(obj)) - Strings.InStr(StringType.FromObject(obj), "].", CompareMethod.Binary) - 1)
                End If
            End If
            Return obj
        End Function

        Public Function myempty(pStr As Object) As Object
            If Information.IsDBNull(RuntimeHelpers.GetObjectValue(pStr)) Then
                pStr = " "
            End If
            Dim result As Object
            If Strings.Len(Strings.Trim(StringType.FromObject(pStr))) = 0 Or StringType.StrCmp(pStr.ToString(), "0", False) = 0 Then
                result = "&nbsp;"
            Else
                result = Strings.Trim(StringType.FromObject(pStr))
            End If
            Return result
        End Function

        Public Function myempty_cmxg(pStr As Object) As Object
            If Information.IsDBNull(RuntimeHelpers.GetObjectValue(pStr)) Then
                pStr = " "
            End If
            Dim result As Object
            If Strings.Len(Strings.Trim(StringType.FromObject(pStr))) = 0 Or StringType.StrCmp(pStr.ToString(), "0", False) = 0 Then
                result = ""
            Else
                result = Strings.Trim(StringType.FromObject(pStr))
            End If
            Return result
        End Function

        Public Function CreateDataSet(myconn As Object, mysql As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(New SqlCommand(mysql, CType(myconn, SqlConnection)) With {.CommandTimeout = 120})
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "mytable")
            Return dataSet
        End Function

        Public Function CreateDataSet(myconn As Object, parentsql As String, childsql As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(parentsql, CType(myconn, SqlConnection))
            Dim sqlCommand2 As SqlCommand = New SqlCommand(childsql, CType(myconn, SqlConnection))
            sqlCommand.CommandTimeout = 120
            sqlCommand2.CommandTimeout = 120
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim sqlDataAdapter2 As SqlDataAdapter = New SqlDataAdapter(sqlCommand2)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "parenttable")
            sqlDataAdapter2.Fill(dataSet, "childtable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, mysp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, value1 As String, value2 As String, value3 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(mysp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "mytable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, mysp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, value1 As String, value2 As String, value3 As String, value4 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(mysp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "mytable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, mysp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(mysp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "mytable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, mysp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, sqlpara6 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String, value6 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(mysp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            Dim obj6 As Object = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "mytable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, mysp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, sqlpara6 As String, sqlpara7 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String, value6 As String, value7 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(mysp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            Dim obj6 As Object = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            Dim obj7 As Object = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "mytable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, mysp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, sqlpara6 As String, sqlpara7 As String, sqlpara8 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String, value6 As String, value7 As String, value8 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(mysp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            Dim obj6 As Object = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            Dim obj7 As Object = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            Dim obj8 As Object = New SqlParameter(sqlpara8, SqlDbType.VarChar)
            LateBinding.LateSet(obj8, Nothing, "value", New Object() {value8}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj8))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "mytable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, mysp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, sqlpara6 As String, sqlpara7 As String, sqlpara8 As String, sqlpara9 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String, value6 As String, value7 As String, value8 As String, value9 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(mysp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            Dim obj6 As Object = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            Dim obj7 As Object = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            Dim obj8 As Object = New SqlParameter(sqlpara8, SqlDbType.VarChar)
            LateBinding.LateSet(obj8, Nothing, "value", New Object() {value8}, Nothing)
            Dim obj9 As Object = New SqlParameter(sqlpara9, SqlDbType.VarChar)
            LateBinding.LateSet(obj9, Nothing, "value", New Object() {value9}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj8))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj9))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "mytable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, mysp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, sqlpara6 As String, sqlpara7 As String, sqlpara8 As String, sqlpara9 As String, sqlpara10 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String, value6 As String, value7 As String, value8 As String, value9 As String, value10 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(mysp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            Dim obj6 As Object = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            Dim obj7 As Object = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            Dim obj8 As Object = New SqlParameter(sqlpara8, SqlDbType.VarChar)
            LateBinding.LateSet(obj8, Nothing, "value", New Object() {value8}, Nothing)
            Dim obj9 As Object = New SqlParameter(sqlpara9, SqlDbType.VarChar)
            LateBinding.LateSet(obj9, Nothing, "value", New Object() {value9}, Nothing)
            Dim obj10 As Object = New SqlParameter(sqlpara10, SqlDbType.VarChar)
            LateBinding.LateSet(obj10, Nothing, "value", New Object() {value10}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj8))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj9))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj10))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "mytable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, parentsp As String, childsp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, value1 As String, value2 As String, value3 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(parentsp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            Dim sqlCommand2 As SqlCommand = New SqlCommand(childsp, CType(myconn, SqlConnection))
            sqlCommand2.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            sqlCommand2.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            obj = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            obj2 = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            obj3 = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim sqlDataAdapter2 As SqlDataAdapter = New SqlDataAdapter(sqlCommand2)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "parenttable")
            sqlDataAdapter2.Fill(dataSet, "childtable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, parentsp As String, childsp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, value1 As String, value2 As String, value3 As String, value4 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(parentsp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            Dim sqlCommand2 As SqlCommand = New SqlCommand(childsp, CType(myconn, SqlConnection))
            sqlCommand2.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            sqlCommand2.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            obj = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            obj2 = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            obj3 = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            obj4 = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim sqlDataAdapter2 As SqlDataAdapter = New SqlDataAdapter(sqlCommand2)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "parenttable")
            sqlDataAdapter2.Fill(dataSet, "childtable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, parentsp As String, childsp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(parentsp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            Dim sqlCommand2 As SqlCommand = New SqlCommand(childsp, CType(myconn, SqlConnection))
            sqlCommand2.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            sqlCommand2.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            obj = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            obj2 = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            obj3 = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            obj4 = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            obj5 = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim sqlDataAdapter2 As SqlDataAdapter = New SqlDataAdapter(sqlCommand2)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "parenttable")
            sqlDataAdapter2.Fill(dataSet, "childtable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, parentsp As String, childsp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, sqlpara6 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String, value6 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(parentsp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            Dim sqlCommand2 As SqlCommand = New SqlCommand(childsp, CType(myconn, SqlConnection))
            sqlCommand2.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            sqlCommand2.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            Dim obj6 As Object = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            obj = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            obj2 = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            obj3 = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            obj4 = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            obj5 = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            obj6 = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim sqlDataAdapter2 As SqlDataAdapter = New SqlDataAdapter(sqlCommand2)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "parenttable")
            sqlDataAdapter2.Fill(dataSet, "childtable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, parentsp As String, childsp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, sqlpara6 As String, sqlpara7 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String, value6 As String, value7 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(parentsp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            Dim sqlCommand2 As SqlCommand = New SqlCommand(childsp, CType(myconn, SqlConnection))
            sqlCommand2.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            sqlCommand2.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            Dim obj6 As Object = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            Dim obj7 As Object = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            obj = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            obj2 = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            obj3 = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            obj4 = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            obj5 = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            obj6 = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            obj7 = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim sqlDataAdapter2 As SqlDataAdapter = New SqlDataAdapter(sqlCommand2)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "parenttable")
            sqlDataAdapter2.Fill(dataSet, "childtable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, parentsp As String, childsp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, sqlpara6 As String, sqlpara7 As String, sqlpara8 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String, value6 As String, value7 As String, value8 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(parentsp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            Dim sqlCommand2 As SqlCommand = New SqlCommand(childsp, CType(myconn, SqlConnection))
            sqlCommand2.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            sqlCommand2.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            Dim obj6 As Object = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            Dim obj7 As Object = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            Dim obj8 As Object = New SqlParameter(sqlpara8, SqlDbType.VarChar)
            LateBinding.LateSet(obj8, Nothing, "value", New Object() {value8}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj8))
            obj = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            obj2 = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            obj3 = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            obj4 = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            obj5 = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            obj6 = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            obj7 = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            obj8 = New SqlParameter(sqlpara8, SqlDbType.VarChar)
            LateBinding.LateSet(obj8, Nothing, "value", New Object() {value8}, Nothing)
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj8))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim sqlDataAdapter2 As SqlDataAdapter = New SqlDataAdapter(sqlCommand2)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "parenttable")
            sqlDataAdapter2.Fill(dataSet, "childtable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, parentsp As String, childsp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, sqlpara6 As String, sqlpara7 As String, sqlpara8 As String, sqlpara9 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String, value6 As String, value7 As String, value8 As String, value9 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(parentsp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            Dim sqlCommand2 As SqlCommand = New SqlCommand(childsp, CType(myconn, SqlConnection))
            sqlCommand2.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            sqlCommand2.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            Dim obj6 As Object = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            Dim obj7 As Object = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            Dim obj8 As Object = New SqlParameter(sqlpara8, SqlDbType.VarChar)
            LateBinding.LateSet(obj8, Nothing, "value", New Object() {value8}, Nothing)
            Dim obj9 As Object = New SqlParameter(sqlpara9, SqlDbType.VarChar)
            LateBinding.LateSet(obj9, Nothing, "value", New Object() {value9}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj8))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj9))
            obj = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            obj2 = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            obj3 = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            obj4 = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            obj5 = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            obj6 = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            obj7 = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            obj8 = New SqlParameter(sqlpara8, SqlDbType.VarChar)
            LateBinding.LateSet(obj8, Nothing, "value", New Object() {value8}, Nothing)
            obj9 = New SqlParameter(sqlpara9, SqlDbType.VarChar)
            LateBinding.LateSet(obj9, Nothing, "value", New Object() {value9}, Nothing)
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj8))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj9))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim sqlDataAdapter2 As SqlDataAdapter = New SqlDataAdapter(sqlCommand2)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "parenttable")
            sqlDataAdapter2.Fill(dataSet, "childtable")
            Return dataSet
        End Function

        Public Function CreateDataSet_up(myconn As Object, parentsp As String, childsp As String, sqlpara1 As String, sqlpara2 As String, sqlpara3 As String, sqlpara4 As String, sqlpara5 As String, sqlpara6 As String, sqlpara7 As String, sqlpara8 As String, sqlpara9 As String, sqlpara10 As String, value1 As String, value2 As String, value3 As String, value4 As String, value5 As String, value6 As String, value7 As String, value8 As String, value9 As String, value10 As String) As DataSet
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(parentsp, CType(myconn, SqlConnection))
            sqlCommand.CommandType = CommandType.StoredProcedure
            Dim sqlCommand2 As SqlCommand = New SqlCommand(childsp, CType(myconn, SqlConnection))
            sqlCommand2.CommandType = CommandType.StoredProcedure
            sqlCommand.CommandTimeout = 120
            sqlCommand2.CommandTimeout = 120
            Dim obj As Object = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            Dim obj2 As Object = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            Dim obj3 As Object = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            Dim obj4 As Object = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            Dim obj5 As Object = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            Dim obj6 As Object = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            Dim obj7 As Object = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            Dim obj8 As Object = New SqlParameter(sqlpara8, SqlDbType.VarChar)
            LateBinding.LateSet(obj8, Nothing, "value", New Object() {value8}, Nothing)
            Dim obj9 As Object = New SqlParameter(sqlpara9, SqlDbType.VarChar)
            LateBinding.LateSet(obj9, Nothing, "value", New Object() {value9}, Nothing)
            Dim obj10 As Object = New SqlParameter(sqlpara10, SqlDbType.VarChar)
            LateBinding.LateSet(obj10, Nothing, "value", New Object() {value10}, Nothing)
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj8))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj9))
            sqlCommand.Parameters.Add(RuntimeHelpers.GetObjectValue(obj10))
            obj = New SqlParameter(sqlpara1, SqlDbType.VarChar)
            LateBinding.LateSet(obj, Nothing, "value", New Object() {value1}, Nothing)
            obj2 = New SqlParameter(sqlpara2, SqlDbType.VarChar)
            LateBinding.LateSet(obj2, Nothing, "value", New Object() {value2}, Nothing)
            obj3 = New SqlParameter(sqlpara3, SqlDbType.VarChar)
            LateBinding.LateSet(obj3, Nothing, "value", New Object() {value3}, Nothing)
            obj4 = New SqlParameter(sqlpara4, SqlDbType.VarChar)
            LateBinding.LateSet(obj4, Nothing, "value", New Object() {value4}, Nothing)
            obj5 = New SqlParameter(sqlpara5, SqlDbType.VarChar)
            LateBinding.LateSet(obj5, Nothing, "value", New Object() {value5}, Nothing)
            obj6 = New SqlParameter(sqlpara6, SqlDbType.VarChar)
            LateBinding.LateSet(obj6, Nothing, "value", New Object() {value6}, Nothing)
            obj7 = New SqlParameter(sqlpara7, SqlDbType.VarChar)
            LateBinding.LateSet(obj7, Nothing, "value", New Object() {value7}, Nothing)
            obj8 = New SqlParameter(sqlpara8, SqlDbType.VarChar)
            LateBinding.LateSet(obj8, Nothing, "value", New Object() {value8}, Nothing)
            obj9 = New SqlParameter(sqlpara9, SqlDbType.VarChar)
            LateBinding.LateSet(obj9, Nothing, "value", New Object() {value9}, Nothing)
            obj10 = New SqlParameter(sqlpara10, SqlDbType.VarChar)
            LateBinding.LateSet(obj10, Nothing, "value", New Object() {value10}, Nothing)
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj2))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj3))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj4))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj5))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj6))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj7))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj8))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj9))
            sqlCommand2.Parameters.Add(RuntimeHelpers.GetObjectValue(obj10))
            Dim sqlDataAdapter As SqlDataAdapter = New SqlDataAdapter(sqlCommand)
            Dim sqlDataAdapter2 As SqlDataAdapter = New SqlDataAdapter(sqlCommand2)
            Dim dataSet As DataSet = New DataSet()
            sqlDataAdapter.Fill(dataSet, "parenttable")
            sqlDataAdapter2.Fill(dataSet, "childtable")
            Return dataSet
        End Function

        Public Function ExecuteSql(myconn As Object, mysql As String) As Object
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(mysql, CType(myconn, SqlConnection))
            sqlCommand.Connection.Close()
            sqlCommand.Connection.Open()
            sqlCommand.ExecuteNonQuery()
            Dim result As Object
            Return result
        End Function

        Public Function ExecuteSqlTrans(myconn As Object, mysql As String) As Object
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            LateBinding.LateCall(myconn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            LateBinding.LateCall(myconn, Nothing, "Open", New Object(-1) {}, Nothing, Nothing)
            Dim sqlCommand As SqlCommand = CType(LateBinding.LateGet(myconn, Nothing, "CreateCommand", New Object(-1) {}, Nothing, Nothing), SqlCommand)
            Dim sqlTransaction As SqlTransaction = CType(LateBinding.LateGet(myconn, Nothing, "BeginTransaction", New Object(-1) {}, Nothing, Nothing), SqlTransaction)
            sqlCommand.Connection = CType(myconn, SqlConnection)
            sqlCommand.Transaction = sqlTransaction
            Dim result As Object
            Try
                sqlCommand.CommandText = mysql
                sqlCommand.ExecuteNonQuery()
                sqlTransaction.Commit()
                result = ChrW(25968) & ChrW(25454) & ChrW(22788) & ChrW(29702) & ChrW(25104) & ChrW(21151) & "!"
            Catch ex As Exception
                sqlTransaction.Rollback()
                result = ChrW(25968) & ChrW(25454) & ChrW(22788) & ChrW(29702) & ChrW(22833) & ChrW(36133) & "," & ChrW(35831) & ChrW(37325) & ChrW(35797) & "!"
            Finally
                sqlTransaction.Dispose()
                LateBinding.LateCall(myconn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            End Try
            Return result
        End Function

        Public Function ExecuteSqlTransRtn(myconn As Object, mysql As String) As Object
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            LateBinding.LateCall(myconn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            LateBinding.LateCall(myconn, Nothing, "Open", New Object(-1) {}, Nothing, Nothing)
            Dim sqlCommand As SqlCommand = CType(LateBinding.LateGet(myconn, Nothing, "CreateCommand", New Object(-1) {}, Nothing, Nothing), SqlCommand)
            Dim sqlTransaction As SqlTransaction = CType(LateBinding.LateGet(myconn, Nothing, "BeginTransaction", New Object(-1) {}, Nothing, Nothing), SqlTransaction)
            sqlCommand.Connection = CType(myconn, SqlConnection)
            sqlCommand.Transaction = sqlTransaction
            Dim result As Object
            Try
                sqlCommand.CommandText = mysql
                sqlCommand.ExecuteNonQuery()
                sqlTransaction.Commit()
                result = 0
            Catch ex As Exception
                sqlTransaction.Rollback()
                result = -1
            Finally
                sqlTransaction.Dispose()
                LateBinding.LateCall(myconn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            End Try
            Return result
        End Function

        Public Function ExecuteSqlTransID(myconn As Object, mysql As String, ByRef ErrText As String) As Object
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            LateBinding.LateCall(myconn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            LateBinding.LateCall(myconn, Nothing, "Open", New Object(-1) {}, Nothing, Nothing)
            Dim sqlCommand As SqlCommand = CType(LateBinding.LateGet(myconn, Nothing, "CreateCommand", New Object(-1) {}, Nothing, Nothing), SqlCommand)
            Dim sqlTransaction As SqlTransaction = CType(LateBinding.LateGet(myconn, Nothing, "BeginTransaction", New Object(-1) {}, Nothing, Nothing), SqlTransaction)
            sqlCommand.Connection = CType(myconn, SqlConnection)
            sqlCommand.Transaction = sqlTransaction
            Dim result As Object
            Try
                sqlCommand.CommandText = mysql
                Dim objectValue As Object = RuntimeHelpers.GetObjectValue(sqlCommand.ExecuteScalar())
                sqlTransaction.Commit()
                result = RuntimeHelpers.GetObjectValue(objectValue)
                ErrText = ""
            Catch ex As Exception
                sqlTransaction.Rollback()
                result = 0
                ErrText = ex.ToString()
            Finally
            End Try
            LateBinding.LateCall(myconn, Nothing, "close", New Object(-1) {}, Nothing, Nothing)
            Return result
        End Function

        Public Function ExecuteSqlId(myconn As Object, mysql As String) As Object
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(mysql, CType(myconn, SqlConnection))
            sqlCommand.Connection.Close()
            sqlCommand.Connection.Open()
            sqlCommand.ExecuteNonQuery()
            Return sqlCommand.ExecuteScalar().ToString()
        End Function

        Public Function ReturnId(myconn As Object, mysql As String) As Object
            If ObjectType.ObjTst(Me.MyEnd(), 0, False) = 0 Then
                myconn = "MyEndTime2005"
            End If
            Dim sqlCommand As SqlCommand = New SqlCommand(mysql, CType(myconn, SqlConnection))
            sqlCommand.Connection.Close()
            sqlCommand.Connection.Open()
            sqlCommand.ExecuteNonQuery()
            Return sqlCommand.ExecuteScalar()
        End Function

        Public Function CreateDataReader(myconn As Object, mysql As String) As Object
            Dim sqlCommand As SqlCommand = New SqlCommand(mysql, CType(myconn, SqlConnection))
            sqlCommand.CommandTimeout = 120
            sqlCommand.Connection.Close()
            sqlCommand.Connection.Open()
            Return sqlCommand.ExecuteReader()
        End Function

        Public Function mylog(myconn As Object, user_ip As Object, user_asp As Object, user_name As Object, user_log As Object) As Object
            Dim value As Object = DateTime.Now
            Dim obj As Object = "insert into t_user_log (rq,time,user_name,user_ip,user_asp,bz) values ('"
        obj = ObjectType.AddObj(obj, ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(StringType.FromObject(value) + "','" + StringType.FromDate(DateAndTime.TimeOfDay) + "','", user_name), "','"), user_ip), "','"), user_asp), "','"), user_log + "total"), "')"))
        Me.ExecuteSql(RuntimeHelpers.GetObjectValue(myconn), StringType.FromObject(obj))
            Dim result As Object
            Return result
        End Function

        Public Function mylog(myconn As Object, user_ip As Object, user_asp As Object, user_name As Object, user_log As Object, tzid As Object, userid As Object, menuid As Object) As Object
            Dim value As Object = DateTime.Now
            Dim obj As Object = "insert into t_user_log (rq,time,user_name,user_ip,user_asp,bz,tzid,userid,menuid) values ('"
            obj = ObjectType.AddObj(obj, ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(StringType.FromObject(value) + "','" + StringType.FromDate(DateAndTime.TimeOfDay) + "','", user_name), "','"), user_ip), "','"), user_asp), "','"), user_log), "',"), tzid), ","), userid), ",isnull("), menuid), ",0))"))
            Me.ExecuteSql(RuntimeHelpers.GetObjectValue(myconn), StringType.FromObject(obj))
            Dim result As Object
            Return result
        End Function

        Public Function close(myconn As Object) As Object
            LateBinding.LateCall(myconn, Nothing, "dispose", New Object(-1) {}, Nothing, Nothing)
            Dim result As Object
            Return result
        End Function

        Public Function CreateDataSet_odbc(mysql As String) As DataSet
            Dim odbcConnection As OdbcConnection = New OdbcConnection("DSN=Llzw_vfp;uid=;pwd=;")
            Dim odbcDataAdapter As OdbcDataAdapter = New OdbcDataAdapter()
            Dim dataSet As DataSet = New DataSet()
            odbcConnection.Open()
            odbcDataAdapter.SelectCommand = New OdbcCommand(mysql, odbcConnection)
            odbcDataAdapter.Fill(dataSet)
            odbcConnection.Dispose()
            Return dataSet
        End Function

        Public Function ExecuteSql_odbc(mysql As String) As Object
            Dim odbcConnection As OdbcConnection = New OdbcConnection("DSN=Llzw_vfp;uid=;pwd=;")
            odbcConnection.Open()
            Dim odbcCommand As OdbcCommand = New OdbcCommand(mysql, odbcConnection)
            odbcCommand.ExecuteNonQuery()
            odbcConnection.Dispose()
            Dim result As Object
            Return result
        End Function

        Public Function CreateDataSet_vfp_cl(mysql As String) As DataSet
            Dim odbcConnection As OdbcConnection = New OdbcConnection("DSN=Llcl_vfp;uid=;pwd=;")
            Dim odbcDataAdapter As OdbcDataAdapter = New OdbcDataAdapter()
            Dim dataSet As DataSet = New DataSet()
            odbcConnection.Open()
            odbcDataAdapter.SelectCommand = New OdbcCommand(mysql, odbcConnection)
            odbcDataAdapter.Fill(dataSet)
            odbcConnection.Dispose()
            Return dataSet
        End Function

        Public Function ExecuteSql_vfp_cl(mysql As String) As Object
            Dim odbcConnection As OdbcConnection = New OdbcConnection("DSN=Llcl_vfp;uid=;pwd=;")
            odbcConnection.Open()
            Dim odbcCommand As OdbcCommand = New OdbcCommand(mysql, odbcConnection)
            odbcCommand.ExecuteNonQuery()
            odbcConnection.Dispose()
            Dim result As Object
            Return result
        End Function

        Public Function ChineseFormat(n As Object) As Object
            Dim text As String = Strings.Format(RuntimeHelpers.GetObjectValue(Conversion.Int(ObjectType.MulObj(n, 100))), "")
            Dim text2 As String = ""
            ' The following expression was wrapped in a checked-statement
            For i As Integer = Strings.Len(text) To 1 Step -1
                Dim text3 As String = Strings.Mid(text, i, 1)
                If StringType.StrCmp(text3, "0", False) = 0 Then
                    Dim num As Integer = Strings.Len(text) - i
                    If num <= 1 Then
                        text2 = ChrW(38646) + Strings.Mid(ChrW(20998) & ChrW(35282) & ChrW(20803) & ChrW(25342) & ChrW(20336) & ChrW(20191) & ChrW(19975) & ChrW(25342) & ChrW(20336) & ChrW(20191) & ChrW(20159) & ChrW(25342) & ChrW(20336) & ChrW(20191) & ChrW(19975), Strings.Len(text) - i + 1, 1) + text2
                    ElseIf num = 2 Then
                        text2 = ChrW(20803) + text2
                    ElseIf num = 6 Then
                        text2 = ChrW(19975) + text2
                    ElseIf num = 10 Then
                        If StringType.StrCmp(Strings.Left(text2, 1), ChrW(19975), False) = 0 Then
                            text2 = Strings.Right(text2, Strings.Len(text2) - 1)
                        End If
                        text2 = ChrW(20159) + text2
                    ElseIf StringType.StrCmp(Strings.Mid(text, i + 1, 1), "0", False) <> 0 Then
                        text2 = ChrW(38646) + text2
                    End If
                Else
                    ' The following expression was wrapped in a unchecked-expression
                    text2 = Strings.Mid(ChrW(38646) & ChrW(22777) & ChrW(36144) & ChrW(21441) & ChrW(32902) & ChrW(20237) & ChrW(38470) & ChrW(26578) & ChrW(25420) & ChrW(29590), CInt(Math.Round(Conversion.Val(text3) + 1.0)), 1) + Strings.Mid(ChrW(20998) & ChrW(35282) & ChrW(20803) & ChrW(25342) & ChrW(20336) & ChrW(20191) & ChrW(19975) & ChrW(25342) & ChrW(20336) & ChrW(20191) & ChrW(20159) & ChrW(25342) & ChrW(20336) & ChrW(20191) & ChrW(19975), Strings.Len(text) - i + 1, 1) + text2
                End If
            Next
            Return text2
        End Function

        Public Function FileFieldSelected(FileField As Object) As Boolean
            Return LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing) IsNot Nothing AndAlso ObjectType.ObjTst(LateBinding.LateGet(LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing), Nothing, "ContentLength", New Object(-1) {}, Nothing, Nothing), 0, False) <> 0
        End Function

        Public Function GetByteArrayFromFileField(FileField As Object) As Byte()
            Dim result As Byte()
            If Me.FileFieldSelected(RuntimeHelpers.GetObjectValue(FileField)) Then
                Dim num As Integer = IntegerType.FromObject(LateBinding.LateGet(LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing), Nothing, "ContentLength", New Object(-1) {}, Nothing, Nothing))
                ' The following expression was wrapped in a checked-expression
                Dim array As Byte() = New Byte(num + 1 - 1) {}
                Dim stream As Stream = CType(LateBinding.LateGet(LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing), Nothing, "InputStream", New Object(-1) {}, Nothing, Nothing), Stream)
                stream.Read(array, 0, num)
                result = array
            End If
            Return result
        End Function

        Public Function FileFieldType(FileField As Object) As String
            Dim result As String
            If LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing) IsNot Nothing Then
                result = StringType.FromObject(LateBinding.LateGet(LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing), Nothing, "ContentType", New Object(-1) {}, Nothing, Nothing))
            End If
            Return result
        End Function

        Public Function FileFieldLength(FileField As Object) As Integer
            Dim result As Integer
            If LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing) IsNot Nothing Then
                result = IntegerType.FromObject(LateBinding.LateGet(LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing), Nothing, "ContentLength", New Object(-1) {}, Nothing, Nothing))
            End If
            Return result
        End Function

        Public Function FileFieldFilename(FileField As Object) As String
            Dim result As String
            If LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing) IsNot Nothing Then
                result = Strings.Replace(StringType.FromObject(LateBinding.LateGet(LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing), Nothing, "FileName", New Object(-1) {}, Nothing, Nothing)), Strings.StrReverse(Strings.Mid(Strings.StrReverse(StringType.FromObject(LateBinding.LateGet(LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing), Nothing, "FileName", New Object(-1) {}, Nothing, Nothing))), Strings.InStr(1, Strings.StrReverse(StringType.FromObject(LateBinding.LateGet(LateBinding.LateGet(FileField, Nothing, "PostedFile", New Object(-1) {}, Nothing, Nothing), Nothing, "FileName", New Object(-1) {}, Nothing, Nothing))), "\", CompareMethod.Binary))), "", 1, -1, CompareMethod.Binary)
            End If
            Return result
        End Function

        Private myconn As SqlConnection

        Private mysql As Object

        Private mydrd As Object

        Private mystr As Object

        Private ZbSer As Object
    End Class
