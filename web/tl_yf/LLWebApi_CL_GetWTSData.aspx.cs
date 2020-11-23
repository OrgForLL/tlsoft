using System;
using System.Collections.Generic;
using System.Web.Services;
using System.Data;
using Newtonsoft.Json;
using nrWebClass;
using LiLanzModel;

using System.Security.Cryptography;
using System.Text;
using System.Net;
using System.IO;

public class par {
    public string partnerid;
    public string servicetype;
    public string bizdata;
    public string timestamp;
    public string nonce;
    public string sign;

}
public partial class LLWebApi_CL_GetWTSData : System.Web.UI.Page
{

    public class par
    {
        public string partnerid;
        public string servicetype;
        public string bizdata;
        public string timestamp;
        public string nonce;
        public string sign;

    }
    public class par2
    {
        public string partnerid;
        public string servicetype;
        public string data;
        public string timestamp;
        public string nonce;
        public string sign;

    }
    protected void Page_Load2(object sender, EventArgs e)
    {
        par2 p = new par2();
        p.partnerid = "17855";
        p.servicetype = "LLWebApi_CL_GetSXB";
        //传参待定
        p.data = "{\"Type\":\"list\",\"gzlx\":\"2010\",\"startDate\":\"2020-05-15\",\"endDate\":\"2020-05-15\"}";   
        p.timestamp = string.Format("{0:yyyyMMddHHmmss}", DateTime.Now);
        p.nonce = System.Guid.NewGuid().ToString();

        p.sign = GetSign2(p.partnerid, p.servicetype, p.data, p.timestamp, p.nonce);
        //正式
        string url = @"http://webt.lilang.com/LLService/ApiRoute.ashx?action=llwebapi";
        //测试
        //string url = @"http://192.168.35.231/LLWebApi/ApiRoute.ASHX?action=llwebapi";
        string postJson = string.Format("partnerid={0}&servicetype={1}&data={2}&timestamp={3}&nonce={4}&sign={5}", p.partnerid, p.servicetype, p.data, p.timestamp, p.nonce, p.sign);

        string r = PostFunction(url, postJson);
        Response.Write(r);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        par p = new par();
        p.partnerid = "18871";
        p.servicetype = "LLWebApi_CL_GetWTSData";
        //传参待定
        p.bizdata = "{\"id\":\"204852\"}";        
        p.timestamp = string.Format("{0:yyyyMMddHHmmss}", DateTime.Now);
        p.nonce = System.Guid.NewGuid().ToString();

        p.sign = GetSign(p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce);
        //正式
        string url = @"http://webt.lilang.com/LLService/ApiRoute.ashx?action=llwebapi";
        //测试
        //string url = @"http://192.168.35.231/LLWebApi/ApiRoute.ASHX?action=llwebapi";
        string postJson = string.Format("partnerid={0}&servicetype={1}&bizdata={2}&timestamp={3}&nonce={4}&sign={5}", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce, p.sign);

        string r = PostFunction(url, postJson);
        Response.Write(r);
    }
    public static string GetSign2(string partnerid, string servicetype, string bizdata, string timestamp, string nonce)
    {
        string partnerKey = "e37f9842-e6a5-46f2-87c1-ed65aa01c90f";
        List<String> lstParams = new List<string>();
        lstParams.Add("partnerid=" + partnerid);
        lstParams.Add("servicetype=" + servicetype);
        lstParams.Add("data=" + bizdata);
        lstParams.Add("timestamp=" + timestamp);
        lstParams.Add("nonce=" + nonce);
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
    public static string GetSign(string partnerid,string servicetype,string bizdata,string timestamp,string nonce)
    {
        string partnerKey = "B28B37B6-4F50-4B9F-B983-745C005C0F32";
        List<String> lstParams = new List<string>();
        lstParams.Add("partnerid="+ partnerid);
        lstParams.Add("servicetype="+ servicetype);
        lstParams.Add("bizdata=" + bizdata);
        lstParams.Add("timestamp=" + timestamp);
        lstParams.Add("nonce=" + nonce);
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
        request.ContentType = "application/x-www-form-urlencoded";
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
   
}