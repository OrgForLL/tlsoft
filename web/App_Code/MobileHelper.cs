using System;
using System.Web;

/// <summary>
/// 手机帮助代码类
/// </summary>
public class MobileHelper
{
    public static bool isMobileBrowser()
    {
        //GETS THE CURRENT USER CONTEXT
        HttpContext context = HttpContext.Current;

        //FIRST TRY BUILT IN ASP.NT CHECK
        if (context.Request.Browser.IsMobileDevice)
        {
            return true;
        }
        //THEN TRY CHECKING FOR THE HTTP_X_WAP_PROFILE HEADER
        if (context.Request.ServerVariables["HTTP_X_WAP_PROFILE"] != null)
        {
            return true;
        }
        //THEN TRY CHECKING THAT HTTP_ACCEPT EXISTS AND CONTAINS WAP
        if (context.Request.ServerVariables["HTTP_ACCEPT"] != null && context.Request.ServerVariables["HTTP_ACCEPT"].ToLower().Contains("wap"))
        {
            return true;
        }
        //AND FINALLY CHECK THE HTTP_USER_AGENT 
        //HEADER VARIABLE FOR ANY ONE OF THE FOLLOWING
        if (context.Request.ServerVariables["HTTP_USER_AGENT"] != null)
        {
            //Create a list of all mobile types
            string[] mobiles = new string[]{
                    "midp", "j2me", "avant", "docomo", 
                    "novarra", "palmos", "palmsource", 
                    "240x320", "opwv", "chtml",
                    "pda", "windows ce", "mmp/", 
                    "blackberry", "mib/", "symbian", 
                    "wireless", "nokia", "hand", "mobi",
                    "phone", "cdm", "up.b", "audio", 
                    "SIE-", "SEC-", "samsung", "HTC", 
                    "mot-", "mitsu", "sagem", "sony"
                    , "alcatel", "lg", "eric", "vx", 
                    "NEC", "philips", "mmm", "xx", 
                    "panasonic", "sharp", "wap", "sch",
                    "rover", "pocket", "benq", "java", 
                    "pt", "pg", "vox", "amoi", 
                    "bird", "compal", "kg", "voda",
                    "sany", "kdd", "dbt", "sendo", 
                    "sgh", "gradi", "jb", "dddi", 
                    "moto", "iphone"
            };

            //Loop through each item in the list created above 
            //and check if the header contains that text
            foreach (string s in mobiles)
            {
                if (context.Request.ServerVariables["HTTP_USER_AGENT"].ToLower().Contains(s.ToLower()))
                {
                    return true;
                }
            }
        }

        return false;
    }

    public static string GetMobileType()
    {
        //GETS THE CURRENT USER CONTEXT
        HttpContext context = HttpContext.Current;

        string vOs = "未知";
        //AND FINALLY CHECK THE HTTP_USER_AGENT 
        //HEADER VARIABLE FOR ANY ONE OF THE FOLLOWING
        if (context.Request.ServerVariables["HTTP_USER_AGENT"] != null)
        {
            //return context.Request.ServerVariables["HTTP_USER_AGENT"];
            string UserAgent = context.Request.ServerVariables["HTTP_USER_AGENT"];
           
            if (UserAgent.Contains("Windows CE"))
                vOs = "Windows CE";
            else if (UserAgent.Contains("iPhone"))
                vOs = "iPhone";
            else if (UserAgent.Contains("Android"))
                vOs = "Android";
            else if (UserAgent.Contains("BlackBerry"))
                vOs = "BlackBerry";
            else if ((UserAgent.Contains("Series60")) && (UserAgent.Contains("NOKIA")))
                vOs = "Nokia S60";
            else if (UserAgent.Contains("NOKIA"))
                vOs = "Nokia";
            else if ((UserAgent.Contains("SymbianOS")) || (UserAgent.Contains("Series")))
                vOs = "SymbianOS";
            else if (UserAgent.Contains("SonyEricsson"))
                vOs = "SonyEricsson";
            else if (UserAgent.Contains("LG"))
                vOs = "LG";
            else if ((UserAgent.Contains("MOT")) || (UserAgent.Contains("Motorola")))
                vOs = "MOTO";
            else if ((UserAgent.Contains("SEC")) || (UserAgent.Contains("SAMSUNG")))
                vOs = "三星";
        }
        return vOs;
    }
}