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
            connStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
            //connStr = dal.ConnectionString;
        }

        string rtMsg = GetWtData(pars["bizdata"], pars["partnerid"]).ToString();

        context.Response.Write(rtMsg);
        context.Response.End();


    }

    /// <summary>
    /// 获取生产订单信息
    /// </summary>
    /// <param name="JSONParas">json格式参数</param>
    /// <returns></returns>
    public string GetWtData(string JSONParas, string khid)
    {
        string rtMsg = "", errInfo = "";
        ScDjCs scDjCs = JsonConvert.DeserializeObject<ScDjCs>(JSONParas);
        string jsonMb = @" {{ ""errcode"": ""{0}"", ""errmsg"": ""{1}"" }} ";
        string jsonMb1 = @" {{ ""errcode"": ""{0}"", ""errmsg"": ""{1}"", ""data"": [{2}] }} ";
        string jsonMb2 = @" {{ ""djh"": ""{0}"", ""htbh"": ""{1}"", ""mxData"": [{2}] }} ";
        string jsonMb3 = @" {{ ""sphh"": ""{0}"", ""shdm"": ""{1}"", ""shmc"": ""{2}"", ""htjq"": ""{3}"", ""cmData"": [{4}] }} ";
        string jsonMb4 = @" {{ ""cmdm"": ""{0}"", ""cmmc"": ""{1}"", ""sl"": {2} }} ";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connStr))
        {
            string str_sql = @"                 
                SELECT a.id,a.djh,b.htbh
                INTO #myzb
                FROM YX_T_dddjb a
                LEFT JOIN dbo.zw_t_htdddjb b ON a.htddid=b.id
                WHERE a.khid=@khid and a.rq >= @ksrq AND a.rq<DATEADD(DAY,1,CAST(@jsrq AS DATETIME))
                --table0
                SELECT id,djh,htbh FROM #myzb
                --table1
                SELECT a.id,a.mxid,a.sphh,c.dm shdm,c.mc shmc,CONVERT(VARCHAR(10),htmx.cpksrq,120) htjq
                FROM dbo.yx_v_dddjmx a
                INNER JOIN #myzb zb ON a.id=zb.id
                LEFT JOIN YX_T_Ypdmb b ON a.yphh=b.yphh 
                LEFT JOIN YX_T_Shdmb c ON b.shid=c.id
                LEFT JOIN zw_v_cphtddmx htmx ON a.htddid=htmx.id AND a.scgzh=htmx.gzh
                --table2
                SELECT a.id,a.mxid,a.cmdm,cm.cmmc,a.sl0
                FROM dbo.yx_v_dddjcmmx a
                INNER JOIN #myzb zb ON a.id=zb.id
                LEFT JOIN dbo.yx_v_cmdmb cm ON a.cmdm='cm'+cm.cmdm

                DROP TABLE #myzb;
            ";

            DataSet ds;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@ksrq", scDjCs.BeginDate));
            paras.Add(new SqlParameter("@jsrq", scDjCs.EndDate));
            paras.Add(new SqlParameter("@khid", khid));
            errInfo = dal.ExecuteQuerySecurity(str_sql, paras, out ds);
            if (errInfo != "")
            {
                rtMsg = string.Format(jsonMb, "4002", "查询出错");
                return rtMsg;
            }
            if (ds.Tables[0].Rows.Count == 0)
            {
                rtMsg = string.Format(jsonMb, "4001", "没有记录");
                return rtMsg;
            }
            string jsonZbStr = "";
            for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
            {
                string jsonMxStr = "";
                //取明细
                DataRow[] mxdrs = ds.Tables[1].Select(" id='"+ ds.Tables[0].Rows[i]["id"] +"' ");
                for (int j = 0; j < mxdrs.Length; j++)
                {
                    string jsonCmMxStr = "";
                    //取尺码明细
                    DataRow[] cmmxdrs = ds.Tables[2].Select(" id='"+ ds.Tables[1].Rows[i]["id"] +"' and mxid='" + ds.Tables[1].Rows[i]["mxid"] + "' ");
                    for (int k = 0; k < cmmxdrs.Length; k++)
                    {
                        //string jsonMb4 = @" {{ ""cmdm"": ""{0}"", ""cmmc"": ""{1}"", ""sl"": {2} }} ";
                        jsonCmMxStr += string.Format(jsonMb4, cmmxdrs[k]["cmdm"].ToString(), cmmxdrs[k]["cmmc"].ToString().Replace("\n","").Replace("<br>","/"), cmmxdrs[k]["sl0"].ToString()) + ",";
                    }
                    if (jsonCmMxStr != "") jsonCmMxStr = jsonCmMxStr.Substring(0, jsonCmMxStr.Length - 1);
                    //string jsonMb3 = @" {{ ""sphh"": ""{0}"", ""shdm"": ""{1}"", ""shmc"": ""{2}"", ""htjq"": ""{3}"", ""cmData"": [{4}] }} ";
                    jsonMxStr += string.Format(jsonMb3, mxdrs[j]["sphh"].ToString(), mxdrs[j]["shdm"].ToString(), mxdrs[j]["shmc"].ToString(),
                        mxdrs[j]["htjq"].ToString(), jsonCmMxStr) + ",";
                }
                if (jsonMxStr != "") jsonMxStr = jsonMxStr.Substring(0, jsonMxStr.Length - 1);
                //string jsonMb2 = @" {{ ""djh"": ""{0}"", ""htbh"": ""{1}"", ""mxData"": [{2}] }} ";
                jsonZbStr += string.Format(jsonMb2, ds.Tables[0].Rows[i]["djh"].ToString(), ds.Tables[0].Rows[i]["htbh"].ToString(), jsonMxStr) + ",";
            }
            if (jsonZbStr != "") jsonZbStr = jsonZbStr.Substring(0, jsonZbStr.Length - 1);
            //string jsonMb1 = @" {{ ""errcode"": ""{0}"", ""errmsg"": ""{1}"", ""data"": [{2}] }} ";
            rtMsg = string.Format(jsonMb1, "0", "请求成功", jsonZbStr);
        }//end using
        return rtMsg;
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
class ScDjCs
{
    public string BeginDate;
    public string EndDate;
}


