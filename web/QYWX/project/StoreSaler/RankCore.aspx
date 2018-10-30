<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    //private string FXDBConnStr = clsConfig.GetConfigValue("FXDBConStr");
    private string FXDBConnStr = "server=192.168.35.11;database=FXDB;uid=ABEASD14AD;pwd=+AuDkDew";
    private string ZBDBConnStr = clsConfig.GetConfigValue("OAConnStr");
    private string ConnWX = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = "";

        if (ctrl == null || ctrl == "")
        {
            ctrl = Convert.ToString(Request.Params["ctrl"]);
        }

        string ryid = Convert.ToString(Request.Params["ryid"]);
        string mdid = Convert.ToString(Request.Params["mdid"]);
        //ryid = "61153";

        switch (ctrl)
        {
            case "saleInfo":
                if (ryid == "" || ryid == null)
                {
                    clsSharedHelper.WriteErrorInfo("缺少人员参数！");
                    return;
                }
                getSaleInfo(ryid);
                break;
            case "getNewInfo":
                if (ryid == "" || ryid == null)
                {
                    clsSharedHelper.WriteErrorInfo("缺少人员参数！");
                    return;
                }
                getNewInfo(ryid);
                break;
            case "GetRySales":                
                mdid = Convert.ToString(Request.Params["mdid"]);
                string type = Convert.ToString(Request.Params["type"]);
                if (mdid == "" || mdid == null || mdid == "0")
                    clsSharedHelper.WriteErrorInfo("缺少门店参数！");
                else if (type == "" || type == null)
                    clsSharedHelper.WriteErrorInfo("缺少查询类型参数！");
                else
                    GetRySales(mdid, type);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                break;                
        };

    }
    
    /// <summary>
    /// 获取某个门店所有导购在某个时间段的销售业绩
    /// </summary>
    /// <param name="mdid">门店ID</param>
    /// <param name="type">时间段类型，目前有四个：by-本月 sy-上月 jn-今年 qn-去年</param>
    public void GetRySales(string mdid,string type) {
        using (LiLanzDALForXLM dal11 = new LiLanzDALForXLM(FXDBConnStr))
        {
            //取销售数据
            DataTable LS_DT = null;
            string str_sql = @"select b.ryid,sum(CASE WHEN a.djlb > 0 THEN b.je ELSE 0-b.je END) je
                                    from zmd_t_lsdjb a
                                    inner join zmd_t_lsdjmx b on a.id=b.id and a.mdid=@mdid
                                    where a.djbs=1 and b.ryid>0 ";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mdid", mdid));
            string ls_tmp = "",mb_tmp="";
            switch (type)
            {
                case "by":
                    ls_tmp = " and a.rq>=convert(varchar(8),getdate(),120)+'01' and a.rq<convert(varchar(8),dateadd(month,1,getdate()),120)+'01' ";
                    mb_tmp = " and nyear=year(getdate()) and nmonth=month(getdate()) ";
                    break;
                case "sy":
                    ls_tmp = " and a.rq>=convert(varchar(8),dateadd(month,-1,getdate()),120)+'01' and a.rq<convert(varchar(8),getdate(),120)+'01' ";
                    mb_tmp = " and nyear=year(dateadd(month,-1,convert(varchar(10),getdate(),120))) and nmonth=month(dateadd(month,-1,convert(varchar(10),getdate(),120))) ";
                    break;
                case "jn":
                    ls_tmp = @" and a.rq>=case when month(getdate())>=3 then convert(varchar(4),year(getdate()))+'-03-01' else convert(varchar(4),year(getdate())-1)+'-03-01' end
                                and a.rq<case when month(getdate())>=3 then convert(varchar(4),year(getdate())+1)+'-03-01' else convert(varchar(4),year(getdate()))+'-03-01' end ";
                    mb_tmp = @" and rq>=case when month(getdate())>=3 then convert(varchar(4),year(getdate()))+'-03-01' else convert(varchar(4),year(getdate())-1)+'-03-01' end 
                                and rq<=case when month(getdate())>=3 then convert(varchar(4),year(getdate())+1)+'-02-01' else convert(varchar(4),year(getdate()))+'-02-01' end ";
                    break;
                case "qn":
                    ls_tmp = @" and a.rq>=case when month(getdate())>=3 then convert(varchar(4),year(getdate())-1)+'-03-01' else convert(varchar(4),year(getdate())-2)+'-03-01' end 
                                and a.rq<case when month(getdate())>=3 then convert(varchar(4),year(getdate()) )+'-03-01' else convert(varchar(4),year(getdate())-1)+'-03-01' end ";
                    mb_tmp = @" and rq>=case when month(getdate())>=3 then convert(varchar(4),year(getdate())-1)+'-03-01' else convert(varchar(4),year(getdate())-2)+'-03-01' end 
                                and rq<=case when month(getdate())>=3 then convert(varchar(4),year(getdate()))+'-02-01' else convert(varchar(4),year(getdate())-1)+'-02-01' end ";
                    break;
                default:
                    ls_tmp = " and 1==2";
                    mb_tmp = " and 1==2";
                    break;
            }

            ls_tmp += " group by b.ryid order by sum(b.je) desc ";
            str_sql += ls_tmp;
            string errinfo = dal11.ExecuteQuerySecurity(str_sql, paras, out LS_DT);
            if (errinfo != "" && LS_DT.Rows.Count > 0)
                clsLocalLoger.WriteError(string.Concat("【GetRySaleData】读取数据出错！错误：", errinfo));
            else { 
                //接下来取62库的导购设置的目标及信息
                using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(ConnWX)) {
                    str_sql = string.Format(@"
                                select *,cast(convert(char(4),nyear)+'-'+convert(char(2),nmonth)+ '-01' as datetime) rq into #zb
                                from wx_t_saletarget 
                                where mdid=@mdid;

                                select zb.id ryid,o.nickname xm,v2.avatar headimg,isnull(a.target,0) target
                                from rs_t_rydwzl zb
                                inner join rs_t_ryjbzl rs on rs.id=zb.id and zb.rzzk='1' and zb.mdid=@mdid    --and zb.tzid=rs.tzid 
                                inner join wx_t_OmniChannelUser o on o.relateid=zb.id
                                inner join wx_t_AppAuthorized v1 on o.id=v1.systemkey and v1.systemid=3
                                inner join wx_t_customers v2 on v1.userid=v2.id
                                left join (
	                                select mdid,ryid,sum(saletarget) target
	                                from #zb
                                    where 1=1 {0}
	                                group by mdid,ryid
                                ) a on zb.id=a.ryid
                                drop table #zb;", mb_tmp);
                    DataTable MB_DT=null;
                    paras.Clear();
                    paras.Add(new SqlParameter("@mdid", mdid));
                    errinfo = dal62.ExecuteQuerySecurity(str_sql, paras, out MB_DT);
                    //clsSharedHelper.WriteInfo(JsonHelp.dataset2json(MB_DT));
                    if (errinfo == "" && MB_DT.Rows.Count > 0)
                    {
                        string VIP_WebPath = clsConfig.GetConfigValue("VIP_WebPath");
                        string OA_WebPath = clsConfig.GetConfigValue("OA_WebPath");
                        
                        //接下来处理两个DATATABLE                        
                        DataColumn dc = new DataColumn();
                        dc.DataType = Type.GetType("System.Int32");
                        dc.ColumnName = "Sales";
                        dc.AllowDBNull = false;
                        dc.DefaultValue = 0;
                        MB_DT.Columns.Add(dc);//业绩列
                        dc = new DataColumn();
                        dc.DataType = Type.GetType("System.Double");
                        dc.ColumnName = "Process";
                        dc.AllowDBNull = false;
                        dc.DefaultValue = 0;
                        MB_DT.Columns.Add(dc);

                        string url = "";
                        for (int i = 0; i < MB_DT.Rows.Count; i++)
                        {
                            string ryid = Convert.ToString(MB_DT.Rows[i]["ryid"]);
                            DataRow[] drs = LS_DT.Select("ryid='" + ryid + "' and je>0","");
                            double target = Convert.ToDouble(MB_DT.Rows[i]["target"]);
                            if (drs.Length > 0)
                            {
                                MB_DT.Rows[i]["Sales"] = drs[0]["je"];
                                if(target>0)
                                    MB_DT.Rows[i]["Process"] = Convert.ToDouble(MB_DT.Rows[i]["Sales"]) / (target * 10000);
                            }
                            url = MB_DT.Rows[i]["headimg"].ToString().Replace("\\", "");
                            if (url == "")
                                url = "../../res/img/StoreSaler/defaulticon.jpg";
                            else if (clsWXHelper.IsWxFaceImg(url))
                                url = clsWXHelper.GetMiniFace(url);
                            else
                                url = OA_WebPath + url;
                            MB_DT.Rows[i]["headimg"] = url;
                        }//end for
                        DataView dv = MB_DT.DefaultView;
                        dv.Sort = "Process desc";
                        MB_DT = dv.ToTable();
                        clsSharedHelper.WriteInfo(JsonHelp.dataset2json(MB_DT));
                    }
                    else
                        clsSharedHelper.WriteErrorInfo("统计店员目标时出错 " + errinfo);
                }                       
            }//end else                
        }
    }

    //处理头像链接
    public DataTable ConvertHeadimgURL(DataTable _dt)
    {
        string VIP_WebPath = clsConfig.GetConfigValue("VIP_WebPath");
        string OA_WebPath = clsConfig.GetConfigValue("OA_WebPath");
        if (_dt.Rows.Count > 0)
        {
            string url = "";
            for (int i = 0; i < _dt.Rows.Count; i++)
            {
                url = _dt.Rows[i]["headimg"].ToString().Replace("\\", "");
                if (url == "")
                    url = "../../res/img/StoreSaler/defaulticon.jpg";
                else if (clsWXHelper.IsWxFaceImg(url))
                    url = clsWXHelper.GetMiniFace(url);
                else
                    url = VIP_WebPath + url;
                _dt.Rows[i]["headimg"] = url;
            }
        }
        return _dt;
    }
    
    public double getYearFinish(string ryid) { 
        double rt=0;
        using (LiLanzDALForXLM dal11 = new LiLanzDALForXLM(FXDBConnStr))
        { 
            //查询今年的零售数据
            string str_sql = @" SELECT convert(varchar(7),rq,120) ny,sum(CASE WHEN a.djlb > 0 THEN b.je ELSE 0-b.je END) je
                                FROM zmd_t_lsdjb A
                                INNER JOIN zmd_t_lsdjmx B ON A.ID = B.ID 
                                WHERE djbs=1 AND B.ryid = @ryid
                                and rq>=convert(varchar(4),year(getdate()))+'-01-01'
                                group by convert(varchar(7),rq,120)";
            DataTable DT_LS = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@ryid", ryid));
            string errinfo = dal11.ExecuteQuerySecurity(str_sql,paras,out DT_LS);                 
            if (errinfo == "" && DT_LS.Rows.Count > 0)
            {
                //查询设置的业绩目标
                using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(ConnWX))
                {                    
                    DataTable DT_MB=null;
                    str_sql = @"select nyear,nmonth from wx_t_saletarget where ryid=@ryid";
                    paras.Clear();
                    paras.Add(new SqlParameter("@ryid", ryid));
                    errinfo = dal62.ExecuteQuerySecurity(str_sql,paras,out DT_MB);
                    if (errinfo == "" && DT_MB.Rows.Count > 0)
                    {                        
                        string nn=DT_MB.Rows[0]["nyear"].ToString(), yy = "";
                        for (int i = 0; i < DT_MB.Rows.Count; i++) {                         
                            yy=DT_MB.Rows[i]["nmonth"].ToString();
                            yy = yy.Length == 1 ? '0' + yy : yy;
                            object sales = DT_LS.Compute("sum(je)", "ny='" + nn + '-' + yy + "'");

                            rt += Convert.ToDouble(sales == DBNull.Value ? 0 : sales);
                        }//end for
                    }
                }
            }
        }
                
        return rt;
    }
    
    public void getNewInfo(string ryid)
    {
        string errInfo = "";
        using (LiLanzDALForXLM fxDal = new LiLanzDALForXLM(FXDBConnStr))
        {
            
            string strSql = @"
                    DECLARE @monthCount INT,
                            @monthSale INT,
                            @dayCount INT,
                            @daySale INT                            
                    SELECT @monthCount = 0,@monthSale = 0,@dayCount = 0,@daySale = 0;

                    SELECT @monthCount = COUNT(DISTINCT A.id) ,@monthSale = SUM(CASE WHEN A.djlb > 0 THEN B.je ELSE 0-B.je END)  
                    FROM zmd_t_lsdjb A
	                INNER JOIN zmd_t_lsdjmx B ON A.ID = B.ID 
                    WHERE djbs=1 AND B.ryid = @ryid
                    AND rq >= CONVERT(CHAR(8),GETDATE(),120) + '01' AND rq < CONVERT(CHAR(8),DATEADD(MONTH, 1, GETDATE()),120) + '01'

                    SELECT @dayCount = COUNT(DISTINCT A.id) ,@daySale = SUM(CASE WHEN A.djlb > 0 THEN B.je ELSE 0-B.je END)
                    FROM zmd_t_lsdjb A
                    INNER JOIN zmd_t_lsdjmx B ON A.ID = B.ID 
                    WHERE djbs=1 AND B.ryid = @ryid
                    AND rq >= CONVERT(CHAR(10),GETDATE(),120) AND rq < CONVERT(CHAR(10),DATEADD(DAY, 1, GETDATE()),120);

                    SELECT ISNULL(@monthCount,0) monthCount,ISNULL(@monthSale,0) monthSale,ISNULL(@dayCount,0) dayCount,ISNULL(@daySale,0) daySale
                                                  ";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@ryid", ryid));

            DataTable dt0 = null;
            DataTable dt1 = null;
            errInfo = fxDal.ExecuteQuerySecurity(strSql, param, out dt0);
            
            if (errInfo == "")
            {
                
                using (LiLanzDALForXLM wxDal = new LiLanzDALForXLM(ConnWX))
                {
                    strSql = @"
                        DECLARE @newYear INT
                        DECLARE @Target1 decimal(12,1), @Target2 decimal(12,1), @SaleTarget decimal(12,1)

                        SELECT TOP 1 @SaleTarget = SaleTarget FROM wx_t_SaleTarget
                        WHERE ryid=@ryid AND nYear=YEAR(GETDATE()) AND nMonth=MONTH(GETDATE());

                        
                        IF(MONTH(GETDATE())<3)
                        BEGIN
	                        SET @newYear = YEAR(DATEADD(YEAR, -1,GETDATE()));
	                        select @Target1 =  SUM(saletarget) FROM wx_t_saletarget WHERE nYear=@newYear AND nMonth>2 AND ryid=@ryid;
	                        SELECT @Target2 =  SUM(saletarget) FROM wx_t_saletarget WHERE nyear=@newYear+1 AND nMonth<3 AND ryid=@ryid
                        END
                        ELSE
	                        SET @newYear = YEAR(GETDATE());
	                        select @Target1 =  SUM(saletarget) FROM wx_t_saletarget WHERE nYear=@newYear AND nmonth>2 AND ryid=@ryid;
	                        SELECT @Target2 =  SUM(saletarget) FROM wx_t_saletarget WHERE nyear=@newYear+1 AND nMonth<3 AND ryid=@ryid;
                        SELECT ISNULL(@SaleTarget,0), ISNULL(@Target1,0) + ISNULL(@Target2,0)
                        ";
                    
                    param.Clear();
                    param.Add(new SqlParameter("@ryid", ryid));
                    errInfo = wxDal.ExecuteQuerySecurity(strSql, param, out dt1);
                    if (errInfo == "")
                    {                        
                        double saleTarget=0,allTarget=0;
                        if (dt1.Rows.Count > 0) 
                        {
                            saleTarget = Convert.ToDouble(dt1.Rows[0][0]);//本月销售目标
                            allTarget = Convert.ToDouble(dt1.Rows[0][1]);//本年销售目标
                        }
                                                
                        int monthSale = Convert.ToInt32(dt0.Rows[0]["monthSale"]);
                        double allSale = getYearFinish(ryid);
                            
                        dt1.Rows.Clear();
                        dt1.Dispose();
                        
                        string pcent,allPercent;
                        if (saleTarget == 0) pcent = "0";
                        else if (monthSale == 0) pcent = "0%";
                        else
                        {
                            pcent = string.Format("{0:P1}", monthSale * 1.0 / (saleTarget * 10000) );//本月目标完成度                            
                        }

                        if (allTarget == 0) allPercent = "0";
                        else if (allSale == 0) allPercent = "0%";
                        else
                        {
                            allPercent = string.Format("{0:P1}", allSale * 1.0 / (allTarget * 10000));//本年目标完成度                            
                        }
                                                
                        dt0.Columns.Add("allTarget", typeof(double), "");
                        dt0.Columns.Add("saleTarget", typeof(double), "");
                        dt0.Columns.Add("pcent", typeof(string), "");
                        dt0.Columns.Add("allPercent", typeof(string), "");
                        dt0.Rows[0]["allTarget"] = allTarget;
                        dt0.Rows[0]["saleTarget"] = saleTarget;
                        dt0.Rows[0]["pcent"] = pcent;
                        dt0.Rows[0]["allPercent"] = allPercent;
                        string json = JsonHelp.dataset2json(dt0);
                        dt0.Rows.Clear(); dt0.Dispose();  //释放资源
                        clsSharedHelper.WriteInfo(json);
                        json = "";//释放资源
                        return;
                    }
                }			
            }
        }

        if (errInfo != "")
        {
            clsSharedHelper.WriteInfo(string.Concat(@"{ ""err"":""", errInfo, @""" }"));
        }
    }

    //图表
    public void getSaleInfo(string ryid)
    {
        string errInfo = "";
        using (LiLanzDALForXLM ADal = new LiLanzDALForXLM(FXDBConnStr))
        {
            DataTable dt = null;
            string strsql = @"SELECT CONVERT(CHAR(7), rq,102) 'ny',SUM(CASE WHEN A.djlb > 0 THEN B.je ELSE 0-B.je END) je  FROM zmd_t_lsdjb A
							INNER JOIN zmd_t_lsdjmx B ON A.ID = B.ID 
							  WHERE djbs=1 AND B.ryid = @ryid
							  AND rq >= CONVERT(CHAR(8),DATEADD(MONTH, -5, GETDATE()),120) + '01'
                           GROUP BY CONVERT(CHAR(7),rq,102) 
                           ORDER BY ny ASC";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@ryid", ryid));
            errInfo = ADal.ExecuteQuerySecurity(strsql, param, out dt);
            if (errInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                }
                else
                {
                    errInfo = "您近半年没有销售数据！";
                }
            }
            else
            {
                clsLocalLoger.WriteError(string.Concat("【全渠道-个人业绩】统计数据时出错！错误：", errInfo));
                errInfo = "统计数据时出错！请联系IT部！";
            }

            dt.Rows.Clear(); dt.Dispose();          //必须释放资源       
        }

        if (errInfo != "")
        {
            clsSharedHelper.WriteInfo(string.Concat(@"{ ""err"":""", errInfo, @""" }"));
        }
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
