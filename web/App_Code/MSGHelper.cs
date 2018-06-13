using System;
using System.Web;
using LILANZDynomic;
using System.Collections.Generic;

/// <summary>
/// 短信发送帮助代码类
/// </summary>
public class MSGHelper
{
    private static string ServiceAddress
    {
        get
        {
            MyConfigHelper config = new MyConfigHelper();
            string address = config.GetValue("LILANZMSGService");
            if (address == "") address = "http://10.0.0.233:8012";
            return address;
        }
    }

    public static string MSGSend(string userssid, string userid, string username, string phone, string msg)
    {
        return MSGSend("", userssid, userid, username, phone, msg, "","0", "");
    }
    public static string MSGSend(string msgtype, string userssid, string userid, string username, string phone, string msg, string sendtime, string sysid, string mark)
    {
        WebRequestHelper h = new WebRequestHelper();
        IDictionary<string, string> dict = new Dictionary<string, string>();
        dict.Add("msgtype", msgtype);
        dict.Add("userssid", userssid);
        dict.Add("userid", userid);
        dict.Add("username", username);
        dict.Add("phone", phone);
        dict.Add("msg", msg);
        dict.Add("sendtime", sendtime);
        dict.Add("sysid", sysid);
        dict.Add("mark", mark);
        return h.DoPost(ServiceAddress, dict);
    }
}