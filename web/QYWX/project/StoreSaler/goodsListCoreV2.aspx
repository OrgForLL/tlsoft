<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">  

    //string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    //string FXDBConStr = clsConfig.GetConfigValue("FXDBConStr");	   
    string FXDBConStr = " server=192.168.35.11;database=FXDB;uid=ABEASD14AD;pwd=+AuDkDew";
    string OAConnStr = " server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    string queryConnStr = " server=192.168.35.32;uid=lllogin;pwd=rw1894tla;database=tlsoft";
    
    private const string qrCodeSphhSQL = @" declare @strGood varchar(30) select @strGood=dbo.f_DBPwd(@sphh) 
                                                    select @strGood = (CASE WHEN (LEN(@strGood) > 13) THEN SUBSTRING(@strGood, 1, LEN(@strGood) - 6) ELSE @strGood END) 
                                                    select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood ";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string showType, mdid, rt = "", scanResult, scanType, ctrl, lastId,sphh;
        showType = Convert.ToString(Request.Params["showType"]);
        mdid = Convert.ToString(Request.Params["mdid"]);
        ctrl = Convert.ToString(Request.Params["ctrl"]);

        switch (showType)
        {
            case "1": 
                switch (ctrl)
                {
                    case "goodsList":
                        scanResult = Convert.ToString(Request.Params["scanResult"]);
                        lastId = Convert.ToString(Request.Params["lastID"]);
                        if (scanResult == "")
                            rt = goodsList(mdid, lastId);
                        else
                            rt = goodsListSingle(mdid, scanResult, "", lastId);
                        break;
                    case "goodsfilter":
                        scanResult = Convert.ToString(Request.Params["scanResult"]);
                        scanType = Convert.ToString(Request.Params["scanType"]);
                        rt = goodsfilter(mdid, scanResult, scanType);
                        break;
                    case "goodsListSingle":
                        scanResult = Convert.ToString(Request.Params["scanResult"]);
                        scanType = Convert.ToString(Request.Params["scanType"]);
                        lastId = Convert.ToString(Request.Params["lastID"]);                        
                        rt = goodsListSingle(mdid, scanResult, scanType, lastId);
                        break;
                    case "goodsDetail":
                        scanResult = Convert.ToString(Request.Params["scanResult"]);
                        scanType = Convert.ToString(Request.Params["scanType"]);
                        rt = goodsDetail(scanResult, scanType);
                        break;
                    case "goodsStock":
                        scanResult = Convert.ToString(Request.Params["scanResult"]);
                        scanType = Convert.ToString(Request.Params["scanType"]);
                        rt = goodsStock(mdid, scanResult, scanType);
                        break;

                    case "goodsImg":
                        scanResult = Convert.ToString(Request.Params["scanResult"]);
                        scanType = Convert.ToString(Request.Params["scanType"]);
                        rt = goodsImg(scanResult, scanType);
                        break;
                    case "selectGoodsStock":
                         sphh = Convert.ToString(Request.Params["sphh"]);
                        string StockType = Convert.ToString(Request.Params["StockType"]);
                       rt= LoadGoodsStock(mdid, sphh, StockType);
                        break;
                    case "loadSameType":
                         sphh = Convert.ToString(Request.Params["sphh"]);
                         rt = loadTheSameType(sphh);
                         break;
                    default:
                        rt = "参数有误Store";
                        break;
                }
                break;
            case "2":
                switch (ctrl)
                {
                    case "goodsDetail":
                        scanResult = Convert.ToString(Request.Params["scanResult"]);
                        scanType = Convert.ToString(Request.Params["scanType"]);
                        rt = goodsDetail(scanResult, scanType);
                        break;
                    case "goodsImg":
                        scanResult = Convert.ToString(Request.Params["scanResult"]);
                        scanType = Convert.ToString(Request.Params["scanType"]);
                        rt = goodsImg(scanResult, scanType);
                        break;
                    case "LoadCMInfos":
                        sphh = Convert.ToString(Request.Params["sphh"]);
						scanType = Convert.ToString(Request.Params["scanType"]);
                        LoadCMInfos(sphh,scanType);
                        break;
                    default:
                        rt = "参数有误Customer";                        
                        break;
                };
                break;
            default: rt = "参数有误"; break;
        };

        clsSharedHelper.WriteInfo(rt);
    }
    //加载货号对应的库存信息
    public string LoadGoodsStock(string mdid, string sphh, string StockType)
    {
        string sql,rt="",errInfo;
        string connecting = queryConnStr;
        //kcxx|dhl|xsl|zzl|bhl
        switch (StockType)
        {
            case "kcxx": sql = @"select top 20 a.cm,SUM(ISNULL(b.sl0,0)) sl
                        from  yx_t_cmzh a
                        inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1
                        left join(
                            select a.cmdm,a.sl0
                            from yx_t_spkccmmx a
                            inner join YX_T_Spdmb b on a.sphh=b.sphh and b.tzid=1
                            where a.tzid='{1}' and a.sphh='{0}' 
                        ) b on a.cmdm=b.cmdm
                        where a.tzid=1 
                        GROUP BY a.cm
						order by a.cm";
                connecting=FXDBConStr;  break;
            case "dhl":
                if (Convert.ToString(Session["RoleID"]) == "3" || Convert.ToString(Session["RoleID"]) == "99")
                {
                    sql = @"SELECT a.cm,SUM(ISNULL(b.sl0,0)) AS sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1 
                                LEFT JOIN (SELECT cmdm,sl0 FROM dbo.yx_v_dddjcmmx
                                WHERE djlx=201 AND djbs=1 AND sphh='{0}' AND tzid={1}) b ON a.cmdm=b.cmdm 
                                GROUP BY a.cm
                                order by a.cm";
                }
                else
                {
                    sql = @"SELECT a.cm,SUM(ISNULL(b.sl0,0)) AS sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1 
                                LEFT JOIN (SELECT cmdm,sl0 FROM dbo.yx_v_dddjcmmx
                                WHERE djlx=201 AND djbs=1 AND sphh='{0}' AND khid={1}) b ON a.cmdm=b.cmdm 
                                GROUP BY a.cm
                                order by a.cm";
                }
               break;
            case "xsl": sql = @"select a.cmdm,a.sl INTO #temp
                                from zmd_V_lsdjmx a
                                inner join YX_T_Spdmb b on a.sphh=b.sphh and b.tzid=1 AND a.djbs=1
                                where a.khid in(select khid from yx_t_khb where khid={1} or ssid={1}) AND a.sphh='{0}'
                                select top 20 a.cm,SUM(ISNULL(b.sl,0)) sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1
                                left JOIN #temp b on a.cmdm=b.cmdm
                                where a.tzid=1 
                                GROUP BY a.cm
                                order by a.cm
                                DROP TABLE #temp "; break;
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
                      connecting = OAConnStr;break;
            case "bhl": sql = @"select top 20 a.cm,SUM(ISNULL(b.sl0,0)) sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1
                                left join(SELECT sl0-dbdf0-qtdf0 AS sl0,cmdm FROM dbo.YX_T_Spkccmmx WHERE sphh='{0}' AND tzid=1) b on a.cmdm=b.cmdm
                                where a.tzid=1 
                                GROUP BY a.cm
                                order by a.cm";
                connecting = OAConnStr;
                               break;
            default :sql="";break;
        }
        //需要增加判断sql合法性
        sql = string.Format(sql,sphh, mdid);
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(connecting))
        {
            errInfo = dal.ExecuteQuery(sql, out dt);
        }
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
    //加载同款商品，要确定要不要根据门店库存情况来显示
    public string loadTheSameType(string sphh)
    {
        string errInfo, rt = "";
        string mysql = @"SELECT TOP 100 b.id,b.sphh,b.spmc,b.lsdj,MAX(ISNULL(p.picUrl,'')) AS urlAddress
                        FROM dbo.YX_T_Spdmb a 
                        INNER JOIN dbo.YX_T_Spdmb b ON a.spkh=b.spkh AND a.sphh='{0}' AND b.sphh<>a.sphh 
                        LEFT JOIN yx_v_goodPicInfo p ON b.sphh=p.sphh
                        GROUP BY b.id, b.sphh,b.spmc,b.lsdj";
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
        errInfo=dal.ExecuteQuery(string.Format(mysql,sphh),out dt);
        }
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
    //加载相应货号的尺码信息 20160613 by liqf
    public void LoadCMInfos(string sphh,string scanType) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            string str_sql = @"declare @sql varchar(8000);declare @tsql varchar(8000);declare @sid int;
			                   {0}
                                select @tsql='';
                                select @sid=max(a.id) from yf_t_ytfab a inner join yf_T_ytfamxb b on a.id=b.id where a.lx='bx' and a.dm=@strGood group by a.dm;
                                select @tsql=@tsql+' max(case when a.mc='''+a.mc+''' then convert(varchar,a.sz) else '''' end) '''+a.mc+''''+','
                                from (select distinct mc from yf_T_ytfamxb where id=@sid) a;
                                if @tsql=''
                                select '00';
                                else
                                begin
                                select @tsql=substring(@tsql,1,len(@tsql)-1);
                                select @sql=' select cm.cm ''尺码'','+@tsql+' from yf_t_ytfamxb a inner join yx_t_cmzh cm on cm.cmdm=a.dm where a.id='+convert(varchar,@sid)+' and cm.tml='''+isnull((select tml from yx_t_spdmb where sphh=@strGood),'')+''' group by cm.cm order by len(cm.cm)';
                                exec(@sql);
                                end";
								
			if	(scanType=="barCode"){
			    str_sql= string.Format(str_sql,@" declare @strGood varchar(30) ; select @strGood = SUBSTRING(@sphh, 1, LEN(@sphh) - 6); select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood");
			}else if(scanType == "qrCode"){
                str_sql = string.Format(str_sql, qrCodeSphhSQL);
			}else{
				str_sql= string.Format(str_sql,@" declare @strGood varchar(30) ; select @strGood=@sphh; ");
			}				
								
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sphh", sphh));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            //WriteLog("CMINFOLOAD ERROR" + "str_sql:" + str_sql + "sphh:" + sphh);
			//clsSharedHelper.WriteErrorInfo(errinfo);
            if (errinfo == "")
                if (dt.Rows.Count > 0 && Convert.ToString(dt.Rows[0][0]) != "00")
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                else
                    clsSharedHelper.WriteInfo("");
            else
                clsSharedHelper.WriteErrorInfo("CMINFO"+errinfo);
        }
    }
    
    //主商品信息
    public string goodsList(string mdid, string lastId)
    {
        string errinfo, rt, strsql;
        string RoleID = Convert.ToString(Session["RoleID"]);
        string ConString = FXDBConStr;
        List<SqlParameter> param = new List<SqlParameter>();
        if (lastId == "-1")
        {
            if (RoleID == "3" || RoleID == "99" || RoleID == "4")
            {
                if (RoleID == "3" || RoleID == "99")
                {
                    ConString = OAConnStr;
                }
                strsql = @" select top 12 c.kfbh,b.sphh,max(c.ypmc) as spmc,max(c.yphh) as yphh,max(c.lsdj) as lsdj,sum(b.sl0)  as kc,'' as urlAddress
                           ,ROW_NUMBER()over(order by b.sphh desc) as xh 
                           from yx_t_spkccmmx b inner join YX_T_ypdmb c on b.sphh=c.sphh and c.tzid=1 
                           where b.tzid=@mdid and left(c.sphh,4)<>'5dzp' and c.ztbs=1 group by b.sphh,c.kfbh order by c.kfbh desc,b.sphh desc;";
                
            }
            else
            {
                strsql = @" select top 12 c.kfbh,b.sphh,max(c.ypmc) as spmc,max(c.yphh) as yphh,max(c.lsdj) as lsdj,sum(b.sl0)  as kc,'' as urlAddress
                           ,ROW_NUMBER()over(order by b.sphh desc) as xh 
                           from t_MDb a  inner join yx_t_spkccmmx b on  a.khid=b.tzid and a.ckid=b.ckid 
                           inner join YX_T_ypdmb c on b.sphh=c.sphh and c.tzid=1 
                           where a.mdid=@mdid and left(c.sphh,4)<>'5dzp' and c.ztbs=1 group by b.sphh,c.kfbh order by c.kfbh desc,b.sphh desc;";
            }
            param.Add(new SqlParameter("@mdid", mdid));
        }
        else
        {
            if (RoleID == "3" || RoleID == "99" || RoleID == "4")//总部查库存
            {
                if (RoleID == "3" || RoleID == "99")
                {
                    ConString = OAConnStr;
                }
                strsql = @" select c.kfbh,b.sphh,max(c.ypmc) as spmc,max(c.yphh) as yphh,max(c.lsdj) as lsdj,sum(b.sl0)  as kc,'' as urlAddress
                           ,ROW_NUMBER()over(order by b.sphh desc) as xh into #temp 
                           from yx_t_spkccmmx b inner join YX_T_ypdmb c on b.sphh=c.sphh and c.tzid=1 
                           where b.tzid=@mdid and left(c.sphh,4)<>'5dzp' and c.ztbs=1 group by b.sphh,c.kfbh order by c.kfbh desc,b.sphh desc;  
                           select top 12 kfbh,sphh,spmc,yphh,lsdj,kc,urlAddress,xh from #temp where xh>@lastId;
                           drop table #temp;";

            }
            else
            {
                strsql = @" select c.kfbh,b.sphh,max(c.ypmc) as spmc,max(c.yphh) as yphh,max(c.lsdj) as lsdj,sum(b.sl0)  as kc,'' as urlAddress
                           ,ROW_NUMBER()over(order by b.sphh desc) as xh into #temp 
                           from t_MDb a  inner join yx_t_spkccmmx b on  a.khid=b.tzid and a.ckid=b.ckid 
                           inner join YX_T_ypdmb c on b.sphh=c.sphh and c.tzid=1 
                           where a.mdid=@mdid and left(c.sphh,4)<>'5dzp' and c.ztbs=1 group by b.sphh,c.kfbh order by c.kfbh desc,b.sphh desc;  
                           select top 12 kfbh,sphh,spmc,yphh,lsdj,kc,urlAddress,xh from #temp where xh>@lastId;
                           drop table #temp;";
            }
          
            param.Add(new SqlParameter("@mdid", mdid));
            param.Add(new SqlParameter("@lastId", lastId));
        }

        DataTable dt = new DataTable();
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(ConString))
        {
            errinfo = MDal.ExecuteQuerySecurity(strsql, param, out dt);
        }
        if (errinfo != "")
        {
            rt = "Error:" + errinfo;
        }
        else if (dt.Rows.Count < 1)
        {            
            rt = clsNetExecute.Error + "未找到关联商品";
            rt = "Warn:未找到相关商品!";
        }
        else
        {
            //获取对应图片
            GoodsPic(ref dt);
            rt = JsonHelp.dataset2json(dt);
        }
        return rt;
    }

    //扫描及查找商品信息列表	
    public string goodsListSingle(string mdid, string scanResult, string scanType,string lastid)
    {
        string errinfo, strsql, rt;
        string goods = scanResult;
        /*strsql=@" {0} 
                select top 12 c.kfbh,b.sphh,max(c.spmc) as spmc,max(c.yphh) as yphh,max(c.lsdj) as lsdj,sum(b.sl0)  as kc,'' as urlAddress ,row_number()over(order by b.sphh desc) as xh
                from t_MDb a  inner join yx_t_spkccmmx b on  a.khid=b.tzid and a.ckid=b.ckid 
                inner join YX_T_Spdmb c on b.sphh=c.sphh and c.tzid=1
                where a.mdid=@mdid {1} group by b.sphh,c.kfbh order by c.kfbh desc,b.sphh desc;    
                "; 
        */
        strsql = @" {0} 
				select c.kfbh,c.sphh,max(c.spmc) as spmc,max(c.yphh) as yphh,max(c.lsdj) as lsdj,sum(case when b.tzid=a.mdid then b.sl0 else 0 end)  as kc,'' as urlAddress ,row_number()over(order by c.sphh desc) as xh into #temp
         	    from  YX_T_spdmb c 
         	    left join yx_t_spkccmmx b on c.sphh=b.sphh
         	    left join t_MDb a on b.tzid=a.khid and b.ckid=a.ckid and a.mdid=@mdid
				where c.tzid=1 {1} group by c.sphh,c.kfbh order by c.kfbh desc,c.sphh desc;
                select top 12 kfbh,sphh,spmc,yphh,lsdj,kc,urlAddress,xh from #temp where xh>@lastId;
                drop table #temp;";
        if (goods.Length > 3)
        {
            if (scanType == "barCode")
            {
                strsql = string.Format(strsql, @"declare @strGood varchar(30) select @strGood = SUBSTRING(@sphh, 1, LEN(@sphh) - 6)
												select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood ", " and c.sphh=@strGood ");
            }
            else if (scanType == "qrCode")
            {
                strsql = string.Format(strsql, qrCodeSphhSQL, " and c.sphh=@strGood ", " and c.sphh=@strGood ");
            }
            else
            {
                strsql = string.Format(strsql, "declare @strGood varchar(30);select @strGood=@sphh;", " and c.sphh like @strGood+'%' ");
            }
        }
        else
        {
            strsql = string.Format(strsql, "declare @strGood varchar(30);select @strGood=@sphh;", " and c.sphh = @strGood ");
        }

        List<SqlParameter> param = new List<SqlParameter>();
        param.Add(new SqlParameter("@mdid", mdid));
        param.Add(new SqlParameter("@sphh", goods));
        param.Add(new SqlParameter("@lastId", lastid));
        DataTable dt = new DataTable();
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(FXDBConStr))
        {
            errinfo = MDal.ExecuteQuerySecurity(strsql, param, out dt);

        }
        if (errinfo != "")
        {
            rt = "Error:" + errinfo;
        }
        else if (dt.Rows.Count < 1)
        {
            //rt = clsNetExecute.Error + "未找到关联商品"+strsql;
            rt = "Warn:无效货号查询";
        }
        else
        {
            //获取对应图片
            GoodsPic(ref dt);
            rt = JsonHelp.dataset2json(dt);
        }
        return rt;
    }


    public string goodsfilter(string mdid, string factor, string val)
    {
        string errinfo, rt, strtj;
        string strsql = @" select top 12 c.kfbh,b.sphh,max(c.ypmc) as spmc,max(c.yphh) as yphh,max(c.lsdj) as lsdj,case when sum(b.sl0)<=0 then 0 else sum(b.sl0) end  as kc,'' as urlAddress,row_number()over(order by b.sphh desc) as xh 
                           from t_MDb a  inner join yx_t_spkccmmx b on  a.khid=b.tzid and a.ckid=b.ckid 
                           inner join YX_T_ypdmb c on b.sphh=c.sphh and c.tzid=1 
                           where a.mdid=@mdid {0} group by b.sphh,c.kfbh {1} order by c.kfbh desc,b.sphh desc;    
                        ";

        List<SqlParameter> param = new List<SqlParameter>();
        param.Add(new SqlParameter("@mdid", mdid));
        if (factor.IndexOf("kczt") > -1 && val.Length > 0)
        {
            strtj = (val == "1") ? " having sum(b.sl0)>0 " : "having sum(b.sl0)<=0";
            strsql = string.Format(strsql, "", strtj);
        }
        else if (factor.IndexOf("yxzt") > -1 && val == "1")
        {
            strtj = " and c.ztbs=1 ";
            strsql = string.Format(strsql, strtj, "");
        }
        else if (factor.IndexOf("splb") > -1 && val.Length > 0)
        {
            strtj = " and c.ypmc like '%'+@lbmc+'%' ";
            strsql = string.Format(strsql, strtj, "");

            param.Add(new SqlParameter("@lbmc", val));
        }
        else
        {
            strsql = string.Format(strsql, "", "");

        }

        DataTable dt = new DataTable();
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(FXDBConStr))
        {
            errinfo = MDal.ExecuteQuerySecurity(strsql, param, out dt);
        }

        if (errinfo != "")
        {
            rt = errinfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "未找到关联商品";
        }
        else
        {
            //获取对应图片
            GoodsPic(ref dt);
            rt = JsonHelp.dataset2json(dt);
        }
        return rt;
    }

    //商品信息
    public string goodsDetail(string scanResult, string scanType)
    {
        string errorinfo, rt, goods;
        goods = scanResult;		
		string strsql = @" {0}
		                   select sp.sphh,sp.yphh,c.picUrl as urlAddress,c.picXh xh,sp.spmc,sp.lsdj
						   from yx_T_spdmb sp 
						   left join yx_v_goodPicInfo c on sp.sphh=c.sphh and c.dataType=1
						   where sp.tzid=1 {1}
		                ";
		
        if (goods.Length > 3)
        {
            if (scanType == "barCode")
            {
                strsql = string.Format(strsql, @"declare @strGood varchar(30)  select @strGood = SUBSTRING(@sphh, 1, LEN(@sphh) - 6)
												select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood ", " and sp.sphh=@strGood ");
            }
            else if (scanType == "qrCode")
            {
                strsql = string.Format(strsql, qrCodeSphhSQL, " and sp.sphh=@strGood ");
            }
            else
            {
                strsql = string.Format(strsql, "declare @strGood varchar(30);select @strGood=@sphh;", " and sp.sphh like @strGood+'%' ");
            }
        }
        else
        {
            strsql = string.Format(strsql, "declare @strGood varchar(30);select @strGood=@sphh;", " and sp.sphh = @strGood ");
        }

        List<SqlParameter> param = new List<SqlParameter>();
        param.Add(new SqlParameter("@sphh", goods));
        DataTable dt = new DataTable();
        //WriteLog("goodsDetail sql=" + strsql + "|sphh=" + goods + "|scantype=" + scanType);
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
        {
            errorinfo = MDal.ExecuteQuerySecurity(strsql, param, out dt); 
        };

        if (errorinfo != "")
        {
            rt = errorinfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "未找到关联商品图片";
        }
        else
        {
            rt = JsonHelp.dataset2json(dt);
        }

        return rt;
    }

    //商品库存
    public string goodsStock(string mdid, string scanResult, string scanType)
    {
        string errorinfo, rt, goods;
        goods = scanResult;
        string strsql = @" {0}
						select top 20 c.sphh,10 as zk,a.cm,isnull(b.sl0,0) sl
                        from  yx_t_cmzh a
                        inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh={1} and c.tzid=1
                        left join(
                            select a.cmdm,a.sl0
                            from yx_t_spkccmmx a
                            inner join YX_T_Spdmb b on a.sphh=b.sphh and b.tzid=1
                            where a.tzid=@mdid {2}
                        ) b on a.cmdm=b.cmdm
                        where a.tzid=1 
						order by a.cm
						;";
        if (goods.Length > 3)
        {
            if (scanType == "barCode")
            {
                strsql = string.Format(strsql, @"declare @strGood varchar(30)  select @strGood = SUBSTRING(@sphh, 1, LEN(@sphh) - 6)
												select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood ", "@strGood", " and a.sphh=@strGood ");
            }
            else if (scanType == "qrCode")
            {
                strsql = string.Format(strsql, qrCodeSphhSQL, "@strGood", " and a.sphh=@strGood ");
            }
            else
            {
                strsql = string.Format(strsql, "declare @strGood varchar(30);select @strGood=@sphh;", "@strGood", " and a.sphh like @strGood+'%' ");
            }
        }
        else
        {
            strsql = string.Format(strsql, "declare @strGood varchar(30);select @strGood=@sphh;", "@strGood", " and a.sphh = @strGood ");
        }

        List<SqlParameter> param = new List<SqlParameter>();
        param.Add(new SqlParameter("@mdid", mdid));
        param.Add(new SqlParameter("@sphh", goods));
        DataTable dt = new DataTable();
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(FXDBConStr))
        {
            errorinfo = MDal.ExecuteQuerySecurity(strsql, param, out dt);
        };


        if (errorinfo != "")
        {
            rt = "Error:" + errorinfo;
            //WriteLog(strsql + "|" + mdid + "|" + goods); ;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = "Warn:" + "未找到关联商品数据";
        }
        else
        {
            rt = JsonHelp.dataset2json(dt);
        }

        return rt;
    }

    //商品风格
    public string goodsImg(string scanResult, string scanType)
    {
        string errorinfo, rt, goods;
        goods = scanResult;

        string strsql = @"  {0}
							select a.sphh,a.spmc,isnull(c.cpmd,'')  AS cpmd,isnull(c.mlcf,'') mlcf,isnull(urlAddress,'') urlAddress
                            From yx_t_spdmb a 
                            inner join t_uploadfile b on a.id=b.tableid and b.groupid=8 
                            left outer join yx_t_cpinfo c on a.sphh=c.sphh 
                            where 1=1 {1}  ;";

        if (goods.Length > 3)
        {
            if (scanType == "barCode")
            {
                strsql = string.Format(strsql, @"declare @strGood varchar(30)  select @strGood = SUBSTRING(@sphh, 1, LEN(@sphh) - 6)
												select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood ", " and a.sphh=@strGood ");
            }
            else if (scanType == "qrCode")
            {
                strsql = string.Format(strsql, qrCodeSphhSQL, " and a.sphh=@strGood ", " and a.sphh=@strGood ");
            }
            else
            {
                strsql = string.Format(strsql, "declare @strGood varchar(30);select @strGood=@sphh;", " and a.sphh like @strGood+'%' ");
            }
        }
        else
        {
            strsql = string.Format(strsql, "declare @strGood varchar(30);select @strGood=@sphh;", " and a.sphh = @strGood ");
        }

        List<SqlParameter> param = new List<SqlParameter>();
        param.Add(new SqlParameter("@sphh", goods));
        DataTable dt = new DataTable();
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
        {
            errorinfo = MDal.ExecuteQuerySecurity(strsql, param, out dt);
        };
        //WriteLog("goodsImg str_sql=" + strsql + "|sphh=" + goods + "|scanType=" + scanType);
        if (errorinfo != "")
        {
            rt = "Error:" + errorinfo;
        }
        else if (dt.Rows.Count < 1)
        {            
            rt = "Warn:" + "无商品图片";
        }
        else
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                dt.Rows[i]["cpmd"] = HttpUtility.UrlEncodeUnicode(Convert.ToString(dt.Rows[i]["cpmd"]));
            }
            rt = JsonHelp.dataset2json(dt);
        }
        return rt;
    }

    //获取商品图片
    public string GoodsPic(ref DataTable dt)
    {
        string strsphhs = "", errinfo, bVal = "";
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            strsphhs += "'" + dt.Rows[i]["sphh"].ToString() + "',";
        }
        if (strsphhs != "")
        {
            strsphhs += "'ZZZ'";
            string strsql = @" select top 100 sphh,yphh,picUrl from yx_v_goodPicInfo where dataType=1 
                              and sphh in (" + strsphhs + ") and picXh=1";

            List<SqlParameter> param = new List<SqlParameter>();
            DataTable dt_url = new DataTable();
            using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
            {
                errinfo = MDal.ExecuteQuerySecurity(strsql, param, out dt_url);
            }

            if (errinfo != "")
            {
                bVal = errinfo;
            }
            else if (dt.Rows.Count < 1)
            {
                bVal = clsNetExecute.Error + "未找到关联商品图片";
            }
            else
            {
                for (int i = 0; i < dt_url.Rows.Count; i++)
                {
                    DataRow[] dr = dt.Select("sphh='" + dt_url.Rows[i]["sphh"].ToString() + "'");
                    dr[0]["urlAddress"] = dt_url.Rows[i]["picUrl"].ToString();
                }
                bVal = "SUCCESS";
            }
        }
        else
        {
            bVal = "无商品信息";
        }
        return bVal;
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
