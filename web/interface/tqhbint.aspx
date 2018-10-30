<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="HtmlAgilityPack" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<!DOCTYPE html>
<script runat="server">
    private string DBConnStr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);        

        switch (ctrl) { 
            case "GetWeatherInfo":
                string cityname = Convert.ToString(Request.Params["cityname"]);
                GetWeatherInfo(cityname);
                break;
            case "GetFlightInfo":
                string flightNo = Convert.ToString(Request.Params["flightno"]);
                string fdate = Convert.ToString(Request.Params["fdate"]);
                try {
                    fdate = Convert.ToDateTime(fdate).ToString("yyyy-MM-dd");
                }catch(Exception ex){
                    clsSharedHelper.WriteErrorInfo("查询的日期不合法！");
                    break;
                }                
                GetFlightInfo(flightNo,fdate);
                break;
            default :
                clsSharedHelper.WriteErrorInfo("无对应操作！");
                break;
        }         

        //string dm = Convert.ToString(Request.Params["dm"]);
        //string level = Convert.ToString(Request.Params["level"]);
        //GenerateData(dm, level);
    }

    //获取航班信息
    public void GetFlightInfo(string fno,string fdate) {        
        string intURL = string.Format("https://sp0.baidu.com/9_Q4sjW91Qh3otqbppnN2DJv/pae/channel/data/asyncqury?flightno={0}&date={1}&appid=4047", fno, fdate);
        string json = clsNetExecute.HttpRequest(intURL);
        clsSharedHelper.WriteInfo(json); return;
        JObject jo = JObject.Parse(json);
        string status = jo["status"].ToString();        
        if (status == "0")
        {                                    
            JArray ja = (JArray)jo["data"]["cities"];
            string fstatus = jo["data"]["flightStatus"].ToString();//航班状态
            string qname, qairport, qplantime, qdptime, qtemp, qwea="";
            string zname, zairport, zdptime, ztemp, zplantime, zpatime, zatime;
            string dname, dairport, dplantime, ddptime, dtemp, dwea="";
            string ss = "";
            if (ja.Count == 0)
                clsSharedHelper.WriteInfo("无该航班" + fno + "信息");
            else if (ja.Count == 2)
            {
                //无中转站
                qname = ja[0]["name"].ToString();//起飞城市
                qairport = ja[0]["airport"].ToString();//起飞机场
                qplantime=ja[0]["planDptTime"].ToString();//计划起飞时间
                qtemp = ja[0]["temperature"].ToString();//温度                
                qdptime = ja[0]["dptTime"].ToString();//实际起飞时间
                //获取天气情况
                ss = GetCityCurrentWea(qname);
                if (ss != "") {
                    qwea = Convert.ToString(ss.Split('|')[0]);
                    qtemp = Convert.ToString(ss.Split('|')[1]);
                }

                dname = ja[1]["name"].ToString();//到达城市
                dairport = ja[1]["airport"].ToString();//到站机场
                dplantime = ja[1]["planArrTime"].ToString();//计划到达时间
                dtemp = ja[1]["temperature"].ToString();//温度                
                ddptime = ja[1]["arrTime"].ToString();//实际到达时间
                ss = GetCityCurrentWea(dname);
                if (ss != "")
                {
                    dwea = Convert.ToString(ss.Split('|')[0]);
                    dtemp = Convert.ToString(ss.Split('|')[1]);
                }

                clsSharedHelper.WriteInfo(qname + "|" + qwea + "|" + qtemp);
            }
            else if (ja.Count == 3)
            {
                //有中转站
                qname = ja[0]["name"].ToString();//起飞城市
                qairport = ja[0]["airport"].ToString();//起飞机场
                qplantime = ja[0]["planDptTime"].ToString();//计划起飞时间
                qtemp = ja[0]["temperature"].ToString();//温度                
                qdptime = ja[0]["dptTime"].ToString();//实际起飞时间
                ss = GetCityCurrentWea(qname);
                if (ss != "")
                {
                    qwea = Convert.ToString(ss.Split('|')[0]);
                    qtemp = Convert.ToString(ss.Split('|')[1]);
                }  
                
                zname = ja[1]["name"].ToString();//中转城市
                zairport = ja[1]["airport"].ToString();//中转机场                
                ztemp = ja[1]["temperature"].ToString();//温度   
                zplantime = ja[1]["planDptTime"].ToString();//计划起飞时间                             
                zdptime = ja[1]["dptTime"].ToString();//实际起飞时间    
                zpatime = ja[1]["planArrTime"].ToString();//计划到达时间 
                zatime=ja[1]["arrTime"].ToString();//实际到达时间           
                
                dname = ja[2]["name"].ToString();//到达城市
                dairport = ja[2]["airport"].ToString();//到站机场
                dplantime = ja[2]["planArrTime"].ToString();//计划到达时间
                dtemp = ja[2]["temperature"].ToString();//温度                
                ddptime = ja[2]["arrTime"].ToString();//实际到达时间
                ss = GetCityCurrentWea(dname);
                if (ss != "")
                {
                    dwea = Convert.ToString(ss.Split('|')[0]);
                    dtemp = Convert.ToString(ss.Split('|')[1]);
                }

                clsSharedHelper.WriteInfo(qname + "|" + qwea + "|" + qtemp);
            }
            else
                clsSharedHelper.WriteInfo("获取到的信息与模板不匹配！");
        }
        else {
            string msg = jo["msg"].ToString();
            clsSharedHelper.WriteErrorInfo("status:" + status + " msg:" + msg);
        }                               
    }

    
    //飞常准网数据
    //string intURL = string.Format("http://www.veryzhun.com/searchnum.asp?flightnum={0}",fno);
    //string json = clsNetExecute.HttpRequest(intURL,"","GET","GB2312",5000);
    //clsSharedHelper.WriteInfo(json);
        
    //获取指定城市的天气情况及温度
    public string GetCityCurrentWea(string cityname) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            string str_sql = @"select top 1 citycode,cityname from t_weatherCityCodeBasic where cityname like '%'+@cname+'%' order by level desc";
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@cname", cityname));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
            {
                cityname = Convert.ToString(dt.Rows[0]["cityname"]);
                string citycode = Convert.ToString(dt.Rows[0]["citycode"]);
                if (citycode == "")
                {
                    return "";
                }
                else
                {
                    HtmlWeb webClient = new HtmlWeb();
                    HtmlDocument doc = webClient.Load(string.Format("http://www.weather.com.cn/weather/{0}.shtml", citycode));
                    HtmlNode rootNode = doc.GetElementbyId("7d");
                    HtmlNode wea = rootNode.SelectSingleNode("//ul[@class='t clearfix']/li[1]/p[@class='wea']");
                    HtmlNode temp = rootNode.SelectSingleNode("//ul[@class='t clearfix']/li[1]/p[@class='tem']");
                    return wea.InnerText + "|" + temp.InnerText;
                }
            }
            else
                return "";
        }
    }
    
    //获取天气情况
    public void GetWeatherInfo(string cityname) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            string str_sql = @"select top 1 citycode,cityname from t_weatherCityCodeBasic where cityname like '%'+@cname+'%' order by level desc";
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@cname", cityname));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count == 0)
                {
                    clsSharedHelper.WriteErrorInfo("查无该城市！可以试着缩小范围！");
                }
                else
                {
                    cityname = Convert.ToString(dt.Rows[0]["cityname"]);
                    string citycode = Convert.ToString(dt.Rows[0]["citycode"]);
                    if (citycode == "")
                    {
                        clsSharedHelper.WriteErrorInfo("查无该城市！可以试着缩小范围！");
                    }
                    HtmlWeb webClient = new HtmlWeb();
                    HtmlDocument doc = webClient.Load(string.Format("http://www.weather.com.cn/weather/{0}.shtml", citycode));
                    HtmlNode rootNode = doc.GetElementbyId("7d");
                    HtmlNode hNode = rootNode.SelectSingleNode("//ul[@class='t clearfix']");
                    clsSharedHelper.WriteInfo(hNode.InnerHtml);
                }
            }
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }
    }
    
    //生成指定一级的数据
    public void GenerateData(string dm,string level) {        
        XmlDocument xmlDoc = new XmlDocument();
        string XMLStr = clsNetExecute.HttpRequest(string.Format("http://flash.weather.com.cn/wmaps/xml/{0}.xml", dm));
        if (XMLStr.IndexOf("您访问的页面不存在") > -1)
        {
            clsSharedHelper.WriteErrorInfo("页面不存在！");
        }
        else
        {           
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
            {
                xmlDoc.LoadXml(XMLStr);
                XmlNode root = xmlDoc.DocumentElement;
                string sqls = "";
                XmlNode cnode = null;
                for (int i = 0; i < root.ChildNodes.Count; i++)
                {
                    cnode = root.ChildNodes[i];
                    sqls += string.Format(@"if not exists(select top 1 1 from t_weatherCityCodeBasic where citycode='{0}' and cityname='{1}')
                            insert into t_weatherCityCodeBasic(citycode,cityname,siteX,siteY,pyname,level,parent)
                            values('{0}','{1}','{2}','{3}','{4}','{5}','{6}');", cnode.Attributes["url"].Value, cnode.Attributes["cityname"].Value, cnode.Attributes["cityX"].Value, cnode.Attributes["cityY"].Value, cnode.Attributes["pyName"].Value, level,dm);
                }//end for

                string errinfo = dal.ExecuteNonQuery(sqls);
                if (errinfo == "")
                    clsSharedHelper.WriteSuccessedInfo("");
                else
                    clsSharedHelper.WriteErrorInfo(dm + "|" + sqls);
            }
        }        
    }


    /// <summary>
    /// 生成根级数据
    /// </summary>
    public void GenerateRootData()
    {
        XmlDocument xmlDoc = new XmlDocument();
        string XMLStr = clsNetExecute.HttpRequest(string.Format("http://flash.weather.com.cn/wmaps/xml/{0}.xml", "china"));
        if (XMLStr.IndexOf("您访问的页面不存在") > -1)
        {
            clsSharedHelper.WriteErrorInfo("页面不存在！");
        }
        else
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
            {
                xmlDoc.LoadXml(XMLStr);
                XmlNode root = xmlDoc.DocumentElement;
                string sqls = "";
                XmlNode cnode = null;
                for (int i = 0; i < root.ChildNodes.Count; i++)
                {
                    cnode = root.ChildNodes[i];
                    sqls += string.Format(@"insert into t_weatherCityCodeBasic(citycode,cityname,siteX,siteY,pyname,level,parent)
                            values('{0}','{1}','{2}','{3}','{4}','{5}','china');", "", cnode.Attributes["quName"].Value, "0", "0", cnode.Attributes["pyName"].Value, "1");
                }//end for
                
                string errinfo = dal.ExecuteNonQuery(sqls);
                if (errinfo == "")
                    clsSharedHelper.WriteSuccessedInfo("");
                else
                    clsSharedHelper.WriteErrorInfo(errinfo);
            }
        }
    }    
</script>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
</body>
</html>
