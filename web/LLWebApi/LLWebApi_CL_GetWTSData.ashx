<%@ WebHandler Language="C#" Class="LLWebApi_CL_GetWTSData" Debug="true" %>
using System;
using System.Web;
using System.Data;
using System.IO;
using System.Text;
using System.Data.SqlClient;
using System.Collections.Generic;
using LLWebApi.Base;
using LLWebApi.Utils;
using nrWebClass;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

public class LLWebApi_CL_GetWTSData : IHttpHandler
{
    string connStr = "";

    public void ProcessRequest(HttpContext context)
    {
        string reqData = readStream(context.Request.InputStream, "utf-8");

        IDictionary<string, string> pars = HttpPostUtil.getURLParameters(reqData);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            //connStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
            connStr = dal.ConnectionString;
        }

        string rtMsg = GetWtData(pars["bizdata"]).ToString();

        context.Response.Write(rtMsg);
        context.Response.End();


    }

    /// <summary>
    /// 获取委托书信息
    /// </summary>
    /// <param name="JSONParas">json格式参数</param>
    /// <returns></returns>
    public string GetWtData(string JSONParas)
    {
        string rtMsg = "", errInfo = "";
        WtsCs wtsCs = JsonConvert.DeserializeObject<WtsCs>(JSONParas);
        string jsonMb = @" {{ ""errcode"": ""{0}"", ""errmsg"": ""{1}"" }} ";
        string jsonMb1 = @" {{ ""errcode"": ""{0}"", ""errmsg"": ""{1}"", ""data"": {{{2}}} }} ";
        string jsonMb2 = @" ""scdwdm"":""{0}"",""scdw"":""{1}"",""jfdw"":""{2}"",""bgjsdw"":""{3}"",""ys"":""{4}"",""cf"":""{5}"",""aqlb"":""{6}"",""chmc"":""{7}"",""sphh"":""{8}"",""yphh"":""{9}"",""ypztms"":""{10}"",""jyyj"":{{""ybdwqr"":""{11}"",""gb_18401"":""{12}"",""zdbz"":""{13}"",""jyyjbz"":""{14}""}},""jylb"":""{15}"",""sxfs"":""{16}"",""sj"":""{17}"",""jyfs"":""{18}"",""csxm"":""{19}"",""csxmbz"":""{20}"" ";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @" 
                SELECT a.jfdw,a.bgjsdw,a.aqjslb,a.ypzt_1,a.ypztbz,a.djlx,ISNULL(b.lymxid,c.lymxid) lymxid,ISNULL(b.chdm,c.chdm) sku,
					a.jyyj_1,a.jyyj_2,a.jyyj_3,a.jyyj_4,
					CASE WHEN ISNULL(a.jylb,0)=1 THEN '委托检测(只出实测数据)'
						 WHEN ISNULL(a.jylb,0)=2 THEN '委托检验(判定合格与不合格)'
						 WHEN ISNULL(a.jylb,0)=3 THEN '其它' ELSE '' END jylb,         
					CASE WHEN ISNULL(a.xdfs,0)=1 THEN '水洗类'
						 WHEN ISNULL(a.xdfs,0)=2 THEN '干洗类'
						 WHEN ISNULL(a.xdfs,0)=3 THEN '水洗/干洗类' ELSE '' END xdfs,        
					CASE WHEN ISNULL(a.sjcs,0)=1 THEN '第一次送检'
						 WHEN ISNULL(a.sjcs,0)=2 THEN '再次送检' ELSE '' END sjcs,         
					CASE WHEN ISNULL(a.jyzq,0)=1 THEN '正常(3个工作日)'
						 WHEN ISNULL(a.jyzq,0)=2 THEN '加急(加收100%费用)'
						 WHEN ISNULL(a.jyzq,0)=3 THEN '特急(加收200%费用)' ELSE '' END jyzq,
					d.mc csxm,a.csxmbz
                FROM yf_t_wtjyxy a
                LEFT JOIN cl_t_sygzb b ON a.sygzid=b.id and b.gzlx=3311
                LEFT JOIN cl_V_sygzb c ON a.sygzid=c.id and c.gzlx IN (3312,3313)
				LEFT JOIN ghs_t_xtdm d ON ISNULL(a.csxm,0)=d.id and d.ty=0 and d.djlx1=9208
                WHERE a.id = @id
            ";

            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@id", wtsCs.id.ToString()));
            errInfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errInfo != "")
            {
                rtMsg = string.Format(jsonMb, "4002", "查询出错");
                return rtMsg;
            }
            if (dt.Rows.Count == 0)
            {
                rtMsg = string.Format(jsonMb, "4001", "没有记录");
                return rtMsg;
            }

            WtsData wtsData = new WtsData();

            if (dt.Rows[0]["jfdw"].ToString() == "1") wtsData.jfdw = "委托单位";
            else if (dt.Rows[0]["jfdw"].ToString() == "3") wtsData.jfdw = "生产单位";

            if (dt.Rows[0]["bgjsdw"].ToString() == "1") wtsData.bgjsdw = "委托单位";
            else if (dt.Rows[0]["bgjsdw"].ToString() == "3") wtsData.bgjsdw = "生产单位";

            if (dt.Rows[0]["aqjslb"].ToString() == "2") wtsData.aqjslb = "B类";
            else if (dt.Rows[0]["aqjslb"].ToString() == "3") wtsData.aqjslb = "C类";

            if (dt.Rows[0]["ypzt_1"].ToString() == "1") wtsData.ypztms = "机织物,";
            else if (dt.Rows[0]["ypzt_1"].ToString() == "2") wtsData.ypztms = "针织物,";
            wtsData.ypztms += dt.Rows[0]["ypztbz"].ToString();

            wtsData.djlx = dt.Rows[0]["djlx"].ToString();
			string sku = dt.Rows[0]["sku"].ToString();
			wtsData.jyyj_1 = dt.Rows[0]["jyyj_1"].ToString();
			wtsData.jyyj_2 = dt.Rows[0]["jyyj_2"].ToString();
			wtsData.jyyj_3 = dt.Rows[0]["jyyj_3"].ToString();
			wtsData.jyyj_4 = dt.Rows[0]["jyyj_4"].ToString();
			wtsData.jylb = dt.Rows[0]["jylb"].ToString();
			wtsData.xdfs = dt.Rows[0]["xdfs"].ToString();
			wtsData.sjcs = dt.Rows[0]["sjcs"].ToString();
			wtsData.jyzq = dt.Rows[0]["jyzq"].ToString();
			wtsData.csxm = dt.Rows[0]["csxm"].ToString();
			wtsData.csxmbz = dt.Rows[0]["csxmbz"].ToString();
            wtsData.lymxids = "";
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                wtsData.lymxids += dt.Rows[i]["lymxid"].ToString() + ",";
            }
            wtsData.lymxids = wtsData.lymxids.Substring(0, wtsData.lymxids.Length - 1);
            wtsData.lymxids = wtsData.lymxids == "" ? "0" : wtsData.lymxids;

            if (wtsData.djlx == "3311")//贴牌
            {
                wtsData = GetTpInfo(wtsData, sku);
            }
            else if (wtsData.djlx == "3312" || wtsData.djlx == "3313")//自制/成分
            {
                wtsData = GetZzOrCfInfo(wtsData);
            }
            rtMsg = string.Format(jsonMb2, wtsData.scdwdm, wtsData.scdw, wtsData.jfdw, wtsData.bgjsdw, wtsData.ys, wtsData.cf,
                wtsData.aqjslb, wtsData.chmc, wtsData.sphh, wtsData.yphh, wtsData.ypztms, wtsData.jyyj_1, wtsData.jyyj_2, wtsData.jyyj_3, wtsData.jyyj_4, wtsData.jylb, wtsData.xdfs, wtsData.sjcs, wtsData.jyzq, wtsData.csxm, wtsData.csxmbz);
            rtMsg = string.Format(jsonMb1, "0", "请求成功", rtMsg);
        }//end using
        return rtMsg;
    }



    /// <summary>
    /// 获取贴牌委托书信息
    /// </summary>
    /// <param name="lymxids">来源明细id串</param>
    /// <returns></returns>
    public WtsData GetTpInfo(WtsData wtsData, string sku)
    {
        string rtMsg = "", errInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string sql = @"
               select top 1 kh.khdm scdwdm,kh.khmc scdw,sh.mc ys,b.cf,cl.chmc,sp.sku sphh,sp.yphh  
               from  zw_t_httpddmx b 
               inner join zw_t_htdddjb x on b.id=x.id
               inner join yx_t_khb kh on kh.khid=x.khid  
               inner join yx_t_spdmb sp on b.sphh=sp.sphh and sp.sku='{1}'
               left join yx_t_ypdmb yp on b.sphh=yp.yphh
               left join cl_t_chdmb cl on yp.mlbh=cl.chdm
               left join yx_t_shdmb sh on sp.ysid=sh.id		 
               where b.id IN ({0}) AND x.djlx=982
            ";
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            sql = string.Format(sql, wtsData.lymxids, sku);
            errInfo = dal.ExecuteQuerySecurity(sql, paras, out dt);
            if (dt.Rows.Count > 0)
            {
                wtsData.scdwdm = dt.Rows[0]["scdwdm"].ToString();
                wtsData.scdw = dt.Rows[0]["scdw"].ToString();
                wtsData.ys = dt.Rows[0]["ys"].ToString();
                wtsData.cf = dt.Rows[0]["cf"].ToString();
                wtsData.chmc = dt.Rows[0]["chmc"].ToString();
                wtsData.sphh = dt.Rows[0]["sphh"].ToString();
                wtsData.yphh = dt.Rows[0]["yphh"].ToString();
            }
        }
        return wtsData;
    }

    /// <summary>
    /// 获取自制或成分委托书信息
    /// </summary>
    /// <param name="lymxids">来源明细id串</param>
    /// <returns></returns>
    public WtsData GetZzOrCfInfo(WtsData wtsData)
    {
        string rtMsg = "", errInfo = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string sql = @"
                --table1
                select b.mxid,kh.khdm scdwdm,kh.khmc scdw,sh.mc ys,b.cfbl cf,cl.chmc
                from  zw_t_htylddmx b 
                inner join zw_t_htdddjb x on b.id=x.id 
                inner join cl_t_chdmb cl on b.clbh=cl.chdm 
                inner join yx_t_khb kh on kh.khid=x.khid 
                left join yx_t_shdmb sh on CL.ysid=sh.id
                where b.mxid IN ({0})

                --table2
                select b.mxid as mxid621
                from zw_t_htylddmx a 
                inner join cl_v_dddjmx b on a.lymxid=b.mxid and a.id=b.htddid and b.djlx=621          
                where  isnull(a.cgddh,'')='' and a.mxid in ({0})  
                union
                select b.mxid as mxid621
                from zw_t_htylddmx a 
                inner join zw_t_htdddjb zb on a.id=zb.id  
                inner join cl_v_dddjmx b on a.clbh=b.chdm and a.id=b.htddid and b.djlx=621         
                where  isnull(a.cgddh,'')='' and zb.zdbs=5 and a.mxid in ({0}) 
            ";
            DataSet ds;
            List<SqlParameter> paras = new List<SqlParameter>();
            sql = string.Format(sql, wtsData.lymxids);
            errInfo = dal.ExecuteQuerySecurity(sql, paras, out ds);
            if (errInfo != "") return wtsData;
            if (ds.Tables[0].Rows.Count > 0)
            {
                wtsData.scdwdm = ds.Tables[0].Rows[0]["scdwdm"].ToString();
                wtsData.scdw = ds.Tables[0].Rows[0]["scdw"].ToString();
                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    if (wtsData.ys.IndexOf(ds.Tables[0].Rows[i]["ys"].ToString()) == -1)
                    {
                        wtsData.ys += ds.Tables[0].Rows[i]["ys"].ToString() + ",";
                    }
                    if (wtsData.cf.IndexOf(ds.Tables[0].Rows[i]["cf"].ToString()) == -1)
                    {
                        wtsData.cf += ds.Tables[0].Rows[i]["cf"].ToString() + ",";
                    }
                    if (wtsData.chmc.IndexOf(ds.Tables[0].Rows[i]["chmc"].ToString()) == -1)
                    {
                        wtsData.chmc += ds.Tables[0].Rows[i]["chmc"].ToString() + ",";
                    }
                }
                if (wtsData.ys != "")
                {
                    wtsData.ys = wtsData.ys.Substring(0, wtsData.ys.Length - 1);
                }
                if (wtsData.cf != "")
                {
                    wtsData.cf = wtsData.cf.Substring(0, wtsData.cf.Length - 1);
                }
                if (wtsData.chmc != "")
                {
                    wtsData.chmc = wtsData.chmc.Substring(0, wtsData.chmc.Length - 1);
                }
            }

            string djIdS = "";
            if (ds.Tables[1].Rows.Count > 0)
            {
                for (int i = 0; i < ds.Tables[1].Rows.Count; i++)
                {
                    djIdS += ds.Tables[1].Rows[i]["mxid621"].ToString() + ",";
                }
                djIdS = djIdS.Substring(0, djIdS.Length - 1);
            }
            djIdS = djIdS == "" ? "0" : djIdS;

            sql = @"
                select sp.sphh,sp.yphh
                from(   
                    select a.cgddh 
                    from  zw_t_htylddmx a  
                    where isnull(a.cgddh,'')<>'' and a.cgddh <>'nbgzh' and a.mxid in ({0})  
                    union
                    select c.scddbh as cgddh
                    from cl_v_cgjh_ddmx c    
                    where c.scddbh<>'nbgzh' and c.mxid in ({1}) 
                ) a      
                inner join YX_T_Spcgjhb cg on cg.cggzh=a.cgddh  
                inner join yx_T_spdmb sp on sp.sphh=cg.sphh   
            ";
            paras = new List<SqlParameter>();
            sql = string.Format(sql, wtsData.lymxids, djIdS);
            errInfo = dal.ExecuteQuerySecurity(sql, paras, out ds);
            if (errInfo != "") return wtsData;
            if (ds.Tables[0].Rows.Count > 0)
            {
                for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                {
                    if (wtsData.sphh.IndexOf(ds.Tables[0].Rows[i]["sphh"].ToString()) == -1)
                    {
                        wtsData.sphh += ds.Tables[0].Rows[i]["sphh"].ToString() + ",";
                    }
                    if (wtsData.yphh.IndexOf(ds.Tables[0].Rows[i]["yphh"].ToString()) == -1)
                    {
                        wtsData.yphh += ds.Tables[0].Rows[i]["yphh"].ToString() + ",";
                    }
                }
                if (wtsData.sphh != "")
                {
                    wtsData.sphh = wtsData.sphh.Substring(0, wtsData.sphh.Length - 1);
                }
                if (wtsData.yphh != "")
                {
                    wtsData.yphh = wtsData.yphh.Substring(0, wtsData.yphh.Length - 1);
                }
            }
        }
        return wtsData;
    }


    private string readStream(Stream iStream, string charset)
    {
        StreamReader reader = new StreamReader(iStream, Encoding.GetEncoding(charset));
        return HttpContext.Current.Server.UrlDecode(reader.ReadToEnd());
    }
    public bool IsReusable
    {
        get { return true; }
    }
}

/// <summary>
/// 委托书参数
/// </summary>
class WtsCs
{
    public int id;
}

/// <summary>
/// 委托书数据
/// </summary>
public class WtsData
{
    public string scdwdm = "";
    public string scdw = "";
    public string jfdw = "";
    public string bgjsdw = "";
    public string ys = "";
    public string cf = "";
    public string aqjslb = "";
    public string chmc = "";
    public string sphh = "";
    public string yphh = "";
    public string ypztms = "";
    public string djlx = "";
    public string lymxids = "";
	public string jyyj_1 = "";
	public string jyyj_2 = "";
	public string jyyj_3 = "";
	public string jyyj_4 = "";
	public string jylb = "";
	public string xdfs = "";
	public string sjcs = "";
	public string jyzq = "";
	public string csxm = "";
	public string csxmbz = "";
}


