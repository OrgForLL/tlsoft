<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    //const string Token = "LilanzXlmToken"; //你的token
    //const string Token = "SAO83V3ld87gIFf73CCZFShhZ3lgGfgx"; //你的token
    const string Token = "jWBinob5hPpRWBIUtUPou5TkPn5KhiI5"; //你的token
    //private string Appid = "wx821a4ec0781c00ca";
    //private string Secret = "a68357539ec388f322787d6d518d6daf";
    private string Appid = "";          //会员专用的公众号信息，在Load事件中加载
    private string Secret = "";
    const int imgWidth = 500;       //处理图片的宽度和高度
    const int imgHeight = 500;
    string signature;
    string timestamp;
    string nonce;
    string fromUsername = "", toUsername = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        config conf = new config();
        conf = conf.load("3");

        this.Appid = conf.Appid;
        this.Secret = conf.Secret;
         
        /*
        try
        {
            FileStream fs = new FileStream(Server.MapPath("weixin.txt"), FileMode.OpenOrCreate);
            //实例化一个StreamWriter-->与fs相关联   
            StreamWriter sw = new StreamWriter(fs);
            //开始写入    
            //Stream s = Request.InputStream;
            StreamReader reader = new StreamReader(Request.InputStream);
            String xml = reader.ReadToEnd();
            sw.Write(xml);
            //清空缓冲区   
            sw.Flush();
            //关闭流   
            sw.Close();
            fs.Close();
        }
        
        catch { }
         */
        //Valid();
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
        //else 
        //{
        //    //这部分是提供给微信公众平台验证使用的 
        //    string[] pp = { Token, timestamp, nonce };
        //    Array.Sort(pp);
        //    string catPP = "";
        //    for (int i = 0; i < 3; i++)
        //    {
        //        catPP += pp[i];
        //    }
        //    string p_p = FormsAuthentication.HashPasswordForStoringInConfigFile(catPP, "SHA1");
        //    if (p_p.ToLower() == signature.ToLower())
        //        Response.Write(Request["echostr"].ToString());
        //    Response.End();
        //}
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
        WriteLog2("开始远程调用..");
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
            WriteLog2("远程调用异常：" + ex.Message);
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
            //XmlNodeList xnl = px.GetElementsByTagName("EventKey");

            //第一次关注subscribe || 已关注SCAN
            //if (px.GetElementsByTagName("Event")[0].InnerText == "subscribe" || px.GetElementsByTagName("Event")[0].InnerText == "SCAN")
            //{
                
            //    if (px.GetElementsByTagName("Event")[0].InnerText == "subscribe")
            //    {
            //        string query = HttpContext.Current.Request.Url.Query;
            //        if (query.Length > 0)
            //        {
            //            query = query.Remove(0, 1); 
            //        }
            //        //string reUrl = string.Concat("http://59.57.110.10/wxcloud/api.php?hash=vY777", "&", query);
            //        string reUrl = string.Concat("http://10.0.0.200/wxcloud/api.php?hash=xWssU", "&", query);       //内部的API服务器
            //        WriteLog2("转发到新地址：" + reUrl);
            //        string bakInfo = RePostDataToWX(reUrl, px.InnerXml);
            //        WriteLog2("返回结果：" + bakInfo);
            //        backText(bakInfo); 
            //        return;
            //    }

            //    //输出定位信息提示
            //    UserInStore(px);
                
            //    return;
            //}
            //else 

            if (px.GetElementsByTagName("Event")[0].InnerText == "subscribe" || px.GetElementsByTagName("Event")[0].InnerText == "SCAN")
            {
                string CodeValue = "";
                if (px.GetElementsByTagName("Event")[0].InnerText == "subscribe" && px.GetElementsByTagName("EventKey").Count > 0) //该参数是带二维码的参数
                {
                    CodeValue = px.GetElementsByTagName("EventKey")[0].InnerText;
                    CodeValue = CodeValue.Replace("qrscene_", "");
                }
                else if (px.GetElementsByTagName("Event")[0].InnerText == "SCAN" && px.GetElementsByTagName("EventKey").Count > 0) //该参数是带二维码的参数
                {
                    CodeValue = px.GetElementsByTagName("EventKey")[0].InnerText;
                }

                if (CodeValue == "60001")
                {
                    System.Data.DataRow dr = FansSaleBind.GetFansSaleRowInfo(fromUsername);
                    if (dr != null)
                    {
                        //backPic(string.Concat("指定您的专属顾问【", dr["cname"] ,"】"), "专属顾问是尊贵的利郎会员服务，系统需要先识别您的会员身份！请点击“阅读全文”，绑定（或注册）您的会员信息。", "http://tm.lilanz.com/res/img/vipweixin/vsb.jpg", "http://tm.lilanz.com/vipBinging.aspx?cid=3");
                        backPic(string.Concat("指定您的专属顾问【", dr["cname"], "】"), "专属顾问是尊贵的利郎会员服务，系统需要先识别您的会员身份！请点击“阅读全文”，绑定（或注册）您的会员信息。", "http://tm.lilanz.com/res/img/vipweixin/vsb.jpg", "http://tm.lilanz.com/project/vipweixin/JoinUS.aspx");
                    }
                    else
                    {
                        backText("感谢您关注本公众号！");
                    }
                    return;
                } 
            }
            else if (px.GetElementsByTagName("Event")[0].InnerText.ToUpper() == "LOCATION")//收集定时发送的位置记录
            {
                try
                {
                    string sqlcomm = @"insert into [wx_userPosition] 
                    (wxOpenid,CreateTime,Lat,Lon,Precision) values ('{0}','{1}', {2}, {3}, {4})";
                    sqlcomm = String.Format(sqlcomm,
                        px.GetElementsByTagName("FromUserName")[0].InnerText,
                    UnixTimeToTime(px.GetElementsByTagName("CreateTime")[0].InnerText).ToString("yyyy-MM-dd HH:mm:ss"),
                    px.GetElementsByTagName("Latitude")[0].InnerText,
                    px.GetElementsByTagName("Longitude")[0].InnerText,
                    px.GetElementsByTagName("Precision")[0].InnerText);
                    DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper("1");
                    dbHelper.ExecuteNonQuery(sqlcomm);
                }
                catch (Exception ex)
                {
                    WriteLog2(ex.ToString());
                }
                return;
            } 
        }
        else if (px.GetElementsByTagName("MsgType")[0].InnerText == "location")
        {
            string sqlcomm = @"insert into [wx_userPosition] 
(wxOpenid,CreateTime,Lat,Lon,Precision) values ('{0}','{1}', {2}, {3}, {4})";
            sqlcomm = String.Format(sqlcomm,
                            px.GetElementsByTagName("FromUserName")[0].InnerText,
                       UnixTimeToTime(px.GetElementsByTagName("CreateTime")[0].InnerText).ToString("yyyy-MM-dd HH:mm:ss"),
                       px.GetElementsByTagName("Location_X")[0].InnerText,
                       px.GetElementsByTagName("Location_Y")[0].InnerText,
                       px.GetElementsByTagName("Scale")[0].InnerText);
            DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper("1");
            dbHelper.ExecuteNonQuery(sqlcomm);

            backText("我们已经收到您发送的位置信息！");
            
            return;
        }
        else if (px.GetElementsByTagName("MsgType")[0].InnerText == "image")    //图片消息
        {
            string strInfo = DownLoadImage(px);
            if (strInfo == "")
            {
                string backInfo = "";
                string StoreName = "";    //获取用户所在店面的名称！

                DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper();
                dbHelper.ConnectionString = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;        //测试系统的数据库  
                string sqlComm = @"SELECT TOP 1 StoreName FROM wx_t_ImageStore A INNER JOIN
                           wx_t_UserInStore B ON B.wxOpenid='{0}' AND A.ID=B.StoreID ORDER BY B.ID DESC";
                sqlComm = string.Format(sqlComm, fromUsername);
                StoreName = Convert.ToString(dbHelper.ExecuteScalar(sqlComm));
                               
                if (StoreName == "")
                {
                    backInfo = "亲~，上传照片之前需要先扫描扫描大屏幕上的二维码哦~";
                }
                else
                {
                    backInfo = "亲~，刚刚上传的图片已经被收录了哦~，马上为您呈现在【{0}】的大屏幕上！";
                    backInfo = string.Format(backInfo, StoreName);    
                }

                backText(backInfo);
            }
        }

        //判断包含以下字段，就返回提示  ——By:薛灵敏 2014-12-11
        if (px.GetElementsByTagName("MsgType")[0].InnerText == "text")
        {
            if (keyword.Contains("年") || keyword.Contains("特卖") || keyword.Contains("福利会")
                    || keyword.Contains("开始") || keyword.Contains("时间") || keyword.Contains("券")
                    || keyword.Contains("票") || keyword.Contains("#"))
            {
                //backWord = "利郎年终特卖会正在筹备！敬请期待...";

                string LogInfo = "客户({0})发送：{1}   返回：图文链接";
                LogInfo = string.Format(LogInfo, fromUsername, keyword, backWord);
                WriteLog2(LogInfo);


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
                picTpl = string.Format(picTpl,fromUsername , toUsername ,    ConvertDateTimeInt(DateTime.Now),
                    "利郎2014-2015年终福利会", "利郎2014-2015年末盛典马上就要开始啦~，点击了解详情！", "http://tm.lilanz.com/SuperSale2014/0.jpg", "http://tm.lilanz.com/SuperSale.html");
                                
                Response.Write(picTpl);            
            }
            else
            {
                string LogInfo = "客户({0})发送：{1}   (转<多客服>回复)";
                LogInfo = string.Format(LogInfo, fromUsername, keyword);
                WriteLog2(LogInfo);
                
                DateTime dt = DateTime.Now;
                string textTpl = @"<xml>
                <ToUserName><![CDATA[" + fromUsername + @"]]></ToUserName>
                <FromUserName><![CDATA[" + toUsername + @"]]></FromUserName>
                <CreateTime>" + ConvertDateTimeInt(DateTime.Now) + @"</CreateTime>
                <MsgType><![CDATA[transfer_customer_service]]></MsgType>
                </xml>"; 
                Response.Write(textTpl);  
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
        string filename = Server.MapPath(@"./logs/viplog.txt"); 
        if (!Directory.Exists(Server.MapPath(@"/logs/")))
            Directory.CreateDirectory(@"/logs/");
        StreamWriter sr = null;
        try
        {
            if (!File.Exists(filename))
            {
                sr = File.CreateText(filename);
            }
            else
            {
                sr = File.AppendText(filename);
            }
            sr.WriteLine(DateTime.Now.ToString("[yyyy-MM-dd HH-mm-ss] "));
            sr.WriteLine(strMemo);
        }
        catch
        {
        }
        finally
        {
            if (sr != null)
                sr.Close();
        }
    }
    ///
    /// 写日志(用于跟踪)       -- By:薛灵敏 2014-12-11
    ///
    private void WriteLog2(string strMemo)
    { 
        string filename = Server.MapPath(@"./logs/vip{0}.log");
        filename = string.Format(filename, DateTime.Now.ToString("yyyyMMdd"));
        if (!Directory.Exists(Server.MapPath(@"/logs/")))
            Directory.CreateDirectory(@"/logs/");
        StreamWriter sr = null;
        try
        {
            if (!File.Exists(filename))
            {
                sr = File.CreateText(filename);
            }
            else
            {
                sr = File.AppendText(filename);
            }
            sr.WriteLine(DateTime.Now.ToString("[yyyy-MM-dd HH-mm-ss] "));
            sr.WriteLine(strMemo);
        }
        catch
        {
        }
        finally
        {
            if (sr != null)
                sr.Close();
        }
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
                posturl = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid={0}&secret={1}";
                posturl = String.Format(posturl, Appid, Secret);
                content = HttpRequest(posturl);
                JsonSerializerSettings jSetting = new JsonSerializerSettings();
                jSetting.NullValueHandling = NullValueHandling.Ignore;

                WXAccessToken wx = JsonConvert.DeserializeObject<WXAccessToken>(content, jSetting);
                
                if (wx.AccessToken != null)//获取Token成功
                {
                    Application["AccToken" + Appid] = wx.AccessToken;       //记录Token时间
                    Application["AccTime" + Appid] = DateTime.Now.AddSeconds(wx.ExpiresIn);
                }         
            }

            if (Application["AccToken" + Appid] == "")
            {
                strInfo = "无法获取公众号AccessToken";
            }else{
                posturl = "https://api.weixin.qq.com/cgi-bin/user/info?access_token={0}&openid={1}&lang=zh_CN";
                posturl = String.Format(posturl, Application["AccToken" + Appid], fromUsername);
                content = HttpRequest(posturl); 

                WXUserInfo user = JsonConvert.DeserializeObject<WXUserInfo>(content);
                string sqlcomm = String.Format(@"INSERT INTO wx_t_UploadImage (myimgUrl,imgUrl,wxNick,wxSex,wxLanguage,wxCity,wxProvince,wxCountry,wxHeadimgurl,wxOpenid)
                     values ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}')"
                    , "UserImages/my/" + filename0, "UserImages/" + filename0, user.nickname, user.sex, user.language,
                    user.city, user.province, user.country, user.headimgurl, user.openid);
                DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper();
                dbHelper.ConnectionString = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;        //测试系统的数据库
                int id = 0; 
                int reslut = dbHelper.ExecuteNonQuery(sqlcomm);
                if (reslut == 0)
                {
                    strInfo = "创建记录失败！【" + sqlcomm + "】";
                }
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

    private void UserInStore(XmlDocument px)
    { 
        string StoreID;
        string EventType = px.GetElementsByTagName("Event")[0].InnerText;

        StoreID = px.GetElementsByTagName("EventKey")[0].InnerText;
        if (StoreID == "") //如果没有携带任何参数，则不处理
        {
            backHelo();
            return;
        }
        if (EventType == "subscribe")
        {
            StoreID = StoreID.Replace("qrscene_", "");
        }

        string sqlcomm = String.Format(@"DECLARE @StoreName VARCHAR(50)
                                            SET @StoreName=''
                                            SELECT TOP 1 @StoreName=StoreName FROM wx_t_ImageStore WHERE ID={0} 
                                            IF (@StoreName <> '') 
                                            BEGIN
                                            INSERT INTO wx_t_UserInStore(wxOpenid,StoreID) VALUES('{1}',{0})
                                            END
                                                
                                            SELECT @StoreName    --返回店名
                                            ", StoreID, fromUsername);
        DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper();
        dbHelper.ConnectionString = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;        //测试系统的数据库                    
        string StoreName = "";
        StoreName = Convert.ToString(dbHelper.ExecuteScalar(sqlcomm));
        string strInfo = "";
        if (StoreName == "")
        {
            strInfo = "店面定位出错！请联系利郎信息技术部";
        }
        else
        {
            //strInfo = "欢迎使用利郎【{0}】照片墙！现在立即使用微信将图片推送给我吧~";
            strInfo = "欢迎使用利郎【{0}】照片墙！<a href='{1}'>点击此处开始发送照片</a>吧~";
            string gotoURL = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx821a4ec0781c00ca&redirect_uri=http%3a%2f%2ftm.lilanz.com%2fWebBLL%2fWXImageWallProject%2findex.aspx&response_type=code&scope=snsapi_userinfo&state=0#wechat_redirect'";

            strInfo = string.Format(strInfo, StoreName, gotoURL);
        }
        backText(strInfo); 
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
