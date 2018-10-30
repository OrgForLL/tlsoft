<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<script runat="server">
    private string DBConStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string ChatProConnStr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private string FXCXDBConStr = "server='192.168.35.20';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    private string CXConStr = "server='192.168.35.20';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string uid, vipkh, mdid;
        switch (ctrl)
        {
            case "getVipList":
                FilterData();
                break;
            case "getSphhInfo":
                getsphhInfo();
                break;
            case "getCardsList":
                getCardsList();
                break;
            case "sendSphhInfo":
                sendSphhInfo();
                break;
            case "senCardToVIP":
                senCardToVIP();
                break;
            case "getsplb":
                getSplbID();
                break;
            case "GetUserInfo":
                string wxid = Convert.ToString(Request.Params["wxid"]);
                if (wxid == null || wxid == "0" || wxid == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数wxid！");
                else
                    GetUserInfo(wxid);
                break;
            case "GetTagTemplate":
                GetTagTemplate();
                break;
            case "GetUserTags":
                wxid = Convert.ToString(Request.Params["wxid"]);
                if (wxid == null || wxid == "0" || wxid == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数uid！");
                else
                    GetUserTags(wxid);
                break;
            case "UpUserTags":
                string jsondata = Convert.ToString(Request.Params["tags"]);
                UpUserTags(jsondata);
                break;
            case "GetVIPBehavior":
                uid = Convert.ToString(Request.Params["uid"]);
                vipkh = Convert.ToString(Request.Params["ukh"]);
                if (vipkh == null || vipkh == "0" || vipkh == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数ukh！");
                else
                    GetVIPBehavior(uid, vipkh);
                break;
            case "GetChartDatas":
                uid = Convert.ToString(Request.Params["uid"]);
                vipkh = Convert.ToString(Request.Params["ukh"]);
                string type = Convert.ToString(Request.Params["type"]);
                if (vipkh == null || vipkh == "0" || vipkh == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数ukh！");
                else if (type == null || type == "0" || type == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数type！");
                else
                    GetChartDatas(uid, vipkh, type);
                break;
            case "LatestConsume":
                vipkh = Convert.ToString(Request.Params["ukh"]);
                if (vipkh == null || vipkh == "0" || vipkh == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数ukh！");
                else
                    LatestConsume(vipkh);
                break;
            case "ConsumeDetail":
                string djid = Convert.ToString(Request.Params["djid"]);
                if (djid == null || djid == "0" || djid == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数djid！");
                else
                    ConsumeDetail(djid);
                break;
            case "GetClothesPics":
                string sphh = Convert.ToString(Request.Params["sphh"]);
                if (sphh == null || sphh == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数sphh！");
                else
                    GetClothesPics(sphh);
                break;
            case "SyncVIPInfo":
                vipkh = Convert.ToString(Request.Params["vipkh"]);

                if (vipkh == null || vipkh == "0" || vipkh == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数vipkh！");
                else
                    clsSharedHelper.WriteInfo(SyncVIPInfo(vipkh));
                break;
            case "SyncMDVIPPoints":
                mdid = Convert.ToString(Request.Params["mdid"]);
                if (mdid == "" || mdid == "0" || mdid == null)
                    clsSharedHelper.WriteErrorInfo("缺少参数mdid！");
                else
                    SyncMDVIPPoints(mdid);
                break;
            case "UpdateChange":
                string lxid = Convert.ToString(Request.Params["lxid"]);
                string jfs = Convert.ToString(Request.Params["jfs"]);
                vipkh = Convert.ToString(Request.Params["vipkh"]);
                UpdateChange(lxid, jfs, vipkh);
                break;
            case "BindVIP":
                string jsonStr = Convert.ToString(Request.Params["jsonStr"]);
                if (jsonStr == "" || jsonStr == null)
                    clsSharedHelper.WriteErrorInfo("请传入相关参数!");
                else
                    BindVIP(jsonStr);
                break;
            case "RegisterVIP":
                jsonStr = Convert.ToString(Request.Params["jsonStr"]);
                if (jsonStr == "" || jsonStr == null)
                    clsSharedHelper.WriteErrorInfo("请传入相关参数!");
                else
                    RegisterVIP(jsonStr);
                break;
            case "TestInt":
                HttpCookie cookie = Request.Cookies["sign"];
                if (cookie == null)
                    clsSharedHelper.WriteErrorInfo("越权访问！");
                else
                    clsSharedHelper.WriteSuccessedInfo(cookie.Value);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无ctrl=" + ctrl + "对应操作！【注意大小写】");
                break;
        }
    }
    private void getSplbID()
    {
        string myslq = @"SELECT id,mc FROM YX_T_Splb WHERE id IN(1336,1476,1486,1298,1337,1477,1492)";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXCXDBConStr))
        {
            DataTable dt;
            string errInfo = dal.ExecuteQuery(myslq, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            clsSharedHelper.WriteInfo(DataTableToJson(dt));
        }
    }
    private void senCardToVIP()
    {
        string bid, wxopenid, cardid, errInfo, mysql;
        bid = Convert.ToString(Request.Params["bid"]);
        cardid = Convert.ToString(Request.Params["cardid"]);
        mysql = "SELECT ObjectID,wxOpenid  FROM dbo.wx_t_vipBinging WHERE id=@bid ";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@bid", bid));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            if (dt.Rows.Count < 1) clsSharedHelper.WriteErrorInfo("无效bid!");
            wxopenid = Convert.ToString(dt.Rows[0]["wxOpenid"]);
            clsSharedHelper.DisponseDataTable(ref dt);

            //判断是否已经发送过了，已发送未领不再发送
            mysql = "SELECT  * FROM dbo.wx_t_CardRelation WHERE Openid=@Openid AND CardID=@CardID AND IsGet=0";
            paras.Clear();
            paras.Add(new SqlParameter("@Openid", wxopenid));
            paras.Add(new SqlParameter("@CardID", cardid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            if (dt.Rows.Count >= 1) clsSharedHelper.WriteErrorInfo("已有一张卡券给该用户，请通知其领取后再发送!");
            clsSharedHelper.DisponseDataTable(ref dt);

            errInfo = clsWXHelper.doSendCard2VIP(wxopenid, cardid);
            JObject jo = JObject.Parse(errInfo);
            if (Convert.ToString(jo["code"]) == "200") clsSharedHelper.WriteSuccessedInfo("");
            else clsSharedHelper.WriteErrorInfo(Convert.ToString(jo["message"]));
            //clsSharedHelper.WriteInfo(errInfo);
        }
    }
    private void sendSphhInfo()
    {
        string sphh = Convert.ToString(Request.Params["sphh"]);
        string bid = Convert.ToString(Request.Params["bid"]);
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string cid = Convert.ToString(Request.Params["cid"]);
        string configkey = "", openid;
        // openid = "oarMEt6cRU2nk3GkRGHfyIfnJZ4c";
        // openid = "o8SpZvwuOsFTgE-Fu1fqrPaSwJFo";//轻商务

        string mysql, errInfo, spmc = "", mdmc = "", cname = "", mobile = "", templateID = "";
        mysql = "SELECT ObjectID,wxOpenid  FROM dbo.wx_t_vipBinging WHERE id=@bid";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@bid", bid));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            if (dt.Rows.Count < 1) clsSharedHelper.WriteErrorInfo("无效vip");
            openid = Convert.ToString(dt.Rows[0]["wxOpenid"]);
            if (Convert.ToString(dt.Rows[0]["ObjectID"]) == "1")
            {
                configkey = "5";
                templateID = "r6eVxXJrC3rOR9o-AshQy_ApyCT2FTxHq_HA5kp4F_E";
            }
            else if (Convert.ToString(dt.Rows[0]["ObjectID"]) == "4")
            {
                configkey = "7";
                templateID = "RElyOPtDDrbPK2DqNXEu0QGj6ODDQTGvEcjOTwGz3FY";
            }
            else configkey = "0";
            clsSharedHelper.DisponseDataTable(ref dt);
            //clsSharedHelper.WriteInfo(configkey);
            //商品名称
            mysql = "SELECT a.spmc FROM dbo.YX_T_Spdmb a WHERE sphh=@sphh";
            paras.Clear();
            paras.Add(new SqlParameter("@sphh", sphh));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            spmc = Convert.ToString(dt.Rows[0]["spmc"]);
            clsSharedHelper.DisponseDataTable(ref dt);

            //门店名称
            mysql = "SELECT mdmc FROM dbo.t_mdb a WHERE mdid=@mdid";
            paras.Clear();
            paras.Add(new SqlParameter("@mdid", mdid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            mdmc = Convert.ToString(dt.Rows[0]["mdmc"]);
            clsSharedHelper.DisponseDataTable(ref dt);

            //名字、电话
            mysql = "SELECT cname,mobile FROM dbo.wx_t_customers WHERE id=@cid";
            paras.Clear();
            paras.Add(new SqlParameter("@cid", cid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            cname = Convert.ToString(dt.Rows[0]["cname"]);
            mobile = Convert.ToString(dt.Rows[0]["mobile"]);
            clsSharedHelper.DisponseDataTable(ref dt);
        }

        string url = "http://tm.lilanz.com/oa/project/StoreSaler/goodsListV7.aspx?showType=2&sphh=" + sphh;
        string errcode = "", postData = "";
        postData = @"{{
                        ""touser"":""{0}"",
                        ""template_id"":""{1}"",
                        ""url"":""{2}"",            
                        ""data"":{{
                                ""first"": {{""value"":""尊贵的利郎会员，您关注的商品已经到货。"",""color"":""#000000""}},
                                ""keyword1"":{{""value"":""{3}"",""color"":""#d9534f""}},
                                ""keyword2"":{{""value"":""{4}"",""color"":""#000000""}},
                                ""keyword3"":{{""value"":""{5}"",""color"":""#173177""}},
                                ""keyword4"":{{""value"":""{6}"",""color"":""#173177""}},
                                ""remark"":{{""value"":""点击详情了解更多>>"",""color"":""#000000""}}
                                 }}
                        }}";
        postData = string.Format(postData, openid, templateID, url, spmc + "(" + sphh + ")", cname, mobile, mdmc, DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

        string token = clsWXHelper.GetAT(configkey);
        using (clsJsonHelper jh = clsWXHelper.SendTemplateMessage(token, postData))
        {
            if (jh.GetJsonValue("errcode") == "0")
                errcode = clsNetExecute.Successed;
            else
            {
                errcode = clsNetExecute.Error + "|" + jh.GetJsonValue("errcode") + "|" + jh.GetJsonValue("errmsg") + "|" + openid;
            }
        }//end send using 
        clsSharedHelper.WriteInfo(errcode);
    }
    //获取门店卡券列表
    private void getCardsList()
    {
        string mdid = Convert.ToString(Request.Params["mdid"]);
        if (string.IsNullOrEmpty(mdid)) mdid = Convert.ToString(Session["mdid"]);
        if (string.IsNullOrEmpty(mdid)) clsSharedHelper.WriteErrorInfo("访问超时或您未有有效mdid");
        string errInfo, mysql;
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            string ConfigKey = "5";
            mysql = @"SELECT TOP 100 khfl 
                      FROM dbo.t_mdb a INNER JOIN dbo.yx_t_khb b ON a.khid=b.khid 
                      where a.mdid=@mdid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mdid", mdid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            if (dt.Rows.Count < 1) clsSharedHelper.WriteErrorInfo("无效门店");
            if (Convert.ToString(dt.Rows[0]["khfl"]).Contains("xk") || Convert.ToString(dt.Rows[0]["khfl"]).Contains("xm") || Convert.ToString(dt.Rows[0]["khfl"]).Contains("xn"))
            {
                ConfigKey = "7";
            }

            mysql = @"SELECT a.id, b.ConfigName,a.title,a.Description,a.BeginTimestamp,a.EndTimestamp,c.Stock,a.Color
                    FROM wx_t_cardinfos a INNER JOIN dbo.wx_t_TokenConfigInfo b ON a.ConfigKey=b.ConfigKey and a.ConfigKey=@ConfigKey
                    INNER JOIN wx_t_CardDistribute c ON a.id=c.CID AND c.mdid=@mdid
                    WHERE a.IsDel=0 AND c.Stock>0  AND a.EndTimestamp>=GETDATE()
                    ORDER BY a.id DESC";
            dal.ConnectionString = ChatProConnStr;
            paras.Clear();
            paras.Add(new SqlParameter("@mdid", mdid));
            paras.Add(new SqlParameter("@ConfigKey", ConfigKey));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            clsSharedHelper.WriteInfo(DataTableToJson("rows", dt));
        }
    }
    //获取商品信息
    private void getsphhInfo()
    {
        string errInfo, sphh = Convert.ToString(Request.Params["sphh"]);
        if (string.IsNullOrEmpty(sphh) || sphh.Length != 9)
        {
            clsSharedHelper.WriteErrorInfo("货号有误！请输入完整的货号。");
        }

        string mysql = @"SELECT spmc,lsdj,a.sphh,a.id,isnull(b.picUrl,'') picUrl
                        FROM dbo.YX_T_Spdmb a 
                        LEFT JOIN yx_v_goodPicInfo b ON a.sphh=b.sphh AND b.picXh=1
                        WHERE a.sphh=@sphh";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@sphh", sphh));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            foreach (DataRow dr in dt.Rows)
            {
                dr["picUrl"] = Convert.ToString(dr["picUrl"]).Replace("../", clsConfig.GetConfigValue("ERP_WebPath"));
            }
        }
        clsSharedHelper.WriteInfo(DataTableToJson("rows", dt));
    }

    /// <summary>
    /// 导购帮客户绑定VIP
    /// </summary>
    /// <param name="jsonStr">相关信息用JSON串传输{ "mdid": mdid, "salerid": AppSystemKey, "bid": bid,"vipkh":vipkh }</param>
    public void BindVIP(string jsonStr)
    {
        clsSharedHelper.WriteErrorInfo("请让客人自己绑定!");
        /* using (LiLanzDALForXLM dal_62 = new LiLanzDALForXLM(ChatProConnStr))
         {
             clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jsonStr);
             string mdid = jh.GetJsonValue("mdid");
             string salerid = jh.GetJsonValue("salerid");
             string bid = jh.GetJsonValue("bid");
             string vipkh = jh.GetJsonValue("vipkh");
             string str_sql = @" declare @openid varchar(100);declare @vipid int;
                                 select @openid=wxopenid,@vipid=vipid from wx_t_vipbinging where id=@bid;
                                 if isnull(@openid,'')=''
                                 select '00';
                                 else if exists (select top 1 a.id from yx_t_vipkh a inner join wx_t_vipbinging b on a.id=b.vipid where a.kh=@vipkh)
                                 select '04';
                                 else if not exists (select top 1 id from wx_t_vipsalerbind where openid=@openid and salerid=@salerid)
                                 select '01';
                                 else if isnull(@vipid,0)>0
                                 select '02';
                                 else if not exists (select top 1 id from yx_t_vipkh where kh=@vipkh)
                                 select '03'
                                 else
                                 select '11',@openid openid,id vipid from yx_t_vipkh where kh=@vipkh";
             List<SqlParameter> paras = new List<SqlParameter>();
             paras.Add(new SqlParameter("@bid", bid));
             paras.Add(new SqlParameter("@salerid", salerid));
             paras.Add(new SqlParameter("@vipkh", vipkh));
             DataTable dt = null;
             string errinfo = dal_62.ExecuteQuerySecurity(str_sql, paras, out dt);
             if (errinfo == "" && dt.Rows.Count > 0)
             {
                 string dm = dt.Rows[0][0].ToString();
                 if (dm == "11")
                 {
                     string openid = dt.Rows[0]["openid"].ToString();
                     string vipid = dt.Rows[0]["vipid"].ToString();
                     //验证通过 接下来更新10及62
                     using (LiLanzDALForXLM dal_10 = new LiLanzDALForXLM(DBConStr))
                     {
                         str_sql = @"update wx_t_vipbinging set vipid=@vipid where id=@bid and objectid=1 and wxopenid=@openid;";
                         paras.Clear();
                         paras.Add(new SqlParameter("@bid", bid));
                         paras.Add(new SqlParameter("@openid", openid));
                         paras.Add(new SqlParameter("@vipid", vipid));
                         errinfo = dal_10.ExecuteNonQuerySecurity(str_sql, paras);
                         if (errinfo == "")
                         {
                             //接下来更新62的VipSalerBind和wx_t_VipSalerHistory
                             str_sql = @"update wx_t_VipSalerBind 
                                         set vipid=@vipid,createid=salerid,createname='导购为客户绑定' where openid=@openid and salerid=@salerid;
                                         update b set b.vipid=@vipid
                                         from wx_t_VipSalerBind a
                                         inner join wx_t_VipSalerHistory b on a.id=b.bindid
                                         where a.openid=@openid;";
                             paras.Clear();
                             paras.Add(new SqlParameter("@salerid", salerid));
                             paras.Add(new SqlParameter("@openid", openid));
                             paras.Add(new SqlParameter("@vipid", vipid));
                             str_sql = "BEGIN TRANSACTION " + str_sql + " COMMIT TRANSACTION GO ";
                             errinfo = dal_62.ExecuteNonQuerySecurity(str_sql, paras);
                             if (errinfo == "")
                                 clsSharedHelper.WriteSuccessedInfo(vipid + "|" + vipkh);
                             else
                                 clsSharedHelper.WriteErrorInfo("更新绑定信息时出错[2] " + errinfo);
                         }
                         else
                             clsSharedHelper.WriteErrorInfo("更新绑定信息时出错[1] " + errinfo);
                     }
                 }
                 else
                 {
                     switch (dm)
                     {
                         case "00"://传入的BID无效
                             clsSharedHelper.WriteErrorInfo("传入的BID无效!");
                             break;
                         case "01"://绑定关系是否还有效
                             clsSharedHelper.WriteErrorInfo("对不起,当前微信用户不是您的粉丝!");
                             break;
                         case "02"://该微信号是否已经绑定过VIP了
                             clsSharedHelper.WriteErrorInfo("对不起,该粉丝微信号已经绑定过VIP了!");
                             break;
                         case "03"://VIP卡号无效
                             clsSharedHelper.WriteErrorInfo("VIP卡号无效!");
                             break;
                         case "04"://该VIP卡已绑定其它微信号
                             clsSharedHelper.WriteErrorInfo("对不起，该VIP卡已经绑定了其它微信号！");
                             break;
                         default:
                             clsSharedHelper.WriteErrorInfo("未知错误!");
                             break;
                     }
                 }
             }
             else
                 clsSharedHelper.WriteErrorInfo("绑定VIP时出错 " + errinfo);
         }*/
    }

    /// <summary>
    /// 导购帮客户注册VIP
    /// </summary>
    /// <param name="jsonStr">相关信息用JSON串传输{ "khid":khid, "mdid": mdid, "salerid": AppSystemKey, "bid": bid, "vipkh": vipkh,name:username, xb:xb, birthday:birthday, tel:tel };</param>    
    public void RegisterVIP(string jsonStr)
    {

        using (LiLanzDALForXLM dal_10 = new LiLanzDALForXLM(DBConStr))
        {
            clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jsonStr);

            string birthday = jh.GetJsonValue("birthday");
            try
            {
                Convert.ToDateTime(birthday);
            }
            catch (Exception ex)
            {
                clsSharedHelper.WriteErrorInfo("生日输入不合法!格式1990-1-1");
                return;
            }
            string khid = jh.GetJsonValue("khid");
            string mdid = jh.GetJsonValue("mdid");
            string salerid = jh.GetJsonValue("salerid");
            string bid = jh.GetJsonValue("bid");
            string vipkh = jh.GetJsonValue("vipkh");
            string username = jh.GetJsonValue("name");
            string xb = jh.GetJsonValue("xb");
            string tel = jh.GetJsonValue("tel");
            string str_sql = @" if exists (select top 1 1 from wx_t_vipbinging where id=@bid and vipid>0)
                                select '00';
                                else if exists (select top 1 1 from yx_t_vipkh where kh=@yddh)
                                select '01';
                                else
                                begin
                                declare @newvipid int;declare @khid int;
                                select @khid=khid from t_mdb where mdid=@mdid;
                                insert yx_t_vipkh(khid,mdid,shbs,kh,xm,xb,csrq,yddh,jdrq,tbrq,klb,isjf) 
                                values (@khid,@mdid,1,@yddh,@xm,@xb,@csrq,@yddh,getdate(),getdate(),'20',0);
                                select @newvipid=@@identity;
                                update wx_t_vipBinging set vipid = @newvipid,khid=@khid,mdid=@mdid where id=@bid and objectid=1;
                                select '11',@newvipid,a.wxopenid
                                from wx_t_vipbinging a where a.id=@bid;
                                end";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@bid", bid));
            paras.Add(new SqlParameter("@yddh", tel));
            paras.Add(new SqlParameter("@mdid", mdid));
            paras.Add(new SqlParameter("@xm", username));
            paras.Add(new SqlParameter("@xb", xb));
            paras.Add(new SqlParameter("@csrq", birthday));
            DataTable dt = null;
            str_sql = "BEGIN TRANSACTION " + str_sql + " COMMIT TRANSACTION GO ";
            string errinfo = dal_10.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                string dm = dt.Rows[0][0].ToString();
                if (dm == "11")
                {
                    string vipid = dt.Rows[0][1].ToString();
                    string openid = dt.Rows[0][2].ToString();
                    clsWXHelper.FansBindStore(openid,Convert.ToInt32(mdid), clsWXHelper.DisBindVipOpinion.其它, Convert.ToInt32(Session["qy_customersid"]));
                }
                else
                {
                    switch (dm)
                    {
                        case "00":
                            clsSharedHelper.WriteErrorInfo("对不起,该微信号已经注册过VIP!");
                            break;
                        case "01":
                            clsSharedHelper.WriteErrorInfo("对不起,该手机号已经被注册过!");
                            break;
                        default:
                            clsSharedHelper.WriteErrorInfo("未知错误!");
                            break;
                    }
                }
            }
            else
                clsSharedHelper.WriteErrorInfo("注册VIP会员时出错 " + errinfo);
        }
    }

    /// <summary>
    /// 用于积分变动时的调用
    /// </summary>
    /// <param name="lxid">积分类型ID</param>
    /// <param name="jfs">变动的值，带符号，但是不可能出现对应类型的方向为-1变动值是负数的情况，或者换句话说当传入变动值为负数时，它的方向只能为正</param>
    /// <param name="vipkh">VIP卡号</param>
    public void UpdateChange(string lxid, string jfs, string vipkh)
    {
        using (LiLanzDALForXLM dal_62 = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = @"select a.name,a.flag,isnull(vi.id,0) infoid,a.impactrange 
                                from wx_t_vippointtype a
                                left join wx_t_vipinfo vi on vi.vipcardno=@vipkh
                                where a.isactive=1 and a.id=@lxid;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipkh", vipkh));
            paras.Add(new SqlParameter("@lxid", lxid));
            DataTable dt = null;
            string errinfo = dal_62.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string remark = dt.Rows[0]["name"].ToString();
                    string flag = dt.Rows[0]["flag"].ToString();
                    string infoid = dt.Rows[0]["infoid"].ToString();
                    string impactRange = dt.Rows[0]["impactrange"].ToString();
                    int val = Convert.ToInt32(flag) * Convert.ToInt32(jfs);
                    int changeValue = val;
                    if (val >= 0)
                    {
                        flag = "1";
                    }
                    else
                    {
                        flag = "-1";
                        changeValue = -1 * val;
                    }

                    if (infoid == "0")
                    {
                        string rt = SyncVIPInfo(vipkh);
                        if (rt.Contains("Error:"))
                        {
                            clsSharedHelper.WriteErrorInfo("初始化该用户积分记录失败！" + rt);
                            return;
                        }
                    }

                    string changeConsume = @" update set consumepoints=consumepoints+@fcv,userpoints=userpoints+@fcv from wx_t_vipinfo where vipcardno=@vipkh;";
                    string changeActivity = @" update set activitypoints=activitypoints+@fcv,userpoints=userpoints+@fcv from wx_t_vipinfo where vipcardno=@vipkh;";
                    string changeCharm = @" update set charmvalue=charmvalue+@fcv,
                                            viptitle=case when charmvalue+@fcv<=0 then 0 else case when charmvalue+@fcv<=2000 then 1 else case when charmvalue+@fcv<=6000 then 2 else case when charmvalue+@fcv<=12000 then 3 
                                            else case when charmvalue+@fcv<=20000 then 4 else case when charmvalue+@fcv<=30000 then 5 else case when charmvalue+@fcv<=42000 then 6 else 7 end end end end end end end
                                            from wx_t_vipinfo where vipcardno=@vipkh;";

                    /*
                     *消费积分、活动积分、魅力值 三位
                     *100-消费积分
                     *010-活动积分
                     *001-魅力值
                     *101-消费积分+魅力值
                     *011-活动积分+魅力值
                     *110-消费积分+活动积分
                     *111-消费积分+活动积分+魅力值
                     */
                    switch (impactRange)
                    {
                        case "001":
                            str_sql = changeCharm;
                            break;
                        case "010":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeActivity;
                            break;
                        case "011":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeActivity + changeCharm;
                            break;
                        case "100":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeConsume;
                            break;
                        case "101":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeConsume + changeCharm;
                            break;
                        case "110":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeConsume + changeActivity;
                            break;
                        case "111":
                            str_sql = @"insert wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid)
                                        select top 1 vipid,vipcardno,@cv,@cf,@remark,getdate(),'system',isnull(userpoints,0)+@changeValue,@lxid,0 from wx_t_vipinfo where vipcardno=@vipkh;";
                            str_sql += changeConsume + changeActivity + changeCharm;
                            break;
                    }
                    paras.Clear();
                    paras.Add(new SqlParameter("@cv", changeValue));
                    paras.Add(new SqlParameter("@cf", flag));
                    paras.Add(new SqlParameter("@remark", remark));
                    paras.Add(new SqlParameter("@changeValue", val));
                    paras.Add(new SqlParameter("@lxid", lxid));
                    paras.Add(new SqlParameter("@vipkh", vipkh));
                    errinfo = dal_62.ExecuteNonQuerySecurity(str_sql, paras);

                    if (errinfo == "")
                        clsSharedHelper.WriteSuccessedInfo("");
                    else
                        clsSharedHelper.WriteErrorInfo(errinfo);
                }
                else
                    clsSharedHelper.WriteErrorInfo("传入的积分类型有误!");
            }
            else
                clsSharedHelper.WriteErrorInfo("更新变动查询时失败 " + errinfo);
        }//end using
    }

    //同步某家门店的VIP积分记录
    public void SyncMDVIPPoints(string mdid)
    {
        int Success = 0, Fails = 0;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = "select kh from yx_t_vipkh where isnull(ty,0)=0 and mdid=@mdid";
            List<SqlParameter> paras = new List<SqlParameter>();
            DataTable dt = null;
            paras.Add(new SqlParameter("@mdid", mdid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        string rt = SyncVIPInfo(dt.Rows[i]["kh"].ToString());
                        if (rt.Contains("Error:"))
                            Fails++;
                        else if (rt.Contains("Successed"))
                            Success++;
                    }//end for
                    clsSharedHelper.WriteInfo("VIP总数：" + dt.Rows.Count.ToString() + " 成功：" + Success.ToString() + " 失败:" + Fails.ToString());
                }
                else
                    clsSharedHelper.WriteErrorInfo("该门店无VIP用户！");
            }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }
    }

    //同步计算更新积分
    public string SyncVIPInfo(string vipkh)
    {
        string rt = "";
        using (LiLanzDALForXLM dal_62 = new LiLanzDALForXLM(ChatProConnStr))
        {
            //公用变量
            string str_sql = "", errinfo = "";
            List<SqlParameter> paras = new List<SqlParameter>();
            StringBuilder sb_sql = new StringBuilder();

            str_sql = @"select top 1 a.id,isnull(a.mdid,0) mdid,isnull(b.userpoints,0) leftpoints,isnull(b.charmvalue,0) charmvalue,
                        case when isnull(b.synctime,'')='' then '1990-01-01'else convert(varchar(10),b.synctime,120) end synctime,
                        isnull(b.activitypoints,0) activitypoints,isnull(b.consumepoints,0) consumepoints
                        from yx_t_vipkh a 
                        left join wx_t_vipinfo b on a.kh=b.vipcardno
                        where isnull(a.ty,0)=0 and a.kh=ltrim(rtrim(@vipkh));";
            paras.Add(new SqlParameter("@vipkh", vipkh));
            DataTable dt = null, dt_ls = null, dt_dh = null;
            errinfo = dal_62.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string vipid = dt.Rows[0]["id"].ToString();
                    string mdid = dt.Rows[0]["mdid"].ToString();
                    string synctime = dt.Rows[0]["synctime"].ToString();
                    int leftPoints = Convert.ToInt32(dt.Rows[0]["leftpoints"].ToString());//剩余积分
                    int charmValue = Convert.ToInt32(dt.Rows[0]["charmvalue"].ToString());//魅力值
                    int activityPoints = Convert.ToInt32(dt.Rows[0]["activitypoints"].ToString());//活动积分
                    int consumePoints = Convert.ToInt32(dt.Rows[0]["consumepoints"].ToString());//消费积分
                    string lastBuyTime = "";

                    //查询零售数据
                    using (LiLanzDALForXLM dal_32 = new LiLanzDALForXLM(FXCXDBConStr))
                    {
                        str_sql = @"select a.id,a.vip,a.rq,round(a.sskje,0) jfs,
                                            case when a.djlb<0 then '商品退货' else '购买商品' end bz,
                                            case when a.djlb<0 then 3 else 2 end ptype,
                                            case when a.djlb<0 then -1 else 1 end flag
                                            from zmd_v_lsdjb a 
                                            where a.djbs=1 and a.vip=@vipkh and a.rq>=convert(varchar(10),@synctime,120) and a.rq<convert(varchar(10),getdate(),120)
                                            order by a.rq desc;";
                        paras.Clear();
                        paras.Add(new SqlParameter("@vipkh", vipkh));
                        paras.Add(new SqlParameter("@synctime", synctime));
                        errinfo = dal_32.ExecuteQuerySecurity(str_sql, paras, out dt_ls);
                        if (errinfo == "")
                        {
                            string rq, bz, ptype, flag, id;
                            int jfs;
                            for (int i = 0; i < dt_ls.Rows.Count; i++)
                            {
                                lastBuyTime = dt_ls.Rows[0]["rq"].ToString();
                                id = dt_ls.Rows[i]["id"].ToString();
                                rq = dt_ls.Rows[i]["rq"].ToString();
                                jfs = Convert.ToInt32(dt_ls.Rows[i]["jfs"]);
                                bz = dt_ls.Rows[i]["bz"].ToString();
                                ptype = dt_ls.Rows[i]["ptype"].ToString();
                                flag = dt_ls.Rows[i]["flag"].ToString();

                                int _cvs = Convert.ToInt32(flag) * Convert.ToInt32(jfs);
                                leftPoints += _cvs;
                                charmValue += _cvs;
                                consumePoints += _cvs;

                                sb_sql.AppendFormat(@"insert into wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid) 
                                                    values ({0},'{1}',{2},{3},'{4}','{5}','system',{6},{7},'{8}');", vipid, vipkh, jfs, flag, bz, rq, leftPoints, ptype, id);
                            }//end for

                            //查询积分兑换记录
                            //暂定积分兑换、赠送不影响魅力值，而且将其累积到活动积分中去
                            using (LiLanzDALForXLM dal_10 = new LiLanzDALForXLM(DBConStr))
                            {
                                str_sql = @"select a.id,a.kh vip,a.rq,
                                            case when a.dhjfs<0 then -1*a.dhjfs else a.dhjfs end jfs,
                                            case when a.jflx=1 then '积分兑换' else '积分赠送' end bz,
                                            case when a.jflx=1 then 4 when a.jflx=2 then 5 else 0 end ptype,
                                            case when a.dhjfs<0 then -1 else 1 end flag
                                            from zmd_t_xfjfdhb a
                                            where a.kh=@vipkh and a.rq>=convert(varchar(10),@synctime,120) and a.rq<convert(varchar(10),getdate(),120);";
                                paras.Clear();
                                paras.Add(new SqlParameter("@vipkh", vipkh));
                                paras.Add(new SqlParameter("@synctime", synctime));
                                errinfo = dal_10.ExecuteQuerySecurity(str_sql, paras, out dt_dh);

                                if (errinfo == "")
                                {
                                    for (int i = 0; i < dt_dh.Rows.Count; i++)
                                    {
                                        rq = dt_dh.Rows[i]["rq"].ToString();
                                        id = dt_ls.Rows[i]["id"].ToString();
                                        jfs = Convert.ToInt32(dt_dh.Rows[i]["jfs"]);
                                        bz = dt_dh.Rows[i]["bz"].ToString();
                                        ptype = dt_dh.Rows[i]["ptype"].ToString();
                                        flag = dt_dh.Rows[i]["flag"].ToString();

                                        int _cvs = Convert.ToInt32(flag) * Convert.ToInt32(jfs);
                                        leftPoints += _cvs;
                                        activityPoints += _cvs;
                                        sb_sql.AppendFormat(@"insert into wx_t_vippointrecords(vipid,vipcardno,changevalue,changeflag,remarks,eventtime,operator,leftpoints,pointtype,relateid) 
                                                    values ({0},'{1}',{2},{3},'{4}','{5}','system',{6},{7},'{8}');", vipid, vipkh, jfs, flag, bz, rq, leftPoints, ptype, id);
                                    }//end for                                    

                                    string titleID = "0";
                                    if (charmValue <= 0)
                                        titleID = "0";
                                    else if (charmValue <= 2000)
                                        titleID = "1";
                                    else if (charmValue <= 6000)
                                        titleID = "2";
                                    else if (charmValue <= 12000)
                                        titleID = "3";
                                    else if (charmValue <= 20000)
                                        titleID = "4";
                                    else if (charmValue <= 30000)
                                        titleID = "5";
                                    else if (charmValue <= 42000)
                                        titleID = "6";
                                    else
                                        titleID = "7";

                                    sb_sql.AppendFormat(@"if not exists(select top 1 1 from wx_t_vipinfo where vipid='{0}') 
                                    insert wx_t_vipinfo (vipid,vipcardno,consumepoints,activitypoints,userpoints,charmvalue,latestbuytime,viptitle,synctime,mdid)
                                    select '{0}','{1}',{2},{3},{4},{5},'{6}','{7}',getdate(),'{8}';", vipid, vipkh, consumePoints, activityPoints, leftPoints, charmValue, lastBuyTime, titleID, mdid);

                                    sb_sql.AppendFormat(@"else 
                                                            update a set a.consumepoints=b.cp,a.activitypoints=b.ap,a.userpoints=b.up,a.charmvalue=b.cv,a.latestbuytime=b.lbt,a.viptitle=b.vt,a.synctime=b.st,a.mdid=b.mdid
                                                            from wx_t_vipinfo a
                                                            inner join (select {0} cp,{1} ap,{2} up,{3} cv,'{4}' lbt,{5} vt,getdate() st,'{6}' mdid) b on 1=1
                                                            where a.vipcardno='{7}';", consumePoints, activityPoints, leftPoints, charmValue, lastBuyTime, titleID, mdid, vipkh);

                                    //加上事务
                                    string str_SQL = "BEGIN TRANSACTION " + sb_sql.ToString() + " COMMIT TRANSACTION GO ";

                                    errinfo = dal_62.ExecuteNonQuery(str_SQL);
                                    if (errinfo == "")
                                        rt = "Successed";
                                    else
                                        rt = "同步用户积分数据时出错【4】 " + errinfo;

                                    //释放资源
                                    DisposeDT(dt);
                                    DisposeDT(dt_ls);
                                    DisposeDT(dt_dh);
                                }
                                else
                                    rt = "同步用户积分数据时出错【3】 " + errinfo;
                            }
                        }
                        else
                            rt = "同步用户积分数据时出错【2】 " + errinfo;
                    }//end using
                }
                else
                    rt = "没有找到此VIP卡号信息！";
            }
            else
                rt = "同步用户积分数据时出错【1】 " + errinfo;
        }//end using

        return rt;
    }

    public void DisposeDT(DataTable dt)
    {
        if (dt != null)
        {
            dt.Dispose();
            dt = null;
        }
    }

    //获取衣服图片地址
    public void GetClothesPics(string sphh)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {

            string str_sql = @"SELECT picUrl+'|' FROM yx_t_goodPicInfo WHERE sphh=@sphh FOR xml path('') ";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sphh", sphh));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo != "")
            {
                clsSharedHelper.WriteInfo("查询货号对应图片时出错 " + errinfo);
                return;
            }
            if (dt.Rows.Count > 0)
            {
                clsSharedHelper.WriteInfo(dt.Rows[0][0].ToString());
                return;
            }

            str_sql = @"select t1.urladdress+'|' 
                                from yx_v_ypdmb a
                                left join yf_t_cpkfsjtg cy on (a.zlmxid>0 and a.zlmxid=cy.zlmxid and cy.tplx='cyzp' ) 
                                or (a.zlmxid=0 and cy.tplx='cgyptp' and a.yphh=cy.yphh)
                                left join t_uploadfile t1 on case when isnull(a.zlmxid,0)=0 then 1002 else 1003 end=t1.groupid
                                and case when isnull(a.zlmxid,0)=0 then isnull(cy.id,0) else isnull(a.zlmxid,0) end=t1.tableid
                                where a.tzid=1 and a.sphh=@sphh
                                for xml path('')";
            paras.Clear();
            paras.Add(new SqlParameter("@sphh", sphh));
            errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo != "")
            {
                clsSharedHelper.WriteInfo("查询货号对应图片时出错 " + errinfo);
                return;
            }
            if (dt.Rows.Count > 0)
            {
                clsSharedHelper.WriteInfo(dt.Rows[0][0].ToString());
            }
            else
                clsSharedHelper.WriteInfo("");
        }
    }

    //查询最近的消费记录
    public void LatestConsume(string vip)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXCXDBConStr))
        {
            string str_sql = @"select top 5 a.* from (
                                select a.id djid,a.djh,convert(varchar(19),a.rq,120) djsj,isnull(md.mdmc,'') mdmc,sum(je) djje 
                                from zmd_v_lsdjmx a
                                left join t_mdb md on md.mdid=a.mdid
                                where a.vip=@vipkh and a.djbs=1 and a.djlb>0
                                group by a.id,djh,convert(varchar(19),a.rq,120),isnull(md.mdmc,'')
                                ) a
                                order by a.djsj desc";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipkh", vip));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count == 0)
                    clsSharedHelper.WriteInfo("");
                else
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
            }
            else
                clsSharedHelper.WriteErrorInfo("查询最近消费记录时出错 " + errinfo);
        }
    }

    //查询消费单据详情
    public void ConsumeDetail(string djid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXCXDBConStr))
        {
            string str_sql = @"select a.sphh,cm.cm cmmc,a.dj,a.sl
                                from zmd_v_lsdjmx a
                                inner join yx_t_spdmb sp on a.sphh=sp.sphh
                                left join yx_t_cmzh cm on cm.tml=sp.tml and a.cmdm=cm.cmdm
                                where a.djbs=1 and a.djlb>0 and a.id=@djid and a.je<>0";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@djid", djid));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count == 0)
                    clsSharedHelper.WriteInfo("");
                else
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
            }
            else
                clsSharedHelper.WriteErrorInfo("查询消费详情时 " + errinfo);
        }
    }

    public void FilterDatav2(string mdid, string roleid, string salerid, string type)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = "";
            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
        }
    }

    private void FilterData()
    {
        /**客户id取session【tzid】确认后再修改**/
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string role = Convert.ToString(Request.Params["role"]);
        string salerid = Convert.ToString(Request.Params["salerid"]);
        string monsStr = Convert.ToString(Request.Params["mons"]);
        string bdaysStr = Convert.ToString(Request.Params["bdays"]);
        string splbStr = Convert.ToString(Request.Params["splb"]);
        string cname = Convert.ToString(Request.Params["cname"]);
        string lable = Convert.ToString(Request.Params["lable"]);
        string lableid = Convert.ToString(Request.Params["lableid"]);
        string bindvip = Convert.ToString(Request.Params["bindvip"]);
        Int32 pageNo, pageSize;

        salerid = Convert.ToString(Session["qy_customersid"]);//查看自己的id

        if (!Int32.TryParse(Request.Params["pageNo"], out pageNo))
        {
            clsSharedHelper.WriteErrorInfo("请输入正确的页码");
        }

        if (!Int32.TryParse(Request.Params["pageSize"], out pageSize))
        {
            clsSharedHelper.WriteErrorInfo("请输入加载行数");
        }

        if (pageNo == 0 || pageSize == 0) clsSharedHelper.WriteInfo("请输入页码及页面长度");

        string namefilter = "", lablefilte = "", lableidfilte = "";
        if (!string.IsNullOrEmpty(cname))
        {
            namefilter = " and t.xm like '%" + HttpUtility.UrlDecode(cname) + "%'";
        }
        if (!string.IsNullOrEmpty(lable))
        {
            lablefilte = @"inner join (SELECT distinct a.wxid FROM yx_t_UserTags a INNER JOIN yx_t_VIPTags b ON a.TagID=b.ID AND b.TagName LIKE '%" + HttpUtility.UrlDecode(lable) + @"%'
                        UNION  
                       SELECT distinct wxid FROM yx_t_UserTags WHERE TagID=0 AND selftags LIKE '%" + HttpUtility.UrlDecode(lable) + "%') lable on t.wxid=lable.wxid";
        }


        lableid = lableid.TrimStart('[').TrimEnd(']');
        if (lableid.Length > 0) lableidfilte = string.Format(" and t.wxid in (SELECT UserID FROM yx_t_UserTags where TagID in({0}))", lableid);


        if (string.IsNullOrEmpty(mdid) || mdid == "0")
            clsSharedHelper.WriteErrorInfo("缺少参数mdid！");
        else if (string.IsNullOrEmpty(role))
            clsSharedHelper.WriteErrorInfo("缺少参数role！");
        else if (string.IsNullOrEmpty(salerid))
            clsSharedHelper.WriteErrorInfo("缺少参数salerid！");

        //月份、天数、商品类别作为条件用拼接，所以转成数字，预防注入
        int mons = 0, bdays = -1, splb = 0, buyIn3Mon = 0;
        if (!string.IsNullOrEmpty(monsStr))
            if (!Int32.TryParse(monsStr, out mons))
            {
                if (monsStr == "m3") buyIn3Mon = 3;
                else
                    clsSharedHelper.WriteErrorInfo("参数有误,mons请输入月数");
            }

        if (!string.IsNullOrEmpty(bdaysStr))
            if (!Int32.TryParse(bdaysStr, out bdays))
                clsSharedHelper.WriteErrorInfo("参数有误,bdays请输入天数");
        if (!string.IsNullOrEmpty(splbStr))
            if (!Int32.TryParse(splbStr, out splb))
                clsSharedHelper.WriteErrorInfo("参数有误,splb请输入splbid值");

        if (bindvip == "false")
        {
            namefilter += " and t.kh=''";
        }

        string mysql = "SELECT khid  FROM dbo.t_mdb WHERE mdid=@mdid";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@mdid", mdid));
        string errInfo, khid = "0";
        DataTable dt, dt_rt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "") clsSharedHelper.WriteErrorInfo(errInfo);
            khid = Convert.ToString(dt.Rows[0]["khid"]);
            clsSharedHelper.DisponseDataTable(ref dt);
            //@roleid=2 OR wb.SalerID=@salerid roleid=2时为店长，可以看全店粉丝，roleid=1时为导购，只能看自己的粉丝
            dal.ConnectionString = ChatProConnStr;//相关数据在62微信库
            mysql = string.Format(@" select  t.*,wo.cname dgxm from (
            SELECT  a.vipid, ISNULL(c.kh,'') AS kh,case when a.wxsex=1 then '男' when a.wxsex=2 then '女' else '未知' end xb,ISNULL(c.xm,a.wxNick) AS xm,
                    a.wxNick AS  nick,CONVERT(VARCHAR(10),a.createtime,120) AS tbrq,isnull(a.wxheadimgurl,'') headimg,CASE WHEN a.vipid>0 THEN 'VIP-WX' else 'WX' END usertype, ISNULL(c.csrq,'1900-01-01') as birthday,
                    a.id as bid,isnull(b.cid,0) salerid,a.id as wxid,a.wxopenid
                    FROM wx_t_vipbinging a
                    LEFT JOIN dbo.wx_t_VipServerBind b ON a.id=b.wxID
					LEFT JOIN YX_T_Vipkh c ON a.vipID=c.id
                    WHERE a.ObjectID IN(1,4) and a.khid=@khid AND (@roleid=2 OR b.cid=@salerid)) t
                    left join wx_t_customers wo on wo.id=t.salerid
                     {1} where 1=1 {0} {2} order by t.vipid desc", namefilter, lablefilte, lableidfilte);
            //clsSharedHelper.WriteInfo(mysql);

            paras.Clear();
            paras.Add(new SqlParameter("@khid", khid));
            paras.Add(new SqlParameter("@roleid", role));
            paras.Add(new SqlParameter("@salerid", salerid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(errInfo);
            }

            DataTable dt_temp = null;
            List<string> list_mon = new List<string>();//查找几个月没有消费的vip 放在list_mon 中
            if (mons > 0)//有查询月份条件
            {
                dal.ConnectionString = CXConStr;//数据在零售查询库
                mysql = @"SELECT DISTINCT a.vip
                        FROM dbo.zmd_v_lsdjmx a 
                        WHERE a.mdid=@mdid AND vip<>'' AND sj>DATEADD(MONTH,-@months,GETDATE())";
                paras.Clear();
                paras.Add(new SqlParameter("@mdid", mdid));
                paras.Add(new SqlParameter("@months", mons));

                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt_temp);
                foreach (DataRow dr in dt_temp.Rows)
                {
                    list_mon.Add(dr[0].ToString());
                }
                clsSharedHelper.DisponseDataTable(ref dt_temp);
            }
            List<string> list_splb = new List<string>();//查找几个月没有消费的vip 放在list_splb 中
            if (splb > 0)//有查询商品列表条件
            {
                dal.ConnectionString = CXConStr;//数据在零售查询库
                mysql = @"SELECT DISTINCT a.vip
                            FROM dbo.zmd_v_lsdjmx a INNER JOIN dbo.YX_T_Spdmb b ON a.sphh=b.sphh AND b.splbid=@splbid
                            WHERE a.mdid=@mdid AND vip<>''";
                paras.Clear();
                paras.Add(new SqlParameter("@mdid", mdid));
                paras.Add(new SqlParameter("@splbid", splb));
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt_temp);
                foreach (DataRow dr in dt_temp.Rows)
                {
                    list_splb.Add(dr[0].ToString());
                }
                clsSharedHelper.DisponseDataTable(ref dt_temp);
            }

            List<string> list_buyIn3Mon = new List<string>();
            if (buyIn3Mon > 0)//最近有购买
            {
                dal.ConnectionString = CXConStr;//数据在零售查询库
                mysql = @"SELECT DISTINCT a.vip
                            FROM dbo.zmd_v_lsdjmx a 
                            WHERE a.mdid=@mdid AND vip<>'' and a.rq>DATEADD(MONTH,-3,GETDATE())  ";
                paras.Clear();
                paras.Add(new SqlParameter("@mdid", mdid));
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt_temp);
                foreach (DataRow dr in dt_temp.Rows)
                {
                    list_buyIn3Mon.Add(dr["vip"].ToString());
                }
                clsSharedHelper.DisponseDataTable(ref dt_temp);
            }

            //处理所有表数据
            DateTime today = DateTime.Now;
            DateTime birthday = DateTime.Now;
            dt_rt = dt.Clone();
            Boolean flag;
            foreach (DataRow dr in dt.Rows)
            {
                dr["nick"] = HttpUtility.UrlEncodeUnicode(Convert.ToString(dr["nick"]));
                flag = true;
                //1、几个月没无消费记录，有记录则删除
                if (Convert.ToString(dr["kh"]) != "" && list_mon.Contains(Convert.ToString(dr["kh"])))
                {
                    flag = false;
                }

                //2、有消费过此品类保留，无则删除
                if (flag && splb > 0 && !list_splb.Contains(Convert.ToString(dr["kh"])))
                {
                    flag = false;
                }

                //3、几天内生日，不在这几天内的去除
                if (flag && bdays >= 0)
                {
                    birthday = DateTime.Now;
                    birthday = birthday.AddMonths(Convert.ToDateTime(dr["birthday"]).Month - today.Month);
                    birthday = birthday.AddDays(Convert.ToDateTime(dr["birthday"]).Day - today.Day);
                    //  Response.Write("name:" + Convert.ToString(dr["xm"])+"birthday:"+birthday+"today:"+today+"</br>");
                    if ((birthday - today).Days > bdays || Convert.ToDateTime(dr["birthday"]).Year < 1901)
                    {
                        flag = false;
                    }
                }

                //4、近三个月有消费的保留，无消费则删除
                if (flag && buyIn3Mon > 0)
                {
                    if (Convert.ToString(dr["kh"]) == "" || list_buyIn3Mon.Contains(Convert.ToString(dr["kh"])) == false) flag = false;
                }

                if (flag)
                {
                    DataRow mydr = dt_rt.NewRow();
                    mydr.ItemArray = dr.ItemArray;
                    dt_rt.Rows.Add(mydr);
                }
            }
            clsSharedHelper.DisponseDataTable(ref dt);
        }//end using

        int startPage = (pageNo - 1) * pageSize;
        int endPage = pageNo * pageSize > dt_rt.Rows.Count ? dt_rt.Rows.Count : pageNo * pageSize;
        // DataTableToJson("rows", dt, startPage, endPage);

        Response.Write(DataTableToJson("rows", dt_rt, startPage, endPage));
        Response.End();
    }
    //统计VIP用户的消费偏好
    public void GetChartDatas(string uid, string kh, string type)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXCXDBConStr))
        {
            string str_sql = @"                             
                                select b.spmc,lb.mc splb,xl.mc fg,replace(substring(b.spmc+'-',charindex('-',b.spmc)+1,6),'-','') ys,a.id,a.je,a.sl,a.zks into #zb
                                from zmd_v_lsdjmx a
                                inner join yx_t_spdmb b on a.sphh=b.sphh
                                left join yx_t_splb lb on lb.id=b.splbid
                                left join t_xtdm xl on xl.ssid=401 and xl.dm=b.fg
                                where a.djbs=1 and a.djlb<10 and a.vip=@vipkh;";
            switch (type)
            {
                case "lb":
                    str_sql += "select top 10 a.* from (select splb label,sum(sl) sl from #zb group by splb) a order by sl desc;drop table #zb;";
                    break;
                case "xl":
                    str_sql += "select top 10 a.* from (select fg label,sum(sl) sl from #zb group by fg) a order by a.sl desc;drop table #zb;";
                    break;
                case "ys":
                    str_sql += "select top 10 a.* from (select ys label,sum(sl) sl from #zb group by ys) a order by a.sl desc ;drop table #zb;";
                    break;
                default:
                    str_sql += "drop table #zb;";
                    break;
            }
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipkh", kh));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    if (dt.Rows[0][0].ToString() == "0")
                        clsSharedHelper.WriteInfo("Warn:该用户暂时无消费记录！");
                    else
                    {
                        clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                    }
                }
                else
                    clsSharedHelper.WriteInfo("");
            }
            else
                clsSharedHelper.WriteErrorInfo("统计用户消费偏好时出错！" + errinfo + "|" + uid);
        }
    }

    /// <summary>
    /// 获取VIP的消费行为相关数据
    /// </summary>
    /// <param name="uid"></param>
    public void GetVIPBehavior(string uid, string vipkh)
    {
        //FXDBConStr
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(FXCXDBConStr))
        {
            string str_sql = @"                                
                                select a.rq,b.spmc,lb.mc splb,xl.mc fg,replace(substring(b.spmc+'-',charindex('-',b.spmc)+1,6),'-','') ys,a.id,a.je,a.sl,a.zks into #zb
                                from zmd_v_lsdjmx a
                                inner join yx_t_spdmb b on a.sphh=b.sphh
                                left join yx_t_splb lb on lb.id=b.splbid
                                left join t_xtdm xl on xl.ssid=401 and xl.dm=b.fg
                                where a.djbs=1 and a.djlb<10 and a.vip=@vipkh 

                                select count(distinct a.id) gmcs,sum(a.je)/sum(sl) pjdj,sum(sl)/count(distinct a.id) pjdl,sum(a.zks)/count(1) pjzks,
                                (select distinct splb+',' from #zb for xml path('')) pl,
                                (select distinct fg+',' from #zb for xml path('')) fg,
                                (select distinct ys+',' from #zb for xml path('')) ys,sum(a.je) xfje,
                                (select top 1 lastje from (select sum(je) lastje,rq from #zb group by rq) a order by rq desc) lastje,
                                (select convert(varchar(10),max(rq),120) from #zb) lastsj,datediff(day,max(rq),getdate()) dists
                                from #zb a                                
                                drop table #zb;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipkh", vipkh));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                if (dt.Rows[0][0].ToString() == "0")
                    clsSharedHelper.WriteInfo("Warn:该用户暂时无消费记录！");
                else
                {
                    clsSharedHelper.WriteInfo(dt.Rows[0]["gmcs"].ToString() + "|" + dt.Rows[0]["pjdj"].ToString() + "|" + dt.Rows[0]["pjdl"].ToString() + "|" + dt.Rows[0]["pjzks"].ToString() + "|" + dt.Rows[0]["pl"].ToString() + "|" + dt.Rows[0]["fg"].ToString() + "|" + dt.Rows[0]["ys"].ToString() + "|" + dt.Rows[0]["xfje"].ToString() + "|" + dt.Rows[0]["lastje"].ToString() + "|" + dt.Rows[0]["lastsj"].ToString() + "|" + dt.Rows[0]["dists"].ToString());
                }
            }
            else
                clsSharedHelper.WriteErrorInfo("查询用户消费行为时出错！ " + errinfo);
        }
    }


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

    /// <summary>
    /// 获取用户详细信息
    /// </summary>
    /// <param name="uid"></param>
    public void GetUserInfo(string wxid)
    {
        string userinfo = @"{{
                                ""username"": ""{0}"", 
                                ""yddh"": ""{1}"",
                                ""klb"":""{2}"",
                                ""qcjf"":""{3}"",
                                ""headimg"":""{4}"",
                                ""sex"":""{5}"",                                
                                ""csrq"":""{6}"",
                                ""nl"":""{7}"",
                                ""jdrq"":""{8}"",
                                ""vipkh"":""{9}"",
                                ""kkdp"":""{10}"",
                                ""lxdz"":""{11}"",
                                ""mlz"":""{12}"",
                                ""viptitle"":""{13}"",
                                ""wxid"":""{14}"",
                                ""wxopenid"":""{15}""
                             }}";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = @"SELECT b.id vipid,b.xm,b.yddh,c.mc klb,isnull(vip.userpoints,0) qcjf,'' headimg,case when convert(varchar(1),a.wxSex)=1 then '男' else '女' end sex,
                                convert(varchar(10),csrq,120) csrq,datediff(yyyy,csrq,getdate()) nl,convert(varchar(10),b.jdrq,120) jdrq,b.kh vipkh,kh.khmc,b.zzdz,
                                isnull(vip.charmvalue,0) mlz,isnull(t.titlename,'') viptitle,a.id AS wxid ,a.wxopenid 
FROM dbo.wx_t_vipBinging a 
inner JOIN yx_t_vipkh b ON a.vipID=b.id
LEFT join yx_T_khb kh ON b.khid=kh.khid
left join yx_t_viplb c ON b.klb=c.Dm
left join wx_t_vipinfo vip on vip.vipid=b.id
left join wx_t_viptitle t on t.id=vip.viptitle
where a.id=@wxid";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@wxid", wxid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string userPoints = GetUserPoints(Convert.ToString(dt.Rows[0]["vipid"]));
                    userinfo = string.Format(userinfo, dt.Rows[0]["xm"].ToString(), dt.Rows[0]["yddh"].ToString(), dt.Rows[0]["klb"].ToString(),
                        userPoints, dt.Rows[0]["headimg"].ToString(), dt.Rows[0]["sex"].ToString(), dt.Rows[0]["csrq"].ToString(),
                        dt.Rows[0]["nl"].ToString(), dt.Rows[0]["jdrq"].ToString(), dt.Rows[0]["vipkh"].ToString(), dt.Rows[0]["khmc"].ToString(), dt.Rows[0]["zzdz"].ToString(),
                        dt.Rows[0]["mlz"].ToString(), dt.Rows[0]["viptitle"].ToString(), dt.Rows[0]["wxid"].ToString(), dt.Rows[0]["wxopenid"].ToString());
                    clsSharedHelper.WriteInfo(userinfo);
                }
                else
                    clsSharedHelper.WriteErrorInfo("找不到该用户信息！");
            }
            else
                clsSharedHelper.WriteErrorInfo("GetUserInfo error:" + errinfo);
        }
    }

    //获取标签模板
    public void GetTagTemplate()
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            string str_sql = @"select a.id,a.tagname,b.id gid,b.groupname 
                                from yx_t_VIPTags a
                                inner join yx_t_viptaggroup b on a.taggroupid=b.id
                                where a.isactive=1 and b.isactive=1
                                order by b.id";
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(str_sql, out dt);
            if (errinfo == "")
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                else
                    clsSharedHelper.WriteErrorInfo("无用户标签模板数据！");
            else
                clsSharedHelper.WriteErrorInfo("加载用户标签模板时出错：" + errinfo);
        }
    }

    //获取用户标签数据
    public void GetUserTags(string wxid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            //string str_sql = "select cast(tagid as varchar)+',' from yx_t_UserTags where userid=@uid for xml path('')";
            string rt = "";
            string str_sql = @"select isnull((select cast(tagid as varchar)+',' from yx_t_UserTags where wxid=@wxid and tagid<>0 for xml path('')),'')+'||'";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@wxid", wxid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo != "")
                clsSharedHelper.WriteErrorInfo("加载用户标签时出错：" + errinfo);
            if (dt.Rows.Count > 0)
                rt = dt.Rows[0][0].ToString();
            clsSharedHelper.DisponseDataTable(ref dt);

            str_sql = "select selftags from yx_t_UserTags where wxid=@wxid and tagid=0 ";
            paras.Clear();
            paras.Add(new SqlParameter("@wxid", wxid));
            errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo != "")
                clsSharedHelper.WriteErrorInfo("加载用户自定义标签时出错：" + errinfo);
            if (dt.Rows.Count > 0)
                rt = string.Concat(rt, HttpUtility.UrlEncode(Convert.ToString(dt.Rows[0]["selftags"])));
            clsSharedHelper.WriteInfo(rt);
        }
    }

    //更新用户标签
    public void UpUserTags(string jsondata)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
        {
            JObject jo = JObject.Parse(jsondata);
            string wxid = Convert.ToString(jo["wxid"]);
            string wxopenid = Convert.ToString(jo["wxopenid"]);
            string type = Convert.ToString(jo["type"]);
            string data = Convert.ToString(jo["data"]);
            if (type == "delete")
            {
                string sql = string.Format("delete from yx_t_UserTags where wxid='{0}';", wxid);
                string errinfo = dal.ExecuteNonQuery(sql);
                if (errinfo == "")
                    clsSharedHelper.WriteInfo("");
                else
                    clsSharedHelper.WriteErrorInfo("提交失败 " + errinfo);
            }
            else if (type == "update")
            {
                string remark = HttpUtility.UrlDecode(Convert.ToString(jo["remark"]));
                string sql = string.Format("delete from yx_t_UserTags where wxid='{0}';", wxid);
                if (data != "")
                {
                    JArray ja = (JArray)jo["data"];
                    for (int i = 0; i < ja.Count; i++)
                    {
                        sql += string.Format(@"insert into yx_t_UserTags(tagid,wxid,openid) values ('{0}','{1}','{2}');", ja[i].ToString(), wxid, wxopenid);
                    }//end for
                }

                sql += string.Format(@"insert into yx_t_UserTags(tagid,selftags,wxid,openid) values (0,@remark,'{0}','{1}');", wxid, wxopenid);
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@remark", remark.Replace("\r\n", " ").Replace("'", " ")));

                string errinfo = dal.ExecuteNonQuerySecurity(sql, paras);
                if (errinfo == "")
                    clsSharedHelper.WriteInfo("");
                else
                    clsSharedHelper.WriteErrorInfo("提交失败 " + errinfo);
            }
        }
    }

    //计算VIP的积分
    public string GetUserPoints(string vipid)
    {
        using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConStr))
        {
            List<SqlParameter> paras = new List<SqlParameter>();
            string str_sql0 = @"DECLARE @kh VARCHAR(30),
				                            @khid INT,
				                            @DBName VARCHAR(30),
				                            @vipbs VARCHAR(6)

                            SELECT @kh = '',@khid=0,@vipbs = '';

                            SELECT TOP 1 @kh = kh,@khid = khid FROM yx_t_vipkh WHERE ID = @vipid
                            IF (@khid > 0)	SELECT TOP 1 @DBName=DBName,@vipbs = vipbs FROM yx_t_khb WHERE khid = @khid

                            SELECT @kh kh,@DBName DBName,@vipbs vipbs";

            paras.Add(new SqlParameter("@vipid", vipid));
            DataTable dt = null;
            string errinfo = dal10.ExecuteQuerySecurity(str_sql0, paras, out dt);
            if (errinfo != "")
            {
                clsLocalLoger.WriteError(string.Format("获取VIP（ID:{0}）的基础信息失败！错误：{1}", vipid, errinfo));
                return "暂不可查";
            }
            else
            {
                string kh = Convert.ToString(dt.Rows[0]["kh"]);
                string DBName = Convert.ToString(dt.Rows[0]["DBName"]).ToUpper();
                string vipbs = Convert.ToString(dt.Rows[0]["vipbs"]);
                dt.Clear(); dt.Dispose();

                string str_sql;
                Object scalar;
                if (vipbs == "new")     //如果是新积分体系，则走新积分体系的查询（这个逻辑尚未测试到）
                {
                    DBName = DBConStr;
                    str_sql = @"SELECT TOP 1 isnull(points,0) points from yx_v_VipPoints where vipid=@vipid";
                    paras.Clear();
                    paras.Add(new SqlParameter("@vipid", vipid));
                }
                else
                {
                    if (DBName == "FXDB") DBName = clsConfig.GetConfigValue("FXConStr");
                    else DBName = DBName = clsConfig.GetConfigValue("ERPConStr");

                    str_sql = @" SELECT  SUM(jfs) points
                                            FROM    ( SELECT    -SUM(CASE WHEN ISNULL(a.jfbs, 0) = 0
                                                                          THEN CASE WHEN ISNULL(a.xfjf, 0) = 0
                                                                                    THEN a.Yskje * b.Kc
                                                                                    ELSE a.xfjf * b.Kc
                                                                               END
                                                                          ELSE 0
                                                                     END) AS jfs
                                                      FROM      Zmd_T_Lsdjb a
                                                                INNER JOIN T_Djlb b ON a.Djlb = b.Dm
                                                                INNER JOIN yx_t_khb kh ON a.Vip = @kh
                                                                                          AND a.khid = kh.khid
                                                                                          AND a.Rq >= kh.jfqyrq
                                                      WHERE     a.Djbs = 1
                                                                AND a.Djlb < 10
                                                      UNION ALL
                                                      SELECT    SUM(a.dhjfs)
                                                      FROM      zmd_t_xfjfdhb a
                                                                INNER JOIN yx_t_khb kh ON a.khid = kh.khid
                                                                                          AND a.rq >= kh.jfqyrq
                                                                                          AND a.kh = @kh
                                                      UNION ALL
                                                      SELECT    qcjf
                                                      FROM      YX_T_Vipkh
                                                      WHERE     id = @vipid  
                                                    ) a";
                    paras.Clear();
                    paras.Add(new SqlParameter("@kh", kh));
                    paras.Add(new SqlParameter("@vipid", vipid));
                }

                using (LiLanzDALForXLM dalDB = new LiLanzDALForXLM(DBName))
                {
                    errinfo = dalDB.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                    if (errinfo == "")
                    {
                        string rt = Convert.ToString(scalar) == "" ? "0" : Convert.ToString(scalar);
                        Session["userpoint"] = rt;
                        return rt;
                    }
                    else
                    {
                        clsLocalLoger.WriteError(string.Format("获取VIP（ID:{0}）的积分失败！错误：{1}", vipid, errinfo));
                        return "暂不可查";
                    }
                }
            }
        }
    }

    public void printDataTable(DataTable dt)
    {
        string printStr = "";
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    if (dt.Rows[i][j] == null)
                        printStr += "null&nbsp;";
                    else
                        printStr += dt.Rows[i][j].ToString() + "&nbsp;";
                }
                printStr += "<br />";
            }
            Response.Write(printStr);
            Response.End();
        }
    }
    public string DataTableToJson(DataTable dt)
    {
        return DataTableToJson("rows", dt, 0, dt.Rows.Count, true);
    }

    public string DataTableToJson(string jsonName, DataTable dt)
    {
        return DataTableToJson(jsonName, dt, 0, dt.Rows.Count, true);
    }

    public string DataTableToJson(string jsonName, DataTable dt, int startRow, int endRow)
    {
        string rt = @"{{""totalRows"":{0},""{1}"":{2}}}";
        string json = DataTableToJson("", dt, startRow, endRow, false);
        if (string.IsNullOrEmpty(jsonName)) jsonName = "rows";
        rt = string.Format(rt, dt.Rows.Count, jsonName, json);
        return rt;
    }
    public string DataTableToJson(string jsonName, DataTable dt, int startRow, int endRow, Boolean isShowName)
    {
        StringBuilder Json = new StringBuilder();
        if (isShowName && string.IsNullOrEmpty(jsonName)) jsonName = "rows";
        if (isShowName) Json.Append("{\"" + jsonName + "\":");
        Json.Append("[");
        if (dt.Rows.Count > 0)
        {
            for (int i = startRow; i < endRow; i++)
            {
                Json.Append("{");
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    Json.Append("\"" + dt.Columns[j].ColumnName.ToString() + "\":\"" + dt.Rows[i][j].ToString() + "\"");
                    if (j < dt.Columns.Count - 1)
                    {
                        Json.Append(",");
                    }
                }
                Json.Append("}");
                if (i < endRow - 1)
                {
                    Json.Append(",");
                }
            }
        }
        Json.Append("]");
        if (isShowName) Json.Append("}");
        return Json.ToString();
    }

</script>
<!DOCTYPE html>
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
