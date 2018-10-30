<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>

<!DOCTYPE html>
<script runat="server">   
    public const int IMGMAXSIZE = 2097152;//图片文件大小的最大值 单位B

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "UploadImg":                
                string info = UploadImageMain(HttpContext.Current);
                clsSharedHelper.WriteInfo(info);
                break;
            case "Save":
                string aid = Convert.ToString(Request.Params["aid"]);
                string jsonData = Convert.ToString(Request.Params["jsondata"]);
                SaveModifyArticle(aid, jsonData);
                break;
            case "LoadArticle":
                aid = Convert.ToString(Request.Params["aid"]);
                LoadArticle(aid);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("参数【CTRL】有误！");
                break;
        }
        //clsSharedHelper.WriteInfo(ctrl);
    }

    public static void Log(string strInfo, string logDirectory)
    {
        strInfo = string.Concat(DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), " - ", "信息", "\r\n") + strInfo;
        string fileName = string.Concat(logDirectory, "\\", "tmp", ".log");
        System.IO.File.WriteAllText(fileName, strInfo, System.Text.Encoding.Default);
    }

    public string UploadImageMain(HttpContext context)
    {
        string rtMsg = "";
        context.Response.ContentType = "text/html";

        HttpPostedFile postedFile = context.Request.Files[0];
        string sourceName = postedFile.FileName;
        string fileExtension = sourceName.Substring(sourceName.LastIndexOf('.'), sourceName.Length - sourceName.LastIndexOf('.')).ToLower();
        if (fileExtension != ".jpg" && fileExtension != ".jpeg" && fileExtension != ".png" && fileExtension != ".gif")
            clsSharedHelper.WriteInfo("error|只能上传图片！jpg|jpeg|png|gif");
        string savePath = "Resource/Image/" + DateTime.Now.ToString("yyyyMMdd") + "/";
        int filelength = postedFile.ContentLength;
        int fileSize = IMGMAXSIZE; //2M 单位B
        string fileName = "-1"; //返回的上传后的文件名                
        if (filelength <= fileSize)
        {
            try
            {
                byte[] buffer = new byte[filelength];
                postedFile.InputStream.Read(buffer, 0, filelength);
                fileName = UploadImage(buffer, savePath, "jpg");
                if (fileName != "-1")
                {
                    //文件保存成功
                    //保存数据库记录
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
                    {
                        string str_sql = @"insert into t_ArticleImages(imgpath,imgfilename,imgsourcename,createtime)
                                            values(@savepath,@filename,@sourcename,getdate());
                                            select @@identity;";
                        DataTable dt = null;
                        List<SqlParameter> paras = new List<SqlParameter>();
                        paras.Add(new SqlParameter("@savepath", savePath));
                        paras.Add(new SqlParameter("@filename", fileName));
                        paras.Add(new SqlParameter("@sourcename", sourceName));
                        string errInfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                        if (errInfo == "" && dt.Rows.Count > 0)
                        {
                            rtMsg = fileName;
                        }
                        else
                        {
                            rtMsg = "error|文件保存成功但是写入数据库失败：" + errInfo;
                        }
                    }
                }
                else
                {
                    rtMsg = "error|" + fileName;
                }
            }
            catch (Exception ex)
            {
                rtMsg = "error|" + ex.Message;
            }
        }
        else
            rtMsg = "error|文件大小超过限制！";

        return rtMsg;
    }

    //上传图片文件
    public string UploadImage(byte[] imgBuffer, string uploadpath, string ext)
    {
        try
        {
            System.IO.MemoryStream m = new MemoryStream(imgBuffer);

            if (!Directory.Exists(HttpContext.Current.Server.MapPath(uploadpath)))
                Directory.CreateDirectory(HttpContext.Current.Server.MapPath(uploadpath));

            string imgname = CreateIDCode() + "." + ext;
            string _path = HttpContext.Current.Server.MapPath(uploadpath) + imgname;

            System.Drawing.Image img = System.Drawing.Image.FromStream(m);
            img.Save(_path, System.Drawing.Imaging.ImageFormat.Jpeg);

            m.Close();

            return uploadpath + imgname;
        }
        catch (Exception ex)
        {
            return ex.Message;
        }

    }

    //生成文件名
    public string CreateIDCode()
    {
        DateTime Time1 = DateTime.Now.ToUniversalTime();
        DateTime Time2 = Convert.ToDateTime("1970-01-01");
        TimeSpan span = Time1 - Time2;   //span就是两个日期之间的差额   
        string t = span.TotalMilliseconds.ToString("0");

        return t;
    }
    
    //加载文章数据
    public void LoadArticle(string aid) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            string str_sql = string.Format("select title,author,sourcelink,bodyhtml from t_MultiArticles where id='{0}'", aid);
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(str_sql,out dt);
            if (errinfo == "")
                if (dt.Rows.Count > 0)
                {
                    string title = Convert.ToString(dt.Rows[0]["title"]);
                    string author = Convert.ToString(dt.Rows[0]["author"]);
                    string sourcelink = Convert.ToString(dt.Rows[0]["sourcelink"]);
                    string bodyhtml = Convert.ToString(dt.Rows[0]["bodyhtml"]);
                    JObject jo = new JObject();
                    jo["title"] = title;
                    jo["author"] = author;
                    jo["sourcelink"] = sourcelink;
                    jo["bodyhtml"] = bodyhtml;
                    clsSharedHelper.WriteInfo(jo.ToString());
                }
                else
                    clsSharedHelper.WriteErrorInfo("请检查传入的参数是否有效！");
            else
                clsSharedHelper.WriteErrorInfo("数据库查询出错 " + errinfo);
        }
    }
    
    //提交保存文章数据
    public void SaveModifyArticle(string aid,string jsonStr) {
        JObject jo = JObject.Parse(jsonStr);
        string title = Convert.ToString(jo["title"]);
        string author=Convert.ToString(jo["author"]);
        string link = Convert.ToString(jo["link"]);
        if (link != "" && !link.Contains("http://") && !link.Contains("https://"))
            link = "http://" + link;
        string bodyhtml = Convert.ToString(jo["bodyhtml"]);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            List<SqlParameter> paras = new List<SqlParameter>();
            string str_sql = "";
            if (aid == "" || aid == "0")
            {
                //新增操作
                str_sql = @"declare @id int;
                            insert into t_MultiArticles(title,author,createrid,creater,createtime,sourcelink,needvalidate,bodyhtml,newversion,isactive) 
                            values (@title,@author,@createrid,@creater,getdate(),@sourcelink,0,@bodyhtml,@needvalidate,@isactive);
                            select @@identity;";
                paras.Add(new SqlParameter("@title",title));
                paras.Add(new SqlParameter("@author", author));
                paras.Add(new SqlParameter("@createrid","1"));
                paras.Add(new SqlParameter("@creater", "Elilee"));
                paras.Add(new SqlParameter("@sourcelink", link));
                paras.Add(new SqlParameter("@bodyhtml", bodyhtml));
                paras.Add(new SqlParameter("@isactive", "1"));
                paras.Add(new SqlParameter("@needvalidate", "1"));
            }
            else
            {
                //修改操作 
                str_sql = @"update t_MultiArticles set title=@title,author=@author,sourcelink=@sourcelink,needvalidate=@needvalidate,bodyhtml=@bodyhtml,isactive=@isactive,
                            lasteditorid=@lasteditor,lasteditorname=@lastname,lasteditortime=getdate() where id=@id;
                            select @id;";
                paras.Add(new SqlParameter("@title", title));
                paras.Add(new SqlParameter("@author", author));
                paras.Add(new SqlParameter("@lasteditor", "1"));
                paras.Add(new SqlParameter("@lastname", "Elilee"));
                paras.Add(new SqlParameter("@sourcelink", link));
                paras.Add(new SqlParameter("@bodyhtml", bodyhtml));
                paras.Add(new SqlParameter("@isactive", "1"));
                paras.Add(new SqlParameter("@needvalidate", "1"));
                paras.Add(new SqlParameter("@id", aid));
            }

            object scalar;
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
            if (errinfo =="")
                clsSharedHelper.WriteSuccessedInfo(Convert.ToString(scalar));
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }//end using
    }
</script>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form runat="server">
        <div>
            BID:<asp:TextBox ID="bidtxt" runat="server"></asp:TextBox><asp:Button ID="backup" runat="server" Text="Backup" />
            <asp:Label ID="txtlab" runat="server" Text="" ForeColor="Red"></asp:Label>
        </div>
    </form>
</body>
</html>
