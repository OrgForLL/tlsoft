<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server"> 
    protected void Page_Load(object sender, EventArgs e)
    {       
        string ctrl = "";

        if (ctrl == null || ctrl == "")
        {
            ctrl = Convert.ToString(Request.Params["ctrl"]);
        }
                                
        switch (ctrl)
        {
            case "getRank":
                getRank();
                break;
            case "saveRemark":
                saveRemark();
                break; 
            default:
                clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                break;
        }        
    }

    public void getRank()
    {
        //try
        //{
            string ryid = Convert.ToString(Request.Params["ryid"]);
            string mdid = Convert.ToString(Request.Params["mdid"]);
            string datatype = Convert.ToString(Request.Params["datatype"]);
            string datamonth = Convert.ToString(Request.Params["datamonth"]);
            string errInfo = "";
        
            string ConWX = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
            string FXDBConnStr = clsConfig.GetConfigValue("FXDBConStr");
            string ZBConnStr = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM zDal = new LiLanzDALForXLM(ZBConnStr))
            {
                using (LiLanzDALForXLM ADal = new LiLanzDALForXLM(FXDBConnStr))
                {
                    DataTable dt = null;
                    string mySQLJe = "CASE WHEN djlb > 0 THEN je ELSE 0-je END";     //根据类型取统计金额的判断。1　是零售单　2是退货单　-1是定制销售　　-2是定制退货　

                    string strSql = string.Concat(@"select top {0} ROW_NUMBER() OVER(ORDER BY sum(" , mySQLJe , ") DESC) as rowNum,ryid,yyy, CONVERT(INT,sum(" , mySQLJe 
                                    , @")) zje,'' faceimg,'' myremark,'' LinkTitle,'' IconUrl,'' PageUrl,0 mdid,'未知门店' mdmc
                                  from zmd_v_lsdjMX a WHERE djbs=1 AND ryid > 0 ");


                    string strSqlMe0 = string.Concat(@"select TOP 500 ROW_NUMBER() OVER(ORDER BY sum(", mySQLJe, ") DESC) as rowNum,ryid,CONVERT(INT,sum(", mySQLJe, @")) zje 
                                from zmd_v_lsdjMX a WHERE djbs=1 AND ryid > 0 ");

                    List<SqlParameter> param = new List<SqlParameter>();
                    List<SqlParameter> param2 = new List<SqlParameter>();

                    DataRow dr2;                   
                    string strSQLKh2;
                    switch (datatype)
                    {
                        case "shop":
                            strSql = string.Format(strSql, "50");

                            strSql = string.Concat(strSql, " and a.mdid=@mdid ");
                            param.Add(new SqlParameter("@mdid", mdid));

                            strSqlMe0 = string.Concat(strSqlMe0, " and a.mdid=@mdid ");
                            param2.Add(new SqlParameter("@mdid", mdid));

                            break;
                        case "area": 
                            DataTable dtmd;
                            string mdList = "";
                            strSql = string.Format(strSql, "20");
                            //首先求得相关的khid
                            strSQLKh2 = @"DECLARE @GLID INT 
                        SET @GLID = 0

                        SELECT TOP 1 @GLID = id FROM rs_T_yxrykhmx
                         WHERE mdid = @mdid
                        ORDER BY mxid DESC

                        IF (@GLID = 0)	SELECT ',' + CONVERT(VARCHAR(20),@mdid)
                        ELSE SELECT ',' + CONVERT(VARCHAR(20),mdid) FROM rs_T_yxrykhmx WHERE id = @GLID FOR XML PATH('')
                    ";

                            param.Add(new SqlParameter("@mdid", mdid));
                            errInfo = zDal.ExecuteQuerySecurity(strSQLKh2, param, out dtmd);
                            if (errInfo != "")
                            {
                                clsLocalLoger.WriteError(string.Concat("统计数据时发生错误！错误:", errInfo));
                                clsSharedHelper.WriteErrorInfo("统计数据时发生错误！");
                                return;
                            }
                            else
                            {
                                mdList = Convert.ToString(dtmd.Rows[0][0]);

                                //clsSharedHelper.WriteInfo("khList=" + khList); return;

                                param.Clear();
                                dtmd.Rows.Clear(); dtmd.Dispose();  //释放资源 
                                mdList = mdList.Remove(0, 1);

                                strSql = string.Concat(strSql, " AND a.mdid IN (", mdList, ") ");
                                strSqlMe0 = string.Concat(strSqlMe0, " AND a.mdid IN (", mdList, ") "); 
                            }
                            break;
                        case "province":
                            string khList = "";
                            DataTable dtkh = null;
                            strSql = string.Format(strSql, "50");

                            ////首先求得相关的khid 这个方法有问题
//                            strSQLKh2 = @"DECLARE @khid INT, 
//                                                  @ssid INT, 
//				                                  @khlbdm VARCHAR(10)
// 
//
//	                                    SELECT TOP 1 @khid = khid FROM t_mdb WHERE mdid = @mdid 
//
//	                                    SELECT TOP 1 @ssid = ssid,@khlbdm = khlbdm FROM yx_t_khb WHERE khid = @khid 
//
//	                                    WHILE (@ssid <> 1 AND @khlbdm = 'C') 
//	                                    BEGIN  
//		                                    SELECT @khid = @ssid 
//		                                    SELECT TOP 1 @ssid = ssid,@khlbdm = khlbdm FROM yx_t_khb WHERE khid = @khid 
//	                                    END 
//
//                                         IF (@khlbdm = 'C') SELECT ',' + CONVERT(VARCHAR(20),C.khid) FROM yx_t_khb A 
//						                                        INNER JOIN t_mdb C ON A.khid = C.khid 
//						                                        WHERE A.khid = @khid FOR XML PATH('')
//                                         ELSE 	
//						                                        SELECT ',' + CONVERT(VARCHAR(20),B.khid) FROM yx_t_khb A 
//											                                        INNER JOIN yx_t_khb B ON A.khid = B.ssid 
//											                                        INNER JOIN t_mdb C ON A.khid = C.khid 
//											                                        WHERE A.khid = @khid FOR XML PATH('')
//                    ";  
                                //20160708 xlm 修正并简化查询方法 
                            if (mdid != "" && mdid != "0")
                            {
                                strSQLKh2 = @"DECLARE @khid INT, 
				                                    @ccid VARCHAR(50), 
				                                    @khlbdm VARCHAR(10)

                                    SELECT TOP 1 @khid = khid FROM t_mdb WHERE mdid = @mdid 

                                    SELECT TOP 1 @ccid = ccid FROM yx_t_khb WHERE khid = @khid 

                                    IF (LEN(@ccid) - LEN(REPLACE(@ccid, '-', '')) > 2)	SELECT @ccid = SUBSTRING(@ccid, 1, CHARINDEX('-', @ccid ,4))
                                    ELSE SELECT @ccid = @ccid + '-'

                                    SELECT ',' + CONVERT(VARCHAR(20),A.khid) FROM yx_t_khb A 					
					                                    WHERE A.ccid + '-' LIKE @ccid + '%' FOR XML PATH('')
                    ";

                                param.Add(new SqlParameter("@mdid", mdid));
                                errInfo = zDal.ExecuteQuerySecurity(strSQLKh2, param, out dtkh);
                            }
                            
                            if (errInfo != "")
                            {
                                clsLocalLoger.WriteError(string.Concat("统计数据时发生错误！错误:", errInfo));
                                clsSharedHelper.WriteErrorInfo("统计数据时发生错误！");
                                return;
                            }
                            else
                            {
                                if (mdid != "" && mdid != "0")
                                {
                                    khList = Convert.ToString(dtkh.Rows[0][0]);
                                    param.Clear();
                                    dtkh.Rows.Clear(); dtkh.Dispose();  //释放资源
                                }
                                  
                                if (khList == "")       //如果相关客户不存在，则只查本店面
                                {
                                    strSql = string.Concat(strSql, " AND a.mdid=@mdid ");
                                    param.Add(new SqlParameter("@mdid", mdid));


                                    strSqlMe0 = string.Concat(strSqlMe0, " AND a.mdid=@mdid ");
                                    param2.Add(new SqlParameter("@mdid", mdid));
                                }
                                else
                                {
                                    khList = khList.Remove(0, 1);

                                    strSql = string.Concat(strSql, " AND a.khid IN (", khList, ") ");

                                    strSqlMe0 = string.Concat(strSqlMe0, " AND a.khid IN (", khList, ") ");
                                }
                            }
                            break;
                        case "all":
                            strSql = string.Format(strSql, "100");
                            break;
                        default:
                            return;
                    }
                     
                    //限定所查月份
                    string SqlAdd = "";
                    switch (datamonth)
                    {
                        case "0":       //本月
                            SqlAdd = @" AND  rq >= CONVERT(CHAR(8),GETDATE(),120) + '01' 
                                AND rq < CONVERT(CHAR(8),DATEADD(MONTH, 1, GETDATE()),120) + '01' ";                            
                            break;
                        case "1":       //上月
                            SqlAdd = @" AND  rq >= CONVERT(CHAR(8),DATEADD(MONTH, -1, GETDATE()),120) + '01' 
                                AND rq < CONVERT(CHAR(8),GETDATE(),120) + '01' ";
                            break;
                        case "2":       //今日 
                            SqlAdd = @" AND  rq >= CONVERT(CHAR(10),GETDATE(),120)
                                AND rq < CONVERT(CHAR(10),DATEADD(DAY, 1, GETDATE()),120) ";     
                            break;
                        case "3":       //昨日
                            SqlAdd = @" AND  rq >= CONVERT(CHAR(10),DATEADD(DAY, -1, GETDATE()),120)
                                AND rq < CONVERT(CHAR(10),GETDATE(),120) ";
                            break;
                    } 
                    strSql = string.Concat(strSql, SqlAdd);

                    strSqlMe0 = string.Concat(strSqlMe0, SqlAdd);

                    string strGroupOrder = " GROUP BY ryid,yyy ORDER BY zje DESC ";

                    strSql = string.Concat(strSql, strGroupOrder);

                    strSqlMe0 = string.Concat(strSqlMe0, strGroupOrder);

                    strSqlMe0 = string.Concat("SELECT TOP 1 * FROM (", strSqlMe0, ") AS T WHERE T.ryid = @ryid ");

                    errInfo = ADal.ExecuteQuerySecurity(strSql, param, out dt);
                    if (errInfo == "")
                    {
                        if (dt.Rows.Count > 0)
                        {
                            using (LiLanzDALForXLM wxDal = new LiLanzDALForXLM(ConWX))
                            {
                                //查表 rs_t_yxmbje ，使用年月
                                strSql = @"
                           SELECT A.relateID AS ryid,C.avatar FROM wx_t_OmniChannelUser A 
                                INNER JOIN wx_t_AppAuthorized B ON A.ID = B.SystemKey AND B.SystemID = 3
                                INNER JOIN dbo.wx_t_customers C ON B.UserID = C.ID
                            WHERE A.relateID IN ({0})";


                                //构造待查找ID
                                string idList = "";
                                foreach (DataRow dr in dt.Rows)
                                {
                                    idList = string.Concat(idList, ",", dr["ryid"]);
                                }
                                if (idList.Length > 0) idList = idList.Remove(0, 1);

                                strSql = string.Format(strSql, idList);

                                DataTable dt1;
                                errInfo = wxDal.ExecuteQuery(strSql, out dt1);
                                if (errInfo == "")
                                {
                                    //dt1.PrimaryKey = new DataColumn[] { dt1.Columns["ryid"] };

                                    DataRow dr1;
                                    DataRow[] dr1List;
                                    string defaultImage = "../../res/img/StoreSaler/defaulticon2.png";
                                    
                                    foreach (DataRow dr in dt.Rows)
                                    {
                                        dr1List = dt1.Select(string.Concat("ryid = ",dr["ryid"]),"");
                                        //dr1 = dt1.Rows.Find(dr["ryid"]);
                                        if (dr1List.Length == 0)
                                        {
                                            dr["faceimg"] = defaultImage;
                                        }
                                        else
                                        {
                                            dr1 = dr1List[0];
                                            if (Convert.ToString(dr1["avatar"]) == "") dr["faceimg"] = defaultImage;
                                            else
                                            {
                                                if (clsWXHelper.IsWxFaceImg(Convert.ToString(dr1["avatar"])))
                                                {
                                                    dr["faceimg"] = clsWXHelper.GetMiniFace(Convert.ToString(dr1["avatar"]));
                                                }
                                                else
                                                {
                                                    dr["faceimg"] = string.Concat("../../", dr1["avatar"]);
                                                }                                                
                                                
                                                //if (Convert.ToString(dr1["avatar"]).EndsWith("/")) dr["faceimg"] = string.Concat(dr1["avatar"], "64");
                                                //else dr["faceimg"] = string.Concat("../../",dr1["avatar"]);
                                            }
                                        }
                                    }

                                    dt1.Rows.Clear(); dt1.Dispose();        //释放资源                        

                                    //加载成功宣言
                                    strSql = @"
                                       SELECT A.ryid,A.Remark,B.LinkTitle,B.IconUrl,B.PageUrl FROM wx_t_SaleRemark A 
                                        LEFT JOIN wx_t_SaleHonor B ON A.ryid = B.ryid AND A.YearMonth = B.YearMonth
                                        WHERE A.ryid IN ({0}) ";

                                    strSql = string.Format(strSql, idList); 
                                    
                                    if (datamonth == "0" || datamonth == "2" || (datamonth == "3" && DateTime.Now.ToString("d") != "1"))
                                    {
                                        SqlAdd = @" AND A.YearMonth = CONVERT(INT,CONVERT(CHAR(6),GETDATE(),112)) ";
                                    }
                                    else
                                    { 
                                        SqlAdd = @" AND A.YearMonth = CONVERT(INT,CONVERT(CHAR(6),DATEADD(MONTH, -1, GETDATE()),112)) ";
                                    }

                                    strSql = string.Concat(strSql, SqlAdd);

                                    DataTable dt2;
                                    errInfo = wxDal.ExecuteQuery(strSql, out dt2);
                                    if (errInfo == "")
                                    { 
                                        dt2.PrimaryKey = new DataColumn[] { dt2.Columns["ryid"] }; 
                                        
                                        foreach (DataRow dr in dt.Rows)
                                        {
                                            dr2 = dt2.Rows.Find(dr["ryid"]);

                                            if (dr2 == null)
                                            {
                                                dr["myremark"] = "这家伙很懒，什么销售心得体会都没有透露~";
                                            }
                                            else
                                            {
                                                dr["myremark"] = Convert.ToString(dr2["Remark"]).Replace("\r", "\\r").Replace("\n", "\\n");
                                                dr["LinkTitle"] = Convert.ToString(dr2["LinkTitle"]);
                                                dr["IconUrl"] = Convert.ToString(dr2["IconUrl"]);
                                                dr["PageUrl"] = Convert.ToString(dr2["PageUrl"]);
                                            }
                                        }

                                        dt2.Rows.Clear(); dt2.Dispose();        //释放资源   
                                    }
                                    else
                                    {
                                        clsLocalLoger.WriteError(string.Concat("读取销售心得失败！错误：", errInfo, " strSql:", strSql));
                                    }
                                    //成功宣言 加载结束
                                    
                                    //加载所属门店信息
                                    strSql = @"
                                       SELECT A.id ryid,B.mdid mdid,B.mdmc FROM Rs_T_Rydwzl A 
                                        INNER JOIN t_mdb B ON  A.id IN ({0}) AND A.mdid = B.mdid ";
                                    strSql = string.Format(strSql, idList); 
                                    errInfo = zDal.ExecuteQuery(strSql, out dt2);
                                    if (errInfo == "")
                                    {
                                        dt2.PrimaryKey = new DataColumn[] { dt2.Columns["ryid"] };
                                                                                
                                        foreach (DataRow dr in dt.Rows)
                                        {
                                            dr2 = dt2.Rows.Find(dr["ryid"]);

                                            if (dr2 != null) 
                                            { 
                                                dr["mdid"] = Convert.ToInt32(dr2["mdid"]);
                                                dr["mdmc"] = Convert.ToString(dr2["mdmc"]); 
                                            }
                                        }

                                        dt2.Rows.Clear(); dt2.Dispose();        //释放资源   
                                    }
                                    else
                                    {
                                        clsLocalLoger.WriteError(string.Concat("读取所属门店失败！错误：", errInfo, " strSql:", strSql));
                                    }  
                                    //所属门店信息 加载结束
                                    
                                    
                                    string json = JsonHelp.dataset2json(dt);

                                    clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(json);

                                    //分析个人业绩 
                                    DataRow[] drMeList = dt.Select("ryid = " + ryid);
                                    if (drMeList.Length > 0)
                                    {
                                        jh.AddJsonVar("MyOrder", Convert.ToString(drMeList[0]["rowNum"]));
                                        jh.AddJsonVar("MyZje", Convert.ToString(drMeList[0]["zje"]));
                                    }
                                    else
                                    {
                                        DataTable dtMe;
                                        param2.Add(new SqlParameter("@ryid", ryid));
                                        errInfo = ADal.ExecuteQuerySecurity(strSqlMe0, param2, out dtMe);

                                        if (errInfo == "")
                                        {
                                            if (dtMe.Rows.Count == 0)
                                            {
                                                //clsSharedHelper.WriteErrorInfo("找不到个人业绩数据！");

                                                jh.AddJsonVar("MyOrder", "-");
                                                jh.AddJsonVar("MyZje", "-");
                                            }
                                            else
                                            {
                                                jh.AddJsonVar("MyOrder", Convert.ToString(dtMe.Rows[0]["rowNum"]));
                                                jh.AddJsonVar("MyZje", Convert.ToString(dtMe.Rows[0]["zje"]));
                                            }
                                            dtMe.Rows.Clear(); dtMe.Dispose();
                                        }
                                        else
                                        {
                                            clsSharedHelper.WriteErrorInfo("错误：" + errInfo);
                                        }
                                    }
                                    dt.Rows.Clear(); dt.Dispose();  //释放资源

                                    //clsLocalLoger.WriteInfo(jh.jSon);
                                    
                                    clsSharedHelper.WriteInfo(jh.jSon);
                                    json = "";//释放资源
                                    jh.Dispose();

                                    return;
                                }
                            }

                            //clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));//JsonHelp.dataset2json(dt)
                        }
                        else
                        {
                            clsSharedHelper.WriteErrorInfo("这里暂时无人上榜，真是寂寞如雪啊~！");
                        }
                    }
                    else
                    {
                        clsSharedHelper.WriteErrorInfo("统计数据时出错 info:" + errInfo);
                    }
                }
            }
        //}
        //catch (Exception ex)
        //{
        //    clsSharedHelper.WriteErrorInfo(string.Concat("未知错误！错误：", ex.Message));
        //}
    }

    public void saveRemark()
    {
        string ryid = Convert.ToString(Request.Params["ryid"]);
        string datamonth = Convert.ToString(Request.Params["datamonth"]);
        string remark = Convert.ToString(Request.Params["remark"]);
        string errInfo = "";
         
        if (datamonth == "0" || datamonth == "2" || (datamonth == "3" && DateTime.Now.ToString("d") != "1"))
        {
            datamonth = @" DECLARE @YearMonth INT
                    SELECT @YearMonth = CONVERT(INT,CONVERT(CHAR(6),GETDATE(),112)) ";
        }
        else
        {
            datamonth = @" DECLARE @YearMonth INT
                    SELECT @YearMonth = CONVERT(INT,CONVERT(CHAR(6),DATEADD(MONTH, -1, GETDATE()),112)) ";
        }

        if (remark.Length > 100) remark = remark.Remove(100);
         
        string ConWX = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
        using (LiLanzDALForXLM wxDal = new LiLanzDALForXLM(ConWX))
        {
            string strSql = string.Concat(datamonth, @"
            DECLARE @SRID INT       

            SET @SRID = 0
            
            SELECT TOP 1 @SRID = ID FROM wx_t_SaleRemark WHERE ryid = @ryid AND YearMonth = @YearMonth

            IF (@SRID = 0)      INSERT INTO wx_t_SaleRemark (ryid,YearMonth,Remark) VALUES (@ryid,@YearMonth,@Remark) 
            ELSE                UPDATE wx_t_SaleRemark SET Remark=@Remark WHERE ID = @SRID ");

            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@ryid", ryid));
            param.Add(new SqlParameter("@Remark", remark));

            errInfo = wxDal.ExecuteNonQuerySecurity(strSql, param);
            if (errInfo == "")
            {
                clsSharedHelper.WriteSuccessedInfo("");
            }
            else
            {
                clsLocalLoger.WriteError(string.Concat("保存心得失败！错误：", errInfo));
                clsSharedHelper.WriteInfo("保存心得失败！");
            }
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
