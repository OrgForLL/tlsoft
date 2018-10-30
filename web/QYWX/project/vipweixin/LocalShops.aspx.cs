using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Data;
using System.Text;

public partial class LocalShops : System.Web.UI.Page
{
    public StringBuilder html = new StringBuilder();
    protected void Page_Load(object sender, EventArgs e)
    {
        //Request.QueryString["cid"]= 1;
        //if (Request.QueryString["cid"] != null)
        {
            string cid = "1";
            //DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
            string posturl = "https://api.weixin.qq.com/sns/oauth2/access_token?appid={0}&secret={1}&code={2}&grant_type=authorization_code";
            posturl = String.Format(posturl, common.appid, common.secret, Request.QueryString["code"].ToString());
            string content = common.HttpRequest(posturl);
            JsonSerializerSettings jSetting = new JsonSerializerSettings();
            jSetting.NullValueHandling = NullValueHandling.Ignore;
            WXAccessToken wx = JsonConvert.DeserializeObject<WXAccessToken>(content, jSetting);
            string sqlcomm = string.Format( @"select top 1 Lat,Lon from [wx_userPosition] 
    where wxOpenid = '{0}'
    order by CREATEtime desc", wx.Openid);
            string city = "";
            using (IDataReader reader = dbHelper.ExecuteReader(sqlcomm))
            {
                if (reader.Read())
                {
                    posturl = string.Format(common.baidumap, reader[0], reader[1]);
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
            };
            if (city != "")
            {
                city = city.Substring(0, city.Length - 1);
                html.AppendFormat("{0}附近专卖店",city);
                sqlcomm = string.Format(@" select t1.zmdmc,yjmstreet,yphone,t2.khid,c.Lat,C.Lng from (select id,khid,max(yjmstreet) yjmstreet,max(yphone) yphone,max(zmdmc) zmdmc
                                        ,CASE WHEN ISNULL(c.mapid,0)=0 then 'hidden' else 'visible' end  bs  from yx_t_jmspb where jmcity like '%{0}%' group by id,khid) as t1
                                        INNER JOIN yx_T_khb as t2 on t1.khid=t2.khid left join wx_t_storepointlocation c on t1.id=c.mapid and c.maptype='jm' ", city);
                using (IDataReader reader = dbHelper.ExecuteReader(sqlcomm))
                {
                    while (reader.Read())
                    {
                        html.AppendFormat(@"<li>{0} {1} {2} <span>
    <a href='LocalPromotion.aspx?shop={3}'>最新活动</a></span><span>
    <a href='LocalPromotion.aspx?Lat={4}&Lng={5}'><span style='visibility:{6}'>导航</a></span></li>",
                        reader[0], reader[1], reader[2], reader[3], reader[4], reader[5], reader[6]);
                    }
                }
            }
        }
    }
}