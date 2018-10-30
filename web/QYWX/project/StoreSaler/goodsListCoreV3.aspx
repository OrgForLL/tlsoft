<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">  	   
    string FXDBConStr = "server=192.168.35.11;database=FXDB;uid=ABEASD14AD;pwd=+AuDkDew";
    string OAConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    string queryConnStr = "server=192.168.35.32;uid=lllogin;pwd=rw1894tla;database=tlsoft";
    string ERPDBConStr = "server=192.168.35.19;database=ERPDB;uid=ABEASD14AD;pwd=+AuDkDew";
    string WXConStr = System.Web.Configuration.WebConfigurationManager.ConnectionStrings["conn"].ToString();
    protected void Page_Load(object sender, EventArgs e)
    {
        string mdid, ctrl, rt = "", sphh, showType;
        mdid = Convert.ToString(Request.Params["mdid"]);
        ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "goodsListSingle":
                string lastId = Convert.ToString(Request.Params["lastID"]);
                string filter = Convert.ToString(Request.Params["filter"]);
                rt = goodsList(mdid, lastId, filter);
                break;
            case "goodsDetail":
                sphh = Convert.ToString(Request.Params["sphh"]);
                showType = Convert.ToString(Request.Params["showType"]);
                rt = goodsDetail(sphh, showType,mdid);
                break;
            case "otherDetail": 
                sphh = Convert.ToString(Request.Params["sphh"]);
                rt = otherDetail(mdid, sphh);
                    break;
            case "getScanSphh":
                string scanType = Convert.ToString(Request.Params["scanType"]);
                string scanResult = Convert.ToString(Request.Params["scanResult"]);
                rt = getScanSphh(scanType, scanResult);
                break;
            case "goodsStock":
                 string StockType = Convert.ToString(Request.Params["StockType"]);
                 sphh = Convert.ToString(Request.Params["sphh"]);
                 rt=LoadGoodsStock(mdid,sphh,StockType);
                 break;
            default: rt = "参数有误"; break;
        }
        clsSharedHelper.WriteInfo(rt);
    }
    
    //商品库存
    //加载货号对应的库存信息
    public string LoadGoodsStock(string mdid, string sphh, string StockType)
    {
        string sql, rt = "", errInfo;
        string connecting = queryConnStr;
        string RoleID = Convert.ToString(Session["RoleID"]);
        string tzid="1";
        if(RoleID == "1" || RoleID == "2"){
            using (LiLanzDALForXLM mydal = new LiLanzDALForXLM(OAConnStr))
            {
                object objtzid = new object();
                errInfo = mydal.ExecuteQueryFast(string.Format("select khid from t_mdb where mdid={0}",mdid), out objtzid);
                if (errInfo == "")
                {
                    tzid = objtzid.ToString();
                }
            }   
        }
        
        LiLanzDALForXLM dal = new LiLanzDALForXLM(queryConnStr);
        switch (StockType)
        {
            case "kcxx":
                if (RoleID == "1" || RoleID == "2")//门店人员，根据mdid来查门店数据
                {
                    sql = @"select top 20 a.cm,SUM(ISNULL(b.sl0,0)) sl
                        from  yx_t_cmzh a
                        inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1
                        left join(
                            select a.cmdm,a.sl0
                            FROM t_mdb md INNER JOIN  yx_t_spkccmmx a ON md.khid=tzid  inner join YX_T_Spdmb b on a.sphh=b.sphh and b.tzid=1
                            where md.mdid='{1}' and a.sphh='{0}' 
                        ) b on a.cmdm=b.cmdm
                        where a.tzid=1 
                        GROUP BY a.cm order by a.cm";
                }
                else//贸易公司或总部人员根据tzid来查
                {
                    tzid = mdid;
                    sql = @"select top 20 a.cm,SUM(ISNULL(b.sl0,0)) sl
                        from  yx_t_cmzh a
                        inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1 left join( select a.cmdm,a.sl0
                            from yx_t_spkccmmx a inner join YX_T_Spdmb b on a.sphh=b.sphh and b.tzid=1
                            where a.tzid='{1}' and a.sphh='{0}' 
                        ) b on a.cmdm=b.cmdm
                        where a.tzid=1 
                        GROUP BY a.cm order by a.cm";
                }
                break;
            case "dhl":
               if (RoleID == "1" || RoleID == "2")
                {
                    sql = @"SELECT a.cm,SUM(ISNULL(b.sl0,0)) AS sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1 
                                LEFT JOIN (SELECT cmdm,sl0 FROM t_mdb a inner join dbo.yx_v_dddjcmmx  b on a.khid=b.tzid 
                                WHERE djlx=201 AND djbs=1 AND sphh='{0}' AND a.mdid={1}) b ON a.cmdm=b.cmdm 
                                GROUP BY a.cm order by a.cm";
                }
                else
                {
                    tzid = mdid;
                    sql = @"SELECT a.cm,SUM(ISNULL(b.sl0,0)) AS sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1 
                                LEFT JOIN (SELECT cmdm,sl0 FROM dbo.yx_v_dddjcmmx
                                WHERE djlx=201 AND djbs=1 AND sphh='{0}' AND tzid={1}) b ON a.cmdm=b.cmdm 
                                GROUP BY a.cm
                                order by a.cm";
                }
               
                break;
            case "xsl": sql = @"select a.cmdm,a.sl*(a.djlb/abs(a.djlb)) sl INTO #temp
                                from zmd_V_lsdjmx a
                                inner join YX_T_Spdmb b on a.sphh=b.sphh and b.tzid=1 AND a.djbs=1
                                where a.khid in(select b.khid FROM yx_t_khb a INNER JOIN yx_t_khb b INNER JOIN yx_t_khfl c ON b.khfl=c.cs ON b.ccid LIKE a.ccid+'%' WHERE a.khid={1} AND b.ty=0 ) AND a.sphh='{0}'
                                select top 20 a.cm,SUM(ISNULL(b.sl,0)) sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1
                                left JOIN #temp b on a.cmdm=b.cmdm
                                where a.tzid=1 
                                GROUP BY a.cm order by a.cm
                                DROP TABLE #temp ";
                break;
            case "zzl": sql = @"select top 20 a.cm,SUM(ISNULL(tc.sl,0)-ISNULL(dd.sl,0)) sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1
                                LEFT JOIN (
                                SELECT  b.cmdm,SUM(b.sl0) AS sl 
                                FROM yx_t_tcjhb a INNER JOIN yx_t_tcjhcmmx b ON a.id=b.id WHERE a.sphh='{0}' and a.shbs=1
                                GROUP BY b.cmdm) tc ON a.cmdm=tc.cmdm
                                LEFT JOIN (
                                SELECT  cmdm,SUM( sl0) AS sl
                                FROM dbo.yx_v_dddjcmmx WHERE sphh='{0}' AND djlx=201
                                GROUP BY cmdm ) dd ON a.cmdm=dd.cmdm 
                                GROUP BY a.cm";
                break;
            case "bhl": sql = @"select top 20 a.cm,SUM(ISNULL(b.sl0,0)) sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1
                                left join(SELECT sl0-dbdf0-qtdf0 AS sl0,cmdm FROM dbo.YX_T_Spkccmmx WHERE sphh='{0}' AND tzid=1) b on a.cmdm=b.cmdm
                                where a.tzid=1 
                                GROUP BY a.cm
                                order by a.cm";
                break;
            default: sql = ""; break;
        }
        switch (StockType)
        {
            case "kcxx":
            case "dhl": if (dal.GetDBName(Convert.ToInt32(tzid)).ToUpper() == "FXDB")
                {
                    connecting = FXDBConStr;
                }
                else if (dal.GetDBName(Convert.ToInt32(tzid)).ToUpper() == "ERPDB")
                {
                    connecting = ERPDBConStr;
                }
                else if (dal.GetDBName(Convert.ToInt32(tzid)).ToUpper() == "TLSOFT")
                {
                    connecting = OAConnStr;
                }
                break;
            case "xsl": connecting = queryConnStr; break;
            case "zzl":
            case "bhl": connecting = OAConnStr;
                break;
            default: sql = ""; break;
        }
        //需要增加判断sql合法性
        sql = string.Format(sql, sphh, mdid);
        DataTable dt;
        dal.ConnectionString = connecting;
        errInfo = dal.ExecuteQuery(sql, out dt);
        dal.Dispose();
        
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            rt = JsonHelp.dataset2json(dt);
        }
        return rt;
    }
    //主商品信息
    public string goodsList(string mdid, string lastId, string filter)
    {
        string errInfo, rt, strsql, sql_tj = "", sqlfilter = " GROUP by  b.sphh,c.kfbh,c.id ";
        string RoleID = Convert.ToString(Session["RoleID"]);
        string ConString=OAConnStr;
      
        if (lastId != "-1")
        {
            sql_tj = string.Format("and c.id<{0}", lastId);
        }

        if (filter != null && filter != "")
        {
            string[] filArry=filter.Split('|');
            switch (filArry[0])
            {
                case "sphh": sqlfilter = string.Concat(string.Format(" and b.sphh like '{0}%'", filArry[1]), sqlfilter); break;
                case "kczt":
                    if (filArry[1] == "1")
                    {
                        sqlfilter =string.Concat(sqlfilter, " having SUM(b.sl0)>0");
                    }
                    else
                    {
                        sqlfilter = string.Concat(sqlfilter, " having SUM(b.sl0)<=0");
                    }
                    break;//库存状态
                case "splb": sqlfilter =string.Concat(string.Format(" and splb.mc like '%{0}%'", filArry[1]),sqlfilter); break;
                case "yxzt": sqlfilter = string.Concat(" and c.ztbs=1 ",sqlfilter); break;
            }
        }

        if (RoleID == "1" || RoleID == "2")//门店人员，根据mdid来查门店数据
        {
            strsql = @"select top 12 c.kfbh,b.sphh,max(c.ypmc) as spmc,MAX(c.yphh) as yphh,MAX(c.lsdj) as lsdj,SUM(b.sl0)  as kc,'' as urlAddress,c.id AS xh
                        FROM t_MDb a INNER JOIN  yx_t_spkccmmx b ON a.khid=b.tzid AND a.ckid=b.ckid  inner join YX_T_ypdmb c on b.sphh=c.sphh and c.tzid=1 
                        inner join YX_T_Splb splb on c.splbid=splb.id 
                        where a.mdid={0}  and left(c.sphh,4)<>'5dzp' and c.ztbs=1 {1} {2} 
                         ORDER by c.kfbh desc,c.id desc;";
        }
        else//贸易公司或总部人员根据tzid来查
        {
            strsql = @"select top 12 c.kfbh,b.sphh,max(c.ypmc) as spmc,MAX(c.yphh) as yphh,MAX(c.lsdj) as lsdj,SUM(b.sl0)  as kc,'' as urlAddress,c.id AS xh
                    from yx_t_spkccmmx b inner join YX_T_ypdmb c on b.sphh=c.sphh and c.tzid=1 
                    inner join YX_T_Splb splb on c.splbid=splb.id 
                    where b.tzid={0}  and left(c.sphh,4)<>'5dzp' and c.ztbs=1 {1} {2}
                    ORDER by c.kfbh desc,c.id desc;";
        }
        strsql = string.Format(strsql,mdid,sql_tj,sqlfilter);
        DataTable dt = new DataTable();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConString))
        {
            if (dal.GetDBName(Convert.ToInt32(mdid)).ToUpper() == "FXDB")
            {
                ConString = FXDBConStr;
            }
            else if (dal.GetDBName(Convert.ToInt32(mdid)).ToUpper() == "ERPDB")
            {
                ConString = ERPDBConStr;
            }
            dal.ConnectionString = ConString;
            errInfo = dal.ExecuteQuery(strsql, out dt);
        }
        if (errInfo != "")
        {
            rt = clsNetExecute.Error + errInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "未找到关联商品";
          //  rt = "Error:未找到相关商品!";
        }
        else
        {
            GoodsPic(ref dt);
            rt = JsonHelp.dataset2json(dt);
            dt.Dispose();
        }
        return rt;
    }
    //获取商品图片
    public string GoodsPic(ref DataTable dt)
    {
        string strsphhs = "'ZZZ'", errinfo, rt;
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            strsphhs = string.Concat(strsphhs, string.Format(",'{0}'", dt.Rows[i]["sphh"].ToString()));
        }
        if (strsphhs != "")
        {
            string strsql = string.Format(@" select top 100 sphh,yphh,picUrl from yx_v_goodPicInfo where dataType=1 and sphh in ({0}) and picXh=1", strsphhs);
            DataTable dt_url = new DataTable();
            using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
            {
                errinfo = MDal.ExecuteQuery(strsql, out dt_url);
            }

            if (errinfo != "")
            {
                rt = errinfo;
            }
            else if (dt.Rows.Count < 1)
            {
                rt = clsNetExecute.Error + "未找到关联商品图片";
            }
            else
            {
                for (int i = 0; i < dt_url.Rows.Count; i++)
                {
                    DataRow[] dr = dt.Select("sphh='" + dt_url.Rows[i]["sphh"].ToString() + "'");
                    dr[0]["urlAddress"] = dt_url.Rows[i]["picUrl"].ToString();
                }
                rt = clsNetExecute.Successed;
                dt_url.Dispose();
            }
        }
        else
        {
            rt =clsNetExecute.Error+ "无商品信息";
        }
        return rt;
    }

    //商品信息
    public string goodsDetail(string sphh,string showType,string mdid)
    {
        string errorInfo, rt, strsql;

        strsql = string.Format(@"select sp.sphh,sp.yphh,isnull(c.picUrl,'') as urlAddress,isnull(c.picXh,0) xh,sp.spmc,sp.lsdj,sp.kfbh
						   from yx_T_spdmb sp 
						   left join yx_v_goodPicInfo c on sp.sphh=c.sphh and c.dataType=1
						   where sp.sphh='{0}' and sp.tzid=1",sphh);
        DataTable dt = new DataTable();
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
        {
            errorInfo = MDal.ExecuteQuery(strsql, out dt);
        }

        if (errorInfo != "")
        {
            rt = errorInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "未找到关联商品图片";
        }
        else
        {
            rt = "";
        }

        clsJsonHelper gdJson = new clsJsonHelper();
        if (rt == "")
        {
            gdJson.AddJsonVar("goodDetail", JsonHelp.dataset2json(dt), false);
            dt.Dispose();
        }
        else
        {
          gdJson.AddJsonVar("goodDetail", rt);
        }

        string goodsStock = LoadGoodsStock(mdid, sphh, "kcxx");

        if (goodsStock.IndexOf(clsNetExecute.Error) >= 0)
        {
            gdJson.AddJsonVar("goodsStock", goodsStock);
        }
        else
        {
            gdJson.AddJsonVar("gStock", goodsStock,false);
        }
      
        
      
        return gdJson.jSon;
    }
    private string otherDetail(string mdid, string sphh)
    {
        string rt = "",errInfo="",sql="";
        clsJsonHelper ogdJson = new clsJsonHelper();
       
        string RoleID = Convert.ToString(Session["RoleID"]);
        if (RoleID == "2")
        {
            sql = string.Format("SELECT count(1)  FROM dbo.wx_t_OpinionFeedback a INNER JOIN wx_t_RelateToSphh b ON a.id=b.RelateTableID where b.sphh='{0}' AND a.CreateCustomerID='{1}'   ", sphh, Convert.ToString(Session["qy_customersid"]));
        }
        else if (RoleID == "3")
        {
            sql = string.Format("SELECT count(1)  FROM dbo.wx_t_OpinionFeedback a INNER JOIN wx_t_RelateToSphh b ON a.id=b.RelateTableID where b.sphh='{0}'", sphh);
        }
        
        DataTable dt=new DataTable();
        if (sql != "")
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConStr))
            {
                errInfo = dal.ExecuteQuery(sql, out dt);
            }
        }

        if (errInfo == "" && dt.Rows.Count > 0)
        {
            ogdJson.AddJsonVar("OFBNum", Convert.ToString(dt.Rows[0][0]));
        }
        else
        {
            ogdJson.AddJsonVar("OFBNum", "0");
        }
        dt.Dispose();

        clsLocalLoger.WriteInfo("WXConStr:" + WXConStr + "|sql=" + sql);
        string temp = LoadCMInfos(sphh);
        if (temp.IndexOf(clsNetExecute.Error)>=0)
        {
            ogdJson.AddJsonVar("CMInfos", temp);
        }
        else
        {
            ogdJson.AddJsonVar("CMInfos", temp, false);
        }

        temp = loadTheSameType(sphh);
        if (temp.IndexOf(clsNetExecute.Error) >= 0)
        {
            ogdJson.AddJsonVar("TheSameType", temp);
        }
        else
        {
            ogdJson.AddJsonVar("TheSameType", temp, false);
        }

        temp = goodsImg(sphh);
        if (temp.IndexOf(clsNetExecute.Error) >= 0)
        {
            ogdJson.AddJsonVar("goodsImg", temp);
        }
        else
        {
            ogdJson.AddJsonVar("goodsImg", temp,false);
        }
        rt = ogdJson.jSon;
        return rt;
    }
    public string LoadCMInfos(string sphh)
    {
        string rt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            string str_sql = @"declare @sql varchar(8000);declare @tsql varchar(8000);declare @sid int;
                                select @tsql='';
                                select @sid=max(a.id) from yf_t_ytfab a inner join yf_T_ytfamxb b on a.id=b.id where a.lx='bx' and a.dm=@sphh group by a.dm;
                                select @tsql=@tsql+' max(case when a.mc='''+a.mc+''' then convert(varchar,a.sz) else '''' end) '''+a.mc+''''+','
                                from (select distinct mc from yf_T_ytfamxb where id=@sid) a;
                                if @tsql=''
                                select '00';
                                else
                                begin
                                select @tsql=substring(@tsql,1,len(@tsql)-1);
                                select @sql=' select cm.cm ''尺码'','+@tsql+' from yf_t_ytfamxb a inner join yx_t_cmzh cm on cm.cmdm=a.dm where a.id='+convert(varchar,@sid)+' and cm.tml='''+isnull((select tml from yx_t_spdmb where sphh=@sphh),'')+''' group by cm.cm order by len(cm.cm)';
                                exec(@sql);
                                end";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sphh", sphh));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0 && Convert.ToString(dt.Rows[0][0]) != "00")
                {
                    rt = JsonHelp.dataset2json(dt);
                    dt.Dispose();
                }
                else
                    rt = clsNetExecute.Error + "：无相关尺码";
            }
            else
            {
                rt=errinfo;
            }
        }
        return rt;
    }
    //加载同款商品，要确定要不要根据门店库存情况来显示
    public string loadTheSameType(string sphh)
    {
        string errInfo;
        string rt;
        string mysql = @"SELECT TOP 100 b.id,b.sphh,b.spmc,b.lsdj,MAX(ISNULL(p.picUrl,'')) AS urlAddress
                        FROM dbo.YX_T_Spdmb a 
                        INNER JOIN dbo.YX_T_Spdmb b ON a.spkh=b.spkh AND a.sphh='{0}' AND b.sphh<>a.sphh 
                        LEFT JOIN yx_v_goodPicInfo p ON b.sphh=p.sphh
                        GROUP BY b.id, b.sphh,b.spmc,b.lsdj";
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(string.Format(mysql, sphh), out dt);
        }
        if (errInfo == "" && dt.Rows.Count > 0)
        {
            rt = JsonHelp.dataset2json(dt);
        }
        else
        {
            rt = clsNetExecute.Error + ":查无同款";
        }
        dt.Dispose();
        return rt;
    }
    public string goodsImg(string sphh)
    {
        string errorInfo, rt;
        string strsql = @" 	select a.sphh,a.spmc,isnull(c.cpmd,'')  AS cpmd,isnull(c.mlcf,'') mlcf,isnull(urlAddress,'') urlAddress
                            From yx_t_spdmb a 
                            inner join t_uploadfile b on a.id=b.tableid and b.groupid=8 
                            left outer join yx_t_cpinfo c on a.sphh=c.sphh 
                            where a.sphh=@sphh ;";

        List<SqlParameter> param = new List<SqlParameter>();
        param.Add(new SqlParameter("@sphh", sphh));
        DataTable dt = new DataTable();
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
        {
            errorInfo = MDal.ExecuteQuerySecurity(strsql, param, out dt);
        };
        if (errorInfo != "")
        {
            rt = clsNetExecute.Error + errorInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "无商品图片";
        }
        else
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                dt.Rows[i]["cpmd"] = HttpUtility.UrlEncodeUnicode(Convert.ToString(dt.Rows[i]["cpmd"]));
            }
            rt = JsonHelp.dataset2json(dt);
            dt.Dispose();
        }
        dt.Dispose();
        return rt;
    }

    
    private string getScanSphh(string scanType, string scanResult)
    {
        string errInfo,mysql,rt = "";
        switch (scanType)
        {
            case "qrCode": mysql = @"declare @strGood varchar(30) select @strGood=dbo.f_DBPwd('{0}') 
                        select @strGood = (CASE WHEN (LEN(@strGood) > 13) 
                        THEN SUBSTRING(@strGood, 1, LEN(@strGood) - 6) ELSE @strGood END) 
                        select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood 
                        SELECT @strGood as sphh";
                break;
            case "barCode": mysql = @"declare @strGood varchar(30)  select @strGood = SUBSTRING('{0}', 1, LEN('{0}') - 6)
                          select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood ; SELECT @strGood  as sphh ";
                break;
            default: mysql = "";
                break;
        }
        DataTable dt;
        if (mysql != "")
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                errInfo = dal.ExecuteQuery(string.Format(mysql, scanResult), out dt);
            }
            if (errInfo != "")
            {
                rt = errInfo;
            }
            else if (dt.Rows.Count < 1)
            {
                rt = clsNetExecute.Error + "无效条码，无法找到相关信息";
            }
            else
            {
                rt = Convert.ToString(dt.Rows[0]["sphh"]);
                dt.Dispose();
            }
        }
        else
        {
            rt =clsNetExecute.Error+ "非法访问。";
        }
        return rt;
    }
  

    //写日志
    private void WriteLog(string strText)
    {
        String path = HttpContext.Current.Server.MapPath("logs/");
        if (!System.IO.Directory.Exists(System.IO.Path.GetDirectoryName(path)))
        {
            System.IO.Directory.CreateDirectory(path);
        }

        System.IO.StreamWriter writer = new System.IO.StreamWriter(path + DateTime.Now.ToString("yyyyMMdd") + ".log", true);
        string str;
        str = "【" + DateTime.Now.ToString() + "】" + "  " + strText;
        writer.WriteLine(str);
        writer.Close();
    }
</script>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
