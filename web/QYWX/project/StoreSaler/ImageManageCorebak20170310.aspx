<%@ Page Language="C#" Debug="true"  %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Globalization" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    string WXDBConnStr ="";// "server=192.168.35.23;uid=lllogin;pwd=rw1894tla;database=weChatTest";
    string OADBConnStr ="";// "server=192.168.35.23;uid=lllogin;pwd=rw1894tla;database=tlsoft";

    private int MapWidth = 0;  //上传图片时会对这两个值赋值。这两个值仅在上传 门店平面图 的时候使用
    private int MapHeight = 0;
    private int MsgAgentID = 0; //消息提醒企业号应用ID
    protected void Page_Load(object sender, EventArgs e)
    {
        WXDBConnStr = clsConfig.GetConfigValue("WXConnStr");
        OADBConnStr = clsConfig.GetConfigValue("OAConnStr");
        Response.ContentEncoding = System.Text.Encoding.GetEncoding("utf-8");
        Request.ContentEncoding = System.Text.Encoding.GetEncoding("utf-8");
        
        string RoleName = Convert.ToString(Session["RoleName"]);
        string userid = Convert.ToString(Session["qy_customersid"]);
        string mdid = Convert.ToString(Session["mdid"]);
        string tzid = Convert.ToString(Session["tzid"]);
        string username = Convert.ToString(Session["qy_cname"]);


        string testflag = Convert.ToString(Request.Params["testflag"]);
        if (testflag == "usetest")
        {
            RoleName = "zb";
            userid = "6097";
            mdid = "0";
            tzid = "0";
            username = "林文印";
            WXDBConnStr = "server=192.168.35.62;database=weChatPromotion;uid=erpUser;pwd=fjKL29ji.353";
            OADBConnStr = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
        }
        
        string rt = "", ctrl, id,cid,rotating,ImageData;
        ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "SaveImgMDRemark":
                id = Convert.ToString(Request.Params["id"]);
                string remark = Convert.ToString(Request.Params["remark"]);
                SaveImgMDRemark(id, remark);
                break;
            case "SaveImageResult":
                SaveImageResult();
                break;
            case "SubmitStoreImg":
                SubmitStoreImg();
                break;
            case "CreateImageForMD":
                //增加参数：
                string isImgMap = Convert.ToString(Request.Params["isImgMap"]);
                if (string.IsNullOrEmpty(isImgMap) == false && isImgMap == "1") CreateImageForMap();
                else CreateImageForMD();
                break;
            case "LoadStoreImgInfoForMD":
                LoadStoreImgInfoForMD();
                break;
            case "SaveStoreImgInfo":
                id = Convert.ToString(Request.Params["id"]);
                cid = Convert.ToString(Request.Params["cid"]);
                string Info = Convert.ToString(Request.Params["Info"]);
                SaveStoreImgInfo(id,cid,Info);
                break;
            case "DeleteImage":
                string Imgid = Convert.ToString(Request.Params["Imgid"]);
                DeleteImage(Imgid);
                break;
            case "CreateImage":
                rotating = Convert.ToString(Request.Params["rotating"]);
                ImageData = Convert.ToString(Request.Params["ImageData"]);
                id = Convert.ToString(Request.Params["id"]);
                cid = Convert.ToString(Request.Params["cid"]);                
                string IsMust = Convert.ToString(Request.Params["ismust"]);
                if (string.IsNullOrEmpty(IsMust))
                {
                    IsMust = "0";
                }
                saveMyImgs(ImageData, cid, rotating, id, IsMust, tzid, username);
                break;
            case "LoadStoreImgInfo":
                id = Convert.ToString(Request.Params["id"]);
                LoadStoreImgInfo(id);
                break;
            case "LoadStoreImgMxInfo":
                id = Convert.ToString(Request.Params["Infoid"]);
                LoadStoreImgMxInfo(id);
                break;
            case "LoadStoreListForMD":
                LoadStoreListForMD();
                break;
            case "SendStoreList":
                SendStoreList(username);
                break;
            case "LoadStoreList":
                LoadStoreList();
                break;
            case "LoadCompanyList":
                LoadCompanyList(userid);
                break;
            case "LoadStoreImgs":
                mdid = Convert.ToString(Request.Params["mdid"]);
                LoadStoreImgs(RoleName, userid, mdid);
                break;
            case "version": rt = "version 1.0";
                break;
            default: rt = clsNetExecute.Error + "传入参数有误！";
                break;
        }

        //if (rt.IndexOf(clsNetExecute.Error) > -1)
        //{
        //    clsLocalLoger.Log(Request.Url.AbsolutePath + "  " + rt);
        //    rt = clsNetExecute.Error+"网络出错了!";
        //}
        if (!string.IsNullOrEmpty(rt))
        {
            clsSharedHelper.WriteInfo(rt);
        }
       
    }

    private void SaveImgMDRemark(string id,string remark)
    {
        string errInfo, mysql;
        mysql = "UPDATE wx_t_StoreImgMXForMD SET Remark=@remark WHERE id=@id";
        List<SqlParameter> paras=new List<SqlParameter>();
        paras.Add(new SqlParameter("@remark", HttpUtility.UrlDecode(remark)));
        paras.Add(new SqlParameter("@id",id));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo == "")
                clsSharedHelper.WriteSuccessedInfo("");
            else
                clsSharedHelper.WriteErrorInfo("");
        }
    }
    
    /// <summary>
    /// 提交审批意见
    /// </summary>
    private void SaveImageResult()
    {
        string cid = Convert.ToString(Request.Params["cid"]);
        string infoid = Convert.ToString(Request.Params["infoid"]);
        string Status = Convert.ToString(Request.Params["Status"]);
        string remark = Convert.ToString(Request.Params["remark"]);
        string MdImgID = Convert.ToString(Request.Params["MdImgID"]);
        string cname = Convert.ToString(Request.Params["cname"]);

        string errInfo, mysql,rt;
        mysql = @"UPDATE wx_t_StoreImgMxForMD SET Status=@Status,FailMsg=@FailMsg WHERE MdImgID=@MdImgID AND InfoID=@InfoID;
                DECLARE @Totalstatus INT;
                SELECT @Totalstatus = MIN(status*ABS(status)) FROM wx_t_StoreImgMxForMD WHERE MdImgID=@MdImgID ;
                UPDATE wx_t_StoreImgForMD SET status=@Totalstatus,AuditTime=GETDATE(),AuditID=@userid,AuditName=@username WHERE id=@MdImgID; 
                select @Totalstatus";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@Status", Status));
        paras.Add(new SqlParameter("@FailMsg", remark));
        paras.Add(new SqlParameter("@MdImgID", MdImgID));
        paras.Add(new SqlParameter("@InfoID", infoid));
        paras.Add(new SqlParameter("@userid", cid));
        paras.Add(new SqlParameter("@username", cname));

        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras,out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }
            rt = clsNetExecute.Successed;
            if (Math.Abs(Convert.ToInt32(dt.Rows[0][0])) == 1)
            {
                mysql = @"SELECT  SUM(CASE WHEN status=1 THEN 1 ELSE 0 END) AS Through, SUM(CASE WHEN status=-1 THEN 1 ELSE 0 END) AS NotThrough  
                          FROM wx_t_StoreImgMxForMD WHERE MdImgID=@MdImgID AND InfoID=@InfoID ";
                clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
                paras.Clear();
                paras.Add(new SqlParameter("@MdImgID", MdImgID));
                paras.Add(new SqlParameter("@InfoID", infoid));
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "")
                {
                    rt = errInfo;
                }else
                rt = clsNetExecute.Successed + string.Format("|该门店的形象册已审毕。通过:{0}，未通过：{1}。", dt.Rows[0]["Through"], dt.Rows[0]["NotThrough"]);
            }
            
            /*审核不通过，发送消息给上传者,agentid=0 消息中心*/
            if (Status == "-1")
            {
                mysql = "SELECT b.name FROM dbo.wx_t_StoreImgForMD a INNER JOIN dbo.wx_t_customers b ON a.CreateID = b.ID WHERE  a.id=@MdImgID";
                paras.Clear();
                paras.Add(new SqlParameter("@MdImgID", MdImgID));
                clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo == "" || dt.Rows.Count > 0)
                {
                    clsWXHelper.SendQYMessage(Convert.ToString(dt.Rows[0]["name"]), MsgAgentID, "您有形象册未通过审核,请及时查看后重新上传");

                    clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
                }
                clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
            }
            clsSharedHelper.WriteInfo(rt);
        } 
    }
    /// <summary>
    /// 门店提交审核
    /// </summary>
    private void SubmitStoreImg()
    {
        string pid = Convert.ToString(Request.Params["pid"]);
        string cid = Convert.ToString(Request.Params["cid"]);
        string cname = Convert.ToString(Request.Params["cname"]);
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string errInfo, mysql;

        mysql = @"SELECT COUNT(1) sl 
                FROM wx_t_StoreImgMx a 
                INNER JOIN wx_t_StoreImgForMD b ON a.pid=b.pid AND b.mdid=@mdid
                LEFT JOIN wx_t_StoreImgMxForMD c ON b.id=c.MdImgID AND a.id=c.InfoID
                WHERE a.pid=@pid AND a.IsMust=1 AND ISNULL(c.id,0)=0";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@pid", pid));
        paras.Add(new SqlParameter("@mdid", mdid));
        DataTable dt = null;
      
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);

            if (errInfo != "")
                clsSharedHelper.WriteErrorInfo(errInfo);
            else
            {
                if (Convert.ToInt32(dt.Rows[0]["sl"]) > 0)
                {
                    clsSharedHelper.WriteErrorInfo("还有必须上传的形象册未上传，不能提交审核");
                    return;
                }
                clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
            }
            
            mysql = "UPDATE wx_t_StoreImgForMD SET IsSubmit=1,SUbmitTime=GETDATE(),SubmitID=@SubmitID,SubmitName=@SubmitName WHERE pid=@pid and mdid=@mdid";
            paras.Clear();
            paras.Add(new SqlParameter("@SubmitID", cid));
            paras.Add(new SqlParameter("@SubmitName", cname));
            paras.Add(new SqlParameter("@pid", pid));
            paras.Add(new SqlParameter("@mdid", mdid));
          
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
        }
        clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
        if (errInfo != "")
        {
            clsSharedHelper.WriteErrorInfo(errInfo);
        }
        else
        {
            clsSharedHelper.WriteSuccessedInfo("");
        }
    }
    
    /// <summary>
    /// 门店上传图片
    /// </summary>
    private void CreateImageForMD()
    {
        string CreateID = Convert.ToString(Request.Params["cid"]);
        string infoid = Convert.ToString(Request.Params["infoid"]);
        string rotate = Convert.ToString(Request.Params["rotating"]);
        string PicBase = Convert.ToString(Request.Params["ImageData"]);
        string MdImgID = Convert.ToString(Request.Params["MdImgID"]); //表wx_t_StoreImgForMD的ID

        string rt = "", mysql;
        DataTable dt = null;
        string myFolder = DateTime.Now.ToString("yyyyMM");
        string pathStr = "upload/ImageManage/" + myFolder + "/";
        string path = HttpContext.Current.Server.MapPath("~/" + pathStr);
        string myPath = HttpContext.Current.Server.MapPath("~/" + pathStr + "my/");
        String strPath = Path.GetDirectoryName(path);
        String filename = CreateID + DateTime.Now.ToString("yyyyMMddHHmmssfff") + ".jpg";

        if (!Directory.Exists(strPath))
        {
            Directory.CreateDirectory(strPath);
        }

        rt = Base64StringToImage(ref PicBase, path, filename, rotate);
        PicBase = "";   //回收资源
        if (rt != "")
        {
            clsSharedHelper.WriteErrorInfo(rt);
            return;
        }
        strPath = Path.GetDirectoryName(myPath);
        if (!Directory.Exists(strPath))
        {
            Directory.CreateDirectory(strPath);
        }
        rt = MakeImage(path + filename, myPath + filename, 100);

        if (rt != "")
        {
            clsSharedHelper.WriteErrorInfo(rt);
            return;
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            mysql = @"insert into wx_t_uploadfile(SourceTableID,TypeID,URLAddress,ThumbnailURL,CreateTime,FileName,CreateCustomerID) 
                      values(@SourceTableID,@TypeID,@URLAddress,@ThumbnailURL,getdate(),@FileName,@CreateCustomerID); select @@identity";
            paras.Add(new SqlParameter("@SourceTableID", "0"));
            paras.Add(new SqlParameter("@TypeID", "3"));
            paras.Add(new SqlParameter("@URLAddress", pathStr));
            paras.Add(new SqlParameter("@ThumbnailURL", pathStr + "my/"));
            paras.Add(new SqlParameter("@FileName", filename));
            paras.Add(new SqlParameter("@CreateCustomerID", CreateID));
            rt = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (rt != "")
            {
                clsSharedHelper.WriteErrorInfo(rt);
                return;
            }
            string Imgid = Convert.ToString(dt.Rows[0][0]);
            paras.Clear();


            mysql = @"DECLARE @Imgid int;DECLARE @url varchar(200); SELECT  @Imgid=Imgid,@url=AddressURL FROM wx_t_StoreImgMxForMD WHERE InfoID=@InfoID and MdImgID=@MdImgID;
                      DELETE wx_t_StoreImgMxForMD WHERE InfoID=@InfoID and MdImgID=@MdImgID; 
                      SELECT ISNULL(@Imgid,0) AS Imgid,isnull(@url,'') as url  ";
            paras.Add(new SqlParameter("@InfoID", infoid));
            paras.Add(new SqlParameter("@MdImgID", MdImgID));
            rt = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (rt != "")
            {
                clsSharedHelper.WriteErrorInfo(rt);
            }

            if (Convert.ToString(dt.Rows[0]["Imgid"]) != "0")
            {
                clearImage(Convert.ToString(dt.Rows[0]["url"]));
                clearImage(Convert.ToString(dt.Rows[0]["url"]).Replace("my/",""));
            }

            mysql = string.Format("INSERT INTO wx_t_StoreImgMxForMD(Pid,Infoid,Imgid,AddressURL,MdImgID) SELECT  pid,id,{0},'{1}',{2} FROM wx_t_StoreImgMx WHERE ID={3};select @@identity;",
                Imgid, pathStr + "my/" + filename, MdImgID,infoid);
            rt = dal.ExecuteQuery(mysql,out dt);

            if (rt != "")
            {
                clsSharedHelper.WriteErrorInfo(rt);
            }
            else
            {
                clsSharedHelper.WriteInfo(string.Format(@"{{""infoid"":""{0}"",""Imgid"": ""{1}"",""url"": ""{2}"",""id"":""{3}""}}", infoid, Imgid, pathStr + "my/" + filename,dt.Rows[0][0]));
            }
        }
    }

    /// <summary>
    /// 上传门店地图
    /// </summary>
    private void CreateImageForMap()
    {
        HttpContext hc = HttpContext.Current;

        string RoleName = Convert.ToString(hc.Session["RoleName"]);
        string CreateID = Convert.ToString(hc.Session["qy_customersid"]);
        string CreateName = Convert.ToString(hc.Session["qy_cname"]);
        if (string.IsNullOrEmpty(RoleName) || string.IsNullOrEmpty(CreateID))
        {
            clsSharedHelper.WriteErrorInfo("访问超时，请重新登录！");
            return;
        }
        else if (RoleName != "dz")
        {
            clsSharedHelper.WriteErrorInfo("必须进入门店管理模式，才能自行上传&创建平面图！");
            return;
        }
         

        string strInfo = "";
        string MdImgID = "", khid = "", mdid = "", Pid = "", AddressURL = "";
        string infoid = Convert.ToString(Request.Params["infoid"]);
        string rotate = Convert.ToString(Request.Params["rotating"]);
        string PicBase = Convert.ToString(Request.Params["ImageData"]);
        MdImgID = Convert.ToString(Request.Params["MdImgID"]); //表wx_t_StoreImgForMD的ID


        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {             
            //1 店铺形象册的信息
            string strSQL = @"  SELECT TOP 1 khid,mdid,Pid FROM wx_t_StoreImgForMD WHERE ID = @MdImgID";
            List<SqlParameter> param = new List<SqlParameter>();
            param.Add(new SqlParameter("@MdImgID", MdImgID));
            DataTable dt;
            strInfo = dal.ExecuteQuerySecurity(strSQL, param, out dt);
            if (strInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("加载陈列图信息失败！错误：", strInfo));
                return;        //直接结束                    
            }
            if (dt.Rows.Count == 0)
            { 
                clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
                clsSharedHelper.WriteErrorInfo(string.Concat("必须先上传陈列图！"));
                return;        //直接结束                            
            }
             
            khid = Convert.ToString(dt.Rows[0]["khid"]);
            mdid = Convert.ToString(dt.Rows[0]["mdid"]);
            Pid = Convert.ToString(dt.Rows[0]["Pid"]); 

            clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
            
            string rt = "";
            string pathStr = "upload/StoreSaler/xxgl/";
            string path = HttpContext.Current.Server.MapPath("~/" + pathStr); 
            String strPath = Path.GetDirectoryName(path); 
            string MdMapName = "";  //门店平面图命名
            MdMapName = string.Concat("MDID", mdid, "_", DateTime.Now.ToString("yyyyMMddHHmmss") , ".gif");

            AddressURL = string.Concat(pathStr, MdMapName);
        
            if (!Directory.Exists(strPath))
            {
                Directory.CreateDirectory(strPath);
            }

            rt = Base64StringToImage(ref PicBase, path, MdMapName, rotate, System.Drawing.Imaging.ImageFormat.Gif);
            PicBase = "";   //回收资源
            if (rt != "")
            {
                clsSharedHelper.WriteErrorInfo(rt);
                return;
            }  
         
            //2 创建平面图对应的信息
            strSQL = @"INSERT INTO [wx_t_StoreImgMap]([MdImgID],[Pid],[khid],[mdid],[MapImageFileSrc],[MapImageWidth],[MapImageHeight],CreateID,CreateName,IsLoadInJmspb)
                                VALUES (@MdImgID,@Pid,@khid,@mdid,@MapImageFileSrc,@MapImageWidth,@MapImageHeight,@CreateID,@CreateName,@IsLoadInJmspb)";

            param.Clear();
            param.AddRange(new SqlParameter[]{ new SqlParameter("@MdImgID", MdImgID), 
                                                   new SqlParameter("@Pid", Pid), 
                                                   new SqlParameter("@khid", khid), 
                                                   new SqlParameter("@mdid", mdid), 
                                                   new SqlParameter("@MapImageFileSrc", AddressURL), 
                                                   new SqlParameter("@MapImageWidth", MapWidth), 
                                                   new SqlParameter("@MapImageHeight", MapHeight), 
                                                   new SqlParameter("@CreateID", CreateID), 
                                                   new SqlParameter("@CreateName", CreateName), 
                                                   new SqlParameter("@IsLoadInJmspb", "0")});
            strInfo = dal.ExecuteNonQuerySecurity(strSQL, param);
            if (strInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("自助启用上传的门店平面图失败！错误：", strInfo));
                return;        //直接结束                    
            }

            clsSharedHelper.WriteSuccessedInfo("");
        }
    }
    
    /// <summary>
    /// 加载门店形象册的信息
    /// </summary>
    /// <param name="id"></param>
    /// <param name="mdid"></param>
    private void LoadStoreImgInfoForMD()
    {
        string id = Convert.ToString(Request.Params["id"]);
        string mdid = Convert.ToString(Request.Params["mdid"]);

        string errInfo, mysql;
        mysql = @"SELECT a.id,a.infoid,a.Imgid,a.AddressURL AS url,a.Status,a.FailMsg,a.Remark
                    FROM wx_t_StoreImgMxForMD a INNER JOIN wx_t_StoreImgForMD b ON b.id=a.MdImgID WHERE b.pid=@id and b.mdid=@mdid ORDER BY a.infoid asc ";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@id",id));
        paras.Add(new SqlParameter("@mdid", mdid));
        DataTable dt;
      
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }

            foreach (DataRow dr in dt.Rows)
            {
                dr["Remark"] = HttpUtility.UrlEncode(dr["Remark"].ToString());
            }

            using (clsJsonHelper json = clsJsonHelper.CreateJsonHelper(DataTableToJson("List", dt)))
            {
                clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
                mysql = "select id,pid,CreateName AS Creator,SubmitTime AS  SendTime,CreateTime UpdateTime,Status,CASE WHEN submitID=0 THEN 0 ELSE 1 END  Submit,mdmc FROM wx_t_StoreImgForMD where pid=@id and mdid=@mdid";
                paras.Clear();
                paras.Add(new SqlParameter("@id", id));
                paras.Add(new SqlParameter("@mdid", mdid));
                errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (errInfo != "")
                {
                    clsSharedHelper.WriteErrorInfo(errInfo);
                    return;
                }
                else if (dt.Rows.Count < 1)
                {
                    clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
                    clsSharedHelper.WriteErrorInfo("不存在该信息");
                    return;
                }
                json.AddJsonVar("id", Convert.ToString(dt.Rows[0]["id"]));
                json.AddJsonVar("Creator", Convert.ToString(dt.Rows[0]["Creator"]));
                json.AddJsonVar("SendTime", Convert.ToString(dt.Rows[0]["SendTime"]));
                json.AddJsonVar("UpdateTime", Convert.ToString(dt.Rows[0]["UpdateTime"]));
                json.AddJsonVar("Status", Convert.ToString(dt.Rows[0]["Status"]));
                json.AddJsonVar("Submit", Convert.ToString(dt.Rows[0]["Submit"]));
                json.AddJsonVar("mdmc", Convert.ToString(dt.Rows[0]["mdmc"]));

                clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
                clsSharedHelper.WriteInfo(json.jSon);
            }
        }
    }
    /// <summary>
    /// 保存模板形象册 创建者名称需要重新保存
    /// </summary>
    /// <param name="id"></param>
    /// <param name="cid"></param>
    /// <param name="info"></param>
    private void SaveStoreImgInfo(string id,string cid,string info)
    {
        if (string.IsNullOrEmpty(id) || id == "0")//更改为上传图片是就插入数据,在保存模板时只做更新动作,ID必须有值
        {
            clsSharedHelper.WriteErrorInfo("参数有误,非法访问!");
            return;
        }
        string errInfo, mysql;
        clsLocalLoger.Log(info);
        Dictionary<string, object> dicInfo = JsonConvert.DeserializeObject<Dictionary<string, object>>(info);
        List<Dictionary<string, string>> infoList = JsonConvert.DeserializeObject<List<Dictionary<string, string>>>(dicInfo["List"].ToString());

        mysql = "UPDATE wx_t_StoreImg SET STitle=@STitle,ImgCount=@ImgCount where id=@Pid;";
        List<SqlParameter> paras = new List<SqlParameter>();
        
        paras.Add(new SqlParameter("@STitle", dicInfo["Title"]));
        paras.Add(new SqlParameter("@ImgCount", infoList.Count));
        paras.Add(new SqlParameter("@Pid", id));
        foreach (Dictionary<string, string> di in infoList)
        {
            mysql = string.Concat(mysql, string.Format(" update wx_t_StoreImgMx set Remark='{0}',IsMust={2} where id={1};", di["remark"], di["Infoid"],di["ismust"]));
        }
       // DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
        }

        if (errInfo != "")
        {
            clsSharedHelper.WriteErrorInfo(errInfo);
        }
        else
        {
            clsSharedHelper.WriteSuccessedInfo("|"+id);
        }
    }
    /// <summary>
    /// 删除图片
    /// </summary>
    /// <param name="Imgid"></param>
    private void DeleteImage(string Imgid)
    {
        string mysql = @"SELECT a.*,CASE WHEN ISNULL(b.id,0)<>0 THEN 'mb' WHEN ISNULL(c.id,0)=0 THEN 'md' ELSE '无效' END AS type ,ISNULL(b.pid,ISNULL(c.MdImgID,0)) AS tableid
             FROM wx_t_uploadfile a LEFT JOIN wx_t_StoreImgMx b ON a.id=b.Imgid LEFT JOIN wx_t_StoreImgMxForMD c ON a.id=c.Imgid WHERE a.id=@id";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@id", Imgid));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            string errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }
            else if (dt.Rows.Count < 1)
            {
                clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
                clsSharedHelper.WriteErrorInfo("图片不存在");
                return;
            }
            else//清除图片
            {
                clearImage( dt.Rows[0]["URLAddress"].ToString() + dt.Rows[0]["FileName"].ToString());
                clearImage(dt.Rows[0]["ThumbnailURL"].ToString() + dt.Rows[0]["FileName"].ToString());
            }
           //清除数据
            if (Convert.ToString(dt.Rows[0]["type"]) == "mb")//模板
            {
                mysql = @"delete wx_t_StoreImgMx where Imgid=@Imgid;
                        DECLARE @count INT; 
                        SELECT @count=COUNT(1) FROM wx_t_StoreImg a INNER JOIN wx_t_StoreImgMx b ON a.id=b.pid AND a.id=@pid
                        IF @count=0 DELETE wx_t_StoreImg WHERE id=@pid 
                        ELSE UPDATE wx_t_StoreImg SET ImgCount=@count WHERE id=@pid";
            }
            else if (Convert.ToString(dt.Rows[0]["type"]) == "md")//门店
            {
                mysql = @"delete wx_t_StoreImgMxForMD where Imgid=@Imgid;
                        DECLARE @count INT; 
                        SELECT @count=COUNT(1) FROM wx_t_StoreImgForMD a INNER JOIN wx_t_StoreImgMxForMD b ON a.id=b.MdImgid AND a.id=@pid
                        IF @count=0 DELETE wx_t_StoreImgForMD WHERE id=@pid";
            }

            mysql =string.Concat(mysql, " delete wx_t_uploadfile where id=@Imgid;");
            paras.Clear();
            paras.Add(new SqlParameter("@Imgid", Imgid));
            paras.Add(new SqlParameter("@pid", dt.Rows[0]["tableid"]));
            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
            if (errInfo == "")
            {
                clsSharedHelper.WriteSuccessedInfo("");
            }
            else
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
            }
        }
    }
    private void clearImage(string url)
    {
        string miniPath = Server.MapPath("~");
        string FileUrl = string.Concat(miniPath,"/", url);
        if (System.IO.File.Exists(FileUrl))
        {
            try
            {
                File.Delete(FileUrl);
            }
            catch (Exception e)
            {
                clsLocalLoger.Log("删除图片失败：【"+url+"】"+e.ToString());
            }
        }
    }
    /// <summary>
    /// 上传图片
    /// </summary>
    /// <param name="PicBase"></param>
    /// <param name="CreateID"></param>
    /// <param name="rotate"></param>
    /// <param name="SourceTableID"></param>
    /// <returns></returns>
    private void saveMyImgs(string PicBase, string CreateID, string rotate, string id, string IsMust,string tzid,string username)
    {        
        string rt = "", mysql;
        DataTable dt = null;
        string myFolder = DateTime.Now.ToString("yyyyMM");
        string pathStr = "upload/ImageManage/" + myFolder + "/";
        string path = HttpContext.Current.Server.MapPath("~/" + pathStr);
        string myPath = HttpContext.Current.Server.MapPath("~/" + pathStr + "my/");
        String strPath = Path.GetDirectoryName(path);
        String filename = CreateID + DateTime.Now.ToString("yyyyMMddHHmmssfff") + ".jpg";

        if (!Directory.Exists(strPath))
        {
            Directory.CreateDirectory(strPath);
        }

        rt = Base64StringToImage(ref PicBase, path, filename, rotate);
        PicBase = "";   //回收资源
        if (rt != "")
        {
            clsSharedHelper.WriteErrorInfo(rt);
            return;
        }
        strPath = Path.GetDirectoryName(myPath);
        if (!Directory.Exists(strPath))
        {
            Directory.CreateDirectory(strPath);
        }
        rt = MakeImage(path + filename, myPath + filename, 100);

        if (rt!="")
        {
            clsSharedHelper.WriteErrorInfo(rt);
            return;  
        }
        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            mysql = @"insert into wx_t_uploadfile(SourceTableID,TypeID,URLAddress,ThumbnailURL,CreateTime,FileName,CreateCustomerID) 
                      values(@SourceTableID,@TypeID,@URLAddress,@ThumbnailURL,getdate(),@FileName,@CreateCustomerID); select @@identity";
            paras.Add(new SqlParameter("@SourceTableID", "0"));
            paras.Add(new SqlParameter("@TypeID", "3"));
            paras.Add(new SqlParameter("@URLAddress", pathStr));
            paras.Add(new SqlParameter("@ThumbnailURL", pathStr + "my/"));
            paras.Add(new SqlParameter("@FileName", filename));
            paras.Add(new SqlParameter("@CreateCustomerID", CreateID));
            rt = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (rt != "")
            {
                clsSharedHelper.WriteErrorInfo(rt);
                return;  
            }
            string Imgid = Convert.ToString(dt.Rows[0][0]);
            clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
            paras.Clear();
            if (string.IsNullOrEmpty(id) || id == "0")
            {
                //INSERT INTO wx_t_StoreImgMx (Pid,Imgid,AddressURL,IsMust) VALUES( @@identity,@Imgid,@AddressURL,@IsMust);
                mysql =@"INSERT INTO wx_t_StoreImg(STitle,CreateTime,CreateID,tzid,CreateName) VALUES('编辑中的模板',GETDATE(),@CreateID,@tzid,@createname);
                INSERT INTO wx_t_StoreImgMx (Pid,Imgid,AddressURL,IsMust) VALUES( @@identity,@Imgid,@AddressURL,@IsMust); select * from wx_t_StoreImgMx where id=@@identity;";
                paras.Add(new SqlParameter("@CreateID", CreateID));
                paras.Add(new SqlParameter("@tzid", tzid));
                paras.Add(new SqlParameter("@createname", username));
            }
            else
            {
                mysql = @"INSERT INTO wx_t_StoreImgMx (Pid,Imgid,AddressURL,IsMust) VALUES( @id,@Imgid,@AddressURL,@IsMust); select * from wx_t_StoreImgMx where id=@@identity;";
                paras.Add(new SqlParameter("@id", id));
            }
            paras.Add(new SqlParameter("@IsMust", IsMust));
            paras.Add(new SqlParameter("@Imgid", Imgid));
            paras.Add(new SqlParameter("@AddressURL", pathStr + "my/" + filename));
            
            rt = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (rt == "")
            {
                rt = string.Format("{{\"id\": \"{0}\",\"infoid\": \"{1}\", \"Imgid\": \"{2}\",\"url\": \"{3}\"}}", dt.Rows[0]["Pid"], dt.Rows[0]["ID"], dt.Rows[0]["Imgid"], dt.Rows[0]["AddressURL"]);
            }
            else
            {
                rt = clsNetExecute.Error + rt;
            }
        }
        clsSharedHelper.WriteInfo(rt);
    }

    /// <summary>
    /// 加载模板形象册的详情信息列表
    /// </summary>
    /// <returns></returns>
    private void LoadStoreImgInfo(string ID)
    {
        string rt = "", errInfo, mysql;
        mysql = "SELECT ID AS infoid,imgid,AddressURL as url,remark,IsMust FROM wx_t_StoreImgMx WHERE Pid=@pid order by ID asc";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@pid", ID));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }
            rt = DataTableToJson("List", dt);
            mysql = "SELECT ID,STitle AS Title FROM wx_t_StoreImg where ID=@id";
            para.Clear();
            dt.Clear();
            para.Add(new SqlParameter("@id", ID));
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }
            else if (dt.Rows.Count < 1)
            {
                clsSharedHelper.WriteErrorInfo("无效ID,无法获取模板信息！");
                return;
            }

            using (clsJsonHelper json = clsJsonHelper.CreateJsonHelper(rt))
            {
                json.AddJsonVar("ID", ID);
                json.AddJsonVar("Title", Convert.ToString(dt.Rows[0]["Title"]));
                rt = json.jSon;
                clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
                json.Dispose();
            }
        }
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 加载模板形象册的详情信息
    /// </summary>
    /// <returns></returns>
    private void LoadStoreImgMxInfo(string Infoid)
    {
        string rt = "", errInfo, mysql;
        mysql = "SELECT ID AS infoid,imgid,AddressURL as url,remark FROM wx_t_StoreImgMx WHERE id=@infoid";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@infoid", Infoid));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }
            rt = DataTableToJson("List", dt);
            // clsJsonHelper json = clsJsonHelper.CreateJsonHelper(rt);
            clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
           // json.Dispose();
            Dictionary<string, object> dic = JsonConvert.DeserializeObject<Dictionary<string, object>>(rt);
            List<object> dicList = JsonConvert.DeserializeObject< List<object>>(dic["List"].ToString());
            rt=dicList[0].ToString();
        }
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 加载已发布的门店详情（以便查看门店形象册详情）
    /// </summary>
    /// <param name="id"></param>
    /// <param name="khid"></param>
    /// <param name="mdmc"></param>
    /// <returns></returns>
    private void LoadStoreListForMD()
    {
        string id = Convert.ToString(Request.Params["id"]);
        string status = Convert.ToString(Request.Params["status"]);
        string mdmcLike = Convert.ToString(Request.Params["mdmcLike"]);
        
        string rt = "", errInfo, mysql="";

        switch (status)
        {
            //未提交
            case "1":
                mysql = " select mdid,mdmc,'1' AS status FROM  wx_t_StoreImgForMD WHERE IsActive=1 AND IsSubmit=0 AND pid=@id ";
                break;
            //待审核
            case "2":
                mysql = "select mdid,mdmc,'2' AS status FROM  wx_t_StoreImgForMD WHERE IsActive=1 AND IsSubmit=1 AND Status=0 AND pid=@id";
                break;
            //已通过
            case "3":
                mysql = "select mdid,mdmc,'3' AS status FROM  wx_t_StoreImgForMD WHERE IsActive=1 AND IsSubmit=1 AND Status=1 AND pid=@id";
                break;
            //未通过
            case "4":
                mysql = "select mdid,mdmc,'4' AS status FROM  wx_t_StoreImgForMD WHERE IsActive=1 AND IsSubmit=1 AND Status=-1 AND pid=@id";
                break;
            default: clsSharedHelper.WriteErrorInfo("非法状态"); break;
        }
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@id", id));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
        }
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            rt = DataTableToJson("List", dt);
        }
        clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
        
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 提交发布门店ID列表
    /// </summary>
    /// <param name="cid"></param>
    /// <param name="mdid"></param>
    /// <param name="userid"></param>
    /// <param name="username"></param>
    /// <returns></returns>
    private void SendStoreList(string username)
    {
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string cid = Convert.ToString(Request.Params["cid"]);
        string pid = Convert.ToString(Request.Params["pid"]);
        string errInfo, mysql;
        string[] mdidArray = mdid.Split('|');

        string mdidlist = "0";
        for (int i = 0; i < mdidArray.Length; i++)
        {
            mdidlist = string.Concat(mdidlist, ",", mdidArray[i]);
        }

        mysql = string.Format("select khid,mdid,mdmc from t_mdb where mdid in({0})", mdidlist);
        DataTable dt_md;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OADBConnStr))
        {
            errInfo = dal.ExecuteQuery(mysql, out dt_md);

            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }
            else if (dt_md.Rows.Count < 1)
            {
                clsSharedHelper.WriteErrorInfo("无效门店" + mdid);
                return;
            }

            dal.ConnectionString = WXDBConnStr;
            mysql = "";
            for (int i = 0; i < dt_md.Rows.Count; i++)
            {
                mysql = string.Concat(mysql, string.Format(@"insert into wx_t_StoreImgForMD(Pid,khid,mdid,CreateTime,CreateID,CreateName,IsActive,IsSubmit,Status,mdmc) 
                VALUES({0},{1},{2},getdate(),{3},'{4}',1,0,0,'{5}');", pid, dt_md.Rows[i]["khid"], dt_md.Rows[i]["mdid"], cid, username, dt_md.Rows[i]["mdmc"]));
            }
            clsSharedHelper.DisponseDataTable(ref dt_md);//回收资源 
            mysql = string.Concat(mysql,string.Format("update wx_t_StoreImg set IsSend=1 where id={0};",pid));
            errInfo = dal.ExecuteNonQuery(mysql);
            if (errInfo != "")
                clsSharedHelper.WriteErrorInfo(errInfo);
            else
                clsSharedHelper.WriteSuccessedInfo("");
        }//end using
    }
    /// <summary>
    /// 加载待发布的门店列表
    /// </summary>
    /// <param name="khid">贸易公司khid</param>
    /// <param name="mdmc">门店名称</param>
    /// <param name="status">发布状态 0 未发布 1 已发布 -1全部</param>
    /// <returns></returns>
    private void LoadStoreList()
    {
        string  khid = Convert.ToString(Request.Params["khid"]);
        string mdmc = Convert.ToString(Request.Params["mdmc"]);
        string pid = Convert.ToString(Request.Params["pid"]);
        string status = Convert.ToString(Request.Params["status"]);
        string ssid = Convert.ToString(Request.Params["ssid"]);//
        
        string rt = "", errInfo, mysql, condition = "",mdidlist="0";
        if (!string.IsNullOrEmpty(mdmc))
        {
            condition = string.Concat(" and b.mdmc like '%", mdmc, "%'");
        }
        DataTable dt_db = null,dt_submit=null;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@pid", pid));
            mysql = string.Format("select b.mdid,b.mdmc,'1' as Status FROM wx_t_StoreImgForMD b  where b.IsActive=1 and pid=@pid ");
            errInfo = dal.ExecuteQuerySecurity(mysql,para, out dt_submit);
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }
            
            for (int i = 0; i < dt_submit.Rows.Count; i++)
            {
                mdidlist = string.Concat(mdidlist, ",", dt_submit.Rows[i]["mdid"]);
            }
            clsSharedHelper.DisponseDataTable(ref dt_submit);//回收资源 

            if (status == "-1")
            {
                status = "";
            }else{
                status = " and (case when isnull(c.mdid,0)=0 then 0 else 1 end)=" + status;
            }
            
            mysql = string.Format(@"SELECT b.mdid,b.mddm + '.' + b.mdmc as mdmc,case when isnull(c.mdid,0)=0 then 0 else 1 end AS Status
                        FROM yx_t_khb a INNER JOIN t_mdb b ON a.khid=b.khid left join t_mdb c on b.mdid=c.mdid and c.mdid in({0})
                        WHERE a.ty=0 AND b.ty=0 and a.ccid+'-' LIKE '%-'+@khid+'-%' {1} {2} ", mdidlist, condition, status);
            para.Clear();
            para.Add(new SqlParameter("@khid", khid));
            dal.ConnectionString = OADBConnStr;
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt_db);
            
            if (errInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(errInfo);
                return;
            }
            rt = DataTableToJson("List", dt_db);
            clsSharedHelper.DisponseDataTable(ref dt_submit);//回收资源 
        }
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 加载可供选择的贸易公司列表
    /// </summary>
    /// <param name="userid"></param>
    /// <returns></returns>
    private void LoadCompanyList(string userid)
    {
        string rt = "", errInfo;
        string mysql = @"SELECT a.khid,a.mdid,a.mdmc,a.ssid 
                         FROM wx_t_OmniChannelAuth a INNER JOIN dbo.wx_t_customers b ON a.Customers_ID=b.ID WHERE ssid=1 AND a.Customers_ID=@userid";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@userid", userid));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
        }
        if (errInfo != "")
        {
            rt = clsNetExecute.Error + errInfo;
        }
        else
        {
            rt = DataTableToJson("List", dt);
            clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
        }
        clsSharedHelper.WriteInfo(rt);
    }
    /// <summary>
    /// 首页 加载模板形象册列表
    /// </summary>
    /// <param name="RoleName"></param>
    /// <param name="userid"></param>
    /// <param name="mdid"></param>
    /// <param name="rid"></param>
    /// <returns></returns>
    private void LoadStoreImgs(string RoleName, string userid, string mdid)
    {
        string rid = Convert.ToString(Request.Params["rid"]);
        
        //取数取错 170208
        //RoleName = Convert.ToString(Request.Params["rolename"]);
        //userid = Convert.ToString(Request.Params["userid"]);
        //mdid = Convert.ToString(Request.Params["mdid"]);

        if (string.IsNullOrEmpty(userid))
        {
            clsSharedHelper.WriteErrorInfo("非法用户");
            return;
        }

        string rt = "", mysql = "", errInfo;
        List<SqlParameter> para = new List<SqlParameter>();
        string STitle;
        if ( RoleName == "my")
        {
            STitle = "未提交,待审核,已通过,未通过";
            mysql = @"SELECT a.id,a.STitle AS title,a.CreateTime AS Date,a.IsSend,a.ImgCount,c.AddressURL,'False' IsSubmit,
                    SUM( CASE WHEN b.IsSubmit=0 THEN 1 ELSE 0 END) s1,
                    SUM( CASE WHEN b.IsSubmit=1 AND Status=0 THEN 1 ELSE 0 END) s2,
                    SUM( CASE WHEN b.IsSubmit=1 AND Status=1 THEN 1 ELSE 0 END) s3,
                    SUM( CASE WHEN b.IsSubmit=1 AND Status=-1 THEN 1 ELSE 0 END) s4
                    FROM wx_t_StoreImg a LEFT JOIN wx_t_StoreImgForMD b ON a.id=b.Pid AND b.IsActive=1
                    INNER JOIN (SELECT pid,min(AddressURL) AddressURL FROM wx_t_StoreImgMx GROUP BY pid ) c ON a.id=c.pid
                    WHERE a.IsActive=1 AND a.CreateID=@CreateID
                    GROUP BY a.id,a.STitle,a.CreateTime,a.IsSend,a.ImgCount,c.AddressURL order by a.id desc";
            para.Add(new SqlParameter("@CreateID", userid));
        }
        else if (RoleName == "zb" || RoleName == "kf")
        {
            STitle = "未提交,待审核,已通过,未通过";
            mysql = @"SELECT a.id,a.STitle AS title,a.CreateTime AS Date,a.IsSend,a.ImgCount,c.AddressURL,'False' IsSubmit,
                    SUM( CASE WHEN b.IsSubmit=0 THEN 1 ELSE 0 END) s1,
                    SUM( CASE WHEN b.IsSubmit=1 AND Status=0 THEN 1 ELSE 0 END) s2,
                    SUM( CASE WHEN b.IsSubmit=1 AND Status=1 THEN 1 ELSE 0 END) s3,
                    SUM( CASE WHEN b.IsSubmit=1 AND Status=-1 THEN 1 ELSE 0 END) s4
                    FROM wx_t_StoreImg a LEFT JOIN wx_t_StoreImgForMD b ON a.id=b.Pid AND b.IsActive=1
                    INNER JOIN (SELECT pid,min(AddressURL) AddressURL FROM wx_t_StoreImgMx GROUP BY pid ) c ON a.id=c.pid
                    WHERE a.IsActive=1 
                    GROUP BY a.id,a.STitle,a.CreateTime,a.IsSend,a.ImgCount,c.AddressURL order by a.id desc";
        }
        else if (RoleName == "dz")
        {
            STitle = "已通过,未通过,已上传,未上传";
            mysql = @"SELECT a.pid as id,b.STitle AS title,a.CreateTime AS Date,'False' AS IsSend,b.ImgCount,MIN(d.AddressURL) AddressURL,a.IsSubmit,
                    SUM( CASE WHEN ISNULL(d.Status,0)=1 THEN 1 ELSE 0 END) AS s1,
                    SUM( CASE WHEN ISNULL(d.Status,0)=-1 THEN 1 ELSE 0 END) AS s2,
                    SUM( CASE WHEN d.ID IS NOT null THEN 1 ELSE 0 END) AS s3,
                    SUM( CASE WHEN ISNULL(d.ID,0)=0 THEN 1 ELSE 0 END) AS s4
                    FROM wx_t_StoreImgForMD a INNER JOIN wx_t_StoreImg b ON a.Pid=b.ID
                    INNER JOIN wx_t_StoreImgMx c ON b.ID=c.Pid
                    LEFT JOIN wx_t_StoreImgMxForMD d ON b.ID=d.Pid AND c.ID=d.InfoID AND a.id=d.MdImgID
                    WHERE a.IsActive=1 AND a.mdid=@mdid
                    GROUP  BY a.pid,b.STitle,a.CreateTime,a.IsSubmit,b.ImgCount order by a.pid desc";
            para.Add(new SqlParameter("@mdid", mdid));
        }
        else
        {
            clsSharedHelper.WriteErrorInfo("无权访问");
            return;
        }
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXDBConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
        }

        if (errInfo != "")
        {
            rt = clsNetExecute.Error + errInfo;
        }
        else
        {
            rt = DataTableToJson("List", dt);
            using (clsJsonHelper json = clsJsonHelper.CreateJsonHelper(rt))
            {
                json.AddJsonVar("STitle", STitle);
                rt = json.jSon;
                json.Dispose();
            }
            clsSharedHelper.DisponseDataTable(ref dt);//回收资源 
        }
        clsSharedHelper.WriteInfo(rt);
    }

    /// <summary>
    /// datatable转成json格式
    /// </summary>
    /// <param name="jsonName">转换后的json名称</param>
    /// <param name="dt">待转数据表</param>
    /// <returns></returns>
    public static string DataTableToJson(string jsonName, DataTable dt)
    {
        StringBuilder Json = new StringBuilder();
        Json.Append("{\"" + jsonName + "\":[");
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                Json.Append("{");
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    Json.Append("\"" + dt.Columns[j].ColumnName.ToString() + "\":\"" + dt.Rows[i][j].ToString() + "\"");
                    if (j < dt.Columns.Count - 1)
                    {
                        Json.Append(",");
                    }
                }
                Json.Append("}");
                if (i < dt.Rows.Count - 1)
                {
                    Json.Append(",");
                }
            }
        }
        Json.Append("]}");
        return Json.ToString();
    }
    /****************上传图片处理***************************/
    //图片处理上传
    private String Base64StringToImage(ref string PicBase64, string path, string filename, string rotate)
    {
        return Base64StringToImage(ref PicBase64, path, filename, rotate, System.Drawing.Imaging.ImageFormat.Jpeg);
    }
    //图片处理上传
    private String Base64StringToImage(ref string PicBase64, string path, string filename, string rotate , System.Drawing.Imaging.ImageFormat imgFormat)
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

                bmp.Save(path + filename, imgFormat);
                
                //获取尺寸数据
                MapWidth = bmp.Width;
                MapHeight = bmp.Height;
                
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
    /****************上传图片结束***************************/
    /// <summary>
    /// unicode转为中文
    /// </summary>
    /// <param name="str"></param>
    /// <returns></returns>
    public static string ToGB2312(string str)
    {
        string r = "";
        MatchCollection mc = Regex.Matches(str, @"\\u([\w]{2})([\w]{2})", RegexOptions.Compiled | RegexOptions.IgnoreCase);
        byte[] bts = new byte[2];
        foreach (Match m in mc)
        {
            bts[0] = (byte)int.Parse(m.Groups[2].Value, NumberStyles.HexNumber);
            bts[1] = (byte)int.Parse(m.Groups[1].Value, NumberStyles.HexNumber);
            r += Encoding.Unicode.GetString(bts);
        }
        return r;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
</head>
<body>
</body>
</html>
