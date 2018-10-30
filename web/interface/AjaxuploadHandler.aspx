<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data"%>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>

<!DOCTYPE html>
<script runat="server">
    //静态变量 变局使用
    public static string access_token = "";
    public static string access_token_time = "";

    public static string jsapi_ticket = "";
    public static string jsapi_ticket_time = "";
    
    public const int IMGMAXSIZE = 2097152;//图片文件大小的最大值 单位B
    //利郎零售管理公众号
    public string AppID = "wx9e66df5eaf2dd2d5";
    public string AppSecret = "4e44e3dfed925e8b2ad99aeebe512bc8";
    //public string DBStr = "server=192.168.35.23;database=tlsoft;uid=lllogin;pwd=rw1894tla";
    protected void Page_Load(object sender, EventArgs e)
    {        
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        if (ctrl == "" || ctrl == null) {
            clsSharedHelper.WriteErrorInfo("请传入正确的CTRL参数！");
            return;
        }

        switch (ctrl) { 
            case "UploadImage":
                string sourceName = Convert.ToString(Request.Params["filename"]);                                
                string info = UploadImageMain(HttpContext.Current, sourceName);
                Response.Clear();
                Response.Write(info);
                Response.End();              
                break;
            case "SaveArticle":
                string userid = Convert.ToString(Request.Params["userid"]);
                string username = Convert.ToString(Request.Params["username"]);                
                string jsonData = Convert.ToString(Request.Params["jsonData"]);
                SaveModifyArticle(jsonData, "0", userid, username);
                break;
            case "loadArticle":
                string id = Convert.ToString(Request.Params["id"]);
                if (id == null || id == "") {
                    clsSharedHelper.WriteErrorInfo("缺少参数ID！");
                }else
                    loadArticle(id);                
                break;
            case "ModifyArticle":
                id = Convert.ToString(Request.Params["id"]); 
                userid = Convert.ToString(Request.Params["userid"]);
                username = Convert.ToString(Request.Params["username"]);               
                jsonData = Convert.ToString(Request.Params["jsonData"]);
                if (id == null || id == "")
                {
                    clsSharedHelper.WriteErrorInfo("缺少参数ID！");
                }
                else
                    SaveModifyArticle(jsonData, id, userid, username);
                break;
            case "loadArticleList":
                string ssid = Convert.ToString(Request.Params["ssid"]);
                if (ssid == null || ssid == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数SSID！");
                loadArticleList("",ssid);
                break;
            case "loadArticleList2":
                string lastid = Convert.ToString(Request.Params["lastid"]);
                ssid = Convert.ToString(Request.Params["ssid"]);
                if (ssid == null || ssid == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数SSID！");
                if (lastid == "" || lastid == null)
                    lastid = "0";
                
                loadArticleList2(lastid,ssid);
                break;
            case "searchArticle":
                string searchtxt = Convert.ToString(Request.Params["txt"]);
                ssid = Convert.ToString(Request.Params["ssid"]);
                if (ssid == null || ssid == "")
                    clsSharedHelper.WriteErrorInfo("缺少参数SSID！");
                loadArticleList(searchtxt,ssid);
                break;
            case "loadGroup":
                ssid = Convert.ToString(Request.Params["ssid"]);
                if (ssid == "" || ssid == null)
                    clsSharedHelper.WriteErrorInfo("请传入分组SSID！");
                else
                    loadGroup(ssid);
                break;
            case "JSConfig":
                string myURL = Convert.ToString(Request.Params["myURL"]);
                if (myURL == "" || myURL == null)
                    clsSharedHelper.WriteErrorInfo("缺少参数myURL！");
                else {
                    myURL = HttpUtility.UrlDecode(myURL);
                    string result = getJSConfig(myURL, AppID, AppSecret);
                    clsSharedHelper.WriteInfo(result);
                }                
                break;
            case "connStr":
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
                    clsSharedHelper.WriteInfo(dal.ConnectionString);
                }
                break;
            //case "writeSession":
            //    Session["id"] = "54199";
            //    Session["cname"] = "林洪茂";
            //    Session["userid"] = "54199";
            //    Session["username"] = "林洪茂";
            //    break;
            //case "clearSession":
            //    Session["id"] = null;
            //    Session["cname"] = null;
            //    Session["userid"] = null;
            //    Session["username"] = null;
            //    break;
            default:
                clsSharedHelper.WriteInfo("无" + ctrl + "对应操作！");
                break;
        }  
        
    }
    
    //获取JSConfig配置参数
    public string getJSConfig(string URL, string appID, string appSecret)
    {
        string rtMsg = "", postURL = "", content = "";
        DateTime currentTime = DateTime.Now;
        clsJsonHelper jh = null;
        if (access_token == "" || access_token_time == "" || DateTime.Compare(currentTime.AddSeconds(-7000), Convert.ToDateTime(access_token_time)) > 0){
            postURL = string.Format("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid={0}&secret={1}", appID, appSecret);
            content = clsNetExecute.HttpRequest(postURL);
            jh = clsJsonHelper.CreateJsonHelper(content);
            access_token = jh.GetJsonValue("access_token");
            access_token_time = currentTime.ToShortTimeString();
        }
        
        currentTime = DateTime.Now;        
        if (jsapi_ticket == "" || jsapi_ticket_time == "" || DateTime.Compare(currentTime.AddSeconds(-7000), Convert.ToDateTime(jsapi_ticket_time)) > 0) {
            postURL = string.Format("https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token={0}&type=jsapi", access_token);
            content = clsNetExecute.HttpRequest(postURL);
            jh = clsJsonHelper.CreateJsonHelper(content);
            jsapi_ticket = jh.GetJsonValue("ticket");
            jsapi_ticket_time = currentTime.ToShortTimeString();
        }
           
        string[] str=callJsApiConfig(URL);
        for (int i = 0; i < str.Length; i++) {
            rtMsg += str[i] + "|";        
        }
        
        return rtMsg;
    }


    public string[] callJsApiConfig(string myURL) {
        string[] rt = new string[4];

        //先拼接成string1
        string string1 = "jsapi_ticket={0}&noncestr={1}&timestamp={2}&url={3}";
        string noncestr = Guid.NewGuid().ToString().Replace("-", "");
        noncestr = noncestr.Substring(noncestr.Length - 16);
        string timestamp = ConvertDateTimeInt(DateTime.Now).ToString();
        if (myURL.Contains("#")) myURL = myURL.Substring(0, myURL.IndexOf('#'));

        string1 = string.Format(string1, jsapi_ticket, noncestr, timestamp, myURL);
        //使用SHA1方法，换算成 signature
        string signature = FormsAuthentication.HashPasswordForStoringInConfigFile(string1, "SHA1");
        signature = signature.ToLower();
        rt[0] = AppID;
        rt[1] = timestamp;//生成签名的时间戳
        rt[2] = noncestr;//生成签名的随机串
        rt[3] = signature;//签名

        return rt;
    }

    private int ConvertDateTimeInt(System.DateTime time)
    {
        System.DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new System.DateTime(1970, 1, 1));
        return (int)(time - startTime).TotalSeconds;
    }
    
    //加载左侧分组列表
    public void loadGroup(string ssid) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {            
            string str_sql = @"select b.id,b.groupname from t_ArticleGroup a
                                inner join t_ArticleGroup b on a.ssid=b.ssid
                                where a.isactive=1 and a.id=@ssid;";
            DataTable dt=null;
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@ssid",ssid));
            string errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            if (errInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    string str = JsonHelp.dataset2json(dt);
                    clsSharedHelper.WriteInfo("Successed:" + str);
                }
                else
                    clsSharedHelper.WriteErrorInfo("SSID=" + ssid + "的分组无下级数据！");
            }
            else
                clsSharedHelper.WriteErrorInfo("加载分组菜单失败:" + errInfo);
        }
    }
    
    //加载文章列表
    public void loadArticleList(string searchtxt,string ssid) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            string str_sql = @"select a.id,a.title,convert(varchar(10),a.createtime,120) createtime
                                from t_multiarticles a
                                inner join (select articleid from t_ArticleGroupLink where groupid=@ssid) b on a.id=b.articleid
                                where a.isactive=1";
            if (searchtxt != "") {
                str_sql += " and a.title like '%" + searchtxt + "%'";
            }
            str_sql += " order by a.createtime desc";
            DataTable dt = null;
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@ssid",ssid));
            string errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            if (errInfo == "")
            {
                if (dt.Rows.Count == 0)
                    clsSharedHelper.WriteInfo("");
                else {
                    string str = JsonHelp.dataset2json(dt);
                    clsSharedHelper.WriteInfo("Successed:" + str);
                }
            }
            else {
                clsSharedHelper.WriteInfo("Error la:" + errInfo);
            }
        }
    }

    //加载文章列表 用于详情模式
    public void loadArticleList2(string lastid, string ssid)
    {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM())
        {
            string str_sql = @"select top 2 a.id,a.title,convert(varchar(5),a.createtime,110) createtime,isnull(p.imgfilename,'') imgurl,convert(varchar(20),a.createtime,102) cretime
                                from t_multiarticles a
                                inner join (select articleid from t_ArticleGroupLink where groupid=@ssid) b on a.id=b.articleid
                                left join (select parentid,min(imgid) imgid from t_articleblocks where blocktype='img' group by parentid) img on img.parentid=a.id
                                left join t_articleimages p on p.id=img.imgid
                                where a.isactive=1 ";
            DataTable dt = null;   
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@ssid", ssid));
            if (lastid != "0" && lastid != "") {
                str_sql += " and a.id<@lastid ";
                para.Add(new SqlParameter("@lastid", lastid));          
            }
            
            str_sql += " order by a.createtime desc";                                 
            string errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            if (errInfo == "")
            {
                if (dt.Rows.Count == 0)
                    clsSharedHelper.WriteInfo("");
                else
                {
                    string str = JsonHelp.dataset2json(dt);
                    clsSharedHelper.WriteInfo("Successed:" + str);
                }
            }
            else
            {
                clsSharedHelper.WriteInfo("Error:" + errInfo);
            }
        }
    }
    
    //加载文章数据
    public void loadArticle(string id) {
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            string str_sql = @"select a.id,a.title,a.author,convert(varchar(10),a.createtime,23) createtime,b.blocktype,b.blockcontent,b.blockorder,b.imgid,isnull(c.imgfilename,'') imgfile,a.viewtimes,a.sourcelink,a.needvalidate
                                from t_multiarticles a
                                inner join t_articleblocks b on a.id=b.parentid and b.ishide=0
                                left join t_articleimages c on b.imgid=c.id
                                where a.isactive=1 and a.id=@id order by b.blockorder;";
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@id", id));
            DataTable dt = null;
            string errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            if (errInfo == "")
            {
                if (dt.Rows.Count > 0){
                    for (int i = 0; i < dt.Rows.Count; i++) {
                        dt.Rows[i]["blockcontent"] = HttpUtility.UrlEncode(dt.Rows[i]["blockcontent"].ToString());
                    }
                    string str = JsonHelp.dataset2json(dt);                    
                    clsSharedHelper.WriteSuccessedInfo(str);
                }                    
                else
                    clsSharedHelper.WriteInfo("Warn");
            }
            else {
                clsSharedHelper.WriteErrorInfo(errInfo);
            }
        }    
    }    
    
    //保存、修改操作
    public void SaveModifyArticle(string jsonData,string id,string userid,string username) {        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
            clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(jsonData);
            List<clsJsonHelper> jhList = jh.GetJsonNodes("blockArray");
            string title = jh.GetJsonValue("title");
            string author = jh.GetJsonValue("author");
            string isValidate = jh.GetJsonValue("needvalidate");
            string sourcelink = HttpUtility.UrlDecode(jh.GetJsonValue("sourcelink"));
            StringBuilder strSQL = new StringBuilder();
            DataTable dt = null;
            string zSQL = "";
            if (id == "0" || id == "")
            {
                zSQL = @"declare @id int;
                     insert into t_multiarticles(title,author,createrid,creater,createtime,sourcelink,needvalidate) values ('{0}','{1}','{2}','{3}',getdate(),'{4}','{5}');
                     select @id=@@identity;";
                strSQL.Append(string.Format(zSQL, title, author, userid, username, sourcelink,isValidate));
            }
            else {
                zSQL = @"declare @id int;set @id={4};
                         update t_multiarticles set title='{0}',author='{1}',lasteditorid='{2}',lasteditorname='{3}',lasteditortime=getdate(),sourcelink='{5}',needvalidate='{6}' where id={4};
                         delete from t_articleblocks where parentid={4};";
                strSQL.Append(string.Format(zSQL, title, author, userid, username, id, sourcelink, isValidate));
            }
            string mSQL = @"insert into t_articleblocks(parentid,blocktype,blockcontent,blockorder,imgid,ishide) 
                                 values (@id,'{0}','{1}','{2}','{3}',{4});";            
            if (jhList.Count > 0)
            {                
                for (int i = 0; i < jhList.Count; i++) {
                    string content = HttpUtility.UrlDecode(jhList[i].GetJsonValue("content"));
                    strSQL.Append(string.Format(mSQL, jhList[i].GetJsonValue("type"), content, jhList[i].GetJsonValue("xh"), jhList[i].GetJsonValue("imgid"), jhList[i].GetJsonValue("ishide")));
                }
            }
            strSQL.Append("select @id;");
            string errInfo = dal.ExecuteQuery(strSQL.ToString(), out dt);
            if (errInfo == "" && dt.Rows.Count > 0)
                clsSharedHelper.WriteSuccessedInfo(dt.Rows[0][0].ToString());
            else {
                writeLog(strSQL.ToString());
                clsSharedHelper.WriteErrorInfo(errInfo);
            }                
        }        
    }
    
    public string UploadImageMain(HttpContext context,string sourceName) {
        string rtMsg = "";      
        context.Response.ContentType = "text/html";
        
        HttpPostedFile postedFile = context.Request.Files[0];
        string savePath = "../Resource/Image/" + DateTime.Now.ToString("yyyyMMdd") + "/";
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
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM()) {
                        string str_sql = @"insert into t_ArticleImages(imgpath,imgfilename,imgsourcename,createtime)
                                            values(@savepath,@filename,@sourcename,getdate());
                                            select @@identity;";
                        DataTable dt = null;
                        //去掉相对路径中的../
                        fileName = fileName.Substring(3);
                        List<SqlParameter> paras = new List<SqlParameter>();
                        paras.Add(new SqlParameter("@savepath", savePath.Substring(3)));
                        paras.Add(new SqlParameter("@filename", fileName));
                        paras.Add(new SqlParameter("@sourcename", sourceName));

                        string errInfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                        if (errInfo == "" && dt.Rows.Count>0)
                        {
                            rtMsg = "Succeed|" + fileName + "|" + dt.Rows[0][0].ToString();
                        }
                        else {
                            rtMsg = "Error:文件保存成功但是写入数据库失败：" + errInfo;
                        }
                    }
                                        
                }
                else {
                    rtMsg = "Error:" + fileName;
                }                
            }
            catch (Exception ex)
            {
                rtMsg = "Error:" + ex.Message;
            }
        }
        else
            rtMsg = "Error:文件大小超过限制！";

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

    //写日志文件方法
    public static void writeLog(string info)
    {
        try
        {
            clsLocalLoger.logDirectory = HttpContext.Current.Server.MapPath("logs/");
            if (System.IO.Directory.Exists(clsLocalLoger.logDirectory) == false)
            {
                System.IO.Directory.CreateDirectory(clsLocalLoger.logDirectory);
            }
            clsLocalLoger.WriteInfo(info);
        }
        catch (Exception ex)
        {

        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta charset="utf-8" />
    <title></title>    
</head>
<body>
    <form id="form1" runat="server">   
    </form>
</body>
</html>
