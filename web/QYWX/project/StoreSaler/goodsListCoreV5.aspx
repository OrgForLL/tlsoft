﻿<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">  	   
    string FXDBConStr = "server=192.168.35.11;database=FXDB;uid=ABEASD14AD;pwd=+AuDkDew";
    string OAConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    string queryConnStr = "server=192.168.35.32;uid=lllogin;pwd=rw1894tla;database=tlsoft";
    string ERPDBConStr = "server=192.168.35.19;database=ERPDB;uid=ABEASD14AD;pwd=+AuDkDew";
    string WXConStr = System.Web.Configuration.WebConfigurationManager.ConnectionStrings["conn"].ToString();
    string RoleName ="";
    protected void Page_Load(object sender, EventArgs e)
    {
        RoleName = Convert.ToString(Session["RoleName"]);
        string mdid, ctrl, rt = "", sphh, showType;
        mdid = Convert.ToString(Request.Params["mdid"]);
        ctrl = Convert.ToString(Request.Params["ctrl"]);
        switch (ctrl)
        {
            case "goodsListSingle":
                string lastId = Convert.ToString(Request.Params["lastID"]);
                string filter = Convert.ToString(Request.Params["filter"]);
                rt = goodsList(mdid, lastId, filter);
                break;
            case "goodsDetail":
                sphh = Convert.ToString(Request.Params["sphh"]);
                showType = Convert.ToString(Request.Params["showType"]);
                rt = goodsDetail(sphh, showType,mdid);
                break;
            case "otherDetail": 
                sphh = Convert.ToString(Request.Params["sphh"]);
                rt = otherDetail(mdid, sphh);
                    break;
            case "getScanSphh":
                string scanType = Convert.ToString(Request.Params["scanType"]);
                string scanResult = Convert.ToString(Request.Params["scanResult"]);
                rt = getScanSphh(scanType, scanResult);
                break;
            case "goodsStock":
                 string StockType = Convert.ToString(Request.Params["StockType"]);
                 sphh = Convert.ToString(Request.Params["sphh"]);
                 rt=LoadGoodsStock(mdid,sphh,StockType);
                 break;
            case "getCommentList":  //获取评论列表。该方法即将作废
                 sphh = Convert.ToString(Request.Params["sphh"]);
                 string maxID = Convert.ToString(Request.Params["maxId"]);
                 rt = GetCommentList(sphh, maxID);
                 break;
            case "SubmitComment":   //提交评论。该方法即将作废
                 sphh = Convert.ToString(Request.Params["sphh"]);
                 string comment = Convert.ToString(Request.Params["comment"]);
                 rt = AddComment(sphh, comment);
                 break;
            case "clickLike":
                 string comID = Convert.ToString(Request.Params["comID"]);
                 rt = ClickLikes(comID);
                 break;
            case "LoadEvaluation":
                 sphh = Convert.ToString(Request.Params["sphh"]);
                 int LoadCount = Convert.ToInt32(Request.Params["LoadCount"]);
                 bool OnlyLoadMy = Convert.ToBoolean(Request.Params["onlyMy"]);
                 LoadEvaluation(sphh, LoadCount, OnlyLoadMy);
                 break;
            case "SaveEvaluation":
                 string paraJson = Convert.ToString(Request.Params["paraJson"]);
                 SaveEvaluation(paraJson);
                 break;
            case "SaveImgs":
                 string rotate =Convert.ToString(Request.Params["rotate"]);
                 string formFile =Convert.ToString(Request.Params["formFile"]);
                 string SourceTableID = Convert.ToString(Request.Params["sid"]);
                 rt = saveMyImgs(formFile, Convert.ToString(Session["qy_customersid"]), rotate, SourceTableID);
                 break;
            case "DelImgs":
                 string pid = Convert.ToString(Request.Params["Pid"]);
                 delMyImgs(pid);
                 break;
            default: rt = "参数有误"; break;
        }
        clsSharedHelper.WriteInfo(rt);
    }
    /****删除图片*****/
    private void delMyImgs(string pid)
    {
        string errInfo = "";
        string mysql = @"select * from wx_t_uploadfile where id=@pid
                        DELETE FROM wx_t_uploadfile WHERE  ID=@pid";
        DataTable dt;
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@pid",pid));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            if (errInfo == "" && dt.Rows.Count > 0)//删除文件
            {
                string URLAddress = Convert.ToString(dt.Rows[0]["URLAddress"]);
                string ThumbnailURL = Convert.ToString(dt.Rows[0]["ThumbnailURL"]);
                string FileName = Convert.ToString(dt.Rows[0]["FileName"]);
                string mainPath = Server.MapPath(URLAddress + FileName);
                string minPath = Server.MapPath(ThumbnailURL + FileName);
                if (System.IO.File.Exists(mainPath))
                {
                    try
                    {
                        File.Delete(mainPath);
                        File.Delete(minPath);
                    }
                    catch (Exception e)
                    {
                        clsLocalLoger.WriteError("图片删除失败！错误：" + e.Message);
                        errInfo = "图片删除失败！错误号1";
                    }
                }
            }
            else
            {
                clsLocalLoger.WriteError("无法删除图片！错误：" + errInfo);
                errInfo = "图片删除失败！错误号2";
            }
        }

        clsSharedHelper.WriteInfo(errInfo);
    }

    /********上传图片***********/
    private string saveMyImgs(String PicBase, String CreateID, String rotate, string SourceTableID)
    {
        
        string rt = "";
        string myFolder = DateTime.Now.ToString("yyyyMM");
        string pathStr = "upload/StoreSaler/" + myFolder + "/";
        string path = HttpContext.Current.Server.MapPath("~/" + pathStr);
        string myPath = HttpContext.Current.Server.MapPath("~/" + pathStr + "my/");
        String strPath = Path.GetDirectoryName(path);
        String filename = CreateID + DateTime.Now.ToString("yyyyMMddHHmmssfff") + ".jpg";

        if (!Directory.Exists(strPath))
        {
            Directory.CreateDirectory(strPath);
        }

        rt = Base64StringToImage(PicBase, path, filename, rotate);

        if (!rt.Equals(""))
        {
            return rt;
        }
        strPath = Path.GetDirectoryName(myPath);
        if (!Directory.Exists(strPath))
        {
            Directory.CreateDirectory(strPath);
        }
        rt = MakeImage(path + filename, myPath + filename, 100);

        if (rt.Equals(""))
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConStr))
            {
                DataTable dt = null;
                List<SqlParameter> paras = new List<SqlParameter>();
                String mysql = @"insert into wx_t_uploadfile(SourceTableID,TypeID,URLAddress,ThumbnailURL,CreateTime,FileName,CreateCustomerID) 
                                 values(@SourceTableID,@TypeID,@URLAddress,@ThumbnailURL,getdate(),@FileName,@CreateCustomerID);
                                     select @@identity";
                paras.Add(new SqlParameter("@SourceTableID", SourceTableID));
                paras.Add(new SqlParameter("@TypeID", "2"));
                paras.Add(new SqlParameter("@URLAddress", pathStr));
                paras.Add(new SqlParameter("@ThumbnailURL", pathStr + "my/"));
                paras.Add(new SqlParameter("@FileName", filename));
                paras.Add(new SqlParameter("@CreateCustomerID", CreateID));

                rt = dal.ExecuteQuerySecurity(mysql, paras, out dt);
                if (rt.Equals("") && dt.Rows.Count > 0)
                {
                    rt = "success|" + dt.Rows[0][0].ToString() + "|" + SourceTableID;
                }
            }
        }
        return rt;
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
    /// 保存评论信息
    /// </summary>
    /// <param name="paraStr"></param>
    private void SaveEvaluation(string paraStr)
    {
        string rtStr="{{\"code\":\"{0}\",\"msg\":\"{1}\"{2}}}";
         if(string.IsNullOrEmpty(Convert.ToString(Session["qy_customersid"]))){
         clsSharedHelper.WriteInfo(string.Format(rtStr,"403","您已超时,请重新访问!"));   
        }
        //paraStr = "{}";
        clsJsonHelper prarJson = clsJsonHelper.CreateJsonHelper(paraStr);
        string mysql = " declare @myid int;";
        List<SqlParameter> para = new List<SqlParameter>();
        if (prarJson.GetJsonValue("ID") == "" || prarJson.GetJsonValue("ID") == "0")
        {
            mysql =string.Concat(mysql, @" INSERT INTO wx_t_Evaluation(khid,mdid,sphh,CreateTime,CreaterType,CreaterID,CreaterName,EvaluationTypeID,OFBGroupID,TheContent,LastUpdateTime,IsActive,IsShow) 
                      VALUES(@khid,@mdid,@sphh,GETDATE(),0,@CreaterID,@CreaterName,@EvaluationTypeID,@OFBGroupID,@TheContent,GETDATE(),@IsActive,@IsShow); SET @myid=@@IDENTITY;");
            para.Add(new SqlParameter( "@khid",Convert.ToString(Session["khid"])));
            para.Add(new SqlParameter( "@mdid",Convert.ToString(Session["mdid"])));
            para.Add(new SqlParameter( "@CreaterID",Convert.ToString(Session["qy_customersid"])));
            para.Add(new SqlParameter("@CreaterName", Convert.ToString(Session["qy_cname"])));
        }
        else
        {
            mysql =string.Concat(mysql, @"UPDATE  wx_t_Evaluation SET EvaluationTypeID=@EvaluationTypeID,OFBGroupID=@OFBGroupID,TheContent=@TheContent,LastUpdateTime=GETDATE(),IsActive=@IsActive,IsShow=@IsShow WHERE ID=@ID; select @myid = ID from wx_t_Evaluation where ID=@ID");
            para.Add(new SqlParameter("@ID", prarJson.GetJsonValue("ID")));
        }
        mysql =string.Concat(mysql, @" SELECT A.ID,ISNULL(CC.avatar,'') userimg,A.CreaterName username,B.GroupName ogroup,C.TypeName etype,A.TheContent centent,A.LastUpdateTime mydate
                    FROM wx_t_Evaluation A
                    INNER JOIN wx_t_OFBGroup B ON A.OFBGroupID = B.ID
                    INNER JOIN wx_t_EvaluationType C ON A.EvaluationTypeID = C.ID
                    LEFT JOIN dbo.wx_t_customers CC ON A.CreaterType = 0 AND CC.ID = A.CreaterID
                    WHERE A.id=@myid");
        para.Add(new SqlParameter("@sphh", prarJson.GetJsonValue("sphh")));
        para.Add(new SqlParameter("@EvaluationTypeID", prarJson.GetJsonValue("etype")));
        para.Add(new SqlParameter("@OFBGroupID", prarJson.GetJsonValue("ogroup")));
        para.Add(new SqlParameter("@TheContent", prarJson.GetJsonValue("TheContent")));
        para.Add(new SqlParameter("@IsActive", prarJson.GetJsonValue("IsActive")));
        para.Add(new SqlParameter("@IsShow", prarJson.GetJsonValue("IsShow")));

        string errInfo;
        DataTable  dt;
        using(LiLanzDALForXLM dal=new LiLanzDALForXLM(WXConStr)){
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            if (errInfo != "")
            {
            rtStr=string.Format(rtStr,"413",errInfo,"");
            }
            else
            {
                DataTable dt_img;
                string imgUrlHead = clsConfig.GetConfigValue("OA_WebPath");
                errInfo = dal.ExecuteQuery(string.Format("SELECT U.ThumbnailURL + U.FileName  FROM wx_t_uploadfile U WHERE U.TypeID = 2 AND u.SourceTableID={0}", dt.Rows[0]["id"]), out dt_img);
                string imgs="";
                if (errInfo == "")
                {
                    foreach (DataRow dr in dt_img.Rows)
                    {
                        //getMiniImage(ref imgUrlHead, imgsList[i])
                        imgs = string.Concat(imgs,"\"", getMiniImage(ref imgUrlHead, Convert.ToString(dr[0])),"\"",",");
                    }
                    imgs = imgs.TrimEnd(',');
                    dt_img.Clear(); dt_img.Dispose();
                }
                string info = string.Format(@"{{
                        ""id"": ""{0}"",
                        ""userimg"": ""{1}"",
                        ""username"": ""{2}"",
                        ""ogroup"": ""{3}"",
                        ""etype"": ""{4}"",
                        ""centent"": ""{5}"",
                        ""date"": ""{6}"",
                        ""img"": [{7}]}}", dt.Rows[0]["id"], getMiniImage(ref imgUrlHead, (string)dt.Rows[0]["userimg"]), dt.Rows[0]["username"], dt.Rows[0]["ogroup"], dt.Rows[0]["etype"], dt.Rows[0]["centent"], Convert.ToDateTime(dt.Rows[0]["mydate"]).ToString("yyyy-MM-dd"), imgs);
                rtStr = string.Format(rtStr, "200", "", string.Format(",\"Info\":{0}", info));
                dt.Clear();
                dt.Dispose();
            }
        }
        clsSharedHelper.WriteInfo(rtStr);
    }

    /// <summary>
    /// 加载评论，暂时不实现分页加载
    /// </summary>
    /// <param name="sphh">商品货号</param>
    /// <param name="LoadCount">加载评论数量</param>
    /// <param name="OnlyLoadMe">是否只加载我的评论</param>
    private void LoadEvaluation(string sphh, int LoadCount, bool OnlyLoadMe)
    {
        string roleName = Convert.ToString(Session["RoleName"]);
        if (roleName == null || roleName == "")
        {
            clsSharedHelper.WriteInfo(string.Concat(clsSharedHelper.Error_Output, "超时访问超时！"));
            return;
        }

        string strSQLAdd = ""; 

        string strInfo = "";
        StringBuilder jsonBuder = new StringBuilder();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConStr)){
            List<SqlParameter> sqlParams = new List<SqlParameter>();
            string strSQL = @"SELECT TOP 10 KeyWordName,TheCount FROM wx_t_ProductKeyWord WHERE sphh=@sphh AND IsActive = 1 ORDER BY TopIndex DESC,TheCount DESC";

            sqlParams.Add(new SqlParameter("@sphh", sphh));
            DataTable dtKeyWrod;
            strInfo = dal.ExecuteQuerySecurity(strSQL, sqlParams, out dtKeyWrod);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat(clsSharedHelper.Error_Output, "评论标签查询失败！错误：", strInfo));
                clsSharedHelper.WriteInfo(string.Concat(clsSharedHelper.Error_Output, "评论标签查询失败！"));
                return;
            }

            //开始生成关键字标签
            jsonBuder.Append(@"{
                ""keywords"": [");
            foreach (DataRow dr in dtKeyWrod.Rows)
            {
                jsonBuder.AppendFormat(@"{{
                                            ""keyword"": ""{0}"",
                                            ""Count"": ""{1}""
                                         }},", dr["KeyWordName"], dr["TheCount"]);
            }
            if (dtKeyWrod.Rows.Count > 0)
            {
                jsonBuder.Remove(jsonBuder.Length - 1, 1);
            }                                           
            jsonBuder.Append("],");

            if (dtKeyWrod != null) { dtKeyWrod.Clear(); dtKeyWrod.Dispose(); }
            //处理关键字标签结束

            //开始生成 评论详情
            
            if (OnlyLoadMe)
            {
                //目前限定发帖者只有企业号内部成员
                string CreaterID = Convert.ToString(Session["qy_customersid"]);
                if (CreaterID == null || CreaterID == "")
                {
                    clsLocalLoger.WriteError(string.Concat(clsSharedHelper.Error_Output, "加载本人发帖信息失败！错误：Session超时"));
                    clsSharedHelper.WriteInfo(string.Concat(clsSharedHelper.Error_Output, "登录超时，不能加载本人发帖信息！"));
                    return;                    
                }                
                strSQLAdd = string.Concat(" AND A.CreaterType = 0 AND A.CreaterID = ",CreaterID);
            }
            else
            {
                if (!(roleName == "zb" || roleName == "kf"))    //如果不是总部或开发者身份，则只能看到 商品卖点
                {
                    strSQLAdd = " AND A.OFBGroupID=6 ";
                }
                strSQLAdd = string.Concat(" AND IsShow = 1 ", strSQLAdd);
            }

            strSQL = string.Concat(@"SELECT TOP ", LoadCount, @" A.ID ,A.CreateTime,A.CreaterName username,A.EvaluationTypeID,A.OFBGroupID,B.GroupName ogroup,C.TypeName etype,A.TheContent centent,A.LastUpdateTime mydate 
                                                ,A.IsGood ,A.IsAudit ,A.TotalReward,ISNULL(CC.avatar,'') userimg
                                                ,(SELECT CAST(U.ID AS VARCHAR(15))  +'-'+   U.ThumbnailURL + U.FileName + '|' FROM wx_t_uploadfile U WHERE U.TypeID = 2 AND u.SourceTableID=A.ID FOR XML PATH('')) AS imgs
                            FROM wx_t_Evaluation A
                          INNER JOIN wx_t_OFBGroup B ON A.OFBGroupID = B.ID
                          INNER JOIN wx_t_EvaluationType C ON A.EvaluationTypeID = C.ID
                          LEFT JOIN dbo.wx_t_customers CC ON A.CreaterType = 0 AND CC.ID = A.CreaterID
                          WHERE A.sphh = @sphh AND A.IsActive = 1 ", strSQLAdd, @"
                           ORDER BY A.TopIndex DESC,A.LastUpdateTime DESC");

          //  clsSharedHelper.WriteInfo(strSQL);

            sqlParams.Clear(); 
            sqlParams.Add(new SqlParameter("@sphh", sphh));                        
            DataTable dtEvaluation;
            strInfo = dal.ExecuteQuerySecurity(strSQL, sqlParams, out dtEvaluation); 
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat(clsSharedHelper.Error_Output, "评论查询失败！错误：", strInfo));
                clsSharedHelper.WriteInfo(string.Concat(clsSharedHelper.Error_Output, "评论查询失败！"));
                return;
            }
             
            jsonBuder.Append(@"
                ""evaluations"": [");

            string imgUrlHead = clsConfig.GetConfigValue("OA_WebPath");
            string imgs;
            string[] imgsList;
            foreach (DataRow dr in dtEvaluation.Rows)
            {
                if ((string)dr["userimg"] == "")
                {
                    dr["userimg"] = "../../res/img/StoreSaler/default-userimg.png";
                }
                else
                {
                    dr["userimg"] = getMiniImage(ref imgUrlHead, (string)dr["userimg"]);
                    //if (clsWXHelper.IsWxFaceImg((string)Convert.ToString(dr["userimg"]))) dr["userimg"] = clsWXHelper.GetMiniFace((string)Convert.ToString(dr["userimg"]));
                    //else dr["userimg"] = string.Concat(imgUrlHead, dr["userimg"]);
                }

                jsonBuder.AppendFormat(@"{{
                        ""id"": ""{0}"",
                        ""userimg"": ""{1}"",
                        ""username"": ""{2}"",
                        ""ogroup"": ""{3}"",
                        ""etype"": ""{4}"",
                        ""centent"": ""{5}！"",
                        ""date"": ""2016-09-11"",
                        ""img"": [", dr["id"], dr["userimg"], dr["username"], dr["ogroup"], dr["etype"], dr["centent"], Convert.ToDateTime(dr["mydate"]).ToString("yyyy-MM-dd HH:mm:ss"));


                imgs = Convert.ToString(dr["imgs"]);


                string imgID = "";
                if (imgs != "")
                {
                          
                    imgsList = imgs.Split('|');
                    for (int i = 0; i < imgsList.Length - 1; i++)
                    {      
                        imgID += "\""+Convert.ToString(imgsList[i].Split('-')[0])+"\",";
                        imgsList[i] = imgsList[i].Split('-')[1];
                        
                        imgsList[i] = getMiniImage(ref imgUrlHead, imgsList[i]);
                        jsonBuder.AppendFormat(@"""{0}"",", imgsList[i]);                     
                    }
                    jsonBuder.Remove(jsonBuder.Length - 1, 1);
                    imgID=imgID.TrimEnd(',');
                }
                jsonBuder.Append(@"],""imgID"":["+ imgID+ @"] },");

            }
            if (dtEvaluation.Rows.Count > 0) jsonBuder.Remove(jsonBuder.Length - 1, 1);
            

            if (dtEvaluation != null) { dtEvaluation.Clear(); dtEvaluation.Dispose(); }
            jsonBuder.Append(@"]
                          }");
            //处理评论详情结束
        }

        string json = jsonBuder.ToString();
        jsonBuder.Length = 0;
        clsSharedHelper.WriteInfo(json);        
    }

    /// <summary>
    /// 获取缩略图路径
    /// </summary>
    /// <param name="imgUrlHead"></param>
    /// <param name="sourceImage"></param>
    /// <returns></returns>
    private string getMiniImage(ref string imgUrlHead, string sourceImage)
    {
        if (clsWXHelper.IsWxFaceImg(sourceImage)) return clsWXHelper.GetMiniFace(sourceImage);
        else return string.Concat(imgUrlHead, sourceImage);
    }
    
    
    private string ClickLikes(string id)
    {
        string rt = "", errInfo = "";
        string mySql = @"if exists(select * from wx_t_OFBLikesRecord where parentID=@parentID and customerID=@customerID)
                        begin
                        select a.customerID,a.customerName,'cancel' as operate,b.LikeNum-1 as LikeNum from wx_t_OFBLikesRecord a INNER JOIN  wx_t_OpinionFeedback b ON a.ParentID=b.ID where a.parentID=@parentID and a.customerID=@customerID
                        delete wx_t_OFBLikesRecord where parentID=@parentID and customerID=@customerID
                        update wx_t_OpinionFeedback set LikeNum=LikeNum-1 where ID=@parentID
                        end
                        else
                        begin
                        insert into wx_t_OFBLikesRecord(ParentID,customerID,customerName) values(@parentID,@customerID,@customerName)
                        update wx_t_OpinionFeedback set LikeNum=LikeNum+1 where ID=@parentID
                        select a.customerID,a.customerName,'addLike' as operate,b.LikeNum from wx_t_OFBLikesRecord a INNER JOIN  wx_t_OpinionFeedback b ON a.ParentID=b.ID  where a.parentID=@parentID and a.customerID=@customerID
                        end";
        DataTable dt;
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@parentID", id));
        para.Add(new SqlParameter("@customerID", Convert.ToString(Session["qy_customersid"])));
        para.Add(new SqlParameter("@customerName", Convert.ToString(Session["qy_cname"])));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
        }

        if (errInfo != "")
        {
            rt = clsNetExecute.Error+ errInfo;
        }
        else
        {
            rt =JsonHelp.dataset2json(dt);
            dt.Clear();
            dt.Dispose();
        }
        return rt;
    }
    private string AddComment(string sphh, string coment)
    {
        
        string rt = "",mdid="",errInfo;
        if (RoleName == "zb" || RoleName == "kf")
        {
            mdid = "1";
        }
        else
        {
            mdid = Convert.ToString(Session["mdid"]);
        }

        string mysql = @"DECLARE @id int;
                        INSERT INTO wx_t_OpinionFeedback(OFBContent,OFBGroupID,CreateTime,CreateName,CreateCustomerID,mdid)
                        VALUES(@OFBContent,1,GETDATE(),@username,@CreateCustomerID,@mdid);
                        SET @id=SCOPE_IDENTITY(); select @id as id,ISNULL(avatar,'') AS headImg from wx_t_customers  where id=@CreateCustomerID";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@OFBContent",coment));
        para.Add(new SqlParameter("@username", Session["qy_cname"]));
        para.Add(new SqlParameter("@CreateCustomerID", Session["qy_customersid"]));
        para.Add(new SqlParameter("@mdid", mdid));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, para, out dt);
            if (errInfo != "")
            {
                return clsNetExecute.Error+ errInfo;
            }
            para.Clear();
            mysql = "INSERT INTO wx_t_RelateToSphh(RelateTableID,sphh,scanResult) VALUES(@RelateTableID,@sphh,@scanResult);";
            List<SqlParameter> para1 = new List<SqlParameter>();
            para1.Add(new SqlParameter("@RelateTableID", dt.Rows[0][0]));
            para1.Add(new SqlParameter("@sphh", sphh));
            para1.Add(new SqlParameter("@scanResult",sphh));
            errInfo = dal.ExecuteNonQuerySecurity(mysql, para1);
            if (errInfo != "")
            {
                return clsNetExecute.Error + errInfo;
            }
        }
        rt = string.Format("{{\"id\":\"{0}\",\"cname\":\"{1}\",\"date\":\"{2}\",\"headImg\":\"{3}\"}}", dt.Rows[0]["id"].ToString(), Session["qy_cname"], DateTime.Now.ToString(), dt.Rows[0]["headImg"].ToString());
        return rt;
    }
    public string GetCommentList(string sphh, string maxId)
    {
        if (sphh.Length != 9)
        {
           return clsNetExecute.Error + "货号有误!";
        }
        string rt = "",errInfo="",filter="";
        string mySql = @"SELECT top 10 a.id, ISNULL(c.avatar,'') AS headImg,c.cname,a.OFBContent,a.LikeNum,a.CreateTime
                    FROM dbo.wx_t_OpinionFeedback a INNER JOIN wx_t_RelateToSphh b ON a.id=b.RelateTableID AND a.OFBGroupID=1
                    INNER JOIN dbo.wx_t_customers c ON a.CreateCustomerID=c.ID 
                    WHERE a.IsDel=0 AND  b.sphh=@sphh ";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@sphh",sphh));
        if (RoleName == "dz")
        {
          mySql=string.Concat(mySql," AND a.CreateCustomerID=@customerID");
          para.Add(new SqlParameter("@customerID", Convert.ToString(Session["qy_customersid"])));
        }
        if (maxId != "-1")
        {
            filter = " and a.id<@maxId ";
            para.Add(new SqlParameter("@maxId", maxId));
        }
        mySql = string.Concat(mySql,filter," order by a.id desc");
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt); 
        }
        if (errInfo != "")
        {
            rt = clsNetExecute.Error + errInfo;
        }
        else
        {
            rt = JsonHelp.dataset2json(dt);
            dt.Clear();
            dt.Dispose();
        }
        return rt;
    }
    
    //商品库存
    //加载货号对应的库存信息
    public string LoadGoodsStock(string mdid, string sphh, string StockType)
    {
        string sql, rt = "", errInfo;
        string connecting = queryConnStr;
        string tzid=mdid;

        using (LiLanzDALForXLM mydal = new LiLanzDALForXLM(OAConnStr))
        {
            object objtzid = new object();
            if (RoleName == "dg" || RoleName == "dz")
            {
                errInfo = mydal.ExecuteQueryFast(string.Format("select khid from t_mdb where mdid={0}", tzid), out objtzid);
                if (errInfo == "")
                {
                    tzid = objtzid.ToString();
                }
            }

            if (StockType == "dhl")
            {
                errInfo = mydal.ExecuteQueryFast(string.Format("select ssid from yx_t_khb where khid={0}", tzid), out objtzid);
                if (errInfo == "")
                {
                    tzid = objtzid.ToString();
                }
            }
        }

        
        LiLanzDALForXLM dal = new LiLanzDALForXLM(queryConnStr);
        switch (StockType)
        {
            case "kcxx":
                if (RoleName == "dg" || RoleName == "dz")//门店人员，根据mdid来查门店数据
                {
                    sql = @"select top 20 a.cm,SUM(ISNULL(b.sl0,0)) sl
                        from  yx_t_cmzh a
                        inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1
                        left join(
                            select a.cmdm,a.sl0
                            FROM t_mdb md INNER JOIN  yx_t_spkccmmx a ON md.khid=a.tzid 
                            where md.mdid='{1}' and a.sphh='{0}' 
                        ) b on a.cmdm=b.cmdm
                        where a.tzid=1 
                        GROUP BY a.cm order by a.cm";
                }
                else//贸易公司或总部人员根据tzid来查
                {
                    tzid = mdid;
                    sql = @"select top 20 a.cm,SUM(ISNULL(b.sl0,0)) sl
                        from  yx_t_cmzh a
                        inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1 
                        left join(
                            select a.cmdm,a.sl0
                            from yx_t_spkccmmx a
                            where a.tzid='{1}' and a.sphh='{0}' 
                        ) b on a.cmdm=b.cmdm
                        where a.tzid=1 
                        GROUP BY a.cm order by a.cm";
                }
                break;
            case "dhl":
               /* if (RoleName == "dg" || RoleName == "dz")
                {
                    sql = @"SELECT a.cm,SUM(ISNULL(b.sl0,0)) AS sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1 
                                LEFT JOIN (SELECT cmdm,sl0 FROM t_mdb a inner join dbo.yx_v_dddjcmmx  b on a.khid=b.tzid 
                                WHERE djlx=201 AND djbs=1 AND sphh='{0}' AND a.mdid={1}) b ON a.cmdm=b.cmdm 
                                GROUP BY a.cm order by a.cm";
                }
                else
                {
                    tzid = mdid;
                    sql = @"SELECT a.cm,SUM(ISNULL(b.sl0,0)) AS sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1 
                                LEFT JOIN (SELECT cmdm,sl0 FROM dbo.yx_v_dddjcmmx
                                WHERE djlx=201 AND djbs=1 AND sphh='{0}' AND zmdid={1}) b ON a.cmdm=b.cmdm 
                                GROUP BY a.cm
                                order by a.cm";
                }*/
                sql = @"SELECT a.cm,SUM(ISNULL(b.sl0,0)) AS sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1 
                                LEFT JOIN (SELECT cmdm,sl0 FROM dbo.yx_v_dddjcmmx
                                WHERE djlx=201 AND djbs=1 AND sphh='{0}' AND zmdid={1}) b ON a.cmdm=b.cmdm 
                                GROUP BY a.cm
                                order by a.cm";
               
                break;
            case "xsl": sql = @"select a.cmdm,a.sl*(a.djlb/abs(a.djlb)) sl INTO #temp
                                from zmd_V_lsdjmx a
                                WHERE a.djbs=1 AND a.sphh='{0}' and a.khid in(SELECT b.khid 
                                                                              FROM yx_t_khb a INNER JOIN yx_t_khb b ON b.ccid+'-' LIKE a.ccid+'-%' AND b.ty=0
                                                                              INNER JOIN yx_t_khfl c ON b.khfl=c.cs  WHERE a.khid={1} ) 
                               
                                select top 20 a.cm,SUM(ISNULL(b.sl,0)) sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1
                                left JOIN #temp b on a.cmdm=b.cmdm
                                where a.tzid=1 
                                GROUP BY a.cm order by a.cm
                                DROP TABLE #temp ";
                break;
            case "zzl": sql = @"select top 20 a.cm,SUM(ISNULL(tc.sl,0)-ISNULL(dd.sl,0)) sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1
                                LEFT JOIN (
                                SELECT  b.cmdm,SUM(b.sl0) AS sl 
                                FROM yx_t_tcjhb a INNER JOIN yx_t_tcjhcmmx b ON a.id=b.id WHERE a.sphh='{0}' and a.shbs=1
                                GROUP BY b.cmdm) tc ON a.cmdm=tc.cmdm
                                LEFT JOIN (
                                SELECT  cmdm,SUM( sl0) AS sl
                                FROM dbo.yx_v_dddjcmmx WHERE sphh='{0}' AND djlx=201
                                GROUP BY cmdm ) dd ON a.cmdm=dd.cmdm 
                                GROUP BY a.cm";
                break;
            case "bhl": sql = @"select top 20 a.cm,SUM(ISNULL(b.sl0,0)) sl
                                from  yx_t_cmzh a
                                inner join YX_T_Spdmb c on a.tml=c.tml and c.sphh='{0}' and c.tzid=1
                                left join(SELECT sl0-dbdf0-qtdf0 AS sl0,cmdm FROM dbo.YX_T_Spkccmmx WHERE sphh='{0}' AND tzid=1) b on a.cmdm=b.cmdm
                                where a.tzid=1 
                                GROUP BY a.cm
                                order by a.cm";
                break;
            default: sql = ""; break;
        }
        switch (StockType)
        {
            case "kcxx":
            case "dhl": if (dal.GetDBName(Convert.ToInt32(tzid)).ToUpper() == "FXDB")
                {
                    connecting = FXDBConStr;
                }
                else if (dal.GetDBName(Convert.ToInt32(tzid)).ToUpper() == "ERPDB")
                {
                    connecting = ERPDBConStr;
                }
                else if (dal.GetDBName(Convert.ToInt32(tzid)).ToUpper() == "TLSOFT")
                {
                    connecting = OAConnStr;
                }
                break;
            case "xsl": connecting = queryConnStr; break;
            case "zzl":
            case "bhl": connecting = OAConnStr;
                break;
            default: sql = ""; break;
        }
        //需要增加判断sql合法性
        sql = string.Format(sql, sphh, mdid);
        DataTable dt;
        dal.ConnectionString = connecting;
        errInfo = dal.ExecuteQuery(sql, out dt);
        dal.Dispose();
        
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            rt = JsonHelp.dataset2json(dt);
          //  clsJsonHelper json = clsJsonHelper.CreateJsonHelper(rt);
           // json.AddJsonVar("TotalSl", dt.Compute("sum(sl)", "").ToString());
        }
        return rt;
    }
    
    //主商品信息
    public string goodsList(string mdid, string lastId, string filter)
    {
        string errInfo, rt, strsql, sql_tj = "", sqlfilter = " GROUP by  b.sphh,c.kfbh,c.id ";
        string RoleName = Convert.ToString(Session["RoleName"]);
        string ConString=OAConnStr,tzid=mdid;
        
        if (RoleName == "dg" || RoleName == "dz")//导购店长的门店ID换取khid
        {
            object objtzid = null;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                errInfo = dal.ExecuteQueryFast(string.Format("select khid from t_mdb where mdid={0}",mdid),out objtzid);
                if (errInfo == "")
                {
                    tzid = objtzid.ToString();
                }
            }
        }
        if (lastId != "-1")
        {
            sql_tj = string.Format("and c.id<{0}", lastId);
        }

        if (!string.IsNullOrEmpty(filter))
        {
            string[] filArry = filter.Split('|');
            switch (filArry[0])
            {
                case "sphh": sqlfilter = string.Concat(string.Format(" and b.sphh like '{0}%'", filArry[1]), sqlfilter); break;
                case "kczt":
                    if (filArry[1] == "1")
                    {
                        sqlfilter = string.Concat(sqlfilter, " having SUM(b.sl0)>0");
                    }
                    else
                    {
                        sqlfilter = string.Concat(sqlfilter, " having SUM(b.sl0)<=0");
                    }
                    break;//库存状态
                case "splb": sqlfilter = string.Concat(string.Format(" and splb.mc like '%{0}%'", filArry[1]), sqlfilter); break;
                case "yxzt": sqlfilter = string.Concat(" and c.ztbs=1 ", sqlfilter); break;
            }
        }

        if (RoleName == "dg" || RoleName == "dz")//门店人员，根据mdid来查门店数据
        {
            strsql = @"select top 12 c.kfbh,b.sphh,max(c.ypmc) as spmc,MAX(c.yphh) as yphh,MAX(c.lsdj) as lsdj,SUM(b.sl0)  as kc,'' as urlAddress,c.id AS xh
                        FROM t_MDb a INNER JOIN  yx_t_spkccmmx b ON a.khid=b.tzid AND a.ckid=b.ckid  inner join YX_T_ypdmb c on b.sphh=c.sphh and c.tzid=1 
                        inner join YX_T_Splb splb on c.splbid=splb.id 
                        where a.mdid={0}  and left(c.sphh,4)<>'5dzp'  {1} {2} 
                         ORDER by c.kfbh desc,c.id desc;";
        }
        else//贸易公司或总部人员根据tzid来查
        {
            strsql = @"select top 12 c.kfbh,b.sphh,max(c.ypmc) as spmc,MAX(c.yphh) as yphh,MAX(c.lsdj) as lsdj,SUM(b.sl0)  as kc,'' as urlAddress,c.id AS xh
                    from yx_t_spkccmmx b inner join YX_T_ypdmb c on b.sphh=c.sphh and c.tzid=1 
                    inner join YX_T_Splb splb on c.splbid=splb.id 
                    where b.tzid={0}  and left(c.sphh,4)<>'5dzp' {1} {2}
                    ORDER by c.kfbh desc,c.id desc;";
        }
        strsql = string.Format(strsql,mdid,sql_tj,sqlfilter);

        DataTable dt = new DataTable();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConString))
        {
            if (dal.GetDBName(Convert.ToInt32(tzid)).ToUpper() == "FXDB")
            {
                ConString = FXDBConStr;
            }
            else if (dal.GetDBName(Convert.ToInt32(tzid)).ToUpper() == "ERPDB")
            {
                ConString = ERPDBConStr;
            }

            dal.ConnectionString = ConString;

            
            errInfo = dal.ExecuteQuery(strsql, out dt);
        }

        if (errInfo != "")
        {
            rt = clsNetExecute.Error + errInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "未找到关联商品";
          //  rt = "Error:未找到相关商品!";
        }
        else
        {
            GoodsPic(ref dt);
            rt = JsonHelp.dataset2json(dt);
            dt.Dispose();
        }
        return rt;
    }
    //获取商品图片
    public string GoodsPic(ref DataTable dt)
    {
        string strsphhs = "'ZZZ'", errinfo, rt;
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            strsphhs = string.Concat(strsphhs, string.Format(",'{0}'", dt.Rows[i]["sphh"].ToString()));
        }
        if (strsphhs != "")
        {
            string strsql = string.Format(@" select top 100 sphh,yphh,picUrl from yx_v_goodPicInfo where dataType=1 and sphh in ({0}) and picXh=1", strsphhs);
            DataTable dt_url = new DataTable();
            using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
            {
                errinfo = MDal.ExecuteQuery(strsql, out dt_url);
            }

            if (errinfo != "")
            {
                rt = errinfo;
            }
            else if (dt.Rows.Count < 1)
            {
                rt = clsNetExecute.Error + "未找到关联商品图片";
            }
            else
            {
                for (int i = 0; i < dt_url.Rows.Count; i++)
                {
                    DataRow[] dr = dt.Select("sphh='" + dt_url.Rows[i]["sphh"].ToString() + "'");
                    dr[0]["urlAddress"] = dt_url.Rows[i]["picUrl"].ToString();
                }
                rt = clsNetExecute.Successed;
                dt_url.Dispose();
            }
        }
        else
        {
            rt =clsNetExecute.Error+ "无商品信息";
        }
        return rt;
    }

    //商品信息 2016-09-20 liqf增加质检报告PDF的查询
    public string goodsDetail(string sphh,string showType,string mdid)
    {
        string errorInfo, rt, strsql;

        strsql = string.Format(@"
                                select a.gzid,a.mxid,a.[text] into #zb from (
                                    --外贴
                                    SELECT a.id gzid,c.mxid,c.[text]
                                    FROM cl_T_sygzb a
                                    INNER JOIN dbo.YX_T_Spdmb sp ON sp.sku=a.chdm
                                    INNER JOIN ghs_t_zldamxb c ON c.zd='sygzb_tp' AND c.mlid=a.id
                                    WHERE a.gzlx='3311' AND sp.sphh='{0}' 
                                    union all
                                    --自制      
                                    SELECT a.id gzid,z.mxid,z.[text]
                                    FROM cl_T_sygzb a
                                    INNER JOIN zw_t_htylddmx b ON b.mxid = a.lymxid
                                    INNER JOIN cl_T_chdmb ch ON ch.chmc = b.sphh AND ch.tzid = 1
                                    INNER JOIN dbo.zw_t_htdddjb zb ON zb.id = b.id AND zb.zdbs = 5
                                    INNER JOIN cl_v_cgjh_ddmx c ON c.chdm = ch.chdm AND c.htddid = b.id
                                    INNER JOIN dbo.YX_T_Spcgjhb jh ON jh.cggzh = c.scddbh
                                    INNER JOIN dbo.YX_T_Spdmb sp ON sp.sphh = jh.sphh
                                    INNER JOIN ghs_t_zldamxb z ON z.mlid = a.id AND z.zd = 'sygzb_sg'
                                    WHERE a.gzlx ='3312' AND sp.sphh='{0}'
                                    union all                    
                                    SELECT a.id gzid,z.mxid,z.[text]
                                    FROM cl_T_sygzb a
                                    INNER JOIN zw_t_htylddmx b ON b.mxid = a.lymxid
                                    INNER JOIN cl_T_chdmb ch ON ch.chmc = b.sphh AND ch.tzid = 1
                                    INNER JOIN dbo.YX_T_Spcgjhb jh ON jh.cggzh = b.cgddh
                                    INNER JOIN dbo.YX_T_Spdmb sp ON sp.sphh = jh.sphh
                                    INNER JOIN ghs_t_zldamxb z ON z.mlid = a.id AND z.zd = 'sygzb_sg'
                                    WHERE a.gzlx ='3312' AND sp.sphh='{0}'
                                ) a
                               select sp.sphh,sp.yphh,isnull(c.picUrl,'') as urlAddress,isnull(c.picXh,0) xh,sp.spmc,sp.lsdj,sp.kfbh,
                               (select top 1 [text] from #zb order by gzid desc,mxid desc) qsreport
						       from yx_T_spdmb sp 
						       left join yx_v_goodPicInfo c on sp.sphh=c.sphh and c.dataType=1
						       where sp.sphh='{0}' and sp.tzid=1;
                               drop table #zb;", sphh);
        DataTable dt = new DataTable();
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
        {
            errorInfo = MDal.ExecuteQuery(strsql, out dt);
        }

        if (errorInfo != "")
        {
            rt = errorInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "未找到关联商品图片";
        }
        else
        {
            rt = "";
        }

        clsJsonHelper gdJson = new clsJsonHelper();
        if (rt == "")
        {
            gdJson.AddJsonVar("goodDetail", JsonHelp.dataset2json(dt), false);
            dt.Dispose();
        }
        else
        {
          gdJson.AddJsonVar("goodDetail", rt);
        }

        if (showType == "1" && mdid != "")
        {
            string goodsStock = LoadGoodsStock(mdid, sphh, "kcxx");

            if (goodsStock.IndexOf(clsNetExecute.Error) >= 0)
            {
                gdJson.AddJsonVar("goodsStock", goodsStock);
            }
            else
            {
                gdJson.AddJsonVar("gStock", goodsStock, false);
            }
        }
        return gdJson.jSon;
    }
    private string otherDetail(string mdid, string sphh)
    {
        string rt = "",errInfo="",sql="";
        clsJsonHelper ogdJson = new clsJsonHelper();

        string RoleName = Convert.ToString(Session["RoleName"]);
        if (RoleName == "dz")
        {
            sql = string.Format("SELECT count(1)  FROM dbo.wx_t_OpinionFeedback a INNER JOIN wx_t_RelateToSphh b ON a.id=b.RelateTableID where b.sphh='{0}' AND a.CreateCustomerID='{1}'  and a.IsDel=0  ", sphh, Convert.ToString(Session["qy_customersid"]));
        }
        else if (RoleName == "zb" || RoleName == "kf")
        {
            sql = string.Format("SELECT count(1)  FROM dbo.wx_t_OpinionFeedback a INNER JOIN wx_t_RelateToSphh b ON a.id=b.RelateTableID where b.sphh='{0}' and a.IsDel=0", sphh);
        }
        
        if (sql != "")
        {
            DataTable dt;
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConStr))
            {
                errInfo = dal.ExecuteQuery(sql, out dt);
               
                if (errInfo == "" && dt.Rows.Count > 0)
                {
                    ogdJson.AddJsonVar("OFBNum", Convert.ToString(dt.Rows[0][0]));
                }
                else
                {
                    ogdJson.AddJsonVar("OFBNum", "0");
                }
                dt.Clear(); dt.Dispose();
            }
        }

      //  clsLocalLoger.WriteInfo("WXConStr:" + WXConStr + "|sql=" + sql);
        string temp = LoadCMInfos(sphh);
        if (temp.IndexOf(clsNetExecute.Error)>=0)
        {
            ogdJson.AddJsonVar("CMInfos", temp);
        }
        else
        {
            ogdJson.AddJsonVar("CMInfos", temp, false);
        }

        temp = loadTheSameType(sphh);
        if (temp.IndexOf(clsNetExecute.Error) >= 0)
        {
            ogdJson.AddJsonVar("TheSameType", temp);
        }
        else
        {
            ogdJson.AddJsonVar("TheSameType", temp, false);
        }

        temp = loadVideos(sphh);
        if (temp.IndexOf(clsNetExecute.Error) >= 0)
            ogdJson.AddJsonVar("sphhvcrs", temp);
        else
            ogdJson.AddJsonVar("sphhvcrs", temp, false);
        
        temp = goodsImg(sphh);
        if (temp.IndexOf(clsNetExecute.Error) >= 0)
        {
            ogdJson.AddJsonVar("goodsImg", temp);
        }
        else
        {
            ogdJson.AddJsonVar("goodsImg", temp,false);
        }
        rt = ogdJson.jSon;
        return rt;
    }
    public string LoadCMInfos(string sphh)
    {
        string rt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            string str_sql = @"declare @sql varchar(8000);declare @tsql varchar(8000);declare @sid int;
                                select @tsql='';
                                select @sid=max(a.id) from yf_t_ytfab a inner join yf_T_ytfamxb b on a.id=b.id where a.lx='bx' and a.dm=@sphh group by a.dm;
                                select @tsql=@tsql+' max(case when a.mc='''+a.mc+''' then convert(varchar,a.sz) else '''' end) '''+a.mc+''''+','
                                from (select distinct mc from yf_T_ytfamxb where id=@sid) a;
                                if @tsql=''
                                select '00';
                                else
                                begin
                                select @tsql=substring(@tsql,1,len(@tsql)-1);
                                select @sql=' select cm.cm ''尺码'','+@tsql+' from yf_t_ytfamxb a inner join yx_t_cmzh cm on cm.cmdm=a.dm where a.id='+convert(varchar,@sid)+' and cm.tml='''+isnull((select tml from yx_t_spdmb where sphh=@sphh),'')+''' group by cm.cm order by len(cm.cm)';
                                exec(@sql);
                                end";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@sphh", sphh));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
            if (errinfo == "")
            {
                if (dt.Rows.Count > 0 && Convert.ToString(dt.Rows[0][0]) != "00")
                {
                    rt = JsonHelp.dataset2json(dt);
                    dt.Dispose();
                }
                else
                    rt = clsNetExecute.Error + "：无相关尺码";
            }
            else
            {
                rt=errinfo;
            }
        }
        return rt;
    }
    
    //加载商品的VCR
    public string loadVideos(string sphh) {
        string errinfo, vcrs;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConStr)) {
            string str_sql = @"declare @kfbh varchar(20);declare @splbid int;
                                select @kfbh=kfbh,@splbid=splbid from [192.168.35.10].tlsoft.dbo.yx_t_spdmb where sphh=@sphh;
                                select distinct videoname,videosrc,videothumb,videotimes
                                from wx_t_goodsvcr 
                                where isdel=0 and (kfbh=isnull(@kfbh,'') and splbid=isnull(@splbid,0)) or sphh=@sphh";
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@sphh", sphh));
            DataTable dt;
            errinfo = dal.ExecuteQuerySecurity(str_sql,para,out dt);
            if (errinfo == "" && dt.Rows.Count > 0)
                vcrs = JsonHelp.dataset2json(dt);
            else
                vcrs = clsNetExecute.Error + "查无VCR";
            dt.Clear(); dt.Dispose();            
            return vcrs;
        }//end using
    }
    
    //加载同款商品，要确定要不要根据门店库存情况来显示
    public string loadTheSameType(string sphh)
    {
        string errInfo;
        string rt;
        string mysql = @"SELECT TOP 100 b.id,b.sphh,b.spmc,b.lsdj,MAX(ISNULL(p.picUrl,'')) AS urlAddress
                        FROM dbo.YX_T_Spdmb a 
                        INNER JOIN dbo.YX_T_Spdmb b ON a.spkh=b.spkh AND a.sphh='{0}' AND b.sphh<>a.sphh 
                        LEFT JOIN yx_v_goodPicInfo p ON b.sphh=p.sphh
                        GROUP BY b.id, b.sphh,b.spmc,b.lsdj";
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(string.Format(mysql, sphh), out dt);
        }
        if (errInfo == "" && dt.Rows.Count > 0)
        {
            rt = JsonHelp.dataset2json(dt);
        }
        else
        {
            rt = clsNetExecute.Error + ":查无同款";
        }
        dt.Dispose();
        return rt;
    }
    public string goodsImg(string sphh)
    {
        string errorInfo, rt;
        string strsql = @" 	select a.sphh,a.spmc,isnull(c.cpmd,'')  AS cpmd,isnull(c.mlcf,'') mlcf,isnull(urlAddress,'') urlAddress
                            From yx_t_spdmb a 
                            inner join t_uploadfile b on a.id=b.tableid and b.groupid=8 
                            left outer join yx_t_cpinfo c on a.sphh=c.sphh 
                            where a.sphh=@sphh ;";

        List<SqlParameter> param = new List<SqlParameter>();
        param.Add(new SqlParameter("@sphh", sphh));
        DataTable dt = new DataTable();
        using (LiLanzDALForXLM MDal = new LiLanzDALForXLM(OAConnStr))
        {
            errorInfo = MDal.ExecuteQuerySecurity(strsql, param, out dt);
        };
        if (errorInfo != "")
        {
            rt = clsNetExecute.Error + errorInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "无商品图片";
        }
        else
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                dt.Rows[i]["cpmd"] = HttpUtility.UrlEncodeUnicode(Convert.ToString(dt.Rows[i]["cpmd"]));
            }
            rt = JsonHelp.dataset2json(dt);
            dt.Dispose();
        }
        dt.Dispose();
        return rt;
    }

    
    private string getScanSphh(string scanType, string scanResult)
    {
        string errInfo,mysql,rt = "";
        switch (scanType)
        {
            case "qrCode": mysql = @"declare @strGood varchar(30) select @strGood=dbo.f_DBPwd('{0}') 
                        select @strGood = (CASE WHEN (LEN(@strGood) > 13) 
                        THEN SUBSTRING(@strGood, 1, LEN(@strGood) - 6) ELSE @strGood END) 
                        select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood 
                        SELECT @strGood as sphh";
                break;
            case "barCode": mysql = @"declare @strGood varchar(30)  select @strGood = SUBSTRING('{0}', 1, LEN('{0}') - 6)
                          select top 1 @strGood = a.sphh from yx_t_tmb a where tm=@strGood ; SELECT @strGood  as sphh ";
                break;
            default: mysql = "";
                break;
        }
        DataTable dt;
        if (mysql != "")
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                errInfo = dal.ExecuteQuery(string.Format(mysql, scanResult), out dt);
            }
            if (errInfo != "")
            {
                rt = errInfo;
            }
            else if (dt.Rows.Count < 1)
            {
                rt = clsNetExecute.Error + "无效条码，无法找到相关信息";
            }
            else
            {
                rt = Convert.ToString(dt.Rows[0]["sphh"]);
                dt.Dispose();
            }
        }
        else
        {
            rt =clsNetExecute.Error+ "非法访问。";
        }
        return rt;
    }
  

    //写日志
    private void WriteLog(string strText)
    {
        String path = HttpContext.Current.Server.MapPath("logs/");
        if (!System.IO.Directory.Exists(System.IO.Path.GetDirectoryName(path)))
        {
            System.IO.Directory.CreateDirectory(path);
        }

        System.IO.StreamWriter writer = new System.IO.StreamWriter(path + DateTime.Now.ToString("yyyyMMdd") + ".log", true);
        string str;
        str = "【" + DateTime.Now.ToString() + "】" + "  " + strText;
        writer.WriteLine(str);
        writer.Close();
    }
</script>

<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>