<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">  
  
   // string FXDBConnStr = clsConfig.GetConfigValue("FXDBConStr");
   // string queryConnStr = "server=192.168.35.32;uid=lllogin;pwd=rw1894tla;database=tlsoft";
    string FXDBConnStr = "server=192.168.35.11;database=FXDB;uid=ABEASD14AD;pwd=+AuDkDew";
    protected void Page_Load(object sender,EventArgs e)
    {      
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string way = Convert.ToString(Request.Params["way"]);
        string ny = null;
        if (mdid == "" || mdid == null)
        {
             clsSharedHelper.WriteErrorInfo("缺少门店参数！");
             return;
        }

        if (way == "thisMonth")
        {
            ny = DateTime.Now.ToString("yyyyMM");

        }else if (way=="beforeMonth")
        {
            ny = DateTime.Now.AddMonths(-1).ToString("yyyyMM");   
        }

        if (ny == "" || ny == null)
        {
            clsSharedHelper.WriteErrorInfo("缺少月份参数！");
            return;
        }  
        switch (ctrl)
        {
            case "VipMain":
                getVipMainData(mdid,ny);    
                break;  
            case "VipAccounting":
                getVipAccountingData(mdid, ny);   
                break;    
            case "VipFrequency": 
                getVipFrequencyData(mdid,ny);
                break;
            case "VipActivity":
                getVipActivityData(mdid, ny);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                break;
        };

    }

    public void getVipMainData(string mdid, string ny)
    {
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(FXDBConnStr))
        {
            DataTable dt = null;
            //vip 总数为本店vip客户, 其他为包含本店的共用vip客户
            string strsql = @"  declare @vipCount int;
                                declare @xfvip int;
                                declare @halfvip int;

                                select @vipCount=COUNT(id) from yx_t_vipkh vip where  mdid=@mdid;                         

                                select @xfvip=count(a.vip) 
                                from
                                  (select  a.vip
                                   from zmd_t_lsdjb a
                                   inner join yx_t_vipkh vip on a.vip=vip.kh  
                                   where a.djbs=1 and isnull(a.vip,'')<>''  and a.mdid=@mdid  
                                   and a.rq>=@ny+'01' and a.rq<DATEADD(month,1,@ny+'01') 
                                   group by a.vip
                                ) a;

                                select @halfvip=count(a.vip) 
                                from
                                  (select  a.vip
                                   from zmd_t_lsdjb a
                                   inner join yx_t_vipkh vip on a.vip=vip.kh 
                                   where a.djbs=1 and isnull(a.vip,'')<>'' and a.mdid=@mdid 
                                   and a.rq>=DATEADD(month,-6,@ny+'01') and a.rq<dateadd(MONTH,1,@ny+'01')
                                   group by a.vip
                                ) a;
                                select isnull(@vipCount,0) as vipCount,isnull(@xfvip,0) as thisNum,isnull(@vipCount,0)-isnull(@halfvip,0) otherNum;";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@mdid", mdid));
            param.Add(new SqlParameter("@ny", ny));
            string errinfo = MDal.ExecuteQuerySecurity(strsql, param, out dt);
            if (errinfo == "" && errinfo.Length == 0)
            {
                if (dt.Rows.Count > 0)
                {
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                }
                else
                {
                    clsSharedHelper.WriteErrorInfo("计算图表数据时查询不到数据！");
                }
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errinfo);
            }
            dt.Rows.Clear(); dt.Dispose();  //释放资源
        };
    }
    
    
    public void getVipAccountingData(string mdid,string ny){
             using (LiLanzDALForXLM ADal = new LiLanzDALForXLM(FXDBConnStr))
        {
            DataTable dt = null;

            string strsql = @"  declare @vipje decimal(18,2);
                                declare @zje decimal(18,2);

                                select @vipje=sum(case when a.djlb<0 then -a.je else a.je end)  
                                from zmd_v_lsdjmx a 
                                inner join yx_t_vipkh vip on a.vip=vip.kh       
                                where a.djbs=1 and a.mdid=@mdid and a.rq>=@ny+'01' and a.rq<DATEADD(month,1,@ny+'01') ;

                                select @zje=sum(case when a.djlb<0 then -a.je else a.je end)  
                                from zmd_v_lsdjmx a    
                                where a.djbs=1 and a.mdid=@mdid and a.rq>=@ny+'01' and a.rq<DATEADD(month,1,@ny+'01') ;

                                select isnull(@vipje,0.00) as vipje,isnull(@zje,0.00)-isnull(@vipje,0.00) as otherje;
                          ";

            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@mdid", mdid));
            param.Add(new SqlParameter("@ny", ny));
            string errinfo = ADal.ExecuteQuerySecurity(strsql,param,out dt);
            if (errinfo == "" && errinfo.Length == 0)
            {
                if (dt.Rows.Count > 0)
                {
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                }
                else
                {
                    clsSharedHelper.WriteErrorInfo("计算图表数据时查询不到数据！");
                }
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("统计数据时出错 info:"+errinfo);
            }
            dt.Rows.Clear(); dt.Dispose();  //释放资源    
        };                
    } 
    
   

    public void getVipFrequencyData(string mdid,string ny)
    {

        using (LiLanzDALForXLM FDal = new LiLanzDALForXLM(FXDBConnStr))
        { 
            DataTable dt = null;
           
            //零售单客单量, 仅当月零售或当月零售并当月退货的单据.
            string strsql = @" select  ls.id,SUM(ls.sl) lssl into #lsd
                               from zmd_v_lsdjmx ls
                               where ls.djbs=1 and ls.mdid=@mdid and ls.djlb>0 and convert(varchar(6),ls.rq,112)=@ny
                               group by ls.id;

                               select c.lydjid,SUM(th.sl) thsl into #thd
                               from zmd_v_lsdjmx th
                               inner join Zmd_T_Lsdjglb c on th.id=c.id 
                               where th.djbs=1 and exists (select ls.id from #lsd ls where ls.id=c.lydjid )
                               group by c.lydjid ;  
                           
                               select ls.id,ls.lssl,th.thsl into #temp
                               from #lsd ls
                               left join #thd th on ls.id=th.lydjid;

                               select a.sl ,count(a.id)  as num into #t
                               from(
                                   select ID,isnull(lssl,0)-isnull(thsl,0) sl from #temp where isnull(lssl,0)-isnull(thsl,0)>0
                               ) a 
                               group by a.sl;

                               select cast(a.sl as varchar)+'件' as js ,a.sl,sum(a.num) as num
                               from #t a
                               group by a.sl
                               having a.sl<=3
                               union all
                               select '3件以上' as js,'4' as sl,sum(a.num) as num
                               from #t a 
                               where a.sl>3
                               having count(a.num)>0;
                               drop table #thd;
                               drop table #lsd;
                               drop table #temp;
                               drop table #t;";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@mdid", mdid));
            param.Add(new SqlParameter("@ny", ny));
            string errinfo = FDal.ExecuteQuerySecurity(strsql, param, out dt);
            
            if (errinfo == "" && errinfo.Length == 0)
            {
                if (dt.Rows.Count > 0)
                {
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                }
                else
                {
                    clsSharedHelper.WriteErrorInfo("计算图表数据时查询不到数据！");
                }
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errinfo);
            }
            dt.Rows.Clear(); dt.Dispose();  //释放资源
        };
    }
    
    public void getVipActivityData(string mdid, string ny)
    {
        using (LiLanzDALForXLM ADal = new LiLanzDALForXLM(FXDBConnStr))
        {
            DataTable dt = null;
            string strsql = @" declare @kjny table(dm varchar(6));
                               declare @ks varchar(6);
                               declare @js varchar(6);
                               declare @times int;
                               set @times=-6;
                               set @js=@ny;
                               set @ks=convert(varchar(6),dateadd(month,@times+1,cast(@js+'01' as datetime)),112);
 
                               select convert(varchar(6),vip.jdrq,112) as ny,COUNT(distinct vip.kh) as activNum ,row_number()over(order by convert(varchar(6),vip.jdrq,112)) as xh into #temp
                               from YX_T_Vipkh vip
                               where  isnull(vip.kh,'')<>'' and vip.mdid=@mdid
                               and vip.jdrq<=dateadd(month,1,@js+'01') and vip.jdrq>=@ks+'01'
                               group by convert(varchar(6),vip.jdrq,112);
 
                               while @ks<=@js
                                  begin
                                     insert into @kjny(dm)
                                     select @ks;
                                     set @ks=convert(char(6),dateadd(m,1,@ks+'01'),112);
                                  end
 
                               select right(a.dm,2) as ny,isnull(b.activNum,0) activNum,isnull((select  sum(c.activNum) from #temp c where c.xh<=b.xh),0) as sumNum
                               from @kjny a                          
                               left join  #temp b on a.dm=b.ny;
                               drop table #temp;";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@mdid", mdid));
            param.Add(new SqlParameter("@ny", ny));
            string errinfo = ADal.ExecuteQuerySecurity(strsql, param, out dt);
            if (errinfo == "" && errinfo.Length == 0)
            {
                if (dt.Rows.Count > 0)
                {
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                }
                else
                {
                    clsSharedHelper.WriteErrorInfo("计算图表数据时查询不到数据！");
                }
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errinfo);
            }
            dt.Rows.Clear(); dt.Dispose();  //释放资源
        };
    }
</script>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
<meta charset="utf-8" />
    <title></title>    
</head>
<body>
    <form id="form1" runat="server">   
    </form>
</body>
</html>