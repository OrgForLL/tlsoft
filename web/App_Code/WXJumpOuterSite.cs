using System;
using System.Web;
using System.Text;
using MyTy;
using System.Net;
using System.IO;
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
            
            HttpWebResponse response = MyTy.HttpWebResponseUtility.CreatePostHttpResponse(this.url, request.InputStream, null, request.UserAgent, request.ContentEncoding, null, request.ContentType);
            StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8);
            return (reader.ReadToEnd());

        }
        catch (Exception ex)
        {
            return (ex.Message);
        }
    }
}