<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>
<script runat="server">  
    string tzid;
    protected void Page_Load(object sender, EventArgs e)
    {
        tzid = "1";
        string ctrl = Request.Params["ctrl"];
        if (string.IsNullOrEmpty(ctrl))
        {
            ctrl = "";
        }
        switch (ctrl)
        {
            case "GetOutput":
                GetOutput();
                break;
            default:
                break;
        }
    }
    //获取员工工资
    public void GetOutput()
    {
        try
        {
            DataTable Output = null;
            string errInfo = "";
            string ny = Request.Params["ny"];
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM data = new LiLanzDALForXLM(OAConnStr))
            {
                string sql = "  select b.spkh,c.mc into #tmp from sc_t_fzjhb a inner join sc_t_fzjhmxb b  on a.id=b.id inner join sc_t_scbmb c on b.cjzb=c.id ";
                sql += "        inner join sc_t_fzjhcmmx d on d.mxid=b.mxid and d.cmdm=convert(varchar(8),cast('" + ny + "' as datetime),112) ";
                sql += "        select scx,max(id)as id,rq,max(dtmb) as dtmb,max(dqmb) dqmb,max(sjfg) sjfg, max(sjlp) sjlp into #lsc from (";
                sql += "        select scx,convert(varchar(8),rq,112) as rq,id,dtmb,dqmb,sjfg,sjlp from sc_t_zdlscsjb ";
                sql += "        ) a group by scx,rq ";
                sql += "        select b.mc,count(a.rybh) as rs into #kqrs from (";
                sql += "        select b.bmid,b.rybh,count(b.id) as sl from kq_t_rydkmx a ";
                sql += "        inner join rs_v_ryxxzhcx b on a.BadgeNumber=b.rybh ";
                sql += "        where tzid=11360 and a.statu=3 and a.ChecktimeStart>cast('" + ny + "' as datetime) and  a.ChecktimeStart<dateadd(day,1,cast('" + ny + "' as datetime)) ";
                sql += "        group by b.bmid,b.rybh ) a inner join sc_t_scbmb b on a.bmid=b.id where a.sl>1 group by b.mc ";
                sql += "        select sum(d.sl0)as sl,c.mc,(select distinct spkh+',' from #tmp where mc=c.mc for xml path('')) as spkh,f.sjlp,f.sjfg,f.dqmb, ";
                sql += "        Convert(decimal(8,2),case when sum(d.sl0)= 0 then 0 else isnull(f.dqmb,0)*1.00/sum(d.sl0) end)*100 dcl,";
                sql += "        Convert(decimal(8,2),case when f.sjlp+f.sjfg=0 then 0 else f.sjlp*1.00/(f.sjlp+f.sjfg) end)*100  as lpl,e.rs as kqrs, ";
                sql += "        Convert(decimal(8,0),case when isnull(e.rs,0)= 0 then 0 else isnull(f.sjlp,0)*1.00/e.rs end) rjcl ";
                sql += "        from sc_t_fzjhb a inner join sc_t_fzjhmxb b  on a.id=b.id inner join sc_t_scbmb c on b.cjzb=c.id";
                sql += "        inner join sc_t_fzjhcmmx d on d.mxid=b.mxid and d.cmdm=convert(varchar(8),cast('" + ny + "' as datetime),112) ";
                sql += "        left join #lsc f on f.scx=c.mc and f.rq=d.cmdm ";
                sql += "        left join #kqrs e on e.mc=c.mc  ";
                sql += "        group by c.mc,f.sjlp,f.sjfg,f.dqmb,e.rs ";
                sql += "        drop table #tmp;drop table #lsc; drop table #kqrs;";
                List<SqlParameter> para = new List<SqlParameter>();
                errInfo = data.ExecuteQuerySecurity(sql, para, out Output);
            }
            Response.Clear();
            if (errInfo == "")
            {
                string outJson = JsonHelp.dataset2json(Output);
                Response.Write(outJson.ToString());
            }
            else
            {
                Response.Write("{result:'Error',state:'NetFail',Message:" + errInfo + "}");
            }
        }
        catch (Exception e)
        {
            Response.Clear();
            Response.Write("{result:'Error',state:'DataFail',Message:" + e.Message + "}");
        }
        finally
        {
            Response.End();
        }
    }
</script>
