<%@ Page Language="C#" AspCompat="true"%>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="HtmlAgilityPack" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Windows.Forms" %>
<!DOCTYPE html>
<script runat="server"> 
    private string DBConstr = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";
    private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    protected void Page_Load(object sender, EventArgs e) {

        clsSharedHelper.WriteInfo(GenerateCheckCode(12));
        
        WebBrowser browser = new WebBrowser();
        browser.ScriptErrorsSuppressed = true;
        browser.Navigate("http://www.baidu.com");
        //if (browser.StatusText == "完成")
            //clsSharedHelper.WriteInfo("donen");
        return;
        string json = @"{
                        ""errcode"": ""0"",
                        ""ems_info"": {
                            ""kind"": ""圆通"",
                            ""num"": ""881540594786594393"",
                            ""des"": [],
                            ""state"": ""2""
                        },
                        ""track_data"": {
                            ""data"": [
                                {
                                    ""datetime"": ""2016-04-10 17:08:26"",
                                    ""place"": [],
                                    ""info"": ""山东省青岛市湛山分部公司 取件人: 刘冰冰 已收件""
                                },
                                {
                                    ""datetime"": ""2016-04-10 17:30:24"",
                                    ""place"": [],
                                    ""info"": ""山东省青岛市湛山分部公司 已揽收""
                                },
                                {
                                    ""datetime"": ""2016-04-10 19:36:56"",
                                    ""place"": [],
                                    ""info"": ""山东省青岛市公司 已收入""
                                }
                            ]
                        }
                    }";        
        
        using (LiLanzDALForXLM dal23 = new LiLanzDALForXLM(DBConstr)) {
            string str_sql = @"select id,num,com,comname,wxopenid,updatetime,remark,[sign],adata
                                from cs_t_myexpress
                                where status<>'3'";
            DataTable dt = null;
            string errinfo = dal23.ExecuteQuery(str_sql,out dt);
            if (errinfo == "") {
                for (int i = 0; i < dt.Rows.Count; i++) {
                    string id = Convert.ToString(dt.Rows[i]["id"]);
                    string num=Convert.ToString(dt.Rows[i]["num"]);
                    string comname=Convert.ToString(dt.Rows[i]["comname"]);
                    string wxopenid=Convert.ToString(dt.Rows[i]["wxopenid"]);
                    string updatetime=Convert.ToString(dt.Rows[i]["updatetime"]);
                    string remark=Convert.ToString(dt.Rows[i]["remark"]);
                    string sign=Convert.ToString(dt.Rows[i]["sign"]);
                    string adata=Convert.ToString(dt.Rows[i]["adata"]);

                    //检查快递当前状态
                    JObject jo = JObject.Parse(json);
                    string errcode = Convert.ToString(jo["errcode"]);
                    if (errcode == "0")
                    {
                        string state = Convert.ToString(jo["ems_info"]["state"]);
                        JArray ja_data = (JArray)jo["track_data"]["data"];
                        if (ja_data.Count > 0) {                            
                            string lasttime = Convert.ToString(ja_data[0]["datetime"]);
                            string content=Convert.ToString(ja_data[0]["info"]);                            
                            if (Convert.ToDateTime(lasttime).ToString("yyyy-MM-dd HH:mm:ss") != Convert.ToDateTime(updatetime).ToString("yyyy-MM-dd HH:mm:ss"))
                            { 
                                //进度有更新 接下来先更新数据库
                                str_sql = string.Format("delete from cs_t_myexpstatus where id={0};",id);
                                for (int j = 0; j < ja_data.Count; j++) {
                                    string datetime = Convert.ToString(ja_data[j]["datetime"]);
                                    string info = Convert.ToString(ja_data[j]["info"]);
                                    str_sql += string.Format("insert into cs_t_myexpstatus(id,[time],info,isnotice) values ({0},'{1}','{2}',{3});", id, datetime, info, 1);
                                }//end for
                                
                                //更新主表
                                if (state == "3")
                                    str_sql += string.Format(" update cs_t_myexpress set status='{0}',updatetime='{1}',[sign]='{2}',adata='{3}' where id='{4}';", state, lasttime, Convert.ToString(jo["ems_info"]["sign"]), Convert.ToString(jo["ems_info"]["adata"]), id);
                                else
                                    str_sql += string.Format(" update cs_t_myexpress set status='{0}',updatetime='{1}' where id='{2}';", state, lasttime, id);

                                errinfo = dal23.ExecuteNonQuery(str_sql);
                                if (errinfo == "")
                                {
                                    //接下来发送微信模板通知
                                    errinfo = SendWXNotice(wxopenid, comname, num, content, remark, lasttime);
                                    if (errinfo != "") {
                                        dal23.ExecuteNonQuery(string.Format("update cs_t_myexpress set updatetime='' where id={0}", id));
                                    }
                                    clsSharedHelper.WriteInfo(errinfo);
                                }
                                else
                                    clsSharedHelper.WriteInfo("更新快递数据时失败 " + errinfo + "【" + str_sql + "】");
                            }//有更新
                        }                                                                                         
                    }
                    else if (errcode == "-10")
                        clsSharedHelper.WriteInfo("当天调用次数超过限制");
                                       
                }//end for
            }                
        }
    }

    public string UnicodeDecode(string str) {
        //最直接的方法Regex.Unescape(str);
        StringBuilder strResult = new StringBuilder();
        if (!string.IsNullOrEmpty(str))
        {
            string[] strlist = str.Replace("\\", "").Split('u');
            try
            {
                for (int i = 1; i < strlist.Length; i++)
                {
                    int charCode = Convert.ToInt32(strlist[i], 16);
                    strResult.Append((char)charCode);
                }
            }
            catch (FormatException ex)
            {
                return Regex.Unescape(str);
            }
        }
        return strResult.ToString();
    }
    
    public string GetAccessToken(string key) {
        string access_token = "";
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(DBConstr)) {
            string sql = string.Format("select accesstoken from wx_t_tokenconfiginfo where configkey='{0}'",key);
            DataTable dt = null;
            string errinfo = dal62.ExecuteQuery(sql,out dt);
            if (errinfo == "" && dt.Rows.Count > 0) {
                access_token = dt.Rows[0]["accesstoken"].ToString();
            }

            return access_token;
        }
    }

    public string SendWXNotice(string receiver, string comname, string comnu, string info, string mark, string time)
    {
        string access_token = GetAccessToken("2");
        string postURL = string.Format("https://api.weixin.qq.com/cgi-bin/message/template/send?access_token={0}",access_token);
        string tempid = "HQPWZA7OZW0LW-Mk5Mh3X_H2nC7fL6_-KWHRYRIp6bY";
        string notice = @"{{
                           ""touser"":""{0}"",
                           ""template_id"":""{1}"",
                           ""url"":"""",
                           ""topcolor"":""#575d6a"",
                           ""data"":{{
                                   ""expressCom"": {{
                                       ""value"":""{2}"",
                                       ""color"":""#575d6a""
                                   }},
                                   ""expressNo"":{{
                                       ""value"":""{3}"",
                                       ""color"":""#575d6a""
                                   }},
                                   ""expressStatus"":{{
                                       ""value"":""{4}"",
                                       ""color"":""#e63863""
                                   }},
                                   ""expressMark"":{{
                                       ""value"":""{5}"",
                                       ""color"":""#575d6a""
                                   }},
                                   ""time"":{{
                                       ""value"":""{6}"",
                                       ""color"":""#575d6a""
                                   }}
                              }}
                           }}";
        notice = string.Format(notice, receiver, tempid, comname, comnu, info, mark, time);
        string wxinfo = PostDataToWX(postURL, notice);
        JObject jo = JObject.Parse(wxinfo);
        if (Convert.ToString(jo["errcode"]) != "0")
            return jo["errmsg"].ToString() + "|" + access_token;
        else
            return "";                
    }
    
    private int rep = 0;
    public string GenerateCheckCode(int codeCount)
    {
        string str = string.Empty;
        long num2 = DateTime.Now.Ticks + this.rep;
        this.rep++;
        Random random = new Random(((int)(((ulong)num2) & 0xffffffffL)) | ((int)(num2 >> this.rep)));
        for (int i = 0; i < codeCount; i++)
        {
            char ch;
            int num = random.Next();
            if ((num % 2) == 0)
            {
                ch = (char)(0x30 + ((ushort)(num % 10)));
            }
            else
            {
                ch = (char)(0x41 + ((ushort)(num % 0x1a)));
            }
            str = str + ch.ToString();
        }
        return str;
    }
    
    private String PostDataToWX(string url, string postData)
    {        
        Stream outstream = null;
        Stream instream = null;
        StreamReader sr = null;
        HttpWebResponse response = null;
        HttpWebRequest request = null;
        Encoding encoding = Encoding.UTF8;
        byte[] data = encoding.GetBytes(postData);
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
        instream = response.GetResponseStream();
        sr = new StreamReader(instream, encoding);
        //返回结果网页（html）代码
        return sr.ReadToEnd();
    }

    //下载文件
    public String DownloadFile(string URL, string filename)
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


    public string GetUrltoHtml(string Url)
    {
        StringBuilder content = new StringBuilder();
        try
        {
            // 与指定URL创建HTTP请求
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(Url);
            request.UserAgent = "Mozilla/5.0 (iPad; U; CPU OS 3_2_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B500 Safari/531.21.10";
            request.Method = "GET";
            request.Accept = "*/*";
            request.ContentType = "application/x-www-form-urlencoded";
            request.Headers.Add("Accept-Language", "zh-cn,en-us;q=0.5");
            //如果方法验证网页来源就加上这一句如果不验证那就可以不写了
            //request.Referer = "http://m.kuaidi100.com";
            CookieContainer objcok = new CookieContainer();
            objcok.Add(new Uri("http://m.kuaidi100.com"), new Cookie("kd_history", "%5B%7B%22code%22%3A%22yuantong%22%2C%22nu%22%3A%22881540594786594393%22%2C%22time%22%3A%222016-04-13T11%3A59%3A09.093Z%22%2C%22ischeck%22%3A%221%22%7D%2C%7B%22code%22%3A%22tiantian%22%2C%22nu%22%3A%22550290278911%22%2C%22time%22%3A%222016-04-13T11%3A42%3A27.465Z%22%2C%22ischeck%22%3A%220%22%7D%2C%7B%22code%22%3A%22yuantong%22%2C%22nu%22%3A%22881443775034378914%22%2C%22time%22%3A%222016-04-13T11%3A14%3A33.641Z%22%2C%22ischeck%22%3A%221%22%7D%2C%7B%22code%22%3A%22huitongkuaidi%22%2C%22nu%22%3A%2270530804054766%22%2C%22time%22%3A%222016-04-13T01%3A58%3A40.302Z%22%2C%22ischeck%22%3A0%7D%5D"));
            objcok.Add(new Uri("http://m.kuaidi100.com"), new Cookie("toolbox_urls", ""));
            //objcok.Add(new Uri("http://txw1958.cnblogs.com"), new Cookie("键", "值"));
            //objcok.Add(new Uri("http://txw1958.cnblogs.com"), new Cookie("sidi_sessionid", "360A748941D055BEE8C960168C3D4233"));
            request.CookieContainer = objcok;
            //不保持连接
            //request.KeepAlive = true;
            // 获取对应HTTP请求的响应
            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            // 获取响应流
            Stream responseStream = response.GetResponseStream();
            // 对接响应流(以"GBK"字符集)
            StreamReader sReader = new StreamReader(responseStream, Encoding.GetEncoding("gb2312"));
            // 开始读取数据
            Char[] sReaderBuffer = new Char[256];
            int count = sReader.Read(sReaderBuffer, 0, 256);
            while (count > 0)
            {
                String tempStr = new String(sReaderBuffer, 0, count);
                content.Append(tempStr);
                count = sReader.Read(sReaderBuffer, 0, 256);
            }
            // 读取结束
            sReader.Close();
        }
        catch (Exception ex)
        {
            content = new StringBuilder("Runtime Error"+ex.Message);
        }
        return content.ToString();
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta charset="utf-8" />
    <title></title>  
    <script type="text/javascript" src="jquery.js"></script>  
</head>
<body>

    <script type="text/javascript">
        window.onload = function () {
            $.ajax({
                type: "POST",
                timeout: 10000,
                url: "https://sp0.baidu.com/9_Q4sjW91Qh3otqbppnN2DJv/pae/channel/data/asyncqury?com=yuantong&nu=881540594786594393&appid=4001",
                data: { },
                success: function (data) {
                    alert(data);
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    
                }
            });
        }
    </script>
</body>
</html>
