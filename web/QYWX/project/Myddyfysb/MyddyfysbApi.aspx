<%@ Page Language="C#" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Class_TLtools" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    private string tzid = "", userName = "";
    Encoding encoding = Encoding.UTF8;  //编码
    LiLanzDAL db;

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ClearHeaders();
        Response.AppendHeader("Access-Control-Allow-Origin", "*");
        string requestHeaders = Request.Headers["Access-Control-Request-Headers"];
        Response.AppendHeader("Access-Control-Allow-Headers", string.IsNullOrEmpty(requestHeaders) ? "*" : requestHeaders);
        Response.AppendHeader("Access-Control-Allow-Methods", "POST, GET,OPTIONS");
        try
        {
            string method = Request["method"] == null ? "" : Request["method"].ToString();  //操作
            if (string.IsNullOrEmpty(method))
            {
                getYfysbList();
            }
            else if (method.Equals("getYfysbList", StringComparison.OrdinalIgnoreCase))
            {
                getYfysbList();
            }
            else if (method.Equals("getYfysbInfo", StringComparison.OrdinalIgnoreCase))
            {
                string id = Request["id"] == null ? "" : Request["id"].ToString();
                getYfysbInfo(id);
            }
            else if (method.Equals("getKhList", StringComparison.OrdinalIgnoreCase))
            {
                getKhList();
            }
            else if (method.Equals("getYslxList", StringComparison.OrdinalIgnoreCase))
            {
                getYslxList();
            }
            else if (method.Equals("saveYfysbInfo", StringComparison.OrdinalIgnoreCase))
            {
                string strInfo = Request["info"] == null ? "" : Request["info"].ToString();
                saveYfysbInfo(strInfo);
            }
            else if (method.Equals("saveImg", StringComparison.OrdinalIgnoreCase))
            {
                HttpPostedFile img = Request.Files["img"];
                string mxid = Request["mxid"] == null ? "" : Request["mxid"].ToString();
                saveImg(img, mxid);
            }
            else if (method.Equals("delImg", StringComparison.OrdinalIgnoreCase))
            {
                string id = Request["id"] == null ? "" : Request["id"].ToString();
                string mxid = Request["mxid"] == null ? "" : Request["mxid"].ToString();
                delImg(id, mxid);
            }
            else if (method.Equals("getImgList", StringComparison.OrdinalIgnoreCase))
            {
                string mxid = Request["mxid"] == null ? "" : Request["mxid"].ToString();
                getImgList(mxid);
            }
            else if (method.Equals("flowStart", StringComparison.OrdinalIgnoreCase))
            {
                string id = Request["id"] == null ? "" : Request["id"].ToString();
                flowStart(id);
            }
            else
            {
                respMsg(201, "操作方法名称错误！");
                return;
            }
        }
        catch (Exception ex)
        {
            respMsg(201, ex.Message);
            CreateErrorMsg(ex.Message + ex.StackTrace);
        }
    }

    public void saveImg(HttpPostedFile img, string mxid)
    {
        if (!checkLogin())
        {
            respMsg(201, "请先登录！");
            return;
        }
        if (img == null)
        {
            respMsg(201, "请选择图片！");
            return;
        }
        if (string.IsNullOrEmpty(mxid) || int.Parse(mxid) < 1)
        {
            respMsg(201, "mxid不能为空！");
            return;
        }
        string fileName = getFileName();
        string filepath = "MyUpload/" + DateTime.Now.ToString("yyyyMM") + "/" + fileName + ".jpg";
        img.SaveAs(Server.MapPath("/" + filepath));
        Response.Charset = "UTF-8";
        Response.ContentEncoding = Encoding.UTF8;
        if (!File.Exists(Server.MapPath("/" + filepath)))
        {
            respMsg(201, "图片保存失败，请重试！");
            return;
        }
        //插入附件表
        string sql = "";
        sql += " INSERT dbo.t_uploadfile";
        sql += " ( TableID , GroupName ,GroupID ,URLAddress ,CreateDate ,FileName ,createname ,tplx ,cip)";
        sql += " VALUES  (" + mxid + ", '' , 21840 , N'../" + filepath + "' ,GETDATE() , N'" + img.FileName + "' ,'' , NULL ,NULL);";
        sql += " SELECT SCOPE_IDENTITY() id;";
        db = new LiLanzDAL(tzid);
        DataTable dt = db.ExecuteDataTable(sql);
        string id = (dt.Rows[0]["id"] == null ? "" : dt.Rows[0]["id"].ToString());
        if (string.IsNullOrEmpty(id) || int.Parse(id) < 1)
        {
            respMsg(201, "图片上传失败，请重试！");
            return;
        }
        respMsg(200, "上传成功！");
    }

    public void delImg(string id, string mxid)
    {
        if (!checkLogin())
        {
            respMsg(201, "请先登录！");
            return;
        }
        if (string.IsNullOrEmpty(id) || int.Parse(id) < 1)
        {
            respMsg(201, "图片id不能为空！");
            return;
        }
        if (string.IsNullOrEmpty(mxid) || int.Parse(mxid) < 1)
        {
            respMsg(201, "mxid不能为空！");
            return;
        }
        string sql = " DELETE t_uploadfile WHERE id = " + id + " AND TableID = " + mxid + " AND GroupID = 21840;";
        //CreateErrorMsg(sql);
        db = new LiLanzDAL(tzid);
        db.ExecuteNonQuery(sql);
        respMsg(200, "删除成功！");
    }

    /// <summary>
    /// 获取文件名
    /// </summary>
    /// <returns>文件名</returns>
    public string getFileName()
    {
        Random rd = new Random();
        StringBuilder serial = new StringBuilder();
        serial.Append(DateTime.Now.ToString("yyyyMMddHHmmssff"));
        serial.Append(rd.Next(0, 999999).ToString());
        return serial.ToString();
    }

    /// <summary>
    /// 获取主列表
    /// </summary>
    public void getYfysbList()
    {
        if (!checkLogin())
        {
            respMsg(201, "请先登录！");
            return;
        }
        string zdr = userName;
        if (string.IsNullOrEmpty(zdr))
        {
            respMsg(201, "制单人不能为空！");
            return;
        }
        string sql = @"  
 select a.id,a.flowid,a.khid,a.mdid,a.tzid,a.zdr,a.zdrq,kh.khmc as khmc,(SELECT SUM(bxje) FROM zw_t_mdyfymx WHERE id = a.id) as je,a.ny,a.djh,CONVERT(VARCHAR(10),a.rq,120) rq,a.bz  
 from zw_t_mdyfyb a 
 inner join dbo.YX_T_Khb kh ON a.khid = kh.khid 
 where a.djlx='12323' and a.shbs='0' AND a.zdr = '" + zdr + "' order by a.rq desc,a.djh desc;  ";
        db = new LiLanzDAL(tzid);
        DataTable dt = db.ExecuteDataTable(sql);
        respMsg(200, "成功！", dt);
    }

    /// <summary>
    /// 获取单据信息
    /// </summary>
    /// <param name="id">单据id</param>
    public void getYfysbInfo(string id)
    {
        if (!checkLogin())
        {
            respMsg(201, "请先登录！");
            return;
        }
        if (string.IsNullOrEmpty(id))
        {
            respMsg(201, "单据id不能为空！");
            return;
        }
        //表头
        string sql = @"  
        select a.id,CONVERT(VARCHAR(10),a.rq,120) rq,a.ny,a.khid from zw_t_mdyfyb a where a.id = " + id + ";  ";
        db = new LiLanzDAL(tzid);
        DataTable dtMain = db.ExecuteDataTable(sql);
        //分录
        sql = @"  
        select b.mxid,b.zy,b.bxje,b.fjs,b.bz,
        b.rcje,b.zgje,b.tmje,b.xkdje,b.zpje,b.yslx, 
        ROW_NUMBER()OVER(ORDER BY mxid) AS xh,b.creator,CONVERT(VARCHAR(10),b.createDate,120) createDate
        FROM  zw_t_mdyfyb a
        INNER JOIN dbo.zw_T_mdyfymx b ON a.id=b.id
        where a.id=" + id + ";  ";
        DataTable dtDetail = db.ExecuteDataTable(sql);
        respMsg(200, "成功！", dtMain, dtDetail);
    }

    public void getImgList(string mxid)
    {
        if (!checkLogin())
        {
            respMsg(201, "请先登录！");
            return;
        }
        if (string.IsNullOrEmpty(mxid) || int.Parse(mxid) < 1)
        {
            respMsg(201, "mxid不能为空！");
            return;
        }
        //图片列表
        string sql = @"  
        SELECT id, filename mc, URLAddress path FROM t_uploadfile WHERE TableID = " + mxid + " AND GroupID = 21840; ";
        db = new LiLanzDAL(tzid);
        DataTable dt = db.ExecuteDataTable(sql);
        respMsg(200, "成功！", dt);
    }

    /// <summary>
    /// 获取当前客户，及下属客户
    /// </summary>
    public void getKhList()
    {
        if (!checkLogin())
        {
            respMsg(201, "请先登录！");
            return;
        }
        string sql = @"  
      select b.gxid id,b.gxmc mc
      from yx_t_khb a inner join YX_v_khgxb b on (b.ccid+'-' like a.ccid+'-%')
      where a.khid=" + tzid + " and b.gxty=0; ";
        db = new LiLanzDAL(tzid);
        DataTable dt = db.ExecuteDataTable(sql);
        respMsg(200, "成功！", dt);
    }

    /// <summary>
    /// 获取类型
    /// </summary>
    public void getYslxList()
    {
        if (!checkLogin())
        {
            respMsg(201, "请先登录！");
            return;
        }
        string sql = @"  
      select id,mc from zw_v_ysfylb; ";
        db = new LiLanzDAL(tzid);
        DataTable dt = db.ExecuteDataTable(sql);
        respMsg(200, "成功！", dt);
    }

    public void saveYfysbInfo(string strInfo)
    {
        JObject joInfo = JsonConvert.DeserializeObject<JObject>(strInfo);
        if (joInfo == null)
        {
            respMsg("201", "单据信息不能为空！");
            return;
        }
        joInfo = (JObject)joInfo.GetValue("info", StringComparison.OrdinalIgnoreCase);
        JObject joMain = (JObject)joInfo.GetValue("main", StringComparison.OrdinalIgnoreCase);
        if (joMain == null)
        {
            respMsg("201", "主表信息不能为空！");
            return;
        }
        string id = (string)joInfo.GetValue("id", StringComparison.OrdinalIgnoreCase);
        string ny = (string)joInfo.GetValue("ny", StringComparison.OrdinalIgnoreCase);
        string rq = (string)joInfo.GetValue("rq", StringComparison.OrdinalIgnoreCase);
        string khid = (string)joInfo.GetValue("khid", StringComparison.OrdinalIgnoreCase);
        string strsql = "";
        strsql += "declare @id int;";
        if (id == "0")
        {
            strsql += "  declare @djh varchar(6); ";
            strsql += " set @djh=(select  cast(isnull(max(djh),100001) as int) + 1 from zw_t_mdyfyb where ny='" + ny + "'); ";
            strsql += "insert into zw_t_mdyfyb (tzid,djh,djlx,khid,mdid,zdr,zdrq,shr,shrq,shbs,ny,flowid,rq) values ";
            strsql += " (" + tzid + ",@djh,12323," + khid + ",0,'" + userName + "',getdate(),'" + userName + "',getdate(),0,'" + ny + "',579,'" + rq + "');";
            strsql += " set @id=scope_identity();";
        }
        else
        {
            strsql += " set @id=" + id + ";";
            strsql += " update zw_t_mdyfyb set xgr='" + userName + "',xgrq=getdate() where id=@id ;";
        }


        JArray jaDetail = (JArray)joInfo.GetValue("detail", StringComparison.OrdinalIgnoreCase);
    }

    public void flowStart(string id)
    {
        if (!checkLogin())
        {
            respMsg(201, "请先登录！");
            return;
        }
        if (string.IsNullOrEmpty(id) || int.Parse(id) < 1)
        {
            respMsg(201, "图片id不能为空！");
            return;
        }
        string sql = " DELETE fl_t_flowRelation WHERE dxid = " + id + " AND flowid = 579 AND flag = 0; ";
        sql += " EXEC dbo.flow_up_start " + tzid + "," + tzid + "," + id + ",'',579,0,'" + userName + "',''; ";
        db = new LiLanzDAL(tzid);
        DataTable dt = db.ExecuteDataTable(sql);
        string strDocid = dt == null || dt.Rows[0] == null ? "0" : dt.Rows[0]["state"].ToString();
        int intDocid = 0;
        if (!int.TryParse(strDocid, out intDocid) || intDocid < 1)
        {
            respMsg(201, "流程发起失败，请重试！");
            return;
        }
        Dictionary<string, string> dic = new Dictionary<string, string>();
        dic.Add("tzid", tzid);
        dic.Add("docid", strDocid);
        dic.Add("dxid", id);
        dic.Add("flowid", "579");
        respMsg(200, "成功！", dic, null);
    }

    /// <summary>
    /// 发送信息
    /// </summary>
    /// <param name="code">代码</param>
    /// <param name="msg">信息</param>
    public void respMsg(Object code, Object msg)
    {
        Dictionary<string, Object> dicRes = new Dictionary<string, Object>();
        dicRes.Add("code", code);
        dicRes.Add("msg", msg);
        byte[] bytes = encoding.GetBytes(JsonConvert.SerializeObject(dicRes));
        HttpResponse hr = HttpContext.Current.Response;
        hr.Clear();
        hr.OutputStream.Write(bytes, 0, bytes.Length);
        hr.OutputStream.Close();
    }

    /// <summary>
    /// 发送信息
    /// </summary>
    /// <param name="code">代码</param>
    /// <param name="msg">信息</param>
    /// <param name="list">列表</param>
    public void respMsg(Object code, Object msg, Object list)
    {
        Dictionary<string, Object> dicRes = new Dictionary<string, Object>();
        dicRes.Add("code", code);
        dicRes.Add("msg", msg);
        dicRes.Add("list", list);
        byte[] bytes = encoding.GetBytes(JsonConvert.SerializeObject(dicRes));
        HttpResponse hr = HttpContext.Current.Response;
        hr.Clear();
        hr.OutputStream.Write(bytes, 0, bytes.Length);
        hr.OutputStream.Close();
    }

    /// <summary>
    /// 发送信息（表头、表体）
    /// </summary>
    /// <param name="code">代码</param>
    /// <param name="msg">信息</param>
    /// <param name="main">表头</param>
    /// <param name="detail">表体</param>
    public void respMsg(Object code, Object msg, Object main, Object detail)
    {
        Dictionary<string, Object> dicInfo = new Dictionary<string, Object>();
        dicInfo.Add("main", main);
        dicInfo.Add("detail", detail);
        Dictionary<string, Object> dicRes = new Dictionary<string, Object>();
        dicRes.Add("code", code);
        dicRes.Add("msg", msg);
        dicRes.Add("info", dicInfo);
        byte[] bytes = encoding.GetBytes(JsonConvert.SerializeObject(dicRes));
        HttpResponse hr = HttpContext.Current.Response;
        hr.Clear();
        hr.OutputStream.Write(bytes, 0, bytes.Length);
        hr.OutputStream.Close();
    }

    /// <summary>
    /// 检查登录，获取tzid,userName
    /// </summary>
    /// <returns>true:已登录 false:未登录</returns>
    public bool checkLogin()
    {
        string strApptoken = Request["apptoken"] == null ? "" : Request["apptoken"].ToString();
        if (Session["tzid"] == null || Session["username"] == null)
        {
            JObject joLoginInfo = getLoginInfo(strApptoken);
            if (joLoginInfo == null)
            {
                return false;
            }
            Session["tzid"] = tzid = (string)joLoginInfo.GetValue("tzid", StringComparison.OrdinalIgnoreCase);
            Session["username"] = userName = (string)joLoginInfo.GetValue("xm", StringComparison.OrdinalIgnoreCase);
        }
        //tzid = Session["userssid"].ToString();
        //userName = Session["qy_cname"].ToString();
        //userName = "鄞娟娟";
        //tzid = "12193";   //Session 没有传tzid，先取总部的
        //CreateErrorMsg("tzid=" + tzid + "  ,userName=" + userName);
        //userName = "管祖才";
        return true;
    }

    /// <summary>
    /// 获取用户登录用户信息
    /// </summary>
    /// <param name="strApptoken">apptoken</param>
    /// <returns>用户信息json对象</returns>
    public JObject getLoginInfo(string strApptoken)
    {
        if (string.IsNullOrEmpty(strApptoken)) return null;
        string strUrl = "http://10.0.0.15/oa/api/appmycore.ashx?action=MyRecordInfo&apptoken=" + strApptoken;
        string strRtn = webRequest(strUrl);
        JObject jo = JsonConvert.DeserializeObject<JObject>(strRtn);
        if (jo == null) return null;
        string strCode = (string)jo.GetValue("code", StringComparison.OrdinalIgnoreCase);
        string strMsg = (string)jo.GetValue("msg", StringComparison.OrdinalIgnoreCase);
        if (strCode != "200")
        {
            respMsg("201", strMsg);
            return null;
        }
        JArray ja = (JArray)jo.GetValue("info", StringComparison.OrdinalIgnoreCase);
        if (ja == null || ja.Count < 1)
        {
            respMsg("201", "获取登录信息失败！");
            return null;
        }
        return (JObject)ja[0];
    }

    public void CreateErrorMsg(string message)
    {
        //LogHelper.Info(message);

        string m_fileName = Request.MapPath("systemlog.txt");
        if (File.Exists(m_fileName))
        {
            StreamWriter sr = File.AppendText(m_fileName);
            sr.Write("\n");
            sr.WriteLine(DateTime.Now.ToString() + " " + message);
            sr.Close();
        }
        else
        {
            ///创建日志文件
            StreamWriter sr = File.CreateText(m_fileName);
            sr.WriteLine(DateTime.Now.ToString() + " " + message);
            sr.Close();
        }

    }

    /// <summary>
    /// 访问指定url页面
    /// </summary>
    /// <param name="url">url</param>
    /// <returns>输出结果</returns>
    public string webRequest(string url)
    {
        WebRequest req = WebRequest.Create(url);
        //超时时间设成10秒
        //req.Timeout = 10000;
        WebResponse resp = req.GetResponse();
        Stream stream = resp.GetResponseStream();
        StreamReader sr = new StreamReader(stream, encoding);
        return sr.ReadToEnd();
    }
</script>
