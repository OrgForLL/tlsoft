<%@ WebHandler Language="C#" Class="UpdateSize" %> 

using System;
using System.Web;
using System.IO;
public class UpdateSize : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        string dirPath = context.Server.MapPath("/AutoUpdater/");
        //context.Response.Write(dirPath);
        //context.Response.End();
        context.Response.ContentType = "text/xml";
        context.Response.Expires = -1;
        context.Response.Write("<?xml version=\"1.0\" encoding=\"utf-8\" ?>");
        context.Response.Write("<UpdateSize Size=\"" + GetUpdateSize(dirPath) + "\" />");
        context.Response.End();
    }

    
    /// <summary> 
    /// 获取所有下载文件大小 
    /// </summary> 
    /// <returns>返回值</returns> 
    private static long GetUpdateSize(string dirPath)
    {
        //判断文件夹是否存在，不存在则退出 
        if (!Directory.Exists(dirPath))
            return 0;
        long len;
        len = 0;
        DirectoryInfo di = new DirectoryInfo(dirPath);
        //获取所有文件大小 
        foreach (FileInfo fi in di.GetFiles())
        {
            //剔除升级数据文件 
            if (fi.Name != "AutoUpdater.xml")
                len += fi.Length;
        }
        return len;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
} 
