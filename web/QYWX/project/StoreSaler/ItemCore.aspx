<%@ Page Language="C#" Debug="true"%>
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
    private const string ConfigKeyValue = "1";
    string QYAccessToken = clsWXHelper.GetAT(ConfigKeyValue);
    string DBConStr ;
    string DBConStr_cfsf = clsConfig.GetConfigValue("CFSF");
  //  string DBConStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");
    string DBConStr_tlsoft = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        DBConStr = System.Web.Configuration.WebConfigurationManager.ConnectionStrings["conn"].ToString();
        string rt = "";
        string ctrl = Request.Params["ctrl"];
        string customersid = Convert.ToString(Session["qy_customersid"]);
        string userName = Convert.ToString(Session["qy_cname"]);

        if (customersid == null || customersid == "" || userName == null || userName == "" || Session["mdid"] == null)
        {
            clsSharedHelper.WriteErrorInfo("登录超时");
            return;
        }
        string OFBGroupID, MyDjID,sphh;
        switch (ctrl)
        {
            case "SaveImgs": 
                string rotate=Request.Params["rotate"];
                string formFile = Request.Params["formFile"];
                string SourceTableID =Convert.ToString(Request.Params["MyID"]);
                OFBGroupID = Convert.ToString(Request.Params["OFBGroupID"]);//质量反馈，开发建议、顾客心声、竞品情报
                //if (SourceTableID == null || SourceTableID=="0")
                //{
                //    if (!CreateSourceRecord(OFBGroupID, out SourceTableID))
                //    {
                //        rt = SourceTableID;
                //        clsSharedHelper.WriteInfo(rt);
                //        return;
                //    }
                //} 
                 rt = saveMyImgs(formFile, customersid, rotate, SourceTableID);
                break;
            case "DelImg":
                string ImgID=Convert.ToString(Request.Params["ImgID"]);
                rt=DelField(ImgID);
                break;
            case "saveConten": 
                MyDjID=Convert.ToString( Request.Params["MyDjID"]);
                string content=Convert.ToString(Request.Params["content"]);
                OFBGroupID=Convert.ToString(Request.Params["OFBGroupID"]);
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
                sphh = Convert.ToString(Request.Params["sphh"]);
                string MyID = Convert.ToString(Request.Params["MyDjID"]);
                OFBGroupID = Convert.ToString(Request.Params["OFBGroupID"]);
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
                OFBGroupID = Convert.ToString(Request.Params["OFBGroupID"]);
                sphh = Convert.ToString(Request.Params["sphh"]);
                rt = LoadMyItemList(maxID, OFBGroupID,sphh);
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
        para.Add(new SqlParameter("@customerID",Convert.ToString(Session["qy_customersid"])));
        para.Add(new SqlParameter("@customerName",Convert.ToString(Session["qy_cname"])));
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
    private string loadNewList(string MyDjID)
    {
        string rt = "";
        string mySql = @"select a.id,REPLACE(REPLACE(ISNULL(a.OFBContent,''),CHAR(10),''),CHAR(13),'')  AS OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType,isnull(b.avatar,'') headImg 
                         from wx_t_OpinionFeedback a inner join wx_t_customers b on a.CreateCustomerID=b.ID  where a.id=@id";
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

                if (clsWXHelper.IsWxFaceImg(Convert.ToString(dt_ZB.Rows[i]["headImg"])))
                {       //20160308 薛灵敏增加此判断
                    dt_ZB.Rows[i]["headImg"] = clsWXHelper.GetMiniFace(Convert.ToString(dt_ZB.Rows[i]["headImg"]));
                }
                else
                {
                    //判断来源，如果来源于OA，则加上OA前缀；否则加上客户的前缀
                    if (Convert.ToInt32(dt_ZB.Rows[i]["OFBGroupID"]) == 4)
                    {
                        dt_ZB.Rows[i]["headImg"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), dt_ZB.Rows[i]["headImg"]);
                    }
                    else
                    {
                        dt_ZB.Rows[i]["headImg"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), dt_ZB.Rows[i]["headImg"]);
                    }
                }                
                
                OFBJson.AddJsonVar("headImg", Convert.ToString(dt_ZB.Rows[i]["headImg"]));
                OFBJson.AddJsonVar("name", Convert.ToString(dt_ZB.Rows[i]["CreateName"]));
                OFBJson.AddJsonVar("time", Convert.ToString(dt_ZB.Rows[i]["CreateTime"]));
                OFBJson.AddJsonVar("OFBContent", Convert.ToString(dt_ZB.Rows[i]["OFBContent"]));
                OFBJson.AddJsonVar("LikeNum", Convert.ToString(dt_ZB.Rows[i]["LikeNum"]));
                OFBJson.AddJsonVar("ID", Convert.ToString(dt_ZB.Rows[i]["ID"]));
                OFBJson.AddJsonVar("ProposalType", Convert.ToString(dt_ZB.Rows[i]["ProposalType"]));
                rows = dt_MX.Select("parentID=" + Convert.ToString(dt_ZB.Rows[i]["ID"]));
                OFBJson.AddJsonVar("PictureNum", Convert.ToString(rows.Length));
                DetailStr = "[";
                for (int j = 0; j < rows.Length - 1; j++)
                {
                    if (Convert.ToInt32(dt_ZB.Rows[i]["OFBGroupID"]) == 4)
                    {
                        rows[j]["URLAddress"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), Convert.ToString(rows[j]["URLAddress"]));
                        rows[j]["ThumbnailURL"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), Convert.ToString(rows[j]["ThumbnailURL"]));
                    }
                    else
                    {
                        rows[j]["URLAddress"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), Convert.ToString(rows[j]["URLAddress"]));
                        rows[j]["ThumbnailURL"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), Convert.ToString(rows[j]["ThumbnailURL"]));
                    }
                    
                    DetailJson.AddJsonVar("URLAddress", Convert.ToString(rows[j]["URLAddress"]));
                    DetailJson.AddJsonVar("ThumbnailURL", Convert.ToString(rows[j]["ThumbnailURL"]));
                    DetailJson.AddJsonVar("FileName", Convert.ToString(rows[j]["FileName"]));
                    DetailStr = string.Concat(DetailStr, DetailJson.jSon, ",");
                }
                if (rows.Length >= 1)
                {
                    if (Convert.ToInt32(dt_ZB.Rows[i]["OFBGroupID"]) == 4)
                    {
                        rows[rows.Length - 1]["URLAddress"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), Convert.ToString(rows[rows.Length - 1]["URLAddress"]));
                        rows[rows.Length - 1]["ThumbnailURL"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), Convert.ToString(rows[rows.Length - 1]["ThumbnailURL"]));
                    }
                    else
                    {
                        rows[rows.Length - 1]["URLAddress"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), Convert.ToString(rows[rows.Length - 1]["URLAddress"]));
                        rows[rows.Length - 1]["ThumbnailURL"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), Convert.ToString(rows[rows.Length - 1]["ThumbnailURL"]));
                    }
                    
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
            json.AddJsonVar("BackURL", clsConfig.GetConfigValue("OAOauthBackURL") + "/");
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
        string mySql = @"select a.id,REPLACE(REPLACE(ISNULL(a.OFBContent,''),CHAR(10),''),CHAR(13),'')  AS OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType,isnull(b.avatar,'') headImg 
                         from wx_t_OpinionFeedback a inner join wx_t_customers b on a.CreateCustomerID=b.ID  where a.id=@id 
                         and not exists (select * from wx_t_OpinionFeedback where a.OFBGroupID=4 and a.ID=@id)
                         union all
                         select  a.id,REPLACE(REPLACE(ISNULL(a.OFBContent,''),CHAR(10),''),CHAR(13),'')  AS OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType, isnull(b.wxHeadimgurl,'') headImg  
                         from wx_t_OpinionFeedback a inner join wx_t_vipBinging b on a.CreateCustomerID=b.ID and a.OFBGroupID=4 where a.id=@id ";

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
                mySql = "select top 50  b.parentID,c.* from wx_t_OpinionFeedback a inner join wx_t_ResRelate b on a.id=b.parentid and a.ID=@ID inner join  wx_t_uploadfile c on b.ResID=c.id ";
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
            if (clsWXHelper.IsWxFaceImg(Convert.ToString(dt_ZB.Rows[0]["headImg"])))
            {       //20160308 薛灵敏增加此判断
                dt_ZB.Rows[0]["headImg"] = clsWXHelper.GetMiniFace(Convert.ToString(dt_ZB.Rows[0]["headImg"]));
            }
            else
            {
                //判断来源，如果来源于OA，则加上OA前缀；否则加上客户的前缀
                if (Convert.ToInt32(dt_ZB.Rows[0]["OFBGroupID"]) == 4)
                {
                    dt_ZB.Rows[0]["headImg"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), dt_ZB.Rows[0]["headImg"]);
                }
                else
                {
                    dt_ZB.Rows[0]["headImg"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), dt_ZB.Rows[0]["headImg"]);
                }
            }  
            
            json.AddJsonVar("headImg", Convert.ToString(dt_ZB.Rows[0]["headImg"]));
            json.AddJsonVar("name", Convert.ToString(dt_ZB.Rows[0]["CreateName"]));
            json.AddJsonVar("time", Convert.ToString(dt_ZB.Rows[0]["CreateTime"]));
            json.AddJsonVar("OFBContent", Convert.ToString(dt_ZB.Rows[0]["OFBContent"]));
            json.AddJsonVar("LikeNum", Convert.ToString(dt_ZB.Rows[0]["LikeNum"]));
            json.AddJsonVar("ID", Convert.ToString(dt_ZB.Rows[0]["ID"]));
            json.AddJsonVar("ProposalType", Convert.ToString(dt_ZB.Rows[0]["ProposalType"]));

            clsJsonHelper PictJson = new clsJsonHelper();
            string PictStr = "";
            for (int i = 0; i < dt_MX.Rows.Count; i++)
            {
                if (Convert.ToInt32(dt_ZB.Rows[0]["OFBGroupID"]) == 4)
                {
                    dt_MX.Rows[i]["ThumbnailURL"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), dt_MX.Rows[i]["ThumbnailURL"]);
                    dt_MX.Rows[i]["URLAddress"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), dt_MX.Rows[i]["URLAddress"]);
                }
                else
                {
                    dt_MX.Rows[i]["ThumbnailURL"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), dt_MX.Rows[i]["ThumbnailURL"]);
                    dt_MX.Rows[i]["URLAddress"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), dt_MX.Rows[i]["URLAddress"]);
                }
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
                ComJson.AddJsonVar("CreateName", Convert.ToString(dt_Com.Rows[i]["CreateName"]));
                ComStr = string.Concat(ComStr, ComJson.jSon, ",");
            }
            ComStr = ComStr.TrimEnd(',');
            json.AddJsonVar("CommentList", string.Concat("[", ComStr, "]"), false);

            clsJsonHelper likeNumJson = new clsJsonHelper();
            string likeNumStr = "";
            int isThums = 0;
            for (int i = 0; i < dt_LikesRecord.Rows.Count; i++)
            {
                if (Convert.ToInt32(dt_LikesRecord.Rows[i]["customerID"]) == Convert.ToInt32(Session["qy_customersid"]))
                {
                    isThums = 1;
                    json.AddJsonVar("myName", Convert.ToString(dt_LikesRecord.Rows[i]["customerName"]));
                }
                else
                {
                    likeNumJson.AddJsonVar("customerName", Convert.ToString(dt_LikesRecord.Rows[i]["customerName"]));
                    likeNumStr = string.Concat(likeNumStr, likeNumJson.jSon, ",");
                }
                 
            }
            likeNumStr = likeNumStr.TrimEnd(',');
            json.AddJsonVar("likeRecordList", string.Concat("[", likeNumStr, "]"), false);
            json.AddJsonVar("isThums", Convert.ToString(isThums));
            json.AddJsonVar("length", Convert.ToString(dt_MX.Rows.Count));
            json.AddJsonVar("BackURL", clsConfig.GetConfigValue("OAOauthBackURL") + "/");

            rt = json.jSon;
        }
        else
        {
            rt = errInfo;
        }
        return rt;
    }
    private string LoadMyItemList(string maxID, string OFBGroupID,string sphh)
    {
        string rt = "", mySql,sqltj="";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@OFBGroupID", OFBGroupID));
        if (sphh == null)
        {
            sphh = "";
        }

        
        if (sphh == "" &&Convert.ToInt32(Session["RoleID"]) == 1)
        {
            mySql = @"select top 10 a.id,REPLACE(REPLACE(ISNULL(a.OFBContent,''),CHAR(10),''),CHAR(13),'')  AS OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType, isnull(b.avatar,'') headImg,(select COUNT(1) from wx_t_OFBComment where ParentID=a.ID) as comNums  
                    from wx_t_OpinionFeedback a inner join wx_t_customers b on a.CreateCustomerID=b.ID and b.ID=@customerid
                    where a.OFBGroupID=@OFBGroupID and IsDel=0 and a.id<@maxID order by a.id desc";
            para.Add(new SqlParameter("@customerid", Convert.ToString(Session["qy_customersid"])));
        }
        else if (sphh == "")
        {
            mySql = @"select top 10 a.id,REPLACE(REPLACE(ISNULL(a.OFBContent,''),CHAR(10),''),CHAR(13),'')  AS OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType, isnull(b.avatar,'') headImg,(select COUNT(1) from wx_t_OFBComment where ParentID=a.ID) as comNums  from wx_t_OpinionFeedback a inner join wx_t_customers b on a.CreateCustomerID=b.ID 
                    where a.OFBGroupID=@OFBGroupID and a.IsDel=0 and a.id<@maxID and a.mdid=@mdid 
                      union all
                    select top 10 a.id,REPLACE(REPLACE(ISNULL(a.OFBContent,''),CHAR(10),''),CHAR(13),'')  AS OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType, isnull(b.wxHeadimgurl,'') headImg,(select COUNT(1) from wx_t_OFBComment where ParentID=a.ID) as comNums  from wx_t_OpinionFeedback a inner join wx_t_vipBinging b on a.CreateCustomerID=b.ID  
                    where a.OFBGroupID=(case when @OFBGroupID=1 then 4 else 0 end) and a.id<@maxID and a.IsDel=0 and a.mdid=@mdid
                    order by a.id desc";
            para.Add(new SqlParameter("@mdid", Convert.ToString(Session["mdid"])));
        }
        else
        {
            if (Convert.ToInt32(Session["RoleID"]) == 2)
            {
                mySql =string.Format( @"select top 10 a.id,REPLACE(REPLACE(ISNULL(a.OFBContent,''),CHAR(10),''),CHAR(13),'')  AS OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType, isnull(b.avatar,'') headImg,(select COUNT(1) 
                         from wx_t_OFBComment where ParentID=a.ID) as comNums  from wx_t_OpinionFeedback a inner join wx_t_customers b on a.CreateCustomerID=b.ID 
                         INNER JOIN  wx_t_RelateToSphh c ON a.id=c.RelateTableID  AND c.sphh='{0}'
                    where a.OFBGroupID=@OFBGroupID and a.IsDel=0 and a.id<@maxID and a.mdid=@mdid order by a.id desc", sphh);
            }
            else
            {
                mySql = string.Format(@"select top 10 a.id,REPLACE(REPLACE(ISNULL(a.OFBContent,''),CHAR(10),''),CHAR(13),'')  AS OFBContent,a.LikeNum,a.OFBGroupID,a.CreateTime,a.CreateName,a.CreateCustomerID,a.IsDel,a.mdid,a.ProposalType, isnull(b.avatar,'') headImg,(select COUNT(1) 
                         from wx_t_OFBComment where ParentID=a.ID) as comNums  from wx_t_OpinionFeedback a inner join wx_t_customers b on a.CreateCustomerID=b.ID 
                         INNER JOIN  wx_t_RelateToSphh c ON a.id=c.RelateTableID  AND c.sphh='{0}'
                    where a.OFBGroupID=@OFBGroupID and a.IsDel=0 and a.id<@maxID order by a.id desc", sphh);
            }
          
        }
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
                mySql = "select top 50 b.parentID,c.* from wx_t_OpinionFeedback a inner join wx_t_ResRelate b on a.id=b.parentid and a.OFBGroupID=@OFBGroupID and a.id<@maxID inner join  wx_t_uploadfile c on b.ResID=c.id order by a.id desc";
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
                if (clsWXHelper.IsWxFaceImg(Convert.ToString(dt_ZB.Rows[i]["headImg"])))
                {       //20160308 薛灵敏增加此判断
                    dt_ZB.Rows[i]["headImg"] = clsWXHelper.GetMiniFace(Convert.ToString(dt_ZB.Rows[i]["headImg"]));
                }
                else
                {
                    //判断来源，如果来源于OA，则加上OA前缀；否则加上客户的前缀
                    if (Convert.ToInt32(dt_ZB.Rows[i]["OFBGroupID"]) == 4)
                    {
                        dt_ZB.Rows[i]["headImg"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), dt_ZB.Rows[i]["headImg"]);
                    }
                    else
                    {
                        dt_ZB.Rows[i]["headImg"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), dt_ZB.Rows[i]["headImg"]);
                    }
                }   
                
                OFBJson.AddJsonVar("headImg", Convert.ToString(dt_ZB.Rows[i]["headImg"]));
                OFBJson.AddJsonVar("name", Convert.ToString(dt_ZB.Rows[i]["CreateName"]));
                OFBJson.AddJsonVar("time", Convert.ToString(dt_ZB.Rows[i]["CreateTime"]));
                OFBJson.AddJsonVar("OFBContent", Convert.ToString(dt_ZB.Rows[i]["OFBContent"]));
                OFBJson.AddJsonVar("LikeNum", Convert.ToString(dt_ZB.Rows[i]["LikeNum"]));
                OFBJson.AddJsonVar("comNums", Convert.ToString(dt_ZB.Rows[i]["comNums"]));
                OFBJson.AddJsonVar("ID", Convert.ToString(dt_ZB.Rows[i]["ID"]));
                OFBJson.AddJsonVar("ProposalType", Convert.ToString(dt_ZB.Rows[i]["ProposalType"]));
                rows = dt_MX.Select("parentID=" + Convert.ToString(dt_ZB.Rows[i]["ID"]));
                OFBJson.AddJsonVar("PictureNum", Convert.ToString(rows.Length));
                DetailStr = "[";
                for (int j = 0; j < rows.Length - 1; j++)
                {
                    if (Convert.ToInt32(dt_ZB.Rows[i]["OFBGroupID"]) == 4)
                    {
                        rows[j]["URLAddress"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), Convert.ToString(rows[j]["URLAddress"]));
                        rows[j]["ThumbnailURL"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), Convert.ToString(rows[j]["ThumbnailURL"]));
                    }
                    else
                    {
                        rows[j]["URLAddress"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), Convert.ToString(rows[j]["URLAddress"]));
                        rows[j]["ThumbnailURL"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), Convert.ToString(rows[j]["ThumbnailURL"]));
                    }
                    DetailJson.AddJsonVar("URLAddress", Convert.ToString(rows[j]["URLAddress"]));
                    DetailJson.AddJsonVar("ThumbnailURL", Convert.ToString(rows[j]["ThumbnailURL"]));
                    DetailJson.AddJsonVar("FileName", Convert.ToString(rows[j]["FileName"]));
                    DetailStr = string.Concat(DetailStr, DetailJson.jSon, ",");
                }
                if (rows.Length >= 1)
                {
                    if (Convert.ToInt32(dt_ZB.Rows[i]["OFBGroupID"]) == 4)
                    {
                        rows[rows.Length - 1]["URLAddress"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), Convert.ToString(rows[rows.Length - 1]["URLAddress"]));
                        rows[rows.Length - 1]["ThumbnailURL"] = string.Concat(clsConfig.GetConfigValue("VIP_WebPath"), Convert.ToString(rows[rows.Length - 1]["ThumbnailURL"]));
                    }
                    else
                    {
                        rows[rows.Length - 1]["URLAddress"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), Convert.ToString(rows[rows.Length - 1]["URLAddress"]));
                        rows[rows.Length - 1]["ThumbnailURL"] = string.Concat(clsConfig.GetConfigValue("OA_WebPath"), Convert.ToString(rows[rows.Length - 1]["ThumbnailURL"]));
                    }
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
            json.AddJsonVar("BackURL", clsConfig.GetConfigValue("OAOauthBackURL") + "/");
            rt = json.jSon;
        }
        else
        {
            rt = errInfo;
        }
        
        json = null;
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
    private string saveComment(string ID, string content)
    {
        string errInfo, rt = "";
        string mySql = "insert into wx_t_OFBComment(ParentID,Content,CreateTime,CreateName,CreateCustomerID) values(@ParentID,@Content,getdate(),@CreateName,@CreateCustomerID)";
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@ParentID", ID));
        para.Add(new SqlParameter("@Content", content));
        para.Add(new SqlParameter("@CreateName", Convert.ToString(Session["qy_cname"])));
        para.Add(new SqlParameter("@CreateCustomerID", Convert.ToString(Session["qy_customersid"])));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            errInfo = dal.ExecuteNonQuerySecurity(mySql, para);
        }
        if (errInfo == "")
        {
            rt = clsNetExecute.Successed + "|" + Convert.ToString(Session["qy_cname"])+"|"+DateTime.Now.ToString() ;
        }
        else
        {
            rt = errInfo;
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
            MySql = @"insert into wx_t_OpinionFeedback(OFBContent,OFBGroupID,CreateTime,CreateName,CreateCustomerID,mdid,ProposalType) 
                             values(@OFBContent,@OFBGroupID,getdate(),@CreateName,@CreateCustomerID,@mdid,@ProposalType)
                             select @@identity";
            para.Add(new SqlParameter("@OFBContent", Content));
            para.Add(new SqlParameter("@OFBGroupID", OFBGroupID));
            para.Add(new SqlParameter("@CreateName", Convert.ToString(Session["qy_cname"])));
            para.Add(new SqlParameter("@CreateCustomerID", Convert.ToString(Session["qy_customersid"])));
            para.Add(new SqlParameter("@mdid", Convert.ToString(Session["mdid"])));
            para.Add(new SqlParameter("@ProposalType", DCategoryVal));
        }
        else
        {
            MySql = "update wx_t_OpinionFeedback set OFBContent=@OFBContent,ProposalType=@ProposalType,IsDel=0 where ID=@ID; select ID from wx_t_OpinionFeedback where ID=@ID";
            para.Add(new SqlParameter("@OFBContent", Content));
            para.Add(new SqlParameter("@ProposalType", DCategoryVal));
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
            paras.Add(new SqlParameter("@CreateName", Convert.ToString(Session["qy_cname"])));
            paras.Add(new SqlParameter("@CreateCustomerID", Convert.ToString(Session["qy_customersid"])));
            paras.Add(new SqlParameter("@mdid", Convert.ToString(Session["mdid"])));

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
    private string saveMyImgs(String PicBase, String CreateID, String rotate, string SourceTableID)
    {
        string rt = "";
        string myFolder = DateTime.Now.ToString("yyyyMM");
        string pathStr = "upload/StoreSaler/" + myFolder+"/";
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
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
</head>
<body>

</body>
</html>
