<%@ WebHandler Language="C#" Class="SalesClerkCore" %>
using System;
using System.Web;
using nrWebClass;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;
using System.Threading;

public class SalesClerkCore : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    string FXDBConStr = clsConfig.GetConfigValue("FXDBConStr");
    string OADBConStr = clsConfig.GetConfigValue("OAConnStr");
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
        if (string.IsNullOrEmpty(ctrl)) ctrl = "";
        ctrl = ctrl.ToLower();
        switch (ctrl)
        {
            case "saleclerklist":
                rt = saleClerkList(context);
                break;
            case "saleclerkdetail":
                rt = saleClerkDetail(context);
                break;
            case "salecomparison":
                string lb = Convert.ToString(context.Request.Params["lb"]);
                if (lb == "faultcode")
                    rt = saleComparison(context);
                else
                    rt = turnoverRatio(context);
                break;
            case "cmdm":
                rt = getCmdm();
                break;
            default:
                rt = JsonConvert.SerializeObject(new Response("201", "无效请求"));
                break;
        }
        clsSharedHelper.WriteInfo(rt);
    }
    public string getCmdm()
    {
        string rt, mysql;
        mysql = "SELECT cmdm1,tml1,tml2,tml3,tml4,tml5 FROM dbo.YX_T_Cmdmb";
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OADBConStr))
        {
            string errrInfo = dal.ExecuteQuery(mysql, out dt);
            if (errrInfo != "") rt = JsonConvert.SerializeObject(new Response("201", errrInfo));
            else
            {
                Dictionary<string, object> dic_rows = new Dictionary<string, object>();
                Dictionary<string, string> dic_temp;
                foreach (DataRow dr in dt.Rows)
                {
                    dic_temp = new Dictionary<string, string>();
                    dic_temp.Add("tml1", dr["tml1"].ToString());
                    dic_temp.Add("tml2", dr["tml2"].ToString());
                    dic_temp.Add("tml3", dr["tml3"].ToString());
                    dic_temp.Add("tml4", dr["tml4"].ToString());
                    dic_temp.Add("tml5", dr["tml5"].ToString());
                    dic_rows.Add(Convert.ToString(dr["cmdm1"]), dic_temp);
                }
                rt = JsonConvert.SerializeObject(new Response("200", dic_rows));
                dic_rows.Clear();
                clsSharedHelper.DisponseDataTable(ref dt);
            }
        }
        return rt;
    }

    public string saleComparison(HttpContext context)
    {
        string rt, mysql, sphh, curkhid, kfbh, isFaultCode, ssid = "1";
        sphh = Convert.ToString(context.Request.Params["sphh"]);
        curkhid = Convert.ToString(context.Request.Params["curkhid"]);
        kfbh = Convert.ToString(context.Request.Params["kfbh"]);
        isFaultCode = Convert.ToString(context.Request.Params["isFaultCode"]);

        if (string.IsNullOrEmpty(curkhid) == false)
        {
            ssid = curkhid;
        }

        string filter = "";
        if (string.IsNullOrEmpty(sphh) == false)
        {
            filter = string.Format(" and sp.sphh like ''%{0}%''", sphh);
        }
        if (string.IsNullOrEmpty(kfbh) == false)
        {
            filter = string.Concat(filter, string.Format(" and sp.kfbh=''{0}''", kfbh));
        }

        mysql = string.Format(@"DECLARE @sqlstr VARCHAR(MAX);
                DECLARE @sqlcm_sl VARCHAR(5000);
                DECLARE @sqlcm_zt VARCHAR(5000);
                SELECT @sqlcm_sl='',@sqlstr=''
                SELECT @sqlcm_sl=@sqlcm_sl+'max(CASE cmdm WHEN '''+cmdm1+''' THEN sl0 else 0 end) as ['+cmdm1+'],'
                FROM dbo.YX_T_Cmdmb 
                SET @sqlcm_zt=REPLACE(@sqlcm_sl,'sl0','dbzt0')
                select  @sqlstr ='select top 200 t.*,kh.khmc,lb.mc,0 as isfaultcode from( 
                select a.tzid,a.sphh,''kc'' as lx,sum(sl0) as sl,'+@sqlcm_sl+' sp.splbid,sp.tml
                from dbo.YX_T_Spkccmmx a  inner join yx_T_spdmb sp on a.sphh=sp.sphh {1}
                WHERE a.tzid=''{0}'' AND sl0<>0  
                group by  a.tzid,a.sphh,sp.splbid,sp.tml
                union all 
                select a.tzid,a.sphh,''zt'' as lx,sum(dbzt0) as sl,'+@sqlcm_zt+' sp.splbid,sp.tml
                from dbo.YX_T_Spkccmmx a   
                inner join yx_T_spdmb sp on a.sphh=sp.sphh {1}
                WHERE a.tzid=''{0}''  AND  a.dbzt0<>0 
                group by  a.tzid,a.sphh,sp.splbid,sp.tml ) t
                inner join yx_t_khb kh on t.tzid=kh.khid
                inner join YX_T_Splb lb on t.splbid=lb.id and qt<>''C''
                order by t.sl desc'
                EXEC (@sqlstr)", ssid, filter);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(Convert.ToInt32(ssid)))
        {
            DataTable dt, dt_rt;
            string errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "") rt = JsonConvert.SerializeObject( new Response("201",errInfo)) ;
            else
            {
                mysql = @"SELECT a.id AS splbid,ISNULL(b.id,c.id) AS faid,famx.cmzds
                    FROM yx_T_splb a 
                    LEFT JOIN (select a.id,b.id as splbid,Row_Number()over(partition by a.tml,b.id order by a.qyrq desc)  as xh from yx_t_fadmb a 
		                      inner join yx_T_fadmfb b on a.id=b.id 
		                    where  a.djlx=4) b ON a.id=b.splbid AND b.xh=1
                    LEFT JOIN (
		                    select a.id,b.id as splbid,Row_Number()over(partition by a.tml,b.id order by a.qyrq desc)  as xh from yx_t_fadmb a 
		                      inner join yx_T_splb b on a.tml=b.tml 
		                    where  a.djlx=3 ) c ON a.id=c.splbid AND c.xh=1
                    INNER JOIN yx_T_fadmmxb famx ON ISNULL(b.id, ISNULL(c.id,0))=famx.id
                    WHERE a.ty=0 AND tzid=1 
                    ORDER BY a.id ";
                DataTable dt_cmdm;
                dal.ConnectionString = OADBConStr;
                errInfo = dal.ExecuteQuery(mysql, out dt_cmdm);
                if (errInfo != "") rt = errInfo;
                {
                    Dictionary<int, List<string>> dic_gjcm = new Dictionary<int, List<string>>();
                    int splbid = 0;
                    //把已维护关键尺码的类别放在字典中
                    foreach (DataRow dr in dt_cmdm.Rows)
                    {
                        splbid = Convert.ToInt32(dr["splbid"]);
                        if (dic_gjcm.ContainsKey(splbid) == false)
                        {
                            dic_gjcm.Add(splbid, new List<string>());
                        }
                        dic_gjcm[splbid].Add(Convert.ToString(dr["cmzds"]));
                    }
                    dt_rt = dt.Clone();
                    //遍历数据表
                    foreach (DataRow dr in dt.Rows)
                    {
                        DataRow dr_rt = dt_rt.NewRow();
                        //找到有维护关键尺码的类别
                        if (dic_gjcm.ContainsKey(Convert.ToInt32(dr["splbid"])))
                        {
                            //查询每个关键尺码是否都大于0
                            foreach (string str in dic_gjcm[Convert.ToInt32(dr["splbid"])])
                            {
                                if (Convert.ToInt32(dr[str]) <= 0)
                                {
                                    dr["isfaultcode"] = "1";
                                    break;
                                }
                            }
                        }
                        if (string.IsNullOrEmpty(isFaultCode) || Convert.ToString(dr["isfaultcode"]) == isFaultCode)
                            dt_rt.ImportRow(dr);
                    }
                    rt = JsonConvert.SerializeObject(new Response("200",dt_rt));
                    clsSharedHelper.DisponseDataTable(ref dt_cmdm);
                    clsSharedHelper.DisponseDataTable(ref dt_cmdm);
                    clsSharedHelper.DisponseDataTable(ref dt);
                }
            }
        }
        return rt;
    }
    public string turnoverRatio(HttpContext context)
    {
        string rt, mysql, sphh, curkhid, kfbh, khid = "1";
        sphh = Convert.ToString(context.Request.Params["sphh"]);
        curkhid = Convert.ToString(context.Request.Params["curkhid"]);
        kfbh = Convert.ToString(context.Request.Params["kfbh"]);
        if (string.IsNullOrEmpty(curkhid) == false)
        {
            khid = curkhid;
        }

        string filter = "";
        if (string.IsNullOrEmpty(sphh) == false)
        {
            filter = string.Format(" and sp.sphh like ''%{0}%''", sphh);
        }
        if (string.IsNullOrEmpty(kfbh) == false)
        {
            filter = string.Concat(filter, string.Format(" and sp.kfbh=''{0}''", kfbh));
        }

        mysql = string.Format(@"DECLARE @sqlstr VARCHAR(MAX);
                DECLARE @sqlcm_sl VARCHAR(5000);
                DECLARE @sqlcm_zt VARCHAR(5000);
                SELECT @sqlcm_sl='',@sqlstr=''
                SELECT @sqlcm_sl=@sqlcm_sl+'max(CASE cmdm WHEN '''+cmdm1+''' THEN sl0 else 0 end) as ['+cmdm1+'],'
                FROM dbo.YX_T_Cmdmb 
                SET @sqlcm_zt=REPLACE(@sqlcm_sl,'sl0','dbzt0')
                select  @sqlstr ='select top 50 t.*,kh.khmc,lb.mc,''0.0'' as turnoverRatio from( 
                select a.tzid,a.sphh,''kc'' as lx,'+@sqlcm_sl+' sp.splbid,sp.tml
                from dbo.YX_T_Spkccmmx a  inner join yx_T_spdmb sp on a.sphh=sp.sphh {1}
                WHERE a.tzid=''{0}'' AND sl0<>0  
                group by  a.tzid,a.sphh,sp.splbid,sp.tml
                union all 
                select a.tzid,a.sphh,''zt'' as lx,'+@sqlcm_zt+' sp.splbid,sp.tml
                from dbo.YX_T_Spkccmmx a   
                inner join yx_T_spdmb sp on a.sphh=sp.sphh {1}
                WHERE a.tzid=''{0}''  AND  a.dbzt0<>0 
                group by  a.tzid,a.sphh,sp.splbid,sp.tml ) t
                inner join yx_t_khb kh on t.tzid=kh.khid
                inner join YX_T_Splb lb on t.splbid=lb.id and qt<>''C''
                order by t.tzid,t.sphh'
                EXEC (@sqlstr)", khid, filter);

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(Convert.ToInt32(khid)))
        {
            string khdbconnectiong = dal.ConnectionString;
            DataTable dt;
            string errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response("201", errInfo));
            Dictionary<string, int> dic_rowNumber = new Dictionary<string, int>();//已查询货号所在表行数关系
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (dic_rowNumber.ContainsKey(dt.Rows[i]["sphh"].ToString()) == false) dic_rowNumber.Add(dt.Rows[i]["sphh"].ToString(), i);
            }
            string[] sphhlist = new string[dic_rowNumber.Count];
            dic_rowNumber.Keys.CopyTo(sphhlist, 0);

            mysql = string.Format("select ssid from yx_T_khb where khid={0}", khid);
            object ssidObj;
            errInfo = dal.ExecuteQueryFast(mysql, out ssidObj);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response("201", errInfo));

            //查询提货数 查询上级客户所在库中的数据
            LiLanzDALForXLM dalt = new LiLanzDALForXLM(Convert.ToInt32(ssidObj));
            dal.ConnectionString = dalt.ConnectionString;
            dalt.Dispose();
            DataTable dt_ths, dt_xxs;
            Dictionary<string, decimal> dic_ths = new Dictionary<string, decimal>();

            mysql = string.Format(@"SELECT a.sphh,0 - SUM(a.sl * DJLB.kc) ths
	                        FROM yx_v_kcdjmx a                            
	                        INNER join t_djlxb DJLB ON a.djlx = DJLB.dm
	                        WHERE a.djlx IN (111,112)  AND a.shbs=1 AND a.qrbs=1 AND a.djbs=1 AND  a.khid={0} and a.sphh in('{1}')
	                        GROUP BY a.sphh" ,khid, string.Join("','", sphhlist));
            errInfo = dal.ExecuteQuery(mysql, out dt_ths);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response("201", errInfo));
            foreach (DataRow dr in dt_ths.Rows)
            {
                dic_ths.Add(dr["sphh"].ToString(), Convert.ToDecimal(dr["ths"]));
            }

            dal.ConnectionString = khdbconnectiong;
            mysql = string.Format(@"SELECT a.sphh,SUM(ABS(a.djlb)/a.djlb*sl) AS xxs
                        FROM dbo.zmd_v_lsdjmx a 
                        WHERE a.djbs=1  AND a.khid={0}  and a.sphh in('{1}')
                        GROUP BY a.sphh" ,khid, string.Join("','", sphhlist));
            errInfo = dal.ExecuteQuery(mysql, out dt_xxs);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response("201", errInfo));
            foreach (DataRow dr in dt_xxs.Rows)
            {
                sphh = dr["sphh"].ToString();
                if (dic_ths[sphh] != 0) dt.Rows[dic_rowNumber[sphh]]["turnoverRatio"] = (Convert.ToDecimal(dr["xxs"]) / dic_ths[sphh]).ToString("0.00%");

            }
            clsSharedHelper.DisponseDataTable(ref dt_ths);
            clsSharedHelper.DisponseDataTable(ref dt_xxs);
            rt = JsonConvert.SerializeObject(new Response("200",dt));
            clsSharedHelper.DisponseDataTable(ref dt);
            dic_rowNumber.Clear();dic_ths.Clear();
        }
        return rt;
    }
    public string saleClerkList(HttpContext context)
    {
        List<SqlParameter> paras = new List<SqlParameter>();
        string kfbh = Convert.ToString(context.Request.Params["kfbh"]);
        string ksrq = Convert.ToString(context.Request.Params["ksrq"]);
        string jsrq = Convert.ToString(context.Request.Params["jsrq"]);
        string khfl = Convert.ToString(context.Request.Params["khfl"]);
        string mdfl = Convert.ToString(context.Request.Params["mdfl"]);
        string curkhid = Convert.ToString(context.Request.Params["curkhid"]);

        if (kfbh == "all") kfbh = "";


        string ssid = "1";
        if (string.IsNullOrEmpty(curkhid) == false)
        {
            ssid = curkhid;
        }

        string kfbh_tj = "", khfl_tj = "", mdfl_tj = "";
        if (string.IsNullOrEmpty(kfbh) == false)
        {
            kfbh_tj = " INNER JOIN dbo.YX_T_Spdmb sp ON a.sphh=sp.sphh AND sp.kfbh=@kfbh";
            paras.Add(new SqlParameter("@kfbh", kfbh));
        }

        if (string.IsNullOrEmpty(khfl) == false)
        {
            khfl_tj = "  and kh.khfl=@khfl ";

            paras.Add(new SqlParameter("@khfl", khfl));
        }

        if (string.IsNullOrEmpty(mdfl) == false)
        {
            mdfl_tj = " and md.khfl=@mdfl ";
            paras.Add(new SqlParameter("@mdfl", mdfl));
        }

        string mysql = string.Format(@"SELECT a.mdid,b.mdmc,a.yyy,a.ryid,CAST(SUM(a.je*ABS(a.djlb)/a.djlb)  AS DECIMAL(9,2)) AS sumje,COUNT(DISTINCT a.id) AS djs,CAST(SUM(a.zks)/COUNT(1)AS DECIMAL(5,2)) avgzk,CAST(SUM(a.sl*ABS(a.djlb)/a.djlb)/COUNT(DISTINCT a.id) AS DECIMAL(9,2)) AS avgsl
                        FROM dbo.zmd_v_lsdjmx a INNER JOIN dbo.t_mdb b ON a.mdid=b.mdid {0}
                        INNER JOIN yx_T_khb md ON b.khid=md.khid {1}
                        INNER JOIN dbo.yx_t_khb kh ON md.ccid+'-' LIKE kh.ccid+'-%' AND (kh.ssid=@ssid OR kh.khid=@ssid) AND kh.khid>1 {2}  AND kh.khfl IN('xf','xd','xg','xk')
                        WHERE a.djbs=1 and a.rq>=@ksrq AND a.rq<DATEADD(DAY,1,@jsrq) AND ryid>0
                        GROUP BY a.mdid,b.mdmc,a.yyy,a.ryid
                        ORDER BY sumje DESC", kfbh_tj, mdfl_tj, khfl_tj);
        paras.Add(new SqlParameter("@ssid", ssid));
        paras.Add(new SqlParameter("@ksrq", ksrq));
        paras.Add(new SqlParameter("@jsrq", jsrq));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXDBConStr))
        {
            DataTable dt;
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);

            if (errInfo != "") return JsonConvert.SerializeObject(new Response("201", errInfo));
            {
                string colname = HttpContext.Current.Request.Params["colname"];
                string ordertype = HttpContext.Current.Request.Params["ordertype"];
                SetOrder(ref dt, colname, ordertype);
                string rt = JsonConvert.SerializeObject(new Response("200", dt));
                clsSharedHelper.DisponseDataTable(ref dt);//回收资源
                return rt;

            }

        }
    }
    public string saleClerkDetail(HttpContext context)
    {
        string ryid = Convert.ToString(context.Request.Params["ryid"]);
        string kfbh = Convert.ToString(context.Request.Params["kfbh"]);
        string ksrq = Convert.ToString(context.Request.Params["ksrq"]);
        string jsrq = Convert.ToString(context.Request.Params["jsrq"]);
        if (kfbh == "all") kfbh = "";
        string kfbh_tj = "";
        List<SqlParameter> paras = new List<SqlParameter>();
        if (string.IsNullOrEmpty(kfbh) == false)
        {
            kfbh_tj = " AND b.kfbh=@kfbh";
            paras.Add(new SqlParameter("@kfbh", kfbh));
        }
        if (string.IsNullOrEmpty(ryid))
        {
            return JsonConvert.SerializeObject(new Response("201", "缺少必要参数"));
        }
        string mysql = string.Format(@"SELECT convert(varchar(10), rq,23) rq,a.sphh,b.spmc,a.sl,a.je,b.lsdj,a.zks,a.dj
                        FROM dbo.zmd_v_lsdjmx a 
                        INNER JOIN  dbo.YX_T_Spdmb b ON a.sphh=b.sphh {0}
                        WHERE ryid=@ryid and a.rq>=@ksrq AND a.rq<DATEADD(DAY,1,@jsrq)", kfbh_tj);
        paras.Add(new SqlParameter("@ryid", ryid));
        paras.Add(new SqlParameter("@ksrq", ksrq));
        paras.Add(new SqlParameter("@jsrq", jsrq));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXDBConStr))
        {
            DataTable dt;
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") return JsonConvert.SerializeObject(new Response("201", errInfo));
            string rt=JsonConvert.SerializeObject(new Response("200", dt));
            clsSharedHelper.DisponseDataTable(ref dt);
            return rt;
        }
    }

    private void SetOrder(ref DataTable dt, string order_colName, string order_direc)
    {
        //排序  
        if (string.IsNullOrEmpty(order_colName) == false)
        {
            if (dt.Columns.Contains(order_colName) == false) return;

            DataView dv = dt.DefaultView;
            dv.Sort = string.Concat(order_colName, " ", order_direc);

            DataTable dt2 = dv.ToTable();
            dt.Clear(); dt.Dispose();

            dt = dt2;
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}

#region 基础类
public class Response
{
    public Response(string code, object obj)
    {
        _code = code;
        _info = obj;
    }
    public Response(string code, string errmsg)
    {
        this._code = code;
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
