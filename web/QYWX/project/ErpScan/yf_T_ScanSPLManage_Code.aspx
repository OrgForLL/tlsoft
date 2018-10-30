<%@ Page Language="VB" Debug="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%
    '模块涉及出库确认，归还管理，包括以下几种情况(也是程序处理的优先逻辑)：
    '1.已开出库单未确认：进行出库单确认操作
    '2.已开归还单未确认：进行归还单确认操作
    '3.出库单已确认，未开归还单：进行归还单生成以及确认操作
    '4.未做出库单：进行出库单生成以及确认操作
    Dim sphh As String = ""
    Dim username As String = ""
    Dim mytype As String = ""
    Dim RetV As String = ""
    Dim htzinfoDs As Data.DataSet
    sphh = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("sphh"))).ToString()
    username = Trim(System.Web.HttpUtility.UrlDecode(Request.QueryString("username"))).ToString()
    'sphh = "1DPM5011S180100100"
    'username="张勇民"
    If sphh.Length = 0 Then
        Response.Write("未传入信息")
        Response.End()
    End If
		
    Dim MySql As String = ""
    Dim OAConnStr As String = clsConfig.GetConfigValue("OAConnStr")
    Dim dal As LiLanzDALForXLM = New LiLanzDALForXLM(OAConnStr)
		
    MySql = "  declare @sphh varchar(12); declare @rybh varchar(12); declare @id int; Declare @maxdjh varchar(10);Declare @shgwid int;Declare @mxid int; "
    '扫吊牌：传进的sphh是唯一码
    'MySql += " select top 1 @sphh=sphh from yx_v_kcdjmx a inner join YX_T_Kcdjspid b on a.id=b.id where b.spid='" + sphh + "' and a.djlx=141; "
    '扫洗水唛 传进的sphh是样号
    MySql += " select top 1 @sphh=sphh from yx_t_spdmb where yphh='" + sphh + "'; "
    MySql += " SELECT @rybh=a.rybh FROM rs_v_ryxxzhcx a left outer join rs_t_bmdmb b on a.bmssid=b.id  WHERE a.bmty=0 AND a.tzid=1 AND a.rzzk IN ('01','99') and a.xm='" + username + "'; "
    '1.存在出库未确认
    MySql += " if exists(select sphh from yx_v_kcdjmx where sphh=@sphh and djzt=0 and djlx=118 and qrbs=0) " 'qrbs:确认1，未确认0；djzt 是否生成归还单：0未生成，2已生成
    MySql += " begin "
    MySql += "    select top 1 @id=id from yx_v_kcdjmx a where sphh=@sphh and djzt=0 and djlx=118 and qrbs=0 ; "
    MySql += "    update a set a.qrbs=1,a.qrr='" + username + "',a.qrrq=getdate() from yx_t_kcdjb a where id=@id "
    MySql += "    update a set a.rksl=a.sl from yx_t_kcdjmx a where id=@id "
    MySql += "    update a set rksl0=sl0 from yx_t_kcdjcmmx a where id=@id "
    MySql += "    select '出库确认成功' as RetV"
    MySql += " end "
    '2.存在归还单已生成未确认
    MySql += " else if exists(select sphh from yx_v_kcdjmx where sphh=@sphh and shbs=1 and djlx=119 and qrbs=0) " 'qrbs:确认1，未确认0；
    MySql += " begin "
    MySql += "    select top 1 @id=id from yx_v_kcdjmx a where sphh=@sphh and shbs=1 and djlx=119 and qrbs=00 ; "
    MySql += "    update a set a.qrbs=1,a.qrr='" + username + "',a.qrrq=getdate() from yx_t_kcdjb a where id=@id "
    MySql += "    update a set a.rksl=a.sl from yx_t_kcdjmx a where id=@id "
    MySql += "    update a set rksl0=sl0 from yx_t_kcdjcmmx a where id=@id "
    MySql += "    select '归还成功' as RetV"
    MySql += " end "
    '3.出库单已确认，未开归还单：进行归还单生成以及确认操作
    MySql += " else if exists(select sphh from yx_v_kcdjmx where sphh=@sphh and djzt=0 and djlx=118 and qrbs=1) "
    MySql += " begin "
    MySql += "    select @maxdjh = isnull(max(djh)+1,'100001') from yx_t_kcdjb where tzid=1 and djlx=119 and convert(varchar(6),rq,112)=convert(varchar(6),getdate(),112);   "
    '插入主表
    MySql += "    insert into yx_t_kcdjb(tzid,dhbh,djlx,djlb,djbs,djh,rq,khid,shdwid,ckid,dfckid,je,cjje,skje,kpje,zdr,shr,qrr,jyr,zdrq,shrq,qrrq,shbs,qrbs,shgwid,pzzdr,pzzdbs,pzdqrq,pzkz,dycs,djzt,zzbs,zzrq,zzr,lydjid,bz,spdlid,qsr) "
    MySql += "    select top 1 1,'',119,2408,1,@maxdjh,getdate(),11038,0,10660,@rybh,0,0,0,0,'" + username + "','" + username + "','" + username + "','',getdate(),getdate(),getdate(),1,1,0,'',0,'','',0,0,0,'','',id,'手机扫描归还',1166,'" + username + "' "
    MySql += "    from yx_v_kcdjmx where sphh=@sphh and djzt=0 and djlx=118"
    MySql += "    SET @id=SCOPE_IDENTITY(); "
    '插入明细
    MySql += "    insert yx_t_kcdjmx(id,yphh,shdm,sl,js,zxid,bj,zks,dj,je,cjje,zzsl,cbje,hscbje,rkjs,rksl,jysl,lymxid,djzt,sphh) "
    MySql += "    select @id,b.yphh,'',sl,0,0,dj,0,dj,je,0,0,0,0,0,sl,0,a.mxid,0,a.sphh from yx_v_kcdjmx a inner join yx_T_spdmb b on a.sphh=b.sphh where a.djlx=118 and a.sphh=@sphh and a.djzt=0 "
    MySql += "    SET @mxid=SCOPE_IDENTITY(); "
    '打上归还标识
    MySql += "    update t set t.djzt=2 from yx_v_kcdjmx t inner join yx_v_kcdjmx a on t.mxid=a.mxid inner join yx_T_spdmb b on a.sphh=b.sphh where a.djlx=118 and a.sphh=@sphh and a.djzt=0 "
    '新增尺码明细
    MySql += "    insert into yx_t_kcdjcmmx(id,mxid,cmdm,sl0,rksl0) values(@id,@mxid,'cm90',1,1); "
    MySql += "    update yx_t_kcdjb set je=(select sum(je) from yx_t_kcdjmx where id=@id),mxjls=(select count(id) from yx_t_kcdjmx where id=@id) where id=@id; "
    MySql += "    Exec yp_up_cgrkd_bc @id; "
    MySql += "    select '归还单生成及确认成功' as RetV"
    MySql += " end "
    '4.未做出库单：进行出库单生成以及确认操作
    MySql += " else  "
    MySql += " begin "
    MySql += "    select @maxdjh = isnull(max(djh)+1,'100001') from yx_t_kcdjb where tzid=1 and djlx=118 and convert(varchar(6),rq,112)=convert(varchar(6),getdate(),112);   "
    MySql += "    select @shgwid=isnull(shgwid,0) from xt_t_djshgw where tzid=1 and xh=1 and djlxid=118 "
    '插入主表
    MySql += "    insert into yx_t_kcdjb(tzid,dhbh,djlx,djlb,djbs,djh,rq,khid,shdwid,ckid,dfckid,je,cjje,skje,kpje,zdr,shr,qrr,jyr,zdrq,shrq,qrrq,shbs,qrbs,shgwid,pzzdr,pzzdbs,pzdqrq,pzkz,dycs,djzt,zzbs,zzrq,zzr,lydjid,bz,spdlid,qsr,qsrq) "
    MySql += "    values (1,'',118,2406,1,@maxdjh,getdate(),11038,0,10660,@rybh,0,0,0,0,'" + username + "','" + username + "','" + username + "','',getdate(),getdate(),getdate(),1,1,@shgwid,'',0,'','',0,0,0,'','',0,'手机扫描出库',1166,'" + username + "',getdate())"
    MySql += "    SET @id=SCOPE_IDENTITY(); "
    '插入明细
    MySql += "    insert yx_t_kcdjmx(id,sphh,shdm,sl,js,zxid,bj,zks,dj,je,cjje,zzsl,cbje,hscbje,rkjs,rksl,jysl,lymxid,djzt,yphh) "
    MySql += "    select @id,@sphh,'',1,0,0,0,0,lsdj,lsdj,0,0,0,0,0,0,0,0,0,yphh from yx_t_spdmb where sphh=@sphh"
    MySql += "    SET @mxid=SCOPE_IDENTITY(); "
    '新增尺码明细
    MySql += "    insert into yx_t_kcdjcmmx(id,mxid,cmdm,sl0,rksl0) values(@id,@mxid,'cm90',1,1); "
    MySql += "    update yx_t_kcdjb set je=(select sum(je) from yx_t_kcdjmx where id=@id),mxjls=(select count(id) from yx_t_kcdjmx where id=@id) where id=@id; "
    MySql += "    Exec yp_up_cgrkd_bc @id; "
    MySql += "    select '出库单生成及确认成功' as RetV"
    MySql += " end "
    'Response.Write(MySql)
    'Response.End()
    dal.ExecuteQuery(MySql, htzinfoDs)
    Dim htzinfo As DataTable = htzinfoDs.Tables(0).Copy()
    RetV = htzinfo.Rows(0)("RetV").ToString()

    Response.Write(RetV)
%>
