 <%@ WebHandler Language="C#" Class="wxCard" %>

using System;
using System.Web;
using nrWebClass;
using Newtonsoft.Json;
using System.Reflection;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using Class_TLtools;
using Newtonsoft.Json.Linq;
using System.IO;
using System.Net;
using System.Text;

public class wxCard : IHttpHandler
{
    int errcode = 0;
    public string activateUrl = "https://api.weixin.qq.com/card/membercard/activate?access_token=";
    public string getInfoUrl = "https://api.weixin.qq.com/card/membercard/activatetempinfo/get?access_token=";
    public string decryptUrl = "https://api.weixin.qq.com/card/code/decrypt?access_token=";
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentEncoding = System.Text.Encoding.UTF8;
        context.Request.ContentEncoding = System.Text.Encoding.UTF8;

        string action = Convert.ToString(context.Request.Params["act"]); 
        string token = clsWXHelper.GetAT("5");
        //MethodInfo method = this.GetType().GetMethod(action);
        //string SQLConnect = clsWXHelper.GetWxConn();

        //using(LiLanzDALForXLM dal = new LiLanzDALForXLM(SQLConnect))
        //{
        //  DataTable dt = null;
        //  string sqlStr = "select AccessToken from wx_t_TokenConfigInfo where ConfigKey=5";
        //  strInfo = dal.ExecuteQuery(sqlStr, out dt);

        //  if (strInfo != "")
        //  {
        //    clsSharedHelper.WriteErrorInfo(string.Concat("获取微信token失败！错误：", strInfo));
        //    return;
        //  }
        //  if (dt.Rows.Count == 0)
        //  {
        //    clsSharedHelper.WriteErrorInfo("未获取到微信token！");
        //    return;
        //  }
        //  token = (string)dt.Rows[0]["AccessToken"];
        //} 

        if (action == null)
            clsSharedHelper.WriteErrorInfo("缺少参数act");
        else if (action == "getInfo")
        {
            string res = "";
            string url = string.Concat(getInfoUrl, token);
            string ticket = context.Request.Form["activate_ticket"];

            string json = "{\"activate_ticket\": \"" + ticket + "\"}";

            res = PostMoths(url, json);
            clsSharedHelper.WriteInfo(res);
        }
        else if (action == "activate")
        {
            StringBuilder json = new StringBuilder();
            string url = string.Concat(activateUrl, token);
            string res = "";
            string[] postkeys = context.Request.Form.AllKeys;
            json.AppendFormat("{{");
            foreach(string key in postkeys)
            {
                if (!url.Contains(string.Concat("&", key, "=")))
                {
                    json.AppendFormat("\"{0}\": \"{1}\",", key, HttpUtility.UrlDecode(context.Request.Form[key], System.Text.Encoding.UTF8));
                }
            }
            json.Length = json.Length - 1;
            json.AppendFormat("}}");
            // clsSharedHelper.WriteInfo(json.ToString());
            res = PostMoths(url, json.ToString());
            json.Length = 0;
            clsSharedHelper.WriteInfo(res);
        }
        else if (action == "decrypt")
        {
            string res = "";
            string url = string.Concat(decryptUrl, token);
            string code = context.Request.Form["code"];

            string json = "{\"encrypt_code\": \"" + code + "\"}";

            res = PostMoths(url, json);
            clsSharedHelper.WriteInfo(res);
        }
    }

    public static string PostMoths(string url, string param)
    {
        string strURL = url;
        System.Net.HttpWebRequest request;
        request = (System.Net.HttpWebRequest)WebRequest.Create(strURL);
        request.Method = "POST";
        request.ContentType = "application/json;charset=UTF-8";
        string paraUrlCoded = param;
        byte[] payload;
        payload = System.Text.Encoding.UTF8.GetBytes(paraUrlCoded);
        request.ContentLength = payload.Length;
        Stream writer = request.GetRequestStream();
        writer.Write(payload, 0, payload.Length);
        writer.Close();
        System.Net.HttpWebResponse response;
        response = (System.Net.HttpWebResponse)request.GetResponse();
        System.IO.Stream s;
        s = response.GetResponseStream();
        string StrDate = "";
        string strValue = "";
        StreamReader Reader = new StreamReader(s, Encoding.UTF8);
        while ((StrDate = Reader.ReadLine()) != null)
        {
            strValue += StrDate + "\r\n";
        }
        return strValue;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}
