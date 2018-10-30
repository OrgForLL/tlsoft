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
    /// 创建时间 2016-09-02
    /// 开发人员：李清峰
    /// 主要用于群发功能的相关接口
    /// 服务号：利郎男装服务号
    /// 数据库：192.168.35.62 weChatPromotion
    /// </summary>  

    //private string WXDBConnStr_Test = "server='192.168.35.23';database=weChatTest;uid=lllogin;pwd=rw1894tla";
    //private string WXDBConnstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    private string WXDBConnstr = "";
    public string Configkey = "5";//利郎男装 
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsConfig.Contains("WXConnStr"))
            WXDBConnstr = clsConfig.GetConfigValue("WXConnStr");
        else
            WXDBConnstr = System.Configuration.ConfigurationManager.ConnectionStrings["WXDBConnStr"].ConnectionString;

        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "getMaterial":
                int offset = Convert.ToInt32(Request.Params["offset"]);
                string key = Convert.ToString(Request.Params["configkey"]);
                if (key == "" || key == "0" || key == null)
                    clsSharedHelper.WriteErrorInfo("请检查传入参数！");
                else
                    getMaterial(key, "news", offset, 20);
                break;
            case "sendMessage":
                string id = Convert.ToString(Request.Params["id"]);
                string creater = Convert.ToString(Request.Params["sender"]);
                string wxProvince = Convert.ToString(Request.Params["wxprovince"]);
                sendMessage(id, creater, wxProvince);
                break;
            case "massMessageEvent":
                //接收微信发送给接口页的数据
                string xmlStr = Convert.ToString(Request.Params[1]);
                massMessageEvent(xmlStr);
                break;
            //case "getOpenIDList":
            //    string khid = Convert.ToString(Request.Params["khid"]);
            //    List<string> openids = getOpenIDList("5", khid, "");
            //    string rt = "【" + string.Join(",", openids.ToArray()).Split(',').Length.ToString() + "】|" + string.Join(",", openids.ToArray());
            //    clsSharedHelper.WriteInfo(rt);
            //    break;
            case "previewMessage":
                id = Convert.ToString(Request.Params["id"]);
                string touser = Convert.ToString(Request.Params["touser"]);
                previewMessage(id, touser);
                break;
            case "previewMessageDirect":
                key = Convert.ToString(Request.Params["configkey"]);
                touser = Convert.ToString(Request.Params["touser"]);
                string mediaid = Convert.ToString(Request.Params["mediaid"]);
                string msgtype = Convert.ToString(Request.Params["msgtype"]);
                string prewxname = Convert.ToString(Request.Params["prewxname"]);
                if (key == "" || key == "0" || key == null)
                    clsSharedHelper.WriteErrorInfo("请传入使用的服务号KEY！");
                else if ((touser == "" || touser == null) && (prewxname == "" || prewxname == null))
                    clsSharedHelper.WriteErrorInfo("请传入预览对象！");
                else if (mediaid == "" || mediaid == "0" || mediaid == null)
                    clsSharedHelper.WriteErrorInfo("请传入消息MEDIAID！");
                else if (msgtype == "" || msgtype == null)
                    clsSharedHelper.WriteErrorInfo("请传入消息类型！");
                else
                    previewMessageDirect(key, touser, prewxname, mediaid, msgtype);
                break;
            //统计某个KHID下微信用户数
            case "staticWXUsers":
                key = Convert.ToString(Request.Params["configkey"]);
                string khid = Convert.ToString(Request.Params["khid"]);
                wxProvince = Convert.ToString(Request.Params["wxprovince"]);
                if (key == "" || key == "0" || key == null)
                    clsSharedHelper.WriteErrorInfo("请传入使用的服务号KEY！");
                else if ((khid == "" || khid == "0" || khid == null) && (wxProvince == "" || wxProvince == null))
                    clsSharedHelper.WriteErrorInfo("请传入统计对象！");
                else
                    staticWXUsers(key, khid, wxProvince);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("请检查传入的CTRL是否有效！");
                break;
        }
    }

    //处理群发任务后微信推送的发送结果报告
    public void massMessageEvent(string xmlstr)
    {
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(WXDBConnstr))
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

    //预览接口 该方法不取数据库数据
    public void previewMessageDirect(string key, string touser, string prewxname, string mediaid, string msgtype)
    {
        string jsonStr = "";
        string url = string.Format("https://api.weixin.qq.com/cgi-bin/message/mass/preview?access_token={0}", getToken(Convert.ToString(key)));
        if (prewxname != "")
        {
            jsonStr = @"{{
                           ""towxname"":""{0}"", 
                           ""mpnews"":{{              
                                    ""media_id"":""{1}""               
                                     }},
                           ""msgtype"":""{2}""
                        }}";
            jsonStr = string.Format(jsonStr, prewxname, mediaid, msgtype);
        }
        else
        {
            jsonStr = @"{{
                      ""touser"":""{0}"", 
                      ""{1}"":{{              
                                ""media_id"":""{2}""
                              }},
                             ""msgtype"":""{1}"" 
                              }}";
            jsonStr = string.Format(jsonStr, touser, msgtype, mediaid);
        }
        string content = PostDataToWX(url, jsonStr);
        JObject jo = JObject.Parse(content);
        if (Convert.ToString(jo["errcode"]) == "0")
            clsSharedHelper.WriteInfo("预览发送成功！");
        else
            clsSharedHelper.WriteInfo(content);
    }

    //预览接口 也可以直接指定微信号但是每日只能调用100次
    public void previewMessage(string id, string touser)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnstr))
        {
            string str_sql = @" select top 1 a.configkey,a.mediaid,a.msgtype
                                from wx_t_MassMessageTask a 
                                where a.isremove=0 and a.id=@id";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@id", id));
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string url = string.Format("https://api.weixin.qq.com/cgi-bin/message/mass/preview?access_token={0}", getToken(Convert.ToString(dt.Rows[0]["configkey"])));
                    string mediaid = Convert.ToString(dt.Rows[0]["mediaid"]);
                    string msgtype = Convert.ToString(dt.Rows[0]["msgtype"]);
                    string jsonStr = @"{{
                                           ""touser"":""{0}"", 
                                           ""{1}"":{{              
                                                    ""media_id"":""{2}""
                                                     }},
                                           ""msgtype"":""{1}"" 
                                        }}";
                    jsonStr = string.Format(jsonStr, touser, msgtype, mediaid);
                    string content = PostDataToWX(url, jsonStr);
                    JObject jo = JObject.Parse(content);
                    if (Convert.ToString(jo["errcode"]) == "0")
                        clsSharedHelper.WriteInfo("预览发送成功！");
                    else
                        clsSharedHelper.WriteInfo(content);
                }
                else
                    clsSharedHelper.WriteErrorInfo("请确保ID有效性！");
            }
            else
                clsSharedHelper.WriteErrorInfo("预览接口-查询数据时出错:" + errinfo);
        }
    }

    /// <summary>
    /// 获取素材列表
    /// </summary>
    /// <param name="type">素材的类型，图片（image）、视频（video）、语音 （voice）、图文（news）</param>
    public void getMaterial(string key, string type, int offset, int size)
    {
        string _data = @"{{
                            ""type"":""{0}"",
                            ""offset"":{1},
                            ""count"":{2}
                         }}";
        _data = string.Format(_data, type, offset, 20);
        string url = string.Format("https://api.weixin.qq.com/cgi-bin/material/batchget_material?access_token={0}", getToken(key));
        string content = PostDataToWX(url, _data);
        JObject jo = JObject.Parse(content);
        string errcode = Convert.ToString(jo["errcode"]);
        if (errcode == "")
        {
            clsSharedHelper.WriteInfo(content);
        }
        else
            clsSharedHelper.WriteErrorInfo(content);
    }

    /// <summary>
    /// 群发消息接口 传入wx_t_MassMessageTask.id
    /// </summary>
    public void sendMessage(string id, string creater, string wxprovince)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnstr))
        {
            string str_sql = @" select top 1 a.configkey,a.mediaid,a.msgtype,a.receiver
                                from wx_t_MassMessageTask a 
                                where a.isremove=0 and a.id=@id";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@id", id));
            DataTable dt;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string msg_json = "";
                    string key = Convert.ToString(dt.Rows[0]["configkey"]);
                    string _token = getToken(key);
                    string url = @"https://api.weixin.qq.com/cgi-bin/message/mass/send?access_token={0}";
                    url = string.Format(url, _token);
                    string mediaid = Convert.ToString(dt.Rows[0]["mediaid"]);
                    string msgtype = Convert.ToString(dt.Rows[0]["msgtype"]);
                    string receiver = Convert.ToString(dt.Rows[0]["receiver"]);
                    //图文消息
                    if (msgtype == "mpnews")
                    {
                        List<string> users = getOpenIDList(key, receiver, wxprovince);
                        int sendCounts = users.Count, succesCount = 0, failCount = 0;
                        for (int i = 0; i < users.Count; i++)
                        {
                            msg_json = @"{{
                                       ""touser"":[{0}],
                                       ""mpnews"":{{
                                          ""media_id"":""{1}""
                                       }},
                                        ""msgtype"":""{2}""
                                    }}";
                            msg_json = string.Format(msg_json, users[i], mediaid, msgtype);
                            string content = PostDataToWX(url, msg_json);
                            JObject jo = JObject.Parse(content);
                            string errcode = Convert.ToString(jo["errcode"]);
                            if (errcode == "0")
                            {
                                str_sql = @"insert into wx_t_MessageSendResult(massid,msgid,msgdataid,creater)
                                            values(@id,@msgid,@msgdataid,@creater);
                                            update wx_t_MassMessageTask set wxusers=@wxusers where id=@id;";
                                string msgid = Convert.ToString(jo["msg_id"]);
                                string msgdataid = Convert.ToString(jo["msg_data_id"]);
                                paras.Clear();
                                paras.Add(new SqlParameter("@id", id));
                                paras.Add(new SqlParameter("@msgid", msgid));
                                paras.Add(new SqlParameter("@msgdataid", msgdataid));
                                paras.Add(new SqlParameter("@creater", creater));
                                paras.Add(new SqlParameter("@wxusers", Convert.ToString(string.Join(",", users.ToArray()).Split(',').Length)));
                                errinfo = dal.ExecuteNonQuerySecurity(str_sql, paras);
                                succesCount++;
                            }
                            else
                            {
                                failCount++;
                                //WriteLog(content);                                
                            }
                        }//end              
                        clsSharedHelper.WriteInfo("【" + DateTime.Now.ToString() + "】 任务提交成功：总共发送【" + sendCounts.ToString() + "】次（每次最多8000个用户），其中成功【" + succesCount.ToString() + "】，失败【" + failCount.ToString() + "】");
                    }
                }
                else
                    clsSharedHelper.WriteErrorInfo("请检查任务是否存在！");
            }
            else
                clsSharedHelper.WriteErrorInfo("查询群发任务时出错 " + errinfo);
        }//end using 
    }

    public void staticWXUsers(string key, string khid, string wxprovince)
    {
        //如果有传入khid且key=5则优先按khid统计，反之按省份统计
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
        {
            string str_sql = "", objectid = "";
            switch (key)
            {
                case "5":
                    objectid = "1";
                    break;
                case "7":
                    objectid = "4";
                    break;
                default:
                    objectid = "-1";
                    break;
            }//end switch
            List<SqlParameter> paras = new List<SqlParameter>();
            //2018-04-07 小薛通知62库去掉了yx_t_khb
            if (khid != "" && khid != "0")
            {
                str_sql = @"select count(wxOpenid) users
                        from wx_t_vipbinging wx 
                        inner join yx_t_khb kh on wx.khid=kh.khid
                        where objectid=@objectid and kh.ccid+'-' like @khid ";
                paras.Add(new SqlParameter("@khid", "%-" + khid + "-%"));
            }
            else
            {
                str_sql = "select count(wxopenid) users from wx_t_vipbinging where objectid=@objectid ";
            }

            if (wxprovince != "")
            {
                wxprovince = "%" + wxprovince + "%";
                str_sql += " and wxprovince like @wxprovince";
                paras.Add(new SqlParameter("@wxprovince", wxprovince));
            }

            paras.Add(new SqlParameter("@objectid", objectid));
            object scalar;
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
            if (errinfo == "")
                clsSharedHelper.WriteInfo(Convert.ToString(scalar));
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }//end using  
    }

    //拼接openid
    public List<String> getOpenIDList(string key, string khid, string wxprovince)
    {
        //每6000个发送一次
        List<String> opendList = new List<string>();
        string objectid = "";
        //string _dbconnStr = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
        {
            string str_sql = "";
            List<SqlParameter> paras = new List<SqlParameter>();
            if (khid == "-1")
            {
                str_sql = @"select 'oarMEt8bqjmZIAhImSXBAg0G7F0I' openid 
                            union all
                            select 'oarMEtzTmu6TCIO1mibQVSYfg94M' openid
                            union all
                            select 'oarMEt6cRU2nk3GkRGHfyIfnJZ4c' openid
                            union all
                            select 'oarMEt3YWz0gndx1RmWolC423swM' openid
                            ";
            }
            else
            {
                switch (key)
                {
                    case "5":
                        objectid = "1";
                        break;
                    case "7":
                        objectid = "4";
                        break;
                    default:
                        objectid = "-1";
                        break;
                }//end switch

                if (khid != "" && khid != "0")
                {
                    str_sql = @"select wx.wxopenid openid
                                from wx_t_vipbinging wx 
                                inner join yx_t_khb kh on wx.khid=kh.khid
                                where objectid=@objectid and kh.ccid+'-' like @khid ";
                    paras.Add(new SqlParameter("@khid", "%-" + khid + "-%"));
                }
                else
                {
                    str_sql = "select wx.wxopenid openid from wx_t_vipbinging where objectid=@objectid ";
                }


                if (wxprovince != "")
                {
                    wxprovince = "%" + wxprovince + "%";
                    str_sql += " and wxprovince like @wxprovince";
                    paras.Add(new SqlParameter("@wxprovince", wxprovince));
                }
                paras.Add(new SqlParameter("@objectid", objectid));
            }

            DataTable dt; int count = 0;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);            
            //WriteLog("正式发送：【" + dt.Rows.Count.ToString() + "】" + JsonHelp.dataset2json(dt));
            string openidStr = "";
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                if (dt.Rows.Count == 1)
                {
                    opendList.Add(Convert.ToString("\"" + dt.Rows[0]["openid"]) + "\",\"\"");
                }
                else
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        openidStr = string.Concat(openidStr, string.Format("\"{0}\",", Convert.ToString(dt.Rows[i]["openid"])));
                        count++;
                        if (count == 6000)
                        {
                            opendList.Add(openidStr.Substring(0, openidStr.Length - 1));
                            count = 0;
                            openidStr = "";
                        }
                    }//end for
                    if (openidStr != "")
                        opendList.Add(openidStr.Substring(0, openidStr.Length - 1));
                }
            }//openid至少要有两个
        }
        return opendList;
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

    //读取数据库中的ACCESS_TOKEN
    public string getToken(string key)
    {
        string _AT = "";
        using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM("server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion"))
        {
            string str_sql = "select top 1 accesstoken from wx_t_tokenconfiginfo where configkey='" + key + "'";
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

    //时间戳转换成日期
    private DateTime unixTime2Date(string timeStamp)
    {
        DateTime dtStart = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        long lTime = long.Parse(timeStamp + "0000000");
        TimeSpan toNow = new TimeSpan(lTime); return dtStart.Add(toNow);
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
