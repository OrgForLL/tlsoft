<%@ Page Language="C#" Debug="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Net" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {

        NameValueCollection formData = new NameValueCollection();
        string action = Convert.ToString(Request.Params["action"]);
        string wenti = Request.Form["wenti"];  //普通参数获取
        string userid = Request.Form["userid"];
        string id = Request.Form["id"];

        HttpPostedFile img = Request.Files["file"];

  
        int FileLen = img.ContentLength;
        Byte[] FileData = new Byte[FileLen];
        Stream sr = img.InputStream;//创建数据流对象 
        sr.Read(FileData, 0, FileLen);
        sr.Close();


        byte[] bytes = new byte[img.ContentLength];
        using (BinaryReader reader = new BinaryReader(img.InputStream, Encoding.UTF8))
        {
            bytes = reader.ReadBytes(0);
        }

        PostFunction("http://localhost:9301/CommoditySearch","abc",FileData);      




        Response.Write("{\"action\":\"" + action + "\", \"id\":\"" + id + "\",\"question\":\"" + wenti + "\",\"userid\":\"" + userid + "\",\"rtvalue\":\"\"}");
        Response.End();

    }

    //public byte[] POST(string Url, byte[] byteRequest)
    //{
    //    byte[] responsebody;
    //    HttpWebRequest httpWebRequest = null;
    //    HttpWebResponse httpWebResponse = null;
    //    try
    //    {

    //        httpWebRequest = (HttpWebRequest)HttpWebRequest.Create(Url);//创建连接请求

    //        httpWebRequest.Method = "POST";


    //        httpWebRequest.ContentType = ContentType;
    //        httpWebRequest.Accept = Accept;
    //        httpWebRequest.UserAgent = UserAgent;
    //        if (!string.IsNullOrEmpty(uuid))
    //        {
    //            httpWebRequest.Headers.Add("seed:" + uuid + "");
    //        }

    //        //Post请求数据，则写入传的PostData
    //        //byte[] byteRequest = Encoding.Default.GetBytes(PostData);
    //        httpWebRequest.ContentLength = byteRequest.Length;
    //        using (Stream stream = httpWebRequest.GetRequestStream())
    //        {
    //            stream.Write(byteRequest, 0, byteRequest.Length);
    //        }
    //        httpWebResponse = (HttpWebResponse)httpWebRequest.GetResponse();//开始获取响应流
    //        Stream responseStream = httpWebResponse.GetResponseStream();
    //        responsebody = StreamToBytes(responseStream);
    //        responseStream.Close();
    //        httpWebRequest.Abort();
    //        cookieContainer.Add(httpWebResponse.Cookies);
    //        cookieCollection.Add(httpWebResponse.Cookies);
    //        httpWebResponse.Close();
    //        //到这里为止，所有的对象都要释放掉，以免内存像滚雪球一样
    //    }
    //    catch (Exception ex)
    //    {
    //        responsebody = Encoding.Default.GetBytes(ex.Message + ex.Source);
    //        LogHelper.Log.Error("POST方式请求网页异常", ex);
    //    }
    //    return responsebody;
    //}

    public string PostFunction(string url, string postJson,byte[] byteRequest)
    {
        string Result = "";
        string serviceAddress = url;
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(serviceAddress);

        request.Method = "POST";
        request.ContentType = "application/json";
        string strContent = postJson;
        using (Stream dataStream  = request.GetRequestStream())
        {   
            dataStream.Write(byteRequest, 0, byteRequest.Length);
            //dataStream.Close();
        }
        HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        string encoding = response.ContentEncoding;
        if (encoding == null || encoding.Length < 1)
        {
            encoding = "UTF-8"; //默认编码  
        }
        // Encoding.GetEncoding(encoding)
        StreamReader reader = new StreamReader(response.GetResponseStream());
        Result = reader.ReadToEnd();
        Console.WriteLine(Result);
        return Result;

    }

    private Stream GetPostStream(NameValueCollection formData, string boundary, HttpPostedFile img)
    {
        Stream postDataStream = new System.IO.MemoryStream();

        string formDataHeaderTemplate = Environment.NewLine + "--" + boundary + Environment.NewLine +
        "Content-Disposition: form-data; name=\"{0}\";" + Environment.NewLine + Environment.NewLine + "{1}";

        foreach (string key in formData.Keys)
        {
            byte[] formItemBytes = System.Text.Encoding.UTF8.GetBytes(string.Format(formDataHeaderTemplate,
            key, formData[key]));
            postDataStream.Write(formItemBytes, 0, formItemBytes.Length);
        }

        string fileHeaderTemplate = Environment.NewLine + "--" + boundary + Environment.NewLine +
        "Content-Disposition: form-data; name=\"{0}\"; filename=\"{1}\"" +
        Environment.NewLine + "Content-Type: application/vnd.ms-excel" + Environment.NewLine + Environment.NewLine;

        byte[] bytes;
        using (BinaryReader reader = new BinaryReader(img.InputStream, Encoding.UTF8))
        {
            bytes = reader.ReadBytes(0);
        }
        byte[] fileHeaderBytes = bytes;

        postDataStream.Write(fileHeaderBytes, 0, fileHeaderBytes.Length);


        byte[] buffer = new byte[1024];

        int bytesRead = 0;

        while ((bytesRead = img.InputStream.Read(buffer, 0, buffer.Length)) != 0)
        {
            postDataStream.Write(buffer, 0, bytesRead);
        }
        img.InputStream.Close();

        byte[] endBoundaryBytes = System.Text.Encoding.UTF8.GetBytes("--" + boundary + "--");
        postDataStream.Write(endBoundaryBytes, 0, endBoundaryBytes.Length);

        return postDataStream;
    }
    // <summary>
    /// 
    /// </summary>
    /// <param name="url">目标url</param>
    /// <param name="strPost">要发送的post字符串</param>
    /// <returns>接收后返回值</returns>
    private string PostXML(string url, string strPost)
    {
        string result = string.Empty;
        //生成文件流
        byte[] buffer = Encoding.UTF8.GetBytes(strPost);
        //向流中写字符串
        StreamWriter mywriter = null;
        //根据url创建请求对象
        HttpWebRequest objrequest = (HttpWebRequest)WebRequest.Create(url);
        //设置发送方式
        objrequest.Method = "POST";
        //提交长度
        objrequest.ContentLength = buffer.Length;
        //发送内容格式
        objrequest.ContentType = "multipart/form-data; boundary=AaB03x";
        try
        {
            mywriter = new StreamWriter(objrequest.GetRequestStream());
            mywriter.Write(strPost);
        }
        catch (Exception)
        {
            result = "发送文件流失败！";

        }
        finally
        {
            mywriter.Close();
        }
        //读取服务器返回信息
        HttpWebResponse objresponse = (HttpWebResponse)objrequest.GetResponse();
        using (StreamReader sr = new StreamReader(objresponse.GetResponseStream()))
        {
            result = sr.ReadToEnd();
            sr.Close();
        }
        return result;
    }
    public class FtpHelper
    {
        string ftpServerIP;
        string ftpRemotePath;
        string ftpUserID;
        string ftpPassword;
        string ftpURI;

        /// <summary>
        /// 连接FTP
        /// </summary>
        /// <param name="FtpServerIP">FTP连接地址</param>
        /// <param name="FtpRemotePath">指定FTP连接成功后的当前目录, 如果不指定即默认为根目录</param>
        /// <param name="FtpUserID">用户名</param>
        /// <param name="FtpPassword">密码</param>
        public FtpHelper(string FtpServerIP, string FtpRemotePath, string FtpUserID, string FtpPassword)
        {
            ftpServerIP = FtpServerIP;
            ftpRemotePath = FtpRemotePath;
            ftpUserID = FtpUserID;
            ftpPassword = FtpPassword;
            ftpURI = "ftp://" + ftpServerIP + "/" + ftpRemotePath + "/";
        }

        /// <summary>
        /// 上传
        /// </summary>
        /// <param name="filename"></param>
        public void Upload(string filename)
        {
            FileInfo fileInf = new FileInfo(filename);
            string uri = ftpURI + fileInf.Name;
            FtpWebRequest reqFTP;

            reqFTP = (FtpWebRequest)FtpWebRequest.Create(new Uri(uri));
            reqFTP.Credentials = new NetworkCredential(ftpUserID, ftpPassword);
            reqFTP.KeepAlive = false;
            reqFTP.Method = WebRequestMethods.Ftp.UploadFile;
            reqFTP.UseBinary = true;
            reqFTP.UsePassive = false;
            reqFTP.ContentLength = fileInf.Length;
            int buffLength = 2048;
            byte[] buff = new byte[buffLength];
            int contentLen;
            FileStream fs = fileInf.OpenRead();
            try
            {
                Stream strm = reqFTP.GetRequestStream();
                contentLen = fs.Read(buff, 0, buffLength);
                while (contentLen != 0)
                {
                    strm.Write(buff, 0, contentLen);
                    contentLen = fs.Read(buff, 0, buffLength);
                }
                strm.Close();
                fs.Close();
            }
            catch (Exception ex)
            {
                throw new Exception("Ftphelper Upload Error --> " + ex.Message);
            }
        }

        /// <summary>
        /// 下载
        /// </summary>
        /// <param name="filePath"></param>
        /// <param name="fileName"></param>
        public void Download(string filePath, string fileName)
        {
            FtpWebRequest reqFTP;
            try
            {
                FileStream outputStream = new FileStream(filePath + "\\" + fileName, FileMode.Create);

                reqFTP = (FtpWebRequest)FtpWebRequest.Create(new Uri(ftpURI + fileName));
                reqFTP.Method = WebRequestMethods.Ftp.DownloadFile;
                reqFTP.UseBinary = true;
                reqFTP.UsePassive = false;
                reqFTP.Credentials = new NetworkCredential(ftpUserID, ftpPassword);
                FtpWebResponse response = (FtpWebResponse)reqFTP.GetResponse();
                Stream ftpStream = response.GetResponseStream();
                long cl = response.ContentLength;
                int bufferSize = 2048;
                int readCount;
                byte[] buffer = new byte[bufferSize];

                readCount = ftpStream.Read(buffer, 0, bufferSize);
                while (readCount > 0)
                {
                    outputStream.Write(buffer, 0, readCount);
                    readCount = ftpStream.Read(buffer, 0, bufferSize);
                }

                ftpStream.Close();
                outputStream.Close();
                response.Close();
            }
            catch (Exception ex)
            {
                throw new Exception("FtpHelper Download Error --> " + ex.Message);
            }
        }


        /// <summary>
        /// 删除文件
        /// </summary>
        /// <param name="fileName"></param>
        public void Delete(string fileName)
        {
            try
            {
                string uri = ftpURI + fileName;
                FtpWebRequest reqFTP;
                reqFTP = (FtpWebRequest)FtpWebRequest.Create(new Uri(uri));

                reqFTP.Credentials = new NetworkCredential(ftpUserID, ftpPassword);
                reqFTP.KeepAlive = false;
                reqFTP.Method = WebRequestMethods.Ftp.DeleteFile;
                reqFTP.UsePassive = false;

                string result = String.Empty;
                FtpWebResponse response = (FtpWebResponse)reqFTP.GetResponse();
                long size = response.ContentLength;
                Stream datastream = response.GetResponseStream();
                StreamReader sr = new StreamReader(datastream);
                result = sr.ReadToEnd();
                sr.Close();
                datastream.Close();
                response.Close();
            }
            catch (Exception ex)
            {
                throw new Exception("FtpHelper Delete Error --> " + ex.Message + "  文件名:" + fileName);
            }
        }

        /// <summary>
        /// 删除文件夹
        /// </summary>
        /// <param name="folderName"></param>
        public void RemoveDirectory(string folderName)
        {
            try
            {
                string uri = ftpURI + folderName;
                FtpWebRequest reqFTP;
                reqFTP = (FtpWebRequest)FtpWebRequest.Create(new Uri(uri));

                reqFTP.Credentials = new NetworkCredential(ftpUserID, ftpPassword);
                reqFTP.KeepAlive = false;
                reqFTP.Method = WebRequestMethods.Ftp.RemoveDirectory;
                reqFTP.UsePassive = false;

                string result = String.Empty;
                FtpWebResponse response = (FtpWebResponse)reqFTP.GetResponse();
                long size = response.ContentLength;
                Stream datastream = response.GetResponseStream();
                StreamReader sr = new StreamReader(datastream);
                result = sr.ReadToEnd();
                sr.Close();
                datastream.Close();
                response.Close();
            }
            catch (Exception ex)
            {
                throw new Exception("FtpHelper Delete Error --> " + ex.Message + "  文件名:" + folderName);
            }
        }

        /// <summary>
        /// 获取当前目录下明细(包含文件和文件夹)
        /// </summary>
        /// <returns></returns>
        public string[] GetFilesDetailList()
        {
            string[] downloadFiles;
            try
            {
                StringBuilder result = new StringBuilder();
                FtpWebRequest ftp;
                ftp = (FtpWebRequest)FtpWebRequest.Create(new Uri(ftpURI));
                ftp.Credentials = new NetworkCredential(ftpUserID, ftpPassword);
                ftp.Method = WebRequestMethods.Ftp.ListDirectoryDetails;
                ftp.UsePassive = false;
                WebResponse response = ftp.GetResponse();
                StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.Default);
                string line = reader.ReadLine();
                //line = reader.ReadLine();
                //line = reader.ReadLine();

                while (line != null)
                {
                    result.Append(line);
                    result.Append("\n");
                    line = reader.ReadLine();
                }
                result.Remove(result.ToString().LastIndexOf("\n"), 1);
                reader.Close();
                response.Close();
                return result.ToString().Split('\n');
            }
            catch (Exception ex)
            {
                downloadFiles = null;
                throw new Exception("FtpHelper  Error --> " + ex.Message);
            }
        }

        /// <summary>
        /// 获取当前目录下文件列表(仅文件)
        /// </summary>
        /// <returns></returns>
        public string[] GetFileList(string mask)
        {
            string[] downloadFiles;
            StringBuilder result = new StringBuilder();
            FtpWebRequest reqFTP;
            try
            {
                reqFTP = (FtpWebRequest)FtpWebRequest.Create(new Uri(ftpURI));
                reqFTP.UseBinary = true;
                reqFTP.Credentials = new NetworkCredential(ftpUserID, ftpPassword);
                reqFTP.Method = WebRequestMethods.Ftp.ListDirectory;
                reqFTP.UsePassive = false;
                WebResponse response = reqFTP.GetResponse();
                StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.Default);

                string line = reader.ReadLine();
                while (line != null)
                {
                    if (mask.Trim() != string.Empty && mask.Trim() != "*.*")
                    {

                        string mask_ = mask.Substring(0, mask.IndexOf("*"));
                        if (line.Substring(0, mask_.Length) == mask_)
                        {
                            result.Append(line);
                            result.Append("\n");
                        }
                    }
                    else
                    {
                        result.Append(line);
                        result.Append("\n");
                    }
                    line = reader.ReadLine();
                }
                result.Remove(result.ToString().LastIndexOf('\n'), 1);
                reader.Close();
                response.Close();
                return result.ToString().Split('\n');
            }
            catch (Exception ex)
            {
                downloadFiles = null;
                if (ex.Message.Trim() != "远程服务器返回错误: (550) 文件不可用(例如，未找到文件，无法访问文件)。")
                {
                    throw new Exception("FtpHelper GetFileList Error --> " + ex.Message.ToString());
                }
                return downloadFiles;
            }
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
</head>
<body>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript">

    </script>
</body>
</html>
