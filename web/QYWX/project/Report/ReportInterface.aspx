<%@ Page Language="C#" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    private string tzid = "", userId = "", userName = "";
    Encoding encoding = Encoding.UTF8;  //编码
    LiLanzDAL db;

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ClearHeaders();
        Response.AppendHeader("Access-Control-Allow-Origin", "*");
        string requestHeaders = Request.Headers["Access-Control-Request-Headers"];
        Response.AppendHeader("Access-Control-Allow-Headers", string.IsNullOrEmpty(requestHeaders) ? "*" : requestHeaders);
        Response.AppendHeader("Access-Control-Allow-Methods", "POST, GET,OPTIONS");
        try
        {
            string methodName = Request["method"] == null ? "" : Request["method"].ToString();  //操作
            /*MethodInfo method = this.GetType().GetMethod(methodName);
            if (method == null)
            {
                respMsg("201", "[" + methodName + "]方法不存在，或方法名称错误！");
                return;
            }
            method.Invoke(this, new Object[] { });*/
            if (methodName.Equals("getFinRpt", StringComparison.OrdinalIgnoreCase))
            {
                getFinRpt();
            }
            else if (methodName.Equals("getFinFil", StringComparison.OrdinalIgnoreCase))
            {
                getFinFil();
            }
            else if (methodName.Equals("getExpFil", StringComparison.OrdinalIgnoreCase))
            {
                getExpFil();
            }
            else if (methodName.Equals("getExpRpt", StringComparison.OrdinalIgnoreCase))
            {
                getExpRpt();
            }
            else
            {
                respMsg("201", "操作方法名称错误！");
                return;
            }
        }
        catch (Exception ex)
        {
            respMsg("201", ex.Message);
            CreateErrorMsg(ex.Message + ex.StackTrace);
        }
    }

    //领航公司资金管控表
    public void getFinFil()
    {
        string dbConn = "server=192.168.35.11;database=fxdb;uid=ABEASD14AD;pwd=+AuDkDew";
        string sql = @" SELECT CONVERT(VARCHAR, khid) AS dm,
        khlbdm + khmc AS mc,
        dzbbpx
        FROM YX_T_Khb
        WHERE ssid = 1
          AND LEN(dzbbpx) > 0
          AND ty = 0
          AND qy = 1
        UNION ALL
        SELECT '@' AS dm,
        '全部' AS mc,
        ''
        ORDER BY dm ";
        DataTable dt = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            string strInfo = dal.ExecuteQuery(sql, out dt);
            if (strInfo != "")
            {
                respMsg("201", "获取客户名称查询条件出错！strInfo:" + strInfo);
                return;
            }
            Dictionary<string, object> dic = new Dictionary<string, object>();
            dic.Add("khid", dt);
            respMsg("200", "成功！", dic);
            dt = null;
        }
    }
    //领航公司资金管控表
    public void getFinRpt()
    {
        string dbConn = "server=192.168.35.11;database=fxdb;uid=ABEASD14AD;pwd=+AuDkDew";
        string sql = @" declare @ksny varchar(6);  
 declare @jsny varchar(6);  
 select @ksny=convert(varchar(6),cast('{0}' as datetime),112);
 select @jsny=convert(varchar(6),cast('{1}' as datetime),112);

 select  a.gxid as djkhid,a.gxdm as djkhdm,a.khjc djkhmc,
        b.ksny+'01' as ksrq,b.jsny+'01' as jsrq,b.ksny,b.jsny,cast(b.tqjsny+'01' as datetime) as tqjsrq , 
        b.gxid khid,b.gxdm khdm,b.gxmc khmc,b.khfl,isnull(b.qtlx,0) qtlx 
 into #tmp_khb 
 from yx_v_khgxb a inner join YX_v_khgxb b on (b.ccid+'-' like a.ccid+'-%') 
 where a.khid=1 and a.khlbdm<>'g' and a.gxty=0 and b.gxty=0 and b.ty=0 
       and isnull(a.qtlx,0)=0 and isnull(b.qtlx,0)=0 and len(a.dzbbpx)>0 {2};

      /*开支预算*/
      select kh.djkhid
      ,sum(a.je) as hj_je
      into #temp_kz
      from #tmp_khb  kh
      left join zw_t_fyjh_kz a  on a.tzid=kh.khid and a.ny>=cast(kh.ksny as int) and a.ny<=cast(kh.jsny as int)
      where  a.nd=left(@jsny,4)  and a.ny>=@ksny and a.ny<=@jsny
      group by kh.djkhid
    
      /*年初调整项*/
      select a.tzid,sum(a.je) as je into #ktpe 
      from [192.168.35.10].tlsoft.dbo.yx_t_myxsmb a
      inner join (select djkhid from #tmp_khb group by djkhid) b on a.tzid=b.djkhid
      where zbdm='ktpe' and falx=-1 and yf=2 and nd=cast(left(@jsny,4) as int)-1  
      group by tzid

 select a.tzid,sum(case when kmdm='100102' then a.qcje else 0 end) as qc_fy,
        sum(case when (kmdm='100101' or kmdm like '1002%') then a.qcje else 0 end) as qc_hk,
        sum(case when a.kmdm in ('220301','112202','112201') then a.qcje else 0 end) as qc_skje,
        sum(case when a.kmdm='224101' then a.qcje else 0 end) as qcfy_sj,
        sum(case when a.kmdm='220201' then a.qcje else 0 end) as qchk_sj
 into #zjyeb 
 from ds_t_cnrjzzzb a where ny=@ksny  
 group by a.tzid ;

 select a.djkhid,sum(case when a.kmdm in ('220301','112202','112201') then a.ce else 0 end) as skje
        ,-sum(case when '{4}'=1 and isnull(a.zjyt,0)!=2 and a.xh=1 and a.kmdm not in ('220301','112202','112201','224116','190101','6301','6711','224101','220201','100101','100102','100201','100202') 
   then a.ce when '{4}'=0 and isnull(a.zjyt,0)!=2 and a.xh=1 then a.ce else 0 end) as fykz_rckz 
        ,-sum(case when '{4}'=1 and isnull(a.zjyt,0)=2 and a.xh=1 and a.kmdm not in ('220301','112202','112201','224116','190101','6301','6711','224101','220201','100101','100102','100201','100202') 
   then a.ce when '{4}'=0 and isnull(a.zjyt,0)=2 and a.xh=1 then a.ce else 0 end)  as fykz_xkd 
        ,sum(case when a.kmdm='224101' then a.dfje else 0 end) as fy_sj
        ,sum(case when isnull(a.zjyt,0)=1 and a.xh=2 then a.jfje else 0 end) as zbbf_rckz 
        ,sum(case when isnull(a.zjyt,0)=2 and a.xh=2 then a.jfje else 0 end) as zbbf_xkd  
        ,-sum(case when a.kmdm='220201' then a.ce else 0 end) as hk_sj
 into #fstmp
 from (
    select a.djkhid,b.dfkm as kmdm,sum(b.jfje-b.dfje) as ce,sum(b.jfje) jfje,sum(b.dfje) dfje,b.zjyt,1 as xh 
    from (select djkhid from #tmp_khb group by djkhid) a 
    inner join Zw_T_Cnrjz b on a.djkhid=b.tzid
    where b.rq>='{0}' and b.rq<dateadd(day,1,'{1}') and b.lylx in (311,312,316,321,322,323,0,826) 
          and b.nd=dbo.f_zw_kjnd(b.tzid,'{1}') 
    group by b.dfkm,a.djkhid ,b.zjyt
    union all 
    select a.djkhid,b.dfkm as kmdm,0 as ce,sum(b.dfje) jfje,0 dfje,b.zjyt,2 as xh 
    from (select djkhid from #tmp_khb group by djkhid) a 
    inner join [192.168.35.10].tlsoft.dbo.Zw_T_Cnrjz b on a.djkhid=b.khid
    where b.rq>='{0}' and b.rq<dateadd(day,1,'{1}')  
          and b.tzid=11355 and b.kmdm='100102' and b.dfkm='122108' and b.khid>0
    group by b.dfkm,a.djkhid,b.zjyt 
 ) a group by a.djkhid;

 select * from (
 select a.djkhid,djkhdm,djkhmc,b.qc_fy,b.qc_hk,c.skje,c.zbbf_rckz,c.zbbf_xkd,b.qc_fy+b.qc_hk+c.skje+c.zbbf_rckz+c.zbbf_xkd as zjze
        ,c.hk_sj,c.fy_sj,d.hk_jh,isnull(d.hk_jh,0)-c.hk_sj as hk_ce,e.fy_jh,isnull(e.fy_jh,0)-c.fy_sj as fy_ce
        ,c.fykz_rckz,c.fykz_xkd,c.fykz_rckz+c.fykz_xkd as fykz_hj
        ,b.qc_fy+c.zbbf_rckz+c.zbbf_xkd-c.fykz_rckz-c.fykz_xkd as qm_fy,b.qc_hk+c.skje-c.hk_sj-c.fy_sj as qm_hk    
        ,b.qc_hk+c.skje-(case when c.hk_sj>=isnull(d.hk_jh,0) then c.hk_sj else isnull(d.hk_jh,0) end)
           -(case when c.fy_sj>=isnull(e.fy_jh,0) then c.fy_sj else isnull(e.fy_jh,0) end) as ktp,
         b.qc_hk+b.qc_skje-b.qcfy_sj-b.qchk_sj as qc_ktp,kz.hj_je as kz_je,tz.je as tz_je    
 from (
    select djkhid,djkhdm,djkhmc from #tmp_khb group by djkhid,djkhdm,djkhmc 
 ) a 
 left outer join #temp_kz kz on a.djkhid=kz.djkhid
 left outer join #ktpe tz on a.djkhid=tz.tzid
 left outer join #zjyeb b on a.djkhid=b.tzid 
 left outer join #fstmp c on a.djkhid=c.djkhid  
 left outer join (select a.tzid as djkhid,sum(a.je) as hk_jh from [192.168.35.10].tlsoft.dbo.yx_t_myxsmb a 
        inner join (select djkhid from #tmp_khb group by djkhid) b on a.tzid=b.djkhid  
        where a.ny>=@ksny and a.ny<=@jsny and zbdm='xshk' group by a.tzid) d on a.djkhid=d.djkhid 
 left outer join (select a.tzid as djkhid,sum(a.je) as fy_jh from [192.168.35.10].tlsoft.dbo.yx_t_myxsmb a 
        inner join (select djkhid from #tmp_khb group by djkhid) b on a.tzid=b.djkhid  
        where a.ny>=@ksny and a.ny<=@jsny and zbdm='fyhk' group by a.tzid) e on a.djkhid=e.djkhid 
 ) a where case when '{3}'=0 then 1 when '{3}'=1 and a.ktp>0 then 1 when '{3}'=2 and a.ktp<0 then 1 else 0 end =1 {5}

 drop table #tmp_khb;
 drop table #zjyeb ; 
 drop table #fstmp ;
 ";
        string strFil = Request["filters"] == null ? "" : Request["filters"].ToString();
        if (string.IsNullOrEmpty(strFil))
        {
            respMsg("201", "查询条件不能为空！");
            return;
        }
        JObject joFil = JsonConvert.DeserializeObject<JObject>(strFil);
        string ksrq = (string)joFil.GetValue("ksrq", StringComparison.OrdinalIgnoreCase);
        string jsrq = (string)joFil.GetValue("jsrq", StringComparison.OrdinalIgnoreCase);
        string khid = (string)joFil.GetValue("khid", StringComparison.OrdinalIgnoreCase);
        string tpzt = (string)joFil.GetValue("tpzt", StringComparison.OrdinalIgnoreCase);
        string fykm = (string)joFil.GetValue("fykm", StringComparison.OrdinalIgnoreCase);
        string khdmmc = (string)joFil.GetValue("khdmmc", StringComparison.OrdinalIgnoreCase);

        string filKhid = khid == "@" ? "" : " and a.gxid=" + khid;
        string filKhdmmc = string.IsNullOrEmpty(khdmmc) ? "" : " and a.djkhdm + a.djkhmc like '%" + khdmmc + "%' ";
        sql = string.Format(sql, ksrq, jsrq, filKhid, tpzt, fykm, filKhdmmc);
        DataTable dt = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            string strInfo = dal.ExecuteQuery(sql, out dt);
            if (strInfo != "")
            {
                respMsg("201", "获取报表数据出错！strInfo:" + strInfo);
                return;
            }
            respMsg("200", "成功！", dt);
        }
    }
    //费用、回款汇总表
    public void getExpFil()
    {
        string dbConn = "server=192.168.35.11;database=fxdb;uid=ABEASD14AD;pwd=+AuDkDew";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            string sql = @" select '@' as dm ,'全部..' as mc,dzbbpx='' 
        union all SELECT case when khid=1 then '1' else convert(varchar,khid) end as dm,case when khid=1 then 'Z领航营销管理有限公司(直营店)' else khlbdm+khmc end as mc,dzbbpx 
        from yx_t_khb where ssid = 1 and len(dzbbpx)>0 and ty=0 and qy=1 or (zbid=khid)   union all select '-9' as dm,'ZZ领航营销管理有限公司(直营+贸易)' as mc,dzbbpx='' 
        union all select '17832' as dm,'福建星尚贸易有限公司' as mc,dzbbpx='' union all select '17878' as dm,'天津新锐轻商务管理服务公司' as mc,dzbbpx=''  order by dzbbpx ";
        DataTable dtKhid = null, dtKhfl = null;
            string strInfo = dal.ExecuteQuery(sql, out dtKhid);
            if (strInfo != "")
            {
                respMsg("201", "获取客户名称查询条件出错！strInfo:" + strInfo);
                return;
            }
            sql = @" select '@' as dm ,'全部...' as mc union all select cs as dm ,(dm+'.'+mc) as mc from yx_v_khfl where tzid=1 and tzfl like 'z%' ";
            strInfo = dal.ExecuteQuery(sql, out dtKhfl);
            if (strInfo != "")
            {
                respMsg("201", "获取客户分类查询条件出错！strInfo:" + strInfo);
                return;
            }
            Dictionary<string, object> dic = new Dictionary<string, object>();
            dic.Add("khid", dtKhid);
            dic.Add("khfl", dtKhfl);
            respMsg("200", "成功！", dic);
            dtKhid = null;
            dtKhfl = null;
        }
    }
    //费用、回款汇总表
    public void getExpRpt()
    {
        string dbConn = "server=192.168.35.11;database=fxdb;uid=ABEASD14AD;pwd=+AuDkDew";
        string sql = @" declare @ksny varchar(6); 
declare @jsny varchar(6); 
declare @tqksny varchar(6); 
declare @tqjsny varchar(6); 
declare @jsrq datetime ;
declare @ksrq datetime ;
declare @tqjsrq varchar(10); 
declare @tqksrq varchar(10);

select @ksny=convert(varchar(6),cast('{1}' as datetime),112);
select @jsny=convert(varchar(6),cast('{2}' as datetime),112);
select @tqksny=convert(varchar(6),dateadd(year,-1,cast('{1}' as datetime)),112);/*上一年度*/
select @tqjsny=convert(varchar(6),dateadd(year,-1,cast('{2}' as datetime)),112);
set @ksrq='{1}' ;
set @jsrq='{2}' ;
select @tqksrq=convert(varchar(10),dateadd(year,-1,cast('{1}' as datetime)) ,120); 
select @tqjsrq=convert(varchar(10),dateadd(year,-1,cast('{2}' as datetime)) ,120); 

select a.* into #tmp_khb from ( 
    select distinct b.khid,a.khid sskhid,a.khdm as sskhdm,a.khjc as sskhmc,b.khmc,b.ccid,gx.ksny,gx.jsny,b.ssid,c.mc as sfmc,a.lxr,
           case when Convert(varchar(6),isnull(gx.sjkyrq,'1900-01-01'),112) between @ksny and @jsny then 1 else 0 end as xdbs   
    from yx_t_khb a 
    left join  [192.168.35.10].tlsoft.dbo.yx_t_khsfdm c on a.sfdm=c.dm   
    inner join yx_t_khb b on a.ssid=1 and a.khlbdm<>'g' and (b.ccid+'-' like a.ccid+'-%')  and a.khid>1 
    left outer join yx_t_khgxb gx on gx.khid=case when b.khlbdm in ('D','d') then b.ssid else a.khid end and b.khid=gx.gxid and (gx.ksny<=@jsny and gx.jsny>=@ksny) 
    where 1=1 and a.khid not in(85,1384,14204) and len(a.dzbbpx)>0 and b.khmc not like '%直销户%' and b.ty=0 
          and a.khfl like 'x%' and isnull(gx.qtlx,0)=0 {0} {3} /*and b.khfl='xz'*/
) as a ; 

select * into #jhb from (
    select 'ys' as cs,b.ny,1 as xh,a.sskhid,a.khid,
           sum(case when b.ny>=@ksny and b.ny<=@jsny and b.bmid=-1 then b.je else 0 end) as ys_gsfy,
	sum(case when b.ny>=@ksny and b.ny<=@jsny and b.bmid=-3 and a.xdbs=0 then b.je else 0 end) as ys_ddgsfy,
	sum(case when b.ny>=@ksny and b.ny<=@jsny and b.bmid=-2 and a.xdbs=0 then b.je else 0 end) as ys_ddfy,
	sum(case when b.ny>=@ksny and b.ny<=@jsny and b.bmid=-3 and a.xdbs=1 then b.je else 0 end) as ys_xdddgsfy,
	sum(case when b.ny>=@ksny and b.ny<=@jsny and b.bmid=-2 and a.xdbs=1 then b.je else 0 end) as ys_xdddfy,
	sum(case when b.ny>=@ksny and b.ny<=@jsny then b.je else 0 end) as ys_hjfy, 
	sum(b.je) as ys_allfy 
    from #tmp_khb a inner join zw_t_fyjh_kz b on a.khid=b.tzid where b.nd=left(@ksny,4) and b.djlx=12457 /*(b.ny>=@ksny and b.ny<=@jsny) */
    and b.ny>=a.ksny and b.ny<=a.jsny
    group by b.ny,a.sskhid,a.khid    
) a ;
 /*同期实际开支*/
   select 'sjfy' as cs,b.nd,b.ny,1 as xh,a.sskhid,a.khid,
   sum(case when a.khid=b.khid and a.sskhid=b.khid and b.sjlx='sjfy' then b.je else 0 end) as sj_gsfy,  
   sum(case when a.khid=b.khid and b.sjlx='ddmy' and a.xdbs=0 then b.je else 0 end) as sj_ddgsfy,
   sum(case when a.khid=b.khid and a.sskhid<>b.khid and b.sjlx='sjfy' and a.xdbs=0 then b.je else 0 end) as sj_ddfy,
   sum(case when a.khid=b.khid and a.sskhid=b.khid and b.sjlx='sjfy' and a.xdbs=1  then b.je else 0 end) as sj_xdddgsfy,
   sum(case when a.khid=b.khid and a.sskhid<>b.khid and b.sjlx='sjfy' and a.xdbs=1  then b.je else 0 end) as sj_xdddfy
   /*,sum(b.je) as sj_hjfy*/
   into #fyb2 
   from #tmp_khb a inner join  [192.168.35.10].tlsoft.dbo.rs_t_yxsjfyb b on a.khid=b.khid 
   where b.nd=2016 and b.khid>0 and b.sjlx in ('sjfy','ddmy') and b.ny>='201603' and b.ny<='201702' 
         and ((b.ny>=@ksny and b.ny<=@jsny) or (b.ny>=@tqksny and b.ny<=@tqjsny) )
    group by b.nd,b.ny,a.sskhid,a.khid;
 /*本期实际开支*/
 select a.* into #fyb1 from (
   /*日常开支，店租费用，税务费用，个人借款，个人花费，差旅费，工资,固定资产*/
   select a.cs,dbo.f_Zw_kjnd(a.khid,a.rq) as nd,convert(varchar(6),a.rq,112) as ny,1 as xh,kh.sskhid,kh.khid,
   sum(case when ((a.jb='xf' and a.bxlx=0) or (a.bxlx=1 and a.jb!='xz')) then a.hdje else 0 end) as sj_gsfy,  
   sum(case when a.jb='mydd' and a.bxlx=0 and kh.xdbs=0  then a.hdje else 0 end) as sj_ddgsfy,  
   sum(case when a.jb='xz'  and kh.xdbs=0 then a.hdje else 0 end) as sj_ddfy, 
   sum(case when a.jb='mydd'  and a.bxlx=0 and kh.xdbs=1  then a.hdje else 0 end) as sj_xdddgsfy,  
   sum(case when a.jb='xz'  and kh.xdbs=1 then a.hdje else 0 end) as sj_xdddfy  
  from zw_v_sjkzfy a
  inner join #tmp_khb kh on a.khid=kh.khid 
  where a.rq>=@ksrq and a.rq<dateadd(d,1,@jsrq)  and a.pzbs=1
  group by dbo.f_Zw_kjnd(a.khid,a.rq),convert(varchar(6),a.rq,112) ,kh.sskhid,kh.khid,a.cs
) a 


select *,sj_gsfy+sj_ddgsfy+sj_ddfy+sj_xdddgsfy+sj_xdddfy as sj_hjfy into #fyb 
from (
   select * from #fyb1   
   union all 
   select * from #fyb2 
) a ;

 /*往来款*/
 select a.tzid,sum(jfje) as sr,sum(dfje) as zc
 into #wlk 
 from Zw_T_Cnrjz as a 
 inner join ( select kmdm from zw_t_kmsdb where djlx='12460' and xjdfkm=6982 and tzid=1 and scxe=1  ) b on a.dfkm=b.kmdm
 where a.lylx in (311,312,316,321,322,323,0,826) 
  and  a.rq>=@ksrq and a.rq<dateadd(d,1,@jsrq)  and a.nd=dbo.f_zw_kjnd(a.tzid,@jsrq) 
 group by a.tzid


  select a.sskhid,km.kmdm into #sykmdm from (select sskhid from #tmp_khb group by sskhid) a 
  inner join zw_t_zwkmb km on a.sskhid=km.tzid 
  where km.nd=2017 and km.kzlb=1 
  group by a.sskhid,km.kmdm ;

 select a.sskhid,sum(xjcnzc) as xjcnzc,sum(xxjcnzc) as xxjcnzc,sum(sjcnzc) as sjcnzc,sum(ddcnzc) as ddcnzc,sum(xdddcnzc) as xdddcnzc 
        into #cnzc 
 from (
    select a.sskhid,sum(case when b.khid>0  and b.khid!=b.tzid and isnull(kh.xdbs,0)=0 then b.dfje else 0 end) as xjcnzc,
           sum(case when b.khid>0  and b.khid!=b.tzid and kh.xdbs=1 then b.dfje else 0 end) as xxjcnzc,
           sum(case when (b.khid=0 or b.khid=b.tzid) then b.dfje else 0 end) as sjcnzc,0 as ddcnzc,0 as xdddcnzc
    from #sykmdm a inner join zw_t_cnrjz b on a.sskhid=b.tzid and a.kmdm=b.dfkm and b.rq>=@ksrq and b.rq<dateadd(d,1,@jsrq)   
    left outer join #tmp_khb kh on b.khid=kh.khid 
    group by a.sskhid 
    union all 
    select a.sskhid,0 as xjcnzc,0 as xxjcnzc,0 as sjcnzc,sum(case when a.xdbs=0 then dfje else 0 end) as ddcnzc,
           sum(case when a.xdbs=1 then dfje else 0 end) as xdddcnzc 
	from (select sskhid,khid,xdbs from #tmp_khb group by sskhid,khid,xdbs) a 
    inner join zw_t_cnrjz b on a.sskhid=b.tzid and b.khid=a.khid and b.rq>=@ksrq and b.rq<dateadd(d,1,@jsrq) and b.dfkm='122111' 
    and b.khid>0 group by a.sskhid 
 ) a group by a.sskhid;


/*资金余额[对公，对私]*/
 select a.tzid,sum(case when a.kmdm in ('100201','100202') then a.qmje else 0 end) as dgje 
              ,sum(case when a.kmdm in ('100101','100102','1012') then a.qmje else 0 end) as dsje 
 into #zjyezb 
 from ds_t_cnrjzzzb a where 1=1 and ny=@jsny and a.kmdm in ('100201','100202','100101','100102','1012') group by a.tzid ;


if '2'='1' 
select a.*,ys_gsfy-sj_gsfy as jc_gsfy,ys_ddgsfy-sj_ddgsfy as jc_ddgsfy,ys_ddfy-sj_ddfy as jc_ddfy
       ,ys_xdddgsfy-sj_xdddgsfy as jc_xdddgsfy,ys_xdddfy-sj_xdddfy as jc_xdddfy,ys_hjfy-sj_hjfy as jc_hjfy
       ,case when ys_allgsfy=0 then 0 else (a.sj_gsfy+a.sj_ddgsfy+a.sj_xdddgsfy)/ys_allgsfy*100 end as gsfyzb 
       ,case when ys_allddfy=0 then 0 else (a.sj_ddfy+a.sj_xdddfy)/ys_allddfy*100 end as ddfyzb
       ,b.sz2 as zcfzr,b.sz3 as ldy,@ksrq as ksrq,@jsrq as jsrq ,@ksny as ksny,@jsny as jsny,@tqksny as tqksny,@tqjsny as tqjsny 
       ,b.cnry as ry_cn,b.kjry as ry_kj,b.rzry as ry_rz,b.spry as ry_sp,@tqksrq as tqksrq,@tqjsrq as tqjsrq    
from (
   select kh.sfmc,kh.sskhid as khid,kh.sskhmc as khmc,kh.sskhdm as khdm,max(kh.lxr) lxr,max(zj.dgje) as dgje,
       max(zj.dsje) as dsje,max(zc.sjcnzc) as sjcnzc,max(zc.xjcnzc) as xjcnzc,max(zc.ddcnzc) as ddcnzc,
       max(zc.xxjcnzc) as xxjcnzc,max(zc.xdddcnzc) as xdddcnzc,
       max(zc.sjcnzc+zc.xjcnzc+zc.ddcnzc+zc.xxjcnzc+zc.xdddcnzc) as cnzc,
       sum(isnull(b.ys_gsfy,0)) as ys_gsfy,sum(isnull(b.ys_ddgsfy,0)) as ys_ddgsfy,
       sum(isnull(b.ys_ddfy,0)) as ys_ddfy,sum(isnull(b.ys_xdddgsfy,0)) as ys_xdddgsfy,
       sum(isnull(b.ys_xdddfy,0)) as ys_xdddfy,sum(isnull(b.ys_hjfy,0)) as ys_hjfy,
       sum(a.sj_gsfy) as sj_gsfy, sum(a.sj_ddgsfy) as sj_ddgsfy,
       sum(a.sj_ddfy) as sj_ddfy, sum(a.sj_xdddgsfy) as sj_xdddgsfy,
       sum(a.sj_xdddfy) as sj_xdddfy, sum(a.sj_hjfy) as sj_hjfy,
       sum(c.sj_gsfy) as tq_gsfy, sum(c.sj_ddgsfy) as tq_ddgsfy,
       sum(c.sj_ddfy) as tq_ddfy, sum(c.sj_xdddgsfy) as tq_xdddgsfy,
       sum(c.sj_xdddfy) as tq_xdddfy,sum(c.sj_hjfy) as tq_hjfy,
       max(allys.ys_allgsfy) as ys_allgsfy, max(allys.ys_allddfy) as ys_allddfy 
       ,max(wl.sr) as wlsr,max(wl.zc) as wlzc,max(wl.zc)-max(wl.sr) as wlce    
   from #tmp_khb kh left outer join #fyb a on kh.sskhid=a.sskhid and kh.khid=a.khid  and a.ny>=@ksny and a.ny<=@jsny
   left outer join #jhb b on kh.sskhid=b.sskhid and kh.khid=b.khid and b.ny>=@ksny and b.ny>=@jsny  
   left outer join #fyb c on kh.sskhid=c.sskhid and kh.khid=c.khid and c.ny>=@tqksny and c.ny<=@tqjsny and right(a.ny,2)=right(c.ny,2) 
        and a.sj_hjfy>0 and c.sj_hjfy>0 
   left outer join (
       select sum(case when a.sskhid=a.khid then ys_allfy else 0 end) as ys_allgsfy , 
              sum(case when a.sskhid<>a.khid then ys_allfy else 0 end) as ys_allddfy ,a.sskhid 
       from #tmp_khb a inner join #jhb b on a.sskhid=b.sskhid and a.khid=b.khid 
       group by a.sskhid 
   ) allys on a.sskhid=allys.sskhid 
   left outer join #cnzc zc on kh.sskhid=zc.sskhid 
   left outer join #zjyezb zj on kh.sskhid=zj.tzid  
   left join #wlk wl on kh.sskhid=wl.tzid
   where 1=1 
   group by kh.sskhid,kh.sskhmc,kh.sskhdm,kh.sfmc   
) a left outer join [192.168.35.10].tlsoft.dbo.xt_T_tycsxz b on a.khid=b.khid and b.bid=1 

if '2'='2' or '2'=''
select a.*,ys_gsfy-sj_gsfy as jc_gsfy,ys_ddgsfy-sj_ddgsfy as jc_ddgsfy,ys_ddfy-sj_ddfy as jc_ddfy
       ,ys_xdddgsfy-sj_xdddgsfy as jc_xdddgsfy,ys_xdddfy-sj_xdddfy as jc_xdddfy,ys_hjfy-sj_hjfy as jc_hjfy
       ,case when ys_allgsfy=0 then 0 else (a.sj_gsfy+a.sj_ddgsfy+a.sj_xdddgsfy)/ys_allgsfy*100 end as gsfyzb 
       ,case when ys_allddfy=0 then 0 else (a.sj_ddfy+a.sj_xdddfy)/ys_allddfy*100 end as ddfyzb 
       ,b.sz2 as zcfzr,b.sz3 as ldy,@ksrq as ksrq,@jsrq as jsrq ,@ksny as ksny,@jsny as jsny,@tqksny as tqksny,@tqjsny as tqjsny 
       ,b.cnry as ry_cn,b.kjry as ry_kj,b.rzry as ry_rz,b.spry as ry_sp,@tqksrq as tqksrq,@tqjsrq as tqjsrq   
       ,zj.dgje,zj.dsje,zc.sjcnzc,zc.xjcnzc,zc.ddcnzc, 
       zc.xxjcnzc,zc.xdddcnzc,
       zc.sjcnzc+zc.xjcnzc+zc.ddcnzc+zc.xxjcnzc+zc.xdddcnzc as cnzc,
       allys.ys_allgsfy,allys.ys_allddfy  
       ,wl.sr as wlsr,wl.zc as wlzc,wl.zc-wl.sr as wlce 
    
from (
   select kh.sfmc,kh.sskhid as khid,kh.sskhmc as khmc,kh.sskhdm as khdm,max(kh.lxr) lxr,
       sum(isnull(b.ys_gsfy,0)) as ys_gsfy,sum(isnull(b.ys_ddgsfy,0)) as ys_ddgsfy,
       sum(isnull(b.ys_ddfy,0)) as ys_ddfy,sum(isnull(b.ys_xdddgsfy,0)) as ys_xdddgsfy,
       sum(isnull(b.ys_xdddfy,0)) as ys_xdddfy,sum(isnull(b.ys_hjfy,0)) as ys_hjfy,
       sum(a.sj_gsfy) as sj_gsfy, sum(a.sj_ddgsfy) as sj_ddgsfy,
       sum(a.sj_ddfy) as sj_ddfy, sum(a.sj_xdddgsfy) as sj_xdddgsfy,
       sum(a.sj_xdddfy) as sj_xdddfy, sum(a.sj_hjfy) as sj_hjfy,
       sum(c.tq_gsfy) as tq_gsfy, sum(c.tq_ddgsfy) as tq_ddgsfy,
       sum(c.tq_ddfy) as tq_ddfy, sum(c.tq_xdddgsfy) as tq_xdddgsfy,
       sum(c.tq_xdddfy) as tq_xdddfy,sum(c.tq_hjfy) as tq_hjfy
   from #tmp_khb kh 
   left outer join (
       select c.sskhid,c.khid,sum(c.sj_gsfy) as sj_gsfy, sum(c.sj_ddgsfy) as sj_ddgsfy,
              sum(c.sj_ddfy) as sj_ddfy, sum(c.sj_xdddgsfy) as sj_xdddgsfy,
              sum(c.sj_xdddfy) as sj_xdddfy,sum(c.sj_hjfy) as sj_hjfy  
       from #fyb c where c.ny>=@ksny and c.ny<=@jsny group by c.sskhid,c.khid 
   ) a on kh.sskhid=a.sskhid and kh.khid=a.khid 
   left outer join (select sskhid,khid,sum(isnull(b.ys_gsfy,0)) as ys_gsfy,sum(isnull(b.ys_ddgsfy,0)) as ys_ddgsfy,
       sum(isnull(b.ys_ddfy,0)) as ys_ddfy,sum(isnull(b.ys_xdddgsfy,0)) as ys_xdddgsfy,
       sum(isnull(b.ys_xdddfy,0)) as ys_xdddfy,sum(isnull(b.ys_hjfy,0)) as ys_hjfy from #jhb b where b.ny>=@ksny and b.ny<=@jsny group by sskhid,khid) b 
   on kh.sskhid=b.sskhid and kh.khid=b.khid 
   left outer join (
       select c.sskhid,c.khid,sum(c.sj_gsfy) as tq_gsfy, sum(c.sj_ddgsfy) as tq_ddgsfy,
              sum(c.sj_ddfy) as tq_ddfy, sum(c.sj_xdddgsfy) as tq_xdddgsfy,
              sum(c.sj_xdddfy) as tq_xdddfy,sum(c.sj_hjfy) as tq_hjfy  
       from #fyb c where c.ny>=@tqksny and c.ny<=@tqjsny group by c.sskhid,c.khid 
   ) c on kh.sskhid=c.sskhid and kh.khid=c.khid 
   group by kh.sskhdm,kh.sskhid,kh.sskhmc,kh.sfmc  
) a left outer join [192.168.35.10].tlsoft.dbo.xt_T_tycsxz b on a.khid=b.khid and b.bid=1 
   left outer join (
       select sum(case when a.sskhid=a.khid then ys_allfy else 0 end) as ys_allgsfy , 
              sum(case when a.sskhid<>a.khid then ys_allfy else 0 end) as ys_allddfy ,a.sskhid 
       from #tmp_khb a inner join #jhb b on a.sskhid=b.sskhid and a.khid=b.khid 
       group by a.sskhid 
   ) allys on a.khid=allys.sskhid 
   left outer join #cnzc zc on a.khid=zc.sskhid 
   left outer join #zjyezb zj on a.khid=zj.tzid 
   left join #wlk wl on a.khid=wl.tzid;

drop table #tmp_khb;
drop table #jhb;
drop table #fyb1 ;
drop table #fyb2 ;
drop table #fyb ;
drop table #sykmdm ;
drop table #cnzc ;
drop table #zjyezb ;
drop table #wlk;
 ";
        string strFil = Request["filters"] == null ? "" : Request["filters"].ToString();
        if (string.IsNullOrEmpty(strFil))
        {
            respMsg("201", "查询条件不能为空！");
            return;
        }
        JObject joFil = JsonConvert.DeserializeObject<JObject>(strFil);
        string khid = (string)joFil.GetValue("khid", StringComparison.OrdinalIgnoreCase);
        string ksrq = (string)joFil.GetValue("ksrq", StringComparison.OrdinalIgnoreCase);
        string jsrq = (string)joFil.GetValue("jsrq", StringComparison.OrdinalIgnoreCase);
        string khdmmc = (string)joFil.GetValue("khdmmc", StringComparison.OrdinalIgnoreCase);

        string filKhid = khid == "@" ? "" : " and a.khid=" + khid;
        string filKhdmmc = string.IsNullOrEmpty(khdmmc) ? "" : " and a.khdm + a.khjc like '%" + khdmmc + "%' ";

        sql = string.Format(sql, filKhid, ksrq, jsrq, filKhdmmc);
        CreateErrorMsg(sql);
        DataTable dt = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            string strInfo = dal.ExecuteQuery(sql, out dt);
            if (strInfo != "")
            {
                respMsg("201", "获取报表数据出错！strInfo:" + strInfo);
                return;
            }
            respMsg("200", "成功！", dt);
        }
    }

    /// <summary>
    /// 发送信息
    /// </summary>
    /// <param name="code">代码</param>
    /// <param name="msg">信息</param>
    public void respMsg(string code, string msg)
    {
        Dictionary<string, Object> dicRes = new Dictionary<string, Object>();
        dicRes.Add("code", code);
        dicRes.Add("msg", msg);
        byte[] bytes = encoding.GetBytes(JsonConvert.SerializeObject(dicRes));
        HttpResponse hr = HttpContext.Current.Response;
        hr.Clear();
        hr.OutputStream.Write(bytes, 0, bytes.Length);
        hr.OutputStream.Close();
    }

    /// <summary>
    /// 发送信息
    /// </summary>
    /// <param name="code">代码</param>
    /// <param name="msg">信息</param>
    /// <param name="data">数据</param>
    public void respMsg(string code, string msg, Object data)
    {
        Dictionary<string, Object> dicRes = new Dictionary<string, Object>();
        dicRes.Add("code", code);
        dicRes.Add("msg", msg);
        dicRes.Add("data", data);
        byte[] bytes = encoding.GetBytes(JsonConvert.SerializeObject(dicRes));
        HttpResponse hr = HttpContext.Current.Response;
        hr.Clear();
        hr.OutputStream.Write(bytes, 0, bytes.Length);
        hr.OutputStream.Close();
    }

    public void CreateErrorMsg(string message)
    {
        //LogHelper.Info(message);

        string m_fileName = Request.MapPath("systemlog.txt");
        if (File.Exists(m_fileName))
        {
            StreamWriter sr = File.AppendText(m_fileName);
            sr.Write("\n");
            sr.WriteLine(DateTime.Now.ToString() + " " + message);
            sr.Close();
        }
        else
        {
            ///创建日志文件
            StreamWriter sr = File.CreateText(m_fileName);
            sr.WriteLine(DateTime.Now.ToString() + " " + message);
            sr.Close();
        }

    }

</script>
