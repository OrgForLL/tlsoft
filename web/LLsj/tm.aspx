<!DOCTYPE html>
<%@ Page Language="vb" Debug="true"%>
<%@Import Namespace="System.Data"%>
<%@Import Namespace="System.Data.SqlClient"%>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0;" name="viewport">
<link rel="stylesheet" href="js/jquery.mobile-1.3.2.min.css">
<script src="js/jquery-1.8.3.min.js"></script>
<script src="js/jquery.mobile-1.3.2.min.js"></script>
<script type="text/javascript" >

    var winHeight;
    var winWidth;

    if (window.innerWidth)
        winWidth = window.innerWidth;
    else if ((document.body) && (document.body.clientWidth))
        winWidth = document.body.clientWidth;
    // 获取窗口高度 
    if (window.innerHeight)
        winHeight = window.innerHeight;
    else if ((document.body) && (document.body.clientHeight))
        winHeight = document.body.clientHeight;
    // 通过深入 Document 内部对 body 进行检测，获取窗口大小 
    if (document.documentElement && document.documentElement.clientHeight && document.documentElement.clientWidth) {
        winHeight = document.documentElement.clientHeight;
        winWidth = document.documentElement.clientWidth;
    }

    window.onload = function () {
        // 先获取想要改变的所有图片对象（集合） 
        var obj = document.getElementById("content").getElementsByTagName("img");
        for (var i = 0; i < obj.length; i++) {
            var width = obj[i].width;
            // 判断图片宽度是否大于屏幕宽度 
            if (width > winWidth) {
                obj[i].width = winWidth-20;
            }
        }
    }
    //self.moveTo(0, 0); //移动窗口位置到(0,0)位置
    //self.resizeTo(screen.availWidth, screen.availHeight); //控制网页窗口大小
</script>
</head>
<body leftmargin="0" topmargin="0">
<style>
    iimg{ 
        border:0; 
        margin:0; 
        padding:0; 
        max-width:1024px; 
        width:expression_r(this.width>1024?"1024px":this.width); 
        max-height:768px; 
        height:expression_r(this.height>768?"768px":this.height); 
    }

</style>
<form method="POST" id="MyForm" name="MyForm">
<!--#include file="../TLinc/inc_Load_public.aspx"-->
<% 
    'Dim strBase64 As String = "2XXC0081Y"
    'Dim b As Byte() = System.Text.Encoding.Default.GetBytes(strBase64)
    'strBase64 = Convert.ToBase64String(b)
    'Response.Write(strBase64)
    'response.end
    Dim lbdll As New lbclass.lbdll
    Dim sphh, spmc, tp, mlcf, khrq, cpmd, urlAddress, bq, id, ids, str_sql, spid As String
    Dim sql As String
    Dim jl As Integer
    dim mydrd 
    
    id = Request.QueryString("id")
    'Dim c As Byte() = Convert.FromBase64String(sphh)
    'sphh = System.Text.Encoding.Default.GetString(c)    

    ids = LCase(id)
    If id.Length = 0 or instr(ids,"update")>0 or instr(ids,"insert")>0 or instr(ids,"delete")>0 Then
        response.write("参数传入有问题！")
        response.end
    End If

    str_sql="SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SET NOCOUNT ON; select dbo.f_dbpwd('" + id + "') as spid;"
	mydrd=lbdll.CreateDataReader(myconn,str_sql)
	if mydrd.read() then
		spid=mydrd.item("spid").tostring()
	end if 
	myconn.close()

    sphh = left(spid, spid.length - instr(spid, right(spid, 9)) + 1)
    

    sql  = " Select  yp.bq,a.sphh,a.yphh,a.spmc,a.kfbh,b.urlAddress,case b.tableid when a.id then '<a rel=productGroup href='+b.urlAddress+'>图片</a>' else '无' end tp,c.mlcf,c.khrq,c.cpmd "
    sql += "From yx_t_spdmb a INNER join "
    sql += " yx_t_ypdmb yp on a.sphh=yp.sphh INNER join "
    sql += "t_uploadfile b on a.id=b.tableid and b.groupid=8 left outer join "
    sql += "yx_t_cpinfo c on a.sphh=c.sphh "
    sql += "Where a.tzid=1 and a.sphh='" + sphh + "' "
    myds = lbdll.CreateDataSet(myconn, sql)
    jl = myds.tables(0).Rows.Count
    If jl = "0" Then
        spmc = ""
        bq = ""
        tp = ""
        mlcf = ""
        khrq = ""
        cpmd = ""
        urlAddress = ""
    Else
        spmc = myds.tables(0).Rows(0).item("spmc").toString()
        bq = myds.tables(0).Rows(0).item("bq").toString()
        tp = myds.tables(0).Rows(0).item("tp").toString()
        mlcf = myds.tables(0).Rows(0).item("mlcf").toString()
        khrq = myds.tables(0).Rows(0).item("khrq").toString()
        cpmd = myds.tables(0).Rows(0).item("cpmd").toString()
        urlAddress = myds.tables(0).Rows(0).item("urlAddress").toString()
    End If
    
    
%>
    <div data-role="header">
        <h1>利郎(中国)有限公司</h1>
    </div>
    <div data-role="footer">
        <h1>商品货号:<%= sphh%></h1>
    </div>
    <div data-role="footer">
        <h1>商品名称:<%= spmc%></h1>
    </div>
    <div data-role="footer">
        <h1>标签:<%= bq%></h1>
    </div>
    <!--
<table height="30" border="0" cellspacing="0" cellpadding="0" width="100%"  height="100%" bgColor="#282828">
    <tr >
        <td width = "180" align = "left" style="FONT-FAMILY: 宋体; COLOR: #eeeeee; FONT-SIZE: 16px">
            商品货号:<%= sphh%>
        </td>
    </tr>
    <tr>
        <td width = "250" align = "left" style="FONT-FAMILY: 宋体; COLOR: #eeeeee; FONT-SIZE: 16px">
            商品名称:<%= spmc%>
        </td>
    </tr>
    <tr>
        <td width = "150" align = "left" style="FONT-FAMILY: 宋体; COLOR: #eeeeee; FONT-SIZE: 16px">
            标签:<%= bq%>
        </td>
        <td>&nbsp;</td>
    </tr>
</table>
-->

<table border="0" cellspacing="0" cellpadding="0"  height="100%" >
<tr>
    <td >
        <table id="content" border="0" cellspacing="0" cellpadding="0" width="100%" height="100%" >
            <tr>
                <td align = "left" style="FONT-FAMILY: 宋体;  FONT-SIZE: 18px"><img src=<%=urlAddress %> ></td>
            </tr>
        </table>
    </td>
</tr>
</table>
</div>
<!--
<table border="0" cellspacing="0" cellpadding="0"  height="100%" >
<tr>
    <td width = "654" colspan="2">
    </td>
</tr>
</table>
-->
</form>
</body>
</html>
