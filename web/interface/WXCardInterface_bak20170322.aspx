<%@ Page Language="C#" %>

<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<!DOCTYPE html>
<script runat="server">
    /// <summary>
    /// 创建时间 2016-05-20
    /// 开发人员：李清峰、林文印
    /// 主要用于微信卡券功能的相关功能调用逻辑页
    /// 服务号：利郎男装服务号
    /// 数据库：192.168.35.62 weChatPromotion
    /// </summary>    
    //private string WXDBConstr = "server='192.168.35.23';database=weChatTest;uid=lllogin;pwd=rw1894tla";    
    //private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";    
    private string WXDBConstr = "";    
    public string Configkey = "5";//利郎男装    
        
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsConfig.Contains("WXConnStr"))
            WXDBConstr = clsConfig.GetConfigValue("WXConnStr");
        else
            WXDBConstr = System.Configuration.ConfigurationManager.ConnectionStrings["WXDBConnStr"].ConnectionString;
                
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "UploadImg2WX":
                if (Request.Files.Count == 0)
                {
                    clsSharedHelper.WriteErrorInfo("至少选择一个文件上传！");
                    return;
                }
                else
                {
                    HttpPostedFile file = Request.Files[0];
                    string rtMsg = HttpUploadFileClient(file, GetToken(Configkey));
                    WriteLog("上传图片至微信" + rtMsg);
                    clsSharedHelper.WriteInfo(rtMsg);
                }
                break;
            case "CreateCard":
                string cid = Convert.ToString(Request.Params["cid"]);
                if (cid == "" || cid == null || cid == "0")
                    clsSharedHelper.WriteErrorInfo("传入的参数有误！");
                else
                    CreateCard(cid);
                break;
            case "UpdateWXCard":
                cid = Convert.ToString(Request.Params["cid"]);
                if (cid == "" || cid == null || cid == "0")
                    clsSharedHelper.WriteErrorInfo("传入的参数有误！");
                else
                    UpdateWXCard(cid);
                break;
            case "GetCardIDList":
                clsSharedHelper.WriteInfo(GetCardIDList(Configkey, 0, 50));
                break;
            case "GetCardDetail":
                string cardid = Convert.ToString(Request.Params["cardid"]);
                if (cardid == "" || cardid == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数CARDID!");
                else
                    GetCardDetail(cardid);
                break;
            case "GetCardStatus":
                cardid = Convert.ToString(Request.Params["cardid"]);
                string cardtype = Convert.ToString(Request.Params["cardtype"]);
                if (cardid == "" || cardid == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数CARDID!");
                else if (cardtype == "" || cardtype == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数CARDTYPE!");
                else
                    clsSharedHelper.WriteInfo(GetCardStatus(cardid, cardtype, true));
                break;
            case "CreateQRCode":
                string jsonStr = Convert.ToString(Request.Params["jsonStr"]);
                if (jsonStr == "" || jsonStr == null)
                    clsSharedHelper.WriteErrorInfo("提交的参数有误！");
                else
                    CreateQRCode(jsonStr);
                CreateQRCode(jsonStr);
                break;
            case "CheckCode":                
                string code = Convert.ToString(Request.Params["code"]);
                string khid = Convert.ToString(Request.Params["tzid"]);//贸易公司KHID
                if (code == "" || code == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数CODE!");
                else
                    clsSharedHelper.WriteInfo(CheckCode(khid, code));
                break;
            case "ConsumeCode":                
                code = Convert.ToString(Request.Params["code"]);
                khid = Convert.ToString(Request.Params["tzid"]);
                if (code == "" || code == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数CODE!");
                else
                    ConsumeCode(khid, code);
                break;
            case "CardEvent":
                CardEventFunc(Convert.ToString(Request.Params[1]));
                break;
            case "SyncCardFromWX":
                cardid = Convert.ToString(Request.Params["cardid"]);                
                if (cardid == "" || cardid == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数CARDID!");
                else
                    clsSharedHelper.WriteInfo(SyncCardFromWX(cardid));               
                break;
            case "DelWXCard":
                cardid = Convert.ToString(Request.Params["cardid"]);
                if (cardid == "" || cardid == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数CARDID!");
                else
                    DelWXCard(cardid);
                break;
            case "ModifyStock":
                cardid = Convert.ToString(Request.Params["cardid"]);
                string stock = Convert.ToString(Request.Params["stock"]);
                if (cardid == "" || cardid == null)
                    clsSharedHelper.WriteErrorInfo("请检查参数CARDID!");
                else if (stock == "" || stock == null)
                    clsSharedHelper.WriteErrorInfo("请传入库存变化量!");
                else
                    ModifyStock(cardid, stock);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("请检查传入的CTRL是否有效！");
                break;
        }
    }

    //卡券事件处理函数
    public void CardEventFunc(string xmlStr) {        
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr)) {
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
            if (str_sql != "") {
                if (paras.Count == 0)
                    errinfo = dal62.ExecuteNonQuery(str_sql);                
                else
                    errinfo = dal62.ExecuteNonQuerySecurity(str_sql, paras);

                if (errinfo == "")
                    //WriteLog("卡券事件推送 结果处理成功！TYPE:" + eventType + " CARDID:" + cardid + " CARD_CODE:" + cardcode + " SQL:" + str_sql);
                    WriteLog("卡券事件推送【CardEventFunc】:" + xmlStr);
                else
                    WriteLog("卡券事件推送 结果处理失败！INFOS:" + errinfo + " TYPE:" + eventType + " CARDID:" + cardid + " CARD_CODE:" + cardcode + eventType + " SQL:" + str_sql);
            }//end execute sql
        }//end using
    }
    
    //核销Code接口
    //检查跟核销接口中的ACCESSTOKEN都直接根据传入的TZID来判断如果是KHID=17832则使用轻商务的反之使用利郎男装
    //由于不能保证CODE在本地一定存在
    public void ConsumeCode(string khid,string code)
    {
        //我们强烈建议开发者在调用核销code接口之前调用查询code接口，并在核销之前对非法状态的code(如转赠中、已删除、已核销等)做出处理。
        string _key = GetTokenKey(khid);
        if (_key.IndexOf(clsNetExecute.Error) >= 0)
        {
            clsSharedHelper.WriteInfo(_key);
            return;
        }
        string url = string.Format("https://api.weixin.qq.com/card/code/consume?access_token={0}", GetToken(_key));
        string data = string.Format(@"{{""code"": ""{0}""}}", code);
        string CheckCodeResult = CheckCode(khid, code);
        JObject ccrjo = JObject.Parse(CheckCodeResult);
        if (Convert.ToBoolean(ccrjo["can_consume"]) && Convert.ToString(ccrjo["errmsg"]) == "")
        {
            string content = PostDataToWX(url, data);
            JObject jo = JObject.Parse(content);
            if (Convert.ToString(jo["errcode"]) == "0") {                
                //核销成功更新本地数据库
                using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr)) {
                    string str_sql = @"update wx_t_CardCodes set usercardstatus='CONSUMED',canconsume=0,isconsume=1,consumetime=getdate() where cardcode=@cardcode;
                                       insert wx_t_CodeConsume(codeid,cardcode,saleid,creater,createtime,khid)
                                       select top 1 id,cardcode,0,0,getdate()," + khid + " from wx_t_CardCodes where cardcode=@cardcode;";
                    List<SqlParameter> paras = new List<SqlParameter>();                    
                    paras.Add(new SqlParameter("@cardcode", code));
                    string errinfo = dal62.ExecuteNonQuerySecurity(str_sql,paras);
                    if (errinfo != "")
                    {
                        WriteLog("核销时提交微信成功，但是更新本地数据时失败！ INFOS:" + errinfo);
                        clsSharedHelper.WriteErrorInfo("核销时提交微信成功，但是更新本地数据时失败！ INFOS:" + errinfo);
                    }
                    else 
                        clsSharedHelper.WriteSuccessedInfo("核销成功：" + Convert.ToString(jo["openid"]));                        
                }
            }
            else
            {
                WriteLog("核销失败 INFOS:" + content);
                clsSharedHelper.WriteErrorInfo("核销失败 INFOS:" + content);
            }
        }
        else
        {
            clsSharedHelper.WriteErrorInfo("检查CODE状态不通过！" + CheckCodeResult);
        }
    }
    //根据客户id来获取使用哪个公众号的key,错误返回clsNetExecute.Error +错误信息；正确返回key值
    private string GetTokenKey(string khid)
    {
        string errInfo, rt;
        string mysql = "select ccid+'-' from yx_t_khb where khid=@khid";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@khid", khid));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM("server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft"))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
        }

        if (errInfo != "")
        {
            rt = clsNetExecute.Error + errInfo;
        }
        else if (dt.Rows.Count > 0)
        {
            if (Convert.ToString(dt.Rows[0][0]).IndexOf("-17832-") > 0)
            {
                rt = "7";
            }
            else
            {
                rt = "5";
            }
        }
        else
        {
            rt = clsNetExecute.Error + "系统未找到该客户信息";
        }
        return rt;
    }
    //查询CODE接口
    public string CheckCode(string khid,string code)
    {
        string _key = GetTokenKey(khid);
        if (_key.IndexOf(clsNetExecute.Error) >= 0)
        {
            return _key;
        }
        
        string rtJson = @"{{""can_consume"":{0},""card_status"":""{1}"",""card_description"":""{3}"",""card_discount"":""{4}"",""errmsg"":""{2}"",""localtype"":""{5}"",""leastcost"":""{6}"",""reducecost"":""{7}""}}";
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr)) {                     
            string url = string.Format("https://api.weixin.qq.com/card/code/get?access_token={0}", GetToken(_key));
            List<SqlParameter> paras = new List<SqlParameter>();            
            string str_sql = "",errinfo="";
            string datas = @"{{                           
                           ""code"" : ""{0}"",
                           ""check_consume"" : false
                        }}";
            
            datas = string.Format(datas, code);
            string content = PostDataToWX(url, datas);                                                     
            JObject jo = JObject.Parse(content);
            if (Convert.ToString(jo["errcode"]) == "0")
            {
                string can_consume = Convert.ToString(jo["can_consume"]).ToLower();
                string openid = Convert.ToString(jo["openid"]);
                string status = Convert.ToString(jo["user_card_status"]);
                string cardid = Convert.ToString(jo["card"]["card_id"]);

                str_sql = @" if exists (select top 1 1 from wx_t_cardinfos where cardid=@cardid and configkey=@configkey and isdel=0)                               
                               begin
                               if exists (select top 1 1 from wx_t_cardcodes where cardid=@cardid and cardcode=@cardcode)
                                 update wx_t_CardCodes set getuser=@openid,usercardstatus=@status,canconsume=@canconsume where cardid=@cardid and cardcode=@cardcode;
                               else
                                 insert into wx_t_CardCodes(cardid,cardcode,isget,getuser,gettime,isconsume,usercardstatus,canconsume)
                                 values(@cardid,@cardcode,1,@openid,getdate(),0,'NORMAL',@canconsume);
                               select top 1 '11',description,localdiscount,localcardtype,LeastCost,ReduceCost from wx_t_cardinfos where cardid=@cardid and configkey=@configkey and isdel=0;
                               end
                             else
                               select '00';";
                paras.Clear();
                paras.Add(new SqlParameter("@cardid", cardid));
                paras.Add(new SqlParameter("@configkey", _key));
                paras.Add(new SqlParameter("@openid", openid));
                paras.Add(new SqlParameter("@status", status));
                paras.Add(new SqlParameter("@canconsume", can_consume));
                paras.Add(new SqlParameter("@cardcode", code));
                DataTable dt = null;
                errinfo = dal62.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo != "")
                {
                    WriteLog("CheckCode WriteDB Is ERROR!" + errinfo);
                    rtJson = string.Format(rtJson, can_consume, status, errinfo, "", "","","","");
                }
                else
                {
                    if (Convert.ToString(dt.Rows[0][0]) == "00")
                        rtJson = string.Format(rtJson, can_consume, status, "该卡券已停用！", "", "","","","");
                    else
                        rtJson = string.Format(rtJson, can_consume, status, "", Convert.ToString(dt.Rows[0][1]), Convert.ToString(dt.Rows[0][2]), 
                            Convert.ToString(dt.Rows[0][3]), Convert.ToString(dt.Rows[0][4]), Convert.ToString(dt.Rows[0][5]));
                }
            }
            else
                rtJson = string.Format(rtJson, "false", "", jo["errmsg"], "", "");
        }
        
        return rtJson;
    }

    //核销卡券--创建二维码 目前只写扫一个二维码领取一张卡券
    public void CreateQRCode(string jsonStr)
    {
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr))
        {            
            //解析从客户端提交的生成报文串            
            JObject jo = JObject.Parse(jsonStr);
            string expires = Convert.ToString(jo["expire_seconds"]);
            expires = expires == "" ? "0" : expires;
            string cardid = Convert.ToString(jo["action_info"]["card"]["card_id"]);
            string outerid = Convert.ToString(jo["action_info"]["card"]["outer_id"]);
            string _key = getConfigKey(cardid, "");
            string url = string.Format("https://api.weixin.qq.com/card/qrcode/create?access_token={0}", GetToken(_key));
            string content = PostDataToWX(url, jsonStr);
            JObject wxjo = JObject.Parse(content);            
            if (Convert.ToString(wxjo["errcode"]) == "0")
            {
                string ticket = Convert.ToString(wxjo["ticket"]);
                string qrurl = Convert.ToString(wxjo["url"]);
                string showurl = Convert.ToString(wxjo["show_qrcode_url"]);
                string str_sql = @"declare @configkey int;
                                    select @configkey=isnull(configkey,0) from wx_t_cardinfos where cardid=@cardid 
                                    if isnull(@configkey,0)=0
                                      select '00'
                                    else 
                                    begin
                                      if not exists (select top 1 1 from wx_t_CardQRCode where cardid=@cardid)
                                        insert into wx_t_CardQRCode(configkey,cardid,expireseconds,isuniquecode,outerid,ticket,url,showqrcodeurl,createtime)
                                        values(@configkey,@cardid,@expires,0,@outerid,@ticket,@url,@showurl,getdate());
                                      else
                                        update wx_t_CardQRCode set expireseconds=@expires,outerid=@outerid,ticket=@ticket,url=@url,showqrcodeurl=@showurl,uptime=getdate() where @cardid=@cardid;
                                      select '11';
                                    end";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@cardid", cardid));
                paras.Add(new SqlParameter("@expires", expires));
                paras.Add(new SqlParameter("@outerid", outerid));
                paras.Add(new SqlParameter("@ticket", ticket));
                paras.Add(new SqlParameter("@url", url));
                paras.Add(new SqlParameter("@showurl", showurl));
                object scalar;
                string errinfo = dal62.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
                if (errinfo == "")
                {
                    if (Convert.ToString(scalar) == "00")
                        clsSharedHelper.WriteErrorInfo("请检查对应卡券的有效性！");
                    else
                        clsSharedHelper.WriteSuccessedInfo("");
                }
                else
                {
                    WriteLog("本地创建二维码时出错 INFOS:" + errinfo + " SQL:" + str_sql + " PARAS:" + jsonStr + " " + content);
                    clsSharedHelper.WriteErrorInfo("本地创建二维码时出错 INFOS:" + errinfo);
                }
            }
            else
            {
                WriteLog("微信上创建二维码时错误！ INFOS:" + content);
                clsSharedHelper.WriteErrorInfo(content);
            }
        }//end using
    }

    //修改库存接口
    //increase_stock_value 增加多少库存，支持不填或填0。
    //reduce_stock_value 减少多少库存，可以不填或填0。
    //cStock库存变化量，正数表示增加，负数表示减少
    public void ModifyStock(string cardid,string cStocks) {
        string _key = getConfigKey(cardid, "");
        string url = string.Format("https://api.weixin.qq.com/card/modifystock?access_token={0}", GetToken(_key));
        string data = @"{{
                        ""card_id"": ""{0}"",
                        ""increase_stock_value"": {1},
                        ""reduce_stock_value"": {2}
                        }}";
        int istock = 0, rstock = 0;
        int stock = Convert.ToInt32(cStocks);
        if (stock >= 0)
        {
            istock = stock;
            rstock = 0;
        }
        else {
            istock = 0;
            rstock = -1 * stock;
        }
        data = string.Format(data, cardid, istock, rstock);
        string content = PostDataToWX(url, data);
                
        //微信端操作成功后，本地也要跟着更新
        JObject jo = JObject.Parse(content);        
        if (Convert.ToString(jo["errcode"]) == "0")
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr)) {
                string str_sql = @"update wx_t_cardinfos set totalquantity=totalquantity+(@stock),quantity=quantity+(@stock) where cardid=@cardid and configkey=@configkey;";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@cardid",cardid));
                para.Add(new SqlParameter("@stock", cStocks));
                para.Add(new SqlParameter("@configkey",_key));
                string errinfo = dal.ExecuteNonQuerySecurity(str_sql, para);
                if (errinfo == "")
                    clsSharedHelper.WriteSuccessedInfo("");
                else
                    clsSharedHelper.WriteErrorInfo(errinfo);
            }//end using
        }
        else {
            clsSharedHelper.WriteInfo(content);
        }
    }
    
    //修改卡券信息
    //传入表wx_t_cardinfos.id
    //更改卡券的部分字段后会重新提交审核，详情见字段说明，更新成功后可通过调用查看卡券详情接口核查更新结果
    //不是卡券所有的信息字段都可能修改
    public void UpdateWXCard(string tableid)
    {
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr)) {            
            string cardStr = @"{{
                              ""card_id"":""{0}"",
                              ""{1}"": {{
                                       ""base_info"": {{
                                           ""color"": ""{2}"",
                                           ""notice"": ""{3}"",
                                           ""service_phone"": ""{4}"",
                                           ""description"": ""{5}"",                                           
                                           ""date_info"": {{
                                               ""type"": ""{6}"",
                                               ""begin_timestamp"": {7},
                                               ""end_timestamp"": {8}
                                           }},
                                           ""get_limit"": {9}, 
                                           ""can_give_friend"":{16},                                                                                                                                  
                                           ""custom_url_name"": ""{10}"",
                                           ""custom_url"": ""{11}"",
                                           ""custom_url_sub_title"": ""{12}"",
                                           ""promotion_url_name"": ""{13}"",
                                           ""promotion_url"": ""{14}"",
                                           ""promotion_url_sub_title"":""{15}""
                                       }}
                                    }}
                                }}";
            string str_sql = string.Format("select top 1 * from wx_t_cardinfos where id='{0}'", tableid);
            DataTable dt = null;
            string errinfo = dal62.ExecuteQuery(str_sql, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string _key = Convert.ToString(dt.Rows[0]["configkey"]);
                    string cardid = Convert.ToString(dt.Rows[0]["cardid"]);
                    string cardtype = Convert.ToString(dt.Rows[0]["cardtype"]);
                    string color = Convert.ToString(dt.Rows[0]["color"]);//颜色
                    string notice = Convert.ToString(dt.Rows[0]["notice"]);//使用提醒
                    string desc = Convert.ToString(dt.Rows[0]["description"]);//使用须知      
                    string datetype = Convert.ToString(dt.Rows[0]["datetype"]); //日期类型             
                    DateTime ksrq = Convert.ToDateTime(dt.Rows[0]["begintimestamp"]);//起用时间
                    DateTime jsrq = Convert.ToDateTime(dt.Rows[0]["endtimestamp"]);//结束时间
                    int btimestamp = ConvertDateTimeInt(ksrq);
                    int etimestamp = ConvertDateTimeInt(jsrq);                    
                    string sphone = Convert.ToString(dt.Rows[0]["servicephone"]);//客服电话        
                    string customurlname = Convert.ToString(dt.Rows[0]["customurlname"]);//外链入口
                    string customurl = Convert.ToString(dt.Rows[0]["customurl"]);
                    string customurlsubtitle = Convert.ToString(dt.Rows[0]["customurlsubtitle"]);
                    string prourlname = Convert.ToString(dt.Rows[0]["promotionurlname"]);//营销入口
                    string prourl = Convert.ToString(dt.Rows[0]["promotionurl"]);
                    string prourlsubtitle = Convert.ToString(dt.Rows[0]["promotionurlsubtitle"]);
                    int getlimit = Convert.ToInt32(dt.Rows[0]["getlimit"]);//每人领取最大数量                    
                    string cangive = Convert.ToString(dt.Rows[0]["cangivefriend"]).ToLower();

                    string url = string.Format("https://api.weixin.qq.com/card/update?access_token={0}", GetToken(_key));
                    cardStr = string.Format(cardStr, cardid, cardtype.ToLower(), color, notice, sphone, desc, datetype, btimestamp, etimestamp, getlimit, customurlname, customurl, customurlsubtitle, prourlname, prourl, prourlsubtitle, cangive);
                    string content = PostDataToWX(url, cardStr);
                    
                    WriteLog("更新卡券 " + cardStr + "提交结果：" + content);
                    JObject jo = JObject.Parse(content);
                    if (Convert.ToString(jo["errcode"]) == "0")
                    {
                        string check = Convert.ToString(jo["send_check"]);
                        if (Convert.ToBoolean(check))
                            clsSharedHelper.WriteSuccessedInfo("更新成功,且微信需要重新审核！");
                        else
                            clsSharedHelper.WriteSuccessedInfo("更新成功！");
                    }
                    else
                        clsSharedHelper.WriteErrorInfo("卡券更新失败！" + content);
                    
                }else
                    clsSharedHelper.WriteErrorInfo("本地查询不到相应的卡券信息！");
            }else
                clsSharedHelper.WriteErrorInfo("LODB查询卡券信息时出错：" + errinfo);    
        }
    }

    //创建卡券 统一使用微信的优惠券类型来自定义我们自己的类型GENERAL_COUPON
    public void CreateCard(string id)
    {
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr))
        {            
            string cardStr = @"{{ 
                            ""card"": {{
                               ""card_type"": ""{0}"",
                               ""{26}"": {{
                                   ""base_info"": {{
                                       ""logo_url"": ""{1}"",
                                       ""brand_name"":""{2}"",
                                       ""code_type"":""{3}"",
                                       ""title"": ""{4}"",
                                       ""sub_title"": ""{5}"",
                                       ""color"": ""{6}"",
                                       ""notice"": ""{7}"",
                                       ""service_phone"": ""{8}"",
                                       ""description"": ""{9}"",
                                       ""date_info"": {{
                                           ""type"": ""{10}"",
                                           ""begin_timestamp"": {11} ,
                                           ""end_timestamp"": {12}
                                       }},
                                       ""sku"": {{
                                           ""quantity"": {13}
                                       }},
                                       ""get_limit"": {14},
                                       ""use_custom_code"": {15},  
                                       ""bind_openid"":{27},                                     
                                       ""can_share"": {16},
                                       ""can_give_friend"": {17},                                       
                                       ""custom_url_name"": ""{18}"",
                                       ""custom_url"": ""{19}"",
                                       ""custom_url_sub_title"": ""{20}"",
                                       ""promotion_url_name"": ""{21}"",
                                       ""promotion_url"": ""{22}"",
                                       ""promotion_url_sub_title"":""{23}"",
                                       ""source"": ""{24}""
                                   }},
                                  {25} 
                                }}
                             }}
                            }}";
            string str_sql = string.Format("select * from wx_t_cardinfos where id={0}", id);
            DataTable dt = null;
            string errinfo = dal62.ExecuteQuery(str_sql, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string _key = Convert.ToString(dt.Rows[0]["configkey"]);
                    string logourl = Convert.ToString(dt.Rows[0]["logourl"]);
                    string cardtype = Convert.ToString(dt.Rows[0]["cardtype"]);
                    string codetype = Convert.ToString(dt.Rows[0]["codetype"]);
                    string brandname = Convert.ToString(dt.Rows[0]["brandname"]);
                    string title = Convert.ToString(dt.Rows[0]["title"]);
                    string subtitle = Convert.ToString(dt.Rows[0]["subtitle"]);
                    string color = Convert.ToString(dt.Rows[0]["color"]);
                    string notice = Convert.ToString(dt.Rows[0]["notice"]);
                    string desc = Convert.ToString(dt.Rows[0]["description"]);
                    int quantity = Convert.ToInt32(dt.Rows[0]["quantity"]);
                    string datetype = Convert.ToString(dt.Rows[0]["datetype"]);
                    DateTime ksrq = Convert.ToDateTime(dt.Rows[0]["begintimestamp"]);
                    DateTime jsrq = Convert.ToDateTime(dt.Rows[0]["endtimestamp"]);
                    int btimestamp = ConvertDateTimeInt(ksrq);
                    int etimestamp = ConvertDateTimeInt(jsrq);
                    string customecode = Convert.ToString(dt.Rows[0]["usecustomcode"]).ToLower();
                    string binduser = Convert.ToString(dt.Rows[0]["bindopenid"]).ToLower();
                    string sphone = Convert.ToString(dt.Rows[0]["servicephone"]);
                    string source = Convert.ToString(dt.Rows[0]["source"]);
                    string customurlname = Convert.ToString(dt.Rows[0]["customurlname"]);
                    string customurl = Convert.ToString(dt.Rows[0]["customurl"]);
                    string customurlsubtitle = Convert.ToString(dt.Rows[0]["customurlsubtitle"]);
                    string prourlname = Convert.ToString(dt.Rows[0]["promotionurlname"]);
                    string prourl = Convert.ToString(dt.Rows[0]["promotionurl"]);
                    string prourlsubtitle = Convert.ToString(dt.Rows[0]["promotionurlsubtitle"]);
                    int getlimit = Convert.ToInt32(dt.Rows[0]["getlimit"]);
                    string canshare = Convert.ToString(dt.Rows[0]["canshare"]).ToLower();
                    string cangive = Convert.ToString(dt.Rows[0]["cangivefriend"]).ToLower();
                    int leastcost = Convert.ToInt32(dt.Rows[0]["leastcost"]);
                    int reducecost = Convert.ToInt32(dt.Rows[0]["reducecost"]);
                    string dedetail = Convert.ToString(dt.Rows[0]["defaultdetail"]);

                    string special_info = "";
                    switch (cardtype)
                    {
                        //代金券
                        case "CASH":
                            special_info = string.Format(" \"least_cost\":{0},\"reduce_cost\":{1} ", leastcost, reducecost);
                            cardStr = string.Format(cardStr, cardtype, logourl, brandname, codetype, title, subtitle, color, notice, sphone, desc, datetype, btimestamp, etimestamp, quantity, getlimit, customecode, canshare, cangive, customurlname, customurl, customurlsubtitle, prourlname, prourl, prourlsubtitle, source, special_info, cardtype.ToLower(), binduser);
                            break;
                        //优惠券
                        case "GENERAL_COUPON":
                            special_info = string.Format(" \"default_detail\":\"{0}\"", dedetail);
                            cardStr = string.Format(cardStr, cardtype, logourl, brandname, codetype, title, subtitle, color, notice, sphone, desc, datetype, btimestamp, etimestamp, quantity, getlimit, customecode, canshare, cangive, customurlname, customurl, customurlsubtitle, prourlname, prourl, prourlsubtitle, source, special_info, cardtype.ToLower(), binduser);
                            break;
                    }

                    string url = string.Format("https://api.weixin.qq.com/card/create?access_token={0}", GetToken(_key));
                    string content = PostDataToWX(url, cardStr);
                    WriteLog("创建卡券 " + cardStr + "提交结果：" + content);
                    JObject jo = JObject.Parse(content);
                    if (Convert.ToString(jo["errcode"]) == "0")
                    {
                        string cardid = Convert.ToString(jo["card_id"]);
                        if (UpCreCardInfo(id, cardid))
                            clsSharedHelper.WriteSuccessedInfo(cardid);
                        else
                            clsSharedHelper.WriteErrorInfo("卡券成功，但是数据异常，该卡券【" + cardid + "】可能无法正常使用！");
                    }
                    else
                        clsSharedHelper.WriteErrorInfo("卡券创建失败！" + content);
                }
                else
                    clsSharedHelper.WriteErrorInfo("本地查询不到相应的卡券信息！");
            }
            else
            {
                WriteLog("LODB查询卡券信息时出错：" + errinfo + " SQL:" + str_sql);
                clsSharedHelper.WriteErrorInfo("LODB查询卡券信息时出错：" + errinfo);
            }
        }
    }

    //从微信同步卡券数据到本地数据库 ！！慎用！！前期仅提供同步单张
    public void SyncAllCards() {
        string content = GetCardIDList(Configkey, 0, 50);
        JObject jo = JObject.Parse(content);
        if (Convert.ToString(jo["errcode"]) == "0")
        {            
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr)) {
                int successCount = 0, failCount = 0;
                string str_sql="";
                string url = string.Format("https://api.weixin.qq.com/card/get?access_token={0}", GetToken(Configkey));
                JArray ja = (JArray)jo["card_id_list"];
                for (int i = 0; i < ja.Count; i++) {
                    string cardid = Convert.ToString(ja[i]);                    
                    string _data = string.Format(@"{{""card_id"":""{0}""}}", cardid);
                    string cd = PostDataToWX(url, _data);
                    JObject cjo = JObject.Parse(cd);
                    if (Convert.ToString(cjo["errcode"]) == "0")
                    {
                        string cardtype = Convert.ToString(cjo);
                    }
                    else {
                        failCount++;
                        WriteLog("查询【" + cardid + "】卡券详情失败！");
                    }                        
                }//end for
            }//end using            
        }
        else
            clsSharedHelper.WriteErrorInfo(content);
    }

    //从微信服务器同步单张卡券到本地
    public string SyncCardFromWX(string cardid) {
        string rt="";
        string url = string.Format("https://api.weixin.qq.com/card/get?access_token={0}", GetToken(Configkey));
        string content = string.Format(@"{{""card_id"":""{0}""}}", cardid);
        string cd = PostDataToWX(url, content);
        JObject jo=JObject.Parse(cd);
        if (Convert.ToString(jo["errcode"]) == "0")
        {
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr)) {
                string cardtype = Convert.ToString(jo["card"]["card_type"]);                
                //base_info
                string logourl = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["logo_url"]);
                string codetype = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["code_type"]);
                string brandname = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["brand_name"]);
                string title = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["title"]);
                string subtitle = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["sub_title"]);
                //date_info
                string datetype = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["date_info"]["type"]);
                string begintime = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["date_info"]["begin_timestamp"]);//起用时间
                string endtime = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["date_info"]["end_timestamp"]);//结束时间
                string fixedterm = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["date_info"]["fixed_term"]);//领取后多少天内生效
                string fixedbeginterm = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["date_info"]["fixed_begin_term"]);//领取后多少天开始开始生效

                string color = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["color"]);
                string notice = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["notice"]);
                string servicephone = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["service_phone"]);
                string description = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["description"]);
                string source = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["source"]);
                string locationlist = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["location_id_list"]);
                string getlimit = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["get_limit"]);
                string canshare = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["can_share"]);
                string cangive = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["can_give_friend"]);
                string customcode = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["use_custom_code"]);
                string bindopenid = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["bind_openid"]);
                string status = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["status"]);

                //sku
                string quantity = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["sku"]["quantity"]);
                string total = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["sku"]["total_quantity"]);

                string customurlname = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["custom_url_name"]);
                string customurl = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["custom_url"]);
                string customsub = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["custom_url_sub_title"]);
                string prourl = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["promotion_url"]);
                string prourlname = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["promotion_url_name"]);
                string prourlsub = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["promotion_url_sub_title"]);

                string dedetail = Convert.ToString(jo["card"][cardtype.ToLower()]["default_detail"]);//优惠券专属字段
                string leastcost = Convert.ToString(jo["card"][cardtype.ToLower()]["least_cost"]);//代金券专属字段
                string reducecost = Convert.ToString(jo["card"][cardtype.ToLower()]["reduce_cost"]);//代金券专属字段                
                string str_sql = @"if not exists(select top 1 1 from wx_t_cardinfos where configkey=@configkey and cardid=@cardid)
                                insert into wx_t_cardinfos(configkey,cardid,cardtype,logourl,codetype,brandname,title,subtitle,color,notice,[description],
                                creater,createtime,totalquantity,quantity,datetype,begintimestamp,endtimestamp,fixedterm,fixedbeginterm,usecustomcode,bindopenid,
                                servicephone,locationidlist,[source],customurlname,customurl,customurlsubtitle,promotionurlname,promotionurl,promotionurlsubtitle,
                                getlimit,canshare,cangivefriend,cardstatus,leastcost,reducecost,defaultdetail) values (@configkey,@cardid,@cardtype,@logo,@codetype,
                                @brandname,@title,@subtitle,@color,@notice,@desc,'使用API同步',getdate(),@total,@quantity,@datetype,@begintime,@endtime,@fterm,@fbterm,
                                @customcode,@bindopenid,@servicephone,@locationlist,@source,@cusurlname,@cusurl,@cusurlsub,@prourlname,@prourl,@prourlsub,@getlimit,
                                @canshare,@cangive,@status,@leastcost,@reducecost,@dedetail);
                              else
                                update wx_t_cardinfos set cardtype=@cardtype,logourl=@logo,codetype=@codetype,brandname=@brandname,title=@title,subtitle=@subtitle,color=@color,
                                notice=@notice,description=@desc,totalquantity=@total,quantity=@quantity,datetype=@datetype,begintimestamp=@begintime,endtimestamp=@endtime,
                                fixedterm=@fterm,fixedbeginterm=@fbterm,usecustomcode=@customcode,bindopenid=@bindopenid,servicephone=@servicephone,locationidlist=@locationlist,source=@source,
                                customurlname=@cusurlname,customurl=@cusurl,customurlsubtitle=@cusurlsub,promotionurlname=@prourlname,promotionurl=@prourl,promotionurlsubtitle=@prourlsub,
                                getlimit=@getlimit,canshare=@canshare,cangivefriend=@cangive,cardstatus=@status,leastcost=@leastcost,reducecost=@reducecost,defaultdetail=@dedetail
                                where configkey=@configkey and cardid=@cardid;";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@configkey", Configkey));
                paras.Add(new SqlParameter("@cardid", cardid));
                paras.Add(new SqlParameter("@cardtype", cardtype));
                paras.Add(new SqlParameter("@logo", logourl));
                paras.Add(new SqlParameter("@codetype", codetype));
                paras.Add(new SqlParameter("@brandname", brandname));
                paras.Add(new SqlParameter("@title", title));
                paras.Add(new SqlParameter("@subtitle", subtitle));
                paras.Add(new SqlParameter("@color", WXCardColors(color)));                
                paras.Add(new SqlParameter("@notice", notice));
                paras.Add(new SqlParameter("@desc", description));
                paras.Add(new SqlParameter("@total", total));
                paras.Add(new SqlParameter("@quantity", quantity));
                paras.Add(new SqlParameter("@datetype", datetype));
                paras.Add(new SqlParameter("@begintime", Convert.ToString(ConvertUnix2Time(begintime))));
                paras.Add(new SqlParameter("@endtime", Convert.ToString(ConvertUnix2Time(endtime))));
                paras.Add(new SqlParameter("@fterm", fixedterm));
                paras.Add(new SqlParameter("@fbterm", fixedbeginterm));
                paras.Add(new SqlParameter("@customcode", customcode));
                paras.Add(new SqlParameter("@bindopenid", bindopenid));
                paras.Add(new SqlParameter("@servicephone", servicephone));
                paras.Add(new SqlParameter("@locationlist", locationlist));
                paras.Add(new SqlParameter("@source", source));
                paras.Add(new SqlParameter("@cusurlname", customurlname));
                paras.Add(new SqlParameter("@cusurl", customurl));
                paras.Add(new SqlParameter("@cusurlsub", customsub));
                paras.Add(new SqlParameter("@prourlname", prourlname));
                paras.Add(new SqlParameter("@prourl", prourl));
                paras.Add(new SqlParameter("@prourlsub", prourlsub));
                paras.Add(new SqlParameter("@getlimit", getlimit));
                paras.Add(new SqlParameter("@canshare", canshare));
                paras.Add(new SqlParameter("@cangive", cangive));
                paras.Add(new SqlParameter("@status", status));
                paras.Add(new SqlParameter("@leastcost", leastcost));
                paras.Add(new SqlParameter("@reducecost", reducecost));
                paras.Add(new SqlParameter("@dedetail", dedetail));

                string errinfo = dal62.ExecuteNonQuerySecurity(str_sql, paras);
                if (errinfo == "")
                    rt = "Successed";
                else
                    rt = "Error:" + errinfo;
                    
            }//end using                       
        }
        else {
            rt = "获取【" + cardid + "】卡券信息失败！ INFOS:" + content + " WXINFOS:" + cd;
            WriteLog("获取【" + cardid + "】卡券信息失败！ INFOS:" + content+" WXINFOS:"+cd);
        }

        return rt;    
    }
    
    //批量查询卡券列表
    /// <param name="offset">起始偏移量</param>
    /// <param name="count">拉取的数量</param>    
    public string GetCardIDList(string key, int offset, int count)
    {
        string url = string.Format("https://api.weixin.qq.com/card/batchget?access_token={0}", GetToken(key));
        string _data = @"{{
                          ""offset"": {0},
                          ""count"": {1}
                        }}";
        _data = string.Format(_data, offset, count);
        string content = PostDataToWX(url, _data);
        return content;
    }

    //该方法用于创建卡券成功后更新cardid
    public bool UpCreCardInfo(string id, string cardid)
    {
        bool rt = true;
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr))
        {
            string str_sql = @"if exists (select top 1 1 from wx_t_cardinfos where id=@id)
                                begin
                                  update wx_t_cardinfos set cardid=@cardid where id=@id;
                                  select '11';
                                end
                                else
                                  select '00';";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@id", id));
            paras.Add(new SqlParameter("@cardid", cardid));
            object scalar;
            string errinfo = dal62.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
            if (errinfo == "")
                if (Convert.ToString(scalar) == "11")
                    rt = true;
                else
                {
                    WriteLog("更新【ID=" + id + "】 【CARDID=" + cardid + "】发现记录不存在！");
                    rt = false;
                }
        }//end using    

        return rt;
    }

    //查询卡券信息    
    public void GetCardDetail(string cardid)
    {
        string _key = getConfigKey(cardid,"");
        string url = string.Format("https://api.weixin.qq.com/card/get?access_token={0}", GetToken(_key));
        string _data = string.Format(@"{{""card_id"":""{0}""}}", cardid);
        string content = PostDataToWX(url, _data);
        clsSharedHelper.WriteInfo(content);
    }
    
    //删除卡券 对于已经发出的CODE仍然有效，仍然可以使用！！！！
    //删除卡券接口允许商户删除任意一类卡券。删除卡券后，该卡券对应已生成的领取用二维码、添加到卡包JS API均会失效。 
    //注意：如用户在商家删除卡券前已领取一张或多张该卡券依旧有效。即删除卡券不能删除已被用户领取，保存在微信客户端中的卡券。
    public void DelWXCard(string cardid) {
        //先更新微信服务器再操作本地数据库
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr)) {
            string _key = getConfigKey(cardid, "");
            string url = string.Format("https://api.weixin.qq.com/card/delete?access_token={0}", GetToken(_key));
            string _data = string.Format(@"{{""card_id"":""{0}""}}", cardid);
            string content = PostDataToWX(url, _data);
            JObject jo = JObject.Parse(content);
            if (Convert.ToString(jo["errcode"]) == "0")
            {
                string str_sql = @"update wx_t_cardinfos set isdel=1,cardstatus='CARD_STATUS_DELETE' where cardid=@cardid and configkey=@configkey";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@cardid", cardid));
                para.Add(new SqlParameter("@configkey", _key));
                string errinfo = dal.ExecuteNonQuerySecurity(str_sql, para);
                if (errinfo == "")
                    clsSharedHelper.WriteSuccessedInfo("");
                else
                    clsSharedHelper.WriteErrorInfo(errinfo);
            }
            else
                clsSharedHelper.WriteErrorInfo(content);
        }    
    }
    
    //查询卡券状态   
    public string GetCardStatus(string cardid, string cardtype, bool isModify)
    {
        string status = "";
        string _key = getConfigKey(cardid, "");
        string url = string.Format("https://api.weixin.qq.com/card/get?access_token={0}", GetToken(_key));
        string _data = string.Format(@"{{""card_id"":""{0}""}}", cardid);
        string content = PostDataToWX(url, _data);
        JObject jo = JObject.Parse(content);
        if (Convert.ToString(jo["errcode"]) == "0")
        {
            status = Convert.ToString(jo["card"][cardtype.ToLower()]["base_info"]["status"]);
            //是否要更新该卡券的状态信息
            if (isModify)
            {
                using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr))
                {
                    string sql = string.Format("update wx_t_cardinfos set cardstatus=@status where cardid='{0}' and configkey='{1}'", cardid, _key);
                    List<SqlParameter> paras = new List<SqlParameter>();
                    paras.Add(new SqlParameter("@status", status));
                    string errinfo = dal62.ExecuteNonQuerySecurity(sql, paras);
                    if (errinfo != "")
                        WriteLog("GetCardStatus is error!CARDID=" + cardid + " INFOS:" + errinfo);
                }
            }//end isModify
        }
        else
            WriteLog("GetCardStatus is error!CARDID:" + cardid + " INFOS:" + content);

        return status;
    }

    /// <summary>
    /// 查询门店列表
    /// </summary>
    /// <param name="begin">开始位置，0 即为从第一条开始查询 必填</param>
    /// <param name="limit">返回数据条数，最大允许50，默认为20 必填</param>
    /// <returns></returns>
    public void GetStoresList(string begin, string limit)
    {
        string _data = @"{{
                            ""begin"":{0},
                            ""limit"":{1}
                            }}";
        _data = string.Format(_data, begin, limit);
        string url = string.Format("https://api.weixin.qq.com/cgi-bin/poi/getpoilist?access_token={0}", GetToken(Configkey));
        string content = PostDataToWX(url, _data);
        clsSharedHelper.WriteInfo(content);
    }

    /// <summary>
    /// 查询单个门店的信息
    /// </summary>
    /// <param name="poid"></param>
    /// <returns></returns>
    public void GetStoreInfo(string poid)
    {
        string _data = string.Format(@"{{""poi_id"":{0}}}", poid);
        string url = string.Format("http://api.weixin.qq.com/cgi-bin/poi/getpoi?access_token={0}", GetToken(Configkey));
        string content = PostDataToWX(url, _data);
        clsSharedHelper.WriteInfo(content);
    }

    //将时间转换成UNIX时间戳
    private int ConvertDateTimeInt(System.DateTime time)
    {
        System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1));
        return (int)(time - startTime).TotalSeconds;
    }

    //将时间戳转换成日期
    private DateTime ConvertUnix2Time(string timeStamp)
    {
        DateTime dtStart = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        long lTime = long.Parse(timeStamp + "0000000");
        TimeSpan toNow = new TimeSpan(lTime); return dtStart.Add(toNow);
    }

    /// <summary>
    ///用FORM表单方式向微信服务器上传图片
    ///开发者需调用该接口上传商户图标至微信服务器，获取相应logo_url，用于卡券创建
    /// </summary>
    /// <param name="access_token"></param>
    /// <param name="path">图片在服务器上的文件路径</param>
    /// <returns></returns>
    public static string HttpUploadFileServer(string path, string access_token)
    {
        string url = string.Format("https://api.weixin.qq.com/cgi-bin/media/uploadimg?access_token={0}", access_token);
        // 设置参数
        HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest;
        CookieContainer cookieContainer = new CookieContainer();
        request.CookieContainer = cookieContainer;
        request.AllowAutoRedirect = true;
        request.Method = "POST";
        string boundary = DateTime.Now.Ticks.ToString("X"); // 随机分隔线
        request.ContentType = "multipart/form-data;charset=utf-8;boundary=" + boundary;
        byte[] itemBoundaryBytes = Encoding.UTF8.GetBytes("\r\n--" + boundary + "\r\n");
        byte[] endBoundaryBytes = Encoding.UTF8.GetBytes("\r\n--" + boundary + "--\r\n");

        int pos = path.LastIndexOf("\\");
        string fileName = path.Substring(pos + 1);

        //请求头部信息 
        StringBuilder sbHeader = new StringBuilder(string.Format("Content-Disposition:form-data;name=\"{0}\";filename=\"{1}\"\r\nContent-Type:application/octet-stream\r\n\r\n", "media", fileName));
        byte[] postHeaderBytes = Encoding.UTF8.GetBytes(sbHeader.ToString());

        FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read);
        byte[] bArr = new byte[fs.Length];
        fs.Read(bArr, 0, bArr.Length);
        fs.Close();

        Stream postStream = request.GetRequestStream();
        postStream.Write(itemBoundaryBytes, 0, itemBoundaryBytes.Length);
        postStream.Write(postHeaderBytes, 0, postHeaderBytes.Length);
        postStream.Write(bArr, 0, bArr.Length);
        postStream.Write(endBoundaryBytes, 0, endBoundaryBytes.Length);
        postStream.Close();

        //发送请求并获取相应回应数据
        HttpWebResponse response = request.GetResponse() as HttpWebResponse;
        //直到request.GetResponse()程序才开始向目标网页发送Post请求
        Stream instream = response.GetResponseStream();
        StreamReader sr = new StreamReader(instream, Encoding.UTF8);
        //返回结果网页（html）代码
        string content = sr.ReadToEnd();
        return content;
    }

    //该方法主要将客户端页面表单提交的图片直接上传至微信
    public static string HttpUploadFileClient(HttpPostedFile file, string access_token)
    {
        string url = string.Format("https://api.weixin.qq.com/cgi-bin/media/uploadimg?access_token={0}", access_token);
        // 设置参数
        HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest;
        CookieContainer cookieContainer = new CookieContainer();
        request.CookieContainer = cookieContainer;
        request.AllowAutoRedirect = true;
        request.Method = "POST";
        string boundary = DateTime.Now.Ticks.ToString("X"); // 随机分隔线
        request.ContentType = "multipart/form-data;charset=utf-8;boundary=" + boundary;
        byte[] itemBoundaryBytes = Encoding.UTF8.GetBytes("\r\n--" + boundary + "\r\n");
        byte[] endBoundaryBytes = Encoding.UTF8.GetBytes("\r\n--" + boundary + "--\r\n");

        //请求头部信息 
        StringBuilder sbHeader = new StringBuilder(string.Format("Content-Disposition:form-data;name=\"{0}\";filename=\"{1}\"\r\nContent-Type:application/octet-stream\r\n\r\n", "media", file.FileName));
        byte[] postHeaderBytes = Encoding.UTF8.GetBytes(sbHeader.ToString());

        Stream fs = file.InputStream;
        byte[] bArr = new byte[fs.Length];
        fs.Read(bArr, 0, bArr.Length);
        fs.Close();

        Stream postStream = request.GetRequestStream();
        postStream.Write(itemBoundaryBytes, 0, itemBoundaryBytes.Length);
        postStream.Write(postHeaderBytes, 0, postHeaderBytes.Length);
        postStream.Write(bArr, 0, bArr.Length);
        postStream.Write(endBoundaryBytes, 0, endBoundaryBytes.Length);
        postStream.Close();

        //发送请求并获取相应回应数据
        HttpWebResponse response = request.GetResponse() as HttpWebResponse;
        Stream instream = response.GetResponseStream();
        StreamReader sr = new StreamReader(instream, Encoding.UTF8);
        //返回结果网页（html）代码
        string content = sr.ReadToEnd();
        return content;
    }

    //获取ACCESS_TOKEN
    public string GetToken(string configkey)
    {
        string _AT = "";
        using (LiLanzDALForXLM dal23 = new LiLanzDALForXLM("server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion"))
        {
            string str_sql = "select top 1 accesstoken from wx_t_tokenconfiginfo where configkey='" + configkey + "'";
            object scaler = null;
            string errinfo = dal23.ExecuteQueryFast(str_sql, out scaler);
            if (errinfo == "")
            {
                _AT = Convert.ToString(scaler);
                if (_AT == "")
                    WriteLog("找不到ConfigKey的ACCESS_TOKEN！");
            }
            else
                WriteLog("查询ACCESS_TOKEN时出错 ConfigKey:" + configkey + " " + errinfo);
        }

        return _AT;
    }

    /// <summary>
    /// POST一段信息给微信服务器
    /// </summary>
    /// <param name="url">目标方法的API的URL</param>
    /// <param name="postData">POS数据</param>
    private string PostDataToWX(string url, string postData)
    {
        try
        {
            Stream outstream = null;
            Stream instream = null;
            StreamReader sr = null;
            HttpWebResponse response = null;
            HttpWebRequest request = null;
            Encoding encoding = Encoding.UTF8;
            byte[] data = encoding.GetBytes(postData);
            request = WebRequest.Create(url) as HttpWebRequest;
            CookieContainer cookieContainer = new CookieContainer();
            request.CookieContainer = cookieContainer;
            request.AllowAutoRedirect = true;
            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            request.ContentLength = data.Length;
            outstream = request.GetRequestStream();
            outstream.Write(data, 0, data.Length);
            outstream.Close();
            //发送请求并获取相应回应数据
            response = request.GetResponse() as HttpWebResponse;
            instream = response.GetResponseStream();
            sr = new StreamReader(instream, encoding);
            string content = sr.ReadToEnd();
            return content;
        }
        catch (Exception ex)
        {
            WriteLog("远程调用异常：" + ex.Message);
            return ex.Message;
        }
    }

    //依据CARDID或CARDCODE获取对应的公众号ID
    public string getConfigKey(string cardid,string cardcode) {
        string key = "";
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConstr)) {
            string str_sql = @"select top 1 a.configkey
                                from wx_t_cardinfos a
                                left join wx_t_cardcodes b on a.cardid=b.cardid
                                where a.cardid=@cardid or b.cardcode=@cardcode";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@cardid", cardid));
            paras.Add(new SqlParameter("@cardcode", cardcode));
            object scalar;
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
            if (errinfo == "" && Convert.ToString(scalar) != "")
                key = Convert.ToString(scalar);
        }

        return key;
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

    //卡券颜色代码对照
    public string WXCardColors(string dm) {
        string color = "";
        switch (dm) {
            case "#63b359":
                color = "Color010";
                break;
            case "#2c9f67":
                color = "Color020";
                break;
            case "#509fc9":
                color = "Color030";
                break;
            case "#5885cf":
                color = "Color040";
                break;
            case "#9062c0":
                color = "Color050";
                break;
            case "#d09a45":
                color = "Color060";
                break;
            case "#e4b138":
                color = "Color070";
                break;
            case "#ee903c":
                color = "Color080";
                break;
            case "#f08500":
                color = "Color081";
                break;
            case "#a9d92d":
                color = "Color082";
                break;
            case "#dd6549":
                color = "Color090";
                break;
            case "#cc463d":
                color = "Color100";
                break;
            case "#cf3e36":
                color = "Color101";
                break;
            case "#5E6671":
                color = "Color102";
                break;            
        }

        return color;
    }
    
    //微信返回码翻译
    public string CardErrorTips(int errcode)
    {
        string ErrMsg = "";
        switch (errcode)
        {
            case -1:
                ErrMsg = "系统繁忙，此时请开发者稍候再试。";
                break;
            case 40009:
                ErrMsg = "图片文件超长。";
                break;
            case 40013:
                ErrMsg = "不合法的Appid，请开发者检查AppID的正确性，避免异常字符，注意大小写。";
                break;
            case 40053:
                ErrMsg = "不合法的actioninfo，请开发者确认参数正确。";
                break;
            case 40071:
                ErrMsg = "不合法的卡券类型。";
                break;
            case 40072:
                ErrMsg = "不合法的编码方式。";
                break;
            case 40078:
                ErrMsg = "不合法的卡券状态。";
                break;
            case 40079:
                ErrMsg = "不合法的时间。";
                break;
            case 40080:
                ErrMsg = "不合法的CardExt。";
                break;
            case 40099:
                ErrMsg = "卡券已被核销。";
                break;
            case 40100:
                ErrMsg = "不合法的时间区间。";
                break;
            case 40116:
                ErrMsg = "不合法的Code码。";
                break;
            case 40122:
                ErrMsg = "不合法的库存数量。";
                break;
            case 40124:
                ErrMsg = "会员卡设置查过限制的 custom_field字段。";
                break;
            case 40127:
                ErrMsg = "卡券被用户删除或转赠中。";
                break;
            case 41012:
                ErrMsg = "缺少cardid参数。";
                break;
            case 45030:
                ErrMsg = "该cardid无接口权限。";
                break;
            case 45031:
                ErrMsg = "库存为0。";
                break;
            case 45033:
                ErrMsg = "用户领取次数超过限制get_limit。";
                break;
            case 41011:
                ErrMsg = "缺少必填字段。";
                break;
            case 45021:
                ErrMsg = "字段超过长度限制，请参考相应接口的字段说明。";
                break;
            case 40056:
                ErrMsg = "不合法的Code码。";
                break;
            case 43009:
                ErrMsg = "自定义SN权限，请前往公众平台申请。";
                break;
            case 43010:
                ErrMsg = "无储值权限，请前往公众平台申请。";
                break;
            default:
                ErrMsg = "未知错误！";
                break;
        }

        return ErrMsg;
    }
</script>


<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
        </div>
    </form>
</body>
</html>
