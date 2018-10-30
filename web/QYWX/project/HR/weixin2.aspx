<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Net" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    const string Token = "token"; //你的token
    string signature;
    string timestamp;
    string nonce;
    protected void Page_Load(object sender, EventArgs e)
    {
        string postStr = "";
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
        string echoStr = Request.QueryString["echoStr"].ToString();
        if (CheckSignature())
        {
            //if (!string.IsNullOrEmpty(echoStr))
            {
                Response.Write(echoStr);
                Response.End();
            }
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
        string fromUsername = px.GetElementsByTagName("FromUserName")[0].InnerText;
        string toUsername = px.GetElementsByTagName("ToUserName")[0].InnerText;
        string keyword = px.GetElementsByTagName("Content")[0].InnerText;

        String backWord = "";

        if (keyword.IndexOf("#") > 0)
        {
            String[] Dp = keyword.Split('#');
            if (Dp.Length >= 3)
            {
                String checkword = DpChcek(Dp[1], Dp[2], Dp[0]);
                if (checkword == "")
                {
                    String url = "http://192.168.35.33/gdSmsMsg/IReceive.aspx?phone={0}&cname={1}&idcard={2}";

                    url = String.Format(url, Dp[1], HttpUtility.UrlEncode(Dp[0], Encoding.GetEncoding("GB2312")), Dp[2]);
                    WebRequest request;
                    request = WebRequest.Create(url);
                    request.ContentType = "text/html;charset=GB2312";
                    Stream dataStream;
                    WebResponse response;

                    response = request.GetResponse();
                    dataStream = response.GetResponseStream();
                    StreamReader reader = new StreamReader(dataStream, Encoding.GetEncoding("GB2312"));
                    // Read the content.
                    string responseFromServer = reader.ReadToEnd();
                    if (responseFromServer.Substring(0, 2) == "OK")
                    {
                        backWord = responseFromServer.Substring(3);
                    }
                    else
                        backWord = "请确认：" + responseFromServer.Substring(3);
                    response = null;
                    request = null;

                }
                else
                    backWord = checkword;
            }
            else
            {
                backWord = "格式有误！请输入正确的格式：姓名#预定手机号码#身份证号";
            }
            
        }
        else
        {
            if (keyword == "Hello2BizUser")
                backWord = "欢迎关注利郎微信公众平台！";
            else
                backWord = "格式有误！请输入正确的格式：姓名#预定手机号码#身份证号";
            //WriteLog("key:"+keyword);
        }
        DateTime dt = DateTime.Now; 
       
        string textTpl = "<xml> <ToUserName><![CDATA[" + fromUsername + @"]]></ToUserName>\r\n";
        textTpl += "<FromUserName><![CDATA[" + toUsername + @"]]></FromUserName>\r\n";
        textTpl += "<CreateTime>" + DateTime.Now + @"</CreateTime>\r\n";
        textTpl += "<MsgType><![CDATA[text]]></MsgType>\r\n";
        textTpl += "<Content><![CDATA[" + backWord + @"]]></Content>\r\n";
        textTpl += "<FuncFlag>0</FuncFlag>\r\n";
        textTpl += "</xml>";
        WriteLog(textTpl);
        Response.Write(textTpl);
       
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
        string filename = Server.MapPath(@"./logs/log.txt");
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
        if (!CheckIDCard(IdCard))
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
            return true;
        }
        else if (Id.Length == 15)
        {
            //bool check = CheckIDCard15(Id);
            return true;
        }
        else
        {
            return false;
        }
    }
    public bool IsHandset(string str_handset)
    {
        if (str_handset.Length > 11) return false;
        return System.Text.RegularExpressions.Regex.IsMatch(str_handset, @"^[1]+[3-9]+\d{9}");
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
