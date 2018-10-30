<%@ WebHandler Language="C#" Class="sphhinfo" Debug="true" %>

using System;
using System.Web;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.Web.SessionState;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using nrWebClass;
using System.IO;
using System.Net;
using System.Drawing;
using System.Drawing.Imaging;
public class sphhinfo : IHttpHandler, IRequiresSessionState
{

    public void ProcessRequest(HttpContext context)
    {

        context.Response.ContentType = "text/plain"; //如果返回给客户端的是 json数据时， 设置ContentType="application/json"
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        string djh = context.Request.Form["djh"].ToString();

        HttpRequest request = context.Request;
        HttpResponse response = context.Response;

        HttpFileCollection files = request.Files; //客户端上传的文件
        if (files.Count > 0)
        {
            HttpPostedFile file = files.Get(0);

            string tail = ""; //文件名尾
            if (file.FileName.LastIndexOf('.') < 0)
            {
                tail = ".jpg";
            }
            else
            {
                tail = Path.GetExtension(file.FileName);
            }
            
            Stream stream = file.InputStream;
            byte[] bytes = null;
            Image img = RotateImage(stream);
            ImageConverter imgconv = new ImageConverter();
            bytes = (byte[])imgconv.ConvertTo(img, typeof(byte[]));

            HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create("http://webt.lilang.com:9001/service/cl_T_flbg_pic.ashx");
            //HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create("http://192.168.35.231/service/cl_T_flbg_pic.ashx");
            myRequest.Method = "POST";
            myRequest.Headers.Add("djh", djh);
            myRequest.Headers.Add("tail", tail);
            myRequest.Headers.Add("FileSize", bytes.Length + "");
            using (Stream newStream = myRequest.GetRequestStream())
            {
                // Send the data. 
                newStream.Write(bytes, 0, bytes.Length);
                newStream.Close();
            }


            // Get response 
            HttpWebResponse myResponse = (HttpWebResponse)myRequest.GetResponse();
            StreamReader sreader = new StreamReader(myResponse.GetResponseStream(), Encoding.GetEncoding("GB2312"));
            string content = sreader.ReadToEnd();


            response.Write(content);
            response.End();
        }
        else
        {
            response.Write("未选择文件");
            response.End();
        }
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
    /// <summary>
    /// 根据图片exif调整方向
    /// </summary>
    /// <param name="sm"></param>
    /// <returns></returns>
    public static Image RotateImage(Stream sm)
    {
        Image img = Image.FromStream(sm);
        PropertyItem[] exif = img.PropertyItems;
        byte orien = 0;
        foreach (PropertyItem i in exif)
        {
            if (i.Id == 274)
            {
                orien = i.Value[0];
                i.Value[0] = 1;
                img.SetPropertyItem(i);
            }
        }
       
        switch (orien)
        {
            case 2:
                img.RotateFlip(RotateFlipType.RotateNoneFlipX);//horizontal flip
                break;
            case 3:
                img.RotateFlip(RotateFlipType.Rotate180FlipNone);//right-top
                break;
            case 4:
                img.RotateFlip(RotateFlipType.RotateNoneFlipY);//vertical flip
                break;
            case 5:
                img.RotateFlip(RotateFlipType.Rotate90FlipX);
                break;
            case 6:
                img.RotateFlip(RotateFlipType.Rotate90FlipNone);//right-top
                break;
            case 7:
                img.RotateFlip(RotateFlipType.Rotate270FlipX);
                break;
            case 8:
                img.RotateFlip(RotateFlipType.Rotate270FlipNone);//left-bottom
                break;
            default:
                break;
        }
        foreach (PropertyItem i in exif)
        {
            if (i.Id == 40962)
            {
                i.Value = BitConverter.GetBytes(img.Width);
            }
            else if (i.Id == 40963)
            {
                i.Value = BitConverter.GetBytes(img.Height);
            }

        }
        return img;
    }
}



