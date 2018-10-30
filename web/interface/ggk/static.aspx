<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server"> 
    protected void Page_Load(object sender, EventArgs e)
    {
        string rq = Convert.ToString(Request.Params["rq"]);
        if (rq == "" || rq == null) {
            clsSharedHelper.WriteErrorInfo("rq is null");
            return;
        }            
        try {
            Convert.ToDateTime(rq);           
        }catch(Exception ex){
            clsSharedHelper.WriteErrorInfo("请传入合法的日期yyy-MM-ddd");
            return;
        }

        GetStatic(rq);
    }

    private void GetStatic(string cxrq) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM("server=192.168.35.62;database=weChatPromotion;uid=lqf;pwd=liqf,456"))
        {
            string str_sql = @"select isnull(b.alls,0) allsums,isnull(b.awards1,0) alla1,isnull(b.awards2,0) alla2,isnull(b.awards3,0) alla3,isnull(b.awards4,0) alla4,
                                a.pageviews,a.gametimes,a.gamers,isnull(c.zawards1,0) za1,isnull(c.zawards2,0) za2,isnull(c.zawards3,0) za3,isnull(c.zawards4,0) za4,
                                (select sum(case when prizeid<>0 and userid=0 then 1 else 0 end) from tm_t_gamerecords) freesums,
                                isnull(d.get1,0) get1,isnull(d.get2,0) get2,isnull(d.get3,0) get3,isnull(d.gameallget,0) gameallget,isnull(d.allget,0) allget,
                                isnull(e.free1,0) free1,isnull(e.free2,0) free2,isnull(e.free3,0) free3,isnull(e.free4,0) free4,
                                isnull(b.daya1,0) daya1,isnull(b.daya2,0) daya2,isnull(b.daya3,0) daya3,isnull(b.daya4,0) daya4
                                from (
                                 select convert(varchar(10),a.gametime,120) rq,count(a.id) pageviews,
                                 sum(case when a.isconsume=1 then 1 else 0 end) gametimes,count(distinct a.userid) gamers
                                 from tm_t_gamerecords a
                                 where a.gameid=1 and a.userid<>0 and convert(varchar(10),a.gametime,120)=@cxrq
                                 group by convert(varchar(10),a.gametime,120)
                                ) a
                                left join (
                                 select count(a.id) alls,
                                 sum(case when a.prizeid=1 then 1 else 0 end) awards1,
                                 sum(case when a.prizeid=2 then 1 else 0 end) awards2,
                                 sum(case when a.prizeid=3 then 1 else 0 end) awards3,
                                 sum(case when a.prizeid=4 then 1 else 0 end) awards4,
                                sum(case when a.prizeid=1 and convert(varchar(10),a.activetime,120)=@cxrq then 1 else 0 end) daya1,
                                sum(case when a.prizeid=2 and convert(varchar(10),a.activetime,120)=@cxrq then 1 else 0 end) daya2,
                                sum(case when a.prizeid=3 and convert(varchar(10),a.activetime,120)=@cxrq then 1 else 0 end) daya3,
                                sum(case when a.prizeid=4 and convert(varchar(10),a.activetime,120)=@cxrq then 1 else 0 end) daya4
                                 from tm_t_gamerecords a
                                 where a.prizeid<>0 --and convert(varchar(10),a.activetime,120)=@cxrq
                                ) b on 1=1
                                left join (
                                select convert(varchar(10),a.createtime,120) rq,count(distinct a.userid) zawards,
                                 sum(case when a.prizeid=1 then 1 else 0 end) zawards1,
                                 sum(case when a.prizeid=2 then 1 else 0 end) zawards2,
                                 sum(case when a.prizeid=3 then 1 else 0 end) zawards3,
                                 sum(case when a.prizeid=4 then 1 else 0 end) zawards4
                                 from tm_t_getprizerecords a
                                 where a.prizeid<>0 and a.gameid=1 and convert(varchar(10),a.createtime,120)=@cxrq
                                 group by convert(varchar(10),a.createtime,120)
                                ) c on a.rq=c.rq
                                left join (
                                select sum(case when prizeid=1 then 1 else 0 end) get1,sum(case when prizeid=2 then 1 else 0 end) get2,
                                sum(case when prizeid=3 then 1 else 0 end) get3,sum(case when gameid=1 then 1 else 0 end) gameallget,count(id) allget
                                from tm_t_getprizerecords where isget=1
                                ) d on 1=1
                                left join (
                                select sum(case when prizeid=1 then 1 else 0 end) free1,sum(case when prizeid=2 then 1 else 0 end) free2,
                                sum(case when prizeid=3 then 1 else 0 end) free3,sum(case when prizeid=4 then 1 else 0 end) free4
                                from tm_t_gamerecords where gameid=0 and userid=0 and isconsume=0
                                ) e on 1=1";
            DataTable dt = null;
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@cxrq",cxrq));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                string rt = dt.Rows[0][0].ToString() + "|" + dt.Rows[0][1].ToString() + "|" + dt.Rows[0][2].ToString() + "|" + dt.Rows[0][3].ToString() + "|" + dt.Rows[0][4].ToString();
                rt += "|" + dt.Rows[0][5].ToString() + "|" + dt.Rows[0][6].ToString() + "|" + dt.Rows[0][7].ToString() + "|" + dt.Rows[0][8].ToString() + "|" + dt.Rows[0][9].ToString();
                rt += "|" + dt.Rows[0][10].ToString() + "|" + dt.Rows[0][11].ToString() + "|" + dt.Rows[0][12].ToString();
                rt += "|" + dt.Rows[0][13].ToString() + "|" + dt.Rows[0][14].ToString() + "|" + dt.Rows[0][15].ToString() + "|" + dt.Rows[0][16].ToString() + "|" + dt.Rows[0][17].ToString();
                rt += "|" + dt.Rows[0][18].ToString() + "|" + dt.Rows[0][19].ToString() + "|" + dt.Rows[0][20].ToString() + "|" + dt.Rows[0][21].ToString();
                rt += "|" + dt.Rows[0][22].ToString() + "|" + dt.Rows[0][23].ToString() + "|" + dt.Rows[0][24].ToString() + "|" + dt.Rows[0][25].ToString();
                clsSharedHelper.WriteInfo(rt);
            }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
