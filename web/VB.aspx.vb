
Partial Class VB
    Inherits System.Web.UI.Page


    Private Sub VB_Init(sender As Object, e As EventArgs) Handles Me.Init
        Dim str As String = "delete t_cx_tmp where dxlx = 'wg' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wg',12742,16733);delete t_cx_tmp where dxlx = 'wd' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wd',12742,2318309);||||delete t_cx_tmp where dxlx = 'wg' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wg',12742,16733);delete t_cx_tmp where dxlx = 'wd' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wd',12742,2316177);||||delete t_cx_tmp where dxlx = 'wg' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wg',12742,16733);delete t_cx_tmp where dxlx = 'wd' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wd',12742,2317327);insert into t_cx_tmp(dxlx,userid,dxid) values('wd',12742,2317366);"

        Dim s As String() = Split(str, "||||")

    End Sub

    Private Sub VB_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim str As String = "delete t_cx_tmp where dxlx = 'wg' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wg',12742,16733);delete t_cx_tmp where dxlx = 'wd' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wd',12742,2318309);||||delete t_cx_tmp where dxlx = 'wg' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wg',12742,16733);delete t_cx_tmp where dxlx = 'wd' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wd',12742,2316177);||||delete t_cx_tmp where dxlx = 'wg' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wg',12742,16733);delete t_cx_tmp where dxlx = 'wd' and userid = 12742;insert into t_cx_tmp(dxlx,userid,dxid) values('wd',12742,2317327);insert into t_cx_tmp(dxlx,userid,dxid) values('wd',12742,2317366);"
    End Sub
End Class
