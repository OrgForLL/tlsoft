<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>

<!DOCTYPE html>

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        //允许跨域访问
        Response.ClearHeaders();
        Response.AppendHeader("Access-Control-Allow-Origin", "*");
        string requestHeaders = Request.Headers["Access-Control-Request-Headers"];
        Response.ContentType = "text/html;charset=utf-8";
        Response.ContentEncoding = Encoding.UTF8;
        Response.AppendHeader("Access-Control-Allow-Headers", string.IsNullOrEmpty(requestHeaders) ? "*" : requestHeaders);
        Response.AppendHeader("Access-Control-Allow-Methods", "POST, GET");
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        //按照功能控制参数执行对应的功能。        
        switch (ctrl)
        {
            case "pzjl":
                Pzjl();
                break;

            case "xl":
                xl();
                break;

            default:
                clsSharedHelper.WriteErrorInfo("无效的控制参数ctrl:" + ctrl);
                break;
        }
    }

    /// <summary>
    /// 20180709 gjf
    /// </summary>
    private void Pzjl()
    {
        Dictionary<string, object> res = new Dictionary<string, object>();
        string dxid = Convert.ToString(Request.Params["dxid"]);
        string flowcs = Convert.ToString(Request.Params["flowcs"]);
        string pzjlyj = Convert.ToString(Request.Params["pzjlyj"]);
        string pzjlqs = Convert.ToString(Request.Params["pzjlqs"]);
        string bgzt = Convert.ToString(Request.Params["bgzt"]);
        string ppzjlqs = "";
        string str_sql = "";
        string errinfo = "";
        DataTable dt;
        if (string.IsNullOrEmpty(dxid))
            res = initResObj(400, "缺少必要参数[dxid]！");
        else
        {
            string DBConnStr = "server='192.168.35.10';uid=abeasd14ad;pwd=+AuDkDew;database=tlsoft";
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
            {
                if (flowcs == "qajl" || flowcs == "zjl")
                {
                    //获取QA经理意见
                    str_sql = "SELECT mlshbs ppzjlqs FROM Yf_T_bjdlb a WHERE id=" + dxid;

                    errinfo = dal.ExecuteQuery(str_sql, out dt);

                    if (errinfo == "")
                    {
                        if (dt.Rows.Count <= 0)
                        {
                            res = initResObj(400, "请填写QA经理意见！");
                            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                        }
                        ppzjlqs = dt.Rows[0]["ppzjlqs"].ToString();
                    }
                    else
                    {
                        res = initResObj(300, "", "执行错误:" + errinfo);
                        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                    }
                }
                //if flowcs = pzjl,zjl
                string str_tj = "";
                if (ppzjlqs == "6871" || ppzjlqs == "7395" || ppzjlqs == "7991" || ppzjlqs == "7992")
                {//同意入库，全捡合格,在QA经理已经入库了，不能再次修改入库意见
                    str_tj = " update yf_T_bjdlb set pzjlyj='" + pzjlyj + "' where id=" + dxid + ";";
                }
                else
                {
                    str_tj = " update yf_T_bjdlb set pzjlqs='" + pzjlqs + "',zpdjg='" + pzjlqs + "',bs='" + bgzt + "' where id=" + dxid;
                    str_tj += " update yf_T_bjdlb set pzjl_bs='" + bgzt + "'  where id=" + dxid;
                    str_tj += " update yf_T_bjdlb set pzjlyj='" + pzjlyj + "' where id=" + dxid + "";
                }
                //errinfo = dal.ExecuteQuery(str_tj, out dt);
                if (errinfo != "")
                {
                    res = initResObj(501, "", "执行错误:" + errinfo);
                    clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                }
                //if flowcs end 

                str_sql = @"SELECT a.zpdjg,a.bs as djbs,a.spid,a.dhid lymxid,a.lysphh,a.qtkcmxid,a.kcmxid,a.qajlyj,
                    a.pzjlyj,isnull(a.pzjlqs,0) as pzjlqs,c.bz flow_bz 
                    FROM Yf_T_bjdlb a 
                    INNER JOIN dbo.fl_t_flowRelation b ON a.flowid=b.flowid AND a.id=b.dxid AND a.flowid=547
                    INNER JOIN dbo.fl_t_nodeConfig c ON a.flowid=c.flowid AND b.currentNode=c.nodeid
                    WHERE a.id=" + dxid;
                errinfo = dal.ExecuteQuery(str_sql, out dt);

                if (errinfo == "")
                {
                    if (dt.Rows.Count > 0)
                    {
                        string zpdjg = dt.Rows[0]["zpdjg"].ToString();
                        string djbs = dt.Rows[0]["djbs"].ToString();
                        string spid = dt.Rows[0]["spid"].ToString();
                        string lymxid = dt.Rows[0]["lymxid"].ToString();
                        string kcmxid = dt.Rows[0]["kcmxid"].ToString();
                        string flow_bz = dt.Rows[0]["flow_bz"].ToString();
                        string lysphh = dt.Rows[0]["lysphh"].ToString();
                        string qtkcmxid = dt.Rows[0]["qtkcmxid"].ToString();

                        string sql = " declare @id as int ;";
                        sql += " set @id=" + dxid + ";";
                        flow_bz = "zjl";
                        if ((flow_bz == "qajl" && (zpdjg == "6871" || zpdjg == "7395" || zpdjg == "7991" || zpdjg == "7992"))
                            || (flow_bz == "pzjl" && (zpdjg == "6872" || zpdjg == "7937" || zpdjg == "7938" || zpdjg == "6873" || zpdjg == "7908" || zpdjg == "7939" || zpdjg == "7940" || zpdjg == "8878" || zpdjg == "16380"))
                            || (flow_bz == "zjl")
                            )
                        {
                            if (djbs == "jy")
                            {
                                if (spid != "")
                                {
                                    string spidArr = spid.Substring(1, spid.Length);

                                    sql += " create TABLE #tmzb (spid varchar(20) COLLATE Chinese_PRC_CI_AS NOT NULL ,sphh varchar(20) COLLATE Chinese_PRC_CI_AS NOT NULL ,cmdm varchar(20) COLLATE Chinese_PRC_CI_AS NOT NULL);";
                                    sql += " insert into #tmzb (spid,sphh,cmdm) select a.tm,a.sphh,a.cmdm  from  yx_v_spidb a  where tm in (" + spidArr + ") ; ";
                                    sql += " insert into yf_T_bjdmxb (mxid,zbid,lxid,sz,pdjg,bzzid,sytjid) select distinct @id,0,515,b.spid,b.zxxh,0,0  from yx_t_kcdjmx a inner join yx_T_kcdjspid b on a.id=b.id  where a.mxid in (" + kcmxid + ") and b.spid in (" + spidArr + ");";
                                    sql += " select a.sphh,a.cmdm,count(a.spid) as thsl into #cmsl from #tmzb a group by a.sphh,a.cmdm; ";
                                    sql += " update yx_T_dddjcmmx set sl0=sl0-a.thsl,sfsl0=isnull(sfsl0,0)+a.thsl from ";
                                    sql += " (";
                                    sql += "select a.mxid,a.cmdm,count(a.id) as thsl  from yx_v_dddjcmmx a inner join yx_T_dddjspid b on a.id=b.id  inner join #tmzb spid on a.cmdm=spid.cmdm and b.spid=spid.spid and a.sphh=spid.sphh  where a.mxid in (" + lymxid + ") group by a.mxid,a.cmdm ";
                                    sql += "  ) a where a.mxid=yx_T_dddjcmmx.mxid and a.cmdm=yx_T_dddjcmmx.cmdm ;";
                                    sql += " update yx_T_kcdjcmmx set sl0=sl0-a.thsl,rksl0=isnull(rksl0,0)+a.thsl from ";
                                    sql += " (";
                                    sql += " select a.mxid,a.cmdm,count(spid.spid) as thsl from yx_V_kcdjcmmx a ";
                                    sql += " inner join yx_T_kcdjspid b on a.id=b.id ";
                                    sql += " inner join #tmzb spid on a.cmdm=spid.cmdm and b.spid=spid.spid  and a.sphh=spid.sphh ";
                                    sql += " where a.mxid in (" + kcmxid + ") group by a.mxid,a.cmdm";
                                    sql += "  ) a where a.mxid=yx_T_kcdjcmmx.mxid and a.cmdm=yx_T_kcdjcmmx.cmdm ;";
                                    sql += " update yx_T_kcdjspid set id=id*-1 where id in (select distinct id from yx_t_kcdjmx where mxid in (" + kcmxid + "))  and spid in (select distinct spid from #tmzb )  ;";
                                    sql += " update yx_T_dddjspid set id=id*-1 where id in (select distinct id from yx_t_dddjmx where mxid in (" + lymxid + "))  and spid in (select distinct spid from #tmzb )  ;";
                                    sql += " update a set a.sl=b.sl from yx_t_kcdjmx a inner join (select mxid,sum(sl0) sl from yx_t_kcdjcmmx where id in (select distinct id from yx_t_kcdjmx where mxid in (" + kcmxid + ") ) group by mxid) b on a.mxid=b.mxid where a.id  in (select distinct id from yx_t_kcdjmx where mxid in (" + kcmxid + "))  ;";
                                    sql += " update yx_t_kcdjmx set je=sl*a.dj,cbje=cbbj*sl from yx_t_kcdjmx a where  mxid in (" + kcmxid + ")  ;";
                                    sql += " update yx_t_kcdjb set je=b.je from (select id,sum(je) as je from yx_t_kcdjmx where id  in (select distinct id from yx_t_kcdjmx where mxid in (" + kcmxid + ")) group  by id ) b where yx_t_kcdjb.id=b.id ;";
                                    sql += " update a set a.sl=b.sl,a.je=b.sl*a.dj from yx_t_dddjmx a inner join (select mxid,sum(sl0) sl from yx_t_dddjcmmx where mxid in (" + lymxid + ")  group by mxid) b on a.mxid=b.mxid where a.mxid in (" + lymxid + ") ;";
                                    sql += " update yx_t_dddjb set je=b.je from (select id,sum(je) as je from yx_t_dddjmx where id  in (select distinct id from yx_t_dddjmx where mxid in (" + lymxid + ")) group  by id ) b where yx_t_dddjb.id=b.id ;";
                                    sql += " drop table #tmzb;";
                                    sql += " drop table #cmsl;";

                                }
                                sql += " update yx_t_dddjmx set lymxid=@id where mxid in (" + lymxid + ") ; ";
                            }
                            else if (djbs == "qt")
                            {
                                if (zpdjg == "6873")
                                {
                                    string[] gx_mxid = lymxid.Split(',');
                                    string[] gx_sphh = lysphh.Split(',');
                                    string[] gx_qtkcmxid = qtkcmxid.Split('|');

                                    //string kctempsql = "", ddtempsql = "";
                                    List<string> kctempsql = new List<string>();
                                    List<string> ddtempsql = new List<string>();
                                    for (int i = 0; i <= gx_mxid.Length - 2; i++)
                                    {

                                        sql += " update yx_T_dddjcmmx set  sfsl0=sl0,sl0=0 where  mxid=" + gx_mxid[i] + ";";
                                        kctempsql.Add(" select distinct id,'" + gx_sphh[i] + "' as sphh  from yx_t_kcdjmx where mxid in (" + gx_qtkcmxid[i] + ")  ");
                                        ddtempsql.Add(" select distinct id,'" + gx_sphh[i] + "' as sphh  from yx_t_dddjmx where mxid in (" + gx_mxid[i] + ")   ");

                                    }

                                    if (kctempsql.Count>0)
                                    {
                                        sql += " select a.id,a.sphh into #kcdj from (" + string.Join(" union all ",kctempsql.ToArray())  + " ) a ;";
                                        sql += " select a.id,a.sphh into #dddj from (" + string.Join(" union all ",ddtempsql.ToArray()) + " ) a; ";
                                        sql += " update a   set a.id=a.id*-1 from yx_T_kcdjspid a inner join #kcdj xz on a.id=xz.id and a.spid like xz.sphh+'%'; ";
                                        sql += " update a   set a.id=a.id*-1 from yx_T_dddjspid a inner join #dddj xz on a.id=xz.id and a.spid like xz.sphh+'%'; ";
                                        sql += " drop table #kcdj; drop table #dddj;";
                                    }
                                    sql += " update yx_T_dddjmx set sjdc=1,lymxid=@id,sl=0 where mxid in (" + lymxid + ");";
                                    sql += "  select mxid into #kcmxid from yx_T_kcdjmx where mxid in (" + kcmxid + ") ;";
                                    sql += " update a set a.yzk=1,a.sl=0  from  yx_T_kcdjmx a inner join #kcmxid xz on xz.mxid=a.mxid ;";
                                    sql += " update a set a.rksl0=a.sl0,a.sl0=0 from yx_T_kcdjcmmx a inner join #kcmxid xz on xz.mxid=a.mxid;";
                                    sql += " update a set a.sl=b.sl from yx_t_kcdjmx a inner join (select mxid,sum(sl0) sl from yx_t_kcdjcmmx where id in (select distinct id from yx_t_kcdjmx where mxid in (" + lymxid + ") ) group by mxid) b on a.mxid=b.mxid where a.id  in (select distinct id from yx_t_kcdjmx where mxid in (" + lymxid + "))  ;";
                                    sql += " update yx_t_kcdjmx set je=sl*a.dj from yx_t_kcdjmx a where  mxid in (" + lymxid + ")  ;";
                                    sql += " update yx_t_kcdjb set je=b.je from (select id,sum(je) as je from yx_t_kcdjmx where id  in (select distinct id from yx_t_kcdjmx where mxid in (" + lymxid + ")) group  by id ) b where yx_t_kcdjb.id=b.id ;";
                                    sql += " update a set a.sl=b.sl,a.je=b.sl*a.dj from yx_t_dddjmx a inner join (select mxid,sum(sl0) sl from yx_t_dddjcmmx where mxid in (" + lymxid + ")  group by mxid) b on a.mxid=b.mxid where a.mxid in (" + lymxid + ") ;";
                                    sql += " update yx_t_dddjmx set je=sl*a.dj from yx_t_dddjmx a where  mxid in (" + lymxid + ")  ;";
                                    sql += " update yx_t_dddjb set je=b.je from (select id,sum(je) as je from yx_t_dddjmx where  mxid in (" + lymxid + ")  group  by id ) b where yx_t_dddjb.id=b.id ;";
                                    sql += " drop table #kcmxid ;";
                                }
                                else
                                {
                                    sql += " update yx_T_dddjmx set lymxid=0 where mxid in (" + lymxid + ");";
                                }
                                sql += " update yx_T_dddjmx set bgid=@id where mxid in (" + lymxid + ");";
                            }
                            else if (djbs == "cxp")
                            {
                                sql += " update a set a.sl=b.sl,a.je=b.sl*a.dj from yx_t_dddjmx a inner join (select mxid,sum(sl0) sl from yx_t_dddjcmmx where mxid in (" + lymxid + ")  group by mxid) b on a.mxid=b.mxid where a.mxid in (" + lymxid + ") ;";
                                sql += " update yx_t_dddjmx set je=sl*a.dj,lymxid=@id,sjdc=1  from yx_t_dddjmx a where  mxid in (" + lymxid + ")  ;";
                                sql += " update yx_t_dddjb set je=b.je from (select id,sum(je) as je from yx_t_dddjmx where  mxid in (" + lymxid + ")  group  by id ) b where yx_t_dddjb.id=b.id ;";
                            }

                            //dal.ExecuteNonQuery(sql);

                            res = initResObj(200, "ok", sql);
                        }
                        else
                        {
                            res = initResObj(200, "ok", "");
                        }

                    }
                    else
                    {
                        res = initResObj(400, "", "没有数据");
                    }
                }
                else
                {
                    res = initResObj(300, "", "执行错误:" + errinfo);
                }
            }
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }

    /// <summary>
    /// 20190108 wwh
    /// </summary>
    private void xl()
    {
        Dictionary<string, object> res = new Dictionary<string, object>();

        string DBConnStr = "server='192.168.35.10';uid=abeasd14ad;pwd=+AuDkDew;database=tlsoft";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {

            int bgid = int.Parse(Convert.ToString(Request.Params["bgid"]));

            string str_sql = @"
					  SELECT * FROM (select '@' as dm,'请选择' as mc,-1 AS xh  union all select cast(id as varchar) dm,rtrim(dm)+mc as mc,a.dm AS xh 
                      FROM t_xtdm  a WHERE ssid=6870 and tzid=1 and bz='cp' ) a ORDER BY a.xh
                    ;";

            str_sql += "EXEC yx_cx_mjgc  " + bgid.ToString();
            DataSet ds;

            string errinfo = dal.ExecuteQuery(str_sql, out ds);

            ds.Tables[0].TableName = "xl";
            ds.Tables[1].TableName = "mjcg";

            if (errinfo == "")
            {
                res = initResObj(200, JsonConvert.SerializeObject(ds), "");
            }
            else
            {
                res = initResObj(300, "", "执行错误:" + errinfo);
            }
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }



    private Dictionary<string, object> initResObj(int code, string message)
    {
        return initResObj(code, null, message);
    }

    private Dictionary<string, object> initResObj(int code, object data, string message)
    {
        Dictionary<string, object> res = new Dictionary<string, object>();
        res.Add("code", code);
        res.Add("data", data == null ? string.Empty : data);
        res.Add("message", message);
        return res;
    }

</script>
