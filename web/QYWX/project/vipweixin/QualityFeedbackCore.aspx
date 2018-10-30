<%@ Page Language="C#" Debug="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    private string DBConStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
    string DBConStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");
    string vipWXid = "0",vipWXname="",vipWXmdid="0";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["openid"] == null || Session["openid"] == "")
        {
            clsSharedHelper.WriteInfo("登录超时，请重试");
            return;
        }
        else
        {
            string errInfo, mySql;
            List<SqlParameter> para = new List<SqlParameter>();
            DataTable dt;
            mySql = "select a.*,ISNULL(b.mdid,0) mdid from wx_t_vipBinging a left join YX_T_Vipkh b on a.vipID=b.id where wxOpenid=@wxOpenid ";
            para.Add(new SqlParameter("@wxOpenid", Convert.ToString(Session["openid"])));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            }
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo("查询用户出错！" + errInfo);
                return;
            }
            else if (dt.Rows.Count < 1)
            {
                clsSharedHelper.WriteInfo("未找到用户！");
                return;
            }
            else
            {
                vipWXid = Convert.ToString(dt.Rows[0]["id"]);
                vipWXname = Convert.ToString(dt.Rows[0]["wxNick"]);
                vipWXmdid = Convert.ToString(dt.Rows[0]["mdid"]);
                dt.Clear();
                dt.Dispose();
            }
        }
        
        string rt = "";
        string ctrl =  Request.Params["ctrl"];
        string OFBGroupID="4", MyDjID;
        switch (ctrl)
        {
            case "SaveImgs": 
                string rotate=Request.Params["rotate"];
                string formFile = Request.Params["formFile"];
                string SourceTableID =Convert.ToString(Request.Params["MyID"]);
                rt = saveMyImgs(formFile, vipWXid, rotate, SourceTableID);
                break;
           case "DelImg":
                string ImgID=Convert.ToString(Request.Params["ImgID"]);
                rt=DelField(ImgID);
                break;
           case "saveConten": 
                MyDjID=Convert.ToString( Request.Params["MyDjID"]);
                string content=Convert.ToString(Request.Params["content"]);
                string strPID = Convert.ToString(Request.Params["strPID"]);
                string DCategoryVal = Convert.ToString(Request.Params["DCategoryVal"]);
                rt = SaveOpinionFeedback(MyDjID, content, OFBGroupID, strPID, DCategoryVal);
                break;
          case "submitComment":
                string ID = Convert.ToString(Request.Params["MyDjID"]);
                string ComContent = Convert.ToString(Request.Params["content"]);
                rt = saveComment(ID, ComContent);
                break;
           case "addRelate":
                string sphh = Convert.ToString(Request.Params["sphh"]);
                string MyID = Convert.ToString(Request.Params["MyDjID"]);
                if (MyID == null || MyID == "0")
                {
                     if (!CreateSourceRecord(OFBGroupID, out MyID))
                     {
                         rt = MyID;
                         clsSharedHelper.WriteInfo(rt);
                         return;
                     }
                 }
                 rt = addRelate(MyID,sphh);
                break;
            case "DelRelated":
                string RID = Convert.ToString(Request.Params["ID"]);
              rt=  delRelate(RID);
                break;
            case "DelMyItem":
                string myItemId = Convert.ToString(Request.Params["ID"]);
                rt = delMyItem(myItemId);
                break;
            case "loadList":
                string maxID = Convert.ToString(Request.Params["maxID"]);
                rt = LoadMyItemList(maxID, OFBGroupID);
                break;
            case "GetDetail":
                MyDjID = Convert.ToString(Request.Params["ID"]);
                rt = GetDetail(MyDjID);
                break;
            case "loadNewList":
                MyDjID = Convert.ToString(Request.Params["MyDjID"]);
                rt = loadNewList(MyDjID);
                break;
            case "ToThumb":
                MyDjID = Convert.ToString(Request.Params["MyDjID"]);
                rt = ToThumb(MyDjID);
                break;
            default: rt = "传入参数有误！";
                break;    
        }
        clsSharedHelper.WriteInfo(rt);
    }
  private string saveMyImgs(String PicBase, String CreateID, String rotate, string SourceTableID)
    {
        string rt = "";
        string myFolder = DateTime.Now.ToString("yyyyMM");
        string pathStr = "upload/vipweixin/" + myFolder + "/";
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
        rt = MakeImage(path + filename, myPath + filename,100);

        if (rt.Equals(""))
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                DataTable dt = null;
                List<SqlParameter> paras = new List<SqlParameter>();
                String mysql = @"insert into wx_t_uploadfile(SourceTableID,TypeID,URLAddress,ThumbnailURL,CreateTime,FileName,CreateCustomerID) 
                                 values(@SourceTableID,@TypeID,@URLAddress,@ThumbnailURL,getdate(),@FileName,@CreateCustomerID);
                                     select @@identity";
                paras.Add(new SqlParameter("@SourceTableID", SourceTableID));
                paras.Add(new SqlParameter("@TypeID", "1"));
                paras.Add(new SqlParameter("@URLAddress", pathStr));
                paras.Add(new SqlParameter("@ThumbnailURL", pathStr+"my/"));
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
    private string DelField(string ImgID)
    {
        string rt = "", errInfo;
        try
        {
            DataTable dt;
            string mySql = "select * from wx_t_uploadfile where ID=@ID";
            List<SqlParameter> para = new List<SqlParameter>();
            para.Add(new SqlParameter("@ID", ImgID));

            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
                para = null;
            }
            if (errInfo != "")
            {
                rt = errInfo;
            }
            else if (dt.Rows.Count < 1)
            {
                rt = "无找到图片！";
            }
            else
            {
                string URLAddress = Convert.ToString(dt.Rows[0]["URLAddress"]);
                string ThumbnailURL = Convert.ToString(dt.Rows[0]["ThumbnailURL"]);
                string fileName = Convert.ToString(dt.Rows[0]["fileName"]);
                string file = System.Web.HttpContext.Current.Server.MapPath("~/" + URLAddress + fileName);

                if (System.IO.File.Exists(file))
                {
                    System.IO.File.Delete(file);
                    file = System.Web.HttpContext.Current.Server.MapPath("~/" + ThumbnailURL + fileName);
                    if (System.IO.File.Exists(file))
                    {
                        System.IO.File.Delete(file);
                        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
                        {
                            mySql = "delete wx_t_uploadfile where ID=@ID";
                            para = new List<SqlParameter>();
                            para.Add(new SqlParameter("@ID", ImgID));
                            errInfo = dal.ExecuteNonQuerySecurity(mySql, para);
                            if (errInfo != "")
                            {
                                rt = errInfo;
                            }
                            else
                            {
                                rt = clsNetExecute.Successed;
                            }
                        }
                    }
                    else
                    {
                        rt = "2文件不存在";
                    }
                }
                else
                {
                    rt = "1文件不存在";
                }
            }
        }catch( Exception t){
            rt = t.ToString();
            clsLocalLoger.WriteInfo(rt);
        }
        return rt;
    }
      private string SaveOpinionFeedback(string MyDjID, string Content, string OFBGroupID, string strID, string DCategoryVal)
    {
        string rt = "";
        string errInfo = "",MySql="";
        DataTable dt;
        List<SqlParameter> para = new List<SqlParameter>();
        if (MyDjID == "0" || MyDjID == "")
        {
            MySql = @"insert into wx_t_OpinionFeedback(OFBContent,OFBGroupID,CreateTime,CreateName,CreateCustomerID,mdid) 
                             values(@OFBContent,@OFBGroupID,getdate(),@CreateName,@CreateCustomerID,@mdid)
                             select @@identity";
            para.Add(new SqlParameter("@OFBContent", Content));
            para.Add(new SqlParameter("@OFBGroupID", OFBGroupID));
            para.Add(new SqlParameter("@CreateName", vipWXname));
            para.Add(new SqlParameter("@CreateCustomerID", vipWXid));
            para.Add(new SqlParameter("@mdid", vipWXmdid));
        }
        else
        {
            MySql = "update wx_t_OpinionFeedback set OFBContent=@OFBContent,IsDel=0 where ID=@ID; select ID from wx_t_OpinionFeedback where ID=@ID";
            para.Add(new SqlParameter("@OFBContent", Content));
            para.Add(new SqlParameter("@ID", MyDjID));
        }

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(MySql, para, out dt);
        }

        if (errInfo != "" )
        {
            rt = errInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt =clsNetExecute.Error+ "未找到ID";
        }
        else
        {
            if (CreateResRelate(strID, Convert.ToString(dt.Rows[0][0]), out errInfo))
            {
                rt = clsNetExecute.Successed + dt.Rows[0][0];
            }
            else
            {
                rt = errInfo;
            }
        }
        
        return rt;
    }   
    private Boolean CreateResRelate(string strPid,string parentID,out string errInfo)
    {
        Boolean myflag ;
        string mySql = "";
        string[] PIDArr = strPid.Split('|');
        List<SqlParameter> para = new List<SqlParameter>();
        for (int i = 0; i < PIDArr.Length-1; i++)
        {
            mySql += "insert into wx_t_ResRelate(ParentID,ResID) values(@ParentID," + PIDArr [i]+ ");";
        }
        para.Add(new SqlParameter("@ParentID", parentID));
        
        if (mySql != "")
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                errInfo = dal.ExecuteNonQuerySecurity(mySql, para);
            }

            if (errInfo != "")
            {
                myflag = false;
            }
            else
            {
                myflag = true;
            }
        }
        else
        {
            myflag = true;
            errInfo = "";
        }
        
        return myflag;
    }
     private string saveComment(string ID, string content)
    {
        string errInfo, rt = "";
        string mySql = "insert into wx_t_OFBComment(ParentID,Content,CreateTime,CreateName,CreateCustomerID) values(@ParentID,@Content,getdate(),@CreateName,@CreateCustomerID)";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@ParentID", ID));
        para.Add(new SqlParameter("@Content", content));
        para.Add(new SqlParameter("@CreateName", vipWXname));
        para.Add(new SqlParameter("@CreateCustomerID", vipWXid));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteNonQuerySecurity(mySql, para);
        }
        if (errInfo == "")
        {
            rt = clsNetExecute.Successed + "|" + vipWXname+"|"+DateTime.Now.ToString() ;
        }
        else
        {
            rt = errInfo;
        }
        return rt;
    } 
     /// <summary>
    /// 创建资源文件记录
    /// </summary>
    /// <param name="OFBGroupID"></param>
    /// <param name="SourceTableID"></param>
    /// <returns></returns>
    private Boolean CreateSourceRecord(string OFBGroupID, out string SourceTableID)
    {
        string errInfo="";
        Boolean flag = true;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            DataTable dt = null;
            List<SqlParameter> paras = new List<SqlParameter>();
            string mysql = @"insert into wx_t_OpinionFeedback(OFBGroupID,CreateTime,CreateName,CreateCustomerID,mdid,IsDel) 
                             values(@OFBGroupID,getdate(),@CreateName,@CreateCustomerID,@mdid,1)
                             select @@identity";
            paras.Add(new SqlParameter("@OFBGroupID", OFBGroupID));
            paras.Add(new SqlParameter("@CreateName",vipWXname));
            paras.Add(new SqlParameter("@CreateCustomerID", vipWXid));
            paras.Add(new SqlParameter("@mdid", vipWXmdid));

            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo.Equals("") && dt.Rows.Count > 0)
            {
                SourceTableID = Convert.ToString(dt.Rows[0][0]);
            }
            else
            {
                SourceTableID = errInfo;
                flag = false;
            }
        }
        return flag;
    }
     private string addRelate(string MyDjID, string scanResult)
    {
        string errInfo, rt = "";
        string sphh;
        if (scanResult.Length >= 9)
        {
            sphh = scanResult.Substring(0, 9);
        }
        else
        {
            sphh = "";
            return "无效货号!";
        }
        string mySql = "select sphh from yx_T_spdmb where sphh=@sphh";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@sphh",sphh));

        DataTable dt=new DataTable();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
        }
        if(errInfo!=""){
            rt = errInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "未找到关联商品" + sphh;
        }
        else
        {
            mySql = @"if exists (select * from [wx_t_RelateToSphh] where RelateTableID=@RelateTableID and sphh=@sphh)
                    select ID,1 as bs from [wx_t_RelateToSphh] where RelateTableID=@RelateTableID and sphh=@sphh
                    else begin
                    insert into [wx_t_RelateToSphh]([RelateTableID],[sphh],[scanResult]) values(@RelateTableID,@sphh,@scanResult)
                    select @@identity ,0 as bs
                    end";
            para.Clear();
            para.Add(new SqlParameter("@RelateTableID", MyDjID));
            para.Add(new SqlParameter("@sphh", sphh));
            para.Add(new SqlParameter("@scanResult", scanResult));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
            }
            if (errInfo != "")
            {
                rt = errInfo;
            }
            else
            {
                rt = clsNetExecute.Successed + "|" + MyDjID + "|" + dt.Rows[0][0] + "|" + sphh.ToUpper() + "|" + dt.Rows[0][1];
            }
        }
        return rt;
    }
     private string delRelate(string ID)
    {
        string errInfo, rt = "";
        string mySql = "delete wx_t_RelateToSphh where ID=@ID";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@ID", ID));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteNonQuerySecurity(mySql, para);
        }
        
        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            rt = clsNetExecute.Successed;
        }
        return rt;
    }
     private string delMyItem(string ID)
    {
        string errInfo, rt = "";
        string mySql = "update wx_t_OpinionFeedback set IsDel=1 where ID=@ID";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@ID", ID));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteNonQuerySecurity(mySql, para);
        }

        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            rt = clsNetExecute.Successed;
        }
        return rt;
    }
     private string LoadMyItemList(string maxID, string OFBGroupID)
    {
        string rt = "", mySql;
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@OFBGroupID", OFBGroupID));
        mySql = @"select top 10  a.id,REPLACE(REPLACE(a.OFBContent,CHAR(10),''),CHAR(13),'') OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType , isnull(b.wxHeadimgurl,'') headImg  
                   from wx_t_OpinionFeedback a inner join wx_t_vipBinging b on a.CreateCustomerID=b.ID
                    where a.OFBGroupID=@OFBGroupID and IsDel=0 and a.id<@maxID order by a.id desc";
 

        string errInfo;
        clsJsonHelper json = new clsJsonHelper();
        DataTable dt_ZB;
        DataTable dt_MX = new DataTable();
      
        para.Add(new SqlParameter("@maxID", maxID));
       
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt_ZB);
            if (errInfo == "")
            {
                para.Clear();
                para.Add(new SqlParameter("@OFBGroupID", OFBGroupID));
                para.Add(new SqlParameter("@maxID", maxID));
                mySql = "select top 50 b.parentID,c.* from wx_t_OpinionFeedback a inner join wx_t_ResRelate b on a.id=b.parentid and a.OFBGroupID=4 inner join  wx_t_uploadfile c on b.ResID=c.id ";
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt_MX);
            }
            else
            {
                errInfo = "查询主表出错" + errInfo;
            }
        }
        
        if (errInfo == "" && dt_ZB.Rows.Count > 0)
        {
            json.AddJsonVar("minMyID", Convert.ToString(dt_ZB.Rows[dt_ZB.Rows.Count - 1]["ID"]));
            clsJsonHelper OFBJson = new clsJsonHelper();
            clsJsonHelper DetailJson = new clsJsonHelper();
            DataRow[] rows;
            string DetailStr, OFJStr = "";
            for (int i = 0; i < dt_ZB.Rows.Count; i++)
            {
                OFBJson.AddJsonVar("headImg", Convert.ToString(dt_ZB.Rows[i]["headImg"]));
                OFBJson.AddJsonVar("name", Convert.ToString(dt_ZB.Rows[i]["CreateName"]).Replace(".", "").Replace("\"", ""));
                OFBJson.AddJsonVar("time", Convert.ToString(dt_ZB.Rows[i]["CreateTime"]));
                OFBJson.AddJsonVar("OFBContent", Convert.ToString(dt_ZB.Rows[i]["OFBContent"]).Replace(".", "").Replace("\"", ""));
                OFBJson.AddJsonVar("LikeNum", Convert.ToString(dt_ZB.Rows[i]["LikeNum"]));
                OFBJson.AddJsonVar("ID", Convert.ToString(dt_ZB.Rows[i]["ID"]));
                rows = dt_MX.Select("parentID=" + Convert.ToString(dt_ZB.Rows[i]["ID"]));
                OFBJson.AddJsonVar("PictureNum", Convert.ToString(rows.Length));
                DetailStr = "[";
                for (int j = 0; j < rows.Length - 1; j++)
                {
                    DetailJson.AddJsonVar("URLAddress", Convert.ToString(rows[j]["URLAddress"]));
                    DetailJson.AddJsonVar("ThumbnailURL", Convert.ToString(rows[j]["ThumbnailURL"]));
                    DetailJson.AddJsonVar("FileName", Convert.ToString(rows[j]["FileName"]));
                    DetailStr = string.Concat(DetailStr, DetailJson.jSon, ",");
                }
                if (rows.Length >= 1)
                {
                    DetailJson.AddJsonVar("URLAddress", Convert.ToString(rows[rows.Length - 1]["URLAddress"]));
                    DetailJson.AddJsonVar("ThumbnailURL", Convert.ToString(rows[rows.Length - 1]["ThumbnailURL"]));
                    DetailJson.AddJsonVar("FileName", Convert.ToString(rows[rows.Length - 1]["FileName"]));
                    DetailStr = string.Concat(DetailStr, DetailJson.jSon, "]");
                    OFBJson.AddJsonVar("PictureList", DetailStr, false);
                }
                else
                {
                    DetailStr = "";
                    OFBJson.AddJsonVar("PictureList", DetailStr);
                }
                OFJStr = string.Concat(OFJStr, OFBJson.jSon, ",");
            }
            OFJStr = OFJStr.TrimEnd(',');
            json.AddJsonVar("rows", string.Concat("[", OFJStr, "]"), false);
            json.AddJsonVar("length", Convert.ToString(dt_ZB.Rows.Count));
            json.AddJsonVar("BackURL", clsConfig.GetConfigValue("VIP_WebPath"));
            rt = json.jSon;
        }
        else
        {
            rt = errInfo;
        }
        json = null;
        return rt;
    }
    private string GetDetail(string MyDjID)
    {
        string rt = "";
        if (MyDjID == null || MyDjID == "")
        {
            return clsNetExecute.Error + "无效ID";
        }
        string errInfo;
        string mySql = "select a.id,REPLACE(REPLACE(a.OFBContent,CHAR(10),''),CHAR(13),'') OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType,isnull(b.wxHeadimgurl,'') headImg from wx_t_OpinionFeedback a inner join wx_t_vipBinging b on a.CreateCustomerID=b.ID  where a.id=@id";

        DataTable dt_ZB;
        DataTable dt_MX = new DataTable();
        DataTable dt_Com = new DataTable();
        DataTable dt_LikesRecord = new DataTable();
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@ID", MyDjID));

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt_ZB);
            para.Clear();
            if (errInfo == "")
            {
                para.Add(new SqlParameter("@ID", MyDjID));
                mySql = "select top 50  b.parentID,c.* from wx_t_OpinionFeedback a inner join wx_t_ResRelate b on a.id=b.parentid and a.ID=@ID inner join  wx_t_uploadfile c on b.ResID=c.id";
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt_MX);
                para.Clear();
            }
            else
            {
                errInfo = "查询主表出错:" + errInfo;
            }

            if (errInfo == "")
            {
                para.Add(new SqlParameter("@ID", MyDjID));
                mySql = "select  b.* from wx_t_OpinionFeedback a inner join  wx_t_OFBComment b on a.ID=b.ParentID where a.ID=@ID";
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt_Com);
                para.Clear();
            }

            if (errInfo == "")
            {
                para.Add(new SqlParameter("@ID", MyDjID));
                mySql = "select b.* from wx_t_OpinionFeedback a inner join  wx_t_OFBLikesRecord b on a.ID=b.ParentID where a.ID=@ID order by b.ID";
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt_LikesRecord);
                para.Clear();
            }
        }
        clsJsonHelper json = new clsJsonHelper();
        json.AddJsonVar("comCountsVal", Convert.ToString(dt_Com.Rows.Count));
        if (errInfo == "" && dt_ZB.Rows.Count > 0)
        {
            json.AddJsonVar("headImg", Convert.ToString(dt_ZB.Rows[0]["headImg"]));
            json.AddJsonVar("name", Convert.ToString(dt_ZB.Rows[0]["CreateName"]).Replace(".", "").Replace("\"", ""));
            json.AddJsonVar("time", Convert.ToString(dt_ZB.Rows[0]["CreateTime"]));
            json.AddJsonVar("OFBContent", Convert.ToString(dt_ZB.Rows[0]["OFBContent"]).Replace(".", "").Replace("\"", ""));
            json.AddJsonVar("LikeNum", Convert.ToString(dt_ZB.Rows[0]["LikeNum"]));
            json.AddJsonVar("ID", Convert.ToString(dt_ZB.Rows[0]["ID"]));

            clsJsonHelper PictJson = new clsJsonHelper();
            string PictStr = "";
            for (int i = 0; i < dt_MX.Rows.Count; i++)
            {
                PictJson.AddJsonVar("FileName", Convert.ToString(dt_MX.Rows[i]["FileName"]));
                PictJson.AddJsonVar("ThumbnailURL", Convert.ToString(dt_MX.Rows[i]["ThumbnailURL"]));
                PictJson.AddJsonVar("URLAddress", Convert.ToString(dt_MX.Rows[i]["URLAddress"]));
                PictStr = string.Concat(PictStr, PictJson.jSon, ",");
            }
            PictStr = PictStr.TrimEnd(',');
            json.AddJsonVar("Picture", string.Concat("[", PictStr, "]"), false);

            clsJsonHelper ComJson = new clsJsonHelper();
            string ComStr = "";
            for (int i = 0; i < dt_Com.Rows.Count; i++)
            {
                ComJson.AddJsonVar("Content", Convert.ToString(dt_Com.Rows[i]["Content"]));
                ComJson.AddJsonVar("CreateTime", Convert.ToString(dt_Com.Rows[i]["CreateTime"]));
                ComJson.AddJsonVar("CreateName", Convert.ToString(dt_Com.Rows[i]["CreateName"]).Replace(".", "").Replace("\"", ""));
                ComStr = string.Concat(ComStr, ComJson.jSon, ",");
            }
            ComStr = ComStr.TrimEnd(',');
            json.AddJsonVar("CommentList", string.Concat("[", ComStr, "]"), false);

            clsJsonHelper likeNumJson = new clsJsonHelper();
            string likeNumStr = "";
            int isThums = 0;
            for (int i = 0; i < dt_LikesRecord.Rows.Count; i++)
            {
                if (Convert.ToInt32(dt_LikesRecord.Rows[i]["customerID"]) == Convert.ToInt32(vipWXid))
                {
                    isThums = 1;
                    json.AddJsonVar("myName", Convert.ToString(dt_LikesRecord.Rows[i]["customerName"]).Replace(".", "").Replace("\"", ""));
                }
                else
                {
                    likeNumJson.AddJsonVar("customerName", Convert.ToString(dt_LikesRecord.Rows[i]["customerName"]).Replace(".", "").Replace("\"", ""));
                    likeNumStr = string.Concat(likeNumStr, likeNumJson.jSon, ",");
                }
                 
            }
            likeNumStr = likeNumStr.TrimEnd(',');
            json.AddJsonVar("likeRecordList", string.Concat("[", likeNumStr, "]"), false);
            json.AddJsonVar("isThums", Convert.ToString(isThums));
            json.AddJsonVar("length", Convert.ToString(dt_MX.Rows.Count));
            json.AddJsonVar("BackURL", clsConfig.GetConfigValue("VIP_WebPath"));

            rt = json.jSon;
        }
        else
        {
            rt = errInfo;
        }
        return rt;
    }
     private string loadNewList(string MyDjID)
    {
        string rt = "";
        string mySql = "select top 10 a.id,REPLACE(REPLACE(a.OFBContent,CHAR(10),''),CHAR(13),'') OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType , isnull(b.wxHeadimgurl,'') headImg  from wx_t_OpinionFeedback a inner join wx_t_vipBinging b on a.CreateCustomerID=b.ID where a.id=@id";
        string errInfo;
        clsJsonHelper json = new clsJsonHelper();
        DataTable dt_ZB;
        DataTable dt_MX = new DataTable();
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@id", MyDjID));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt_ZB);
            if (errInfo == "")
            {
                para.Clear();
                para.Add(new SqlParameter("@id", MyDjID));
                mySql = "select  b.parentID,c.* from wx_t_OpinionFeedback a inner join wx_t_ResRelate b on a.id=b.parentid and a.ID=@id inner join  wx_t_uploadfile c on b.ResID=c.id ";
                errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt_MX);
            }
            else
            {
                errInfo = "查询主表出错" + errInfo;
            }
        }

        if (errInfo == "" && dt_ZB.Rows.Count > 0)
        {
            clsJsonHelper OFBJson = new clsJsonHelper();
            clsJsonHelper DetailJson = new clsJsonHelper();
            DataRow[] rows;
            string DetailStr, OFJStr = "";
            for (int i = 0; i < dt_ZB.Rows.Count; i++)
            {
                OFBJson.AddJsonVar("headImg", Convert.ToString(dt_ZB.Rows[i]["headImg"]));
                OFBJson.AddJsonVar("name", Convert.ToString(dt_ZB.Rows[i]["CreateName"]).Replace(".", "").Replace("\"", ""));
                OFBJson.AddJsonVar("time", Convert.ToString(dt_ZB.Rows[i]["CreateTime"]));
                OFBJson.AddJsonVar("OFBContent", Convert.ToString(dt_ZB.Rows[i]["OFBContent"]).Replace(".", "").Replace("\"", ""));
                OFBJson.AddJsonVar("LikeNum", Convert.ToString(dt_ZB.Rows[i]["LikeNum"]));
                OFBJson.AddJsonVar("ID", Convert.ToString(dt_ZB.Rows[i]["ID"]));
                rows = dt_MX.Select("parentID=" + Convert.ToString(dt_ZB.Rows[i]["ID"]));
                OFBJson.AddJsonVar("PictureNum", Convert.ToString(rows.Length));
                DetailStr = "[";
                for (int j = 0; j < rows.Length - 1; j++)
                {
                    DetailJson.AddJsonVar("URLAddress", Convert.ToString(rows[j]["URLAddress"]));
                    DetailJson.AddJsonVar("ThumbnailURL", Convert.ToString(rows[j]["ThumbnailURL"]));
                    DetailJson.AddJsonVar("FileName", Convert.ToString(rows[j]["FileName"]));
                    DetailStr = string.Concat(DetailStr, DetailJson.jSon, ",");
                }
                if (rows.Length >= 1)
                {
                    DetailJson.AddJsonVar("URLAddress", Convert.ToString(rows[rows.Length - 1]["URLAddress"]));
                    DetailJson.AddJsonVar("ThumbnailURL", Convert.ToString(rows[rows.Length - 1]["ThumbnailURL"]));
                    DetailJson.AddJsonVar("FileName", Convert.ToString(rows[rows.Length - 1]["FileName"]));
                    DetailStr = string.Concat(DetailStr, DetailJson.jSon, "]");
                    OFBJson.AddJsonVar("PictureList", DetailStr, false);
                }
                else
                {
                    DetailStr = "";
                    OFBJson.AddJsonVar("PictureList", DetailStr);
                }
                OFJStr = string.Concat(OFJStr, OFBJson.jSon, ",");
            }
            OFJStr = OFJStr.TrimEnd(',');
            json.AddJsonVar("rows", string.Concat("[", OFJStr, "]"), false);
            json.AddJsonVar("length", Convert.ToString(dt_ZB.Rows.Count));
            json.AddJsonVar("BackURL", clsConfig.GetConfigValue("VIP_WebPath"));
            rt = json.jSon;
        }
        else
        {
            rt = errInfo;
        }

        json = null;
        return rt;
    }
     private string ToThumb(string MyDjID)
    {
        string  rt = "",errInfo="";
        string mySql = @"if exists(select * from wx_t_OFBLikesRecord where parentID=@parentID and customerID=@customerID)
                        begin
                        select customerID,customerName,'cancel' as operate from wx_t_OFBLikesRecord  where parentID=@parentID and customerID=@customerID
                        delete wx_t_OFBLikesRecord where parentID=@parentID and customerID=@customerID
                        update wx_t_OpinionFeedback set LikeNum=LikeNum-1 where ID=@parentID
                        end
                        else
                        begin
                        insert into wx_t_OFBLikesRecord(ParentID,customerID,customerName) values(@parentID,@customerID,@customerName)
                        update wx_t_OpinionFeedback set LikeNum=LikeNum+1 where ID=@parentID
                        select customerID,customerName,'Thumbs' as operate from wx_t_OFBLikesRecord  where parentID=@parentID and customerID=@customerID
                        end";
        DataTable dt;
        List<SqlParameter> para=new List<SqlParameter>();
        para.Add(new SqlParameter("@parentID",MyDjID));
        para.Add(new SqlParameter("@customerID",Convert.ToString(vipWXid)));
        para.Add(new SqlParameter("@customerName",Convert.ToString(vipWXname)));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mySql, para, out dt);
        }

        if (errInfo != "")
        {
            rt = errInfo;
        }
        else
        {
            rt = clsSharedHelper.Successed + "|" + dt.Rows[0][0] + "|" + dt.Rows[0][1] + "|" + dt.Rows[0][2];
        }
        return rt;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
</head>
<body>
</body>
</html>
