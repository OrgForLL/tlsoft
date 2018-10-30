<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<!DOCTYPE html>
<script runat="server">
    private string DBConnStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string FXDBConnStr = "server='192.168.35.11';uid=ABEASD14AD;pwd=+AuDkDew;database=FXDB";
    

    protected void Page_Load(object sender, EventArgs e)
    {        
        string ctrl = Convert.ToString(Request.Params["ctrl"]);

        switch (ctrl)
        {
            case "loadBasicInfo":
                string tm = Convert.ToString(Request.Params["tm"]);
                string mdid = Convert.ToString(Request.Params["mdid"]);
                if (tm == "" || tm == null)
                    clsSharedHelper.WriteErrorInfo("缺少参数tm");
                else if (mdid == "" || mdid == "0" || mdid == null)
                    clsSharedHelper.WriteErrorInfo("缺少参数mdid");
                else {
                    if (tm.Trim().Length == 9)
                        loadBasicInfo(tm, mdid);
                    else {
                        string code = tmConvert(tm);
                        if (code != "")
                        {
                            loadBasicInfo(code, mdid);
                        }
                        else
                            clsSharedHelper.WriteErrorInfo("条码转换失败！【" + tm + "】");
                    }
                }
                break;
            case "staticData":
                string sphh = Convert.ToString(Request.Params["sphh"]);
                mdid = Convert.ToString(Request.Params["mdid"]);
                if (sphh == "" || sphh == null)
                    clsSharedHelper.WriteErrorInfo("缺少参数sphh");
                else if (mdid == "" || mdid == "0" || mdid == null)
                    clsSharedHelper.WriteErrorInfo("缺少参数mdid");
                else
                    staticData(sphh, mdid);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("请检查传入参数！");
                break;
        }
    }

    //获取货号基本信息
    public void loadBasicInfo(string code, string mdid)
    {
        using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConnStr))
        {
            Dictionary<string, object> jo = new Dictionary<string, object>();
            string str_sql = @"select top 1 a.sphh,cm.cm,sp.lsdj,sp.spmc 
                               from yx_t_tmb a
                               inner join yx_t_spdmb sp on a.sphh=sp.sphh
                               left join yx_t_cmzh cm on cm.tml=sp.tml and cm.cmdm=a.cmdm
                               where tm=@sphh or a.sphh=@sphh;";
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sphh", code));
            string errinfo = dal10.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string sphh = dt.Rows[0]["sphh"].ToString();
                    jo.Add("sphh", sphh);
                    jo.Add("spmc", dt.Rows[0]["spmc"].ToString());
                    jo.Add("cm", dt.Rows[0]["cm"].ToString());
                    jo.Add("lsdj", dt.Rows[0]["lsdj"].ToString());
                    dt.Clear(); dt.Dispose();

                    loadPics(sphh, mdid, jo);
                }
                else
                    clsSharedHelper.WriteErrorInfo("查询不到该货号！");
            }
            else
                clsSharedHelper.WriteErrorInfo("查询货号信息时出错 " + errinfo);
        }//end using dal10
    }

    //查询衣服图片
    public void loadPics(string sphh, string mdid, Dictionary<string, object> jo)
    {                
        using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConnStr))
        {
            string str_sql = string.Format(@"select picUrl url,picXh xh
                                             from yx_v_goodPicInfo
                                             where dataType=1 and sphh='{0}' order by picxh", sphh);
            DataTable dt;
            string errinfo = dal10.ExecuteQuery(str_sql, out dt);
            if (errinfo == "")
            {
                jo.Add("pics", dt);
                //staticData(sphh, mdid);
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(jo));
            }
            else
                clsSharedHelper.WriteErrorInfo("查询货号图片时出错 " + errinfo);
        }//end using
    }

    //统计相关数据
    public void staticData(string sphh, string mdid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXDBConnStr))
        {
            Dictionary<string, object> jo = new Dictionary<string, object>();
            DataTable LSDataTable = null;//零售数据表
            DataTable KCDataTable = null;//库存表            
            string str_sql = @"select substring(convert(varchar(20),a.rq,112),1,6) ny,b.sphh,sum(case when a.djlb in (-1,-2) then -1*b.sl else b.sl end) xssl
                                from zmd_t_lsdjb a
                                inner join zmd_t_lsdjmx b on a.id=b.id
                                inner join yx_t_spdmb c on c.sphh=@sphh 
                                inner join yx_t_spdmb sp on b.sphh=sp.sphh and sp.splbid=c.splbid and c.kfbh=sp.kfbh
                                where a.djlb in (1,-1,2,-2) and a.mdid=@mdid and a.djbs=1
                                group by substring(convert(varchar(20),a.rq,112),1,6),b.sphh";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sphh", sphh));
            paras.Add(new SqlParameter("@mdid", mdid));
            string errinfo1 = dal.ExecuteQuerySecurity(str_sql, paras, out LSDataTable);
            str_sql = @"select a.ny,a.sphh,sum(a.cgrksl) cgrksl,sum(a.cgthsl) cgthsl,sum(a.dbsl) dbsl 
                        from ds_T_Spkhckcrkqkb a
                        inner join t_mdb md on md.khid=a.tzid
                        inner join yx_t_spdmb sp on sp.sphh=@sphh
                        inner join yx_t_spdmb c on a.sphh=c.sphh and c.splbid=sp.splbid and c.kfbh=sp.kfbh
                        where md.mdid=@mdid
                        group by a.ny,a.sphh";
            paras.Clear();
            paras.Add(new SqlParameter("@sphh", sphh));
            paras.Add(new SqlParameter("@mdid", mdid));
            string errinfo2 = dal.ExecuteQuerySecurity(str_sql, paras, out KCDataTable);
            if (errinfo1 == "" && errinfo2 == "")
            {
                string ny = DateTime.Now.ToString("yyyyMM");
                int hhxssl = 0, hhdysl = 0, hhcgsl = 0, hhdbsl = 0;//货号的三个数量
                int plxssl = 0, pldysl = 0, plcgsl = 0, pldbsl = 0;//同品类的三个数量
                //统计本货号的数据
                Object _sl = LSDataTable.Compute("sum(xssl)", "ny='" + ny + "' and sphh='" + sphh + "'");
                hhdysl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                _sl = LSDataTable.Compute("sum(xssl)", "sphh='" + sphh + "'");
                hhxssl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);                
                _sl = KCDataTable.Compute("sum(cgrksl)", "sphh='" + sphh + "'");                
                hhcgsl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                _sl = KCDataTable.Compute("sum(dbsl)", "sphh='" + sphh + "'");
                hhdbsl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                jo.Add("hhdysl", hhdysl);
                jo.Add("hhxssl", hhxssl);
                jo.Add("hhcgsl", hhcgsl);
                jo.Add("hhdbsl", hhdbsl);

                //统计同品类的数据
                _sl = LSDataTable.Compute("sum(xssl)", "ny='" + ny + "'");
                pldysl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                _sl = LSDataTable.Compute("sum(xssl)", "");
                plxssl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                _sl = KCDataTable.Compute("sum(cgrksl)", "");
                plcgsl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                _sl = KCDataTable.Compute("sum(dbsl)", "");
                pldbsl = _sl == DBNull.Value ? 0 : Convert.ToInt32(_sl);
                //rt += ":" + pldysl.ToString() + "|" + plxssl.ToString() + "|" + plcgsl.ToString() + "|" + pldbsl.ToString();
                jo.Add("pldysl", pldysl);
                jo.Add("plxssl", plxssl);
                jo.Add("plcgsl", plcgsl);
                jo.Add("pldbsl", pldbsl);

                LSDataTable.Clear(); LSDataTable.Dispose();
                KCDataTable.Clear(); KCDataTable.Dispose();

                staticStock(sphh, mdid, jo);
            }
            else
                clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errinfo1 + "|" + errinfo2);
        }
    }

    //计算某个货号的库存
    public void staticStock(string sphh, string mdid, Dictionary<string, object> jo)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXDBConnStr))
        {
            string str_sql = @"select top 1 sum(isnull(a.qms,0)) qms 
                                    from (  
	                                    (select a.sphh,a.sl qms 
	                                    from yx_t_kcdjmx a
	                                    inner join yx_t_kcdjb b on a.id = b.id 
	                                    inner join t_djlxb d on b.djlx = d.dm
	                                    where  b.tzid = @mdid 
	                                    and b.qrbs = 1 and b.djbs=1 and d.lsjxc = 1 and a.sphh=@sphh 
	                                    and isnull(b.wzbs,0)<>1) 
                                    union all 
	                                    (select a.sphh,sum(a.sl*d.kc) qms 
	                                    from yx_t_kcdjmx a
	                                    inner join yx_t_kcdjb b on a.id = b.id 
	                                    inner join t_djlxb d on b.djlx = d.dm
	                                    where  b.tzid = @mdid  
	                                    and b.qrrq < DateAdd(day,1,GETDATE())  and b.qrbs = 1 and b.djbs=1 
	                                    and d.lsjxc > 1 and a.sphh=@sphh and isnull(b.wzbs,0)<>1 group by a.sphh) 
                                    union all 
	                                    (select a.sphh,sum(a.sl*d.kc) qms 
	                                    from zmd_t_lsdjmx a
	                                    inner join zmd_t_lsdjb b on a.id = b.id
	                                    inner join t_djlb d on b.djlb = d.dm
	                                    where  b.khid = @mdid 
	                                    and b.rq < DateAdd(day,1,GETDATE())  and b.djbs = 1 and b.sjcs = 0 
	                                    and b.djlb < 10 and a.sphh=@sphh and b.wzbs<>0 group by a.sphh) 
                                    ) a
                                    inner join yx_t_spdmb b on a.sphh = b.sphh
                                    inner join yx_t_splb c on b.splbid = c.id
                                    where b.tzid = 1 and b.spdlid = '1166' 
                                    group by a.sphh having sum(qms)<>0 
                                    order by a.sphh ";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sphh", sphh));
            paras.Add(new SqlParameter("@mdid", mdid));
            object scalar;
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
            if (errinfo == "")
            {
                jo.Add("kcsl", Convert.ToString(scalar));
                getSameStyle(sphh, jo);
            }
            else
                clsSharedHelper.WriteErrorInfo("计算商品库存时出错 " + errinfo);
        }//end using
    }

    //获取同款商品
    public void getSameStyle(string sphh,Dictionary<string, object> jo) {
        using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConnStr)) {
            string sql = string.Format(@"select distinct b.sphh,p.picurl
                                        from yx_t_spdmb a
                                        inner join yx_t_spdmb b on a.spkh=b.spkh and a.sphh<>b.sphh
                                        left join yx_v_goodpicinfo p on b.sphh=p.sphh
                                        where p.picxh=1 and a.sphh='{0}'
                                        order by b.sphh", sphh);
            DataTable dt;
            string errinfo = dal10.ExecuteQuery(sql,out dt);
            if (errinfo == "") {
                jo.Add("sameStyle", dt);
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(jo));
            }
            else
                clsSharedHelper.WriteErrorInfo("获取同款数据失败 " + errinfo);
        }//end using
    }
    
    //20160705 liqf调整此方法：发现有些品类的条码如鞋包类，是不需要减6
    //判断依据是总位数是否大否13，若大于13才减6否则原样返回
    private string tmConvert(string tm)
    {
        string rt = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            string sql = "select dbo.f_DBpwd(@tm)";
            object scalar;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@tm", tm));

            string errinfo = dal.ExecuteQueryFastSecurity(sql, paras, out scalar);
            if (errinfo == "")
            {
                string str = Convert.ToString(scalar);
                if (str.Length > 13)
                    rt = str.Substring(0, str.Length - 6);
                else
                    rt = str;
            }
        }

        return rt;
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
