<%@ WebHandler Language="C#" Class="sphhinfo" Debug="true" %>

using System;
using System.Web;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.Web.SessionState;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using nrWebClass;
public class sphhinfo : IHttpHandler, IRequiresSessionState
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        string from = context.Request.Form["from"].ToString();
        SCData scData = new SCData();
        if (string.Compare(from, "gyd", true) == 0)
        {//获取工艺单
            string sphh = context.Request.Form["sphh"].ToString();
            DataSet ds = null;
            string errInfo = "";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                string str_sql = @" SELECT   wjpath  FROM yx_t_spkhxxb c   inner join yx_t_spdmb a on c.spkh=a.spkh    WHERE c.djlx=409 and a.sphh='" + sphh + "' ";
                str_sql += "  SELECT DISTINCT e.id,isnull(f.id,0) syid,a.flowid,e.bgbh FROM cl_V_dddjmx a";
                str_sql += " INNER JOIN dbo.cl_v_jhdjmxb b ON a.sqid=b.id AND a.sqmxid=b.mxid AND b.jylx='517'";
                str_sql += " INNER JOIN dbo.Yf_T_bjdlb e ON e.id=b.jyid";
                str_sql += " left outer join yf_t_bjdlb f on e.ddid=f.id and f.lxid=518 and f.sylx=8";
                str_sql += " WHERE a.djlx=624 AND a.scddbh LIKE '" + sphh + "%'";
                List<SqlParameter> para = new List<SqlParameter>();
                errInfo = dal.ExecuteQuerySecurity(str_sql, para, out ds);
            }

            if (ds.Tables[0].Rows.Count > 0)
            {
                scData.WJpath =ds.Tables[0].Rows[0]["wjpath"].ToString();
            }

            if (ds.Tables[1].Rows.Count > 0)
            {
                foreach (DataRow dr in ds.Tables[1].Rows)
                {
                    JYBG jyBG = new JYBG();
                    jyBG.Id = int.Parse(dr["id"].ToString());
                    jyBG.Syid = int.Parse(dr["syid"].ToString());
                    jyBG.Flowid = int.Parse(dr["flowid"].ToString());
                    jyBG.Bgbh = dr["bgbh"].ToString();
                    scData.JYBGList.Add(jyBG);
                }
            }
        }
        context.Response.Write(JsonConvert.SerializeObject(scData));
        context.Response.End();
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}

public class SCData
{
    private List<JYBG> jybgList = new List<JYBG>();
    public List<JYBG> JYBGList { get { return jybgList; } set { jybgList = value; } }
    private string wjpath;
    public string WJpath { get { return wjpath; } set { wjpath = value; } }
}
public class JYBG
{
    private int id;
    public int Id { get { return id; } set { id = value; } }
    private int syid;
    public int Syid { get { return syid; } set { syid = value; } }
    private int flowid;
    public int Flowid { get { return flowid; } set { flowid = value; } }
    private string bgbh;
    public string Bgbh { get { return bgbh; } set { bgbh = value; } }
}



