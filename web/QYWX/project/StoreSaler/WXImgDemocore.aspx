<%@ Page Language="C#" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Web" %>
<!DOCTYPE html>
<script runat="server">
    public static string mainpath=HttpContext.Current.Server.MapPath("~/");
    protected void Page_Load(object sender, EventArgs e)
    {
        string mediaid = Convert.ToString(Request.Params["mediaid"]);
        mediaid = "dk4jdR-cDCl3QARoDkEhhilyEiRcN2KtLoSRWHimwFug2zreihQ_xhhaDMUvooF8";
        string saveUrl = ""; 
       // string downInfo = DownLoadMedia(true, mediaid, 1, ref saveUrl);
        saveUrl = "upload/ImageManage/201703/my/wx20170330144939746.jpg";
        string[] s = saveUrl.Split('/');
        saveUrl = s[s.Length - 1];
        
        Response.Write("name:" + saveUrl+"<br/>");
        Response.Write("pa:" + saveUrl + "<br/>");
    }
    
    private const int imgWidth = 500;
    private static object objDownLoad = new object();

    /// <summary>
    /// 从微信服务器下载图片
    /// </summary>
    /// <param name="px"></param>
    /// <returns></returns>
    public static string DownLoadImage(string imageUrl, ref string saveImageURL)
    {
        
        string strInfo = "";
        lock (objDownLoad)
        {
            string DirImage = string.Concat(mainpath, "upload\\ImageManage\\", DateTime.Now.ToString("yyyyMM"));
            string myDirImage = string.Concat(DirImage, "\\my");

            if (!Directory.Exists(DirImage))
                Directory.CreateDirectory(DirImage);

            if (!Directory.Exists(myDirImage))
                Directory.CreateDirectory(myDirImage);
                
            string filename0 = string.Concat("wx", DateTime.Now.ToString("yyyyMMddHHmmss"), DateTime.Now.Millisecond + ".jpg");       //相对路径
            string filename = string.Concat(DirImage, "\\", filename0);
            string myfilename = string.Concat(myDirImage, "\\", filename0);
           
            saveImageURL = string.Concat("upload/ImageManage/", DateTime.Now.ToString("yyyyMM"), "/my/", filename0);
            strInfo = DownloadFile(imageUrl, filename);
            if (strInfo.StartsWith(clsSharedHelper.Error_Output) == false)
            {
                strInfo = MakeImage(filename, myfilename, imgWidth);
            }

            if (strInfo.StartsWith(clsSharedHelper.Error_Output))
            {
                clsLocalLoger.WriteError("图片推送不成功！错误：" + strInfo);
            }
        }
        return strInfo;
    }

    /// <summary>
    /// 从微信服务器下载音频
    /// </summary>
    /// <param name="px"></param>
    /// <returns></returns>
    public static string DownLoadVoice(string mediaUrl, ref string saveURL)
    {
        string strInfo = "";
        lock (objDownLoad)
        {
            string DirMedia = string.Concat(mainpath, "upload\\ImageManage\\", DateTime.Now.ToString("yyyyMM"), "\\Voice");

            if (!Directory.Exists(DirMedia))
                Directory.CreateDirectory(DirMedia);

            string filename0 = string.Concat("Voice", DateTime.Now.ToString("yyyyMMddHHmmss"), DateTime.Now.Millisecond, ".amr");       //相对路径
            string filename = string.Concat(DirMedia, "\\", filename0);

            saveURL = string.Concat("upload/ImageManage/", DateTime.Now.ToString("yyyyMM"), "/Voice/", filename0);
            strInfo = DownloadFile(mediaUrl, filename);
            if (strInfo.StartsWith(clsSharedHelper.Error_Output))
            {
                clsLocalLoger.WriteError("语音推送不成功！错误：" + strInfo);
            }
        }

        return strInfo;
    }
    /// <summary>
    /// 处理图片成指定尺寸()正方形 方便后期的直接使用；
    /// By:xlm 由于处理成正方形可能导致图片呈现效果不理想，因此缩放即可，但是不填充成正方形。
    /// </summary>
    /// <param name="SourceImage"></param>
    /// <param name="SaveImage"></param>
    /// <returns></returns>
    public static string MakeImage(string SourceImage, string SaveImage, int setWidth)
    {
        int imgWidth = setWidth; //缩放以宽度为基准
        try
        {
            System.Drawing.Bitmap myBitMap = new System.Drawing.Bitmap(SourceImage);
            int pWidth = myBitMap.Width;
            int pHeight = myBitMap.Height;
            int draX = 0;
            int draY = 0;

            double pcent = pWidth * 1.0 / imgWidth; //得到缩放比分比
            int imgHeight = Convert.ToInt32(Math.Round(pHeight * 1.0 / pcent));

            System.Drawing.Bitmap eImage = new System.Drawing.Bitmap(imgWidth, imgHeight);
            System.Drawing.Graphics g = System.Drawing.Graphics.FromImage(eImage);
            g.DrawImage(myBitMap, draX, draY, imgWidth, imgHeight);

            g.Save();

            myBitMap.Dispose();

            eImage.Save(SaveImage, System.Drawing.Imaging.ImageFormat.Jpeg);
            g.Dispose();

            return "";
        }
        catch (Exception ex)
        {
            return string.Concat(clsSharedHelper.Error_Output, "处理图片失败！错误：" + ex.Message);
        }
    }


    /// <summary>
    /// 下载图片
    /// </summary>
    /// <param name="URL">目标URL</param>
    /// <param name="filename">本地的路径</param>
    /// <returns></returns>
    public static string DownloadFile(string URL, string filename)
    {
        try
        {
            System.Net.HttpWebRequest Myrq = (System.Net.HttpWebRequest)System.Net.HttpWebRequest.Create(URL);
            using (System.Net.HttpWebResponse myrp = (System.Net.HttpWebResponse)Myrq.GetResponse())
            {
                long totalBytes = myrp.ContentLength;
                using (System.IO.Stream st = myrp.GetResponseStream())
                {
                    using (System.IO.Stream so = new System.IO.FileStream(filename, System.IO.FileMode.Create))
                    {
                        long totalDownloadedByte = 0;
                        byte[] by = new byte[1024];
                        int osize = st.Read(by, 0, (int)by.Length);
                        while (osize > 0)
                        {
                            totalDownloadedByte = osize + totalDownloadedByte;
                            so.Write(by, 0, osize);
                            osize = st.Read(by, 0, (int)by.Length);
                        }
                        so.Close();
                        st.Close();
                        myrp.Close();
                        
                        so.Dispose();
                        st.Dispose();
                    }
                }
            }

            return "";
        }
        catch (Exception ex)
        {
            return string.Concat(clsSharedHelper.Error_Output, ex.Message);
        }
    }


    /// <summary>
    /// 从微信服务器下载媒体
    /// </summary>
    /// <param name="IsSalerMedia">是否为销售人员发送的媒体(企业端媒体)</param>
    /// <param name="MediaID">媒体ID</param>
    /// <param name="MediaType">下载的媒体类型。1图片 2音频</param>
    /// <param name="saveURL">最终被保存的URL</param>
    /// <returns></returns>
    public static string DownLoadMedia(bool IsSalerMedia, string MediaID, int MediaType, ref string saveURL)
    {
        string url;
        string access_token;
        if (IsSalerMedia)
        {
            url = "https://qyapi.weixin.qq.com/cgi-bin/media/get?access_token={0}&media_id={1}";
            access_token = clsWXHelper.GetAT("1");
        }
        else
        {
            //url = "https://api.weixin.qq.com/cgi-bin/media/get?access_token={0}&media_id={1}";
            url = "http://file.api.weixin.qq.com/cgi-bin/media/get?access_token={0}&media_id={1}";      //旧的媒体下载接口
            access_token = clsWXHelper.GetAT(clsConfig.GetConfigValue("VIPConfigKey"));
        }

        url = string.Format(url, access_token, MediaID);
        clsLocalLoger.WriteDebug(string.Concat("下载媒体链接url=", url));
        if (MediaType == 1) return DownLoadImage(url, ref saveURL);
        else if (MediaType == 2) return DownLoadVoice(url, ref saveURL);
        return "";
    }



    /// <summary>
    /// 上传媒体到服务器
    /// </summary>
    /// <param name="IsUploadToSaler">是否上传给销售人员(上传成为企业端的媒体)</param>
    /// <param name="MediaType">媒体文件类型，分别有图片（image）、语音（voice）、视频（video）和缩略图（thumb）</param>
    /// <param name="MediaFile">媒体文件的服务器本地存储路径</param>
    /// <returns></returns>
    public static string UpLoadMedia(bool IsUploadToSaler, string MediaType, string MediaFile)
    {
        string url;
        string access_token;
        if (IsUploadToSaler)
        {
            url = "https://qyapi.weixin.qq.com/cgi-bin/media/upload?access_token={0}&type={1}";
            access_token = clsWXHelper.GetAT("1");
        }
        else
        {
            //url = "https://api.weixin.qq.com/cgi-bin/media/upload?access_token={0}&type={1}";
            url = "http://file.api.weixin.qq.com/cgi-bin/media/upload?access_token={0}&type={1}";       //旧的媒体上传接口
            access_token = clsWXHelper.GetAT(clsConfig.GetConfigValue("VIPConfigKey"));
        }

        MediaFile = string.Concat(mainpath, MediaFile.Replace("/", "\\"));


        url = string.Format(url, access_token, MediaType);

        clsLocalLoger.WriteDebug("MediaFile=" + MediaFile);
        clsLocalLoger.WriteDebug("url=" + url);

        string content = HttpUploadFileToWx(url, MediaFile);

        if (content.StartsWith(clsSharedHelper.Error_Output))
        {
            return "";
        }
        else
        {
            clsLocalLoger.WriteDebug("媒体上传结果。" + content);
            using (clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(content))
            {
                return jh.GetJsonValue("media_id");
            }
        }
    }

    /// <summary>
    /// 上传一个文件
    /// </summary>
    /// <param name="url">接口URL</param>
    /// <param name="path">图片的服务器本地路径</param>
    /// <returns></returns>
    public static string HttpUploadFileToWx(string url, string path)
    {
        try
        {
            // 设置参数
            HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest;
            CookieContainer cookieContainer = new CookieContainer();
            request.CookieContainer = cookieContainer;
            request.AllowAutoRedirect = true;
            request.Method = "POST";
            string boundary = DateTime.Now.Ticks.ToString("X"); // 随机分隔线
            request.ContentType = "multipart/form-data;charset=utf-8;boundary=" + boundary;
            byte[] itemBoundaryBytes = Encoding.UTF8.GetBytes("\r\n--" + boundary + "\r\n");
            byte[] endBoundaryBytes = Encoding.UTF8.GetBytes("\r\n--" + boundary + "--\r\n");

            int pos = path.LastIndexOf("\\");
            string fileName = path.Substring(pos + 1);

            //请求头部信息 
            StringBuilder sbHeader = new StringBuilder(string.Format("Content-Disposition:form-data;name=\"{0}\";filename=\"{1}\"\r\nContent-Type:application/octet-stream\r\n\r\n", "media", fileName));
            byte[] postHeaderBytes = Encoding.UTF8.GetBytes(sbHeader.ToString());

            FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read);
            byte[] bArr = new byte[fs.Length];
            fs.Read(bArr, 0, bArr.Length);
            fs.Close();

            Stream postStream = request.GetRequestStream();
            postStream.Write(itemBoundaryBytes, 0, itemBoundaryBytes.Length);
            postStream.Write(postHeaderBytes, 0, postHeaderBytes.Length);
            postStream.Write(bArr, 0, bArr.Length);
            postStream.Write(endBoundaryBytes, 0, endBoundaryBytes.Length);
            postStream.Close();

            //发送请求并获取相应回应数据
            HttpWebResponse response = request.GetResponse() as HttpWebResponse;
            //直到request.GetResponse()程序才开始向目标网页发送Post请求
            Stream instream = response.GetResponseStream();
            StreamReader sr = new StreamReader(instream, Encoding.UTF8);
            //返回结果网页（html）代码
            string content = sr.ReadToEnd();
            return content;
        }
        catch (Exception ex)
        {
            clsLocalLoger.WriteError(string.Concat("媒体上传失败！错误：", ex.Message));
            return string.Concat(clsSharedHelper.Error_Output, ex.Message);
        }
    }

</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
</body>
</html>
