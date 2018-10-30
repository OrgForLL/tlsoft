<%@ WebHandler Language="C#" Class="GenericHandler1" %>

using System;
using System.Web;
using nrWebClass;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

public class GenericHandler1 : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{

    private const string erpLink = "http://192.168.35.51:8100/files/";      //对于服务器而言的主应用层链接URL 
    private string erpOutLink = clsConfig.GetConfigValue("OA_WebPath");     //对于外部访问而言的主应用层链接URL 
    private const int scaleImgWidth = 2500;                                 //平面底图缩放到尺寸

    private string WXConnStr;// = clsConfig.GetConfigValue("WXConnStr");

    private int MiniImgWidth = 0, MiniImgHeight = 0;    //缩略图的尺寸。在处理图片时会赋值（仅GetMapInfo方法使用）
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
         
        if (clsConfig.Contains("WXConnStr"))
        {
            WXConnStr = clsConfig.GetConfigValue("WXConnStr");
        }
        else
        {
            WXConnStr = System.Web.Configuration.WebConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        }

        //SetTestMode();
        
        string ctrl = context.Request.Params["ctrl"];
        switch (ctrl)
        {
            case "GetMapInfo":        //加载指定平面图上的所有拍摄点信息
                GetMapInfo();
                break;
            //case "MapUseCurrentImage":        //直接使用当前的陈列图作为 门店平面图
            //    MapUseCurrentImage();
            //    break; 
            case "SaveCameraInfo":       //保存一个拍摄点的信息
                SaveCameraInfo();
                break;
            case "LoadCameraInfos":        //加载指定平面图上的所有拍摄点信息
                LoadCameraInfos();
                break; 
            default:
                clsSharedHelper.WriteErrorInfo("接口不存在！ctrl=" + ctrl);
                break;
        } 
        
    }

    /// <summary>
    /// 返回平面底图信息
    /// 必须的传入参数：MdImgID    /// 
    /// 正确时返回格式：{"MapInfo":[{"MapID":"1","MapImageFileSrc":"http://tm.lilanz.com/qywx/upload/StoreSaler/xxgl/my/MDID7078_20170227181004.jpg","MapImageWidth":"1400","MapImageHeight":"990","IsLoadInJmspb":"True"}]}
    /// 错误时返回：Error:错误描述
    /// </summary>
    public void GetMapInfo()
    {
        HttpContext hc = HttpContext.Current;

        string MdImgID = Convert.ToString(hc.Request.Params["MdImgID"]);

        if (string.IsNullOrEmpty(MdImgID))
        {
            clsSharedHelper.WriteErrorInfo("缺少参数：门店形象册ID。MdImgID");
            return;
        }
        
        string strInfo = "";
        string Pid = "", khid= "",mdid = "", FileName = "";
        string OldOaCon = clsConfig.GetConfigValue("OldOAConnStr");
        using (LiLanzDALForXLM wxDal = new LiLanzDALForXLM(WXConnStr))
        {
            using (LiLanzDALForXLM oaDal = new LiLanzDALForXLM(OldOaCon))
            {
                //1 判断平面图表是否已经存在该图，有则直接使用              //取到结果，则直接返回它
                if (LoadMapInfo(wxDal, MdImgID)) return;

                //2 取得这个门店形象册的门店ID 
                string strSQL = @"SELECT TOP 1 Pid,khid,mdid FROM wx_t_StoreImgForMD WHERE id = @MdImgID";
                List<SqlParameter> param = new List<SqlParameter>();
                param.Add(new SqlParameter("@MdImgID", MdImgID));

                DataTable dt;
                strInfo = wxDal.ExecuteQuerySecurity(strSQL, param, out dt);
                if (strInfo != "" || dt.Rows.Count == 0)
                {
                    clsSharedHelper.WriteErrorInfo(string.Concat("读取平面图所属门店失败！错误：", strInfo));
                    return;        //直接结束                    
                }
                Pid = Convert.ToString(dt.Rows[0]["Pid"]);
                khid = Convert.ToString(dt.Rows[0]["khid"]);
                mdid = Convert.ToString(dt.Rows[0]["mdid"]);
                clsSharedHelper.DisponseDataTable(ref dt);  //回收资源 
                
                //3 查询加盟审批表的内容 
                strSQL = @"SELECT TOP 1 B.fileName
                                FROM tlsoft.dbo.yx_t_jmspb C
                                  INNER JOIN vt_frm_jmspb A ON C.ID = A.fld_id AND C.mdid = @mdid
	                              LEFT JOIN t_accessory B ON A.punid=B.punid  
                                            WHERE   b.description='平面图'  
	                                ORDER BY C.ID DESC ";
                param.Clear();
                param.Add(new SqlParameter("@mdid", mdid));

                object objFileName = null;
                strInfo = oaDal.ExecuteQueryFastSecurity(strSQL, param, out objFileName);
                if (strInfo != "")
                {
                    clsSharedHelper.WriteErrorInfo(string.Concat("读取加盟审批数据失败！错误：", strInfo));
                    return;        //直接结束                    
                }
                FileName = Convert.ToString(objFileName);   //得到路径
                if (string.IsNullOrEmpty(FileName))
                {
                    //clsSharedHelper.WriteErrorInfo(string.Concat("没有从加盟审批数据中找到门店的'平面图'！"));
                    clsSharedHelper.WriteInfo("Self");
                    return;        //直接结束                         
                }                
                
                //4 下载到本地并生成缩略图
                string MdMapName = "";  //门店平面图命名
                MdMapName = string.Concat("MDID", mdid,"_", DateTime.Now.ToString("yyyyMMddHHmmss"));
                string MapImageFileSrc = DownloadAndCreateMiniImg(string.Concat(erpLink, FileName), MdMapName);
                if (MapImageFileSrc == "")
                {
                    clsSharedHelper.WriteErrorInfo("下载处理图片失败！请联系总部IT部处理！");
                    return;
                }
                
                //5 创建平面图对应的信息
                strSQL = @"INSERT INTO [wx_t_StoreImgMap]([MdImgID],[Pid],[khid],[mdid],[MapImageFileSrc],[MapImageWidth],[MapImageHeight])
                                VALUES (@MdImgID,@Pid,@khid,@mdid,@MapImageFileSrc,@MapImageWidth,@MapImageHeight)";
                param.Clear();
                param.AddRange(new SqlParameter[]{ new SqlParameter("@MdImgID", MdImgID), 
                                                   new SqlParameter("@Pid", Pid), 
                                                   new SqlParameter("@khid", khid), 
                                                   new SqlParameter("@mdid", mdid), 
                                                   new SqlParameter("@MapImageFileSrc", MapImageFileSrc), 
                                                   new SqlParameter("@MapImageWidth", MiniImgWidth), 
                                                   new SqlParameter("@MapImageHeight", MiniImgHeight)});
                strInfo = wxDal.ExecuteNonQuerySecurity(strSQL, param);
                if (strInfo != "")
                {
                    clsSharedHelper.WriteErrorInfo(string.Concat("创建门店平面图信息失败！错误：", strInfo));
                    return;        //直接结束                    
                }

                //重新取一次
                if (LoadMapInfo(wxDal, MdImgID) == false)
                {
                    clsSharedHelper.WriteErrorInfo(string.Concat("无法获取门店平面图，请稍后重试！错误：", strInfo));
                    return;        //直接结束                          
                } 
            }
        }
    }



