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
        string errInfo = ""; string mysql = "";
        DataSet ds = null;
        if (from == "BID.18393")
        {
            #region
            try
            {
                string tm = ""; 
                if (!string.IsNullOrEmpty(context.Request.Form["tm"].ToString()))
                {
                    tm = context.Request.Form["tm"].ToString();
                }
                
                if (!string.IsNullOrEmpty(tm))
                {

                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                    {
                        mysql = @" 
                         select c.sytj,cast(b.sz as varchar) sz,b.mxid,c.lx into #syz 
                         from  yf_t_bjdmxb b
                         inner join Yf_T_bjdbjzb as c on c.id=b.zbid 
                         inner join  yf_T_ghsmlsyb a on a.id=b.mxid and a.djlx=9114 and a.mlbhkh like '%{0}%'
                         inner join YF_t_bjdlxb d on d.id=a.mllb and d.bz = '面料' AND d.flbs='ml'
                         where isnull(c.jszb1,'')<>'sylx' and c.tzid=1 and c.sfbh=0 and isnull(c.bzzid,0)<>0 
                         and c.sytj in ('ys') AND b.LYDJLX=9114; 

                         select  a.llyphh,a.mlbh,gz.zpdjg,MAX(ys.ys) as ys,fabP.fabricMainPictUrl as pic,gz.bgid  from yf_T_ghsmlsyb a 
                         left join (
                            select a.id,lbb.zpdjg,row_number()over(partition by a.id order by gz.id desc ) xh,lbb.id bgid
                            from yf_T_ghsmlsyb a 
                            inner join cl_t_sygzb gz on a.lydjid=gz.lymxid and gz.gzlx=1005 and gz.tzid=1
                            inner join cl_v_syypzt zt on zt.gzlx=1005 and zt.dm=gz.ypzt
                            left join yf_t_bjdlb lbb on lbb.lxid=518 and lbb.fhbs=1 and lbb.sylx in ('2') and lbb.ddid=gz.id  
                         ) gz on gz.xh=1 and gz.id=a.id
                         left JOIN  (	                 
                            select  a.mxid,a.lx,a.sytj,a.sz ys from #syz  a  where a.sytj='ys'                      
                         ) ys  ON a.id = ys.mxid
                         left join yf_t_MyfabricScan fabP on a.mlbh=fabP.fabricCode and fabP.IsDel=0
                         WHERE a.djlx = 9114 and a.mlbhkh like '%{0}%'
                         group by a.mlbh,gz.zpdjg,fabP.fabricMainPictUrl,a.llyphh,gz.bgid;";
                        List<SqlParameter> para = new List<SqlParameter>();
                        dal.ExecuteQuerySecurity(string.Format(mysql,tm), para, out ds);
                        if (ds.Tables.Count == 1 && ds.Tables[0].Rows.Count==0)
                        {
                            errInfo = "{result:'NoRows',data:''}";
                        }
                        else {
                            errInfo = "{result:'Successed',data:'" + JsonConvert.SerializeObject(ds) + "'}";
                        }

                    }
                }
            }
            catch (SystemException ex)
            {
                errInfo = "{result:'Successed',data:'" + ex.Message + "'}";
            }
            #endregion
        }
        context.Response.Write(errInfo);
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

 


