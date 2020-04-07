<%@ WebHandler Language="C#" Class="XPS" %>

using System;
using System.Web;
using System.Diagnostics;

public class XPS : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string ex = "Hello World";
        try
        {
            xps2jpg(context.Request.QueryString["fN"].ToString());
        }catch(SystemException e)
        {
            ex = e.Message.ToString();
        }
        context.Response.Write(ex);
    }
    public void xps2jpg(string fileName)
    {
        const string sSrcFolder = @"\\192.168.35.6\商品技术研发部\裁床样板";
        string sMask = fileName+".oxps";
        const string sOutFolder = @"\\192.168.35.6\商品技术研发部\裁床样板\xps\Out";
        string converterPath = @"D:\Program Files (x86)\2JPEG\2jpeg.exe";
        string procArguments = "-src \"" + sSrcFolder + "\\" + sMask + "\" -dst \"" + sOutFolder + "\" -options alerts:no";
        Process process = new Process();
        process.StartInfo.UseShellExecute = true;
        process.StartInfo.CreateNoWindow = true;
        process.StartInfo.WindowStyle = ProcessWindowStyle.Normal;// ProcessWindowStyle.Hidden;
        process.StartInfo.FileName = converterPath;
        process.StartInfo.Arguments = procArguments;
        process.Start();
        process.WaitForExit();
        process.Close();
        process.Dispose();
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}