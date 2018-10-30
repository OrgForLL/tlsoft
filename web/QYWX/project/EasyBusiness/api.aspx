<%@ Page Language="C#" Debug="true" ResponseEncoding="UTF-8" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %> 
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    const string Token = "jWBinob5hPpRWBIUtUPou5TkPn5KhiI5"; //你的token 
    private string Appid = "wx60aada4e94aa0b73";          //公众号信息，在Load事件中加载
    private string Secret = "5baaa8061418367e557f2591b03162e5";
    const int imgWidth = 500;       //处理图片的宽度和高度
    const int imgHeight = 500;
    string signature;
    string timestamp;
    string nonce;
    string fromUsername = "", toUsername = "";
    private const string ConfigKey = "7";	//APPID 
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (Request.HttpMethod.ToLower() == "post")
            {
                //Stream s = Request.InputStream;
                //byte[] b = new byte[s.Length];
                //s.Read(b, 0, (int)s.Length);
                //postStr = Encoding.UTF8.GetString(b);
                //WriteLog(postStr);
                //if (postStr != "")
                //{

                //}
                ResponseMsg();
            }
            else
            {
                Valid();
            }
        }
        catch (Exception ex)
        {
            WriteLog(ex.ToString());
        }
        Response.Flush();
        Response.End();
    }

    ///
    /// 验证微信签名
    ///
    /// * 将token、timestamp、nonce三个参数进行字典序排序
    /// * 将三个参数字符串拼接成一个字符串进行sha1加密
    /// * 开发者获得加密后的字符串可与signature对比，标识该请求来源于微信。
    ///
    private bool CheckSignature()
    {
        signature = Request.QueryString["signature"].ToString();
        timestamp = Request.QueryString["timestamp"].ToString();
        nonce = Request.QueryString["nonce"].ToString();
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
        string echoStr = Request.QueryString["echostr"].ToString();
        if (CheckSignature())
        {
            if (!string.IsNullOrEmpty(echoStr))
            {
                Response.Write(echoStr);
                Response.End();
            }
        }
    }

    /// <summary>
    /// POST一段信息给微信服务器
    /// </summary>
    /// <param name="url">目标方法的API的URL</param>
    /// <param name="postData">POS数据</param>
    private string RePostDataToWX(string url, string postData)
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
            WriteLog("远程调用异常：" + ex.Message);
            return ex.Message;
        }
    }

    ///
    /// 返回信息结果(微信信息返回)
    ///
    ///
    private void ResponseMsg()
    {
        //回复消息的部分:你的代码写在这里
        XmlDocument px = new XmlDocument();
        //Request.InputStream
        //px.LoadXml(weixinXML);
        px.Load(Request.InputStream);
        fromUsername = px.GetElementsByTagName("FromUserName")[0].InnerText;
        toUsername = px.GetElementsByTagName("ToUserName")[0].InnerText;


        string keyword = "";
        String backWord = "";

        if (px.GetElementsByTagName("MsgType")[0].InnerText == "text")
        {
            keyword = px.GetElementsByTagName("Content")[0].InnerText.Replace(" ", "");
            keyword = ToDBC(keyword);//全角转成半角  
        }else if (px.GetElementsByTagName("MsgType")[0].InnerText == "event")
        {
            string Eventname = px.GetElementsByTagName("Event")[0].InnerText;
            if (Eventname == "user_pay_from_pay_cell" || Eventname.Contains("card"))
            {
                //将报文转发一份至以下地址 
                PostDataToWX("http://10.0.0.15/oa/project/interface/WXCallBackReceive.aspx", px.InnerXml);
                WriteLog(px.InnerXml);
                return;
            }

            if (Eventname == "CLICK")
            {
                if (px.GetElementsByTagName("EventKey")[0].InnerText == "play")
                {
                    //backText("拼人气的时候就要到了，玩转游戏赢ipad mini ，还有利郎限量版皮带、皮夹等更多海量豪礼/:gift等你来！");

                    //输出图文信息
                    //backPic("刮刮卡游戏", "恭喜您获得礼品一份！领取礼品需要完善您的身份信息！请点击阅读全文。",
                    //    "http://tm.lilanz.com/res/img/EasyBusiness/ggklogo.jpg", "http://tm.lilanz.com/project/EasyBusiness/nggkGame.aspx");   

                    //List<string[]> listInfo = new List<string[]>();
                    //listInfo.Add(new string[]{"【限利郎轻商务天津一店】玩刮刮卡游戏，赢精美奖品","","http://tm.lilanz.com/res/img/EasyBusiness/ggklogo.jpg","http://tm.lilanz.com/project/EasyBusiness/nggkGame.aspx"});
                    //listInfo.Add(new string[] { "【限利郎轻商务天津一店】刮刮卡领奖通道...", "", "http://tm.lilanz.com/res/img/EasyBusiness/ggklj.jpg", "http://tm.lilanz.com/project/easybusiness/nMyPrizeList.aspx?OAuth=WeiXin" });

                    //backPic(listInfo);

                    return;
                }
                else
                {
                    backText("该功能正在筹备中，敬请期待...");
                    return;
                }
            }
            else if (Eventname == "WifiConnected")
            {
                WriteLog("扫码连WIFI");
                string shopid = px.GetElementsByTagName("ShopId")[0].InnerText; //表示扫码连WIFI  总部轻商务的门店ID为2920429

                clsWXHelper.UpdateGzhUserInfo(ConfigKey, fromUsername);
                UpdateUserInStore(shopid);
                clsWXHelper.WxUserSubscribe(fromUsername, clsWXHelper.SubscribeType.WxWifi);
            }
            else if (Eventname == "subscribe" || Eventname == "SCAN")
            {
                string ObjectID = clsWXHelper.GetObjectID(ConfigKey);
                string CodeValue = "";
                clsWXHelper.UpdateGzhUserInfo(ConfigKey, fromUsername);
                if (Eventname == "subscribe") //该参数是带二维码的参数
                {
                    if (px.GetElementsByTagName("EventKey").Count > 0)
                    {
                        CodeValue = px.GetElementsByTagName("EventKey")[0].InnerText;

                        if (CodeValue.StartsWith("qrscene_"))       //扫描带信息的关注二维码
                        {
                            clsWXHelper.WxUserSubscribe(fromUsername, clsWXHelper.SubscribeType.ScanQrCode);

                            CodeValue = CodeValue.Replace("qrscene_", "");
                            clsWXHelper.WriteQrcodeInfo(CodeValue, fromUsername, ObjectID);
                        }
                        else if (CodeValue.StartsWith("last_trade_no_"))   //由交易引导而来的关注     
                        {
                            clsWXHelper.WxUserSubscribe(fromUsername, clsWXHelper.SubscribeType.WxPay);

                            string trade_no = CodeValue.Replace("last_trade_no_", "");
                            CodeValue = "88888888";
                            clsWXHelper.WriteQrcodeInfo(CodeValue, fromUsername, ObjectID);
                        }
                        else
                        {
                            clsWXHelper.WxUserSubscribe(fromUsername, clsWXHelper.SubscribeType.Default);
                        }
                    }
                    else
                    {
                        clsWXHelper.WxUserSubscribe(fromUsername, clsWXHelper.SubscribeType.Default);
                    }
                }
                else if (Eventname == "SCAN" && px.GetElementsByTagName("EventKey").Count > 0) //该参数是带二维码的参数
                {
                    CodeValue = px.GetElementsByTagName("EventKey")[0].InnerText;
                    clsWXHelper.WriteQrcodeInfo(CodeValue, fromUsername, ObjectID);
                }

                //backPic("这一刻去爱吧！", "我有句情话想对你说！利郎轻商务情人节倾情献礼！快来抽取属于你的情话吧...", "http://tm.lilanz.com/project/EasyBusiness/2017valentine/img/thumb.jpg",
                //    "http://tm.lilanz.com/project/easybusiness/2017valentine/2017valenday.aspx");
                CheckVIP();

                //backText("利郎品牌入驻，关注公众平台参与游戏互动开业期间就有机会免费领取利郎精品皮带、钱夹、领带，更有Ipad等你拿！\n\n开业在即，敬请期待！");
            }
            else if (Eventname == "unsubscribe")
            {
                clsWXHelper.WxUserDisSubscribe(fromUsername);
            }
            else if (Eventname.ToUpper() == "LOCATION")//收集定时发送的位置记录
            {
                //try
                //{
                //    string sqlcomm = @"insert into [wx_userPosition] 
                //    (wxOpenid,CreateTime,Lat,Lon,Precision) values ('{0}','{1}', {2}, {3}, {4})";
                //    sqlcomm = String.Format(sqlcomm,
                //        px.GetElementsByTagName("FromUserName")[0].InnerText,
                //    UnixTimeToTime(px.GetElementsByTagName("CreateTime")[0].InnerText).ToString("yyyy-MM-dd HH:mm:ss"),
                //    px.GetElementsByTagName("Latitude")[0].InnerText,
                //    px.GetElementsByTagName("Longitude")[0].InnerText,
                //    px.GetElementsByTagName("Precision")[0].InnerText);
                //    DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper("1");
                //    dbHelper.ExecuteNonQuery(sqlcomm);
                //}
                //catch (Exception ex)
                //{
                //    WriteLog(ex.ToString());
                //}
                return;
            }
        }
        else if (px.GetElementsByTagName("MsgType")[0].InnerText == "location")
        {
            //            string sqlcomm = @"insert into [wx_userPosition] 
            //(wxOpenid,CreateTime,Lat,Lon,Precision) values ('{0}','{1}', {2}, {3}, {4})";
            //            sqlcomm = String.Format(sqlcomm,
            //                            px.GetElementsByTagName("FromUserName")[0].InnerText,
            //                       UnixTimeToTime(px.GetElementsByTagName("CreateTime")[0].InnerText).ToString("yyyy-MM-dd HH:mm:ss"),
            //                       px.GetElementsByTagName("Location_X")[0].InnerText,
            //                       px.GetElementsByTagName("Location_Y")[0].InnerText,
            //                       px.GetElementsByTagName("Scale")[0].InnerText);
            //            DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper("1");
            //            dbHelper.ExecuteNonQuery(sqlcomm);

            //            backText("我们已经收到您发送的位置信息！");

            return;
        }
        else if (px.GetElementsByTagName("MsgType")[0].InnerText == "image")    //图片消息
        {
            string strInfo = DownLoadImage(px);
            if (strInfo == "")
            {
                //string backInfo = "";
                //string StoreName = "";    //获取用户所在店面的名称！

                //DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper();
                //dbHelper.ConnectionString = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;        //测试系统的数据库  
                //string sqlComm = @"SELECT TOP 1 StoreName FROM wx_t_ImageStore A INNER JOIN
                //           wx_t_UserInStore B ON B.wxOpenid='{0}' AND A.ID=B.StoreID ORDER BY B.ID DESC";
                //sqlComm = string.Format(sqlComm, fromUsername);
                //StoreName = Convert.ToString(dbHelper.ExecuteScalar(sqlComm));

                //if (StoreName == "")
                //{
                //    backInfo = "亲~，上传照片之前需要先扫描扫描大屏幕上的二维码哦~";
                //}
                //else
                //{
                //    backInfo = "亲~，刚刚上传的图片已经被收录了哦~，马上为您呈现在【{0}】的大屏幕上！";
                //    backInfo = string.Format(backInfo, StoreName);
                //}

                //backText(backInfo);
            }
        }

        //判断包含以下字段，就返回提示  ——By:薛灵敏 2014-12-11
        if (px.GetElementsByTagName("MsgType")[0].InnerText == "text" || px.GetElementsByTagName("MsgType")[0].InnerText == "image"
                || px.GetElementsByTagName("MsgType")[0].InnerText == "voice" || px.GetElementsByTagName("MsgType")[0].InnerText == "video"
                || px.GetElementsByTagName("MsgType")[0].InnerText == "shortvideo")
        {
            string LogInfo = "客户({0})发送：{1}   (转<多客服>回复)";
            LogInfo = string.Format(LogInfo, fromUsername, keyword);
            WriteLog(LogInfo);

            DateTime dt = DateTime.Now;
            string textTpl = @"<xml>
                <ToUserName><![CDATA[" + fromUsername + @"]]></ToUserName>
                <FromUserName><![CDATA[" + toUsername + @"]]></FromUserName>
                <CreateTime>" + ConvertDateTimeInt(DateTime.Now) + @"</CreateTime>
                <MsgType><![CDATA[transfer_customer_service]]></MsgType>
                </xml>";
            Response.Write(textTpl);


            //            if (keyword.Contains("年") || keyword.Contains("特卖") || keyword.Contains("福利会")
            //                    || keyword.Contains("开始") || keyword.Contains("时间") || keyword.Contains("券")
            //                    || keyword.Contains("票") || keyword.Contains("#"))
            //            {
            //                //backWord = "利郎年终特卖会正在筹备！敬请期待...";

            //                string LogInfo = "客户({0})发送：{1}   返回：图文链接";
            //                LogInfo = string.Format(LogInfo, fromUsername, keyword, backWord);
            //                WriteLog(LogInfo);


            //                //加载图文模版
            //                string picTpl = @"<xml>
            //					<ToUserName><![CDATA[{0}]]></ToUserName>
            //					<FromUserName><![CDATA[{1}]]></FromUserName>
            //					<CreateTime>{2}</CreateTime>
            //					<MsgType><![CDATA[news]]></MsgType>
            //					<ArticleCount>1</ArticleCount>
            //					<Articles>
            //					<item>
            //					<Title><![CDATA[{3}]]></Title>
            //					<Description><![CDATA[{4}]]></Description>
            //					<PicUrl><![CDATA[{5}]]></PicUrl>
            //					<Url><![CDATA[{6}]]></Url>
            //					</item>
            //					</Articles> 
            //					</xml> ";
            //                picTpl = string.Format(picTpl,fromUsername , toUsername ,    ConvertDateTimeInt(DateTime.Now),
            //                    "利郎2014-2015年终福利会", "利郎2014-2015年末盛典马上就要开始啦~，点击了解详情！", "http://tm.lilanz.com/SuperSale2014/0.jpg", "http://tm.lilanz.com/SuperSale.html");

            //                Response.Write(picTpl);
            //            }

        }
    }


    //private bool UserInfoCreateOoUpdate(string CodeValue)
    //{
    //    //获取个人信息 
    //    string token = clsWXHelper.GetAT(ConfigKey);       
    //    string url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token={0}&openid={1}&lang=zh_CN";
    //    url = string.Format(url, token, fromUsername);
    //    string rContent = clsNetExecute.HttpRequest(url, "", "GET", "utf-8", 3000);
    //    if (clsWXHelper.CheckResult(ConfigKey, rContent) == true)
    //    {
    //        int cUserID = UserInfoCreateGetID(rContent);
    //        if (cUserID > 0)
    //        {
    //            WriteQrcodeInfo(CodeValue, cUserID);

    //            return true;
    //        }
    //        else
    //        { 
    //            return false;                
    //        }
    //    }
    //    else
    //    {
    //        WriteLog("错误的执行结果：" + rContent);
    //        return false;
    //    }                      
    //}

    private void CheckVIP()
    {
        using(LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
        {
            object VipID = null;
            string strInfo = dal.ExecuteQueryFast(string.Format("SELECT TOP 1 VipID FROM wx_t_vipBinging WHERE wxOpenID = '{0}' ", fromUsername), out VipID);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("公众号，检查VIPID失败！错误：", strInfo));
                return;
            }
            if (VipID == null || Convert.ToString(VipID) == "0")
            {
                backPic(string.Concat("感谢您关注利郎轻商务"), "为了给您提供更加优质的利郎会员服务，系统需要先识别您的会员身份！点击 绑定（或注册）您的会员信息。"
                    , "http://tm.lilanz.com/vip2/res/img/EasyBusiness/vsb.jpg", "http://tm.lilanz.com/vip2/project/EasyBusiness/JoinUS.aspx");
                return;
            }

            Response.Clear();
            Response.Write("success");
            //clsSharedHelper.WriteInfo("success");
        }
    }

    private void UpdateUserInStore(string CodeValue)
    {
        string khid = "-1";     //如果khid得到-1 表示不正常
        string mdid = CodeValue;
        switch (CodeValue)
        {
            case "2920429":         //晋江长兴路轻商务展厅
                khid = "18090";
                mdid = "8125";
                break;
        }

        string ObjectID = clsWXHelper.GetObjectID(ConfigKey);      //表示轻商务
        string sqlcomm = @" UPDATE wx_t_vipBinging SET khid = @khid,mdid = @mdid WHERE wxOpenid = @openid AND vipID = 0 AND ObjectID = @ObjectID ";

        List<SqlParameter> listSqlParameter = new List<SqlParameter>();

        listSqlParameter.Add(new SqlParameter("@openid", fromUsername));
        listSqlParameter.Add(new SqlParameter("@khid", khid));
        listSqlParameter.Add(new SqlParameter("@mdid", mdid));
        listSqlParameter.Add(new SqlParameter("@ObjectID", ObjectID));

        string ConnStr = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM Dal = new LiLanzDALForXLM(ConnStr))
        {
            string strInfo = Dal.ExecuteNonQuerySecurity(sqlcomm, listSqlParameter);
            if (strInfo != "")
            {
                WriteLog("更新粉丝归属门店失败！错误：" + strInfo);
            }
        }
    }


    ///
    /// unix时间转换为datetime
    ///
    ///
    ///
    private DateTime UnixTimeToTime(string timeStamp)
    {
        DateTime dtStart = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        long lTime = long.Parse(timeStamp + "0000000");
        TimeSpan toNow = new TimeSpan(lTime);
        return dtStart.Add(toNow);
    }

    ///
    /// datetime转换为unixtime
    ///
    ///
    ///
    private int ConvertDateTimeInt(System.DateTime time)
    {
        System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1));
        return (int)(time - startTime).TotalSeconds;
    }

    ///
    /// 写日志(用于跟踪)
    ///
    private void WriteLog(string strMemo)
    {
        clsLocalLoger.WriteInfo(string.Concat("[利郎轻商务] ",strMemo));
    }


    public String DpChcek(String phone, String IdCard, String Cname)
    {
        if (CheckIDCard(IdCard))
            return "身份证号有误！";
        if (!IsHandset(phone))
            return "手机号码有误！";
        return "";
    }
    /// 身份证验证
    /// </summary>
    /// <param name="Id">身份证号</param>
    /// <returns></returns>
    public bool CheckIDCard(string Id)
    {
        if (Id.Length == 18)
        {
            //bool check = CheckIDCard18(Id);
            return false;
        }
        else if (Id.Length == 15)
        {
            //bool check = CheckIDCard15(Id);
            return false;
        }
        else
        {
            return true;
        }
    }
    public bool IsHandset(string str_handset)
    {
        return System.Text.RegularExpressions.Regex.IsMatch(str_handset, @"^[1]+[3-9]+\d{9}");
    }
    private void backHelo()
    {
        //        String msg = @"<xml>
        //        <ToUserName><![CDATA[{0}]]></ToUserName>
        //        <FromUserName><![CDATA[{1}]]></FromUserName>
        //        <CreateTime>{2}</CreateTime>
        //        <MsgType><![CDATA[news]]></MsgType>
        //        <ArticleCount>1</ArticleCount>
        //        <Articles>
        //        <item>
        //        <Title><![CDATA[最新活动]]></Title> 
        //        <Description><![CDATA[欢迎关注利郎公众平台，参与活动请输入:姓名#手机号码#身份证，如：李四#13912345678#350582199010201234或直接点击直接查看全文提交申请]]></Description>
        //        <PicUrl><![CDATA[http://218.104.241.164/img/sales.gif]]></PicUrl>
        //        <Url><![CDATA[http://218.104.241.164/SaleForSpecial.aspx]]></Url>
        //        </item>
        //        </Articles>
        //        </xml>";
        backText("感谢您关注利郎微信公众号！");
    }

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

        Response.Write(msg);
    }


    private void backPic(string title, string body, string picUrl, string DumpUrl)
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

        Response.Write(picTpl);
    }

    private void backPic(List<string[]> strInfoList)
    {
        //加载图文模版
        StringBuilder sbTpl = new StringBuilder();
        sbTpl.AppendFormat(@"<xml>
        					 <ToUserName><![CDATA[{0}]]></ToUserName>
        					 <FromUserName><![CDATA[{1}]]></FromUserName>
        					 <CreateTime>{2}</CreateTime>
        					 <MsgType><![CDATA[news]]></MsgType>
        					 <ArticleCount>{3}</ArticleCount>
        					 <Articles>", fromUsername, toUsername, ConvertDateTimeInt(DateTime.Now), strInfoList.Count);

        foreach(string[] appInfo in strInfoList){
            sbTpl.AppendFormat(@"<item>
        					 <Title><![CDATA[{0}]]></Title>
        					 <Description><![CDATA[{1}]]></Description>
        					 <PicUrl><![CDATA[{2}]]></PicUrl>
        					 <Url><![CDATA[{3}]]></Url>
        					 </item>",appInfo[0],appInfo[1],appInfo[2],appInfo[3]);
        }

        sbTpl.Append(@"
            </Articles> 
        	</xml> ");

        Response.Write(sbTpl.ToString());
    }



    /// <summary> 转半角的函数(DBC case) </summary>
    /// <param name="input">任意字符串</param>
    /// <returns>半角字符串</returns>
    ///<remarks>
    ///全角空格为12288，半角空格为32
    ///其他字符半角(33-126)与全角(65281-65374)的对应关系是：均相差65248
    ///</remarks>
    public static string ToDBC(string input)
    {
        char[] c = input.ToCharArray();
        for (int i = 0; i < c.Length; i++)
        {
            if (c[i] == 12288)
            {
                c[i] = (char)32;
                continue;
            }
            if (c[i] > 65280 && c[i] < 65375)
                c[i] = (char)(c[i] - 65248);
        }
        return new string(c);
    }

    /// <summary>
    /// 从微信服务器下载图片
    /// </summary>
    /// <param name="px"></param>
    /// <returns></returns>
    public string DownLoadImage(XmlDocument px){
        string strInfo = "";

        string DirImage = Server.MapPath(@"/UserImages/");
        if (!Directory.Exists(DirImage))
            Directory.CreateDirectory(DirImage);

        string myDirImage = Server.MapPath(@"/UserImages/my/");
        if (!Directory.Exists(myDirImage))
            Directory.CreateDirectory(myDirImage);

        string filename0 = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + fromUsername + ".png";       //相对路径
        string filename = DirImage + filename0;
        string myfilename = myDirImage + "" + filename0;
        strInfo = DownloadFile(px.GetElementsByTagName("PicUrl")[0].InnerText, filename);

        if (strInfo == "")
        {
            strInfo = MakeImage(filename, myfilename);
        }

        if (strInfo == "")
        {
            //config myconfig = new config();       //该对象获取不到数据(可能是因为相对路径问题)；所以将微信的Appid, Secret 写死在顶部 薛灵敏
            //myconfig.load("3");
            string content, posturl;
            if (Application["AccTime" + Appid] == null || Convert.ToDateTime(Application["AccTime" + Appid]).Subtract(DateTime.Now).TotalMinutes < 5)
            {
                //posturl = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid={0}&secret={1}";
                //posturl = String.Format(posturl, Appid, Secret);
                //content = HttpRequest(posturl);
                //JsonSerializerSettings jSetting = new JsonSerializerSettings();
                //jSetting.NullValueHandling = NullValueHandling.Ignore;

                //WXAccessToken wx = JsonConvert.DeserializeObject<WXAccessToken>(content, jSetting);

                //if (wx.AccessToken != null)//获取Token成功
                //{
                //    Application["AccToken" + Appid] = wx.AccessToken;       //记录Token时间
                //    Application["AccTime" + Appid] = DateTime.Now.AddSeconds(wx.ExpiresIn);
                //}
            }

            if (Application["AccToken" + Appid] == "")
            {
                strInfo = "无法获取公众号AccessToken";
            }else{
                //posturl = "https://api.weixin.qq.com/cgi-bin/user/info?access_token={0}&openid={1}&lang=zh_CN";
                //posturl = String.Format(posturl, Application["AccToken" + Appid], fromUsername);
                //content = HttpRequest(posturl);

                //WXUserInfo user = JsonConvert.DeserializeObject<WXUserInfo>(content);
                //string sqlcomm = String.Format(@"INSERT INTO wx_t_UploadImage (myimgUrl,imgUrl,wxNick,wxSex,wxLanguage,wxCity,wxProvince,wxCountry,wxHeadimgurl,wxOpenid)
                //     values ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}')"
                //    , "UserImages/my/" + filename0, "UserImages/" + filename0, user.nickname, user.sex, user.language,
                //    user.city, user.province, user.country, user.headimgurl, user.openid);
                //DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper();
                //dbHelper.ConnectionString = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;        //测试系统的数据库
                //int id = 0;
                //int reslut = dbHelper.ExecuteNonQuery(sqlcomm);
                //if (reslut == 0)
                //{
                //    strInfo = "创建记录失败！【" + sqlcomm + "】";
                //}
            }
        }

        if (strInfo != "")
        {
            WriteLog("图片上传出错！错误：" + strInfo);
        }
        return strInfo;
    }

    /// <summary>
    /// 处理图片成指定尺寸
    /// </summary>
    /// <param name="SourceImage"></param>
    /// <param name="SaveImage"></param>
    /// <returns></returns>
    private string MakeImage(string SourceImage,string SaveImage)
    {
        try
        {
            System.Drawing.Bitmap myBitMap = new System.Drawing.Bitmap(SourceImage);
            int pWidth = myBitMap.Width;
            int pHeight = myBitMap.Height;
            double pcent = pWidth * 1.0 / pHeight;
            double ecent = imgWidth * 1.0 / imgHeight;
            int eWidth = 0;
            int eHeight = 0;
            int draX = 0;
            int draY = 0;
            //上传图片更宽，需要补充高度
            if (pcent > ecent)
            {
                pWidth = imgWidth;
                pHeight = Convert.ToInt32(pWidth * 1.0 / pcent);
                eWidth = pWidth;
                eHeight = Convert.ToInt32(pWidth * 1.0 / ecent);
                draX = 0;
                draY = (eHeight - pHeight) / 2;
                //上传图片更窄，需要补充宽度
            }
            else
            {
                pHeight = imgHeight;
                pWidth = Convert.ToInt32(pHeight * pcent);

                eWidth = Convert.ToInt32(pHeight * ecent);
                eHeight = pHeight;
                draX = (eWidth - pWidth) / 2;
                draY = 0;
            }

            System.Drawing.Bitmap eImage = new System.Drawing.Bitmap(imgWidth, imgHeight);
            System.Drawing.Graphics g = System.Drawing.Graphics.FromImage(eImage);
            g.FillRectangle(System.Drawing.Brushes.Black, new System.Drawing.Rectangle(0, 0, imgWidth, imgHeight));
            g.DrawImage(myBitMap, draX, draY, pWidth, pHeight);

            g.Save();

            myBitMap.Dispose();
            //eImage.Save(savejpg, System.Drawing.Imaging.ImageFormat.Jpeg);
            eImage.Save(SaveImage, System.Drawing.Imaging.ImageFormat.Png);
            g.Dispose();

            return "";
        }
        catch (Exception ex)
        {
            return "处理图片失败！错误：" + ex.Message;
        }
    }
    /// <summary>
    /// 下载图片
    /// </summary>
    /// <param name="URL">目标URL</param>
    /// <param name="filename">本地的路径</param>
    /// <returns></returns>
    public string DownloadFile(string URL, string filename)
    {
        try
        {
            System.Net.HttpWebRequest Myrq = (System.Net.HttpWebRequest)System.Net.HttpWebRequest.Create(URL);
            System.Net.HttpWebResponse myrp = (System.Net.HttpWebResponse)Myrq.GetResponse();
            long totalBytes = myrp.ContentLength;
            System.IO.Stream st = myrp.GetResponseStream();
            System.IO.Stream so = new System.IO.FileStream(filename, System.IO.FileMode.Create);
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
            return "";
        }
        catch (Exception ex)
        {
            return ex.Message;
        }
    }

    private string HttpRequest(string url)
    {
        HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
        request.ContentType = "application/x-www-form-urlencoded";

        HttpWebResponse myResponse = (HttpWebResponse)request.GetResponse();
        StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8);
        return reader.ReadToEnd();//得到结果
    }



    #region 新增业务

    /// <summary>
    /// 如果用户不存在则用户信息
    /// </summary>
    /// <param name="content"></param>
    /// <returns></returns>
    private int UserInfoCreateGetID(string content)
    {
        try
        {
            using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content))
            {
                string sqlcomm = @"DECLARE @ID INT,@ObjectID INT

                SELECT @ID = 0,@ObjectID = 4

                SELECT TOP 1 @ID = ID FROM wx_t_vipBinging WHERE wxOpenid = @openid
                IF (@ID = 0)	    
                BEGIN
	                INSERT INTO [wx_t_vipBinging]([wxNick],[wxSex],[wxLanguage],[wxCity],[wxProvince],[wxCountry],[wxHeadimgurl],[wxOpenid],createTime,[ObjectID],wxUnionid)
								                VALUES (@nickname,@sex,@language,@city,@province,@country,@headimgurl,@openid,GetDate(),@ObjectID,@wxUnionid)
                    SELECT @ID = @@IDENTITY
                END
                ELSE IF (@nickname <> '' AND @sex <> 0)
	                UPDATE wx_t_vipBinging SET wxNick = @nickname,wxSex = @sex,wxLanguage = @language,wxCity = @city,wxProvince = @province
								                ,wxCountry = @country,wxHeadimgurl = @headimgurl,wxUnionid=@wxUnionid WHERE ID = @ID

                SELECT @ID
                ";

                List<SqlParameter> listSqlParameter = new List<SqlParameter>();

                listSqlParameter.Add(new SqlParameter("@openid", jh.GetJsonValue("openid")));
                listSqlParameter.Add(new SqlParameter("@nickname", jh.GetJsonValue("nickname")));
                listSqlParameter.Add(new SqlParameter("@sex", jh.GetJsonValue("sex")==""? 0:Convert.ToInt32(jh.GetJsonValue("sex"))));
                listSqlParameter.Add(new SqlParameter("@language", jh.GetJsonValue("language")));
                listSqlParameter.Add(new SqlParameter("@city", jh.GetJsonValue("city")));
                listSqlParameter.Add(new SqlParameter("@province", jh.GetJsonValue("province")));
                listSqlParameter.Add(new SqlParameter("@country", jh.GetJsonValue("country")));
                listSqlParameter.Add(new SqlParameter("@headimgurl", jh.GetJsonValue("headimgurl").Replace("\\", "")));
                listSqlParameter.Add(new SqlParameter("@wxUnionid", jh.GetJsonValue("unionid")));

                string ConnStr = clsConfig.GetConfigValue("OAConnStr");
                using (LiLanzDALForXLM Dal = new LiLanzDALForXLM(ConnStr))
                {
                    object scalar ;
                    string strInfo = Dal.ExecuteQueryFastSecurity(sqlcomm, listSqlParameter, out scalar);
                    if (strInfo == "")
                    {
                        return Convert.ToInt32(scalar);
                    }
                    else
                    {
                        WriteLog("创建用户档案失败！错误：" + strInfo);
                        return 0;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            WriteLog("存储用户信息错误：" + ex.Message);
            return 0;
        }
    }

    //    /// <summary>
    //    /// 记录二维码信息
    //    /// </summary>
    //    /// <param name="GameCode"></param>
    //    /// <param name="cUserID">用户ID</param>
    //    private void WriteQrcodeInfo(string GameCode, int cUserID)
    //    {
    //        try
    //        {
    //            string Ip = GetSourceIP();

    //            string sqlcomm = @"
    //            INSERT INTO [tm_t_QRScan]([GameID],[ScanUserID],[IP]) VALUES (@GameCode,@ID,@IP)";

    //            List<SqlParameter> listSqlParameter = new List<SqlParameter>();

    //            listSqlParameter.Add(new SqlParameter("@GameCode", GameCode));
    //            listSqlParameter.Add(new SqlParameter("@IP", Ip));
    //            listSqlParameter.Add(new SqlParameter("@ID", cUserID));

    //            string ConWX = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
    //            using (LiLanzDALForXLM Dal = new LiLanzDALForXLM(ConWX))
    //            {
    //                string strInfo = Dal.ExecuteNonQuerySecurity(sqlcomm, listSqlParameter);
    //                if (strInfo != "")
    //                {
    //                    WriteLog("统计二维码失败！错误：" + strInfo);
    //                }
    //            }
    //        }
    //        catch (Exception ex)
    //        {
    //            WriteLog("存储扫码信息错误：" + ex.Message);
    //        }
    //    }
    //    /// <summary>
    //    /// 记录二维码信息
    //    /// </summary>
    //    /// <param name="GameCode"></param>
    //    /// <param name="cUserID">用户ID</param>
    //    private void WriteQrcodeInfo(string GameCode, string wxOpenid)
    //    {
    //        try
    //        {
    //            string sqlcomm = "";
    //            int wxID = 0;
    //            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
    //            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
    //            {
    //                sqlcomm = string.Format("SELECT TOP 1 ID FROM wx_t_vipBinging WHERE wxOpenID = '{0}'", wxOpenid);
    //                object objWxID = 0;
    //                string strInfo = dal.ExecuteQueryFast(sqlcomm, out objWxID);
    //                if (strInfo != "")
    //                {
    //                    WriteLog("统计二维码获取身份ID失败！错误：" + strInfo);
    //                    return;
    //                }
    //                wxID = Convert.ToInt32(objWxID);
    //            }
    //            WriteQrcodeInfo(GameCode, wxID);
    //        }
    //        catch (Exception ex)
    //        {
    //            WriteLog("存储扫码信息错误：" + ex.Message);
    //        }
    //    }



    //    /// <summary>
    //    /// 获得奖品
    //    /// </summary>
    //    /// <returns></returns>
    //    private void GetPrize()
    //    {
    //        //判断奖品表中是否有该用户  
    //        string GameID = "10002";
    //        try
    //        {
    //            string sqlcomm = @"
    //            DECLARE @UserID INT,
    //				            @GetPrizeID INT
    //
    //            SELECT @UserID = 0,@GetPrizeID = 0
    //            SELECT TOP 1 @UserID=ID FROM wx_t_vipBinging WHERE wxOpenid = @wxOpenid
    //            SELECT TOP 1 @GetPrizeID=ID FROM tm_t_GetPrizeRecords WHERE UserID = @UserID AND PrizeID = @PrizeID
    //
    //            IF (@GetPrizeID > 0)	SELECT -1		--奖品已分配
    //            ELSE IF (@UserID = 0)	SELECT 0		--用户信息不存在
    //            ELSE
    //            BEGIN
    //	            INSERT INTO tm_t_GetPrizeRecords (GameID,GameToken,UserID,PrizeID,IsActive,ActiveTime) VALUES (@GameID,NewID(),@UserID,@PrizeID,1,getdate())
    //              SELECT 1 --礼品生成成功！
    //            END ";

    //            List<SqlParameter> listSqlParameter = new List<SqlParameter>();

    //            listSqlParameter.Add(new SqlParameter("@wxOpenid", fromUsername));
    //            listSqlParameter.Add(new SqlParameter("@GameID", PaperGameID));
    //            listSqlParameter.Add(new SqlParameter("@PrizeID", GameID));

    //            DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(DBIndex);
    //            object myresult = dbHelper.ExecuteScalar(sqlcomm, CommandType.Text, listSqlParameter.ToArray());
    //            switch (Convert.ToInt32(myresult))
    //            {
    //                case 0:
    //                    backText("系统忙！请稍后再扫描本二维码...");
    //                    break;
    //                case -1:
    //                    //输出文字提示
    //                    backText("您已经参加过本活动了。你可以从菜单“<a href='http://tm.lilanz.com/SuperSaleGames/MyPrizeList.aspx'>我的礼券</a>”中进行查询。");
    //                    break;
    //                case 1:
    //                    //输出图文信息
    //                    backPic("领取礼品", "恭喜您获得礼品一份！领取礼品需要完善您的身份信息！请点击阅读全文。",
    //                        "http://tm.lilanz.com/SuperSaleGames/img/main2015.jpg", "http://tm.lilanz.com/SuperSaleGames/MyPrizeList.aspx");
    //                    break;
    //            }
    //        }
    //        catch (Exception ex)
    //        {
    //            WriteLog("扫码获奖错误：" + ex.Message);
    //        }
    //    }

    //    /// <summary>
    //    /// 获取游戏次数
    //    /// </summary>
    //    /// <param name="CodeValue"></param>
    //    private void GetGameCount(string CodeValue)
    //    {
    //        try
    //        {
    //            string sqlcomm = @"
    //             DECLARE @UserID INT,
    //				            @GameCount INT,
    //				            @NowCount INT,
    //							@ToDayScanID INT
    //
    //            SELECT @UserID = 0,@GameCount = 0,@NowCount = 0,@ToDayScanID = 0
    //						
    //            SELECT TOP 1 @UserID=ID,@GameCount=GameCount,@NowCount=NowCount FROM wx_t_vipBinging WHERE wxOpenid = @wxOpenid 
    //
    //			SELECT TOP 1 @ToDayScanID = ID FROM tm_t_QRScan WHERE ScanUserID = @UserID AND GameID=@CodeValue AND ScanTime > CONVERT(VARCHAR(10),GETDATE(),120)
    //              
    //            IF (@ToDayScanID > 0)	SELECT '您今天已经扫描过此二维码了！' + CHAR(13) + '您当前还有' + CONVERT(VARCHAR(3),@GameCount - @NowCount) + ' 次游戏机会！'		--今天已经参加过本活动了
    //            ELSE IF (@UserID> 0)
    //            BEGIN
    //                UPDATE wx_t_vipBinging SET GameCount = GameCount + 1 WHERE ID = @UserID
    //                SELECT '恭喜您获得一次游戏机会！' + CHAR(13) + '您当前还有' + CONVERT(VARCHAR(3),@GameCount - @NowCount + 1) + ' 次游戏机会！'
    //            END  
    //			ELSE SELECT ''
    //						";

    //            List<SqlParameter> listSqlParameter = new List<SqlParameter>();

    //            listSqlParameter.Add(new SqlParameter("@wxOpenid", fromUsername));
    //            listSqlParameter.Add(new SqlParameter("@CodeValue", CodeValue));

    //            DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(DBIndex);
    //            object myresult = dbHelper.ExecuteScalar(sqlcomm, CommandType.Text, listSqlParameter.ToArray());

    //            string strInfo = Convert.ToString(myresult);
    //            if (strInfo == "")
    //            {
    //                strInfo = "系统繁忙！";
    //            }
    //            else
    //            {
    //                backPic("每日扫码送游戏机会", strInfo + " 点击阅读全文，试试手气？",
    //                    "http://tm.lilanz.com/SuperSaleGames/img/guaguaka.jpg", "http://tm.lilanz.com/SuperSaleGames/ggkGame.aspx");
    //            }

    //            backText(strInfo);
    //        }
    //        catch (Exception ex)
    //        {
    //            WriteLog("扫码获奖错误：" + ex.Message);
    //        }

    //    }


    ///// <summary>
    ///// 检查来访IP是否为授权合法的IP
    ///// </summary>
    ///// <returns></returns>
    //private string GetSourceIP()
    //{
    //    string clientIp = HttpContext.Current.Request.UserHostAddress;
    //    if (clientIp == "::1")  //测试时发现使用 localhost访问时输出的IP可能为该值。
    //    {
    //        clientIp = "127.0.0.1";
    //    }
    //    return clientIp;
    //}


    #endregion

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
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>    
    </div>
    </form>
</body>
</html>
