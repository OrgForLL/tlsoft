<%@ WebHandler Language="C#" Class="mTagPick" %>
using System.Web;
using System.Collections.Generic;
using System;
using System.Security.Cryptography;
using System.Text;
public class mTagPick : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {

        context.Response.ContentType = "text/plain";
        GetSign();
        context.Response.Write("");
    }

    public static string GetSign()
    {
        string partnerid = "18134";
        string partnerKey = "06156B03-194B-4266-A459-0A1AF03330DA";
        List<String> lstParams = new List<string>();
        lstParams.Add("partnerid="+partnerid);
        lstParams.Add("servicetype=LLWebApi_CL_GetScDdData");
        lstParams.Add("bizdata={\"BeginDate\":\"2017-10-15\",\"EndDate\":\"2017-10-30\"}");
        lstParams.Add("timestamp=" + string.Format("{0:yyyyMMddHHmmss}", DateTime.Now));
        lstParams.Add("nonce=" + System.Guid.NewGuid().ToString());
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




    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}
 