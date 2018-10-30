<%@ Page Language="C#" ValidateRequest="false" %>

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
    /// 该页面主要负责接收相关微信接口页转发数据过来的接收处理
    /// </summary>    
    public string Configkey = "5";//利郎男装
    private const string ObjectID = "1";//利郎男装

    #region 微信接口验证

    const string Token = "jWBinob5hPpRWBIUtUPou5TkPn5KhiI5"; //你的token  
    string signature;
    string timestamp;
    string nonce;

    string fromUsername = "";
    string toUsername = "";

    ///
    /// 验证微信签名
    ///
    /// * 将token、timestamp、nonce三个参数进行字典序排序
    /// * 将三个参数字符串拼接成一个字符串进行sha1加密
    /// * 开发者获得加密后的字符串可与signature对比，标识该请求来源于微信。
    ///
    private bool CheckSignature()
    {
        signature = Request.QueryString["signature"];
        timestamp = Request.QueryString["timestamp"];
        nonce = Request.QueryString["nonce"];
        string[] ArrTmp = { Token, timestamp, nonce };
        Array.Sort(ArrTmp);     //字典排序
        string tmpStr = string.Join("", ArrTmp);
        tmpStr = FormsAuthentication.HashPasswordForStoringInConfigFile(tmpStr, "SHA1");
        tmpStr = tmpStr.ToLower();
        if (tmpStr == signature)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    private void Valid()
    {
        string echoStr = Request.QueryString["echostr"];
        if (CheckSignature())
        {
            if (!string.IsNullOrEmpty(echoStr))
            {
                Response.Write(echoStr);
                Response.End();
            }
        }
    }
    #endregion



    /// <summary>
    /// POST一段信息给其它服务器
    /// </summary>
    /// <param name="url">目标方法的API的URL</param>
    /// <param name="postData">POS数据</param>
    private string RePostData(string url, string postData)
    {
        WriteLog("开始远程调用..");
        try
        {
            Stream outstream = null;
            Stream instream = null;
            StreamReader sr = null;
            HttpWebResponse response = null;
            HttpWebRequest request = null;
            Encoding encoding = Encoding.UTF8;
            byte[] data = encoding.GetBytes(postData);
            // 准备请求...
            // 设置参数
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
            //直到request.GetResponse()程序才开始向目标网页发送Post请求
            instream = response.GetResponseStream();
            sr = new StreamReader(instream, encoding);
            //返回结果网页（html）代码
            string content = sr.ReadToEnd();

            return content;
        }
        catch (Exception ex)
        {
            WriteLog("【利郎男装接口回调】转发报文异常！错误：" + ex.Message);
            return ex.Message;
        }
    }

    private void CheckPoint(int index)
    {
        return;
        //if (fromUsername == "oarMEt3YWz0gndx1RmWolC423swM")
        //{
        //    clsLocalLoger.WriteInfo(string.Concat("检查点",index));
        //}
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.HttpMethod.ToLower() != "post")
        {
            Valid();
            return;
        }
        Stream postData = Request.InputStream;
        StreamReader sRead = new StreamReader(postData);
        string postContent = sRead.ReadToEnd();
        sRead.Dispose();


        XmlDocument px = new XmlDocument();
        px.LoadXml(postContent);
        string msgType = px.GetElementsByTagName("MsgType")[0].InnerText;
        //报文如果是文本消息，则把报文post 到http://tm.lilanz.com/chat/callback
        //return;

        fromUsername = px.GetElementsByTagName("FromUserName")[0].InnerText;
        toUsername = px.GetElementsByTagName("ToUserName")[0].InnerText;

        if (fromUsername == "oarMEt3YWz0gndx1RmWolC423swM")
        {
            clsLocalLoger.WriteInfo("[公众号]收到：" + postContent);
        }

        CheckPoint(3);

        if (px.GetElementsByTagName("MsgType")[0].InnerText == "text")  //转发到姚总NodeJs的页面
        {
            string content = RePostData("http://10.0.0.15/chat/callback", postContent);
            clsLocalLoger.WriteInfo(string.Format("转发结果：{0}", content));
            Response.Write(content);
            return;
        }

        CheckPoint(4);

        if (msgType == "location")
        {
            if (SaveLocationInfo(fromUsername, Convert.ToDecimal(px.GetElementsByTagName("Location_X")[0].InnerText)
                , Convert.ToDecimal(px.GetElementsByTagName("Location_Y")[0].InnerText), Convert.ToDecimal(px.GetElementsByTagName("Scale")[0].InnerText)))
            {
                backText("根据您提供的位置信息，我们为您推荐附近的利郎门店！请点击<a href='http://tm.lilanz.com/project/vipweixin/storelists.aspx'>这里</a>查看！");
            }
            else
            {
                backText("系统暂时不能为您提供服务！");
            }
            return;
        }


        if (msgType == "event")
        {
            string xEvent = px.GetElementsByTagName("Event")[0].InnerText;
            if (xEvent == "CLICK")
            {
                //if (px.GetElementsByTagName("EventKey")[0].InnerText == "wsxn")
                //{
                //    backText("《我是型男》6月13日正式报名启动，敬请关注！");
                //    return;
                //}
            }

            if (xEvent == "WifiConnected")
            {
                WriteLog("扫码连WIFI");
                string shopid = px.GetElementsByTagName("ShopId")[0].InnerText; //表示扫码连WIFI  总部轻商务的门店ID为2920429

                clsWXHelper.UpdateGzhUserInfo(Configkey, fromUsername);
                clsWXHelper.WxUserSubscribe(fromUsername, clsWXHelper.SubscribeType.WxWifi);
            }
            else if (xEvent == "subscribe" || xEvent == "SCAN")
            {
                //关注
                clsWXHelper.UpdateGzhUserInfo(Configkey, fromUsername);
                if (px.GetElementsByTagName("EventKey").Count > 0)  //该参数是带二维码的参数
                {

                    CheckPoint(41);
                    string CodeValue = px.GetElementsByTagName("EventKey")[0].InnerText;

                    if (CodeValue.StartsWith("qrscene_"))       //扫描带信息的关注二维码
                    {
                        CheckPoint(42);
                        if (xEvent == "subscribe") clsWXHelper.WxUserSubscribe(fromUsername, clsWXHelper.SubscribeType.ScanQrCode);

                        CodeValue = CodeValue.Replace("qrscene_", "");

                        CheckPoint(43);
                        clsWXHelper.WriteQrcodeInfo(CodeValue, fromUsername, ObjectID);
                    }
                    else if (CodeValue.StartsWith("last_trade_no_"))   //由交易引导而来的关注     
                    {
                        CheckPoint(44);
                        clsWXHelper.WxUserSubscribe(fromUsername, clsWXHelper.SubscribeType.WxPay);

                        string trade_no = CodeValue.Replace("last_trade_no_", "");
                        CodeValue = "88888888";
                        clsWXHelper.WriteQrcodeInfo(CodeValue, fromUsername, ObjectID);
                        CheckPoint(45);
                    }
                    else
                    {
                        CheckPoint(46);
                        if (xEvent == "subscribe") clsWXHelper.WxUserSubscribe(fromUsername, clsWXHelper.SubscribeType.Default);
                    }
                    CheckPoint(5);
                    //吸粉操作
                    if (CodeValue == "60001")
                    {
                        CheckPoint(51);
                        System.Data.DataRow dr = FansSaleBind.GetFansSaleRowInfo(fromUsername);
                        if (dr != null)
                        {CheckPoint(52);
                            backPic(string.Concat("指定您的专属顾问【", dr["cname"], "】"), "专属顾问是尊贵的利郎会员服务，系统需要先识别您的会员身份！请点击“阅读全文”，绑定（或注册）您的会员信息。"
                                , "http://tm.lilanz.com/res/img/vipweixin/vsb.jpg", "http://tm.lilanz.com/project/vipweixin/JoinUS.aspx");
                            return;
                        }
                        else
                        {CheckPoint(53);
                            backText("感谢您关注本公众号！");
                        }
                        return;
                    }
                    CheckPoint(6);
                }
                else
                {
                    clsWXHelper.WxUserSubscribe(fromUsername, clsWXHelper.SubscribeType.Default);
                }
                CheckPoint(7);
                //response.write("返回图文消息报文");
                //Act1900(fromUsername, toUsername);
                return;
            }
            else if (xEvent == "unsubscribe")
            {
                clsWXHelper.WxUserDisSubscribe(fromUsername);
                return;
            }
            else if (xEvent.ToUpper() == "LOCATION")//收集定时发送的位置记录
            {
                SaveLocationInfo(fromUsername, Convert.ToDecimal(px.GetElementsByTagName("Latitude")[0].InnerText)
                , Convert.ToDecimal(px.GetElementsByTagName("Longitude")[0].InnerText), Convert.ToDecimal(px.GetElementsByTagName("Precision")[0].InnerText));
                //不管有没有正确处理，都返回这个
                clsSharedHelper.WriteInfo("");
                return;
            }
            else
            {   //尝试卡券的判断
                //微信推送过来的事件信息            
                string eventName = xEvent;
                List<String> cardEvents = new List<string>();
                cardEvents.Add("card_pass_check");//卡券审核通过事件
                cardEvents.Add("card_not_pass_check");//卡券审核未通过事件
                cardEvents.Add("user_get_card");//用户领取卡券事件
                cardEvents.Add("user_del_card");//用户删除事件
                cardEvents.Add("user_consume_card");//核销事件
                cardEvents.Add("user_pay_from_pay_cell");//买单事件
                cardEvents.Add("user_view_card");//进入会员卡事件
                cardEvents.Add("update_member_card");//会员卡内容更新事件
                cardEvents.Add("user_enter_session_from_card");//从卡券进入公众号事件
                cardEvents.Add("card_sku_remind");//库存报警事件                  

                if (cardEvents.Contains(eventName))
                {
                    //卡券事件推送
                    cardEvent(postContent);
                }
                else if (eventName == "MASSSENDJOBFINISH")
                {
                    //群发结果报告
                    WriteLog(postContent);
                    massMessageEvent(postContent);
                }
            }
        }
    }



    private bool SaveLocationInfo(string wxOpenid, decimal Lat, decimal Lon, decimal Precision)
    {
        string wxConn = clsWXHelper.GetWxConn();
        string strInfo = "";
        using (LiLanzDALForXLM wxdal = new LiLanzDALForXLM(wxConn))
        {
            string strSQL = @"insert into [wx_userPosition] 
                        (wxOpenid,Lat,Lon,Precision) values (@wxOpenid,@Lat,@Lon,@Precision) ";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@wxOpenid", fromUsername));
            paras.Add(new SqlParameter("@Lat", Lat));
            paras.Add(new SqlParameter("@Lon", Lon));
            paras.Add(new SqlParameter("@Precision", Precision));

            strInfo = wxdal.ExecuteNonQuerySecurity(strSQL, paras);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("[利郎男装接口页]接收地理位置信息失败！错误：", strInfo));
                return false;
            }

            return true;
        }
    }


    public string WXDBConstr()
    {

        return clsWXHelper.GetWxConn();
    }


    //public void Act1900(string fromUsername, string toUsername)   //睿智活动
    //{
    //    string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    //    string strInfo = "";
    //    using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(OAConnStr))
    //    {
    //        string strSQL = @"SELECT TOP 1 ISNULL(khid,0) 'khid' FROM wx_t_vipBinging WHERE wxOpenid = @wxOpenid";
    //        List<SqlParameter> paras = new List<SqlParameter>();
    //        paras.Add(new SqlParameter("@wxOpenid", fromUsername));
    //        object objKhid = 0;
    //        strInfo = dal10.ExecuteQueryFastSecurity(strSQL, paras, out objKhid);
    //        if (strInfo != "")
    //        {
    //            clsLocalLoger.WriteError(string.Format("[睿智五一活动]查询关注人所属khid失败！错误：" , strInfo));
    //            clsSharedHelper.WriteInfo("");
    //            return;
    //        }

    //        int khid = 0;
    //        if (objKhid != null) khid = Convert.ToInt32(objKhid);

    //        objKhid = null;
    //        int mygskhid = 1900;
    //        strSQL = string.Format(@"SELECT TOP 1 khid FROM YX_T_khgxb 
    //                WHERE khid = {0} AND gxid = {1} AND ty = 0
    //                AND ksny <= year(GETDATE()) * 100 + MONTH(GETDATE()) AND jsny >= year(GETDATE()) * 100 + MONTH(GETDATE()) ", mygskhid, khid);

    //        strInfo = dal10.ExecuteQueryFast(strSQL, out objKhid);
    //        if (strInfo != "")
    //        {
    //            clsLocalLoger.WriteError(string.Format("[睿智五一活动]查询客户关系表失败！错误：", strInfo));
    //            clsSharedHelper.WriteInfo("");
    //            return;
    //        }
    //        if (objKhid == null) clsSharedHelper.WriteInfo("");
    //        else
    //        {
    //            //if (fromUsername == "oarMEt3YWz0gndx1RmWolC423swM")     //测试薛灵敏的微信号
    //            backPic(fromUsername, toUsername, "【睿智专属】男人坚持30秒难不难？试试就知道！", "你能坚持15秒算我输了..."
    //                , "http://mmbiz.qpic.cn/mmbiz_png/wrgiaawibvBmD4LcCy5P1yagKkjCFUq73sU78cet6EaXtY4c3icC0M0CoKjeQCwjVEyCLSY7LGnuFnBWRclSgdlYQ/0?tp=webp&wxfrom=5&wx_lazy=1"
    //                , "http://mp.weixin.qq.com/s/WdDUVF2TuTGTSP1HbHS3pg");
    //        }
    //    }
    //}

    private void backText(string strMsg)
    {
        string msg = @"<xml> 
                    <ToUserName><![CDATA[{0}]]></ToUserName>
                    <FromUserName><![CDATA[{1}]]></FromUserName>
                    <CreateTime>{2}</CreateTime>
                    <MsgType><![CDATA[text]]></MsgType>
                    <Content><![CDATA[{3}]]></Content>
                    <FuncFlag>0</FuncFlag>
                    </xml>";

        msg = String.Format(msg, fromUsername, toUsername, ConvertDateTimeInt(DateTime.Now)
                            , strMsg);
        Response.Clear();
        Response.Write(msg);
        Response.End();
    }

    private void backPic(string title, string body, string picUrl, string DumpUrl)
    {
        backPic(fromUsername, toUsername, title, body, picUrl, DumpUrl);
    }

    private void backPic(string fromUsername, string toUsername,string title, string body, string picUrl, string DumpUrl)
    {
        //加载图文模版
        string picTpl = @"<xml>
        					 <ToUserName><![CDATA[{0}]]></ToUserName>
        					 <FromUserName><![CDATA[{1}]]></FromUserName>
        					 <CreateTime>{2}</CreateTime>
        					 <MsgType><![CDATA[news]]></MsgType>
        					 <ArticleCount>1</ArticleCount>
        					 <Articles>
        					 <item>
        					 <Title><![CDATA[{3}]]></Title>
        					 <Description><![CDATA[{4}]]></Description>
        					 <PicUrl><![CDATA[{5}]]></PicUrl>
        					 <Url><![CDATA[{6}]]></Url>
        					 </item>
        					 </Articles> 
        					 </xml> ";
        picTpl = string.Format(picTpl, fromUsername, toUsername, ConvertDateTimeInt(DateTime.Now),
            title, body, picUrl, DumpUrl);
        Response.Clear();
        Response.Write(picTpl);
        Response.End();
    }


    private int ConvertDateTimeInt(System.DateTime time)
    {
        System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1));
        return (int)(time - startTime).TotalSeconds;
    }


    //卡券事件处理函数
    public void cardEvent(string xmlStr)
    {
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr()))
        {
            XmlDocument px = new XmlDocument();
            px.LoadXml(xmlStr);
            string tousername = px.GetElementsByTagName("ToUserName")[0].InnerText;
            //gh_ad354904c302(利郎男装) gh_4eadcad20982(利郎轻商务)
            string _configkey = "";
            if (tousername == "gh_ad354904c302")
                _configkey = "5";
            else if (tousername == "gh_4eadcad20982")
                _configkey = "7";
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
                    //20170331 liqf 加入来源判断是哪个公众号推送的事件记录 touserfrom configkey
                    string isgiven = px.GetElementsByTagName("IsGiveByFriend")[0].InnerText;
                    string olduser = px.GetElementsByTagName("FriendUserName")[0].InnerText;
                    string oldcode = px.GetElementsByTagName("OldUserCardCode")[0].InnerText;
                    string outerid = px.GetElementsByTagName("OuterId")[0].InnerText;
                    str_sql = @"  if not exists(select top 1 1 from wx_t_CardCodes where cardid=@cardid and cardcode=@cardcode)  
                                    begin                                   
                                      declare @relationID int;
                                      select @relationID=min(id) from wx_t_CardRelation where openid=@getuser and cardcode=@cardid and WXCode='' and isget=0;
                                      insert into wx_t_CardCodes(cardid,cardcode,isget,getuser,outerid,gettime,isconsume,usercardstatus,canconsume,IsGiveByFriend,FriendUserName,oldusercardcode,touserfrom,configkey)
                                      values(@cardid,@cardcode,1,@getuser,@outerid,getdate(),0,'NORMAL',1,@isgiven,@olduser,@oldcode,@touserfrom,@key);
                                      update wx_t_CardRelation set WXCode=@cardcode,isget=1,gettime=getdate() where id=@relationID and openid=@getuser and cardcode=@cardid and WXCode='';
                                    end
                                  if @isgiven='1'
                                    update wx_t_CardCodes set usercardstatus='GIFT_SUCC',canconsume=0 where cardid=@cardid and cardcode=@oldcode and touserfrom=@touserfrom;";
                    paras.Add(new SqlParameter("@cardid", cardid));
                    paras.Add(new SqlParameter("@cardcode", cardcode));
                    paras.Add(new SqlParameter("@getuser", getusername));
                    paras.Add(new SqlParameter("@outerid", outerid));
                    paras.Add(new SqlParameter("@isgiven", isgiven));
                    paras.Add(new SqlParameter("@olduser", olduser));
                    paras.Add(new SqlParameter("@oldcode", oldcode));
                    paras.Add(new SqlParameter("@touserfrom", tousername));
                    paras.Add(new SqlParameter("@key", _configkey));
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

                if (errinfo == "")
                    //WriteLog("卡券事件推送 结果处理成功！TYPE:" + eventType + " CARDID:" + cardid + " CARD_CODE:" + cardcode + " SQL:" + str_sql);
                    WriteLog("卡券事件推送【CardEventFunc】:" + xmlStr);
                else
                    WriteLog("卡券事件推送 结果处理失败！INFOS:" + errinfo + " TYPE:" + eventType + " CARDID:" + cardid + " CARD_CODE:" + cardcode + eventType + " SQL:" + str_sql);
            }//end execute sql
        }//end using
    }

    //处理群发任务后微信推送的发送结果报告
    public void massMessageEvent(string xmlstr)
    {
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConstr()))
        {
            XmlDocument px = new XmlDocument();
            px.LoadXml(xmlstr);
            string eventName = px.GetElementsByTagName("Event")[0].InnerText.ToUpper();
            if (eventName == "MASSSENDJOBFINISH")
            {
                string msgid = px.GetElementsByTagName("MsgID")[0].InnerText;
                string status = px.GetElementsByTagName("Status")[0].InnerText;//群发的结果，为“send success”或“send fail”或“err(num)”
                int total = Convert.ToInt32(px.GetElementsByTagName("TotalCount")[0].InnerText);//发送时的openid总数   
                int filter = Convert.ToInt32(px.GetElementsByTagName("FilterCount")[0].InnerText);//过滤（过滤是指特定地区、性别的过滤、用户设置拒收的过滤，用户接收已超4条的过滤）后，准备发送的粉丝数，原则上，FilterCount = SentCount + ErrorCount
                int sent = Convert.ToInt32(px.GetElementsByTagName("SentCount")[0].InnerText);//发送成功的粉丝数
                int error = Convert.ToInt32(px.GetElementsByTagName("ErrorCount")[0].InnerText);//发送失败的粉丝数
                string createtime = unixTime2Date(px.GetElementsByTagName("CreateTime")[0].InnerText).ToString("yyyy-MM-dd hh:mm:ss");
                string str_sql = @" if exists (select top 1 1 from wx_t_MessageSendResult where msgid=@msgid)
                                      update wx_t_MessageSendResult set createtime=@createtime,event=@event,status=@status,totalcount=@total,
                                      filtercount=@filter,sentcount=@sent,errorcount=@error where msgid=@msgid
                                    else
                                      insert into wx_t_MessageSendResult(massid,msgid,createtime,event,status,totalcount,filtercount,sentcount,errorcount,creater)
                                      values (0,@msgid,@createtime,@event,@status,@total,@filter,@sent,@error,'mphelper');";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@msgid", msgid));
                paras.Add(new SqlParameter("@createtime", createtime));
                paras.Add(new SqlParameter("@event", eventName));
                paras.Add(new SqlParameter("@status", status));
                paras.Add(new SqlParameter("@total", total));
                paras.Add(new SqlParameter("@filter", filter));
                paras.Add(new SqlParameter("@sent", sent));
                paras.Add(new SqlParameter("@error", error));
                string errinfo = dal62.ExecuteNonQuerySecurity(str_sql, paras);
                if (errinfo != "")
                    WriteLog("处理群发结果报告失败 " + errinfo + "【XMLSTR】:" + xmlstr);
                else
                    WriteLog("【MASSSENDJOBFINISH】" + xmlstr);
            }
        }//end using
    }

    //时间戳转换成日期
    private DateTime unixTime2Date(string timeStamp)
    {
        DateTime dtStart = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        long lTime = long.Parse(timeStamp + "0000000");
        TimeSpan toNow = new TimeSpan(lTime); return dtStart.Add(toNow);
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
