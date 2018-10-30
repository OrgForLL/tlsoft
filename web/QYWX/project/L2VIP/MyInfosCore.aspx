<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Web.Security" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    //string WXconnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
    string WXconnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
     
    protected void Page_Load(object sender, EventArgs e)
    {
        string openid = Convert.ToString(Session["openid"]);
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "SaveFaceImage":
                string formFile = Convert.ToString(Request.Params["formFile"]);
                string rotate = Convert.ToString(Request.Params["rotate"]);
                clsSharedHelper.WriteInfo(SaveFaceImage(openid, formFile, rotate));
                break;
            case "SaveNickname":
                string nickname = System.Web.HttpUtility.UrlDecode(Request.Params["nickname"], System.Text.Encoding.Default);
                clsSharedHelper.WriteInfo(SaveNickname(openid, nickname));
                break;
            default:
                clsSharedHelper.WriteErrorInfo("参数【ctrl】有误！");
                break;
        }
    }

    public string SaveNickname(string openid, string nickname)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXconnStr))
        {
            string errInfo = "";
            string strSQL = @"update wx_t_vipBinging set wxNick=@Nickname where wxOpenid=@openid";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@Nickname", nickname));
            paras.Add(new SqlParameter("@openid", openid));
            errInfo = dal.ExecuteNonQuerySecurity(strSQL, paras);
            if (errInfo == "")
            {
                return clsNetExecute.Successed;
            }
            else
            {
                errInfo = "error:" + errInfo;
                return errInfo;
            }
        }
    }

    public string SaveFaceImage(string openid, string formFile, string rotate)
    {
        string path = HttpContext.Current.Server.MapPath("../../upload/" + DateTime.Now.ToString("yyyyMM") + "/");
        string myPath = HttpContext.Current.Server.MapPath("../../upload/" + DateTime.Now.ToString("yyyyMM") + "/my/"); //压缩图路径
        string strPath = Path.GetDirectoryName(path);
        string filename = DateTime.Now.ToString("yyyyMMddHHmmss") + ".png";
        if (!Directory.Exists(strPath))
        {
            Directory.CreateDirectory(strPath);
        }
        String rt = Base64StringToImage(formFile, path, filename, rotate);

        strPath = Path.GetDirectoryName(myPath);
        if (!Directory.Exists(strPath))
        {
            Directory.CreateDirectory(strPath);
        }
        int setImgWidth = 140;
        rt = MakeImage(path + filename, myPath + filename, setImgWidth);
        if (rt.Equals(""))
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXconnStr))
            {
                string errInfo = "";
                string strSQL = @"update wx_t_vipBinging set wxHeadimgurl=@FaceImg where wxOpenid=@openid";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@FaceImg", "upload/" + DateTime.Now.ToString("yyyyMM") + "/my/" + filename));
                paras.Add(new SqlParameter("@openid", openid));
                errInfo = dal.ExecuteNonQuerySecurity(strSQL, paras);
                if (errInfo == "")
                {
                    return "upload/" + DateTime.Now.ToString("yyyyMM") + "/my/" + filename;
                }
                else
                {
                    errInfo = "error:" + errInfo;
                    return errInfo;
                }
            }
        }
        else
        {
            return "error:" + rt;
        }        
    }

    //图片处理上传
    private String Base64StringToImage(string PicBase64, string path, string filename, string rotate)
    {
        try
        {
            byte[] arr = Convert.FromBase64String(PicBase64);
            MemoryStream ms = new MemoryStream(arr);
            using (Bitmap bmp = new Bitmap(ms))
            {
                switch (rotate)
                {
                    case "2": bmp.RotateFlip(RotateFlipType.RotateNoneFlipX);
                        break;
                    case "3": bmp.RotateFlip(RotateFlipType.Rotate180FlipNone);
                        break;
                    case "4": bmp.RotateFlip(RotateFlipType.RotateNoneFlipY);
                        break;
                    case "5": bmp.RotateFlip(RotateFlipType.Rotate90FlipX);
                        break;
                    case "6": bmp.RotateFlip(RotateFlipType.Rotate90FlipNone);
                        break;
                    case "7": bmp.RotateFlip(RotateFlipType.Rotate270FlipX);
                        break;
                    case "8": bmp.RotateFlip(RotateFlipType.Rotate270FlipNone);
                        break;
                    default:
                        break;
                }

                bmp.Save(path + filename, System.Drawing.Imaging.ImageFormat.Jpeg);
                ms.Close();
                return "";
            }
        }
        catch (Exception ex)
        {
            return "Base64StringToImage 转换失败\nException：" + ex.Message;
        }
    }

    /// <summary>
    /// 处理图片成指定尺寸()正方形 方便后期的直接使用；
    /// By:xlm 由于处理成正方形可能导致图片呈现效果不理想，因此缩放即可，但是不填充成正方形。
    /// </summary>
    /// <param name="SourceImage">源图片的文件位置</param>
    /// <param name="SaveImage">图片文件保存的目标位置</param>
    /// <param name="setWidth">设置的宽度，以宽度为基准</param>
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

            return "";
        }
        catch (Exception ex)
        {
            return "处理图片失败！错误：" + ex.Message;
        }
    }

    /// <summary>
    /// 处理图片成指定尺寸()正方形 方便后期的直接使用
    /// 直接处理成50X50用于帖子的缩略图加快读取
    /// </summary>
    /// <param name="SourceImage"></param>
    /// <param name="SaveImage"></param>
    /// <returns></returns>
    private string MakeImage(string SourceImage, string SaveImage)
    {
        int imgWidth = 100;
        int imgHeight = 100;
        try
        {
            System.Drawing.Bitmap myBitMap = new System.Drawing.Bitmap(SourceImage);
            int pWidth = myBitMap.Width;
            int pHeight = myBitMap.Height;
            double pcent = pWidth * 1.0 / pHeight;
            double ecent = imgWidth * 1.0 / imgHeight;
            int eWidth = 0;
            int eHeight = 0;
            int draX = 0;
            int draY = 0;
            //上传图片更宽，需要补充高度
            if (pcent > ecent)
            {
                pWidth = imgWidth;
                pHeight = Convert.ToInt32(pWidth * 1.0 / pcent);
                eWidth = pWidth;
                eHeight = Convert.ToInt32(pWidth * 1.0 / ecent);
                draX = 0;
                draY = (eHeight - pHeight) / 2;
                //上传图片更窄，需要补充宽度
            }
            else
            {
                pHeight = imgHeight;
                pWidth = Convert.ToInt32(pHeight * pcent);

                eWidth = Convert.ToInt32(pHeight * ecent);
                eHeight = pHeight;
                draX = (eWidth - pWidth) / 2;
                draY = 0;
            }

            System.Drawing.Bitmap eImage = new System.Drawing.Bitmap(imgWidth, imgHeight);
            System.Drawing.Graphics g = System.Drawing.Graphics.FromImage(eImage);
            g.FillRectangle(System.Drawing.Brushes.Black, new System.Drawing.Rectangle(0, 0, imgWidth, imgHeight));
            g.DrawImage(myBitMap, draX, draY, pWidth, pHeight);

            g.Save();

            myBitMap.Dispose();
            eImage.Save(SaveImage, System.Drawing.Imaging.ImageFormat.Jpeg);
            g.Dispose();

            return "";
        }
        catch (Exception ex)
        {
            return "处理图片失败！错误：" + ex.Message;
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    </div>
    </form>
</body>
</html>
