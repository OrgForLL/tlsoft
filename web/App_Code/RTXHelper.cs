using System;

/// <summary>
/// RTXHelper 的摘要说明
/// </summary>
public class RTXHelper
{
    private static string rtxURL = "{0}/sendnotify.cgi?receiver={1}&title={2}&msg={3}&delaytime={4}";

    private static string ServiceAddress
    {
        get
        {
            MyConfigHelper config = new MyConfigHelper();
            string address = config.GetValue("RTXService");
            if (address == "") address = "http://10.0.0.233:8012";
            return address;
        }
    }

    public static bool SendRTXMSG(string receiver, string title, string msg)
    {
        return SendRTXMSG(receiver, title, msg, "");
    }
    public static bool SendRTXMSG(string receiver, string title, string msg, string delaytime)
    {
        string url = string.Format(rtxURL, new object[] { ServiceAddress, receiver, title, msg, delaytime });
        System.Net.WebRequest rtx_SERVER = System.Net.WebRequest.Create(url);
        try
        {
            rtx_SERVER.Timeout = 500;
            System.Net.WebResponse wr = rtx_SERVER.GetResponse();
            return true;
        }
        catch
        {
            return false;
        }
        finally
        {
        }
    }
}
