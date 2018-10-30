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

<head id="Head1" runat="server">
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
                        else {
                            openid = "";

                        }

                        string cid = "1";
                        string cid1 = "4";
                        string lat = "", lng = "";
                        Double distance = 0.0;
                        DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
                        DAL.SqlDbHelper dbHelper1= new DAL.SqlDbHelper(cid1);
                        string posturl = "https://api.weixin.qq.com/sns/oauth2/access_token?appid={0}&secret={1}&grant_type=authorization_code";
                        posturl = String.Format(posturl, common1.appid, common1.secret);

                        string sqlcomm = string.Format(@"select top 1 Lat,Lon from [wx_userPosition] 
    where wxOpenid = '{0}'
    order by CREATEtime desc", openid);
                        string city = "";
                        using (IDataReader reader = dbHelper1.ExecuteReader(sqlcomm))
                        {
                            if (reader.Read())
                            {
                                posturl = string.Format(common1.baidumap, reader[0], reader[1]);
                                JObject jo = ((JObject)JsonConvert.DeserializeObject(common1.HttpRequest(posturl)));
                                string status = jo["status"].ToString();
                                if (status == "0")
                                {
                                    //正常返回
                                    city = jo["result"]["addressComponent"]["district"].ToString();
                                    lat = reader[0].ToString();
                                    lng = reader[1].ToString();
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
                        };
                        if (city != "")
                        {
                            city = city.Substring(0, city.Length - 1);
                            html.AppendFormat("{0}附近专卖店", city);
                            sqlcomm = string.Format(@" select t1.zmdmc,yjmstreet,yphone,t2.khid,c.addressinfo,c.Lat as zmdLat,C.Lng as zmdLng,CASE WHEN ISNULL(c.mapid,0)=0 then 'hidden' else 'visible' end  bs,t1.id from (
     select  id,khid,max(yjmstreet) yjmstreet,max(yphone) yphone,max(zmdmc) zmdmc
    from yx_t_jmspb where jmcity like '%{0}%' group by id,khid) as t1  
    left join wx_t_storepointlocation c on t1.id=c.mapid and c.maptype='jm'
    INNER JOIN yx_T_khb as t2 on t1.khid=t2.khid and t2.ty=0  ", city);

                            using (IDataReader reader = dbHelper.ExecuteReader(sqlcomm))
                            {
                                while (reader.Read())
                                {
                                    if (Convert.ToString(reader[5]) != "")
                                    {

                                        if (GetDistance.getDistance(Convert.ToDouble(lat), Convert.ToDouble(lng), Convert.ToDouble(reader[5]), Convert.ToDouble(reader[6])) <= 10000)
                                        {
                                            distance = Convert.ToDouble((GetDistance.getDistance(Convert.ToDouble(lat), Convert.ToDouble(lng), Convert.ToDouble(reader[5]), Convert.ToDouble(reader[6])) / 1000).ToString("0.00"));
                                            html.AppendFormat(@"<li><div class='cell'><div class='label'>店铺：</div><div class='labelval'>{0}</div> </div>
                                                     <div class='cell'><div class='label'>地址：</div><div class='labelval'>{1}</div> </div>     
                                                     <div class='cell'><div class='label'>联系电话：</div><div class='labelval'>{2}</div> </div>
                                                     <div class='btns floatfix'><input type='hidden' value='{3}' /><p>距离当前位置：</p>
                                                    <p style='visibility:{7}'><i class='fa fa-map-marker'></i><a href='map4.aspx?zmdLat={4}&zmdLng={5}&lat={9}&lng={10}&mapid={6} ' >{11}KM</a></p></div></li>",
                                        Convert.ToString(reader[0]), Convert.ToString(reader[4]), Convert.ToString(reader[2]), Convert.ToString(reader[3]), Convert.ToString(reader[5]), Convert.ToString(reader[6]), Convert.ToString(reader[8]), Convert.ToString(reader[7]), Convert.ToString(reader[4]), lat, lng, distance);

                                        }
                                    }
                                }
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
                public class common1
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
               
                }
               
                
            </script>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="css/font-awesome.min.css" />
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
