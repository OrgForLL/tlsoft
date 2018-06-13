
Imports System.Runtime.CompilerServices
Imports Microsoft.VisualBasic.CompilerServices

Partial Class tl_yf_Default2
    Inherits System.Web.UI.Page

    Private Sub form1_Load(sender As Object, e As EventArgs) Handles form1.Load
        Dim test = "abc eaf afasf"
        test = test.Replace(" ", "")
        Dim abc = Context.Server.MapPath("../photo/sygzb_pdf/_0@131593299401353442.pdf")
        Console.Write(abc)
        Dim i = 0
        Dim arr(1) As String
        arr(0) = "name"
        arr(1) = "age"
        For Each key As String In arr
            Dim crlhx() As String
            crlhx = Nothing

            Dim tmpi As Integer = 0
            If key = "name" Then
                For Each b As String In arr
                    ReDim Preserve crlhx(tmpi)
                    crlhx(tmpi) = b
                    tmpi = tmpi + 1
                Next
            End If
            Response.Write(crlhx.ToString)
        Next


    End Sub

    'Public Function mylog(myconn As Object, user_ip As Object, user_asp As Object, user_name As Object, user_log As Object) As Object
    '    Dim value As Object = DateTime.Now
    '    Dim obj As Object = "insert into t_user_log (rq,time,user_name,user_ip,user_asp,bz) values ('"
    '    obj = ObjectType.AddObj(obj, ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(ObjectType.AddObj(StringType.FromObject(value) + "','" + StringType.FromDate(DateAndTime.TimeOfDay) + "','", user_name + "123"), "','"), user_ip), "','"), user_asp), "','"), user_log), "')"))
    '    Me.ExecuteSql(RuntimeHelpers.GetObjectValue(myconn), StringType.FromObject(obj))
    '    Dim result As Object
    '    Return result
    'End Function
End Class
