<html>
<head>
	<title>到货通知导成总部入库处理</title>
</head>
 
<form id="Form1" name="Form1" method="post" runat=server>
	
    </form>

<script language="vb" runat="server">

    dim str_sql,str_tj,parentsql,childsql,str_sphh,tzid,zbid,djlx,lydjlx,bgcolor
    dim zb_dhbh,zb_spdlid,zb_khid,zb_je,zb_djzt,zb_bz ,khid,zb_zdr
    dim mydrd,myds,mydscm,jls,jlscm,i,j,cmdm,zt,cbdjzt,tmp_kz

    Dim cm(93),cmxg(30)

    Sub page_load(Source as object,E As EventArgs)
        '??????????????////
        tzid=Session("userssid")
        zbid=session("zbid")
        zb_zdr=session("username")
        Dim lbdll = New lbclass.lbdll
        Dim myconn = New Data.SqlClient.SqlConnection("server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft ")
        lbdll.mylog(myconn, "", "", "user", "tzid-" + tzid + "完工入库导成出库保存成功：")
    End Sub


</script>
