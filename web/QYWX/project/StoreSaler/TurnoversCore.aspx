<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<%@ Import Namespace="ThoughtWorks.QRCode.Codec" %>
<%@ Import Namespace="ThoughtWorks.QRCode.Codec.Data" %>
<%@ Import Namespace="ThoughtWorks.QRCode.Codec.Util" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<!DOCTYPE html>
<script runat="server"> 

    private const int PageRowCount = 10;
    private const string erpLink = "http://10.0.0.15:9001";      //对于服务器而言的主应用层链接URL 
    private const string erpOutLink = "http://webt.lilang.com:9001";      //对于外部访问而言的主应用层链接URL 
    private const string LilanzShopApiUrl = "svr-commodity/ReleaseGoods?sphh={0}&mdid={1}";   //商品同步微服务的API后缀，要在前面补充 JavaApiGatway
    private const string CreateMiniProgramQrCodeAPI = "https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token={0}";   //小程序创建带场景的分享码
    private const string MiniProgramConfigKey = "201";  //轻商务的小程序

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ClearHeaders();
        Response.AppendHeader("Access-Control-Allow-Origin", "*");
        string requestHeaders = Request.Headers["Access-Control-Request-Headers"];
        Response.AppendHeader("Access-Control-Allow-Headers", string.IsNullOrEmpty(requestHeaders) ? "*" : requestHeaders);
        Response.AppendHeader("Access-Control-Allow-Methods", "PUT,POST,GET,DELETE,OPTIONS");

        Request.ContentEncoding = System.Text.Encoding.UTF8;
        Response.ContentEncoding = System.Text.Encoding.UTF8;
        string ctrl = "";

        if (ctrl == null || ctrl == "")
        {
            ctrl = Convert.ToString(Request.Params["ctrl"]);
        }

        switch (ctrl)
        {
            case "getTurnovers"://废弃
                getTurnovers();
                break;
            case "getList"://废弃
                getList();
                break;
            case "SaveBhDj"://废弃
                SaveBhDj();
                break;
            case "DeleteBhDj"://废弃
                DeleteBhDj();
                break;
            //以下接口被利郎商城使用
            case "getShareUrl":
                getShareUrl();
                break;
            case "ProductDecode":   //商品解码
                ProductDecode();
                break;
            case "getShareHisotry": //返回记录
                getShareHisotry();
                break;
            case "getShareDataByID": //返回一条记录
                getShareDataByID();
                break;
            case "ShareCount": //记录使用次数
                ShareCount();
                break;
            default:
                string rt = ReturnJson(500, "无【CTRL=" + ctrl + "】对应操作！", "");
                clsSharedHelper.WriteInfo(rt);
                break;
        }
    }

    /// <summary>
    /// 获取周转量信息
    /// </summary>
    public void getTurnovers()
    {
        string sphh = Convert.ToString(Request.Params["sphh"]);
        string strPageIndex = Convert.ToString(Request.Params["pageIndex"]);
        string errInfo = "";

        string zCon = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM zDal = new LiLanzDALForXLM(zCon))
        {
            List<SqlParameter> param = new List<SqlParameter>();

            if (sphh == null) sphh = "";
            if (strPageIndex == null) strPageIndex = "0";
            int IndexBegin = Convert.ToInt32(strPageIndex) * PageRowCount;
            int nextPage;

            string strSql = string.Concat(@"SELECT TOP " , PageRowCount , @" * FROM
                        (
                            SELECT sphh,SUM(sl0 - dbdf0 - qtdf0) kc, row_number() over(order by SUM(sl0 - dbdf0 - qtdf0) DESC) as spIndex FROM YX_T_Spkccmmx
                                WHERE tzid=1 AND ckid=13580 AND sphh LIKE @sphh + '%'
							GROUP BY sphh
                        ) AS T
                        WHERE spIndex > ", IndexBegin);

            param.Add(new SqlParameter("@sphh", sphh));

            DataTable dt = null;
            errInfo = zDal.ExecuteQuerySecurity(strSql, param, out dt);

            if (errInfo == "")
            {
                StringBuilder sb = new StringBuilder();

                if (dt.Rows.Count < PageRowCount)  nextPage = -1;
                else nextPage = Convert.ToInt32(strPageIndex) + 1;

                foreach (DataRow dr in dt.Rows)
                {
                    if (sb.Length != 0) sb.Append(",");

                    sb.Append(string.Concat("'", dr["sphh"], "'"));
                }
                dt.Clear(); dt.Dispose();

                if (sb.Length != 0)
                {
                    strSql = string.Concat(@"
                            SELECT B.yphh,B.sphh,B.lsdj,C.cmdm,C.cm,ISNULL(SUM(sl0 - dbdf0 - qtdf0),0) kc  ,ISNULL(G.picUrl,'') picUrl,C.xm
                                FROM YX_T_Spdmb B
                                INNER JOIN yx_t_cmzh C ON B.tml = C.tml AND B.sphh IN (", sb.ToString(), @")
                                LEFT JOIN YX_T_Spkccmmx A ON A.sphh = B.sphh AND A.cmdm = C.cmdm AND A.tzid = 1 AND A.ckid = 13580    
                                LEFT JOIN yx_t_goodPicInfo G ON B.sphh = G.sphh AND G.picXh = 1                          
                                GROUP BY B.yphh,B.sphh,B.lsdj,C.cmdm,C.cm,G.picUrl,C.xm ORDER BY B.sphh ,C.xm");

                    if (dt != null)
                    {
                        dt.Clear(); dt.Dispose(); dt = null;
                    }
                    errInfo = zDal.ExecuteQuery(strSql, out dt);
                    StringBuilder sbJson = new StringBuilder();

                    if (errInfo == "")
                    {
                        List<string> cmname = new List<string>();
                        List<string> cmdm = new List<string>();
                        List<string> kc = new List<string>();
                        string mySphh = "";
                        string myYphh = "";
                        string myLsdj = "";
                        string pic = "";
                        string minipic = "";

                        foreach (DataRow dr in dt.Rows)
                        {
                            if (Convert.ToString(dr["sphh"]) != mySphh)
                            {
                                if (mySphh != "")
                                {
                                    sbJson.Append(",");
                                    AddSb(ref sbJson, mySphh, myYphh, myLsdj, cmname, cmdm, kc, pic, minipic);
                                }

                                mySphh = Convert.ToString(dr["sphh"]);
                                myYphh = Convert.ToString(dr["yphh"]);
                                myLsdj = Convert.ToString(dr["lsdj"]);
                                pic = Convert.ToString(dr["picUrl"]);
                                if (pic == "") minipic = "";
                                else minipic = DownloadAndCreateMiniImg(string.Concat(erpLink, pic.Remove(0, 2)), mySphh);
                                if (pic == "") pic = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), "res/img/StoreSaler/lllogo5.jpg");
                                else pic = string.Concat(erpOutLink, pic.Remove(0, 2));

                                cmname.Clear();
                                cmdm.Clear();
                                kc.Clear();
                            }

                            cmname.Add(Convert.ToString(dr["cm"]));
                            cmdm.Add(Convert.ToString(dr["cmdm"]));
                            kc.Add(string.Format(@"""_{0}"":""{1}""", dr["cm"], dr["kc"]));
                        }

                        if (mySphh != "")
                        {
                            sbJson.Append(",");
                            AddSb(ref sbJson, mySphh, myYphh, myLsdj, cmname, cmdm, kc, pic, minipic);
                        }

                        if (sbJson.Length > 0) sbJson = sbJson.Remove(0,1);


                        sbJson.Insert(0, @"{
                                     ""list"": [");

                        sbJson.Append(@"
                            ],
                           ""err"":""""
                        }");
                    }
                    else
                    {
                        clsLocalLoger.WriteError(string.Concat("获取库存失败！错误：", errInfo));
                        sbJson.Append(string.Concat(@"{""err"":""获取库存失败！""}"));
                    }

                    using (clsJsonHelper ch = clsJsonHelper.CreateJsonHelper(sbJson.ToString()))
                    {
                        sbJson.Length = 0;
                        ch.AddJsonVar("nextPage", Convert.ToString(nextPage));

                        clsSharedHelper.WriteInfo(ch.jSon);
                    }
                }
                else
                {
                    clsSharedHelper.WriteInfo(string.Concat(@"{""err"":""所查商品没有库存！""}"));
                }
            }

            if (errInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("查询商品失败！错误：" , errInfo));
                clsSharedHelper.WriteInfo(string.Concat(@"{""err"":""查询商品失败！""}"));
            }
        }
    }

    /// <summary>
    /// 返回单据列表
    /// </summary>
    private void getList()
    {
        string userid = Request.Params["userid"];

        if (userid == null || userid == "")
        {
            myWriteErrorInfo("必须传入userid");
            return;
        }

        string strErr = "";
        StringBuilder sbJson = new StringBuilder();
        string zCon = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM zDal = new LiLanzDALForXLM(zCon))
        {
            string id_menu = "11450"; //菜单[订购申请单处理] 的id_menu
            string strSql = string.Concat(@"SELECT ',' + CONVERT(VARCHAR(10),B.khid)  FROM t_user_qx A
                    INNER JOIN yx_t_khb B ON A.id_ssid = B.khid 
                    WHERE id_user = ", userid, " AND id_menu = ", id_menu,
                    " FOR XML PATH('')   ");

            object objKhList = null;
            string khList = "";
            string strInfo = zDal.ExecuteQuery(strSql, out objKhList);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("查询权限系统出错！错误：", strInfo));
                strErr = "执行错误！请稍后重试！";
            }
            else
            {
                if (objKhList == null) strErr = "您必须先开通ERP上的 营销管理 - 补货管理 - 订购申请单处理 功能的访问权限！";
                else
                {
                    //取用户信息
                    khList = Convert.ToString(objKhList);
                    khList = khList.Remove(0, 1);
                }
            }

            if (strErr == "")
            {
                //利用 khList 查询单据列表 
                strSql = string.Concat(@"SELECT TOP 20 b.khmc as tzmc ,c.khmc AS mdmc,a.djh,a.je,a.rq,
                            CASE a.shbs WHEN 0 THEN '未审' WHEN 1 THEN '已审毕' ELSE '审核中' END AS shqk, 
	                        CASE a.xjshbs WHEN 0 THEN '未审' WHEN 1 THEN '已审毕' ELSE '审核中' END AS xjshqk, 
	                        CASE a.djzt WHEN 0 THEN '未收发' WHEN 1 THEN '部分收发' ELSE '全部收发' END AS rkqk 
                        FROM yx_T_dddjb a 
                        INNER JOIN yx_t_khb b ON a.tzid=b.khid 
                        LEFT join yx_t_khb c on a.zmdid=c.khid 
                        WHERE a.khid IN (", khList, @") AND a.djlx='204' 
                        ORDER BY A.ID DESC    ");

                DataTable dt = null;

                strInfo = zDal.ExecuteQuery(strSql, out dt);
                if (strInfo == "")
                {
                    string jsonBase = @",{{
                                    ""tzmc"":""{0}"",
                                    ""mdmc"":""{1}"", 
                                    ""shqk"":""{2}"",
                                    ""xjshqk"":""{3}"",
                                    ""rkqk"":""{4}"",
                                    ""djh"":""{5}"",
                                    ""rq"":""{6}"",
                                    ""je"":""{7}""
                                    }}";
                    foreach (DataRow dr in dt.Rows)
                    {
                        sbJson.AppendFormat(jsonBase, dr["tzmc"], dr["mdmc"], dr["shqk"], dr["xjshqk"], dr["rkqk"]
                                                , dr["djh"], Convert.ToDateTime(dr["rq"]).ToString("yyyy-MM-dd"), dr["je"]);
                    }
                    if (sbJson.Length > 0) sbJson.Remove(0, 1);

                    sbJson.Insert(0, @"{
                                     ""list"": [");
                    sbJson.Append(@"]
                              }");
                }
                else
                {
                    strErr = "获取单据信息失败！";
                    clsLocalLoger.WriteError(string.Concat(strErr, "错误：", strInfo));
                }
            }
        }

        if (strErr == "") clsSharedHelper.WriteInfo(sbJson.ToString());
        else myWriteErrorInfo(strErr);

        return;
    }

    private void SaveBhDj()
    {
        object maxdjh = "",shgwid = "", xjshgwid = "", xjshbs = "", zb_dhbh = "", id = "";

        string tzid = Request.Params["khid"];

        string zbid = "1";          //总部是 1
        object tzssid = "1";        //tzid  的所属ID。总部是 1
        string djlx = "204";        //周转量订货单

        List<SqlParameter> lstSqlParams = new List<SqlParameter>();
        string zb_zdr = Convert.ToString(Session["qy_cname"]); //制单人
        if (zb_zdr == null || zb_zdr == "") {
            myWriteErrorInfo("您已登录超时！请重新打开页面。");
            return;
        }

        string zCon = clsConfig.GetConfigValue("OAConnStr");
        string strInfo = "";
        using (LiLanzDALForXLM zDal = new LiLanzDALForXLM(zCon))
        {
            string str_sql = "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SET NOCOUNT ON; select TOP 1 ssid from yx_t_khb where khid=" + tzid;
            strInfo = zDal.ExecuteQueryFast(str_sql, out tzssid);
            if (strInfo == "")
            {
                str_sql = "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SET NOCOUNT ON; select max(djh) as maxdjh from yx_t_dddjb where tzid=" + tzssid + " and year(rq)=YEAR(GetDate()) and month(rq)=MONTH(GetDate()) and djlx=" + djlx;
                strInfo = zDal.ExecuteQueryFast(str_sql, out maxdjh);
                if (strInfo == "")
                {
                    if (maxdjh == null) maxdjh = "100001";
                    else maxdjh = Convert.ToString(Convert.ToInt32(maxdjh) + 1);
                }
            }


            //取得上级第一道审核岗位ID
            if (strInfo == "")
            {
                str_sql = "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SET NOCOUNT ON; select shgwid from xt_v_djshl where sfsh=1 and tzid=" + tzssid + " and djlxid=" + djlx + " and xh=1";
                strInfo = zDal.ExecuteQueryFast(str_sql, out shgwid);
                if (strInfo == "")
                {
                    if (shgwid != null) shgwid = shgwid.ToString().Trim();
                    else shgwid = "0";
                }
            }

            //取得第一道审核岗位ID
            if (strInfo == "")
            {
                str_sql = "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SET NOCOUNT ON; select shgwid from xt_v_djshl where sfsh=1 and tzid=@tzid and djlxid=" + djlx + " and xh=1";
                lstSqlParams.Add(new SqlParameter("@tzid", tzid));
                strInfo = zDal.ExecuteQueryFastSecurity(str_sql,lstSqlParams, out xjshgwid);
                if (strInfo == "")
                {
                    if (xjshgwid != null)
                    {
                        xjshgwid = xjshgwid.ToString().Trim();
                        xjshbs = "0";
                    }
                    else
                    {
                        xjshgwid = "0";
                        xjshbs = "1";
                    }
                }
            }

            //取订货编号
            if (strInfo == "")
            {
                str_sql = "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SET NOCOUNT ON; select TOP 1 dm from yx_v_dhbh where tzid=" + zbid + " order by dm desc";
                strInfo = zDal.ExecuteQueryFast(str_sql, out zb_dhbh);
            }


            if (strInfo == "")
            {
                //直接取所选商品最新的季度
                string zb_spdlid = "1166";//1166	11商务系列      1201	12运动系列
                string zb_djlb = "4792";            //4792  周转补货
                string zb_khid = tzid;
                string zb_zmdid =  "0";
                string zb_bz = Request.Params["bz"];
                string zb_je = Request.Params["jehj"];

                //更新主表记录                 
                string strSpmxJson = Request.Params["SpmxJson"];
                using (clsJsonHelper infoJson = clsJsonHelper.CreateJsonHelper(strSpmxJson))
                {
                    List<clsJsonHelper> lsitJH = infoJson.GetJsonNodes("list");
                    List<clsJsonHelper> lsitCM;

                    str_sql = string.Concat(@"
                                DECLARE @id int,
                                        @mxid int 

                                insert into yx_t_dddjb (tzid,dhbh,djlx,djlb,djbs,djh,rq,khid,zmdid,je,kpje,zdr,xgr,shr,qrr,zdrq,xgrq,jhrq,shrq,qrrq,shbs,qrbs,shgwid,dycs,djzt,zzbs,zzrq,zzr,lydjid,bz,spdlid,xjshbs,xjshgwid,mxjls) values "
                            , "(", tzssid, ",'", zb_dhbh, "',", djlx, ",", zb_djlb, ",1,'", maxdjh, "',GetDate(),", tzid, ",", zb_zmdid, ",@zb_je,0,@zb_zdr,'','','',getdate(),'','','','',0,0,", shgwid, ",0,0,0,'','',0,@zb_bz,"
                                , zb_spdlid, ",", xjshbs, ",", xjshgwid, ",", lsitJH.Count, ") "
                            , " SELECT @id = SCOPE_IDENTITY() ");
                    lstSqlParams.Clear();
                    lstSqlParams.Add(new SqlParameter("@zb_je", zb_je));
                    lstSqlParams.Add(new SqlParameter("@zb_zdr", zb_zdr));
                    lstSqlParams.Add(new SqlParameter("@zb_bz", zb_bz));

                    //strInfo = zDal.ExecuteQueryFastSecurity(str_sql, lstSqlParams, out id);

                    //以下写法会有SQL注入的风险
                    foreach (clsJsonHelper mxJson in lsitJH)
                    {
                        //添加明细表
                        str_sql = string.Concat(str_sql, @" insert into yx_t_dddjmx (id,yphh,sphh,shdm,sl,js,zxid,dj,je,sfjs,sfsl,sfje,lymxid,djzt) values 
                                    (@id,'" , mxJson.GetJsonValue("yphh") , "','" ,mxJson.GetJsonValue("sphh"), "',''," , mxJson.GetJsonValue("sl") ,
                                            ",0,0," +  mxJson.GetJsonValue("dj")  + "," +  mxJson.GetJsonValue("je")  + ",0,0,0,0,0) ");

                        str_sql = string.Concat(str_sql,"SELECT @mxid=SCOPE_IDENTITY() ");

                        lsitCM = mxJson.GetJsonNodes("cmmx");

                        foreach (clsJsonHelper cmJson in lsitCM)
                        {
                            str_sql = string.Concat(str_sql,@" insert into yx_t_dddjcmmx(id,mxid,cmdm,sl0) 
                                        VALUES (@id,@mxid,'" , cmJson.GetJsonValue("cmName") , "'," , cmJson.GetJsonValue("sl") , ") ");

                            cmJson.Dispose();
                        }

                        mxJson.Dispose();
                    }
                }

                strInfo = zDal.ExecuteNonQuerySecurity(str_sql,lstSqlParams);
            }
        }

        if (strInfo == "") clsSharedHelper.WriteSuccessedInfo("");
        else myWriteErrorInfo(string.Concat("执行错误：", strInfo));
    }

    private void DeleteBhDj()
    {
        string id = Request.Params["id"];

        string str_sql = @"DELETE FROM yx_t_dddjb WHERE id=@id
                           DELETE FROM yx_t_dddjmx WHERE id=@id
                           DELETE FROM yx_t_dddjcmmx WHERE id=@id ";

        str_sql = string.Format(str_sql, id);

        string zCon = clsConfig.GetConfigValue("OAConnStr");
        string strInfo = "";
        using (LiLanzDALForXLM zDal = new LiLanzDALForXLM(zCon))
        {
            List<SqlParameter> lstSqlParams = new List<SqlParameter>();
            lstSqlParams.Add(new SqlParameter("@id",id));

            strInfo = zDal.ExecuteNonQuerySecurity(str_sql, lstSqlParams);
        }

        if (strInfo == "") clsSharedHelper.WriteSuccessedInfo("");
        else myWriteErrorInfo(string.Concat("执行错误：", strInfo));
    }

    private static string ReturnJson(int errcode, string errmsg ,string data)
    {
        string strBase = @"{{""errcode"":{0},""errmsg"":""{1}"",""data"":""{2}""}}";

        return string.Format(strBase, errcode, errmsg, data);
    }
    private static string ReturnJson2(int errcode, string errmsg ,string JsonData)
    {
        string strBase = @"{{""errcode"":{0},""errmsg"":""{1}"",""data"":{2}}}";

        return string.Format(strBase, errcode, errmsg, JsonData);
    }
    public void ProductDecode()
    {
        string id = Request.Params["id"];

        string json = "";
        string zCon = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(zCon))
        {
            DataTable dt;
            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@id", id));
            string strInfo = dal.ExecuteQuerySecurity("EXEC wx_up_BarcodeCheck @id", lstParams, out dt);
            if (strInfo != "")
            {
                myWriteErrorInfo(string.Concat("执行错误：", strInfo));
                json = ReturnJson(500, string.Concat("执行错误：", strInfo), "");
                clsSharedHelper.WriteInfo(json);
                return;
            }else if (dt.Rows.Count == 0)
            {
                json = ReturnJson(404, "没有获取到数据", "");
                clsSharedHelper.WriteInfo(json);
                return;
            }

            string sphh = Convert.ToString(dt.Rows[0]["sphh"]);
            clsSharedHelper.DisponseDataTable(ref dt);
            json = ReturnJson(0, "ok", sphh);

        }
        clsSharedHelper.WriteInfo(json);
    }

    public void ShareCount()
    {
        string rt;
        string sharekey = Request.Params["sharekey"];
        string sharetype = Request.Params["sharetype"];  //open商品详情打开时调用传此参数   share2friend分享给朋友动作成功时调用传此参数   share2group分享到朋友圈动作成功时调用传此参数
        string sharesource = Request.Params["sharesource"]; //web  miniprogram        
        if (string.IsNullOrEmpty(sharekey))
        {
            rt = ReturnJson(304, "缺少参数sharekey","");
            clsSharedHelper.WriteInfo(rt);
            return;
        }
        if (string.IsNullOrEmpty(sharetype))
        {
            rt = ReturnJson(304, "缺少参数sharetype","");
            clsSharedHelper.WriteInfo(rt);
            return;
        }
        if (string.IsNullOrEmpty(sharesource))
        {
            rt = ReturnJson(304, "缺少参数sharesource","");
            clsSharedHelper.WriteInfo(rt);
            return;
        }

        using (LiLanzDALForXLM wxdal = new LiLanzDALForXLM(clsWXHelper.GetWxConn()))
        {
            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@sharekey", sharekey));
            string strAdd;
            if (sharetype == "open") strAdd = "openCount = openCount + 1,lastOpenTime = GetDate()";
            else strAdd = "shareCount = shareCount + 1,lastShareTime = GetDate()";

            string strSQL = string.Concat("UPDATE wx_t_ProductShare SET " , strAdd, " WHERE sharekey = @sharekey");
            string strInfo = wxdal.ExecuteNonQuerySecurity(strSQL, lstParams);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("登记分享和打开次数失败！错误：", strInfo));
                rt = ReturnJson(500, "登记分享和打开次数失败","");
                clsSharedHelper.WriteInfo(rt);
                return;
            }
            //登记历史记录
            strSQL = string.Concat("INSERT wx_t_ProductShareHistory (sharekey,sharetype,sharesource) VALUES  (@sharekey,@sharetype,@sharesource) ");
            lstParams.Clear();
            lstParams.Add(new SqlParameter("@sharekey", sharekey));
            lstParams.Add(new SqlParameter("@sharetype", sharetype));
            lstParams.Add(new SqlParameter("@sharesource", sharesource));

            strInfo = wxdal.ExecuteNonQuerySecurity(strSQL, lstParams);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("登记分享和打开历史失败！错误：", strInfo));
                rt = ReturnJson(500, "登记分享和打开历史失败","");
                clsSharedHelper.WriteInfo(rt);
                return;
            }
        }

        rt = ReturnJson(0, "ok", "");
        clsSharedHelper.WriteInfo(rt);
    }

    public void getShareHisotry()
    {
        string cid = Request.Params["cid"];
        string mdid = Request.Params["mdid"];
        string isminiprogram = Request.Params["isminiprogram"];

        using (LiLanzDALForXLM wxdal = new LiLanzDALForXLM(clsWXHelper.GetWxConn()))
        {
            DataTable dtInfo = null;
            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@cid", cid));
            lstParams.Add(new SqlParameter("@mdid", mdid));
            string strSQL = "SELECT TOP 1000 * FROM wx_t_ProductShare WHERE cid = @cid AND mdid = @mdid ";
            if (!string.IsNullOrEmpty(isminiprogram))
            {
                strSQL = string.Concat(strSQL, " AND isminiprogram = @isminiprogram ");
                lstParams.Add(new SqlParameter("@isminiprogram", isminiprogram));
            }
            strSQL = string.Concat(strSQL, " ORDER BY lastUseTime DESC");
            string strInfo = wxdal.ExecuteQuerySecurity(strSQL, lstParams, out dtInfo);
            if (strInfo != "")
            {
                myWriteErrorInfo(string.Concat("获取个人近期分享记录失败！错误：", strInfo));
                return;
            }
            string rt = "";
            try
            {
                rt = wxdal.DataTableToJson(dtInfo);
                Response.Clear();
                Response.Write(rt);
            }
            finally
            {
                clsSharedHelper.DisponseDataTable(ref dtInfo);
                rt = "";
            }
            Response.End();
        }
    }


    public void getShareDataByID()
    {
        string id = Request.Params["id"];

        using (LiLanzDALForXLM wxdal = new LiLanzDALForXLM(clsWXHelper.GetWxConn()))
        {
            string rt = "";
            DataTable dtInfo = null;
            List<SqlParameter> lstParams = new List<SqlParameter>();
            lstParams.Add(new SqlParameter("@id", id));
            string strInfo = wxdal.ExecuteQuerySecurity("SELECT TOP 1 * FROM wx_t_ProductShare WHERE id = @id"
                    ,lstParams, out dtInfo);
            if (strInfo != "" || dtInfo.Rows.Count == 0)
            {
                clsLocalLoger.WriteError(string.Concat("使用场景ID信息失败！错误：", strInfo));

                rt = ReturnJson(500, "使用场景ID信息失败", "");
                clsSharedHelper.WriteInfo(rt);
                return;
            }
            try
            {
                rt = wxdal.DataTableToJson(dtInfo);
                using(clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(rt))
                {
                    rt = jh.GetJsonNodes("list")[0].jSon;
                }
            }
            finally
            {
                clsSharedHelper.DisponseDataTable(ref dtInfo);
            }

            rt = ReturnJson2(0, "ok", rt);

            clsSharedHelper.WriteInfo(rt);
        }
    }

    public void getShareUrl()
    {
        string sphh = Request.Params["sphh"];
        string cid = Request.Params["cid"];
        string mdid = Request.Params["mdid"];
        string isminiprogram = Request.Params["isminiprogram"];
        bool IsMp ;
        if (Convert.ToString(isminiprogram) == "1") IsMp = true;
        else IsMp = false;

        string strInfo = "";
        string zCon = clsConfig.GetConfigValue("OAConnStr");
        using(LiLanzDALForXLM dal = new LiLanzDALForXLM(zCon))
        {
            string picUrl, spmc, mdmc, cname,ryid;
            List<SqlParameter> lstParams = new List<SqlParameter>();

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@sphh", sphh));
            object objSpmc = null;
            strInfo = dal.ExecuteQueryFastSecurity(@"SELECT TOP 1 spmc FROM YX_T_Spdmb WHERE sphh = @sphh AND ty = 0 ", lstParams, out objSpmc);
            if (strInfo != "")
            {
                myWriteErrorInfo(string.Concat("执行错误：", strInfo));
                return;
            }
            spmc = Convert.ToString(objSpmc);
            if (spmc == "")
            {
                myWriteErrorInfo(string.Concat("商品不存在！"));
                return;
            }

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@mdid", mdid));
            object objMdmc = null;
            strInfo = dal.ExecuteQueryFastSecurity(@"SELECT TOP 1 mdmc FROM t_mdb WHERE mdid = @mdid AND ty = 0", lstParams, out objMdmc);
            if (strInfo != "")
            {
                myWriteErrorInfo(string.Concat("执行错误：", strInfo));
                return;
            }
            mdmc = Convert.ToString(objMdmc);
            if (mdmc == "")
            {
                myWriteErrorInfo(string.Concat("门店不存在！"));
                return;
            }

            lstParams.Clear();
            lstParams.Add(new SqlParameter("@cid", cid));
            DataTable dt = null;
            strInfo = dal.ExecuteQuerySecurity(@"SELECT TOP 1 A.cname,B.SystemKey FROM wx_t_customers A
                INNER JOIN wx_t_AppAuthorized B ON A.ID = B.UserID AND B.SystemID = 3
                WHERE A.id = @cid  AND A.IsActive = 1", lstParams, out dt);
            if (strInfo != "")
            {
                myWriteErrorInfo(string.Concat("执行错误：", strInfo));
                return;
            }
            if (dt.Rows.Count == 0)
            {
                myWriteErrorInfo(string.Concat("您没有全渠道权限！"));
                return;
            }
            cname = Convert.ToString(dt.Rows[0]["cname"]);
            string SystemKey = Convert.ToString(dt.Rows[0]["SystemKey"]);
            clsSharedHelper.DisponseDataTable(ref dt);

            using(LiLanzDALForXLM wxdal = new LiLanzDALForXLM(clsWXHelper.GetWxConn()))
            {
                object objRelateID = null;
                strInfo = wxdal.ExecuteQuery(string.Concat("SELECT TOP 1 relateID FROM wx_t_OmniChannelUser WHERE id = '" , SystemKey , "'"),out objRelateID);
                if (strInfo != "" || objRelateID == null)
                {
                    myWriteErrorInfo(string.Concat("无法获取全渠道用户信息：", strInfo));
                    return;
                }
                ryid = Convert.ToString(objRelateID);


                DataTable dtInfo = null;
                strInfo = wxdal.ExecuteQuery(string.Format("SELECT TOP 1 ID,linkurl,imgurl,miniimgurl FROM wx_t_ProductShare WHERE cid = {0} AND ryid = {1} AND mdid = {2} AND sphh = '{3}' AND isminiprogram = {4}"
                        ,cid,ryid,mdid,sphh,IsMp?1:0),out dtInfo);
                if (strInfo != "")
                {
                    myWriteErrorInfo(string.Concat("获取历史分享记录失败！错误：", strInfo));
                    return;
                }
                if (dtInfo.Rows.Count == 1)
                {
                    string ID, linkurl, imgurl, miniimgurl;
                    ID = Convert.ToString(dtInfo.Rows[0]["ID"]);
                    linkurl = Convert.ToString(dtInfo.Rows[0]["linkurl"]);
                    imgurl = Convert.ToString(dtInfo.Rows[0]["imgurl"]);
                    miniimgurl = Convert.ToString(dtInfo.Rows[0]["miniimgurl"]);
                    clsSharedHelper.DisponseDataTable(ref dtInfo);

                    wxdal.ExecuteNonQuery(string.Format("UPDATE wx_t_ProductShare SET useCount = useCount + 1,lastUseTime = GetDate() WHERE ID = {0}", ID));
                    string rt0 = ReturnJson(0, "已存在", miniimgurl, linkurl, sphh, spmc);
                    clsSharedHelper.WriteInfo(rt0);
                    return;
                }
            }

            lstParams.Clear();
            object objPic = null;
            lstParams.Add(new SqlParameter("@sphh", sphh));
            strInfo = dal.ExecuteQueryFastSecurity(@"SELECT TOP 1 picUrl FROM yx_t_goodPicInfo WHERE sphh = @sphh ORDER BY picXh ", lstParams, out objPic);

            if (strInfo != "")
            {
                myWriteErrorInfo(string.Concat("执行错误：", strInfo));
                return;
            }
            picUrl = Convert.ToString(objPic);
            if (picUrl == "")
            {
                myWriteErrorInfo(string.Concat("本商品不提供分享图！"));
                return;
            }
            if (picUrl.StartsWith("..")) picUrl = picUrl.Remove(0, 2);

            string rt = DownloadImgAndCreateInfo(string.Concat(erpLink, picUrl), sphh, cid, mdid, spmc, cname, mdmc,ryid,IsMp);
            if (rt == "")
            {
                myWriteErrorInfo("执行错误！");
            }
            else
            {
                //clsSharedHelper.WriteSuccessedInfo(string.Concat(erpLink, picUrl));
                clsSharedHelper.WriteInfo(rt);
            }
        }
    }

    private void myWriteErrorInfo(string strInfo)
    {
        clsLocalLoger.WriteError(strInfo);
        string rt = ReturnJson(500, strInfo, "");
        clsSharedHelper.WriteInfo(rt);
    }


    /// <summary>
    /// 创建缩略图
    /// </summary>
    /// <param name="url"></param>
    /// <param name="sphh"></param>
    /// <returns></returns>
    private string DownloadImgAndCreateInfo(string url,string sphh,string cid,string mdid,string spmc,string cname,string mdmc,string ryid,bool IsMp)
    {
        string strIsMp = IsMp ? "1" : "0";

        string myFileUrl = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), "upload/StoreSaler/share/my/",cid , "_" ,ryid ,"_" ,mdid , "_",sphh , "_" ,strIsMp, ".jpg");

        string dirMyName = Server.MapPath(string.Concat("../../upload/StoreSaler/share/my"));
        if (!System.IO.Directory.Exists(dirMyName)) System.IO.Directory.CreateDirectory(dirMyName);
        string dirName = Server.MapPath(string.Concat("../../upload/StoreSaler/share"));
        string myFileName = string.Concat(dirMyName , "\\",  cid, "_" ,ryid ,"_" ,mdid , "_",sphh , "_" ,strIsMp, ".jpg");
        string DownFileName = string.Concat(dirMyName , "\\down",  cid, "_" ,ryid ,"_" ,mdid , "_",sphh , "_" ,strIsMp, ".jpg");
        string goodid = "0";

        Random rd = new Random();
        string sharekey = string.Concat(cid, "_", DateTime.Now.ToString("yyMMddHHmmss"),"_",rd.Next(1000,10000));  //Guid.NewGuid().ToString();
        string linkurl = getLinkUrl(sphh, sharekey, mdid, ryid,ref goodid);
        string rj = "";

        if (linkurl == "")
        {
            rj = ReturnJson(500, string.Concat("初始化商城商品信息接口调用失败！"), "", linkurl, sphh, spmc);
            return rj;
        }

        if (System.IO.File.Exists(myFileName))
        {
            System.IO.File.Delete(myFileName);
            //rj = ReturnJson(0, "", myFileUrl, linkurl, sphh, spmc);
            //return rj;
            //return miniFileUrl;    //如果已经存在该文件，则不重新下载         
        }

        string FileName = string.Concat(dirName , "\\", cid, "_" ,ryid ,"_" ,mdid , "_",sphh , "_" ,strIsMp, ".jpg");

        string strInfo = "";

        strInfo = DownloadFile(url, DownFileName);

        object objScene = null;
        using (LiLanzDALForXLM wxdal = new LiLanzDALForXLM(clsWXHelper.GetWxConn()))
        {
            string sql = string.Format(@"INSERT INTO wx_t_ProductShare (cid,ryid,mdid,sphh,linkurl,imgurl,miniimgurl,isminiprogram,goodid,sharekey) VALUES 
                                            ({0},{1},{2},'{3}','{4}','{5}','{6}',{7},{8},'{9}') 
                                    SELECT @@IDENTITY ", cid, ryid, mdid, sphh, linkurl, myFileUrl.Replace("/my/", "/"), myFileUrl,IsMp?1:0,goodid,sharekey);
            strInfo = wxdal.ExecuteQueryFast(sql,out objScene);
            if (strInfo != "")
            {
                myWriteErrorInfo(string.Concat("生成分享记录失败！错误：", strInfo , " sql=",sql));
            }
        }

        if (objScene == null)
        {
            rj = ReturnJson(500, string.Concat("创建分享记录失败！错误：", strInfo), "", linkurl, sphh, spmc);
            return rj;
        }
        if (!IsMp) objScene = "0";
        strInfo = MakeImageInfo(DownFileName, FileName, sphh, mdid, spmc, cname, mdmc,linkurl,Convert.ToInt32(objScene),goodid);

        if (strInfo == "")
        {
            MakeImage(FileName, myFileName, 100);
            System.IO.File.Delete(DownFileName);


            rj = ReturnJson(0, "", myFileUrl, linkurl, sphh, spmc);
            return rj;
            //return myFileUrl;
        }else{
            clsLocalLoger.WriteError(string.Concat("下载图片失败！错误：", strInfo, " url=", url));
            rj = ReturnJson(500, string.Concat("下载图片失败！错误：", strInfo, " url=", url), "", linkurl, sphh, spmc);
            return rj;
            //return "";
        }
    }

    private static string ReturnJson(int errcode, string errmsg ,string miniImgUrl,string linkUrl,string sphh,string spmc)
    {
        string strBase = @"{{""errcode"":{0},""errmsg"":""{1}"",""miniimgurl"":""{2}"",""imgurl"":""{3}"",""linkurl"":""{4}"",""sphh"":""{5}"",""spmc"":""{6}"" }}";

        return string.Format(strBase, errcode, errmsg, miniImgUrl, miniImgUrl.Replace("/my/", "/"), linkUrl, sphh, spmc);

    }


    private static string getLinkUrl(string sphh,string sharekey,string mdid,string ryid,ref string goodid)
    {
        //首先调用 商城初始化接口，传入 sphh 和 mdid 得到 goodId；用于构造二维码的内容
        //string goodid = "0";
        string url = LilanzShopApiUrl;
        url = string.Concat(clsConfig.GetConfigValue("JavaApiGatway"), url);
        url = string.Format(url, sphh, mdid);
        string strResult = clsNetExecute.HttpRequest(url, "", "get", "utf-8", 10000);

        using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(strResult))
        {
            if (jh.GetJsonValue("errcode") == "0")
            {
                goodid = jh.GetJsonValue("data");
            }else
            {
                clsLocalLoger.WriteError(string.Concat("生成分享码-初始化商城商品信息接口调用失败！错误：", strResult));
                return "";
                //goodid = "107332";
            }
        }
        //构造二维码的URL
        string qrCode = string.Concat(clsConfig.GetConfigValue("LilanzShop_WebPath"), "#/gooddetail?goodid={0}&storeid={1}&salerid={2}&sharetype=xssq&sharekey={3}");
        string linkurl = string.Format(qrCode, goodid, mdid, ryid, sharekey);

        return linkurl;
    }


    private static System.Drawing.Font fb = new System.Drawing.Font("宋体", 12);
    private static System.Drawing.Font fbw = new System.Drawing.Font("宋体", 12,System.Drawing.FontStyle.Bold);
    /// <summary>
    /// 处理生成推广图
    /// </summary> 
    /// <returns></returns>
    public static string MakeImageInfo(string SourceImage, string SaveImage, string sphh,string mdid,string spmc,string cname
                            ,string mdmc,string linkurl,int scene,string goodid)
    {
        try
        {
            System.Drawing.Image qrimage = null;
            if (scene > 0)
            {
                string at = clsWXHelper.GetAT(MiniProgramConfigKey);
                string url = string.Format(CreateMiniProgramQrCodeAPI, at);
                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(url);


                req.ContentType = "application/x-www-form-urlencoded";
                req.Method = "POST";

                //填充并发送要post的内容 
                byte[] bytesToPost = System.Text.Encoding.UTF8.GetBytes(string.Format(@"{{
	                                                            ""scene"":""{0}"",
                                                                ""width"":150,
	                                                            ""page"":""pages/redirect/index""
                                                            }}" ,scene));
                req.ContentLength = bytesToPost.Length;

                Stream requestStream = req.GetRequestStream();

                requestStream.Write(bytesToPost, 0, bytesToPost.Length);

                requestStream.Close();

                //发送post请求到服务器并读取服务器返回信息 
                HttpWebResponse rsp = (HttpWebResponse)req.GetResponse();

                req.ContentType = "image/png";
                System.IO.Stream stream = req.GetResponse().GetResponseStream();

                try
                {
                    //以字符流的方式读取HTTP响应
                    stream = rsp.GetResponseStream();
                    qrimage = System.Drawing.Image.FromStream(stream);
                }
                finally
                {
                    // 释放资源
                    if (stream != null) stream.Close();
                    if (rsp != null) rsp.Close();
                }
            }
            else
            {
                QRCodeEncoder qrCodeEncoder = new QRCodeEncoder();
                qrCodeEncoder.QRCodeEncodeMode = QRCodeEncoder.ENCODE_MODE.BYTE;
                qrCodeEncoder.QRCodeScale = 4;
                qrCodeEncoder.QRCodeVersion = 8;
                qrCodeEncoder.QRCodeErrorCorrect = QRCodeEncoder.ERROR_CORRECTION.M;
                qrimage = qrCodeEncoder.Encode(linkurl);
            }

            System.Drawing.Bitmap myBitMap = new System.Drawing.Bitmap(SourceImage);
            float pWidth = myBitMap.Width  - 225;
            float pHeight = myBitMap.Height - 280;

            int maxFontLen = spmc.Length;
            if (maxFontLen < mdmc.Length) maxFontLen = mdmc.Length;

            if (maxFontLen > 8)
            {
                pWidth -= 17 * (maxFontLen - 8);
            }


            System.Drawing.Brush bb = System.Drawing.Brushes.Black;
            System.Drawing.Brush bw = System.Drawing.Brushes.White;
            System.Drawing.Pen p = new System.Drawing.Pen(bb);
            System.Drawing.Pen p2 = new System.Drawing.Pen(bw);

            System.Drawing.Graphics g = System.Drawing.Graphics.FromImage(myBitMap);
            g.DrawRectangle(p, pWidth - 5 , pHeight - 5, myBitMap.Width - pWidth - 1, myBitMap.Height - pHeight - 1);
            g.DrawRectangle(p2, pWidth - 3 , pHeight - 3, myBitMap.Width - pWidth - 5, myBitMap.Height - pHeight - 5);
            g.DrawRectangle(p, pWidth - 1 , pHeight - 1, myBitMap.Width - pWidth - 9, myBitMap.Height - pHeight - 9);


            g.DrawString(string.Format("商品货号：{0}",sphh),fb, bw, pWidth+2,pHeight + 2);
            g.DrawString(string.Format("商品名称：{0}",spmc),fb, bw, pWidth+2,pHeight + 20);
            g.DrawString(string.Format("分享者：{0}",cname),fb, bw, pWidth+2,pHeight + 38);
            g.DrawString(string.Format("分享门店：{0}",mdmc),fb, bw, pWidth+2,pHeight + 56);

            g.DrawString(string.Format("商品货号：{0}",sphh),fb, bb, pWidth,pHeight);
            g.DrawString(string.Format("商品名称：{0}",spmc),fb, bb, pWidth,pHeight + 18);
            g.DrawString(string.Format("分享者：{0}",cname),fb, bb, pWidth,pHeight  + 36);
            g.DrawString(string.Format("分享门店：{0}",mdmc),fb, bb, pWidth,pHeight + 54);

            float qrcodeLeft = pWidth + (myBitMap.Width - pWidth - 160) * 0.5f;
            float qrcodeFontLeft = qrcodeLeft - 22;

            g.DrawRectangle(p, qrcodeLeft - 5, pHeight + 80, 160, 160);
            if (qrimage != null)
            {
                g.DrawImage(qrimage, new System.Drawing.Rectangle(Convert.ToInt32(qrcodeLeft), Convert.ToInt32(pHeight + 85), 150, 150));
                g.DrawString("长按识别二维码了解更多", fbw, bw, qrcodeFontLeft + 2, pHeight + 252);
                g.DrawString("长按识别二维码了解更多", fbw, bb, qrcodeFontLeft, pHeight + 250);
            }

            g.Save();

            myBitMap.Save(SaveImage, System.Drawing.Imaging.ImageFormat.Jpeg);
            g.Dispose();

            myBitMap.Dispose();
            return "";
        }
        catch (Exception ex)
        {
            return string.Concat(clsSharedHelper.Error_Output, "生成图片失败！错误：", ex.Message, " InnerException:" ,ex.InnerException, " StackTrace:" ,ex.StackTrace, " SourceImage=", SourceImage, " SaveImage=", SaveImage);
        }
    }


    /// <summary>
    /// 创建缩略图
    /// </summary>
    /// <param name="url"></param>
    /// <param name="sphh"></param>
    /// <returns></returns>
    private string DownloadAndCreateMiniImg(string url,string sphh)
    {
        string miniFileUrl = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), "upload/StoreSaler/sphh/my/",sphh , ".jpg");

        string dirMyName = Server.MapPath(string.Concat("../../upload/StoreSaler/sphh/my"));
        if (!System.IO.Directory.Exists(dirMyName)) System.IO.Directory.CreateDirectory(dirMyName);
        string dirName = Server.MapPath(string.Concat("../../upload/StoreSaler/sphh"));
        string miniFileName = string.Concat(dirMyName , "\\", sphh , ".jpg");

        if (System.IO.File.Exists(miniFileName)) return miniFileUrl;    //如果已经存在该文件，则不重新下载         

        string FileName = string.Concat(dirName , "\\", sphh , ".jpg");

        string strInfo = "";

        strInfo = DownloadFile(url, FileName);
        if (strInfo == "")
        {
            strInfo = MakeImage(FileName, miniFileName, 80);
        }

        if (strInfo == "")
        {
            return miniFileUrl;
        }else{

            clsLocalLoger.WriteError(string.Concat("下载图片失败！错误：", strInfo, " url=", url));

            return "";
        }
    }

    /// <summary>
    /// 处理图片成指定尺寸()正方形 方便后期的直接使用；
    /// By:xlm 由于处理成正方形可能导致图片呈现效果不理想，因此缩放即可，但是不填充成正方形。
    /// </summary>
    /// <param name="SourceImage"></param>
    /// <param name="SaveImage"></param>
    /// <returns></returns>
    public static string MakeImage(string SourceImage, string SaveImage, int setWidth)
    {
        int imgWidth = setWidth; //缩放以宽度为基准
        try
        {
            System.Drawing.Bitmap myBitMap = new System.Drawing.Bitmap(SourceImage);
            int pWidth = myBitMap.Width;
            int pHeight = myBitMap.Height;
            int draX = 0;
            int draY = 0;

            double pcent = pWidth * 1.0 / imgWidth; //得到缩放比分比
            int imgHeight = Convert.ToInt32(Math.Round(pHeight * 1.0 / pcent));

            System.Drawing.Bitmap eImage = new System.Drawing.Bitmap(imgWidth, imgHeight);
            System.Drawing.Graphics g = System.Drawing.Graphics.FromImage(eImage);
            g.DrawImage(myBitMap, draX, draY, imgWidth, imgHeight);

            g.Save();

            myBitMap.Dispose();

            eImage.Save(SaveImage, System.Drawing.Imaging.ImageFormat.Jpeg);
            g.Dispose();

            eImage.Dispose();
            return "";
        }
        catch (Exception ex)
        {
            return string.Concat(clsSharedHelper.Error_Output, "处理图片失败！错误：", ex.Message, " SourceImage=", SourceImage, " SaveImage=", SaveImage);
        }
    }


    /// <summary>
    /// 下载图片
    /// </summary>
    /// <param name="URL">目标URL</param>
    /// <param name="filename">本地的路径</param>
    /// <returns></returns>
    public static string DownloadFile(string URL, string filename)
    {
        try
        {
            System.Net.HttpWebRequest Myrq = (System.Net.HttpWebRequest)System.Net.HttpWebRequest.Create(URL);
            using (System.Net.HttpWebResponse myrp = (System.Net.HttpWebResponse)Myrq.GetResponse())
            {
                long totalBytes = myrp.ContentLength;
                using (System.IO.Stream st = myrp.GetResponseStream())
                {
                    using (System.IO.Stream so = new System.IO.FileStream(filename, System.IO.FileMode.Create))
                    {
                        long totalDownloadedByte = 0;
                        byte[] by = new byte[1024];
                        int osize = st.Read(by, 0, (int)by.Length);
                        while (osize > 0)
                        {
                            totalDownloadedByte = osize + totalDownloadedByte;
                            so.Write(by, 0, osize);
                            osize = st.Read(by, 0, (int)by.Length);
                        }
                        so.Close();
                        st.Close();

                        so.Dispose();
                        st.Dispose();
                        myrp.Close();
                    }
                }
            }

            return "";
        }
        catch (Exception ex)
        {
            return string.Concat(clsSharedHelper.Error_Output, ex.Message);
        }
    }

    private void AddSb(ref StringBuilder sbJson, string mySphh,string myYphh,string myLsdj
            ,List<string> cmname, List<string> cmdm, List<string> kc, string pic, string miniPic)
    {
        if (miniPic == "") miniPic = pic;

        sbJson.AppendFormat(@" {{
                                        ""sphh"": ""{0}"",
                                        ""yphh"": ""{1}"",
                                        ""lsdj"": ""{2}"",
                                        ""cmname"": ""{3}"",
                                        ""cmdm"": ""{4}"",
                                        ""kc"": {{
                                                    {5}     
                                                }},
                                        ""pic"": ""{6}"",
                                        ""minipic"": ""{7}""
                                        }}"
                                   , mySphh, myYphh, myLsdj, string.Join(",", cmname.ToArray())
                                   , string.Join(",", cmdm.ToArray()), string.Join(",", kc.ToArray()), pic, miniPic);
    }

    //private void SetKcInfo(DataRow dr)
    //{
    //    if (Convert.ToInt32(dr["kc"]) > 10)
    //    {
    //        dr["kcInfo"] = "2";
    //    }
    //    else if (Convert.ToInt32(dr["kc"]) < 1)
    //    {
    //        dr["kcInfo"] = "0";
    //    }
    //    else
    //    {
    //        dr["kcInfo"] = "1";
    //    }
    //}

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
