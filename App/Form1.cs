using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;
using System.Windows.Forms;
using System.Net;
using System.IO;
namespace App
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {

            par p = new par();
            p.partnerid = "16434";
            p.servicetype = "LLWebApi_CL_GetPick";            
            p.bizdata = "{\"BeginDate\":\"2018-10-15\",\"EndDate\":\"2018-10-30\"}";
            p.timestamp = string.Format("{0:yyyyMMddHHmmss}", DateTime.Now);
            p.nonce = System.Guid.NewGuid().ToString();

            p.sign = GetSign(p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce);
            //正式
            string url = @"http://webt.lilang.com/LLService/ApiRoute.ashx?action=llwebapi";
            //测试
            //string url = @"http://192.168.35.231/LLWebApi/ApiRoute.ASHX?action=llwebapi";
            string postJson = string.Format("partnerid={0}&servicetype={1}&bizdata={2}&timestamp={3}&nonce={4}&sign={5}", p.partnerid, p.servicetype, p.bizdata, p.timestamp, p.nonce, p.sign);
            string r = PostFunction(url, postJson);
        }
        public static string GetSign(string partnerid, string servicetype, string bizdata, string timestamp, string nonce)
        {
            string partnerKey = "7a6ee705-18cc-4614-b2bb-f8b6b0095e4e";
            List<String> lstParams = new List<string>();
            lstParams.Add("partnerid=" + partnerid);
            lstParams.Add("servicetype=" + servicetype);
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
        private void button2_Click(object sender, EventArgs e)
        {
            Form f = new GraphicsAPI();
            f.Show();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Form f = new ScoketServer();
            f.Show();
        }
    }
    public class par
    {
        public string partnerid;
        public string servicetype;
        public string bizdata;
        public string timestamp;
        public string nonce;
        public string sign;

    }
}
