<%@ WebHandler Language="C#" Class="SalesChartCore" %>
using System;
using System.Web;
using nrWebClass;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;
using System.Threading;

public class SalesChartCore : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ClearHeaders();
        context.Response.AppendHeader("Access-Control-Allow-Origin", "*");
        string requestHeaders = context.Request.Headers["Access-Control-Request-Headers"];
        context.Response.AppendHeader("Access-Control-Allow-Headers", string.IsNullOrEmpty(requestHeaders) ? "*" : requestHeaders);
        context.Response.AppendHeader("Access-Control-Allow-Methods", "POST, GET,OPTIONS");


        context.Response.ContentType = "text/plain";
        string ctrl = Convert.ToString(context.Request.Params["ctrl"]);
        string rt = "";
        DataSerach ds = new DataSerach();
        if (string.IsNullOrEmpty(ctrl)) ctrl = "";
        ctrl = ctrl.ToLower();
        switch (ctrl)
        {
            //单品
            case "sphhranking":
                rt = ds.singleProduct();
                break;
            //单店排行
            case "storesranking":
                rt = ds.singleStore();
                break;
            //渠道分析
            case "channel":
                rt = ds.channel();
                break;
            //货品分析（品类）
            case "splbranking":
                string kfbh = Convert.ToString(context.Request.Params["kfbh"]);
                string type = Convert.ToString(context.Request.Params["type"]);
                rt = ds.saleCategory(kfbh, type);
                break;
            //销售费用分析
            case "costpay":
                rt = ds.costPay();
                break;
            //省份销售
            case "provincesale":
                rt = ds.provinceSale();
                break;
            case "salecount":
                rt = ds.saleCount();
                break;
            case "mdlocation":
                rt = ds.mdLocation();
                break;
            case "test":
                rt = Convert.ToString("tzid=" + context.Session["tzid"]);
                break;
            case "mddistribution":
                rt = ds.mdDistribution();
                break;
            default:
                rt = JsonConvert.SerializeObject(new Response("无效请求"));
                break;
        }
        clsSharedHelper.WriteInfo(rt);
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}
#region 逻辑处理类
public class DataSerach
{
    public string CXDBConstr = "server='192.168.35.20';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft;";
    public static string OADBConstr = "server='192.168.35.10';uid=lllogin;pwd=rw1894tla;database=tlsoft";
    public string WXDBConstr = "server=192.168.35.62;database=weChatPromotion;uid=erpUser;pwd=fjKL29ji.353";
    private string FXDBConstr = "server='192.168.35.11';uid=ABEASD14AD;pwd=+AuDkDew;database=FXDB";
    static Dictionary<int, string> dic_splb = null;
    static object splblock = new object();
    /// <summary>
    /// 加载splb到内存
    /// </summary>
    private static void getSplb()
    {
        if (dic_splb == null)
        {
            lock (splblock)
            {
                string mysql = "SELECT id,mc FROM dbo.YX_T_Splb WHERE ty=0 AND jb=3";
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OADBConstr))
                {
                    DataTable dt;
                    string errInfo = dal.ExecuteQuery(mysql, out dt);
                    if (errInfo == "" && dt.Rows.Count > 0)
                    {
                        dic_splb = new Dictionary<int, string>();
                        foreach (DataRow dr in dt.Rows)
                        {
                            dic_splb.Add(Convert.ToInt32(dr["id"]), Convert.ToString(dr["mc"]));
                        }
                    }
                }
            }
        }
    }

    /// <summary>
    /// 单品分析
    /// </summary>
    /// <returns></returns>
    public string singleProduct()
    {
        string rt = "", errInfo;
        string mysql = @"SELECT TOP 6 cast( SUM(a.sl*(ABS(a.djlb)/a.djlb)) as int) sl,a.sphh,b.spmc
                        FROM zmd_v_lsdjmx a INNER JOIN yx_T_spdmb b ON a.sphh=b.sphh
                        WHERE a.djbs=1 and b.splbid<>1280 AND  rq>DATEADD(MONTH,-1,GETDATE()) 
                        GROUP BY a.sphh,b.spmc
                        ORDER BY sl DESC";
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBConstr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));
            rt = JsonConvert.SerializeObject(new Response(dt));
            clsSharedHelper.DisponseDataTable(ref dt);
        }
        return rt;
    }
    /// <summary>
    /// 单店排行
    /// </summary>
    /// <returns></returns>
    public string singleStore()
    {
        DateTime startdate, enddate;
        startdate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
        enddate = new DateTime(DateTime.Now.Year, DateTime.Now.Month + 1, 1);
        string rt = "", errInfo;
        string mysql = @"SELECT TOP 20 CAST(SUM(a.je*ABS(a.djlb)/a.djlb) AS INT) je,mdid,'' mdmc,0.0 as sjmj,0.0 as lastyear
                         FROM zmd_v_lsdjmx a 
                         WHERE rq>=@startdate AND rq<@enddate
                         GROUP BY a.mdid
                         ORDER BY je DESC";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@startdate", startdate));
        para.Add(new SqlParameter("@enddate", enddate));
        DataTable dt, dt_low, dt_lastyear;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBConstr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));
            if (dt.Rows.Count < 1) return JsonConvert.SerializeObject(new Response("未找到销售数据"));

            //mysql = @"SELECT TOP 10  CAST(SUM(a.je*ABS(a.djlb)/a.djlb) AS INT) je,mdid,'' mdmc,0.0 as sjmj,0.0 as lastyear
            //             FROM zmd_v_lsdjmx a 
            //             WHERE rq>=@startdate AND rq<@enddate
            //             GROUP BY a.mdid
            //             ORDER BY je ASC";
            //para.Clear();
            //para.Add(new SqlParameter("@startdate", startdate));
            //para.Add(new SqlParameter("@enddate", enddate));
            //errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt_low);
            //if (errInfo != "") return errInfo;
            //foreach (DataRow dr in dt_low.Rows)
            //{
            //    dt.ImportRow(dr);
            //}
            //clsSharedHelper.DisponseDataTable(ref dt_low);

            string mdidStr = "0";
            Dictionary<int, int> dic_mdid = new Dictionary<int, int>();
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                mdidStr = string.Concat(mdidStr, ",", dt.Rows[i]["mdid"]);
                dic_mdid.Add(Convert.ToInt32(dt.Rows[i]["mdid"]), i);
            }
            mysql = string.Format(@"SELECT a.mdid,a.mdmc,CASE WHEN b.djlx=1 THEN b.sjmj ELSE b.jzmj END  as sjmj,b.id
                    FROM  t_mdb a 
                    LEFT JOIN  yx_t_jmspb b ON a.mdid=b.mdid AND b.id IN(SELECT MAX(id) FROM yx_t_jmspb WHERE mdid IN({0}) GROUP BY mdid)
                    WHERE a.mdid IN({0})   ", mdidStr);
            DataTable dt_jm;
            errInfo = dal.ExecuteQuery(mysql, out dt_jm);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));

            int rowindex = 0;
            for (int i = 0; i < dt_jm.Rows.Count; i++)
            {
                rowindex = Convert.ToInt32(dt_jm.Rows[i]["mdid"]);
                dt.Rows[dic_mdid[rowindex]]["mdmc"] = dt_jm.Rows[i]["mdmc"];
                dt.Rows[dic_mdid[rowindex]]["sjmj"] = dt_jm.Rows[i]["sjmj"];
            }
            //去年本月数据
            mysql = string.Format(@"SELECT CAST(SUM(a.je*ABS(a.djlb)/a.djlb) AS INT) je,mdid
                         FROM zmd_v_lsdjmx a 
                         WHERE rq>=DATEADD(YEAR,-1, @startdate)  AND rq<DATEADD(YEAR,-1,@enddate) and a.mdid IN({0})
                         GROUP BY a.mdid ", mdidStr);

            para.Clear();
            para.Add(new SqlParameter("@startdate", startdate));
            para.Add(new SqlParameter("@enddate", enddate));
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt_lastyear);
            for (int i = 0; i < dt_lastyear.Rows.Count; i++)
            {
                rowindex = Convert.ToInt32(dt_jm.Rows[i]["mdid"]);
                dt.Rows[dic_mdid[rowindex]]["lastyear"] = dt_lastyear.Rows[i]["je"];
            }
            rt = JsonConvert.SerializeObject(new Response(dt));
            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.DisponseDataTable(ref dt_jm);
            clsSharedHelper.DisponseDataTable(ref dt_lastyear);
        }
        return rt;
    }
    /// <summary>
    /// 渠道分析
    /// </summary>
    /// <returns></returns>
    public string channel()
    {
        string rt = "", errInfo;

        string mysql = @"SELECT COUNT( B.mdid)'totalStores',SUM(c.sjmj) 'totalArea',
                        SUM(CASE WHEN c.ISZG=0 THEN 1 ELSE 0 END) 'totalLeague',
                        SUM(CASE WHEN c.ISZG=0 AND d.cs='ZMD' THEN 1 ELSE 0 END) 'leagueStore',
                        SUM(CASE WHEN c.ISZG=0 AND d.cs='ZMT' THEN 1 ELSE 0 END) 'leagueHall',
                        SUM(CASE WHEN c.ISZG=0 THEN c.sjmj ELSE 0 END) 'leagueArea',
                        SUM(CASE WHEN c.ISZG=1 THEN 1 ELSE 0 END) 'totalModify',
                        SUM(CASE WHEN c.ISZG=1 AND d.cs='ZMD' THEN 1 ELSE 0 END) 'modifyStore',
                        SUM(CASE WHEN c.ISZG=1 AND d.cs='ZMT' THEN 1 ELSE 0 END) 'modifyHall',
                        SUM(CASE WHEN c.ISZG=1 THEN c.SJMJ ELSE 0 END) 'modifyArea',
                        SUM(CASE WHEN c.ISZG=2 THEN 1 ELSE 0 END) 'totalNewImage',
                        SUM(CASE WHEN c.ISZG=2 AND d.cs='ZMD' THEN 1 ELSE 0 END) 'newImagStore',
                        SUM(CASE WHEN c.ISZG=2  AND d.cs='ZMT' THEN 1 ELSE 0 END) 'newImagHall',
                        SUM(CASE WHEN c.ISZG=2 THEN c.SJMJ ELSE 0 END) 'newImageArea',
                        SUM(CASE WHEN b.mdmc like '%万达%' THEN 1 ELSE 0 END) 'wanda',
                        SUM(CASE WHEN a.khfl IN('xm','xk','xn') THEN 1 ELSE 0 END) 'light'
                        FROM yx_t_khb A 
                        INNER JOIN t_mdb B ON A.khid = B.khid
                        INNER JOIN yx_t_jmspb c ON b.mdid=c.mdid AND c.id IN(SELECT MAX(id) FROM yx_t_jmspb WHERE shbs=1 GROUP BY mdid)
                        INNER JOIN T_xtdm d ON c.JYFS =d.gjz AND d.ssid=8780
                        LEFT JOIN yx_t_zxspb e ON b.mdid=e.mdid
                        WHERE  A.ty = 0 AND B.ty = 0  AND e.id IS NULL";
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OADBConstr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
        }

        if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));

        rt = JsonConvert.SerializeObject(new Response(dt));
        clsSharedHelper.DisponseDataTable(ref dt);
        return rt;
    }
    /// <summary>
    /// 货品分析 
    /// </summary>
    /// <param name="kfbh"></param>
    /// <param name="type"></param>
    /// <returns></returns>
    public string saleCategory(string kfbh, string type)
    {
        getSplb();
        if (dic_splb == null) return JsonConvert.SerializeObject(new Response("无法获取商品类别"));
        if (string.IsNullOrEmpty(type)) type = "je";
        string rt, errInfo, mysql = "";

        Dictionary<string, Dictionary<string, string>> dic_table = new Dictionary<string, Dictionary<string, string>>();//存表格内容
        Dictionary<string, string> dic_trows;//表格行内容
        DataTable dt, dt_sale, dt_last;
        if (string.IsNullOrEmpty(kfbh))//加载开发编号
        {
            mysql = "SELECT TOP 5 dm FROM dbo.YF_T_Kfbh ORDER BY id DESC";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OADBConstr))
            {
                errInfo = dal.ExecuteQuery(mysql, out dt);
                if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));
                if (dt.Rows.Count < 1) return JsonConvert.SerializeObject(new Response("缺少必要参数"));
                kfbh = dt.Rows[dt.Rows.Count - 1]["dm"].ToString();
                clsSharedHelper.DisponseDataTable(ref dt);
            }
        }

        if (type.Equals("je") || type.Equals("sl"))
        {
            mysql = string.Format(@"SELECT CAST(SUM(a.{0}*ABS(a.djlb)/a.djlb) AS INT) AS sales,CAST(SUM(a.sl*ABS(a.djlb)/a.djlb) AS INT) as xssl,b.splbid,'' mc,0.0 AS proportion
                    FROM dbo.zmd_v_lsdjmx a 
                    INNER JOIN dbo.YX_T_Spdmb b ON a.sphh=b.sphh
                    WHERE b.kfbh=@kfbh AND a.djbs=1
                    GROUP BY b.splbid ORDER BY sales DESC", type);
        }
        else return JsonConvert.SerializeObject(new Response("无效参数"));

        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@kfbh", kfbh));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBConstr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));
            if (dt.Rows.Count < 1) return JsonConvert.SerializeObject(new Response("查无数据")); ;

            decimal sumsl = Convert.ToDecimal(dt.Compute("sum(sales)", ""));
            dt_sale = dt.Clone();
            string splbid;
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                Convert.ToDecimal(dt.Rows[i]["sales"]);
                splbid = Convert.ToString(dt.Rows[i]["splbid"]);
                if (i < 9)
                {
                    //图表内容
                    DataRow dr = dt_sale.NewRow();
                    dr["splbid"] = splbid;
                    dr["mc"] = dic_splb[Convert.ToInt32(splbid)];
                    //  dr["sales"]=Convert.ToDecimal(dt.Rows[i]["sales"]).ToString(fomat);
                    dr["sales"] = dt.Rows[i]["sales"];
                    dr["proportion"] = (Convert.ToDecimal(dt.Rows[i]["sales"]) / sumsl * 100).ToString("0.00");
                    dt_sale.Rows.Add(dr);

                    //列表内容
                    dic_trows = new Dictionary<string, string>();
                    dic_trows.Add("mc", dic_splb[Convert.ToInt32(splbid)]);
                    dic_trows.Add("sales", Convert.ToDecimal(dt.Rows[i]["sales"]).ToString());
                    dic_trows.Add("xssl", Convert.ToDecimal(dt.Rows[i]["xssl"]).ToString("0"));
                    dic_trows.Add("dhs", "0");
                    dic_trows.Add("lastSale", "0");
                    dic_trows.Add("sql", "0");
                    dic_trows.Add("tqdb", "0");
                    dic_table.Add(splbid, dic_trows);
                }
                else
                {
                    dt.Rows[9]["sales"] = (Convert.ToDecimal(dt.Rows[9]["sales"]) + Convert.ToDecimal(dt.Rows[i]["sales"]));
                }
            }

            string qtsales = "0", qtxssl = "0";
            if (dt.Rows.Count >= 9)
            {
                DataRow dr = dt_sale.NewRow();
                dr["splbid"] = "0";
                dr["mc"] = "其他";
                dr["sales"] = Convert.ToDecimal(dt.Rows[9]["sales"]).ToString();
                dr["proportion"] = (Convert.ToDecimal(dt.Rows[9]["sales"]) / sumsl * 100).ToString("0.00");
                dt_sale.Rows.Add(dr);
                qtsales = Convert.ToDecimal(dt.Rows[9]["sales"]).ToString();
                qtxssl = Convert.ToDecimal(dt.Rows[9]["xssl"]).ToString();
            }
            //列表内容的其他行
            dic_trows = new Dictionary<string, string>();
            dic_trows.Add("mc", "其他");
            dic_trows.Add("sales", qtsales);
            dic_trows.Add("xssl", qtxssl);
            dic_trows.Add("dhs", "0");
            dic_trows.Add("lastSale", "0");
            dic_trows.Add("sql", "0");
            dic_trows.Add("tqdb", "0");
            dic_table.Add("0", dic_trows);
            dt_sale.Columns.Remove("xssl");
            string saleaccoun = JsonConvert.SerializeObject(dt_sale);
            clsSharedHelper.DisponseDataTable(ref dt);
            //去年同期
            paras.Clear();
            paras.Add(new SqlParameter("@kfbh", string.Concat((Convert.ToInt32(kfbh.Substring(0, 4)) - 1).ToString(), kfbh.Substring(4, 1))));
            mysql = string.Format(@"SELECT CAST(SUM(a.{0}*ABS(a.djlb)/a.djlb) AS INT) AS lastsale,b.splbid,'' mc,0.0 AS proportion
                        FROM dbo.zmd_v_lsdjmx a 
                        INNER JOIN dbo.YX_T_Spdmb b ON a.sphh=b.sphh
                        WHERE b.kfbh=@kfbh AND a.djbs=1 AND a.rq<DATEADD(MONTH,-12,GETDATE())
                        GROUP BY b.splbid
                        HAVING CAST(SUM(a.je*ABS(a.djlb)/a.djlb) AS INT)<>0
                        ORDER BY lastsale DESC", type);
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));
            sumsl = Convert.ToDecimal(dt.Compute("sum(lastsale)", ""));
            dt_last = dt.Clone();
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                splbid = dt.Rows[i]["splbid"].ToString();
                if (i < 9)
                {
                    DataRow dr = dt_last.NewRow();
                    dr["splbid"] = dt.Rows[i]["splbid"];
                    dr["mc"] = dic_splb[Convert.ToInt32(dr["splbid"])];
                    dr["lastsale"] = Convert.ToDecimal(dt.Rows[i]["lastsale"]).ToString();
                    dr["proportion"] = (Convert.ToDecimal(dt.Rows[i]["lastsale"]) / sumsl * 100).ToString("0.00");
                    dt_last.Rows.Add(dr);
                }
                else
                    dt.Rows[9]["lastsale"] = (Convert.ToDecimal(dt.Rows[9]["lastsale"]) + Convert.ToDecimal(dt.Rows[i]["lastsale"])).ToString();

                if (dic_table.ContainsKey(splbid))
                {
                    dic_table[splbid]["lastSale"] = Convert.ToDecimal(dt.Rows[i]["lastsale"]).ToString();
                }
                else
                    dic_table["0"]["lastSale"] = (Convert.ToDecimal(dic_table["0"]["lastSale"]) + Convert.ToDecimal(dt.Rows[i]["lastsale"])).ToString();
            }
            if (dt.Rows.Count >= 9)
            {
                DataRow dr = dt_last.NewRow();
                dr["splbid"] = "0";
                dr["mc"] = "其他";
                dr["lastsale"] = Convert.ToDecimal(dt.Rows[9]["lastsale"]).ToString();
                dr["proportion"] = (Convert.ToDecimal(dt.Rows[9]["lastsale"]) / sumsl * 100).ToString("0.00");
                dt_last.Rows.Add(dr);
            }

            string thesameperiod = JsonConvert.SerializeObject(dt_last);
            clsSharedHelper.DisponseDataTable(ref dt);

            mysql = string.Format(@"SELECT c.splbid,sum(a.sl) as dhs
                    FROM yx_v_dddjmx a inner join yx_t_spdmb c on c.tzid=1 and a.sphh=c.sphh  
                    WHERE a.tzid=1 and a.djbs=1 AND c.kfbh=@kfbh  and a.djlx=201 
                    GROUP BY c.splbid ", type);
            paras.Clear();
            paras.Add(new SqlParameter("@kfbh", kfbh));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));
            foreach (DataRow dr in dt.Rows)
            {
                splbid = dr["splbid"].ToString();
                if (dic_table.ContainsKey(splbid))
                {
                    dic_table[splbid]["dhs"] = Convert.ToDecimal(dr["dhs"]).ToString();
                    dic_table[splbid]["sql"] = (Convert.ToDecimal(dic_table[splbid]["xssl"]) / Convert.ToDecimal(dic_table[splbid]["dhs"])).ToString("0.00%");
                    dic_table[splbid]["tqdb"] = ((Convert.ToDecimal(dic_table[splbid]["sales"]) - Convert.ToDecimal(dic_table[splbid]["lastSale"])) / Convert.ToDecimal(dic_table[splbid]["sales"])).ToString("0.00%");

                }
                else
                    dic_table["0"]["dhs"] = (Convert.ToDecimal(dic_table["0"]["dhs"]) + Convert.ToDecimal(dr["dhs"])).ToString();
            }
            dic_table["0"]["sql"] = (Convert.ToDecimal(dic_table["0"]["xssl"]) / Convert.ToDecimal(dic_table["0"]["dhs"])).ToString("0.00%");
            dic_table["0"]["tqdb"] = ((Convert.ToDecimal(dic_table["0"]["sales"]) - Convert.ToDecimal(dic_table["0"]["lastSale"])) / Convert.ToDecimal(dic_table["0"]["sales"])).ToString("0.00%");

            Dictionary<string, string>[] dicarr = new Dictionary<string, string>[dic_table.Count];
            dic_table.Values.CopyTo(dicarr, 0);
            string tablelist = JsonConvert.SerializeObject(dicarr);
            clsSharedHelper.DisponseDataTable(ref dt);
            dic_table.Clear();
            Dictionary<string, object> dicrt = new Dictionary<string, object>();
            dicrt.Add("saleaccoun", dt_sale);
            dicrt.Add("lastsale", dt_last);
            dicrt.Add("tablelist", dt);
            rt = JsonConvert.SerializeObject(new Response(dicrt));
            clsSharedHelper.DisponseDataTable(ref dt_sale);
            clsSharedHelper.DisponseDataTable(ref dt_last);
            clsSharedHelper.DisponseDataTable(ref dt);
        }//end using
        return rt;
    }

    // <summary>
    /// 费用列表 V2.0
    /// </summary>
    /// <returns></returns>
    public string costPay()
    {
        string rt = "", errInfo;
        string ny = DateTime.Now.AddMonths(-1).ToString("yyyyMM");
        string mysql = @"SELECT  SUM(CASE WHEN B.yefx = 0 THEN B.bqjf ELSE B.bqdf END) LSJE ,A.SSKHID ,A.SSKHMC,0.0 fyje,0.0 fyzb,0.0 dzje,0.0 dzzb,0.0 zxje,0.0 zxzb,0.0 sdje,0.0 sdzb,0.0 gzje,0.0 gzzb, 0.0 as qtje,0.0 as qtzb
                        FROM    (SELECT B.khid ,A.khid SSKHID ,A.khdm AS SSKHDM ,A.khmc AS SSKHMC ,B.khmc
                        FROM   yx_t_khb A 
                        INNER JOIN yx_t_khb B ON A.ssid = 1 AND B.ssid <> 1 
                        AND A.khlbdm <> 'G' AND B.ccid + '-' LIKE A.ccid+ '-%'  AND A.khid > 1 AND A.ty =0 AND B.ty =0
                        WHERE   LEN(A.dzbbpx) > 0 ) A
                        INNER JOIN zw_v_kmyeb B ON A.khid = B.tzid AND B.kmdm = '6001'
                        WHERE   B.ny >= @ny AND B.ny <= @ny AND A.SSKHID <> A.khid AND B.hsdx = 'KM'
                        GROUP BY A.SSKHID ,A.SSKHMC";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@ny", ny));
        DataTable dt, dt_temp;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXDBConstr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));

            if (dt.Rows.Count < 1) return JsonConvert.SerializeObject(new Response("未找到数据"));
            Dictionary<int, int> dickhid = new Dictionary<int, int>();//客户对应的行数
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                dickhid.Add(Convert.ToInt32(dt.Rows[i]["SSKHID"]), i);
            }
            //获取费用的科目代码
            mysql = @"SELECT b.mxid cmdm,b.mc as lmmc,c.kmdm
                    from ( 
                        select *,row_number() over(order by qyny desc) as xh from  zw_t_zwfxfa where falx=1 and qyny<=@ny
                        ) a 
                        inner join  zw_t_zwfxfamx b on a.id=b.id 
                        inner join  zw_t_zwfxfagx c on b.mxid=c.mxid and a.id=c.id 
                        WHERE a.xh=1";
            para.Clear();
            para.Add(new SqlParameter("@ny", ny));
            dal.ConnectionString = OADBConstr;
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt_temp);
            Dictionary<string, string> dickmdm = new Dictionary<string, string>();
            string khmdstr = "''", kmdm;
            foreach (DataRow dr in dt_temp.Rows)
            {
                if (dr["lmmc"].ToString().IndexOf("店租") > -1)
                {
                    kmdm = "dzje";
                }
                else if (dr["lmmc"].ToString().IndexOf("装修") > -1)
                {
                    kmdm = "zxje";
                }
                else if (dr["lmmc"].ToString().IndexOf("水电") > -1)
                {
                    kmdm = "sdje";
                }
                else if (dr["lmmc"].ToString().IndexOf("工资") > -1)
                {
                    kmdm = "gzje";
                }
                else
                {
                    kmdm = "qtje";
                }
                dickmdm.Add(dr["kmdm"].ToString(), kmdm);
                khmdstr = string.Concat(khmdstr, ",'", dr["kmdm"].ToString(), "'");
            }
            dt_temp.Clear(); dt_temp.Dispose();
            //获取费用金额
            mysql = string.Format(@"SELECT sum(case when b.yefx = 0 then b.bqjf else b.bqdf end) as je,a.sskhid,b.kmdm
                                    FROM (SELECT B.khid ,A.khid SSKHID ,A.khdm AS SSKHDM ,A.khmc AS SSKHMC ,B.khmc
                                    FROM   yx_t_khb A 
                                    INNER JOIN yx_t_khb B ON A.ssid = 1 AND B.ssid <> 1 
                                    AND A.khlbdm <> 'G' AND B.ccid + '-' LIKE A.ccid+ '-%'  AND A.khid > 1 AND A.ty =0 AND B.ty =0
                                    WHERE   LEN(A.dzbbpx) > 0 ) a INNER JOIN  zw_v_kmyeb b ON a.khid=b.tzid
                                        WHERE hsdx = 'km' AND  ny=@ny AND kmdm IN({0}) 
                                        GROUP BY a.sskhid ,b.kmdm
                                        HAVING sum(case when b.yefx = 0 then b.bqjf else b.bqdf end)>0", khmdstr);

            para.Clear();
            para.Add(new SqlParameter("@ny", ny));
            dal.ConnectionString = FXDBConstr;
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt_temp);
            if (errInfo != "")
            {
                return errInfo + "11";
            }
            int rowindex = 0;
            string kmmc = "";
            foreach (DataRow dr in dt_temp.Rows)
            {
                rowindex = dickhid[Convert.ToInt32(dr["sskhid"])];
                kmmc = dickmdm[dr["kmdm"] + ""];
                dt.Rows[rowindex][kmmc] = Convert.ToDecimal(dt.Rows[rowindex][kmmc]) + Convert.ToDecimal(dr["je"]);
                dt.Rows[rowindex]["fyje"] = Convert.ToDecimal(dt.Rows[rowindex]["fyje"]) + Convert.ToDecimal(dr["je"]);
            }
            foreach (DataRow dr in dt.Rows)
            {
                if (Convert.ToDecimal(dr["LSJE"]) == 0)
                {
                    dr["fyzb"] = 0;
                    dr["dzzb"] = 0;
                    dr["zxzb"] = 0;
                    dr["sdzb"] = 0;
                    dr["gzzb"] = 0;
                    dr["qtzb"] = 0;
                }
                else
                {
                    dr["fyzb"] = (Convert.ToDecimal(dr["fyje"]) / Convert.ToDecimal(dr["LSJE"]) * 100).ToString("0.00");
                    dr["dzzb"] = (Convert.ToDecimal(dr["dzje"]) / Convert.ToDecimal(dr["LSJE"]) * 100).ToString("0.00");
                    dr["zxzb"] = (Convert.ToDecimal(dr["zxje"]) / Convert.ToDecimal(dr["LSJE"]) * 100).ToString("0.00");
                    dr["sdzb"] = (Convert.ToDecimal(dr["sdje"]) / Convert.ToDecimal(dr["LSJE"]) * 100).ToString("0.00");
                    dr["gzzb"] = (Convert.ToDecimal(dr["gzje"]) / Convert.ToDecimal(dr["LSJE"]) * 100).ToString("0.00");
                    dr["qtzb"] = (Convert.ToDecimal(dr["qtje"]) / Convert.ToDecimal(dr["LSJE"]) * 100).ToString("0.00");
                }
            }
            //清空变量，内存表
            dickhid.Clear(); dickhid = null;
            dickmdm.Clear(); dickmdm = null;
            //rt = DataTableToJson(dt);
            rt = JsonConvert.SerializeObject(new Response(dt));
            clsSharedHelper.DisponseDataTable(ref dt_temp);
            clsSharedHelper.DisponseDataTable(ref dt);
        }
        return rt;
    }
    public string provinceSale()
    {
        string rt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBConstr))
        {
            string mysql = @"SELECT CAST(SUM(je*ABS(a.djlb)/a.djlb) AS DECIMAL(12,2)) AS je,LEFT(c.khjc,2) AS pro
                    FROM dbo.zmd_v_lsdjmx a 
                    INNER JOIN yx_t_khb b ON a.khid=b.khid
                    INNER JOIN yx_T_khb c ON (b.ccid LIKE c.ccid+'-%' OR b.khid=c.khid) AND c.ssid=1 AND c.khid>1
                    WHERE a.djbs=1 AND  a.rq>DATEADD(MONTH,-1,GETDATE())
                    GROUP BY LEFT(c.khjc,2)";
            DataTable dt;
            string errInfo = dal.ExecuteQuery(mysql, out dt);
            rt = JsonConvert.SerializeObject(new Response(dt));
            clsSharedHelper.DisponseDataTable(ref dt);
        }
        return rt;
    }

    public string saleCount()
    {
        string mysql = @"SELECT CAST(SUM(a.je*a.djlb/ABS(a.djlb)) AS DECIMAL(11,2)) AS je,CAST(SUM(a.sl*a.djlb/ABS(a.djlb)) AS DECIMAL(11,2)) AS sl,c.khid,c.khjc
                        FROM dbo.zmd_v_lsdjmx a 
                        INNER JOIN yx_t_khb b ON a.khid=b.khid
                        INNER JOIN dbo.yx_t_khb c ON (b.khid=c.khid OR b.ccid+'-' LIKE c.ccid +'-%') AND c.ssid=1 AND c.khid<>1  AND c.khfl IN('xf','xd','xg','xk') 
                        WHERE a.djbs=1 AND a.rq>DATEADD(MONTH,-1,GETDATE())
                        GROUP BY c.khid,c.khjc";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(CXDBConstr))
        {
            DataTable dt;
            string errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));
            return JsonConvert.SerializeObject(new Response(dt));
        }
    }
    public string mdLocation()
    {
        string mysql = @"SELECT a.mdmc,a.mdid,c.Lat,c.Lng
                        FROM t_mdb a 
                        INNER JOIN dbo.yx_t_jmspb b ON a.mdid=b.mdid AND b.id IN(SELECT MAX(id) FROM yx_t_jmspb GROUP BY mdid)
                        INNER JOIN wx_t_storepointlocation c on b.id=c.mapid AND c.mapType='jm'";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OADBConstr))
        {
            DataTable dt;
            string errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));
            return JsonConvert.SerializeObject(new Response(dt));
        }
    }

    public string mdDistribution()
    {
        string rt,mysql;
        /*mysql = @"SELECT d.bz as sf,COUNT(1) AS sl
FROM dbo.t_mdb a INNER JOIN yx_T_khb b ON a.khid=b.khid 
INNER JOIN dbo.yx_t_khb c ON  c.ssid=1 AND c.khfl IN('xf','xd','xg','xk','xm') AND c.khid>1 AND b.khid<>c.khid AND  b.ccid+'-' LIKE c.ccid+'-%'
INNER JOIN yx_t_khsfdm d ON c.sfdm=d.dm
LEFT JOIN yx_t_zxspb zx ON a.khid=zx.khid 
INNER JOIN (SELECT khid FROM yx_t_jmspb GROUP BY khid) jm ON a.khid=jm.khid
WHERE  a.ty=0 AND b.ty=0 AND c.ty=0 AND ISNULL(zx.id,0)=0 
GROUP BY d.bz order by sl DESC";*/
        mysql = @"SELECT COUNT(1) AS sl,sf.bz as sf
FROM( SELECT A.KHID,C.MDID,LEFT(REPLACE(A.CCID,'-1-',''),CHARINDEX('-',REPLACE(A.CCID,'-1-','')+'-')-1) AS DJKHID 
      FROM YX_T_KHB A 
      INNER JOIN T_MDB C ON A.KHID=C.KHID  WHERE A.TY=0 AND C.TY=0) E 
INNER JOIN YX_T_KHB D ON E.DJKHID=D.KHID      
INNER JOIN (SELECT ROW_NUMBER()OVER(PARTITION BY A.KHID,A.MDID ORDER BY A.TBRQ DESC) AS XH,A.ID,A.KHID,A.MDID         
                 FROM YX_T_JMSPB A INNER JOIN YX_T_JMSPMXB B ON A.ID=B.ID 
                 WHERE A.KHID>0 AND A.MDID>0 AND (CASE WHEN '0'='0'AND B.FGSYWJLZXRQ IS NOT NULL THEN 1 WHEN '0'='1' 
                 AND A.SHBS=1 THEN 1 ELSE 0 END)=1 
                 AND A.TBRQ>='2008-01-01' ) JM ON E.KHID=JM.KHID AND E.MDID=JM.MDID
                 AND JM.XH=1    
LEFT OUTER JOIN (SELECT KHID,MDID FROM YX_T_ZXSPB GROUP BY KHID,MDID) ZX ON E.KHID=ZX.KHID AND E.MDID=ZX.MDID 
INNER JOIN dbo.yx_t_khsfdm sf ON d.sfdm=sf.dm  
WHERE ZX.KHID IS NULL
GROUP BY sf.bz
ORDER BY sl DESC";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OADBConstr))
        {
            DataTable dt;
            string errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response(errInfo));

            int sumsl = Convert.ToInt32(dt.Compute("sum(sl)", ""));
            DataRow dr = dt.NewRow();
            dr["sf"] = "china";
            dr["sl"] = sumsl;
            dt.Rows.Add(dr);

            rt = JsonConvert.SerializeObject(new Response(dt));
            clsSharedHelper.DisponseDataTable(ref dt);
            return rt;
        }
    }

}
#endregion

#region 基础类
public class Response
{
    public Response() { }
    public Response(object obj)
    {
        _code = "200";
        _info = obj;
    }
    public Response(string errmsg)
    {
        this._code = "201";
        this._msg = errmsg;
    }
    string _code;
    public string code
    {
        get
        {
            if (string.IsNullOrEmpty(_code)) _code = "201";
            return _code;
        }
        set
        {
            _code = value;
        }
    }
    object _info;
    public object info
    {
        get { return _info == null ? "" : _info; }
        set { _info = value; }
    }
    string _msg;
    public string msg
    {
        get
        {
            if (string.IsNullOrEmpty(_msg)) _msg = "";
            return _msg;
        }
        set
        {
            _msg = value;
        }
    }
}
#endregion
