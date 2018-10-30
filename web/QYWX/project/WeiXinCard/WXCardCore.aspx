<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Newtonsoft.Json"%>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<!DOCTYPE html>
<script runat="server">
    private string WXDBConstr = "", OAConnStr = "";
    private string ConfigKey = "5";//利郎男装

    protected void Page_Load(object sender, EventArgs e)
    {
        if(clsConfig.Contains("WXConnStr"))
            WXDBConstr = clsConfig.GetConfigValue("WXConnStr");
        else
            WXDBConstr = System.Configuration.ConfigurationManager.ConnectionStrings["WXDBConnStr"].ConnectionString;

        //测试模式下
        //WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";

        OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "CreateQRcode":
                string id = Convert.ToString(Request.Params["id"]);
                string userid = Convert.ToString(Request.Params["userid"]);
                string mdid = Convert.ToString(Request.Params["mdid"]);
                if (id == "" || id == "0" || id == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数ID是否有误！");
                else if (userid == "" || userid == "0" || userid == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数USERID是否有误！");
                else if (mdid == "" || mdid == "0" || mdid == null)
                    clsSharedHelper.WriteErrorInfo("请检查传入的参数MDID是否有误");
                else
                    clsSharedHelper.WriteInfo(CreateQRcode(id, userid, mdid));
                break;
            case "Send2VIP":
                id = Convert.ToString(Request.Params["id"]);
                userid = Convert.ToString(Request.Params["userid"]);
                mdid = Convert.ToString(Request.Params["mdid"]);
                string openid = Convert.ToString(Request.Params["openid"]);
                if (id == "" || id == "0" || id == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数ID是否有误！");
                else if (userid == "" || userid == "0" || userid == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数USERID是否有误！");
                else if (mdid == "" || mdid == "0" || mdid == null)
                    clsSharedHelper.WriteErrorInfo("请检查传入的参数MDID是否有误！");
                else if (openid == "" || openid == null)
                    clsSharedHelper.WriteErrorInfo("请检查传入的参数OPENID是否有误！");
                else
                    Send2VIP(id, userid, mdid, openid, Convert.ToString(Request.Params["username"]));
                break;
            case "UserGetTicket":
                string ticket = Convert.ToString(Request.Params["ticket"]);
                UserGetTicket(ticket);
                break;
            case "LoadCardList":
                mdid = Convert.ToString(Request.Params["mdid"]);
                if (mdid == "" || mdid == "0" || mdid == null)
                    clsSharedHelper.WriteErrorInfo("请检查传入的参数MDID是否有误");
                else
                    LoadCardList(mdid);
                break;
            case "GetCardDetail":
                id = Convert.ToString(Request.Params["id"]);
                if (id == "" || id == "0" || id == null)
                    clsSharedHelper.WriteErrorInfo("请检查传入的参数ID是否有误！");
                else
                    GetCardDetail(id);
                break;
            case "LoadVipList":
                userid = Convert.ToString(Request.Params["customerid"]);
                mdid = Convert.ToString(Request.Params["mdid"]);
                string roleName = Convert.ToString(Request.Params["roleName"]);
                if (userid == "" || userid == "0" || userid == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数CUSTOMERID是否有误！");
                else
                    LoadVipList(userid, roleName, mdid);
                break;
            case "CardEvent":
                CardEventFunc(Convert.ToString(Request.Params[1]));
                break;
            case "doSendCard2VIP":
                openid = Convert.ToString(Request.Params["openid"]);
                string cardid = Convert.ToString(Request.Params["cardid"]);
                string vipid = Convert.ToString(Request.Params["vipid"]);
                string objectid = Convert.ToString(Request.Params["objectid"]);

                if (!string.IsNullOrEmpty(openid))
                    //clsSharedHelper.WriteInfo(doSendCard2VIP(openid, cardid));
                    clsSharedHelper.WriteInfo(clsWXHelper.doSendCard2VIP(openid, cardid));
                else
                    //clsSharedHelper.WriteInfo(doSendCard2VIP(vipid, objectid, cardid));
                    clsSharedHelper.WriteInfo(clsWXHelper.doSendCard2VIP(vipid, objectid, cardid));
                break;
            case "getStoreVIPList":
                string khid = Convert.ToString(Request.Params["khid"]);
                cardid = Convert.ToString(Request.Params["cardid"]);
                if (string.IsNullOrEmpty(cardid))
                    //getStoreVIPList(khid);
                    clsWXHelper.getStoreVIPList(khid);
                else
                    //getStoreVIPList(khid, cardid);
                    clsWXHelper.getStoreVIPList(khid, cardid);
                break;
            case "couponlist":
                couponList();
                break;
            default:
                clsSharedHelper.WriteErrorInfo("请检查传入的CTRL是否有效！");
                break;
        }
    }

    //可用卡券信息 提供商城调用 创建卡券,目前写死使用长兴路轻商务门店
    private void couponList()
    {
        Dictionary<string, object> rtobj = new Dictionary<string, object>();
        string rtstr;
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr))
        {
            DataTable dt;
            int code = 200;
            object info;
            string errInfo = dal62.ExecuteQuery("SELECT TOP 100 id,Title, TotalQuantity,  CONVERT(VARCHAR(10),BeginTimestamp,23) BeginTimestamp,CONVERT(VARCHAR(10),EndTimestamp,23) EndTimestamp FROM dbo.wx_t_CardInfos WHERE khid=18090 AND shbs=1 AND EndTimestamp>GETDATE() ORDER BY id DESC", out dt);
            if (errInfo == "")
            {
                info = dt;
            }
            else
            {
                code = 400;
                info = "";
            }
            rtobj.Add("code",code);
            rtobj.Add("info",info);
            rtobj.Add("errmsg",errInfo);
            rtstr = JsonConvert.SerializeObject(rtobj);
            clsSharedHelper.DisponseDataTable(ref dt);
        }
        clsSharedHelper.WriteInfo(rtstr);
    }

    //卡券事件处理函数 利郎男装接口页转发数据过来
    public void CardEventFunc(string xmlStr)
    {
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr))
        {
            XmlDocument px = new XmlDocument();
            px.LoadXml(xmlStr);
            string eventType = px.GetElementsByTagName("Event")[0].InnerText;
            string cardid = px.GetElementsByTagName("CardId")[0].InnerText;
            string cardcode = px.GetElementsByTagName("UserCardCode")[0].InnerText;
            string getusername = px.GetElementsByTagName("FromUserName")[0].InnerText;
            string str_sql = "", errinfo = "";
            List<SqlParameter> paras = new List<SqlParameter>();
            switch (eventType)
            {
                case "card_pass_check"://卡券审核通过事件
                    str_sql = string.Format("update wx_t_cardinfos set cardstatus='CARD_STATUS_VERIFY_OK',wxchecktime=getdate() where cardid={0};", cardid);
                    break;
                case "card_not_pass_check"://卡券审核未通过事件         
                    str_sql = string.Format("update wx_t_cardinfos set cardstatus='CARD_STATUS_VERIFY_FAIL',wxchecktime=getdate() where cardid={0};", cardid);
                    break;
                case "user_get_card"://用户领取卡券事件                    
                    string isgiven = px.GetElementsByTagName("IsGiveByFriend")[0].InnerText;
                    string olduser = px.GetElementsByTagName("FriendUserName")[0].InnerText;
                    string oldcode = px.GetElementsByTagName("OldUserCardCode")[0].InnerText;
                    string outerid = px.GetElementsByTagName("OuterId")[0].InnerText;
                    str_sql = @"  if not exists(select top 1 1 from wx_t_CardCodes where cardid=@cardid and cardcode=@cardcode)                                     
                                    insert into wx_t_CardCodes(cardid,cardcode,isget,getuser,outerid,gettime,isconsume,usercardstatus,canconsume,IsGiveByFriend,FriendUserName,oldusercardcode)
                                    values(@cardid,@cardcode,1,@getuser,@outerid,getdate(),0,'NORMAL',1,@isgiven,@olduser,@oldcode);                                                                        
                                  if @isgiven='1'
                                    update wx_t_CardCodes set usercardstatus='GIFT_SUCC',canconsume=0 where cardid=@cardid and cardcode=@oldcode;";
                    paras.Add(new SqlParameter("@cardid", cardid));
                    paras.Add(new SqlParameter("@cardcode", cardcode));
                    paras.Add(new SqlParameter("@getuser", getusername));
                    paras.Add(new SqlParameter("@outerid", outerid));
                    paras.Add(new SqlParameter("@isgiven", isgiven));
                    paras.Add(new SqlParameter("@olduser", olduser));
                    paras.Add(new SqlParameter("@oldcode", oldcode));
                    break;
                case "user_del_card"://用户删除事件                    
                    str_sql = @"if exists (select top 1 1 from wx_t_CardCodes where cardid=@cardid and cardcode=@cardcode)                                
                                    update wx_t_CardCodes set IsRemoveByUser=1,UserRemoveTime=getdate(),UserCardStatus='DELETE',canconsume=0 
                                    where cardid=@cardid and cardcode=@cardcode;                                
                                else
                                    insert into wx_t_CardCodes(cardid,cardcode,isget,getuser,gettime,isconsume,usercardstatus,canconsume)
                                    values(@cardid,@cardcode,1,@getuser,getdate(),0,'DELETE',0)";
                    paras.Add(new SqlParameter("@cardid", cardid));
                    paras.Add(new SqlParameter("@cardcode", cardcode));
                    paras.Add(new SqlParameter("@getuser", getusername));
                    break;
                case "user_consume_card"://核销事件                    
                    string source = px.GetElementsByTagName("ConsumeSource")[0].InnerText;
                    string location = px.GetElementsByTagName("LocationName")[0].InnerText;
                    string staff = px.GetElementsByTagName("StaffOpenId")[0].InnerText;
                    str_sql = @" if exists (select top 1 1 from wx_t_CardCodes where cardid=@cardid and cardcode=@cardcode)
                                    update wx_t_CardCodes set isconsume=1,consumesource=@source,consumetime=getdate(),locationname=@location,
                                    staffopenid=@staff,UserCardStatus='CONSUMED',canconsume=0 where cardid=@cardid and cardcode=@cardcode;
                                else
                                    insert into wx_t_CardCodes(cardid,cardcode,isget,getuser,gettime,isconsume,usercardstatus,canconsume)
                                    values(@cardid,@cardcode,1,@getuser,getdate(),1,'CONSUMED',0)";
                    paras.Add(new SqlParameter("@cardid", cardid));
                    paras.Add(new SqlParameter("@cardcode", cardcode));
                    paras.Add(new SqlParameter("@source", source));
                    paras.Add(new SqlParameter("@location", location));
                    paras.Add(new SqlParameter("@staff", staff));
                    paras.Add(new SqlParameter("@getuser", getusername));
                    break;
                case "user_pay_from_pay_cell"://买单事件                
                    break;
                case "user_view_card"://进入会员卡事件                
                    break;
                case "user_enter_session_from_card"://从卡券进入公众号事件                
                    break;
                case "update_member_card"://会员卡内容更新事件
                    break;
                case "card_sku_remind"://库存报警事件                
                    break;
                default:
                    WriteLog("卡券未知事件！");
                    break;
            }

            //执行SQL
            if (str_sql != "")
            {
                if (paras.Count == 0)
                    errinfo = dal62.ExecuteNonQuery(str_sql);
                else
                    errinfo = dal62.ExecuteNonQuerySecurity(str_sql, paras);

                if (errinfo == "") {
                    WriteLog("卡券事件推送【CardEventFunc】:" + xmlStr);
                    //WriteLog("卡券事件推送 结果处理成功！TYPE:" + eventType + " CARDID:" + cardid + " CARD_CODE:" + cardcode + " SQL:" + str_sql);
                }
                else
                    WriteLog("卡券事件推送 结果处理失败！INFOS:" + errinfo + " TYPE:" + eventType + " CARDID:" + cardid + " CARD_CODE:" + cardcode + eventType + " SQL:" + str_sql);
            }//end execute sql
        }//end using
    }

    //加载VIP用户列表
    //如果是店长身份则列出本店的所有VIP客户 roleName="dz"
    public void LoadVipList(string customerid,string roleName,string mdid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM("server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion"))
        {
            string str_sql = "";
            if (roleName == "dz")
                str_sql = @"declare @khid int;
                            select top 1 @khid=isnull(khid,0) from [192.168.35.10].tlsoft.dbo.t_mdb where mdid=@mdid                            
                            select vip.kh,vip.xm,wx.wxnick,wx.wxheadimgurl headimg,wx.wxopenid openid,isnull(u.cname,'') dgname
                            from yx_t_vipkh vip
                            inner join wx_t_vipbinging wx on vip.id=wx.vipid and wx.wxopenid<>'' and wx.objectid=1
                            left join wx_t_vipsalerbind s on s.openid=wx.wxopenid
                            left join wx_t_appauthorized au on au.systemkey=s.salerid and au.systemid=3
                            left join wx_t_customers u on u.id=au.userid
                            where vip.khid=@khid and vip.ty=0";
            else
                str_sql = @"select vip.kh,vip.xm,wx.wxnick,wx.wxheadimgurl headimg,b.openid,'' dgname
                            from wx_t_appauthorized a
                            inner join wx_t_vipsalerbind b on a.systemkey=b.salerid
                            inner join wx_t_vipbinging wx on wx.wxopenid=b.openid and wx.objectid=1
                            inner join yx_t_vipkh vip on vip.id=wx.vipid
                            where a.systemid=3 and b.openid<>'' and a.userid=@customerid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@customerid", customerid));
            paras.Add(new SqlParameter("@mdid", mdid));
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
                if (dt.Rows.Count > 0)
                {
                    dt = ConvertHeadimgURL(dt);
                    string jsonStr = JsonHelp.dataset2json(dt);
                    dt.Clear(); dt.Dispose();
                    clsSharedHelper.WriteInfo(jsonStr);
                }
                else
                    clsSharedHelper.WriteInfo("");
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }//end using
    }

    //加载卡券列表
    public void LoadCardList(string mdid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string str_sql = @"select b.id,b.title,b.subtitle,a.stock,convert(varchar(10),b.begintimestamp,120) ksrq,b.color,
                                convert(varchar(10),b.endtimestamp,120) jsrq,b.configkey,
                                case when b.localcardtype='LILANZ_CASH' then '抵用券' when b.localcardtype='LILANZ_DISCOUNT' then '折扣券' else '' end typename,
                                isnull(i.configname,'--') configname
                                from wx_t_CardDistribute a
                                inner join wx_t_cardinfos b on a.cid=b.id
                                left join wx_t_tokenconfiginfo i on i.configkey=b.configkey
                                where  b.shbs=1 and a.mdid=@mdid and a.stock>0 and getdate()<=b.endtimestamp and b.isdel=0
                                order by a.createtime desc";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@mdid", mdid));
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
                if (dt.Rows.Count == 0)
                    clsSharedHelper.WriteInfo("");
                else {
                    string jsonStr = JsonHelp.dataset2json(dt);
                    dt.Clear(); dt.Dispose();
                    clsSharedHelper.WriteInfo(jsonStr);
                }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }
    }

    //加载卡券详情
    public void GetCardDetail(string tableid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string str_sql = @"select top 1 title,subtitle,convert(varchar(10),begintimestamp,120) ksrq,convert(varchar(10),endtimestamp,120) jsrq,
                                defaultdetail detail,getlimit,notice,[description],servicephone,
                                case when cangivefriend=1 then 'check' else '' end cangive,
                                case when canshare=1 then 'check' else '' end canshare,localdiscount,leastcost,reducecost,localcardtype
                                from wx_t_cardinfos 
                                where id=@id";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@id", tableid));
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
                if (dt.Rows.Count == 0)
                    clsSharedHelper.WriteInfo("");
                else {
                    for (int i = 0; i < dt.Rows.Count; i++) {
                        dt.Rows[i]["description"] = Convert.ToString(dt.Rows[i]["description"]).Replace("\r", " ").Replace("\n", " ");
                        dt.Rows[i]["detail"] = Convert.ToString(dt.Rows[i]["detail"]).Replace("\r", " ").Replace("\n", " ");
                    }

                    string jsonStr = JsonHelp.dataset2json(dt);
                    dt.Clear(); dt.Dispose();
                    clsSharedHelper.WriteInfo(jsonStr);
                }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }
    }

    //用户立即领取卡券 更新标识
    public void UserGetTicket(string ticket)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string str_sql = @"update wx_t_CardRelation set isget=1,gettime=getdate() where ticket=@ticket and isget=0;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@ticket", ticket));
            string errinfo = dal.ExecuteNonQuerySecurity(str_sql, paras);
            if (errinfo == "")
                clsSharedHelper.WriteSuccessedInfo("");
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }
    }

    public string CreateQRcode(string cid, string userid, string mdid)
    {
        string msg = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string ticket = System.Guid.NewGuid().ToString();
            string str_sql = @" declare @ticket varchar(500);
                                if exists (select top 1 1 from wx_t_cardinfos where id=@id)
                                begin
                                  select @ticket=ticket from wx_t_CardRelation where createrid=@customerid and cardid=@id and isbind=0 and isget=0;
                                  if isnull(@ticket,'')=''
                                  begin
                                    if exists (select top 1 1 from wx_t_CardDistribute where cid=@id and mdid=@mdid and stock>0)
                                    begin
                                      insert wx_t_CardRelation(ticket,khid,mdid,cardid,cardcode,openid,createrid,isbind,isget,gettime)
                                      select top 1 @guid,khid,mdid,cid,cardid,'',@customerid,0,0,'' from wx_t_CardDistribute where cid=@id and mdid=@mdid;                                      
                                      select '11';
                                    end
                                    else
                                      select '01';
                                  end
                                  else
                                    select '10',@ticket;
                                end
                                else
                                  select '00'";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@id", cid));
            paras.Add(new SqlParameter("@guid", ticket));
            paras.Add(new SqlParameter("@customerid", userid));
            paras.Add(new SqlParameter("@mdid", mdid));
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                string rt = Convert.ToString(dt.Rows[0][0]);
                if (rt == "00")
                    msg = "Error:生成失败，请检查当前卡券的有效性！";
                //clsSharedHelper.WriteErrorInfo("生成失败，请检查当前卡券的有效性！");
                else if (rt == "01")
                    msg = "Error:生成失败，当前卡券库存不足！";
                //clsSharedHelper.WriteErrorInfo("生成失败，当前卡券库存不足！");
                else if (rt == "10")
                    msg = "Warn:" + Convert.ToString(dt.Rows[0][1]);
                //clsSharedHelper.WriteInfo("Warn:" + Convert.ToString(dt.Rows[0][1]));
                else
                    msg = "Successed" + ticket;
                //clsSharedHelper.WriteSuccessedInfo(ticket);
            }
            else
                msg = "Error:操作数据库失败 INFOS：" + errinfo;
            //clsSharedHelper.WriteErrorInfo("操作数据库失败 INFOS：" + errinfo);

            return msg;
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

    //发送卡券给VIP用户
    //此方法还需要改造 因为目前不支持群发 即发出后必须得等绑定了用户信息后才能继续
    //解决方法：发送给用户后已经自动为其绑定了用户信息
    //用户点击领取后如果碰到网络或者是服务器卡，那么可能更新领取标识会不成功，此时用户可能会多领取
    public void Send2VIP(string cid, string userid, string mdid, string openid,string username)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr)) {
            string ticket = System.Guid.NewGuid().ToString();
            string str_sql = @" declare @ticket varchar(500);declare @khid int;declare @getlimit int;declare @dataID int;
                                select @getlimit=isnull(getlimit,0),@dataID=id from wx_t_cardinfos where id=@id and isdel=0
                                if @dataID is not null
                                  --先判断该用户有没有超过领取限制
                                  if exists (select top 1 1 from wx_t_CardRelation where isget=1 and openid=@openid and mdid=@mdid and cardid=@id having count(id)>=@getlimit)
                                    select '10',@getlimit
                                  else
                                    if exists (select top 1 1 from wx_t_CardDistribute where cid=@id and mdid=@mdid and stock>0)
                                    begin
                                      select @ticket=ticket,@khid=khid from wx_t_CardRelation where createrid=@customerid and cardid=@id and isbind=0 and isget=0;
                                      if isnull(@ticket,'')=''
                                      begin
                                        insert wx_t_CardRelation(ticket,khid,mdid,cardid,cardcode,openid,createrid,isbind,bindtime,isget,gettime)
                                        select top 1 @guid,khid,mdid,cid,cardid,@openid,@customerid,1,getdate(),0,'' from wx_t_CardDistribute where cid=@id and mdid=@mdid;
                                        update wx_t_CardDistribute set stock=stock-1 where cid=@id and khid=@khid and mdid=@mdid;
                                        select top 1 '11' code,@guid ticket,title,[description],localdiscount,
                                        convert(varchar(10),begintimestamp,120) ksrq,convert(varchar(10),endtimestamp,120) jsrq,configkey
                                        from wx_t_cardinfos where id=@id;
                                      end
                                      else
                                      begin
                                        update wx_t_CardRelation set isbind=1,openid=@openid,bindtime=getdate() where ticket=@ticket;
                                        update wx_t_CardDistribute set stock=stock-1 where cid=@id and khid=@khid and mdid=@mdid;
                                        select top 1 '11' code,@ticket ticket,title,[description],localdiscount,
                                        convert(varchar(10),begintimestamp,120) ksrq,convert(varchar(10),endtimestamp,120) jsrq,configkey
                                        from wx_t_cardinfos where id=@id;
                                      end
                                    end
                                    else
                                      select '01';
                                else
                                  select '00'";

            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@id", cid));
            paras.Add(new SqlParameter("@guid", ticket));
            paras.Add(new SqlParameter("@customerid", userid));
            paras.Add(new SqlParameter("@mdid", mdid));
            paras.Add(new SqlParameter("@openid", openid));
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                string code = Convert.ToString(dt.Rows[0][0]);
                if (code == "00")
                    clsSharedHelper.WriteErrorInfo("生成失败，请检查当前卡券的有效性！");
                else if (code == "10") {
                    string _limit = Convert.ToString(dt.Rows[0][1]);
                    clsSharedHelper.WriteErrorInfo("对不起，该用户已经超过了该类券每人最大领取数【" + _limit + "】！");
                }
                else if (code == "01")
                    clsSharedHelper.WriteErrorInfo("生成失败，库存不足！");
                else if (code == "11")
                {
                    //构造用户领取的URL地址      
                    //string url = "http://tm.lilanz.com/qywx/test/weixincard/UserGetTicket.aspx?ticket=" + Convert.ToString(dt.Rows[0]["ticket"]) + "&configkey=5";
                    string url = "http://tm.lilanz.com/project/easybusiness/UserGetTicket.aspx?ticket=" + Convert.ToString(dt.Rows[0]["ticket"]) + "&configkey=5";
                    string TemplateID = "yJZUs7ZJUuuqizRTHySG-7PM-uIcybVdCp-rYHMCwjY";
                    string cardinfo = "【" + Convert.ToString(dt.Rows[0]["title"]) + "】 " + Convert.ToString(dt.Rows[0]["description"]).Replace("\r\n", " ");
                    string postData = @"  {{
                                            ""touser"":""{0}"",
                                            ""template_id"":""{1}"",
                                            ""url"":""{2}"",            
                                            ""data"":{{
                                                       ""first"": {{
                                                                    ""value"":""尊敬的利郎会员，您获得了一张利郎优惠券！"",
                                                                    ""color"":""#000000""
                                                                   }},
                                                       ""keyword1"":{{
                                                                    ""value"":""点击立即领取"",
                                                                    ""color"":""#d9534f""
                                                                    }},
                                                       ""keyword2"": {{
                                                                    ""value"":""{3}"",
                                                                    ""color"":""#000000""
                                                                     }},
                                                       ""keyword3"": {{
                                                                     ""value"":""{5}"",
                                                                     ""color"":""#173177""
                                                                     }},
                                                       ""keyword4"": {{
                                                                     ""value"":""{4}"",
                                                                     ""color"":""#173177""
                                                                     }},
                                                        ""remark"":{{
                                                                     ""value"":""赶快点击领取吧！"",
                                                                     ""color"":""#000000""
                                                                   }}
                                                       }}
                                               }}";
                    postData = string.Format(postData, openid, TemplateID, url, cardinfo, DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), username);
                    string token = GetToken(ConfigKey);
                    using (clsJsonHelper jh = clsWXHelper.SendTemplateMessage(token, postData))
                    {
                        if (jh.GetJsonValue("errcode") == "0")
                            clsSharedHelper.WriteSuccessedInfo("");
                        else
                        {
                            WriteLog("模板消息发送错误:" + postData);
                            clsSharedHelper.WriteErrorInfo("模板消息发送错误：" + jh.jSon);
                        }
                    }//end send using
                }//end code='11'
            }
            else
                clsSharedHelper.WriteErrorInfo("发送失败：创建TICKET时失败！" + errinfo);
        }//end using
    }

    //=============================================20170331liqf 增加方法如下=============================================
    /// <summary>
    /// 获取某个门店的粉丝列表 注意，传入KHID就已经确定了粉丝是属于男装或者是公众号的会员即就已经确定了objectid了
    /// </summary>
    /// <param name="khid">门店的KHID</param>
    public void getStoreVIPList(string khid) {
        string res = @"{{""code"":{0},""data"":{1},""message"":""{2}""}}";
        if (string.IsNullOrEmpty(khid)) {
            res = string.Format(res, 201, "", "请传入参数【khid】");
            clsSharedHelper.WriteInfo(res);
            return;
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string str_sql = @"select a.wxnick,isnull(v.xm,'') xm,a.wxheadimgurl,a.wxopenid,isnull(a.vipid,0) vipid,isnull(v.kh,'') vipkh,
                                isnull(v.ty,0) vipty,a.objectid
                                from wx_t_vipbinging a
                                left join yx_t_vipkh v on a.vipid=v.id
                                where a.khid=@khid and a.objectid in (1,4)
                                order by a.createtime desc";
            DataTable dt;
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@khid", khid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            if (errinfo == "")
            {
                //特殊字符转码
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    dt.Rows[i]["wxnick"] = HttpUtility.UrlEncodeUnicode(dt.Rows[i]["wxnick"].ToString());
                }
                res = string.Format(res, 200, JsonConvert.SerializeObject(dt), "");
                dt.Clear(); dt.Dispose();
            }
            else
                res = string.Format(res, 201, "\"\"", errinfo);

            clsSharedHelper.WriteInfo(res);
        }//end using
    }

    /// <summary>
    /// 获取某个门店的粉丝列表 如果多传入卡券ID则关联出最后一次领券的时间
    /// </summary>
    /// <param name="khid"></param>
    /// <param name="cardid"></param>
    public void getStoreVIPList(string khid, string cardid) {
        string res = @"{{""code"":{0},""data"":{1},""message"":""{2}""}}";
        if (string.IsNullOrEmpty(khid))
        {
            res = string.Format(res, 201, "", "请传入参数【khid】");
            clsSharedHelper.WriteInfo(res);
            return;
        }

        if (string.IsNullOrEmpty(cardid) || cardid == "0")
        {
            res = string.Format(res, 201, "", "请传入参数【cardid】");
            clsSharedHelper.WriteInfo(res);
            return;
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr)) {
            string str_sql = @"select a.wxnick,isnull(v.xm,'') xm,a.wxheadimgurl,a.wxopenid,isnull(a.vipid,0) vipid,isnull(v.kh,'') vipkh,
                                isnull(v.ty,0) vipty,a.objectid into #zb
                                from wx_t_vipbinging a
                                left join yx_t_vipkh v on a.vipid=v.id
                                where a.khid=@khid and a.objectid in (1,4)
                                order by a.createtime desc

                                select a.wxopenid,max(b.createtime) lastsend into #send
                                from (select wxopenid from #zb) a
                                inner join wx_t_cardrelation b on a.wxopenid=openid
                                where b.cardid=@cardid
                                group by a.wxopenid

                                select a.*,b.lastsend
                                from #zb a left join #send b on a.wxopenid=b.wxopenid
                                drop table #zb;drop table #send;";
            DataTable dt;
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@khid", khid));
            para.Add(new SqlParameter("@cardid", cardid));

            string errinfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            if (errinfo == "")
            {
                //特殊字符转码
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    dt.Rows[i]["wxnick"] = HttpUtility.UrlEncodeUnicode(dt.Rows[i]["wxnick"].ToString());
                }
                res = string.Format(res, 200, JsonConvert.SerializeObject(dt), "");
                dt.Clear(); dt.Dispose();
            }
            else
                res = string.Format(res, 201, "\"\"", errinfo);

            clsSharedHelper.WriteInfo(res);
        }//end using        
    }

    /// <summary>
    /// 发送给单个会员卡券 根据vipid 
    /// </summary>
    /// <param name="vipid"></param>
    /// <param name="objectid"></param>
    /// <param name="cardid"></param>
    public string doSendCard2VIP(string vipid, string objectid, string cardid) {
        string res = @"{{""code"":{0},""data"":{1},""message"":""{2}""}}";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr))
        {
            string str_sql = @"select top 1 ty from yx_t_vipkh where id=@vipid";
            Object scalar;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@vipid", vipid));
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
            if (errinfo == "")
            {
                if (Convert.ToString(scalar) == "False")
                {
                    str_sql = "select top 1 wxopenid from wx_t_vipbinging where vipid=@vipid and objectid=@objectid";
                    paras.Clear();
                    paras.Add(new SqlParameter("@vipid", vipid));
                    paras.Add(new SqlParameter("@objectid", objectid));
                    errinfo = dal.ExecuteQueryFastSecurity(str_sql,paras,out scalar);
                    if (errinfo == "")
                    {
                        if (!string.IsNullOrEmpty(Convert.ToString(scalar))) {
                            string openid = Convert.ToString(scalar);
                            //判断卡券所属与VIP所属信息是否匹配
                            str_sql = @"select top 1 configkey from wx_t_cardinfos where id=@cardid";
                            paras.Clear();
                            paras.Add(new SqlParameter("@cardid", cardid));
                            errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                            string configkey = Convert.ToString(scalar);

                            if (!string.IsNullOrEmpty(configkey) && ((configkey == "5" && objectid != "1") || (configkey == "7" && objectid != "4")))
                                res = string.Format(res, 201, "\"\"", "发送失败，卡券所属与VIP所属信息不匹配！");
                            else
                                res = doSendCard2VIP(openid, cardid);
                        }else
                            res = string.Format(res, 201, "\"\"", "发送失败，该VIP尚未关联微信公众号！");
                    }
                    else
                        res = string.Format(res, 201, "\"\"", "发送失败，" + errinfo);
                }
                else
                    res = string.Format(res, 201, "\"\"", "发送失败，该VIP卡已经停用！");
            }
            else
                res = string.Format(res, 201, "\"\"", "查询VIP用户状态时出错！" + errinfo);
        }//end using wxdb        

        return res;
    }

    /// <summary>
    /// 根据用户的OPENID来发送一张卡券 
    /// </summary>
    /// <param name="openid"></param>
    /// <param name="cardid">wx_t_cardinfos.id</param>
    public string doSendCard2VIP(string openid,string cardid) {
        string res = @"{{""code"":{0},""data"":{1},""message"":""{2}""}}";
        if (string.IsNullOrEmpty(openid)) {
            clsSharedHelper.WriteInfo(string.Format(res, 201, "\"\"", "缺少必要参数【openid】"));
            return res;
        }

        if (string.IsNullOrEmpty(cardid) || cardid == "0") {
            clsSharedHelper.WriteInfo(string.Format(res, 201, "\"\"", "缺少必要参数【cardid】"));
            return res;
        }
        //WXCardURL_5        
        //string url_5 = @"http://tm.lilanz.com/project/vipweixin/UserGetTicket.aspx?ticket={0}&configkey=5";//利郎男装 objectid=1
        //string url_7 = @"http://tm.lilanz.com/vip2/easybusiness/UserGetTicket.aspx?ticket={0}&configkey=7";//轻商务 objectid=4
        string url_5 = clsConfig.GetConfigValue("WXCardURL_5");
        string url_7 = clsConfig.GetConfigValue("WXCardURL_7");

        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr))
        {
            string mdid = Convert.ToString(Session["mdid"]);
            string customerid = Convert.ToString(Session["qy_customersid"]);
            if (string.IsNullOrEmpty(mdid)) {
                return string.Format(res, 201, "\"\"", "系统超时，请重新登陆！");
            }

            DataTable dt;
            List<SqlParameter> paras = new List<SqlParameter>();
            //先判断券的有效性
            string str_sql = @"select a.configkey,a.cardid,a.getlimit,a.title,a.[description],isnull(b.id,0) did,isnull(b.stock,0) stock,isnull(wx.wxid,0) wxid,wx.objectid                                
                                from wx_t_cardinfos a
                                left join wx_t_CardDistribute b on a.id=b.cid and b.mdid=@mdid
                                left join (select top 1 id wxid,objectid from wx_t_vipbinging where wxopenid=@openid) wx on 1=1
                                where a.id=@id and a.isdel=0 and getdate()<=endtimestamp";
            paras.Add(new SqlParameter("@id", cardid));
            paras.Add(new SqlParameter("@mdid", mdid));
            paras.Add(new SqlParameter("@openid", openid));
            string errinfo = dal62.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string cardcode = Convert.ToString(dt.Rows[0]["cardid"]);
                    string configkey = Convert.ToString(dt.Rows[0]["configkey"]);
                    int getlimit = Convert.ToInt32(dt.Rows[0]["getlimit"]);
                    int disid = Convert.ToInt32(dt.Rows[0]["did"]);
                    int stock = Convert.ToInt32(dt.Rows[0]["stock"]);
                    int wxid = Convert.ToInt32(dt.Rows[0]["wxid"]);
                    string objectid = Convert.ToString(dt.Rows[0]["objectid"]);

                    if (wxid != 0)
                    {
                        if ((configkey == "5" && objectid == "1") || (configkey == "7" && objectid == "4"))
                        {
                            if (disid != 0)
                            {
                                if (stock > 0)
                                {
                                    //检查该用户领取数量是否超出了限制
                                    //str_sql = "select count(id) sl from wx_t_cardcodes where isget=1 and cardid=@cardcode and getuser=@openid and configkey=@configkey";
                                    str_sql = "select count(id) sl from wx_t_cardrelation where isget=1 and cardid=@cardid and openid=@openid";
                                    paras.Clear();
                                    paras.Add(new SqlParameter("@cardid", cardid));
                                    paras.Add(new SqlParameter("@openid", openid));
                                    object scalar;
                                    errinfo = dal62.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                                    if (errinfo == "")
                                    {
                                        if (Convert.ToInt32(scalar) < getlimit)
                                        {
                                            //判断通过发送微信模板消息 维护绑定数据 最后发送微信消息
                                            string newTicket = System.Guid.NewGuid().ToString();
                                            str_sql = @"declare @ticket varchar(200);declare @tid int;
                                                select top 1 @ticket=ticket,@tid=id from wx_t_CardRelation where createrid=@customerid and cardid=@id and isbind=0 and isget=0;
                                                if isnull(@ticket,'')=''
                                                begin
                                                  insert wx_t_CardRelation(ticket,khid,mdid,cardid,cardcode,openid,createrid,isbind,bindtime,isget,gettime,givetype)
                                                  select top 1 @guid,khid,mdid,cid,cardid,@openid,@customerid,1,getdate(),0,'','customer_mass_send' 
                                                  from wx_t_CardDistribute where cid=@id and mdid=@mdid;
                                                  update wx_t_CardDistribute set stock=stock-1 where cid=@id and mdid=@mdid;
                                                  select @guid ticket;
                                                end
                                                else
                                                begin
                                                  update wx_t_CardRelation set isbind=1,openid=@openid,bindtime=getdate(),givetype='customer_mass_send' where id=@tid and ticket=@ticket;
                                                  update wx_t_CardDistribute set stock=stock-1 where cid=@id and mdid=@mdid;
                                                  select @ticket ticket;
                                                end";
                                            paras.Clear();
                                            paras.Add(new SqlParameter("@guid", newTicket));
                                            paras.Add(new SqlParameter("@openid", openid));
                                            paras.Add(new SqlParameter("@customerid", customerid));
                                            paras.Add(new SqlParameter("@id", cardid));
                                            paras.Add(new SqlParameter("@mdid", mdid));
                                            errinfo = dal62.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                                            if (errinfo == "")
                                            {
                                                string _ticket = Convert.ToString(scalar), _url = "";
                                                if (configkey == "5")
                                                {
                                                    _url = string.Format(url_5, _ticket);
                                                }
                                                else if (configkey == "7")
                                                {
                                                    _url = string.Format(url_7, _ticket);
                                                }
                                                //开始发送微信模板消息
                                                string info = "【" + Convert.ToString(dt.Rows[0]["title"]) + "】 " + Convert.ToString(dt.Rows[0]["description"]).Replace("\r\n", " ");
                                                string sendResult = doSendWXCardTemplate(configkey, openid, info, _url);
                                                if (sendResult == "0")
                                                    res = string.Format(res, 200, "\"\"", "发送成功！");
                                                else
                                                    res = string.Format(res, 201, "\"\"", "微信发送失败！" + sendResult);
                                            }
                                            else
                                                res = string.Format(res, 201, "\"\"", "生成相关数据时出错！" + errinfo);
                                        }
                                        else
                                            res = string.Format(res, 201, "\"\"", "领取失败，该用户已经达到该类券的最大领取数量！");
                                    }
                                    else
                                        res = string.Format(res, 201, "\"\"", "查询用户领取数量时出错！" + errinfo);
                                }
                                else
                                    res = string.Format(res, 201, "\"\"", "对不起，该卡券库存不足！");
                            }
                            else
                                res = string.Format(res, 201, "\"\"", "您所处门店尚未被分配该卡券！");
                        }
                        else
                            res = string.Format(res, 201, "\"\"", "发送失败！卡券与用户不属于同一个公众号！");
                    }
                    else
                        res = string.Format(res, 201, "\"\"", "请检查OPENID的有效性！");
                }
                else
                    res = string.Format(res, 201, "\"\"", "请检查卡券的有效性！"+WXDBConstr);
            }
            else
                res = string.Format(res, 201, "\"\"", "查询卡券信息时出错！" + errinfo);
        }//end using wxdb

        return res;
    }

    //发送用户领取微信卡券的模板通知
    //利郎男装与轻商务使用的模板不一样
    public string doSendWXCardTemplate(string configkey, string openid, string desc, string url)
    {
        string errcode = "", templateID = "", postData = "";
        if (configkey == "5") {
            templateID = "yJZUs7ZJUuuqizRTHySG-7PM-uIcybVdCp-rYHMCwjY";
            postData = @"{{
                        ""touser"":""{0}"",
                        ""template_id"":""{1}"",
                        ""url"":""{2}"",            
                        ""data"":{{
                                ""first"": {{""value"":""尊敬的利郎会员，您获得了一张利郎优惠券！"",""color"":""#000000""}},
                                ""keyword1"":{{""value"":""点击立即领取"",""color"":""#d9534f""}},
                                ""keyword2"":{{""value"":""{3}"",""color"":""#000000""}},
                                ""keyword3"":{{""value"":""利郎会员"",""color"":""#173177""}},
                                ""keyword4"":{{""value"":""{4}"",""color"":""#173177""}},
                                ""remark"":{{""value"":""赶快点击领取吧！"",""color"":""#000000""}}
                                 }}
                        }}";
            postData = string.Format(postData, openid, templateID, url, desc, DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
        }
        else if (configkey == "7") {
            templateID = "dKqAlhh-54n0GRFHXnqCC1Kd2tS5nmnCHzLlsT_0zF8";
            postData = @"{{
                        ""touser"":""{0}"",
                        ""template_id"":""{1}"",
                        ""url"":""{2}"",
                        ""data"":{{
                                ""first"":{{""value"":""尊敬的利郎会员，您获得了一张利郎优惠券！"",""color"":""#000000""}},
                                ""keyword1"":{{""value"":""利郎轻商务""}},
                                ""keyword2"":{{""value"":""{3}"",""color"":""#333333""}},
                                ""keyword3"":{{""value"":""点击立即领取""}},
                                ""keyword4"":{{""value"":""{4}""}},
                                ""remark"":""赶快点击领取吧，感谢您对利郎的支持！""
                                 }}
                        }}";
            postData = string.Format(postData, openid, templateID, url, desc, DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
        }

        string token = GetToken(configkey);
        using (clsJsonHelper jh = clsWXHelper.SendTemplateMessage(token, postData))
        {
            if (jh.GetJsonValue("errcode") == "0")
                errcode = "0";
            else
            {
                WriteLog("模板消息发送错误:" + postData);
                //clsSharedHelper.WriteErrorInfo("模板消息发送错误：" + jh.jSon);
                errcode = jh.GetJsonValue("errcode") + "|" + jh.GetJsonValue("errmsg") + "|" + openid;
            }

            return errcode;
        }//end send using 
    }

    //获取ACCESS_TOKEN
    public string GetToken(string configkey)
    {
        string _AT = "";
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM("server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion"))
        {
            string str_sql = "select top 1 accesstoken from wx_t_tokenconfiginfo where configkey='" + configkey + "'";
            object scaler = null;
            string errinfo = dal62.ExecuteQueryFast(str_sql, out scaler);
            if (errinfo == "")
                _AT = Convert.ToString(scaler);
        }

        return _AT;
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
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
