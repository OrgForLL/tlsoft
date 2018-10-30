<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%@ Import Namespace="System.IO" %>

<script runat="server">
    //private string ZBDBConstr = clsConfig.GetConfigValue("OAConnStr");
    private string CXDBConstr = "server=192.168.35.20;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";//clsConfig.GetConfigValue("FXDBConStr"); 
    //private string FXDBConstr = clsConfig.GetConfigValue("CX1ConStr");
    //private string ERPDBConstr = clsConfig.GetConfigValue("CX2ConStr");
    Encoding encoding = Encoding.UTF8;  //编码

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
            switch (methodName.ToUpper())
            {
                case "GETFILTER_23864":
                    getFilter_23864();
                    break;
                case "GETRPT_23864":
                    getRpt_23864();
                    break;
                default:
                    respMsg("201", "操作方法名称错误！");
                    return;
            }
        }
        catch (Exception ex)
        {
            respMsg("2011", ex.Message);
            CreateErrorMsg(ex.Message + ex.StackTrace);
        }
    }

    public void getFilter_23864()
    {
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
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBConstr))
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
        }
    }

    public void getRpt_23864()
    {   //zbid,ksny,jsny,fxserver, khxztj
        string sql = @"  declare @userssid int; set @userssid=1;
                         declare @tqksny varchar(6);declare @tqjsny varchar(6);
                         set @tqksny=convert(varchar(6),dateadd(year,-1,'{1}01'),112);
                         set @tqjsny=convert(varchar(6),dateadd(year,-1,'{2}01'),112);
                        /*客户范围*/
                        select a.* into #tmp_khb from (
                            select a.gxid as djkhid,b.gxid as khid ,b.khdm,b.khmc,b.khfl,a.khfl as djkhfl ,a.lxr,a.khjc as djkhmc ,a.gxdm as djkhdm,
                                b.ksny+'01' as ksrq,dateadd(month,1,b.jsny+'01') as jsrq 
                             from yx_v_khgxb a inner join YX_v_khgxb b on (b.ccid+'-' like a.ccid+'-%')  
                              where  a.khid={0} {4} AND a.gxid=(CASE WHEN @userssid={0} THEN a.gxid ELSE @userssid end) and a.khlbdm<>'G' and a.gxid>{0} and a.gxid not in(85,1384) and len(a.dzbbpx)>0 and b.khfl in ('xz','xm') 
                         ) as a left outer join zw_t_zwinfo fo on a.khid = fo.tzid where 1=1 ;
                         /*销售收入数据*/
                          select b.djkhid,sum(case when isnumeric(a.g)=1 then cast(a.g as decimal(12,2)) else 0 end ) xssr_bn,
                              sum(case when isnumeric(a.h)=1 then cast(a.h as decimal(12,2)) else 0 end ) xssr_tq,
                              sum(case when isnumeric(a.i)=1 then cast(a.i as decimal(12,2)) else 0 end ) xssr_zj,
                              sum(case when isnumeric(a.v)=1 then cast(a.v as decimal(12,2)) else 0 end ) jlr2_bn,
                              sum(case when isnumeric(a.w)=1 then cast(a.w as decimal(12,2)) else 0 end ) jlr2_tq,
                              sum(case when isnumeric(a.x)=1 then cast(a.x as decimal(12,2)) else 0 end ) jlr2_zj 
                            into #tmp_xssrb from {3}zw_t_zwzhbb_sj a inner join (select djkhid from #tmp_khb group by djkhid) b on a.tzid=b.djkhid  
                             inner join {3}zw_t_zwzhbb zh on a.id=zh.id and b.djkhid=zh.tzid 
                           where  a.ny>='{1}' and a.ny<='{2}' and zh.jysjbs=26 group by b.djkhid; 
                         /*零售数据：销售金额、吊牌销售金额，新货销售金额，旧货销售金额，旧货销售目标，新货平均折扣*/
                         select a.djkhid,sum(a.xsje) as xsje,sum(a.xh_xsje) as xh_xsje,sum(a.jh_xsje) as jh_xsje,sum(a.xh_dpje) as xh_dpje,sum(a.jh_dpje) as jh_dpje,
                           sum(a.dpje) as dpje,sum(a.pjzk) as pjzk,sum(a.jh_mbje) as jh_mbje,sum(a.jh_dpje41) jh_dpje41 into #tmp_lsb
                         from (
                             select b.djkhid,sum(a.je) as xsje,sum(a.xh_xsje) as xh_xsje,sum(a.jh_xsje) as jh_xsje,sum(a.xh_dpje) as xh_dpje,sum(a.jh_dpje) as jh_dpje,
                               sum(a.jh_dpje)*0.41 as jh_dpje41,sum(a.xh_dpje+a.jh_dpje) as dpje,
                               cast((case when sum(a.xh_dpje)=0 then 0 else sum(a.xh_xsje)/sum(a.xh_dpje)*10.0 end) as decimal(10,2)) as pjzk,0 as jh_mbje  
                               from ds_t_khnylsb a inner join #tmp_khb b on a.khid=b.khid where a.ny>='{1}' and a.ny<='{2}' 
                             group by b.djkhid 
                             union all 
                             select b.djkhid,0 as xsje,0 as xh_xsje,0 as jh_xsje,0 as xh_dpje,0 as jh_dpje,0 as jh_dpje41,0 as dpje,0 as pjzk,sum(a.je) jh_mbje 
                               from rs_t_yxjmbje a inner join #tmp_khb b on a.khid=b.khid where a.ny>='{1}' and a.ny<='{2}' and a.shbs=1 
                               group by b.djkhid 
                         ) a group by a.djkhid;
                        /*新货售罄率计算(排除长线产品)售罄率=销售/(出库额+-调拨-长线部份不考核产品-总部铺货）*/
                        select a.id as splbid into #tmp_splb from YX_T_Splb a where a.tzid='{0}' and a.mj=1 and a.ty=0 and a.dm not like 'CX%' and a.mc not like '%衬衫%' 
                           and a.mc not like '%西服%' and a.dm not like '%定制%' ;

                        select a.djkhid,case when sum(a.cksl-a.zbphsl)=0 then 0 else sum(a.xssl)/sum(a.cksl-a.zbphsl) end as sql,
                         case when sum(a.tqcksl-a.tqzbphsl)=0 then 0 else sum(a.tqxssl)/sum(a.tqcksl-a.tqzbphsl) end as tqsql 
                         into #tmp_sql from (
                             select b.djkhid,-sum(a.xscksl+a.xsthsl) as xssl,-sum(a.cgrksl+a.cgthsl+a.dbsl-a.dbthsl) as cksl,0 as zbphsl,0 as tqxssl,0 as tqcksl,0 as tqzbphsl 
                             from {3}ds_T_SpKhcrkqkb a inner join #tmp_khb b on a.khid=b.khid 
                             inner join yx_t_spdmb c on c.tzid='{0}' and a.sphh=c.sphh inner join #tmp_splb d on c.splbid=d.splbid 
                             where a.ny>='201610' and a.ny<='{2}' and case when cast(right('{2}',2) as int)>=3 then left('{2}',4) else left('{2}',4)-1 end>=left(c.kfbh,4)
                             group by b.djkhid 
                            union all 
                            select kh.djkhid,0 as xssl,0 as cksl,-SUM(b.kc*a.sl) as zbphsl,0 as tqxssl,0 as tqcksl,0 as tqzbphsl from yx_v_kcdjmx a 
                             inner join t_djlxb b on a.djlx=b.dm inner join yx_t_spdmb c on c.tzid='{0}' and a.sphh=c.sphh 
                             inner join #tmp_splb d on c.splbid=d.splbid inner join yx_t_djlb e on a.djlb=e.id 
                             inner join (select djkhid from #tmp_khb group by djkhid) kh on a.khid=kh.djkhid 
                             and case when month(a.rq)>=3 then year(a.rq) else year(a.rq)-1 end<=left(c.kfbh,4)
                             where a.tzid='{0}' and e.kzx=9305 and a.rq>='{1}01' and a.rq<dateadd(month,1,CAST('{2}01' AS datetime)) 
                             group by kh.djkhid 
                            union all 
                             select b.djkhid,0 as xssl,0 as cksl,0 as zbphsl,-sum(a.xscksl+a.xsthsl) as tqxssl,-sum(a.cgrksl+a.cgthsl+a.dbsl-a.dbthsl) as tqcksl,0 as tqzbphsl 
                             from {3}ds_T_SpKhcrkqkb a inner join #tmp_khb b on a.khid=b.khid 
                             inner join yx_t_spdmb c on c.tzid='{0}' and a.sphh=c.sphh inner join #tmp_splb d on c.splbid=d.splbid 
                             where a.ny>='201510' and a.ny<=@tqjsny and case when cast(right(@tqjsny,2) as int)>=3 then left(@tqjsny,4) else left(@tqjsny,4)-1 end>=left(c.kfbh,4)
                             group by b.djkhid 
                            union all 
                            select kh.djkhid,0 as xssl,0 as cksl,0 as zbphsl,0 as tqxssl,0 as tqcksl,-SUM(b.kc*a.sl) as tqzbphsl from yx_v_kcdjmx a 
                             inner join t_djlxb b on a.djlx=b.dm inner join yx_t_spdmb c on c.tzid='{0}' and a.sphh=c.sphh 
                             inner join #tmp_splb d on c.splbid=d.splbid inner join yx_t_djlb e on a.djlb=e.id 
                             inner join (select djkhid from #tmp_khb group by djkhid) kh on a.khid=kh.djkhid 
                             and case when month(a.rq)>=3 then year(a.rq) else year(a.rq)-1 end<=left(c.kfbh,4)
                             where a.tzid='{0}' and e.kzx=9305 and a.rq>=@tqksny+'01' and a.rq<dateadd(month,1,CAST(@tqjsny+'01' AS datetime)) 
                             group by kh.djkhid 
                        ) a group by a.djkhid;

                        /*同期可比同店增长率*/
                        select a.djkhid,SUM(a.xsje) as xsje,SUM(a.tqxsje) as tqxsje, 
                          cast(case when isnull(sum(a.tqxsje),0)=0 then 0 else (sum(a.xsje)-sum(a.tqxsje))/sum(a.tqxsje) end as decimal(12,2)) as zzl
                          into #tmp_tbzzl from (
                             select a.djkhid,a.khid,a.ny,SUM(a.xsje) as xsje,SUM(a.tqxsje) as tqxsje from (
                                 select b.djkhid,a.khid,a.ny,sum(a.je) as xsje,0 as tqxsje  
                                   from  ds_t_khnylsb a inner join #tmp_khb b on a.khid=b.khid where a.ny>='{1}' and a.ny<='{2}' 
                                   group by b.djkhid,a.khid,a.ny 
                                 union all 
                                 select b.djkhid,a.khid,cast(a.ny as int)+100 as ny,0 as xsje,sum(a.je) as tqxsje  
                                   from  ds_t_khnylsb a inner join #tmp_khb b on a.khid=b.khid where a.ny>=@tqksny and a.ny<=@tqjsny 
                                   group by b.djkhid,a.khid,a.ny  
                             ) a group by a.djkhid,a.khid,a.ny 
                         ) a where a.xsje<>0 and a.tqxsje<>0 group by a.djkhid;

                        /*查询*/
                        select '' as sfmc,kh.khid,kh.khdm,kh.khmc,sum(a.xssr) as xssr,sum(a.yl) as yl,sum(a.pjzk) as pjzk
                           ,sum(a.sql1) as sql1,sum(a.sql2) as sql2,sum(a.jhxsmb) as jhxsmb,sum(a.pjdx1) as pjdx1,sum(a.pjdx2) as pjdx2
                           ,sum(a.xssr+a.yl+a.pjzk+a.sql1+a.sql2+a.jhxsmb+a.pjdx1+a.pjdx2) as zf ,
                           rank()over(ORDER BY sum(a.xssr+a.yl+a.pjzk+a.sql1+a.sql2+a.jhxsmb+a.pjdx1+a.pjdx2)  desc) AS xh  
                        from (
                             select a.djkhid,sum(case when a.xssr_tq=0 then 0 else 
                               case when a.xssr_zj/a.xssr_tq>=b.ksqj/100 and a.xssr_zj/a.xssr_tq<b.jsqj/100 then b.fs else 0 end end) as xssr
                               ,0 as yl,0 as pjzk,0 as sql1,0 as sql2,0 as jhxsmb,0 as pjdx1,0 as pjdx2    
                             from #tmp_xssrb a inner join yx_T_jyzbfs b on b.faid=1 and b.zbdm='A01' 
                             group by a.djkhid 
                            union all 
                             select a.djkhid,0 as xssr
                               ,sum(case when a.jlr2_tq=0 then 0 else 
                               case when a.jlr2_zj/ABS(a.jlr2_tq)>=c.ksqj/100 and a.jlr2_zj/ABS(a.jlr2_tq)<c.jsqj/100 then c.fs else 0 end end) as yl
                               ,0 as pjzk,0 as sql1,0 as sql2,0 as jhxsmb,0 as pjdx1,0 as pjdx2    
                             from #tmp_xssrb a inner join yx_T_jyzbfs c on c.faid=1 and c.zbdm='A02' 
                             group by a.djkhid 
                            union all 
                             select a.djkhid,0 as xssr,0 as yl,sum(case when a.pjzk>=c.ksqj and a.pjzk<c.jsqj then c.fs else 0 end)  as pjzk
                               ,0 as sql1,0 as sql2,0 as jhxsmb,0 as pjdx1,0 as pjdx2    
                             from #tmp_lsb a inner join yx_T_jyzbfs c on c.faid=1 and c.zbdm='A03' 
                             group by a.djkhid 
                            union all 
                             select a.djkhid,0 as xssr,0 as yl,0  as pjzk
                               ,/*sum(case when a.sql>=c.ksqj/100 and a.sql<c.jsqj/100 then c.fs else 0 end)*/0 as sql1,0 as sql2,0 as jhxsmb,0 as pjdx1,0 as pjdx2    
                             from #tmp_sql a inner join yx_T_jyzbfs c on c.faid=1 and c.zbdm='A04' 
                             group by a.djkhid 
                            union all 
                             select a.djkhid,0 as xssr,0 as yl,0 as pjzk
                               ,0 as sql1,/*case when max(a.sql)>0.75 then 10 else sum(case when a.tqsql=0 then 0 else 
                               case when (a.sql-a.tqsql)/a.tqsql>=c.ksqj/100 and (a.sql-a.tqsql)/a.tqsql<c.jsqj/100 then c.fs else 0 end end) end*/0 as sql2
                               ,0 as jhxsmb,0 as pjdx1,0 as pjdx2    
                             from #tmp_sql a left join yx_T_jyzbfs c on c.faid=1 and c.zbdm='A05' 
                             group by a.djkhid 
                            union all 
                             select a.djkhid,0 as xssr
                               ,0 as yl,0 as pjzk,0 as sql1,0 as sql2,sum(case when a.jh_mbje=0 then 0 else 
                               case when a.jh_dpje41/a.jh_mbje>=b.ksqj/100.0 and a.jh_dpje41/a.jh_mbje<b.jsqj/100.0 then b.fs else 0 end end) as jhxsmb,
                               0 as pjdx1,0 as pjdx2    
                             from #tmp_lsb a inner join yx_T_jyzbfs b on b.faid=1 and b.zbdm='A06' 
                             group by a.djkhid 
                            union all 
                             select a.djkhid,0 as xssr,0 as yl,0  as pjzk,0 as sql1,0 as sql2,0 as jhxsmb,
                               sum(case when a.zzl>=c.ksqj/100 and a.zzl<c.jsqj/100 and a.zzl>=b.pjzzl then c.fs else 0 end) as pjdx1,0 as pjdx2    
                             from #tmp_tbzzl a inner join yx_T_jyzbfs c on c.faid=1 and c.zbdm='A07' 
                             inner join (select avg(zzl) as pjzzl from #tmp_tbzzl) b on 1=1 
                             group by a.djkhid 
                            union all 
                             select a.djkhid,0 as xssr,0 as yl,0  as pjzk
                               ,0 as sql1,0 as sql2,0 as jhxsmb,0 as pjdx1,case when a.zzl>=b.pjzzl then 10 else 0 end as pjdx2    
                             from #tmp_tbzzl a inner join (select avg(zzl) as pjzzl from #tmp_tbzzl) b on 1=1 
                        ) a inner join yx_t_khb kh on a.djkhid=kh.khid 
                        group by kh.khid,kh.khdm,kh.khmc;

                        drop table #tmp_xssrb;
                        drop table #tmp_lsb;
                        drop table #tmp_sql;
                        drop table #tmp_splb;
                        drop table #tmp_tbzzl;
                        drop table #tmp_khb;
 ";
        //接收查询参数
        string strFil = Convert.ToString(Request.Params["filters"]);
        if (string.IsNullOrEmpty(strFil))
        {
            respMsg("201", "getRpt_23864:缺少查询条件！");
            return;
        }        
        //解析查询参数
        JObject joFil = JsonConvert.DeserializeObject<JObject>(strFil);
        string ksny = (string)joFil.GetValue("ksny", StringComparison.OrdinalIgnoreCase);
        string jsny = (string)joFil.GetValue("jsny", StringComparison.OrdinalIgnoreCase);
        string khid = (string)joFil.GetValue("khid", StringComparison.OrdinalIgnoreCase);
        string khcxtj = khid != "@" ? " and a.gxid= " + khid : "";
        //zbid,ksny,jsny,fxserver
        sql = string.Format(sql, "1", ksny, jsny, "cx1.dbo.", khcxtj);
        DataTable dt = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBConstr))
        {
            string strInfo = dal.ExecuteQuery(sql, out dt);
            if (strInfo != "")
            {
                respMsg("201", "getRpt_23864:获取报表数据出错！strInfo:" + strInfo);
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