//    /// <summary>
//    /// 直接使用当前的陈列图作为 门店平面图
//    /// 必须的传入参数：MdMXImgID
//    /// 必须Session["RoleName"] == dz
//    /// </summary>
//    private void MapUseCurrentImage()
//    {
//        HttpContext hc = HttpContext.Current;

//        string RoleName = Convert.ToString(hc.Session["RoleName"]);
//        string CreateID = Convert.ToString(hc.Session["qy_customersid"]);
//        string CreateName = Convert.ToString(hc.Session["qy_cname"]);
//        if (string.IsNullOrEmpty(RoleName) || string.IsNullOrEmpty(CreateID))
//        {
//            clsSharedHelper.WriteErrorInfo("访问超时，请重新登录！");
//            return;
//        }
//        else if (RoleName != "dz")
//        {
//            clsSharedHelper.WriteErrorInfo("必须进入门店管理模式，才能自行上传&创建平面图！");
//            return;
//        }


//        string MdMXImgID = hc.Request.Params["MdMXImgID"];
//        if (string.IsNullOrEmpty(MdMXImgID))
//        {
//            clsSharedHelper.WriteErrorInfo("访问超时，请重新登录！");
//            return;
//        }

//        string strInfo = "";
//        string MdImgID = "", khid = "", mdid = "", Pid = "", AddressURL = "";
//        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
//        {
//            //1 首先读取当前已上传的图片
//            string strSQL = @"  SELECT TOP 1 A.MdImgID,B.khid,B.mdid,B.Pid,A.AddressURL FROM wx_t_StoreImgMXForMD A
//	                                INNER JOIN wx_t_StoreImgForMD B ON A.MdImgID = B.ID
//                                WHERE A.ID = @MdMXImgID";
//            List<SqlParameter> param = new List<SqlParameter>();
//            param.Add(new SqlParameter("@MdMXImgID", MdMXImgID));
//            DataTable dt;
//            strInfo = dal.ExecuteQuerySecurity(strSQL, param, out dt);
//            if (strInfo != "")
//            {
//                clsSharedHelper.WriteErrorInfo(string.Concat("加载陈列图信息失败！错误：", strInfo));
//                return;        //直接结束                    
//            }
//            if (dt.Rows.Count == 0)
//            {
//                clsSharedHelper.WriteErrorInfo(string.Concat("必须先上传陈列图！"));
//                return;        //直接结束                            
//            }

