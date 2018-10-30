<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">  	 
    string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    string dhbh = "";
    string lastDhbh = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        ////设置为测试模式
        //SetIsTestMode();        
        
        string ctrl, rt = "";
        string customersID = Convert.ToString(Session["qy_customersid"]);
        if (customersID == null || customersID == "")
        {
           clsSharedHelper.WriteErrorInfo("您已超时,请重新刷新后访问");
           return;
        }
        
        ctrl = Convert.ToString(Request.Params["ctrl"]);

        dhbh = clsErpCommon.getDhbh();
        //计算得到 lastDhbh; 
        lastDhbh = getLastDhbh(dhbh);        

        switch (ctrl)
        {
            case "GetDhryxxList":
                string mdid = Convert.ToString(Request.Params["mdid"]);
                rt = GetDhryxxList(mdid,customersID);
                break;
            case "GetLastBaseInfo":
                string cname = Convert.ToString(Request.Params["cname"]);
                string InfoType = Convert.ToString(Request.Params["InfoType"]);
                rt = GetLastBaseInfo(customersID, cname, InfoType);
                break;
            case "SaveBaseInfo":
                string baseInfoStr = Convert.ToString(Request.Params["baseInfoStr"]);
                rt = SaveBaseInfo(baseInfoStr);
                break;
            case "SaveDhryway":
                string wayInfoStr = Convert.ToString(Request.Params["wayInfoStr"]);
                rt = SaveDhryway(wayInfoStr);
             break;
            case "GetPersonDetail":
             string ryid = Convert.ToString(Request.Params["ryid"]);
             rt = GetPersonDetail(ryid);
             break;
            //default: rt = clsNetExecute.Error + "参数有误" + "|dhbh:" + dhbh + "|lastdhbh:" + lastDhbh; break;
            default: rt = clsNetExecute.Error + "参数有误"; break;
        }
        clsSharedHelper.WriteInfo(rt);
    }

    /// <summary>
    /// 获取上一季的订货编号
    /// </summary>
    /// <param name="dhbh">本季的订货编号</param>
    /// <returns></returns>
    private string getLastDhbh(string strDhbh)
    {
        if (strDhbh.Length < 5)
        {
            return "";
        }

        int y = Convert.ToInt32(strDhbh.Substring(0, 4));
        int j = Convert.ToInt32(strDhbh.Substring(4, 1));

        if (j == 1) { j = 3; y--; }
        else j--;

        return string.Concat(y, j, "1");
    }
    /// <summary>
    /// 设置为测试模式。即将测试参数写到此处，用于测试
    /// </summary>
    private void SetIsTestMode()
    {        
        OAConnStr = "Data Source=192.168.35.10;Initial Catalog=tlsoft;User ID=ABEASD14AD;password=+AuDkDew";

        // Session["qy_customersid"]= "352";
    }
  
    /// <summary>
    /// 查询门店订货会人员信息列表
    /// </summary>
    /// <param name="mdid"></param>
    /// <returns></returns>
    public string GetDhryxxList(string mdid,string customerid)
    {
        string rt = "", errInfo;
        if (mdid == null || mdid == "")
        {
            return clsNetExecute.Error + "无效门店!";
        }
        string mysql = string.Format(@"SELECT a.id,a.cname,ISNULL(a.sex,0) sex, ISNULL(a.shbs,0) AS shbs,a.phoneNumber,a.idCard,a.rygx,a.hotel,a.hotelRoom,isnull(e.avatar,'') as headImg,case when isnull(e.id,0)={0} then a.id else 0 end as myid,a.rygxqt otherRygx,
                                case when isnull(b.rq,'')='' then '' else CONVERT(VARCHAR(10),b.rq,120) end goTime,
                                case when isnull(b.kssj,'')='' then '' else CONVERT(VARCHAR(10),b.kssj,23) +'T' +CONVERT(VARCHAR(10),b.kssj,108) end goStartTime,
                                isnull(b.wayType,0) AS goWayType,b.wayNum as goWayNum, b.Toaddr AS goToAddr,b.fromaddr as goFromAddr,
                                case when isnull(b.jssj,'')='' then '' else CONVERT(VARCHAR(10),b.jssj,23) +'T' +CONVERT(VARCHAR(10),b.jssj,108) end goEndTime,
                                isnull(c.wayType,0) AS backWayType,c.wayNum as backWayNum, c.fromaddr as backFromAddr,
                                case when isnull(c.kssj,'')='' then '' else CONVERT(VARCHAR(10),c.kssj,23) +'T' +CONVERT(VARCHAR(10),c.kssj,108) end  as backStartTime,
                                case when isnull(c.rq,'')='' then '' else CONVERT(VARCHAR(10),c.rq,120) end  as backTime
                                FROM  yx_t_dhryxx a
                                LEFT JOIN yx_t_dhryway b ON a.id=b.id and b.jllb=1
                                LEFT JOIN yx_t_dhryway c ON a.id=c.id and c.jllb=2
                                LEFT JOIN wx_t_AppAuthorized d on a.id=d.SystemKey and d.SystemID=6
                                LEFT JOIN wx_t_customers e on d.userid=e.id
                                WHERE a.dhbh='{1}' and a.mdid={2} order by a.id", customerid ,dhbh,mdid);
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
        }
        if (errInfo == "")
        {
            rt = JsonHelp.dataset2json(dt);
            dt.Dispose();
        }
        else
        {
            rt = clsNetExecute.Error+ errInfo;
            clsLocalLoger.Log(string.Format("JoinOrderCore.aspx:查询门店列表出错：mysql={0}", mysql));
        }
        return rt;
    }
    /// <summary>
    /// 获取上季报名基本信息
    /// </summary>
    /// <param name="customersID"></param>
    /// <param name="cname"></param>
    /// <param name="InfoType"></param>
    /// <returns></returns>
    public string GetLastBaseInfo(string customersID, string cname, string InfoType)
    {
        string rt = "", errInfo, mysql ;
        switch (InfoType)
        {
            case "myself":
                mysql = string.Format(@" SELECT a.cname,ISNULL(a.sex,0) sex,a.phoneNumber,a.idCard,a.rygx,wx.ID as wxid,a.mdid,wx.avatar as headImg
                                        FROM  dbo.wx_t_customers wx 
                                        INNER JOIN dbo.wx_t_AppAuthorized auth ON wx.ID=auth.userid AND auth.SystemID=6 AND wx.id={0}
                                        INNER JOIN  yx_t_dhryxx a ON auth.SystemKey=a.id and a.dhbh='{1}'", customersID, lastDhbh);
                break;
            case "others":
                mysql = string.Format(@" SELECT b.cname,ISNULL(b.sex,0) sex,b.phoneNumber,b.idCard,b.rygx,d.ID as wxid,b.mdid,d.avatar as headImg
                                        FROM wx_t_customers wx 
                                        INNER JOIN dbo.wx_t_AppAuthorized auth ON wx.ID=auth.userid AND auth.SystemID=6 AND wx.id={0}
                                        INNER JOIN  yx_t_dhryxx a ON auth.SystemKey=a.id
                                        INNER JOIN yx_t_dhryxx b ON a.mdid=b.mdid AND a.id<>b.id
                                        LEFT JOIN wx_t_AppAuthorized c ON b.id=c.SystemKey and c.SystemID=6
                                        left join wx_t_customers d on c.userid=d.id
                                        where b.dhbh={1} AND b.cname='{2}'", customersID, lastDhbh,cname);
                                 
                break;
            default: mysql = ""; break;
        }
        DataTable dt;
        if (mysql == "")
        {
            rt = clsNetExecute.Error + "：InfoType无效";
            return rt;
        }
        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
        }
        if (errInfo == "")
        {
            if (dt.Rows.Count > 1)
            {
                dt.Clear();
            }
            rt = JsonHelp.dataset2json(dt);
            dt.Dispose();
        }
        else
        {
            rt =clsNetExecute.Error+ errInfo;
            clsLocalLoger.Log(string.Format("JoinOrderCore.aspx:获取上季报名基本信息：mysql={0}", mysql));
        }
        return rt;
    }
    /// <summary>
    /// 保存个人基础信息
    /// </summary>
    /// <param name="baseInfoStr"></param>
    /// <returns></returns>
    public string SaveBaseInfo(string baseInfoStr)
    {
        string rt = "", errInfo, mysql = "declare @id int;";
        DataTable dt;
       
        clsJsonHelper baseInfoJson = clsJsonHelper.CreateJsonHelper(baseInfoStr);
        List<SqlParameter> para = new List<SqlParameter>();

        string rygxqt = "";
        if (Convert.ToString(baseInfoJson.GetJsonValue("rygx")) == "其他")
        {
            rygxqt = Convert.ToString(baseInfoJson.GetJsonValue("otherRygx"));
        }
         
        if (baseInfoJson.GetJsonValue("ryid") == "0" || baseInfoJson.GetJsonValue("ryid").Trim() == "")
        {
            mysql = string.Concat(mysql, @"DECLARE @khid varchar(10);
                                    SELECT @khid=khid FROM t_mdb WHERE mdid=@mdid ;
                                    IF NOT EXISTS (SELECT 1 FROM yx_t_dhryxx WHERE PhoneNumber=@PhoneNumber  AND dhbh=@dhbh) BEGIN
                                    INSERT INTO yx_t_dhryxx(tzid,khid,mdid,dhbh,Cname,PhoneNumber,Sex,IdCard,rygx,rygxqt,zdr,zdrq,bz) VALUES(1,@khid,@mdid,@dhbh,@Cname,@PhoneNumber,@Sex,@IdCard,@rygx,@rygxqt,@zdr,GETDATE(),'数据来源于[微信会务系统]');set @id=@@IDENTITY; END ELSE SET @id=0 ;");
            if (baseInfoJson.GetJsonValue("wxid") != "0" && baseInfoJson.GetJsonValue("wxid").Trim() != "")
            {
                mysql = string.Concat(mysql, " IF @id<>0 BEGIN UPDATE dbo.wx_t_AppAuthorized SET SystemKey=@@IDENTITY WHERE userid=@wxid and SystemID=6 end ;");
                para.Add(new SqlParameter("@wxid", baseInfoJson.GetJsonValue("wxid")));
            }
            para.Add(new SqlParameter("@mdid", baseInfoJson.GetJsonValue("mdid")));
            para.Add(new SqlParameter("@zdr", Convert.ToString(Session["qy_cname"])));
            para.Add(new SqlParameter("@dhbh", dhbh));
        }
        else
        {
            //此处少定义了连接目标，这将导致数据无法创建到正式的服务器。  By:xlm 20170116 发现此问题并修正
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                errInfo = dal.ExecuteQuery(string.Format( @"SELECT  ISNULL(c.hzqr,0) hzqr, ISNULL(c.fcqr,0) fcqr
                          FROM dbo.yx_t_dhryxx a INNER JOIN yx_t_khb b ON a.khid=b.khid AND a.id='{0}'
                          INNER JOIN t_customer c ON dbo.split(b.ccid,'-',2)=c.khid AND c.dhbh='{1}'", baseInfoJson.GetJsonValue("ryid"),dhbh),out dt);
            }

            if (errInfo != "")
            {
                return clsNetExecute.Error + errInfo;
            }
            else if (dt.Rows.Count < 1)
            {
                dt.Dispose();
                return clsNetExecute.Error + "未找到修改信息！";
            }
            else
            {
                if (Convert.ToString(dt.Rows[0]["hzqr"]) == "1")
                {
                    return clsNetExecute.Error + "回执信息已确认,个人基本信息不能修改！";
                }
                else
                {
                    dt.Clear();
                }
            }

            mysql = string.Concat(mysql, string.Format(" UPDATE yx_t_dhryxx set Cname=@Cname,PhoneNumber=@PhoneNumber,Sex=@Sex,IdCard=@IdCard,rygx=@rygx,rygxqt=@rygxqt, bz=RIGHT(ISNULL(bz,''),470)+'于{0}使用[微信会务系统]编辑;' where id=@ryid;set @id=@ryid ;", DateTime.Now.ToString("yyyy-MM-dd HH:mm")));
            para.Add(new SqlParameter("@ryid", baseInfoJson.GetJsonValue("ryid")));
        }

        mysql = string.Concat(mysql, "select @id");
        para.Add(new SqlParameter("@Cname", baseInfoJson.GetJsonValue("cname").Trim()));
        para.Add(new SqlParameter("@PhoneNumber", baseInfoJson.GetJsonValue("phoneNumber").Trim()));
        para.Add(new SqlParameter("@Sex", baseInfoJson.GetJsonValue("sex")));
        para.Add(new SqlParameter("@IdCard", baseInfoJson.GetJsonValue("idCard")));
        para.Add(new SqlParameter("@rygx", baseInfoJson.GetJsonValue("rygx")));
        para.Add(new SqlParameter("@rygxqt", rygxqt));

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            baseInfoJson.Dispose();
        }
        if (errInfo == "")
        {
            if (Convert.ToString(dt.Rows[0][0]) == "0")
            {
                rt = clsNetExecute.Error + "此号码已存在,不能重复保存！";
            }
            else
            {
                rt = clsNetExecute.Successed + dt.Rows[0][0];
                dt.Dispose();
            }
        }
        else
        {
            rt = clsNetExecute.Error+errInfo;
        }
        return rt;
    }
    /// <summary>
    /// 保存航班信息
    /// </summary>
    /// <param name="wayInfoStr"></param>
    /// <returns></returns>
    public string SaveDhryway(string wayInfoStr)
    {
        string rt = "",errInfo="";
        DataTable dt;
        
        clsJsonHelper wayInfoJson = clsJsonHelper.CreateJsonHelper(wayInfoStr);
        clsJsonHelper ToInfoJson = clsJsonHelper.CreateJsonHelper(wayInfoJson.GetJsonValue("goInfo"));
        clsJsonHelper BackInfoJson = clsJsonHelper.CreateJsonHelper(wayInfoJson.GetJsonValue("backInfo"));

        if (wayInfoJson.GetJsonValue("id").Equals(""))
        {
            rt = string.Format("{0}保存出错,无人员信息，不能保存航班信息", clsNetExecute.Error);
            return rt;
        }

        //此处少定义了连接目标，这将导致数据无法创建到正式的服务器。  By:xlm 20170116 发现此问题并修正
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(string.Format(@"SELECT  ISNULL(c.hzqr,0) hzqr, ISNULL(c.fcqr,0) fcqr
                          FROM dbo.yx_t_dhryxx a INNER JOIN yx_t_khb b ON a.khid=b.khid AND a.id='{0}'
                          INNER JOIN t_customer c ON dbo.split(b.ccid,'-',2)=c.khid AND c.dhbh='{1}'", wayInfoJson.GetJsonValue("id"), dhbh), out dt);
        }
        if (errInfo != "")
        {
            return clsNetExecute.Error + errInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            dt.Dispose();
            return clsNetExecute.Error + "未找到修改信息！";
        }
        
        string mysql="";
        List<SqlParameter> para = new List<SqlParameter>();

        if (Convert.ToString(ToInfoJson.GetJsonValue("wayType")) != "0" && Convert.ToString(dt.Rows[0]["hzqr"]) != "1")//行程信息,有交通工具才保存
        {
            mysql = @"IF NOT EXISTS (SELECT 1 FROM yx_t_dhryway WHERE id=@id AND jllb=1) BEGIN
                    INSERT INTO yx_t_dhryway(id,jllb,wayType,wayNum,jssj,toaddr,rq,kssj,fromaddr) 
                    VALUES(@id,1,@gowayType,@gowayNum,@gojssj,@gotoaddr,@goTime,@goStartTime,@goFromAddr) END
                    ELSE BEGIN
                    UPDATE yx_t_dhryway SET wayType=@gowayType,wayNum=@gowayNum,jssj=@gojssj,toaddr=@gotoaddr,rq=@goTime,kssj=@goStartTime,fromaddr=@goFromAddr WHERE id=@id AND jllb=1 END;";
            para.Add(new SqlParameter("@gowayType", ToInfoJson.GetJsonValue("wayType")));
            para.Add(new SqlParameter("@gowayNum", ToInfoJson.GetJsonValue("wayNum")));
            para.Add(new SqlParameter("@gojssj", ToInfoJson.GetJsonValue("endTime")));
            para.Add(new SqlParameter("@gotoaddr", ToInfoJson.GetJsonValue("goAddr")));
            para.Add(new SqlParameter("@goTime", ToInfoJson.GetJsonValue("goTime")));
            para.Add(new SqlParameter("@goStartTime", ToInfoJson.GetJsonValue("goStartTime")));
            para.Add(new SqlParameter("@goFromAddr", ToInfoJson.GetJsonValue("goFromAddr")));
        }
        else if (Convert.ToString(dt.Rows[0]["hzqr"]) == "1")
        {
            rt = "回执信息已确认,不能修改;";
        }

        if (Convert.ToString(BackInfoJson.GetJsonValue("wayType")) != "0" && Convert.ToString(dt.Rows[0]["fcqr"]) != "1")//返程信息,有交通工具才保存
        {
            mysql += @" IF NOT EXISTS (SELECT 1 FROM yx_t_dhryway WHERE id=@id AND jllb=2) BEGIN
                   INSERT INTO yx_t_dhryway(id,jllb,wayType,wayNum,kssj,fromaddr,rq)  VALUES(@id,2,@backwayType,@backwayNum,@backkssj,@backfromaddr,@backTime) END
                   ELSE BEGIN UPDATE yx_t_dhryway SET wayType=@backwayType,wayNum=@backwayNum,kssj=@backkssj,fromaddr=@backfromaddr,rq=@backTime WHERE id=@id AND jllb=2 END";
            para.Add(new SqlParameter("@backwayType", BackInfoJson.GetJsonValue("wayType")));
            para.Add(new SqlParameter("@backwayNum", BackInfoJson.GetJsonValue("wayNum")));
            para.Add(new SqlParameter("@backkssj", BackInfoJson.GetJsonValue("startTime")));
            para.Add(new SqlParameter("@backfromaddr", BackInfoJson.GetJsonValue("fromAddr")));
            para.Add(new SqlParameter("@backTime", BackInfoJson.GetJsonValue("backTime")));
        }
        else
        {
            rt = "回执信息已确认,不能修改。";
        }
        
        para.Add(new SqlParameter("@id", wayInfoJson.GetJsonValue("id")));
        if (!mysql.Equals(""))
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                errInfo = dal.ExecuteNonQuerySecurity(mysql, para);
            }
            if (errInfo == "")
            {
                rt = clsNetExecute.Successed + rt;
            }
            else
            {
                rt =clsNetExecute.Error+ errInfo;
            }
        }
        else
        {
            rt = clsNetExecute.Error+ "无交通信息,不需要保存行程信息！";
        }
        return rt;
    }
    /// <summary>
    /// 获取本季报名基本信息
    /// </summary>
    /// <param name="customersID"></param>
    /// <param name="cname"></param>
    /// <param name="InfoType"></param>
    /// <returns></returns>
    public string GetPersonDetail(string ryid)
    {
        string rt = "", errInfo;
        if (ryid == null || ryid == "")
        {
            return clsNetExecute.Error + "无效人员ID";
        }
        string mysql = string.Format(@"SELECT a.id, a.cname,ISNULL(a.sex,0) sex, ISNULL(a.shbs,0) AS shbs,a.phoneNumber,a.idCard,a.rygx,a.hotel,a.hotelRoom,a.mdid,isnull(e.avatar,'') as headImg,a.rygxqt otherRygx,
                        case when isnull(b.rq,'')='' then '' else CONVERT(VARCHAR(10),b.rq,120) end goTime,
                        case when isnull(b.kssj,'')='' then '' else CONVERT(VARCHAR(10),b.kssj,23) +'T' +CONVERT(VARCHAR(10),b.kssj,108) end goStartTime,
                        isnull(b.wayType,0) AS goWayType,b.wayNum as goWayNum,b.Toaddr as goToAddr,b.mxid AS goMxid,b.fromaddr as goFromAddr,
                        case when isnull(b.jssj,'')='' then '' else CONVERT(VARCHAR(10),b.jssj,23) +'T' +CONVERT(VARCHAR(10),b.jssj,108) end  as goEndTime,
                        isnull(c.wayType,0) AS backWayType,c.wayNum as backWayNum,c.fromaddr as backFromAddr,c.mxid AS backMxid,
                        case when isnull(c.kssj,'')='' then '' else CONVERT(VARCHAR(10),c.kssj,23) +'T' +CONVERT(VARCHAR(10),c.kssj,108) end  as backStartTime,
                        case when isnull(c.rq,'')='' then '' else CONVERT(VARCHAR(10),c.rq,120) end  as backTime
                        FROM  yx_t_dhryxx a
                        LEFT JOIN yx_t_dhryway b ON a.id=b.id and b.jllb=1
                        LEFT JOIN yx_t_dhryway c ON a.id=c.id and c.jllb=2
                        LEFT JOIN wx_t_AppAuthorized d on a.id=d.SystemKey and d.SystemID=6
                        LEFT JOIN wx_t_customers e on d.userid=e.id
                        WHERE a.id={0} ", ryid);
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt);
        }
        if (errInfo == "")
        {
            rt = JsonHelp.dataset2json(dt);
            dt.Dispose();
        }
        else
        {
            rt = clsNetExecute.Error+ errInfo;
            clsLocalLoger.Log(string.Format("JoinOrderCore.aspx:人员基本信息：mysql={0}", mysql));
        }
        return rt;
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
