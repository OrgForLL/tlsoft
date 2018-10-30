<%@ Page Language="C#" Debug="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server"> 
    string ZBConnStr = clsConfig.GetConfigValue("OAConnStr");//10

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = "";
        string salerId = Convert.ToString(Request.Params["salerId"]);
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string area = Convert.ToString(Request.Params["area"]);
        string month = Convert.ToString(Request.Params["month"]);
        string myID = Convert.ToString(Request.Params["myID"]);

        if (ctrl == null || ctrl == "")
        {
            ctrl = Convert.ToString(Request.Params["ctrl"]);
        }

        switch (ctrl)
        {
            case "getRank":
                getRank(mdid, area, month);
                break;
            //case "getMine":
            //    getMine(area, myID, month, mdid);
            //    break;
            default:
                clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                break;
        }

    }

    //public void getMine(string area, string myID, string month, string mdid)
    //{
    //    string ConWX = clsWXHelper.GetWxConn();

    //    string sqlStr = @"SELECT b.id as ID, COUNT(b.id) AS fans, ROW_NUMBER() OVER(ORDER BY COUNT(b.id) desc) AS rownumber
    //                       from wx_t_VipSalerBind a
    //                       inner JOIN wx_t_OmniChannelUser b ON a.SalerID=b.ID
    //                       inner JOIN rs_t_rydwzl rs ON rs.id=b.relateID
    //                       where rs.mdid in ({0})";
    //    string groupStr = @"GROUP BY b.id ORDER BY fans DESC";
    //    string nMonth = "";
    //    string mdList = "";
    //    string errInfo = "";
    //    DataTable myDt = null;
    //    clsJsonHelper myJson = new clsJsonHelper();
    //    List<SqlParameter> myParam = new List<SqlParameter>();
    //    if (month == "1")
    //    {
    //        nMonth = @" AND CreateTime >= CONVERT(CHAR(8),GETDATE(),120) + '01' 
    //                            AND CreateTime < CONVERT(CHAR(8),DATEADD(MONTH, 1, GETDATE()),120) + '01' ";
    //    }
    //    else if (month == "0")
    //    {
    //        nMonth = @" AND CreateTime >= CONVERT(CHAR(8),DATEADD(MONTH, -1, GETDATE()),120) + '01' 
    //                            AND CreateTime < CONVERT(CHAR(8),GETDATE(),120) + '01' ";
    //    }
    //    else if (month == "2")
    //    {
    //        //昨日
    //        nMonth = " and convert(varchar(10),createtime,120)=dateadd(day,-1,convert(varchar(10),getdate(),120)) ";
    //    }
    //    else if (month == "3")
    //    {
    //        //今日
    //        nMonth = " and convert(varchar(10),createtime,120)=convert(varchar(10),getdate(),120) ";
    //    }

    //    switch (area)
    //    {
    //        case "shop":
    //            myParam.Clear();
    //            sqlStr = string.Format(sqlStr, "@mdid");
    //            sqlStr = string.Concat(sqlStr, nMonth, groupStr);
    //            myParam.Add(new SqlParameter("@mdid",mdid));
    //            break;
    //        case "area":
    //            myParam.Clear();
    //            mdList = getArea("area", mdid);
    //            sqlStr = string.Format(sqlStr, mdList);
    //            sqlStr = string.Concat(sqlStr, nMonth, groupStr);
    //            myParam.Add(new SqlParameter("@mdid",mdid));
    //            break;
    //        case "province":
    //            myParam.Clear();
    //            mdList = getArea("province", mdid);
    //            sqlStr = string.Format(sqlStr, mdList);
    //            sqlStr = string.Concat(sqlStr, nMonth, groupStr);
    //            myParam.Add(new SqlParameter("@mdid", mdList));
    //            break;
    //        case "all":
    //            myParam.Clear();
    //            sqlStr = string.Format(sqlStr, "rs.mdid");
    //            sqlStr = string.Concat(sqlStr, nMonth, groupStr);
    //            break;
    //        default:
    //            break;
    //    }
    //    using (LiLanzDALForXLM wxDAL = new LiLanzDALForXLM(ConWX))
    //    {
    //        errInfo = wxDAL.ExecuteQuerySecurity(sqlStr, myParam, out myDt);

    //        if (errInfo == "")
    //        {
    //            foreach(DataRow dr in myDt.Rows)
    //            {
    //                while (myID == Convert.ToString(dr["ID"]))
    //                {
    //                    myJson.AddJsonVar("rank", Convert.ToString(dr["rownumber"]));
    //                    myJson.AddJsonVar("fans", Convert.ToString(dr["fans"]));
    //                    clsSharedHelper.WriteInfo("[" + myJson.jSon + "]");
    //                }
    //            }
    //            clsSharedHelper.WriteInfo("[{\"rank\":\"0\", \"fans\":\"0\"}]");
    //        }
    //    }
    //}

    //根据范围，取得区域所有门店
    public string getArea(string area, string mdid)
    {
        if (mdid == "0") return "0";

        string mdList = "", sqlStr = "";
        switch (area)
        {
            case "area":
                sqlStr = @"DECLARE @GLID INT 
                            SET @GLID = 0
                            SELECT TOP 1 @GLID = id FROM rs_T_yxrykhmx
                            WHERE mdid = @mdid
                            ORDER BY mxid DESC

                            IF (@GLID = 0)	SELECT ',' + CONVERT(VARCHAR(20),@mdid)
                            ELSE SELECT ',' + CONVERT(VARCHAR(20),mdid) FROM rs_T_yxrykhmx WHERE id = @GLID FOR XML PATH('')";
                break;
            case "province":
                //                sqlStr = @"DECLARE @khid INT, 
                //                                          @ssid INT,
                //				                          @whileCount INT
                //                                          SET @whileCount = 0
                //				 
                //                            SELECT TOP 1 @khid = khid FROM t_mdb WHERE mdid = @mdid 
                //                            SELECT TOP 1 @ssid = ssid FROM yx_t_khb WHERE khid = @khid 
                //                            WHILE (@ssid <> 1) 
                //                        BEGIN 
                //	                        SELECT @whileCount = @whileCount + 1
                //	                        SELECT @khid = @ssid 
                //	                        SELECT TOP 1 @ssid = ssid FROM yx_t_khb WHERE khid = @khid 
                //                        END 
                //
                //                        IF (@whileCount = 0) SELECT ',' + CONVERT(VARCHAR(20),C.khid) FROM yx_t_khb A 
                //												INNER JOIN t_mdb C ON A.khid = C.khid 
                //												WHERE A.khid = @khid FOR XML PATH('')
                //                        ELSE 				    SELECT ',' + CONVERT(VARCHAR(20),B.khid) FROM yx_t_khb A 
                //												INNER JOIN yx_t_khb B ON A.khid = B.ssid 
                //												INNER JOIN t_mdb C ON A.khid = C.khid 
                //												WHERE A.khid = @khid FOR XML PATH('')";
                //20160708 xlm 修正并简化查询方法
                sqlStr = @"DECLARE @khid INT, 
				                                    @ccid VARCHAR(50), 
				                                    @khlbdm VARCHAR(10)

                                    SELECT TOP 1 @khid = khid FROM t_mdb WHERE mdid = @mdid 

                                    SELECT TOP 1 @ccid = ccid FROM yx_t_khb WHERE khid = @khid 

                                    IF (LEN(@ccid) - LEN(REPLACE(@ccid, '-', '')) > 2)	SELECT @ccid = SUBSTRING(@ccid, 1, CHARINDEX('-', @ccid ,4))
                                    ELSE SELECT @ccid = @ccid + '-'

                                    SELECT ',' + CONVERT(VARCHAR(20),A.khid) FROM yx_t_khb A 					
					                                    WHERE A.ccid + '-' LIKE @ccid + '%' FOR XML PATH('')";

                break;
            default:
                break;
        }
        DataTable myDt = null;
        string errInfo = "";
        using (LiLanzDALForXLM zDal = new LiLanzDALForXLM(ZBConnStr))
        {

            List<SqlParameter> myParam = new List<SqlParameter>();
            myParam.Add(new SqlParameter("@mdid", mdid));
            errInfo = zDal.ExecuteQuerySecurity(sqlStr, myParam, out myDt);
            if (errInfo == "")
            {
                mdList = Convert.ToString(myDt.Rows[0][0]);
                mdList = mdList.Remove(0, 1);
            }
            else
            {
                clsSharedHelper.WriteErrorInfo("查询出错。");
            }
        }
        return mdList;
    }


    public void getRank(string mdid, string area, string month)
    {

        string ConWX = clsWXHelper.GetWxConn();

        string errInfo = "";
        string nMonth = "";
        string strSql = "";
        strSql = @"SELECT {0} A.CID, ISNULL(B.cname,'【调岗】') cname,B.avatar, COUNT(A.id) AS fans, ROW_NUMBER() OVER(ORDER BY COUNT(A.id) desc) AS rownumber
                    FROM wx_t_VipServerBind A
                    LEFT JOIN wx_t_customers B ON A.CID = B.ID
                   where {1}";

        string mdList = "";
        switch (area)
        {
            case "shop":
                strSql = string.Format(strSql, "top 10", string.Concat(" A.StoreID = " , mdid));
                break;
            case "area":
                mdList = getArea("area", mdid);
                strSql = string.Format(strSql, "top 20", string.Concat(" A.StoreID IN (", mdList, ")"));
                break;
            case "province":
                mdList = getArea("province", mdid);
                strSql = string.Format(strSql, "top 50", string.Concat(" A.StoreID IN (", mdList, ")"));
                break;
            case "all":
                strSql = string.Format(strSql, "top 100", " 1 = 1 ");
                break;
            default:
                break;

        }

        if (month == "1")//本月
        {
            nMonth = @" AND A.CreateTime >= CONVERT(CHAR(8),GETDATE(),120) + '01' 
                                AND A.CreateTime < CONVERT(CHAR(8),DATEADD(MONTH, 1, GETDATE()),120) + '01' ";
        }
        else if (month == "0")//上月
        {
            nMonth = @" AND A.CreateTime >= CONVERT(CHAR(8),DATEADD(MONTH, -1, GETDATE()),120) + '01' 
                                AND A.CreateTime < CONVERT(CHAR(8),GETDATE(),120) + '01' ";
        }
        else if (month == "2") {
            //昨日
            nMonth = @"  AND A.CreateTime >= CONVERT(CHAR(10),DATEADD(DAY, -1, GETDATE()),120)
                                AND A.CreateTime < CONVERT(CHAR(10),GETDATE(),120)  ";
        }
        else if (month == "3") {
            //今日
            nMonth = @" AND A.CreateTime >= CONVERT(CHAR(10),GETDATE(),120)
                                AND A.CreateTime < CONVERT(CHAR(10),DATEADD(DAY, 1, GETDATE()),120) ";
        }


        using (LiLanzDALForXLM wxDal = new LiLanzDALForXLM(ConWX))
        {
            DataTable dt = null;
            string json= "";
            string groupSql = @"GROUP BY A.CID, B.cname,B.avatar
                                ORDER BY fans DESC";

            strSql = string.Concat(strSql, nMonth, groupSql);

            errInfo = wxDal.ExecuteQuery(strSql, out dt);

            if (errInfo != "")
            {
                clsLocalLoger.WriteError("粉丝排行榜查询失败！错误：" + errInfo);
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }

            string img = "";
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (Convert.ToString(dt.Rows[i]["avatar"]) == "")
                {
                    img = "../../res/img/StoreSaler/defaulticon.jpg";
                }
                else
                {
                    img = clsWXHelper.GetMiniFace(Convert.ToString(dt.Rows[i]["avatar"])); 
                    if (img.StartsWith("http:") == false)
                    {                        
                        img = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), img); 
                    }
                }

                dt.Rows[i]["avatar"] = img;
            }

            json = wxDal.DataTableToJson(dt);

            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.WriteInfo(json);
        }
    }
</script>
 