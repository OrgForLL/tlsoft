
<script language="vb" runat="server">

    Sub Myok(S as object,E As EventArgs)

        Dim lbdll As New lbclass.lbdll()
        'Dim mylink = lbdll.MyDataLink("1")
        Dim myconn As New Data.SqlClient.SqlConnection()
        myconn.ConnectionString = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft "

        Dim str_sql = "SET NOCOUNT ON;DECLARE @id int;DECLARE @mxid int;DECLARE @maxdjh varchar(6);select @maxdjh=convert(varchar(6),isnull(max(djh),'100000')+1) from yx_t_kcdjb where tzid=1 and year(rq)=year('2017-12-11') and month(rq)=month('2017-12-11') and djlx=141;insert into yx_t_kcdjb (tzid,dhbh,djlx,djlb,djbs,djh,rq,khid,shdwid,ckid,dfckid,je,cjje,skje,kpje,zdr,xgr,shr,qrr,jyr,zdrq,xgrq,shrq,qrrq,shbs,qrbs,shgwid,pzzdr,pzzdbs,pzdqrq,pzkz,dycs,djzt,zzbs,zzrq,zzr,lydjid,lydjlx,bz,spdlid,gbk,cgdjh,zmdid,htddid) select 1,'201731',141,2037,1,@maxdjh,'2017-12-11',a.khid,0,1239,0,0,0,0,0,'张茂洪','','','','',getdate(),'','','',0,0,2,'',0,'','',0,0,0,'','',a.id,a.djlx, '到货通知转成总部入库',a.spdlid,'','201106100182','117','9095' from yx_t_dddjb a where a.id=954183;SET @id=SCOPE_IDENTITY();insert into yx_t_kcdjmx (id,sphh,shdm,gc,scgzh,pc,sl,js,zxid,bj,zks,dj,je,cjje,zzsl,cbbj,cbje,hscbje,rkjs,rksl,jysl,lymxid,djzt,hsje,bhsje) values (@id,'1DPM5011S','','DZ1','1DPM5011S-0101','1',1,0,0,3599.00,1.00,84.48,84.48*1,0,17.00,298.15,1*298.15,0,0,0,0,0,0,84.48,72.21);SET @mxid=SCOPE_IDENTITY();insert into yx_t_kcdjcmmx(id,mxid,cmdm,sl0)  values(@id,@mxid,'cm24',1);update yx_t_kcdjb set mxjls=1,je=isnull((select sum(je) from yx_t_kcdjmx where id=@id),0) where id=@id;Exec yx_up_cgrkd_bc @id;select @id"
        Dim ErrText As String
        Dim zt = lbdll.ExecuteSqlTransID(myconn, str_sql, ErrText)

    End Sub
</script>
<html>
    <body>
        <form runat="server">
<asp:Button id="Btn_save" class="blk" runat="server" Text=" 保存 " OnClick="Myok"  tabIndex="98"></asp:Button>
        </form>
    </body>
</html>

