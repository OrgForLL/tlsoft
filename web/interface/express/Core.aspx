<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="HtmlAgilityPack" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Net" %>
<!DOCTYPE html>
<script runat="server"> 
    private string DBConstr = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";
    private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";
    protected void Page_Load(object sender, EventArgs e) {        
        //string json2 = clsNetExecute.HttpRequest("http://api.kuaidiwo.cn:88/api/?key=6DUXNSwjwXBs&com=yuantong&cno=881540594786594393&sort=desc");
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
