using nrWebClass;
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
 

public partial class WebService_原料检测项目 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string DBConnStr = "server='192.168.35.10';uid=abeasd14ad;pwd=+AuDkDew;database=tlsoft";
        List<Dictionary<string, string>> xg = new List<Dictionary<string, string>>();
        int errcode = 0;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            string str_sql = @"
DECLARE @ddbh VARCHAR(max);DECLARE @spkh VARCHAR(max);DECLARE @ddbh2 VARCHAR(max);
SET @ddbh='DJP19020002' ;SET @ddbh2='DJP19030761';
 SET @spkh='19QXL314'
--标准量 table0
 SELECT a.sphh,b.cmdm,SUM(b.sl0) sl0 --INTO #bz -- DROP TABLE #bz
 FROM dbo.YX_T_Spcgjhb a  
 INNER JOIN dbo.YX_T_spcgjhcmmx b ON a.id=b.id
 INNER JOIN zw_t_htdddjb ht ON ht.id=a.htddid AND ht.ddbh=@ddbh 
 GROUP BY a.sphh,b.cmdm
--入库量table1
SELECT a.id,a.mxid,a.sphh,e.cmdm,SUM(sl0) sl0  --INTO #al -- DROP TABLE #al
FROM dbo.yx_v_kcdjmx a 
INNER JOIN zw_t_htdddjb b ON a.htddid=b.id AND b.ddbh=@ddbh
INNER JOIN dbo.YX_T_kcdjcmmx e ON a.mxid=e.mxid
 WHERE a.djlx=141  
 GROUP BY a.sphh,e.cmdm,a.id,a.mxid
--table2
SELECT DISTINCT A.DJH,A.RQ,A.djlx INTO #DD -- DROP TABLE #DD
 FROM dbo.yx_v_dddjmx A
INNER JOIN zw_t_htdddjb B ON A.htddid=B.ID AND B.DDBH=@ddbh
 WHERE A.DJLX IN (221,225)

select * from #DD

 --检查table3
 SELECT a.* 
FROM dbo.yx_v_kcdjmx A --入库
 INNER JOIN #DD B ON A.lydjlx=B.DJLX AND CONVERT(VARCHAR(6),B.RQ,112)+B.DJH=A.cgdjh
 left JOIN dbo.yx_v_kcdjmx C ON C.djlx=111 AND C.lydjid=a.id AND c.lydjlx=a.djlx AND a.sphh=c.sphh --出库
 left JOIN dbo.YX_T_dddjb e ON e.djlx=224 AND c.zbyid=e.id--到货
 LEFT JOIN YX_T_kcdjb f ON f.djlx=141 AND f.lydjid=e.id
 WHERE A.DJLX=141 AND A.TZID=11360  AND f.id IS NULL 

";
         
            DataSet ds = new DataSet();
            string errinfo = dal.ExecuteQuery(str_sql, out ds);
            if (errinfo != "")            
                return;
            DataTable 标准量 = ds.Tables[0];
            DataTable rk = ds.Tables[1];
            DataTable 下单221225 = ds.Tables[2];
            DataTable isrk = ds.Tables[3];
            if (isrk.Rows.Count > 0)
            {
                Response.Write("有目标合同有没入库的刷吗");
                return ;
            }
           
            foreach(DataRow dr in 标准量.Rows)
            {//a.sphh,b.cmdm,SUM(b.sl0) sl0
                int sl0 =int.Parse( dr["sl0"].ToString());//要满足的量
                string sphh = (dr["sphh"].ToString());
                string cmdm = (dr["cmdm"].ToString());
                DataRow[] rkdr = rk.Select("sphh='" + sphh + "' and cmdm='" + cmdm + "'");
                if (rkdr.Length > 0)
                {
                    for(int i = 0; i < rkdr.Length; i++)
                    {
                        if(int.Parse(rkdr[i]["sl0"].ToString())>=sl0)
                        {
                            Dictionary<string, string> t = new Dictionary<string, string>();
                            t.Add("mxid", rkdr[i]["mxid"].ToString());
                            t.Add("sl0", (int.Parse(rkdr[i]["sl0"].ToString())-sl0).ToString() );
                            xg.Add(t);
                            rkdr[i]["sl0"] = (int.Parse(rkdr[i]["sl0"].ToString()) - sl0).ToString();
                            sl0 = 0;
                        }
                        else
                        {
                            rkdr[i]["sl0"] = "0";
                            sl0 = sl0 - int.Parse(rkdr[i]["sl0"].ToString());
                        }
                        if (sl0 == 0)
                        {
                            break;
                        }
                    }

                    if (sl0 > 0)
                    {
                        Response.Write(sphh + "|" + cmdm + "没数量不够");
                        errcode = 10;
                        break;
                    }

                }else
                {
                    Response.Write(sphh + "|" + cmdm + "没数量");
                    errcode = 20;
                    break;
                }


            }
            if (xg.Count > 0 && errcode==0)
            {
                string insql = "";
                for(int i = 0; i < xg.Count; i++)
                {
                    insql += " isnert ht20190605 (mxid,sl0) values('" + xg[i]["mxid"] + "','" + xg[i]["sl0"] + "') ";
                }
                DataSet tmp = new DataSet();
                 dal.ExecuteQuery(insql, out tmp);

            }

        }
    }
}