//            MdImgID = Convert.ToString(dt.Rows[0]["MdImgID"]);
//            khid = Convert.ToString(dt.Rows[0]["khid"]);
//            mdid = Convert.ToString(dt.Rows[0]["mdid"]);
//            Pid = Convert.ToString(dt.Rows[0]["Pid"]);
//            AddressURL = Convert.ToString(dt.Rows[0]["AddressURL"]);

//            clsSharedHelper.DisponseDataTable(ref dt);//回收资源

//            //2 将图片（原图）生成缩略图
//            AddressURL = AddressURL.Replace("/my/", "/");
//            AddressURL = hc.Server.MapPath(string.Concat("../../", AddressURL));

//            string MdMapName = "";  //门店平面图命名
//            MdMapName = string.Concat("MDID", mdid, "_", DateTime.Now.ToString("yyyyMMddHHmmss"));
//            string MapImageFileSrc = CopyAndCreateMiniImg(AddressURL, MdMapName);
//            if (MapImageFileSrc == "")
//            {
//                clsSharedHelper.WriteErrorInfo("拷贝处理图片失败！请联系总部IT部处理！");
//                return;
//            }

//            //3 创建平面图对应的信息
//            strSQL = @"INSERT INTO [wx_t_StoreImgMap]([MdImgID],[Pid],[khid],[mdid],[MapImageFileSrc],[MapImageWidth],[MapImageHeight],CreateID,CreateName,IsLoadInJmspb)
//                                VALUES (@MdImgID,@Pid,@khid,@mdid,@MapImageFileSrc,@MapImageWidth,@MapImageHeight,@CreateID,@CreateName,@IsLoadInJmspb)";
//            param.Clear();
//            param.AddRange(new SqlParameter[]{ new SqlParameter("@MdImgID", MdImgID), 
//                                                   new SqlParameter("@Pid", Pid), 
//                                                   new SqlParameter("@khid", khid), 
//                                                   new SqlParameter("@mdid", mdid), 
//                                                   new SqlParameter("@MapImageFileSrc", MapImageFileSrc), 
//                                                   new SqlParameter("@MapImageWidth", MiniImgWidth), 
//                                                   new SqlParameter("@MapImageHeight", MiniImgHeight), 
//                                                   new SqlParameter("@CreateID", CreateID), 
//                                                   new SqlParameter("@CreateName", CreateName), 
//                                                   new SqlParameter("@IsLoadInJmspb", "0")});
//            strInfo = dal.ExecuteNonQuerySecurity(strSQL, param);
//            if (strInfo != "")
//            {
//                clsSharedHelper.WriteErrorInfo(string.Concat("自助启用上传的门店平面图失败！错误：", strInfo));
//                return;        //直接结束                    
//            }

