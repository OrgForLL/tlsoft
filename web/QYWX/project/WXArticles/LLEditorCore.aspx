<%@ Page Language="C#" ValidateRequest="false" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<!DOCTYPE html>
<script runat="server"> 
    //20160514 liqf 加入日志记录功能
    public const int IMGMAXSIZE = 5242880;//图片文件大小的最大值 单位B
    public string UID = "";
    public string UNAME = "";
    private string DBConnStr = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        if (ctrl == "UploadImg" || ctrl == "Save")
        {
            UID = Convert.ToString(Session["AR_UID"]);
            UNAME = Convert.ToString(Session["AR_UNAME"]);
            if (UID == "" || UID == "0" || UID == null)
            {
                clsSharedHelper.WriteErrorInfo("系统超时，请重新登录！");
                return;
            }

            switch (ctrl)
            {
                case "UploadImg":
                    string uplx = Convert.ToString(Request.Params["uplx"]);
                    if (uplx == "" || uplx == null)
                        uplx = "";
                    string info = UploadImageMain(HttpContext.Current, uplx);
                    clsSharedHelper.WriteInfo(info);
                    break;
                case "Save":
                    string aid = Convert.ToString(Request.Params["aid"]);
                    string jsonData = Convert.ToString(Request.Params["jsondata"]);
                    SaveModifyArticle(aid, jsonData);
                    break;
                default:
                    clsSharedHelper.WriteErrorInfo("参数【CTRL】有误！");
                    break;
            }
        }
        else
        {
            switch (ctrl)
            {
                case "login":
                    string username = Convert.ToString(Request.Params["username"]).Trim();
                    string pwd = Convert.ToString(Request.Params["pwd"]);
                    UserLogin(username, pwd);
                    break;
                case "logout":
                    LogOut();
                    break;
                case "LoadArticleList":
                    string gid = Convert.ToString(Request.Params["gid"]);
                    string xh = Convert.ToString(Request.Params["xh"]);
                    if (gid == "" || gid == "0" || gid == null)
                        clsSharedHelper.WriteErrorInfo("请检查参数GID！");
                    else if (xh == "" || xh == null)
                        clsSharedHelper.WriteErrorInfo("请检查参数XH！");
                    else
                        LoadArticleList(gid,xh);
                    break;
                case "LoadArticle":
                    string aid = Convert.ToString(Request.Params["aid"]);
                    LoadArticle(aid);
                    break;
                case "LoadArticle_PC":
                    gid = Convert.ToString(Request.Params["gid"]);
                    xh=Convert.ToString(Request.Params["lastxh"]);
                    if (gid == "" || gid == "0" || gid == null)
                        clsSharedHelper.WriteErrorInfo("请检查参数GID是否有误！");
                    else if (xh == "" || xh == null)
                        clsSharedHelper.WriteErrorInfo("请检查参数LASTXH是否有误！");
                    else
                        LoadArticleList_PC(gid,xh);
                    break;
                case "LoadGroups_PC":
                    string ssid = Convert.ToString(Request.Params["ssid"]);
                    if (ssid == "" || ssid == "0" || ssid == null)
                        clsSharedHelper.WriteErrorInfo("参数SSID有误！");
                    else
                        LoadGroups_PC(ssid);
                    break;
                default:
                    clsSharedHelper.WriteErrorInfo("参数【CTRL】有误！");
                    break;
            }
        }
    }

    //加载分组列表
    public void LoadGroups_PC(string ssid) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            string str_sql = @"select groupid,count(articleid) sl into #gsl
                                from t_ArticleGroupLink a
                                group by groupid

                                select a.id,a.groupname,b.sl
                                from t_articlegroup a 
                                left join #gsl b on a.id=b.groupid
                                where a.ssid=@ssid and a.isactive=1;
                                drop table #gsl;";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@ssid", ssid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                else
                    clsSharedHelper.WriteInfo("");
            }
            else
            {
                WriteLog("PC端加载文章分组时出错！" + errinfo);
                clsSharedHelper.WriteErrorInfo("PC端加载文章分组时出错！" + errinfo);
            }
        }
    }

    //加载文章列表(移动端使用)
    public void LoadArticleList(string gid,string xh)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            string str_sql = @"select b.id,b.title,b.summary,b.author,month(b.createtime) yf,day(b.createtime) dd,b.viewtimes,
                                convert(varchar(5),b.createtime,114) sj,isnull(d.imgfilename,'') coverimg,row_number() over(order by b.id desc) xh into #alist
                                from t_ArticleGroupLink a
                                inner join t_MultiArticles b on a.articleid=b.id
                                inner join t_articlegroup c on a.groupid=c.id and c.ssid=10
                                left join t_articleimages d on b.coverid=d.id
                                where a.groupid=case when @gid=-1 then a.groupid else @gid end;
                                select top 20 * from #alist where xh>@xh;drop table #alist;";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gid", gid));
            paras.Add(new SqlParameter("@xh", xh));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                else
                    clsSharedHelper.WriteInfo("");
            }
            else {
                WriteLog("PC端加载文章列表时出错！" + errinfo);
                clsSharedHelper.WriteErrorInfo("PC端加载文章列表时出错！" + errinfo);
            }                
        }
    }

    //加载文章列表(PC端使用)
    public void LoadArticleList_PC(string gid,string lastxh) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            string str_sql = @"select b.id,b.title,b.author,convert(varchar(10),b.createtime,120) createtime,isnull(c.imgfilename,'') thumb,b.viewtimes,
                                row_number() over(order by b.createtime desc) xh into #myzb
                                from t_ArticleGroupLink a
                                inner join t_MultiArticles b on a.articleid=b.id
                                left join t_ArticleImages c on b.coverid=c.id
                                where a.groupid=@gid

                                select top 10 * from #myzb where xh>@xh;
                                drop table #myzb;";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@gid", gid));
            paras.Add(new SqlParameter("@xh", lastxh));
            string errinfo = dal.ExecuteQuerySecurity(str_sql,paras,out dt);
            if (errinfo == "")
                if (dt.Rows.Count > 0)
                    clsSharedHelper.WriteInfo(JsonHelp.dataset2json(dt));
                else
                    clsSharedHelper.WriteInfo("");
            else
                clsSharedHelper.WriteErrorInfo(errinfo);
        }
    }    
    
    //退出操作
    public void LogOut()
    {
        Session["AR_UID"] = null;
        Session["AR_UNAME"] = null;
        Session.Remove("AR_UID");
        Session.Remove("AR_UNAME");
        clsSharedHelper.WriteSuccessedInfo("");
    }

    //登陆逻辑
    public void UserLogin(string username, string password)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            string str_sql = @"select top 1 cname,id from t_user where name=@username and pass=@pass;";
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@username", username));
            paras.Add(new SqlParameter("@pass", MD5(password)));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    Session["AR_UID"] = Convert.ToString(dt.Rows[0]["id"]);
                    Session["AR_UNAME"] = Convert.ToString(dt.Rows[0]["cname"]);
                    clsSharedHelper.WriteSuccessedInfo("");
                }
                else
                    clsSharedHelper.WriteErrorInfo("请检查用户名或密码是否有误！");
            }
            else {
                WriteLog("验证账号时出错 " + errinfo);
                clsSharedHelper.WriteErrorInfo("验证账号时出错 " + errinfo);
            }                
        }
    }

    /// <summary>
    /// 拓力用的MD5加密算法
    /// </summary>
    /// <param name="sText"></param>
    /// <returns></returns>
    public static string MD5(string sText)
    {
        string newPwd = string.Empty;
        Byte[] clearBytes = Encoding.Unicode.GetBytes(sText);
        Byte[] hashedBytes = ((HashAlgorithm)CryptoConfig.CreateFromName("MD5")).ComputeHash(clearBytes);
        newPwd = BitConverter.ToString(hashedBytes).Replace("-", "");

        return newPwd;
    }

    public string UploadImageMain(HttpContext context, string uplx)
    {
        string rtMsg = "";
        context.Response.ContentType = "text/html";

        HttpPostedFile postedFile = context.Request.Files[0];
        string sourceName = postedFile.FileName;
        string fileExtension = sourceName.Substring(sourceName.LastIndexOf('.'), sourceName.Length - sourceName.LastIndexOf('.')).ToLower();
        if (fileExtension != ".jpg" && fileExtension != ".jpeg" && fileExtension != ".png" && fileExtension != ".gif")
            clsSharedHelper.WriteInfo("error|只能上传图片！jpg|jpeg|png|gif");
        string savePath = "../../upload/WXArticles/Image/" + DateTime.Now.ToString("yyyyMM") + "/";
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
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
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
                            if (uplx == "thumb")
                                rtMsg = Convert.ToString(dt.Rows[0][0]);
                            else
                                rtMsg = fileName;                            
                        }
                        else
                        {
                            WriteLog("error|文件保存成功但是写入数据库失败：" + errInfo + "【SQL】:" + str_sql);
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
                WriteLog("上传图片出错 " + ex.StackTrace);
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
            WriteLog("上传图片出错 " + ex.StackTrace);
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
    public void LoadArticle(string aid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            string str_sql = @"select title,author,sourcelink,bodyhtml,convert(varchar(5),createtime,10)+' '+convert(varchar(5),createtime,114) createtime 
                               from t_MultiArticles where id='{0}'";
            str_sql = string.Format(str_sql, aid);
            DataTable dt = null;
            string errinfo = dal.ExecuteQuery(str_sql, out dt);
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
                    jo["createtime"] = Convert.ToString(dt.Rows[0]["createtime"]);
                    clsSharedHelper.WriteInfo(jo.ToString());
                }
                else
                    clsSharedHelper.WriteErrorInfo("请检查传入的参数是否有效！");
            else {
                WriteLog("加载文章数据时查询出错 " + errinfo + "【SQL】:" + str_sql);
                clsSharedHelper.WriteErrorInfo("数据库查询出错 " + errinfo);
            }                
        }
    }

    //提交保存文章数据
    public void SaveModifyArticle(string aid, string jsonStr)
    {
        JObject jo = JObject.Parse(jsonStr);
        string title = Convert.ToString(jo["title"]);
        string author = Convert.ToString(jo["author"]);
        string link = Convert.ToString(jo["link"]);
        string summary = Convert.ToString(jo["summary"]);
        string thumbid = Convert.ToString(jo["thumbid"]);
        string groupid = Convert.ToString(jo["groupid"]);
        if (link != "" && !link.Contains("http://") && !link.Contains("https://"))
            link = "http://" + link;
        string bodyhtml = Convert.ToString(jo["bodyhtml"]);
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
        {
            List<SqlParameter> paras = new List<SqlParameter>();
            string str_sql = "";
            if (aid == "" || aid == "0")
            {
                //新增操作
                str_sql = @"declare @id int;
                            insert into t_MultiArticles(title,author,createrid,creater,createtime,sourcelink,needvalidate,bodyhtml,newversion,isactive,summary,coverid) 
                            values (@title,@author,@createrid,@creater,getdate(),@sourcelink,0,@bodyhtml,@needvalidate,@isactive,@summary,@thumbid);
                            select @id=@@identity;
                            insert into t_ArticleGroupLink(groupid,articleid) values (@gid,@id);
                            select @id;";
                paras.Add(new SqlParameter("@title", title));
                paras.Add(new SqlParameter("@author", author));
                paras.Add(new SqlParameter("@createrid", UID));
                paras.Add(new SqlParameter("@creater", UNAME));
                paras.Add(new SqlParameter("@sourcelink", link));
                paras.Add(new SqlParameter("@bodyhtml", bodyhtml));
                paras.Add(new SqlParameter("@isactive", "1"));
                paras.Add(new SqlParameter("@needvalidate", "1"));
                paras.Add(new SqlParameter("@summary", summary));
                paras.Add(new SqlParameter("@thumbid", thumbid));
                paras.Add(new SqlParameter("@gid",groupid));
            }
            else
            {
                //修改操作 
                str_sql = @"update t_MultiArticles set title=@title,author=@author,sourcelink=@sourcelink,needvalidate=@needvalidate,bodyhtml=@bodyhtml,isactive=@isactive,
                            lasteditorid=@lasteditor,lasteditorname=@lastname,lasteditortime=getdate(),summary=@summary,coverid=@thumbid where id=@id;
                            update t_ArticleGroupLink set groupid=@gid where articleid=@id;
                            select @id;";
                paras.Add(new SqlParameter("@title", title));
                paras.Add(new SqlParameter("@author", author));
                paras.Add(new SqlParameter("@lasteditor", UID));
                paras.Add(new SqlParameter("@lastname", UNAME));
                paras.Add(new SqlParameter("@sourcelink", link));
                paras.Add(new SqlParameter("@bodyhtml", bodyhtml));
                paras.Add(new SqlParameter("@isactive", "1"));
                paras.Add(new SqlParameter("@needvalidate", "1"));
                paras.Add(new SqlParameter("@id", aid));
                paras.Add(new SqlParameter("@gid", groupid));
                paras.Add(new SqlParameter("@summary", summary));
                paras.Add(new SqlParameter("@thumbid", thumbid));
            }

            object scalar;
            string errinfo = dal.ExecuteQueryFastSecurity(str_sql, paras, out scalar);
            WriteLog("SaveModifyArticle 【SQL】:" + str_sql);                       
            if (errinfo == "")
                clsSharedHelper.WriteSuccessedInfo(Convert.ToString(scalar));
            else {
                WriteLog("保存文章时出错 " + errinfo + "【SQL】:" + str_sql);
                clsSharedHelper.WriteErrorInfo(errinfo);
            }                
        }//end using
    }

    //写日志方法
    private void WriteLog(string text)
    {
        //AppDomain.CurrentDomain.BaseDirectory + "logs\\"
        String path = HttpContext.Current.Server.MapPath("logs/");
        if (!System.IO.Directory.Exists(System.IO.Path.GetDirectoryName(path)))
        {
            System.IO.Directory.CreateDirectory(path);
        }
        System.IO.StreamWriter writer =new System.IO.StreamWriter(path + DateTime.Now.ToString("yyyyMMdd") + ".log", true);
        string str;
        str = "[" + DateTime.Now.ToString() + "]\r\n" + text;
        writer.WriteLine(str);
        writer.Close();
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
