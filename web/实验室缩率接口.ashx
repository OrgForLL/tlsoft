<%@ WebHandler Language="C#" Class="LLWebApi_CL_GetSXB" Debug="true" %>

using System;
using System.Web;
using System.Data;
using System.IO;
using System.Text;
using System.Data.SqlClient;
using System.Collections.Generic;

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.Net;
using System.Web.Services;
using System.Security.Cryptography;
public class Par
{
    public string partnerid;
    public string servicetype;
    public string bizdata;
    public string timestamp;
    public string nonce;
    public string sign;
    public string ddl;
}




public class LLWebApi_CL_GetSXB : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;
        Par p = new Par();
        p.partnerid = "20101";//利郎分配
        p.servicetype = "LLWebApi_Cooperativeoffice";
        //传参待定
        DataItem data1 = new DataItem();
        data1.cs = 11;
        data1.xh = 12;
        data1.bhl = 0.1;
        DataItem data2 = new DataItem();
        data2.cs = 12;
        data2.xh = 13;
        data2.bhl = 0.1;
        DataItem data3 = new DataItem();
        data3.cs = 12;
        data3.xh = 13;
        data3.bhl = 0.1;
        DataItem data4 = new DataItem();
        data4.cs = 11;
        data4.xh = 12;
        data4.bhl = 0.1;
        DataItem data5 = new DataItem();
        data5.cs = 12;
        data5.xh = 13;
        data5.bhl = 0.1;
        DataItem data6 = new DataItem();
        data6.cs = 12;
        data6.xh = 13;
        data6.bhl = 0.1;

        JwxObjItem jw1 = new JwxObjItem();
        jw1.lx = "经向";
        jw1.data.Add(data1);
        jw1.data.Add(data2);
        jw1.data.Add(data3);
        jw1.avg = 1.1;

        JwxObjItem jw2 = new JwxObjItem();
        jw2.lx = "纬向";
        jw2.data.Add(data4);
        jw2.data.Add(data5);
        jw2.data.Add(data6);
        jw2.avg = 2.2;

        CcdataItem cc1 = new CcdataItem();
        cc1.lx = "水洗";
        cc1.jwxObj.Add(jw1);
        cc1.jwxObj.Add(jw2);

        CcdataItem cc2 = new CcdataItem();
        cc2.lx = "汽烫";
        cc2.jwxObj.Add(jw1);
        cc2.jwxObj.Add(jw2);

        BgRes bg1 = new BgRes();
        bg1.bgbh = "LL-LAB-R111212001";
        bg1.bgid = 483091;
        bg1.ccdata.Add(cc1);
        bg1.ccdata.Add(cc2);

        BgRes bg2 = new BgRes();
        bg2.bgbh = "LL-LAB-R111212002";
        bg2.bgid = 483092;
        bg2.ccdata.Add(cc1);
        bg2.ccdata.Add(cc2);

        List<BgRes> bgList = new List<BgRes>();
        bgList.Add(bg1);
        bgList.Add(bg2);


        //p.bizdata = "{\"tzid\":\"1\",\"username\":\"zzz\",\"data\":[{\"chdm\":\"AT1901481\",\"tmlb\":\"1\",\"tmdw\":\"包\",\"sl\":\"11\",\"bz\":\"11\"},{\"chdm\":\"H18633120\",\"tmlb\":\"1\",\"tmdw\":\"包\",\"sl\":\"22\",\"bz\":\"12\"}]}";
        p.bizdata = JsonConvert.SerializeObject(bgList);
        p.timestamp = string.Format("{0:yyyyMMddHHmmss}", DateTime.Now);
        p.nonce = System.Guid.NewGuid().ToString();
        p.ddl = "ccbhl";
        p.sign = GetSign(p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce, p.ddl);

        string postJson = string.Format("partnerid={0}&servicetype={1}&bizdata={2}&timestamp={3}&sign={5}&nonce={4}&ddl={6}", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce, p.sign, p.ddl);
        //正式
        //string url = @"http://webt.lilang.com/LLService/ApiRoute.ashx?action=llwebapi";
        //string url = @"http://192.168.35.231/LLWebApi/ApiRoute.ashx?action=llwebapi";
            string url = @"http://192.168.35.96:8900/svr-cooperativeoffice/sizechange";
        string r = PostFunction(url, JsonConvert.SerializeObject(bgList));
        context.Response.Write(r);
        context.Response.End();
    }

    public static string GetSign(string partnerid, string servicetype, string bizdata, string timestamp, string nonce, string ddl)
    {
        string partnerKey = "86D16B55-7545-4D94-9753-2D765B92A2C3";//利郎分配
        List<String> lstParams = new List<string>();
        lstParams.Add("partnerid=" + partnerid);
        lstParams.Add("servicetype=" + servicetype);
        lstParams.Add("bizdata=" + bizdata);
        lstParams.Add("timestamp=" + timestamp);
        lstParams.Add("nonce=" + nonce);
        lstParams.Add("ddl=" + ddl);
        string[] strParams = lstParams.ToArray();
        Array.Sort(strParams);     //参数名ASCII码从小到大排序（字典序）； 
        string origin = string.Join("&", strParams);
        origin = string.Concat(origin, partnerKey);
        MD5 md5 = new MD5CryptoServiceProvider();
        byte[] targetData = md5.ComputeHash(System.Text.Encoding.UTF8.GetBytes(origin));
        StringBuilder sign = new StringBuilder("");
        foreach (byte b in targetData)
        {
            sign.AppendFormat("{0:x2}", b);
        }
        return sign.ToString();
    }
    /// <summary>
    /// 发送POST请求
    /// </summary>
    /// <param name="url"></param>
    /// <param name="postJson"></param>
    /// <returns></returns>
    public string PostFunction(string url, string postJson)
    {
        string Result = "";
        string serviceAddress = url;
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(serviceAddress);

        request.Method = "POST";
        request.ContentType = "application/json";
        string strContent = postJson;
        using (StreamWriter dataStream = new StreamWriter(request.GetRequestStream()))
        {
            dataStream.Write(strContent);
            dataStream.Close();
        }

        HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        string encoding = response.ContentEncoding;
        if (encoding == null || encoding.Length < 1)
        {
            encoding = "UTF-8"; //默认编码  
        }
        // Encoding.GetEncoding(encoding)
        StreamReader reader = new StreamReader(response.GetResponseStream());
        Result = reader.ReadToEnd();
        //Console.WriteLine(Result);
        return Result;

    }
    public class DataItem
    {
        /// <summary>
        /// 初始长度
        /// </summary>
        public double cs;
        /// <summary>
        /// 洗后长度
        /// </summary>
        public double xh;
        /// <summary>
        /// 变化率
        /// </summary>
        public double bhl;
    }

    public class JwxObjItem
    {
        /// <summary>
        /// 经向
        /// </summary>
        public string lx;
        /// <summary>
        /// 
        /// </summary>
        public List<DataItem> data=new List<DataItem>();
        /// <summary>
        /// 平均值
        /// </summary>
        public double avg;
    }

    public class CcdataItem
    {
        /// <summary>
        /// 汽烫
        /// </summary>
        public string lx;
        /// <summary>
        /// 
        /// </summary>
        public List<JwxObjItem> jwxObj = new List<JwxObjItem>();
    }

    public class BgRes
    {
        /// <summary>
        /// 报告编号1
        /// </summary>
        public string bgbh;
        /// <summary>
        /// 
        /// </summary>
        public int bgid;
        public List<CcdataItem> ccdata = new List<CcdataItem>();
    }

    public bool IsReusable
    {
        get { return true; }
    }


}
