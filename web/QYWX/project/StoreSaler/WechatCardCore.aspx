<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">  
    public ResponseModel res;
    private static string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    private static string WXDBConnStr = clsConfig.GetConfigValue("WXConnStr");
    private static string CXDBconnStr = clsConfig.GetConfigValue("FXDBConStr");
    protected void Page_Load(object sender, EventArgs e)
    {
        OAConnStr = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
        WXDBConnStr = "server=192.168.35.62;database=weChatPromotion;uid=sa;pwd=ll=8727";
        Response.ContentType = "text/html;charset=utf-8";
        Response.ContentEncoding = Encoding.UTF8;
        Request.ContentEncoding = Encoding.UTF8;

        if (Request.HttpMethod.ToUpper().Equals("POST"))
        {
            Stream stream = HttpContext.Current.Request.InputStream;
            StreamReader streamReader = new StreamReader(stream);
            string data = streamReader.ReadToEnd();

            if (string.IsNullOrEmpty(data) == false)
            {
                RequestModel req = JsonConvert.DeserializeObject<RequestModel>(data);
                MethodInfo method = this.GetType().GetMethod(req.action);

                if (method != null)
                {
                    object[] methodAttrs = method.GetCustomAttributes(typeof(MethodPropertyAttribute), false);
                    if (methodAttrs.Length > 0)
                    {

                        MethodPropertyAttribute att = methodAttrs[0] as MethodPropertyAttribute;
                        if (att.WebMethod)
                        {
                            int code = 400;
                            if (att.CheckToken && checkSession(out code) == false)
                            {
                                res = ResponseModel.setRes(code, "访问超时！");
                            }
                            else
                            {
                                try
                                {
                                    method.Invoke(this, req.parameter);
                                    return;
                                }
                                catch (Exception ex)
                                {
                                    res = ResponseModel.setRes(400, "Server Error!" + ex.Message);
                                }
                            }
                        }
                        else
                            res = ResponseModel.setRes(400, "无效请求！！|" + req.action);
                    }
                }
                else
                    res = ResponseModel.setRes(400, "无效操作！");
            }
            else
                res = ResponseModel.setRes(400, "无有效参数！");
        }
        else
            res = ResponseModel.setRes(400, "请求方式不正确！");
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    /*****功能方法*******/
    /// <summary>
    /// 获取卡券列表
    /// </summary>
    [MethodProperty(CheckToken = true, WebMethod = true)]
    public void getCardList()
    {
        DataTable dt;
        Dictionary<string, string> user = userInfo();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string mysql = string.Format(@" SELECT a.id, localcardtype AS localtype,Title AS cardname,subtitle,localdiscount,defaultdetail AS accept_category, 
                                              leastcost,reducecost,totalquantity AS total,convert(varchar(10), begintimestamp,120) AS begintime,convert(varchar(10),endtimestamp,120) AS endtime,description,
                                              ISNULL(c.khmc,'') khmc,a.shbs
                                              FROM  wx_t_cardinfos a
                                              inner JOIN dbo.yx_t_khb kh ON a.khid=kh.khid AND kh.ccid+'-' LIKE '%-{0}-%'
                                              left JOIN (SELECT khid,CID,ROW_NUMBER() OVER(PARTITION BY cid ORDER BY id ) AS xh  FROM wx_t_CardDistribute ) b ON a.id=b.cid AND xh=1
                                              LEFT JOIN dbo.yx_t_khb c ON b.khid=c.khid
                                               WHERE a.EndTimestamp>GETDATE()
                                              order BY a.id DESC", user["khid"]);
            string errInfo = dal.ExecuteQuery(mysql, out dt);
            if (errInfo != "") ResponseModel.setRes(400, "", errInfo);
            else
                res = ResponseModel.setRes(200, dt);
        }
        string rt = JsonConvert.SerializeObject(res);
        clsSharedHelper.DisponseDataTable(ref dt);
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 卡券信息保存
    /// </summary>
    /// <param name="cardStr"></param>
    [MethodProperty(CheckToken = true, WebMethod = true)]
    public void saveCard(string cardStr)
    {
        string localtype, cardname, localdiscount, accept_category, leastcost, reducecost, description, errInfo;
        DateTime begintime, endtime;
        int id, total;
        clsLocalLoger.Log("【移动卡券创建】："+cardStr);
        Dictionary<string, object> dCard;
        try
        {
            dCard = JsonConvert.DeserializeObject<Dictionary<string, object>>(cardStr);
            id = Convert.ToInt32(dCard["id"]);
            localtype = Convert.ToString(dCard["localtype"]);
            cardname = Convert.ToString(dCard["cardname"]);
            localdiscount = Convert.ToString(dCard["localdiscount"]) == "" ? "0" : Convert.ToString(dCard["localdiscount"]);
            accept_category = Convert.ToString(dCard["accept_category"]);
            leastcost = Convert.ToString(dCard["leastcost"]) == "" ? "0" : Convert.ToString(dCard["leastcost"]);
            reducecost = Convert.ToString(dCard["reducecost"]) == "" ? "0" : Convert.ToString(dCard["reducecost"]);
            total = Convert.ToInt32(dCard["total"]);
            begintime = Convert.ToDateTime(dCard["begintime"]);
            endtime = Convert.ToDateTime(dCard["endtime"]);
            description = Convert.ToString(dCard["description"]);
        }
        catch (Exception e)
        {
            res = ResponseModel.setRes(400, "", e.ToString());
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }

        Dictionary<string, string> dUser = userInfo();
        if (dUser == null)
        {
            res = ResponseModel.setRes(400, "", "您停留时间太长,已超时,请退出后重新发访问");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }

        if (dUser["roleName"] != "dz")
        {
            res = ResponseModel.setRes(400, "", "店长这是店长才能创建的卡券,请您切换到店长模式!");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }

        string defaultdetail = "买单前请主动出示收银员，本券为一次性使用。";//品类限制
        if (string.IsNullOrEmpty(accept_category) == false && accept_category!="0")
        {
            defaultdetail = defaultdetail + "仅限购买【" + accept_category + "】使用!";
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            DataTable dt;
            string mysql, ctrl;
            List<SqlParameter> paras = new List<SqlParameter>();
            if (id == 0)
            {
                ctrl = "CreateCard";
                mysql = @"INSERT  INTO wx_t_cardinfos
                            ( khid ,configkey ,cardid ,cardtype ,logourl ,codetype ,brandname ,title ,subtitle ,color ,notice ,[description] ,creater ,createtime ,totalquantity ,quantity ,
                            datetype ,begintimestamp ,endtimestamp ,fixedterm ,fixedbeginterm ,usecustomcode ,bindopenid ,servicephone ,locationidlist ,[source] ,customurlname ,
                            customurl ,customurlsubtitle ,promotionurlname ,promotionurl ,promotionurlsubtitle ,getlimit ,canshare ,cangivefriend ,cardstatus ,leastcost ,
                            reducecost ,defaultdetail ,localcardtype ,localdiscount)
                            VALUES(@khid ,@configkey ,'' ,'GENERAL_COUPON' ,@logourl ,@codetype ,@brandname ,@title ,@subtitle ,@color,@notice,@description,@username,GETDATE() ,@total ,@total ,
                            @datetype ,@begintime ,@endtime ,@fterm ,@fbterm ,'false' ,@binduser ,@servicephone ,'[]' ,@source ,@customurlname ,
                            @customurl ,@customurlsubtitle ,@promotionurlname ,@promotionurl ,@promotionurlsubtitle ,@getlimit ,@canshare ,@cangive ,'CARD_STATUS_NOT_VERIFY' ,@leastcost ,
                            @reducecost ,@defaultdetail ,@localtype ,@localdiscount);select cast( @@identity  as varchar(10))as id,'' CardID";
                paras.Add(new SqlParameter("@khid", dUser["khid"]));
                paras.Add(new SqlParameter("@configkey", dUser["configkey"]));
                paras.Add(new SqlParameter("@logourl", dUser["logourl"]));
                paras.Add(new SqlParameter("@codetype", "CODE_TYPE_BARCODE"));
                paras.Add(new SqlParameter("@brandname", dUser["brandname"]));
                paras.Add(new SqlParameter("@subtitle", "LESS IS MORE"));
                paras.Add(new SqlParameter("@color", backgroudColor()));
                paras.Add(new SqlParameter("@notice", "请让营业员扫码销券"));
                paras.Add(new SqlParameter("@username", Session["qy_cname"]));
                paras.Add(new SqlParameter("@datetype", "DATE_TYPE_FIX_TIME_RANGE"));
                paras.Add(new SqlParameter("@fterm", ""));//多少天内有效
                paras.Add(new SqlParameter("@fbterm", ""));//领取后多少天开始生效
                paras.Add(new SqlParameter("@binduser", "1"));//指定用户
                paras.Add(new SqlParameter("@servicephone", ""));//客户电话
                paras.Add(new SqlParameter("@source", "LILANZ"));//第三方来源
                paras.Add(new SqlParameter("@customurlname", ""));//外链入口名
                paras.Add(new SqlParameter("@customurl", ""));//外链URL地址
                paras.Add(new SqlParameter("@customurlsubtitle", ""));//外链提示语
                paras.Add(new SqlParameter("@promotionurlname", ""));//营销入口名
                paras.Add(new SqlParameter("@promotionurl", ""));//营销URL地址
                paras.Add(new SqlParameter("@promotionurlsubtitle", ""));//营销提示语
                paras.Add(new SqlParameter("@getlimit", "1"));//每个人领取数量限制
                paras.Add(new SqlParameter("@canshare", "0"));//是否可分享
                paras.Add(new SqlParameter("@cangive", false));//是否可转赠
            }
            else
            {
                ctrl = "UpdateWXCard";
                mysql = @"UPDATE wx_t_cardinfos SET title=@title,description=@description,totalquantity=@total,quantity=@total,begintimestamp=@begintime,endtimestamp=@endtime,
                          leastcost=@leastcost,reducecost=@reducecost,defaultdetail=@defaultdetail,localcardtype=@localtype,localdiscount=@localdiscount  WHERE id=@id; 
                          select id,CardID from wx_t_cardinfos where id=@id";
                paras.Add(new SqlParameter("@id", id));
            }
            paras.Add(new SqlParameter("@title", cardname));
            paras.Add(new SqlParameter("@description", description));
            paras.Add(new SqlParameter("@total", total));
            paras.Add(new SqlParameter("@begintime", begintime.ToString("yyyy-MM-dd 00:00")));
            paras.Add(new SqlParameter("@endtime", endtime.ToString("yyyy-MM-dd 23:59")));
            paras.Add(new SqlParameter("@leastcost", leastcost));//起用金额
            paras.Add(new SqlParameter("@reducecost", reducecost));//抵用金额
            paras.Add(new SqlParameter("@defaultdetail", defaultdetail));//优惠说明
            paras.Add(new SqlParameter("@localtype", localtype));
            paras.Add(new SqlParameter("@localdiscount", localdiscount));

            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                res = ResponseModel.setRes(400, "", errInfo);
            }
            else
            {
                id = Convert.ToInt32(dt.Rows[0]["id"]);
                if (Convert.ToString(dt.Rows[0]["CardID"]) == "") ctrl = "CreateCard";
                dt.Columns.Remove("CardID");
                errInfo = clsNetExecute.HttpRequest(string.Format("http://192.168.35.33/interface/WXCardInterface.aspx?ctrl={0}&cid={1}", ctrl, id));
                if (errInfo.IndexOf("Error:") > -1)
                {
                    res = ResponseModel.setRes(400, dt, errInfo);
                }
                else
                {
                    res = ResponseModel.setRes(200, dt, "");
                    Distribute(id);
                }
            }
            string rt = JsonConvert.SerializeObject(res);
            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.WriteInfo(rt);
        }
    }
    /// <summary>
    /// 添加适用门店  可同时插入门店或贸易公司。如果已存在则不再插入，结果返回所有加入的适用门店
    /// </summary>
    /// <param name="id">卡券id</param>
    /// <param name="jstr">门店信息列表</param>
    [MethodProperty(CheckToken = true, WebMethod = true)]
    public void AddSuitStord(string id, string jstr)
    {
        List<Dictionary<string, string>> ld = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(jstr);
        List<string> lkh = new List<string>(), lmd = new List<string>();
        foreach (Dictionary<string, string> d in ld)
        {
            if (d["type"] == "md") lmd.Add(d["khid"]);
            else lkh.Add(d["khid"]);
        }
        DataTable _dtkh = getmc(lkh, "kh"), _dtmd = getmc(lmd, "md");
        string mysql = "", errInfo;
        if (_dtkh != null)
        {
            foreach (DataRow dr in _dtkh.Rows)
            {
                mysql = string.Concat(mysql, string.Format(@"INSERT INTO wx_t_CardSuitStore(cid,khid,khmc,suitType)
                                         SELECT {0},{1},'{2}','kh' FROM (SELECT {0} AS id) a 
                                         LEFT JOIN  dbo.wx_t_CardSuitStore b ON a.id=b.cid AND b.khid={1} 
                                        WHERE a.id={0} AND b.id IS null;", id, dr["khid"], dr["khmc"]));
            }
            clsSharedHelper.DisponseDataTable(ref _dtkh);
        }

        if (_dtmd != null)
        {
            foreach (DataRow dr in _dtmd.Rows)
            {
                mysql = string.Concat(mysql, string.Format(@"INSERT INTO wx_t_CardSuitStore(cid,mdid,mdmc,suitType)
                                         SELECT {0},{1},'{2}','md' FROM (SELECT {0} AS id) a 
                                         LEFT JOIN  dbo.wx_t_CardSuitStore b ON a.id=b.cid AND b.mdid={1} 
                                        WHERE a.id={0} AND b.id IS null;", id, dr["mdid"], dr["mdmc"]));
            }
            clsSharedHelper.DisponseDataTable(ref _dtmd);
        }
        if (mysql.Length > 0)
        {
            // clsSharedHelper.WriteInfo(mysql);
            DataTable dt;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
            {
                errInfo = dal.ExecuteNonQuery(mysql);
                if (errInfo == "")
                {
                    dt = getSuitStore(Convert.ToInt32(id));
                    res = ResponseModel.setRes(200, dt);
                }
                else
                {
                    res = ResponseModel.setRes(400, "", errInfo);
                }
            }
        }
        else
        {
            res = ResponseModel.setRes(400, "", "参数有误");
        }
        string rt = JsonConvert.SerializeObject(res);
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 移除适用门店
    /// </summary>
    /// <param name="sid"></param>
    [MethodProperty(CheckToken = true, WebMethod = true)]
    public void removeSuitStord(string sid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string mysql = "  delete wx_t_CardSuitStore where id=@sid;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sid", sid));
            string errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo == "") res = ResponseModel.setRes(200, "", "");
            else res = ResponseModel.setRes(400, "", errInfo);
        }
        clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
    }
    /// <summary>
    /// 获取授权的客户信息
    /// </summary>
    [MethodProperty(CheckToken = true, WebMethod = true)]
    public void authKH()
    {
        string customerid = Convert.ToString(Session["qy_customersid"]);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string mysql, errInfo;
            DataTable dt = null;
            mysql = @"	SELECT  mdid AS khid,mdmc AS khmc,'md' AS atype FROM wx_t_OmniChannelAuth a WHERE mdid>0  AND ssid>1 AND Customers_ID=@customerid
	                    UNION ALL
	                    SELECT TOP 100 a.khid AS khid,b.khmc AS mdmc,'kh' AS atype
	                    FROM wx_t_OmniChannelAuth a INNER JOIN yx_T_khb b ON a.khid=b.khid AND b.ssid=1 WHERE Customers_ID=@customerid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@customerid", customerid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);

            if (Convert.ToString(Session["RoleName"]) == "dz")
            {
                bool currflag = true;
                foreach (DataRow dr in dt.Rows)
                {
                    if (Convert.ToString(dr["khid"]) == Convert.ToString(Session["mdid"]) && Convert.ToString(dr["atype"]) == "md")
                    {
                        currflag = false;
                        break;
                    }
                }
                if (currflag)
                {
                    string mdmc = getKhmc(Convert.ToString(Session["mdid"]), "md");
                    DataRow dr = dt.NewRow();
                    dr["khid"] = Convert.ToInt32(Session["mdid"]);
                    dr["khmc"] = mdmc;
                    dr["atype"] = "md";
                    dt.Rows.Add(dr);
                }
            }
            res = ResponseModel.setRes(200, dt);
            string rt = JsonConvert.SerializeObject(res);
            clsSharedHelper.DisponseDataTable(ref dt);
            clsSharedHelper.WriteInfo(rt);
        }
    }
    /// <summary>
    /// 获取下级部门信息
    /// </summary>
    /// <param name="khid">所属bmid</param>
    [MethodProperty(CheckToken = true, WebMethod = true)]
    public void xjmd(string khid)
    {
        DataTable dt = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            string mysql = @" SELECT c.mdid,c.mdmc FROM yx_t_khb a INNER JOIN yx_t_khb b ON b.ccid+'-' LIKE a.ccid+'-%' AND b.ty=0 AND a.khid=@khid INNER JOIN dbo.t_mdb c ON b.khid=c.khid ";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@khid", khid));
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") res = ResponseModel.setRes(400, "", errInfo);
            res = ResponseModel.setRes(200, dt, "");
        }
        string rt = JsonConvert.SerializeObject(res);
        clsSharedHelper.DisponseDataTable(ref dt);
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 卡片详细信息
    /// </summary>
    /// <param name="id"></param>
    [MethodProperty(CheckToken = true, WebMethod = true)]
    public void getCard(string id)
    {
        string errInfo;
        string mysql = @"SELECT localcardtype AS localtype,Title AS cardname,localdiscount,defaultdetail AS accept_category, 
  leastcost,reducecost,totalquantity AS total,convert(varchar(10), begintimestamp,120) AS begintime,convert(varchar(10),endtimestamp,120) AS endtime,description
  FROM  wx_t_cardinfos where id=@id";
        DataTable dt = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@id", id));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                res = ResponseModel.setRes(400, "", errInfo);
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                return;
            }
            if (dt.Rows.Count < 1)
            {
                res = ResponseModel.setRes(400, "", "查询有误");
                clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
                return;
            }
            dt.Rows[0]["accept_category"] = Convert.ToString(dt.Rows[0]["accept_category"]).Replace("买单前请主动出示收银员，本券为一次性使用。", "").Replace("仅限购买【", "").Replace("】使用!", "");
        }

        Dictionary<string, object> rtobj = new Dictionary<string, object>();
        rtobj.Add("card", dt);
        DataTable dt_suit = getSuitStore(Convert.ToInt32(id));
        if (dt_suit != null) rtobj.Add("suit", dt_suit);
        else rtobj.Add("suit", "");
        string rt = JsonConvert.SerializeObject(ResponseModel.setRes(200, rtobj));
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 卡券审核
    /// </summary>
    /// <param name="cid"></param>
    [MethodProperty(CheckToken = true, WebMethod = true)]
    public void cardAudit(string cid)
    {
        Dictionary<string, string> user = userInfo();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string mysql = @" UPDATE wx_t_cardinfos SET shbs=1,shr=@shr,shrq=GETDATE() WHERE id=@id ";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@shr", user["cname"]));
            paras.Add(new SqlParameter("@id", cid));
            string errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo != "") ResponseModel.setRes(400, "", errInfo);
            else
                res = ResponseModel.setRes(200, "审核成功", "");
            string rt = JsonConvert.SerializeObject(res);
            clsSharedHelper.WriteInfo(rt);
        }
    }
    /*****功能方法*END******/
    private DataTable getmc(List<string> lkh, string type)
    {
        DataTable dt = null;
        if (lkh.Count < 1) return dt;
        string[] skh = new string[lkh.Count];
        lkh.CopyTo(skh);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            string sql;
            if (type == "kh")
                sql = string.Format("select khid,khmc from yx_T_khb where khid in({0})", string.Join(",", skh));
            else sql = string.Format("select mdid,mdmc from t_mdb where mdid in({0})", string.Join(",", skh));

            string errInfo = dal.ExecuteQuery(sql, out dt);
            if (errInfo != "") dt = null;
        }
        return dt;
    }

    private string getKhmc(string khid, string type)
    {
        string mysql, khmc;
        if (type == "kh")
            mysql = "select khmc from yx_T_khb where khid=@khid";
        else mysql = "select mdmc as khmc from t_mdb where mdid=@khid";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@khid", khid));
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "" || dt.Rows.Count < 1) khmc = "";
            else khmc = Convert.ToString(dt.Rows[0]["khmc"]);
            clsSharedHelper.DisponseDataTable(ref dt);
        }
        return khmc;
    }
    public DataTable getSuitStore(int id)
    {
        DataTable dt = null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string mysql = @" select id as sid, mdid AS khid,mdmc AS khmc,suitType FROM wx_t_CardSuitStore WHERE cid=@id AND suitType='md'
                             UNION ALL 
                              select id as sid, khid AS khid,khmc,suitType FROM wx_t_CardSuitStore WHERE cid=@id AND suitType='kh'";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@id", id));
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") dt = null;
        }
        return dt;
    }

    //检查卡券是否创建到微信服务器，有回填CardID 则默认已创建
    private bool checkCreateWX(int id)
    {
        bool flag = false;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string mysql = "SELECT CardID FROM  wx_t_cardinfos WHERE id=@id";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@id", id));
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            string cardID = "";
            if (errInfo == "" && dt.Rows.Count > 0)
                cardID = Convert.ToString(dt.Rows[0]["CardID"]);
            if (cardID != "") flag = true;
            clsSharedHelper.DisponseDataTable(ref dt);
        }
        return flag;
    }

    private Dictionary<string, string> userInfo()
    {

        string roleName = Convert.ToString(Session["RoleName"]);
        string khid = "1", khfl = "",brandname="利郎男装",configkey="5",logourl="http://mmbiz.qpic.cn/mmbiz/wrgiaawibvBmAF6dCOA33AxFSc5gmSpgjZ4D7YExKlEJ6jUNgtmEHB3roAWKLX8e6s2stsCXN67ZRrnLhaMyYenQ/0";
        Dictionary<string, string> dUser = new Dictionary<string, string>();
        dUser.Add("roleName", roleName);
        DataTable dt;

        if (roleName.Equals("dg") || roleName.Equals("dz") || roleName.Equals("my"))
        {
            List<SqlParameter> paras = new List<SqlParameter>();
            string errInfo, mysql;
            if (roleName.Equals("my"))
            {
                mysql = @"SELECT c.khid, c.khfl 
                    FROM  dbo.wx_t_customers a 
                    INNER JOIN dbo.wx_t_Deptment b ON a.department=b.wxid AND b.deptType='my'
                    INNER JOIN yx_T_khb c ON b.id=c.khid  AND a.id=@uid";
                paras.Add(new SqlParameter("@uid", Session["qy_customersid"]));
            }
            else
            {
                mysql = "select khid,khfl from yx_t_khb where khid=@khid";
                paras.Add(new SqlParameter("@khid", Session["tzid"]));
            }

            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            }

            if (errInfo != "")
            {
                clsLocalLoger.Log("【移动端创建微信卡券出错】：" + errInfo);
                return null;
            }

            if (dt.Rows.Count > 0)
            {
                khid = Convert.ToString(dt.Rows[0]["khid"]);
                khfl = Convert.ToString(dt.Rows[0]["khfl"]);
            }
            clsSharedHelper.DisponseDataTable(ref dt);

        }
        if (khfl=="xk" || khfl=="xm" || khfl=="xn")
        {
            dUser.Add("brandname", "利郎轻商务");
            dUser.Add("configkey", "7");
            dUser.Add("logourl", "https://mmbiz.qlogo.cn/mmbiz_jpg/ricQmKND28iaB9aR747G31jxKvOLs8LKoCYzmVIIor2MbNZ1hHGAjLib2xibUibKumzOIuYJqDagIiaQo6BvO3qlIPBQ/0?wx_fmt=jpeg");
        }

        dUser.Add("khid", khid);
        dUser.Add("cname", Convert.ToString(Session["qy_cname"]));
        dUser.Add("brandname",brandname);
        dUser.Add("configkey",configkey);
        dUser.Add("logourl", logourl);
        //  clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(dUser));
        return dUser;
    }
    /*分配卡券*/
    private void Distribute(int id)
    {
        if (checkCreateWX(id) == false)
        {
            res = ResponseModel.setRes(400, "", "微信卡券尚未创建,不能分配");
            clsSharedHelper.WriteInfo(JsonConvert.SerializeObject(res));
            return;
        }
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            string mysql = "select id from wx_t_CardDistribute where cid=@id and mdid=@mdid";
            paras.Add(new SqlParameter("@id", id));
            paras.Add(new SqlParameter("@mdid", Session["mdid"]));
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (dt.Rows.Count < 1)
                mysql = @"INSERT INTO wx_t_CardDistribute(cid,CardID,khid,mdid,Quantity,Stock,Creater,CreateTime)
                            SELECT id,CardID,khid,@mdid,TotalQuantity,TotalQuantity,Creater,GETDATE()
                            FROM wx_t_cardinfos where id=@id;";
            else mysql = "UPDATE b SET b.Quantity=a.TotalQuantity,b.Stock=a.TotalQuantity FROM wx_t_cardinfos a INNER JOIN wx_t_CardDistribute b ON a.id=b.cid AND b.mdid=@mdid AND a.id=@id";
            clsSharedHelper.DisponseDataTable(ref dt);
            paras.Clear();
            paras.Add(new SqlParameter("@id", id));
            paras.Add(new SqlParameter("@mdid", Session["mdid"]));
            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo != "")
            {
                clsLocalLoger.Log("【移动卡券分配】" + errInfo);
            }
        }
    }
    private string backgroudColor()
    {
        string[] color = { "Color010", "Color020", "Color030", "Color040", "Color050", "Color060", "Color070", "Color080", "Color081", "Color082", "Color090", "Color100", "Color101", "Color102" };
        Random rd = new Random();
        return color[rd.Next(0, color.Length - 1)];
    }
    /// <summary>
    /// 判断session是否存在
    /// </summary>
    /// <param name="context"></param>
    /// <param name="code">输出错误码，提供上级调用判断错误类型</param>
    /// <returns></returns>
    public Boolean checkSession(out int code)
    {
        if (string.IsNullOrEmpty(Convert.ToString(Session["qy_customersid"])))
        {
            code = 401;
            return false;
        }
        else
        {
            code = 0;
            return true;
        }
    }
    //请求的格式
    public class RequestModel
    {
        private string _action;
        public string action
        {
            get { return this._action; }
            set { this._action = value; }
        }

        private string _token;
        public string token
        {
            get { return this._token; }
            set { this._token = value; }
        }

        private Object[] _parameter;
        public Object[] parameter
        {
            get { return this._parameter; }
            set { this._parameter = value; }
        }
    }
    //返回格式
    public class ResponseModel
    {
        private int _code;
        public int code
        {
            set { this._code = value; }
            get { return this._code; }
        }

        private object _data;
        public object data
        {
            set { this._data = value; }
            get { return this._data == null ? string.Empty : this._data; }
        }

        private string _message = "";
        public string message
        {
            set { this._message = value; }
            get { return this._message; }
        }

        public static ResponseModel setRes(int pcode, object pdata, string pmes)
        {
            ResponseModel res = new ResponseModel();
            res.code = pcode;
            res.data = pdata;
            res.message = pmes;
            return res;
        }

        public static ResponseModel setRes(int pcode, object pdata)
        {
            return setRes(pcode, pdata, string.Empty);
        }

        public static ResponseModel setRes(int pcode, string pmes)
        {
            return setRes(pcode, string.Empty, pmes);
        }
    }
    [AttributeUsage(AttributeTargets.Method)]
    public class MethodPropertyAttribute : Attribute
    {
        private bool checkToken = false;
        private bool webMethod = false;

        public bool CheckToken
        {
            get { return this.checkToken; }
            set { this.checkToken = value; }
        }

        public bool WebMethod
        {
            get { return this.webMethod; }
            set { this.webMethod = value; }
        }

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
