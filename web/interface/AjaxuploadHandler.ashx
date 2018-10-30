<%@ WebHandler Language="C#" Class="GenericHandler1" %>

using System;
using System.Web;
using System.IO;
using System.Drawing;

public class GenericHandler1 : IHttpHandler {

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/html";
        
        HttpPostedFile postedFile = context.Request.Files[0];
        string savePath = "/upload/images/" + DateTime.Now.ToString("yyyyMMdd") + "/";
        int filelength = postedFile.ContentLength;
        int fileSize = 2097152; //2M 单位B
        string fileName = "-1"; //返回的上传后的文件名
        if (filelength <= fileSize)
        {
            byte[] buffer = new byte[filelength];
            postedFile.InputStream.Read(buffer, 0, filelength);
            fileName = UploadImage(buffer, savePath, "jpg");
        }

        context.Response.Write("succeed|" + fileName);
    }

    public static string UploadImage(byte[] imgBuffer, string uploadpath, string ext)
    {
        try
        {
            System.IO.MemoryStream m = new MemoryStream(imgBuffer);

            if (!Directory.Exists(HttpContext.Current.Server.MapPath(uploadpath)))
                Directory.CreateDirectory(HttpContext.Current.Server.MapPath(uploadpath));

            string imgname = CreateIDCode() + "." + ext;
            string _path = HttpContext.Current.Server.MapPath(uploadpath) + imgname;

            Image img = Image.FromStream(m);
            img.Save(_path, System.Drawing.Imaging.ImageFormat.Jpeg);
            
            m.Close();

            return uploadpath + imgname;
        }
        catch (Exception ex)
        {
            return ex.Message;
        }

    }

    public static string CreateIDCode()
    {
        DateTime Time1 = DateTime.Now.ToUniversalTime();
        DateTime Time2 = Convert.ToDateTime("1970-01-01");
        TimeSpan span = Time1 - Time2;   //span就是两个日期之间的差额   
        string t = span.TotalMilliseconds.ToString("0");

        return t;
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}