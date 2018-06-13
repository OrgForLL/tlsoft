using System;
using System.Collections.Generic;
using System.Web;

/// <summary>
///WebGlobal 的摘要说明
/// </summary>
public class WebGlobal : TLWebStar.TLGlobals
{
    void Application_Error(object sender, EventArgs e)  
    {
        //在出现未处理的错误时运行的代码
        HttpServerUtility server = (sender as HttpApplication).Server;
        Exception baseException = Server.GetLastError().GetBaseException();
        Exception innerException = Server.GetLastError().InnerException;
        string stackTrace = Server.GetLastError().StackTrace;
        string source = Server.GetLastError().Source;
        string user = Request.LogonUserIdentity.ToString();
        //针对这个异常的处理
        //Response.Write("数据库连接不上");
        //server.ClearError();
        string Message = Convert.ToString(baseException.Message) +  Convert.ToString(innerException);
        //Exception ex = Server.GetLastError().InnerException;
        //Message = "發生錯誤的網頁:{0}錯誤訊息:{1}堆疊內容:{2}";
        /*
        Message = String.Format(Message, Request.Path + Environment.NewLine,
            ex.GetBaseException().Message + Environment.NewLine, 
            Environment.NewLine + ex.StackTrace);
        */
        //Convert.ToString(ex.Message)+Convert.ToString(innerException)
        //寫入事件撿視器,方法一  
        //System.Diagnostics.EventLog.WriteEntry("WebAppError", Message, System.Diagnostics.EventLogEntryType.Error);
        //寫入文字檔,方法二  
         System.IO.File.AppendAllText(Server.MapPath(string.Format("Logs\\{0}.txt", DateTime.Now.Ticks.ToString())), Message);
        //寄出Email,方法三  
        //此方法請參考System.Net.Mail.MailMessage  
        //清除Error  
        //Server.ClearError();
        //Server.Transfer("/Error.aspx");
        //Response.Write("系統錯誤,請聯絡系統管理員!!"); 
        
    }
}