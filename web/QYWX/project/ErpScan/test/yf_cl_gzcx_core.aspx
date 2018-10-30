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
            case "GetWageData":
                GetWage();
                break;
            default :
                break;
        }
    }
    //获取员工工资
    public void GetWage()
    {
        try {
            DataTable Wage = null;
            string errInfo = "";
            string tj = "0";
            int userid = int.Parse(Request.Params["userid"]);
            string lastId = Request.Params["lastid"];
            if (lastId != "-1" && lastId!="")
            {
                tj =  lastId;
            }
            string ny = Request.Params["ny"];
            if (userid == 19163) { userid = 33; }
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM data = new LiLanzDALForXLM(OAConnStr))
            {
                string sql = @"declare @faid int; 
                             select top 1 @faid=id from yf_t_gzfab where tzid=@tzid and ny<=@ny and isnull(lx,0)=2 order by ny desc  
                             select mx.splbid,famx.*,gylx.mc as gymc into #temp from yx_t_splbgsb a inner join yx_t_splbgsmx mx on a.id=mx.id inner join yf_t_gzfamxb famx on famx.lbid = a.id 
                             inner join yf_t_gzfab fa on fa.id = famx.id left outer join yf_V_gylxdmb gylx on famx.lx=gylx.cs and gylx.tzid=@tzid where a.lx='yf' and fa.id=@faid ;
 
                             SELECT top 50 tg.id,convert(char(10),tg.zyjsrq,120)  as rq,zb.mc as xlmc,f.dm+f.mc as splbmc,tg.yphh,case when tg.cjfs='1' then '自动' when tg.cjfs='2' then '手动' end as cjfsmc,
                                 case when tg.gylx='@' then '' else tg.gylx end as gylxmc, isnull(tg.gydz,'B') gydz ,cast(tg.sl*b.bl/100 as decimal(12,2)) as sl,(CASE WHEN d.id=13 AND tg.yffl='sy' THEN lx.dbgj else d.dbgj END )  as jg
                             , case when b.bl>0 then (CASE WHEN d.id=13 AND tg.yffl='sy' THEN lx.dbgj else d.dbgj END ) *tg.sl*(CASE WHEN  tg.gydz='A' THEN 1.5 WHEN tg.gydz='C' THEN 0.7 ELSE 1 END )*b.bl*0.01 else
                             (CASE WHEN d.id=13 AND tg.yffl='sy' THEN lx.dbgj else d.dbgj END ) *tg.sl*(CASE WHEN  tg.gydz='A' THEN 1.5 WHEN tg.gydz='C' THEN 0.7 ELSE 1 END )/tg.yygrs  end  as je  
                             FROM yf_t_cpkfsjtg tg inner join yf_v_cpsplb splb on tg.zlmxid=splb.zlmxid  inner join  yf_t_cpkfzlb a  on a.zlmxid=tg.zlmxid and tg.tplx='sjtg' inner join yf_t_cpkfjh_ghs c on a.id=c.id and a.mxid=c.mxid
                             inner join yf_t_yprygxb b on tg.id=b.id and b.tzid=@tzid left join  (select dm,mc from t_xtdm where   tzid=@tzid and ssid='401') zb on zb.dm =c.xlid inner join yf_t_cpkfjh jh on c.id=jh.id 
                             inner join yx_t_splb f on case a.qybs when 1 then 6409 else jh.splbid end =f.id left join yx_t_ypdmb cb on tg.yphh=cb.yphh left join #temp d on splb.splbid=d.splbid AND tg.gylx=d.gymc  
                             LEFT JOIN (SELECT lx,MIN(dbgj) dbgj,MIN(bdbgj) bdbgj FROM #temp WHERE id=14 GROUP BY lx)lx ON d.lx=lx.lx WHERe convert(varchar(6),tg.zyjsrq,112)=@ny
                             and b.djlx='tgry' and b.dxlx='yygs' and tg.yyg not in('外发;','茄克组;','衬衫组;') and tg.id>@tj AND b.val=@userid  order by tg.id asc ";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@userid", userid));
                para.Add(new SqlParameter("@tzid", tzid));
                para.Add(new SqlParameter("@ny", ny));
                para.Add(new SqlParameter("@tj", tj));
                errInfo = data.ExecuteQuerySecurity(sql, para, out Wage);
            }
            Response.Clear();
            if (errInfo == "")
            {
                string outJson = JsonHelp.dataset2json(Wage);
                Response.Write(outJson.ToString());
            }
            else
            {
                Response.Write("{result:'Error',state:'NetFail',Message:"+errInfo+"}");
            }
        }catch (Exception e)
        {
            Response.Clear();
            Response.Write("{result:'Error',state:'DataFail',Message:"+e.Message+"}");
        }
        finally
        {
            Response.End();
        }
    }
</script>