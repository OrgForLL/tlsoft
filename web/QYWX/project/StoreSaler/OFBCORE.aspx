<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">

    private string ConnWX = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = "",rt="";
       
        string OFBGroupID;
        int maxID, rq;
        ctrl = Convert.ToString(Request.Params["ctrl"]);
        OFBGroupID = Convert.ToString(Request.Params["OFBGroupID"]);
        rq = Convert.ToInt32(Request.Params["rq"]);
        
        switch (ctrl)
        {
            case "getCommentList":
               maxID = Convert.ToInt32(Request.Params["maxID"]);
               rt = getCommentList(OFBGroupID, maxID, rq);
                break;
            case "getMaxID":
                rt = GetmaxID();
                break;
            default:
                clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                break;
        };
        clsSharedHelper.WriteInfo(rt);
    }
    private string GetmaxID()
    {
        string strSql, errInfo, rt="";
        strSql = "select max(ID) from wx_t_OpinionFeedback ";
        object obj;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConnWX))
        {
            errInfo = dal.ExecuteQueryFast(strSql, out obj);
        }
        if (errInfo == "")
        {
            rt =clsNetExecute.Successed + Convert.ToString(obj);
        }
        else
        {
            rt = errInfo;
        }
        return rt;
    }
    public string getCommentList(string OFBGroupID,int maxID, int rq)
    {
        

        string strSql, errInfo, rt, createTime;
        Boolean flag = true;

        switch (rq) {            
            case 1:
                createTime = DateTime.Now.AddDays(-1).ToShortDateString().ToString();               
                break;
            case 7:
                createTime = DateTime.Now.AddDays(-7).ToShortDateString().ToString();                
                break;
            case 30:
                createTime = DateTime.Now.AddDays(-31).ToShortDateString().ToString();
                break;
            default:
                createTime = "2016-01-01";
                break;
        }
        strSql = @"select top 10 a.*,isnull(b.avatar,'') headImg 
                from wx_t_OpinionFeedback a 
                    inner join wx_t_customers b 
                on a.CreateCustomerID=b.ID  
                where OFBGroupID=@OFBGroupID 
                        and a.ID<@maxID 
                        and isDel=0 
                        and a.CreateTime > @CreateTime
                order by a.id desc";
        DataTable dt_zb;
        DataTable dt_img = new DataTable();
        DataTable dt_com = new DataTable();
        DataTable dt_LR = new DataTable();
        List<SqlParameter> para = new List<SqlParameter>();
        para.Add(new SqlParameter("@OFBGroupID", OFBGroupID));
        para.Add(new SqlParameter("@maxID", maxID));
        para.Add(new SqlParameter("@CreateTime", createTime));
        using (LiLanzDALForXLM wxDal = new LiLanzDALForXLM(ConnWX))
        {
            errInfo = wxDal.ExecuteQuerySecurity(strSql, para, out dt_zb);

            if (errInfo == "" )
            {
                strSql = "select top  50 b.parentID,c.* from wx_t_OpinionFeedback a inner join wx_t_ResRelate b on a.id=b.parentid and a.OFBGroupID=@OFBGroupID inner join  wx_t_uploadfile c on b.ResID=c.id and a.ID<@maxID and a.isDel=0 order by a.id desc ";
                para.Clear();
                para.Add(new SqlParameter("@OFBGroupID", OFBGroupID));
                para.Add(new SqlParameter("@maxID", maxID));
                errInfo = wxDal.ExecuteQuerySecurity(strSql, para, out dt_img);
            }
            else
            {
                flag = false;
                errInfo = "查询主表出错" + errInfo;
            }

            if (flag == true)
            {
                strSql = "SELECT TOP 10000 b.* FROM dbo.wx_t_OpinionFeedback a INNER JOIN dbo.wx_t_OFBComment b ON a.id=b.ParentID where a.OFBGroupID=@OFBGroupID and a.ID<@maxID and a.isDel=0 order by a.id desc";
                para.Clear();
                para.Add(new SqlParameter("@OFBGroupID", OFBGroupID));
                para.Add(new SqlParameter("@maxID", maxID));
                errInfo = wxDal.ExecuteQuerySecurity(strSql, para, out dt_com);
                if (errInfo != "")
                {
                    flag = false;
                }
            }

            if (flag == true)
            {
                strSql = "SELECT TOP 10000 b.* FROM dbo.wx_t_OpinionFeedback a INNER JOIN dbo.wx_t_OFBLikesRecord b ON a.id=b.ParentID where a.OFBGroupID=@OFBGroupID and a.ID<@maxID and a.isDel=0 order by a.id desc";
                para.Clear();
                para.Add(new SqlParameter("@OFBGroupID", OFBGroupID));
                para.Add(new SqlParameter("@maxID", maxID));
                errInfo = wxDal.ExecuteQuerySecurity(strSql, para, out dt_LR);
                if (errInfo != "")
                {
                    flag = false;
                }
            }
            
        }

     
        clsJsonHelper json = new clsJsonHelper();
        if (errInfo == "" && dt_zb.Rows.Count > 0)
        {
          
            json.AddJsonVar("minMyID", Convert.ToString(dt_zb.Rows[dt_zb.Rows.Count - 1]["ID"]));
            clsJsonHelper OFBJson = new clsJsonHelper();
            clsJsonHelper DetailJson = new clsJsonHelper();
            DataRow[] rows;
            string DetailStr, OFJStr = "";
            
            for (int i = 0; i < dt_zb.Rows.Count-1; i++)
            {
                OFBJson.AddJsonVar("headImg", Convert.ToString(dt_zb.Rows[i]["headImg"]));
                OFBJson.AddJsonVar("name", Convert.ToString(dt_zb.Rows[i]["CreateName"]));
                OFBJson.AddJsonVar("time", Convert.ToString(dt_zb.Rows[i]["CreateTime"]));
                OFBJson.AddJsonVar("OFBContent", Convert.ToString(dt_zb.Rows[i]["OFBContent"]));
                OFBJson.AddJsonVar("ID", Convert.ToString(dt_zb.Rows[i]["ID"]));
                OFBJson.AddJsonVar("ProposalType", Convert.ToString(dt_zb.Rows[i]["ProposalType"]));

                //添加图片内容
                rows = dt_img.Select("parentID=" + Convert.ToString(dt_zb.Rows[i]["ID"]));
                OFBJson.AddJsonVar("PictureNum", Convert.ToString(rows.Length));
                DetailStr = "[";
                for (int j = 0; j < rows.Length; j++)
                {
                    DetailJson.AddJsonVar("URLAddress", Convert.ToString(rows[j]["URLAddress"]));
                    DetailJson.AddJsonVar("ThumbnailURL", Convert.ToString(rows[j]["ThumbnailURL"]));
                    DetailJson.AddJsonVar("FileName", Convert.ToString(rows[j]["FileName"]));
                    DetailStr = string.Concat(DetailStr, DetailJson.jSon, ",");
                }
                if (rows.Length >= 1)//去掉最后“，”;
                {
                    DetailStr = DetailStr.TrimEnd(',');
                    DetailStr = string.Concat(DetailStr, "]");
                    OFBJson.AddJsonVar("PictureList", DetailStr, false);
                }
                else
                {
                    DetailStr = "";
                    OFBJson.AddJsonVar("PictureList", DetailStr);
                }

                //添加评论内容
                rows = dt_com.Select("parentID=" + Convert.ToString(dt_zb.Rows[i]["ID"]));
                DetailStr = "[";
                for (int j = 0; j < rows.Length; j++)
                {
                    DetailJson.AddJsonVar("Content", Convert.ToString(rows[j]["Content"]));
                    DetailJson.AddJsonVar("CreateTime", Convert.ToString(rows[j]["CreateTime"]));
                    DetailJson.AddJsonVar("CreateName", Convert.ToString(rows[j]["CreateName"]));
                    DetailStr = string.Concat(DetailStr, DetailJson.jSon, ",");
                }
                if (rows.Length >= 1)//去掉最后“，”;
                {
                    DetailStr = DetailStr.TrimEnd(',');
                    DetailStr = string.Concat(DetailStr, "]");
                    OFBJson.AddJsonVar("ComList", DetailStr, false);
                }
                else
                {
                    DetailStr = "";
                    OFBJson.AddJsonVar("ComList", DetailStr);
                }
                //点赞人
                rows = dt_LR.Select("parentID=" + Convert.ToString(dt_zb.Rows[i]["ID"]));
                DetailStr = "";

                for (int j = 0; j < rows.Length; j++)
                {
                  DetailStr += rows[j]["CustomerName"] + ",";
                }
                DetailStr = DetailStr.TrimEnd(',');
                OFBJson.AddJsonVar("thumbsName", DetailStr);
                OFJStr = string.Concat(OFJStr, OFBJson.jSon, ",");
                
            }
            OFJStr = OFJStr.TrimEnd(',');
            json.AddJsonVar("rows", string.Concat("[", OFJStr, "]"), false);
            json.AddJsonVar("length", Convert.ToString(dt_zb.Rows.Count));
            json.AddJsonVar("BackURL", clsConfig.GetConfigValue("OAOauthBackURL") + "/");
            rt = json.jSon;
            dt_com = null;
            dt_img = null;
            dt_LR = null;
            dt_zb = null;
            OFBJson = null;
            json = null;
        }
        else
        {
            rt = errInfo+ "没有数据了";
        }
        return rt;
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
