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
    //获取产量信息
    public void GetOutput()
    {
        try
        {
            DataTable Output = null;
            string errInfo = "";
            string ny = Request.Params["ny"];
            string tj = Request.Params["tj"];
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM data = new LiLanzDALForXLM(OAConnStr))
            {
                 //ljmbcl:累计目标产量，sjlp:实际良品也即实际产量,zmbdcl:周目标达成率，zmbce:周目标差额
                string sql = @"  declare @rq datetime ; set @rq= CONVERT(nvarchar(10), DATEADD(wk, DATEDIFF(wk,0,DATEADD(dd, -1, convert( datetime ,@nyr) )), 0),112);
                                  select scx,max(id)as id,rq,max(dtmb) as dtmb,max(dqmb) dqmb,max(sjfg) sjfg, max(sjlp) sjlp into #lsc from (
                                  select scx,convert(varchar(8),rq,112) as rq,id,dtmb,dqmb,sjfg,sjlp from sc_t_zdlscsjb ) a group by scx,rq ;

                                  select a.mc,sum(a.ljmbcl) as zljmbcl,sum(a.sjcl) as zsjcl,convert(decimal(8,2),sum(a.sjcl)*1.00/sum(a.ljmbcl)) zmbdcl,sum(a.ljmbcl)-sum(a.sjcl) zmbce,
                                   sum(a.drljmbcl)as drljmbcl,sum(a.drsjcl) as drsjcl,convert(decimal(8,2),sum(a.drsjcl)*1.00/sum(a.drljmbcl)) drmbdcl,sum(a.drljmbcl)-sum(a.drsjcl) drmbce
	                                from(
	                                  select c.mc,b.sl as ljmbcl,f.sjlp as sjcl,d.cmdm,
	                                  case when d.cmdm=convert(varchar(8),cast(@nyr as datetime),112) then b.sl end drljmbcl,
	                                  case when d.cmdm=convert(varchar(8),cast(@nyr as datetime),112) and @tj=1 then f.sjlp 
	                                  when d.cmdm=convert(varchar(8),cast(@nyr as datetime),112) and @tj=0 then scmx.sl else 0  end  drsjcl
	                                  from sc_t_fzjhb a 
	                                  inner join sc_t_fzjhmxb b on a.id=b.id 
	                                  inner join sc_t_scbmb c on b.cjcj=c.id
	                                  inner join sc_t_scbmb g on g.id=b.cjzb
	                                  inner join sc_t_fzjhcmmx d on d.mxid=b.mxid and d.cmdm<=convert(varchar(8),cast(@nyr as datetime),112) and d.cmdm>=@rq
	                                  left join #lsc f on f.scx=g.mc and f.rq=d.cmdm 
                                      left outer join sc_t_scbcplzb sc on sc.tzid=11360 and sc.djlx=229 and sc.rq=@nyr and b.cjcj=sc.zcbmid
	                                  left outer join sc_t_scbcplzmx scmx on sc.id=scmx.id 
	                                  )a group by a.mc; drop table #lsc;";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@nyr", ny));
                para.Add(new SqlParameter("@tj", tj));
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
