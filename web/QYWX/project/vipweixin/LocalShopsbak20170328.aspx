<%@ Page Language="C#" %>
<%@ Import Namespace = "System" %>
<%@ Import Namespace = "System.Collections.Generic" %>
<%@ Import Namespace = "System.Web" %>
<%@ Import Namespace = "System.Web.UI" %>
<%@ Import Namespace = "System.Web.UI.WebControls" %>
<%@ Import Namespace = "Newtonsoft.Json" %>
<%@ Import Namespace = "Newtonsoft.Json.Linq" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Text" %>
<%@ Import Namespace = "nrWebClass" %>
<%@ Import Namespace = "System.IO" %>
<%@ Import Namespace = "System.Text.RegularExpressions" %>
<%@ Import Namespace = "System.Net" %>
<%@ Import Namespace = "System.Collections.Generic" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>周边店铺信息</title>
            <script runat="server">
                private const string ConfigKeyValue = "5";	//微信配置信息索引值
                public StringBuilder html = new StringBuilder();
                protected void Page_Load(object sender, EventArgs e)
                {

                    {

                        string openid = "";
                        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
                        {
                            openid = Convert.ToString(Session["openid"]);

                        }

                        String lat="", lng="";
                        Double distance=0.0;

                        
                        string cid = "1";
                        string errInfo, city = "";
                        DataTable dt;
                        //DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
                        string posturl = "https://api.weixin.qq.com/sns/oauth2/access_token?appid={0}&secret={1}&grant_type=authorization_code";

                        posturl = String.Format(posturl, common.appid, common.secret);

                        string sqlcomm = @"select top 1 Lat,Lon from [wx_userPosition] 
                        where wxOpenid = @openid order by CREATEtime desc";
                        List<SqlParameter> para = new List<SqlParameter>();
                        para.Add(new SqlParameter("@openid", openid));
                        //using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("ChatProConnStr")))
                        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("FormalModeConnStr")))
                        {
                            errInfo = dal.ExecuteQuerySecurity(sqlcomm,para, out dt);
                            para = null;
                        }
                        if (errInfo == "")
                        {
                            posturl = string.Format(common.baidumap, Convert.ToString(dt.Rows[0]["Lat"]), Convert.ToString(dt.Rows[0]["Lon"]));
                            lat = Convert.ToString(dt.Rows[0]["Lat"]);
                            lng = Convert.ToString(dt.Rows[0]["Lon"]);
                            //clsSharedHelper.WriteInfo(lat);
                            //return;
                            JObject jo = ((JObject)JsonConvert.DeserializeObject(common.HttpRequest(posturl)));
                            string status = jo["status"].ToString();
                            if (status == "0")
                            {
                                //正常返回
                                city = jo["result"]["addressComponent"]["district"].ToString();
                            }
                        }
                        else
                            {
                                msg.Text = @"发送你的位置，寻找离你最近的专卖店：<br/>
                        1、点击左下方的“小键盘”<br/>
                        2、点击“+”键<br/>
                        3、点击“位置”<br/>
                        4、成功定位后点击“发送”";
                            }

                        if (city != "")
                        {

                            city = city.Substring(0, city.Length - 1);
                            //clsSharedHelper.WriteInfo(city);
                            //return;
                            html.AppendFormat("{0}附近专卖店", city);
                            sqlcomm = @" select t1.id,t1.zmdmc,yjmstreet,c.addressinfo,yphone,t2.khid,isnull(c.Lat,0.0) as zmdLat,isnull(C.Lng,0.0) as zmdLng,CASE WHEN ISNULL(c.mapid,0)=0 then 'hidden' else 'visible' end  bs from (select id,khid,max(yjmstreet) yjmstreet,max(yphone) yphone,max(zmdmc) zmdmc
                                          from yx_t_jmspb where jmcity like '%" + city +@"%' group by id,khid) as t1
                                        INNER JOIN yx_T_khb as t2 on t1.khid=t2.khid and t2.ty=0 left join wx_t_storepointlocation c on t1.id=c.mapid and c.maptype='jm' ";
                            //List<SqlParameter> para1 = new List<SqlParameter>();
                            //para.Add(new SqlParameter("@city", city));
                            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("FormalModeConnStr")))
                            {
                                errInfo = dal.ExecuteQuery(sqlcomm, out dt);
                                //para1 = null;
                            }
                            if (errInfo == "")
                            {
                                
                                foreach (DataRow row in dt.Rows)
                                {
                                    if (Convert.ToString(row["zmdLat"]) != "")
                                    {
                                        //Response.Write(Convert.ToString(row["zmdmc"]) + '|' + GetDistance.getDistance(Convert.ToDouble(lat), Convert.ToDouble(lng), Convert.ToDouble(row["zmdLat"]), Convert.ToDouble(row["zmdLng"])));
                                        //Response.End();
                                        if (GetDistance.getDistance(Convert.ToDouble(lat), Convert.ToDouble(lng), Convert.ToDouble(row["zmdLat"]), Convert.ToDouble(row["zmdLng"]))<=10000)
                                        {
                                            distance = Convert.ToDouble((GetDistance.getDistance(Convert.ToDouble(lat), Convert.ToDouble(lng), Convert.ToDouble(row["zmdLat"]), Convert.ToDouble(row["zmdLng"])) / 1000).ToString("0.00"));
                                            html.AppendFormat(@"<li><div class='cell'><div class='label'>店铺：</div><div class='labelval'>{0}</div> </div>
                                                     <div class='cell'><div class='label'>地址：</div><div class='labelval'>{1}</div> </div>     
                                                     <div class='cell'><div class='label'>联系电话：</div><div class='labelval'>{2}</div> </div>
                                                     <div class='btns floatfix'><p><i class='fa fa-bullhorn'></i><a href='LocalPromotion.aspx?shop={3}'>最新活动</a></p>
                                                    <p style='visibility:{7}'><i class='fa fa-map-marker'></i><a href='map4.aspx?zmdLat={4}&zmdLng={5}&lat={9}&lng={10}&mapid={6} ' >{11}KM</a></p></div></li>",
                                        Convert.ToString(row["zmdmc"]), Convert.ToString(row["addressinfo"]), Convert.ToString(row["yphone"]), Convert.ToString(row["khid"]), Convert.ToString(row["zmdLat"]), Convert.ToString(row["zmdLng"]), Convert.ToString(row["id"]), Convert.ToString(row["bs"]), Convert.ToString(row["addressinfo"]), lat, lng,distance);
                                
                                        }
                                    }
                                       //?zmdLat={4}&zmdLng={5}&lat={9}&lng={10} &zmdmc={6}&addressInfo={8}
                                }
                            }
                            else {

                            }
                            
                           
                        }
                    }
                }
                /***** * 取两坐标之间的距离 *****/
                public class GetDistance {    
                    private static double EARTH_RADIUS = 6378.137;//地球半径    
                    private static double rad(double d)    
                    {       
                        return d * Math.PI / 180.0;   
                    }   
                    public static double getDistance(double lat1, double lng1, double lat2, double lng2)    
                    {       
                        double radLat1 = rad(lat1);       
                        double radLat2 = rad(lat2);       
                        double a = radLat1 - radLat2;       
                        double b = rad(lng1) - rad(lng2);      
                        double s = 2 * Math.Asin(Math.Sqrt(Math.Pow(Math.Sin(a/2),2) +Math.Cos(radLat1)*Math.Cos(radLat2)*Math.Pow(Math.Sin(b/2),2)));       
                        s = s * EARTH_RADIUS;       
                        s = Math.Round(s * 10000*1000) / 10000;//米       
                        return s;    
                    }
                }
                public class common
                {
                public const string appid = "wx821a4ec0781c00ca";
                public const string secret = "a68357539ec388f322787d6d518d6daf";
                public const string baidumap = "http://api.map.baidu.com/geocoder/v2/?ak=7Um0jdvLYbGWc6IFtd6gcdpg&location={0},{1}&output=json&pois=0";
                static public string HttpRequest(string url)
                {
                    HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
                    request.ContentType = "application/x-www-form-urlencoded";

                    HttpWebResponse myResponse = (HttpWebResponse)request.GetResponse();
                    StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8);
                    return reader.ReadToEnd();//得到结果
                }
                ///
                /// 写日志(用于跟踪)
                ///
                static public void WriteLog(string strMemo)
                {
                    string path = System.Web.HttpContext.Current.Request.PhysicalApplicationPath;
                    string filename = path + @"/logs/log.txt";
                    if (!Directory.Exists(path + @"/logs/"))
                        Directory.CreateDirectory(path + @"/logs/");
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
                public static string ConnectionByID(string tzid, string cid)
                {
                    String CustomerLevel = "0",errInfo, CustomerLevelStr = "", DBName = "", CustomerID = "";

                    DataTable dt;
                    //DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
                    String sql = @"SELECT DBServer,DBName,ccid,jb FROM yx_t_khb WHERE khid = @tzid ";

                    List<SqlParameter> para = new List<SqlParameter>();
                    para.Add(new SqlParameter("@tzid", tzid));

                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("FormalModeConnStr")))
                    {
                        errInfo = dal.ExecuteQuerySecurity(sql,para, out dt);
                        para = null;
                    }
                    if (errInfo == "")
                    {
                        CustomerLevel = dt.Rows[0]["jb"].ToString();
                        CustomerLevelStr = dt.Rows[0]["ccid"].ToString();
                        DBName = dt.Rows[0]["DBName"].ToString();
                    }
                    else { 
                    }
                    
                    if (int.Parse(CustomerLevel) > 0)
                    {
                        String[] arr = Regex.Split(CustomerLevelStr, "-", RegexOptions.IgnoreCase);
                        if (arr.Length > 2)
                        {
                            CustomerID = arr[2];
                            sql = @"SELECT DBServer,DBName FROM yx_t_khb WHERE khid = @CustomerID ";

                            List<SqlParameter> para1 = new List<SqlParameter>();
                            para1.Add(new SqlParameter("@CustomerID", CustomerID));

                            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("FormalModeConnStr")))
                            {
                                errInfo = dal.ExecuteQuerySecurity(sql, para1,out dt);
                                para1 = null;
                            }
                            if (errInfo == "")
                            {

                                DBName = dt.Rows[0]["DBName"].ToString();
                            }
                            else
                            {
                            }
                            

                        }
                    }
                    return Class_BBlink.LILANZ.DatabaseConn.get(DBName);
                }
                }
                public class WXAccessToken
                {
                    private String accessToken;

                    [JsonProperty("access_token")]
                    public String AccessToken
                    {
                        get { return accessToken; }
                        set { accessToken = value; }
                    }


                    private int expiresIn;

                    [JsonProperty("expires_in")]
                    public int ExpiresIn
                    {
                        get { return expiresIn; }
                        set { expiresIn = value; }
                    }


                    private String refreshToken;

                    [JsonProperty("refresh_token")]
                    public String RefreshToken
                    {
                        get { return refreshToken; }
                        set { refreshToken = value; }
                    }


                    private String openid;

                    [JsonProperty("openid")]
                    public String Openid
                    {
                        get { return openid; }
                        set { openid = value; }
                    }


                    private String scope;

                    [JsonProperty("scope")]
                    public String Scope
                    {
                        get { return scope; }
                        set { scope = value; }
                    }
                }
                
            </script>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        
