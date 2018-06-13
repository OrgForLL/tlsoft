using System;
using System.Web;
using System.Net;
using System.IO;
using System.Xml;
using Newtonsoft.Json;
using Structs;

namespace WebApplication1
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            
            // 请求对象
            ReportsListRequestStructBean RequestBean = new ReportsListRequestStructBean();

            // 请求头对象
            RequestHeadStc Head = new RequestHeadStc();

            // 请用户名
            Head.AppKey = "lilang";

            // 请求用户密码 
            Head.SecretKey = "123454" ;

            // 请求方法
            Head.Method = "GetReportsList";

            // 请求唯一标识 建议用UUID 双方排查日志用
            Head.AskSerialNo = Guid.NewGuid().ToString() ;

            // 请求时间
            Head.SendTime = System.DateTime.Now.ToString("yyyyMMddHHmmss" );

            // 请求体对象
            ReportsListInputStc Body = new ReportsListInputStc();
            Body.TrustDateFrom = "2017-05-01" ;
            Body.TrustDateTo = "2017-11-01" ;
            RequestBean.Head = Head ;
            RequestBean.Body = Body ;

            // 返回对象
            ReportsListResponseStructBean ResponseBean = new ReportsListResponseStructBean();


            // 请求功能URL
            string url = "http://data.cnttts.com:58080/dmz/v1/M0001";
            string postJson = JsonConvert.SerializeObject(RequestBean, Newtonsoft.Json.Formatting.None);

            // 请求后台
            string retmp = PostFunction(url, postJson);

            ResponseBean = JsonConvert.DeserializeObject<ReportsListResponseStructBean>(retmp);

        }

       
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
            Console.WriteLine(Result);
            return Result;

        }

    }
}