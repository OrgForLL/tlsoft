<%@ Page Language="C#" Debug="true" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server"> 
    public class Result
    {
        public string code;
        public string msg;
    }
    private const string bPath = "../MyUpload/smallImg";      //缩略图文件路径 
    protected void Page_Load(object sender, EventArgs e)
    {
        string url = Request.Params["src"];
        string myType = Request.Params["mytype"];
        if (url.IndexOf("../") > -1)
        {
            //虚拟路径转化成url
            //url = "http://" + Request.Url.Host + ":" + Request.Url.Port + url.Replace("../", "/");
            url = "http://192.168.35.33:88" + url.Replace("../", "/");
            //Response.Write(url);
            //Response.End();
        }

        if (string.IsNullOrEmpty(url))
        {
            Response.Write("图片路径有问题");
            Response.End();
        }

        Result result = DownloadAndCreateMiniImg(url);
        if (result.code == "success") {
            string miniPath = result.msg;
            if (string.IsNullOrEmpty(myType))
            {
                if (string.IsNullOrEmpty(miniPath))
                {
                    Response.Write("图片不存在！");
                }
                else
                {
                    showIamge(miniPath);
                }
            }
            else if (myType == "delmin")//删除小图
            {
                if (string.IsNullOrEmpty(miniPath))
                {
                    Response.Write("图片不存在！");
                }
                else
                {
                    if (File.Exists(miniPath))
                    {
                        File.Delete(miniPath);
                    }
                }
            }
        }else
        {
            Response.Write(result.msg);
            Response.End();
        }
    }


    /// <summary>
    /// 创建缩略图
    /// </summary>
    /// <param name="url"></param>
    /// <param name="bPath"></param>
    /// <param name="newFilename"></param>
    /// <returns></returns>
    private Result DownloadAndCreateMiniImg(string url)
    {
        Result result = new Result();
        string miniPath = Server.MapPath(bPath);
        miniPath += "/" + GetURLFileName(url, 1);//获取目录名
                                                 //string bPath=Server.MapPath(string.Concat("../MyUpload/smallImg"));
                                                 // System.Web.HttpContext.Current.Request.PhysicalApplicationPath

        string oldFileName = GetURLFileName(url, 0);
        string miniFilename = "mini_" + oldFileName;
        if (!Directory.Exists(miniPath))//如果日志目录不存在就创建
        {
            Directory.CreateDirectory(miniPath);
        }

        string miniFileUrl = string.Concat(miniPath, "/", miniFilename);
        if (System.IO.File.Exists(miniFileUrl))
        {
            result.code = "success";
            result.msg = miniFileUrl;
            return result; //如果文件已经存在，则不重新下载              
        }

        string strInfo = "";
        strInfo = DownloadFile(url, miniFileUrl);
        if (strInfo == "")
        {//成功
            strInfo = MakeImage(miniFileUrl, miniFileUrl, 200);
            if (strInfo == "")
            {//成功
                result.code = "success";
                result.msg = miniFileUrl;
                return result;
            }
            else
            {
                //Response.Write("处理失败");
                result.code = "error";
                result.msg = strInfo;
                return result;
            }
        }
        else
        {//失败
            result.code = "error";
            result.msg = strInfo;
            return result;
        }


    }

    /// <summary>
    /// 处理图片成指定尺寸()正方形 方便后期的直接使用；
    /// By:xlm 由于处理成正方形可能导致图片呈现效果不理想，因此缩放即可，但是不填充成正方形。
    /// </summary>
    /// <param name="SourceImage"></param>
    /// <param name="SaveImage"></param>
    /// <returns></returns>
    public string MakeImage(string SourceImage, string SaveImage, int setWidth)
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

            eImage.Dispose();
            return "";
        }
        catch (Exception ex)
        {
            //Response.Write("生成缩略图失败");
            return ex.ToString();
        }
    }


    /// <summary>
    /// 下载图片
    /// </summary>
    /// <param name="URL">目标URL</param>
    /// <param name="filename">本地的路径</param>
    /// <returns></returns>
    public string DownloadFile(string URL, string filename)
    {
        try
        {
            System.Net.HttpWebRequest Myrq = (System.Net.HttpWebRequest)System.Net.HttpWebRequest.Create(URL);
            Myrq.Timeout = 5000;
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

                        so.Dispose();
                        st.Dispose();
                        myrp.Close();
                    }
                }
            }

            return "";
        }
        catch (Exception ex)
        {
            //Response.Write("下载失败");
            return ex.ToString();
            //return string.Concat(clsSharedHelper.Error_Output, ex.Message);
        }
    }


    /// <summary>
    /// 获取url文件名
    /// </summary>
    /// <param name="url"></param>
    /// <param name="lastindex">按/ 截取的倒数第几个值；  从0开始</param>
    /// <returns></returns>
    public string GetURLFileName(string url, int lastindex)
    {
        if (string.IsNullOrEmpty(url))
        {
            return "";
        }
        Uri t_uri = new Uri(url);
        string str_url = t_uri.AbsolutePath;
        string[] str = url.Split('/');

        string fileName = "";
        if (str.Length - 1 - lastindex >= 0)
        {
            fileName = str[str.Length - 1 - lastindex];
        }
        return fileName;
    }
    /// <summary>
    /// 图片读取
    /// </summary>
    /// <param name="urlPath">加载图片的路径</param>
    public void showIamge(string urlPath)
    {
        try
        {
            System.Drawing.Image oImg = System.Drawing.Image.FromFile(urlPath);
            Response.ContentType = "application/octet-stream";
            MemoryStream mStream = new MemoryStream();
            oImg.Save(mStream, System.Drawing.Imaging.ImageFormat.Jpeg);
            mStream.WriteTo(Response.OutputStream);
            mStream.Close();
            oImg.Dispose();
        }catch(Exception ex)
        {
            Response.Write(ex.Message+",urlPath:"+urlPath);
            Response.End();
        }
    }
</script>