//            clsSharedHelper.WriteSuccessedInfo("");
//        }
//    }
    
    /// <summary>
    /// 保存一个摄像点信息
    /// 必须传入参数：CameraInfo 格式如：{"mapID":"1","MdImgID":"1","MdMXImgID":"1","XPec":"1","YPec ":"1","Rotate":"180"}
    /// 正确执行后返回报文：Successed
    /// 执行错误时返回报文：Error:错误描述
    /// </summary>
    public void SaveCameraInfo()
    {
        HttpContext hc = HttpContext.Current;
        string strJson = hc.Request.Params["CameraInfo"];
        
        if (string.IsNullOrEmpty(strJson))
        {
            clsSharedHelper.WriteErrorInfo("缺少参数：拍摄点信息。CameraInfo");
            return;
        }

        string mapID = "", MdImgID = "", MdMXImgID = "", XPec = "", YPec = "", Rotate = ""; 
        
        using(clsJsonHelper jh = clsJsonHelper.CreateJsonHelper(strJson)){
            mapID = jh.GetJsonValue("mapID");
            MdImgID = jh.GetJsonValue("MdImgID");
            MdMXImgID = jh.GetJsonValue("MdMXImgID");
            XPec = jh.GetJsonValue("XPec");
            YPec = jh.GetJsonValue("YPec");
            Rotate = jh.GetJsonValue("Rotate"); 
        }

        string strInfo = "";
        string strSQL = @"
            DELETE FROM wx_t_StoreImgMapMX WHERE MdImgID = @MdImgID AND MdMXImgID = @MdMXImgID
            INSERT INTO [wx_t_StoreImgMapMX]([mapID],[MdImgID],[MdMXImgID],[XPec],[YPec],[Rotate]) VALUES (@mapID,@MdImgID,@MdMXImgID,@XPec,@YPec,@Rotate)";
        List<SqlParameter> param = new List<SqlParameter>();
        param.Add(new SqlParameter("@mapID", mapID));
        param.Add(new SqlParameter("@MdImgID", MdImgID));
        param.Add(new SqlParameter("@MdMXImgID", MdMXImgID));
        param.Add(new SqlParameter("@XPec", XPec));
        param.Add(new SqlParameter("@YPec", YPec));
        param.Add(new SqlParameter("@Rotate",Rotate));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
        {
            strInfo = dal.ExecuteNonQuerySecurity(strSQL, param); 
            if (strInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("保存拍摄点信息失败！错误：", strInfo));
                return;        //直接结束                    
            }                       
        }

        clsSharedHelper.WriteSuccessedInfo(""); 
    }

    /// <summary>
    /// 加载当前店铺形象册的所有锚点信息
    /// 必须传入参数：MdImgID
    /// 传出 JSON 格式的数据
    /// </summary>
    public void LoadCameraInfos()
    {
        HttpContext hc = HttpContext.Current;
        string MdImgID = hc.Request.Params["MdImgID"]; 

        if (string.IsNullOrEmpty(MdImgID))
        {
            clsSharedHelper.WriteErrorInfo("缺少参数：门店形象册ID。MdImgID");
            return;
        } 
        string strInfo = "";
        string strSQL = @"  SELECT A.[ID],A.[mapID],B.[MdImgID],B.ID AS 'MdMXImgID',A.[XPec],A.[YPec],A.[Rotate],A.[CreateTime]
			                              ,B.AddressURL,B.FailMsg,B.Remark,B.Status,C.AddressURL 'Photo' FROM wx_t_StoreImgMXForMD B
										  INNER JOIN wx_t_StoreImgMX C ON B.InfoID = C.ID
	                            LEFT JOIN wx_t_StoreImgMapMX A ON A.MdMXImgID = B.ID
                             WHERE B.MdImgID = @MdImgID";
        List<SqlParameter> param = new List<SqlParameter>();
        param.Add(new SqlParameter("@MdImgID", MdImgID)); 
         
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(WXConnStr))
        {
            DataTable dt;
            strInfo = dal.ExecuteQuerySecurity(strSQL, param,out dt);
            if (strInfo != "")
            {
                clsSharedHelper.WriteErrorInfo(string.Concat("加载拍摄点信息失败！错误：", strInfo));
                return;        //直接结束                    
            }

            string strJson = dal.DataTableToJson(dt, "CameraInfos", true);
            clsSharedHelper.DisponseDataTable(ref dt);//回收资源

            clsSharedHelper.WriteInfo(strJson);
            strJson = "";
        } 
    }

    #region "读取并返回平面图信息"
    
    /// <summary>
    /// 加载店铺平面图信息。加载成功（或出现致命错误）返回true；找不到信息则返回false 
    /// </summary> 
    /// <returns></returns>
    private bool LoadMapInfo(LiLanzDALForXLM wxDal, string MdImgID)
    {
        List<SqlParameter> param = new List<SqlParameter>();
        string strSQL0;
        //1 判断平面图表是否已经存在该图，有则直接使用
        strSQL0 = string.Concat("SELECT TOP 1 ID AS mapID,('" , erpOutLink 
            , @"' + MapImageFileSrc) AS 'MapImageFileSrc',[MapImageWidth],[MapImageHeight],CONVERT(INT,[IsLoadInJmspb]) 'IsLoadInJmspb' 
            FROM wx_t_StoreImgMap WHERE IsActive=1 AND MdImgID = @MdImgID");

        param.Add(new SqlParameter("@MdImgID", MdImgID));

        DataTable dt0;
        string strInfo = wxDal.ExecuteQuerySecurity(strSQL0, param, out dt0);
        if (strInfo != "")
        {
            clsSharedHelper.WriteErrorInfo(string.Concat("读取平面图信息失败！错误：", strInfo));
            return true;        //直接结束
        }

        //取到结果，则直接返回它
        if (dt0.Rows.Count > 0)
        {
            strInfo = wxDal.DataTableToJson(dt0, "MapInfo", true);
            clsSharedHelper.DisponseDataTable(ref dt0);

            clsSharedHelper.WriteInfo(strInfo);                        
            return true;
        }
        else
        {
            clsSharedHelper.DisponseDataTable(ref dt0);
            return false;
        } 
    }
    
    #endregion

    #region


    /// <summary>
    /// 创建缩略图
    /// </summary>
    /// <param name="url"></param>
    /// <param name="MdMapName"></param>
    /// <returns></returns>
    private string DownloadAndCreateMiniImg(string url, string MdMapName)
    {
        string miniFileUrl = string.Concat("upload/StoreSaler/xxgl/my/", MdMapName, ".gif");

        string dirMyName = HttpContext.Current.Server.MapPath(string.Concat("../../upload/StoreSaler/xxgl/my"));
        if (!System.IO.Directory.Exists(dirMyName)) System.IO.Directory.CreateDirectory(dirMyName);
        string dirName = HttpContext.Current.Server.MapPath(string.Concat("../../upload/StoreSaler/xxgl"));
        string miniFileName = string.Concat(dirMyName, "\\", MdMapName, ".gif");

        if (System.IO.File.Exists(miniFileName)) return miniFileUrl;    //如果已经存在该文件，则不重新下载         

        string FileName = string.Concat(dirName, "\\", MdMapName, ".jpg");

        string strInfo = "";

        strInfo = DownloadFile(url, FileName);
        if (strInfo == "")
        {
            strInfo = MakeImage(FileName, miniFileName, scaleImgWidth);
        }

        if (strInfo == "")
        {
            return miniFileUrl;
        }
        else
        {

            clsLocalLoger.WriteError(string.Concat("下载图片失败！错误：", strInfo, " url=", url));

            return "";
        }
    }


    ///// <summary>
    ///// 创建缩略图
    ///// </summary>
    ///// <param name="FileFullDir">原始的完整路径</param>
    ///// <param name="MdMapName"></param>
    ///// <returns></returns>
    //private string CopyAndCreateMiniImg(string FileFullDir, string MdMapName)
    //{
    //    string miniFileUrl = string.Concat("upload/StoreSaler/xxgl/my/", MdMapName, ".gif");

    //    string dirMyName = HttpContext.Current.Server.MapPath(string.Concat("../../upload/StoreSaler/xxgl/my"));
    //    if (!System.IO.Directory.Exists(dirMyName)) System.IO.Directory.CreateDirectory(dirMyName);
    //    string dirName = HttpContext.Current.Server.MapPath(string.Concat("../../upload/StoreSaler/xxgl"));
    //    string miniFileName = string.Concat(dirMyName, "\\", MdMapName, ".gif");

    //    if (System.IO.File.Exists(miniFileName)) return miniFileUrl;    //如果已经存在该文件，则不重新下载         

    //    string FileName = string.Concat(dirName, "\\", MdMapName, ".jpg");

    //    string strInfo = "";

    //    try
    //    {
    //        System.IO.File.Copy(FileFullDir, FileName);
    //    }
    //    catch (Exception ex)
    //    {
    //        strInfo = ex.Message;
    //    }
        
    //    if (strInfo == "")
    //    {
    //        strInfo = MakeImage(FileName, miniFileName, scaleImgWidth);
    //    }

    //    if (strInfo == "")
    //    {
    //        return miniFileUrl;
    //    }
    //    else
    //    {
    //        clsLocalLoger.WriteError(string.Concat("COPY图片失败！错误：", strInfo, " FileFullDir=", FileFullDir));

    //        return "";
    //    }
    //}

    /// <summary>
    /// 处理图片成指定尺寸 方便后期的直接使用；
    /// By:xlm 由于处理成正方形可能导致图片呈现效果不理想，因此缩放即可，但是不填充成正方形。
    /// </summary>
    /// <param name="SourceImage">原始图片的文件路径</param>
    /// <param name="SaveImage">保存到目标路径</param>
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
                                   
            eImage.Save(SaveImage, System.Drawing.Imaging.ImageFormat.Gif);
            g.Dispose();

            eImage.Dispose();

            MiniImgWidth = imgWidth;
            MiniImgHeight = imgHeight;
            
            return "";
        }
        catch (Exception ex)
        {
            return string.Concat(clsSharedHelper.Error_Output, "处理图片失败！错误：", ex.Message, " SourceImage=", SourceImage, " SaveImage=", SaveImage);
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
            return string.Concat(clsSharedHelper.Error_Output, ex.Message);
        }
    }

    #endregion

    public void SetTestMode()
    {
        WXConnStr = "server='192.168.35.23';database=weChatTest;uid=lllogin;pwd=rw1894tla";
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

}