#storeinfo {
            background-color: #f7f7f7;
            color: #303030;
            font-family: "San Francisco",Helvitica Neue,Helvitica,Arial,sans-serif;
        }

        .page {
            padding: 15px 0;
        }

        .title {
            font-size: 1.2em;
            padding-left: 10px;
            margin-bottom: -8px;
            color: #888;
        }

        .storeul li {
            background: #fff;
            box-shadow: 0 1px .5px #eceef1;
            margin-top: 10px;
        }

        .btns {
            border-top: 1px solid #ebebeb;
        }

            .btns p {
                width: 50%;
                float: left;
                padding: 10px;
                text-align: center;
                font-size: 1.2em;
            }

                .btns p:first-child {
                    border-right: 1px solid #ebebeb;
                }

        .cell {
            position: relative;
            display: -webkit-box;
            display: -webkit-flex;
            display: flex;
            -webkit-box-align: center;
            -webkit-align-items: center;
            align-items: center;
            overflow: hidden;
            font-size: 1.2em;
            line-height: 36px;
        }

            .cell .label {
                text-align: center;
                width: 94px;
                background: #ebebeb;
            }

            .cell .labelval {
                padding-left: 10px;
            }
        .btns i {
            margin-right:5px;
        }
body{
	background-image:url(img/bk_repeat1_1.jpg)
}
	</style>
</head>
<body>
<form id="form1" runat="server">
<%--        <div class="top">
            <div class="userinfo">
                <p class="wxnums">附近门店</p>
            </div>
            <div class="rightset"><i class="fa fa-edit"></i></div>
        </div>--%>
        <div class="wrap-page">
    <asp:Label ID="msg" runat="server" Text=""></asp:Label>
        <section class="page" id="storeinfo">
    <ul id="item-list" class="storeul">
		<%=html%>
    </ul>
    </section>
    </div>
    </form>
</body>
</html>
