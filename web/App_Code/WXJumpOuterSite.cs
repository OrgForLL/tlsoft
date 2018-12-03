using System;
using System.Collections.Generic;
using System.Text;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Net;
using System.IO;
using System;
using System.Web;
using System.Text;
using System.Net;
using System.IO;
using System.Net.Security;
/// <summary>
///
/// </summary>
public class WXJumpOuterSite
{
    /// <summary>
    /// 微信消息处理URL
    /// </summary> 
    public string url;	
    /// <summary>
    /// 
    /// </summary>
    /// <param name="url">微信消息处理URL</param>
    public WXJumpOuterSite(string url)
    {
        this.url = url;
    }    
    /// <summary>
    /// 发送请求
    /// </summary>
    /// <param name="request"></param>
    /// <returns></returns>
    public string Post(HttpRequest request)
    {
        
        try
        {            

            foreach (string key in request.QueryString.Keys)
            {
                url += "&" + key + "=" + request.QueryString[key];
            }       
            
            HttpWebResponse response = CreatePostHttpResponse(this.url, request.InputStream, null, request.UserAgent, request.ContentEncoding, null, request.ContentType);
            StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8);
            return (reader.ReadToEnd());

        }
        catch (Exception ex)
        {
            return (ex.Message);
        }
    }
    public static HttpWebResponse CreatePostHttpResponse(string url, Stream streamIn, int? timeout, string userAgent, Encoding requestEncoding, CookieCollection cookies, string contentType)
    {

        if (string.IsNullOrEmpty(url))
        {
            throw new ArgumentNullException("url");
        }
        if (requestEncoding == null)
        {
            throw new ArgumentNullException("requestEncoding");
        }
        HttpWebRequest request = null;
        //如果是发送HTTPS请求
        if (url.StartsWith("https", StringComparison.OrdinalIgnoreCase))
        {
            ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback(CheckValidationResult);
            request = WebRequest.Create(url) as HttpWebRequest;
            request.ProtocolVersion = HttpVersion.Version10;
        }
        else
        {
            request = WebRequest.Create(url) as HttpWebRequest;
        }
        request.Method = "POST";
        request.ContentType = contentType;
        request.UserAgent = userAgent;

        if (timeout.HasValue)
        {
            request.Timeout = timeout.Value;
        }
        if (cookies != null)
        {
            request.CookieContainer = new CookieContainer();
            request.CookieContainer.Add(cookies);
        }

        using (Stream s = request.GetRequestStream())
        {
            byte[] inStr = StreamToBytes(streamIn);
            s.Write(inStr, 0, inStr.Length);
        }

        return request.GetResponse() as HttpWebResponse;
    }

    /* - - - - - - - - - - - - - - - - - - - - - - - -  
 * Stream 和 byte[] 之间的转换 
 * - - - - - - - - - - - - - - - - - - - - - - - */
    /// <summary> 
    /// 将 Stream 转成 byte[] 
    /// </summary> 
    public static byte[] StreamToBytes(Stream stream)
    {
        byte[] bytes = new byte[stream.Length];
        stream.Read(bytes, 0, bytes.Length);

        // 设置当前流的位置为流的开始 
        stream.Seek(0, SeekOrigin.Begin);
        return bytes;
    }

    private static bool CheckValidationResult(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors)
    {
        return true; //总是接受
    }
}