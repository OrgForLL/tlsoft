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


        int id;
        ctrl = Convert.ToString(Request.Params["ctrl"]);
        id = Convert.ToInt32(Request.Params["id"]);
        
        switch (ctrl)
        {
            case "getComment":
                rt = getComment(id);
                break;                
            default:
                clsSharedHelper.WriteErrorInfo("无【CTRL=" + ctrl + "】对应操作！");
                break;
        };
        clsSharedHelper.WriteInfo(rt);
    }

    public string getComment(int id)
    {

        
        string strSql, errInfo, rt;
        Boolean flag = true;

        strSql = @"select top 1 a.*,isnull(b.avatar,'') headImg 
                from wx_t_OpinionFeedback a 
                    inner join wx_t_customers b 
                on a.CreateCustomerID=b.ID  
                where a.ID=@ID";
        
        DataTable dt_zb;
        DataTable dt_img = new DataTable();
        DataTable dt_com = new DataTable();
        DataTable dt_LR = new DataTable();
        List<SqlParameter> para = new List<SqlParameter>();        
        para.Add(new SqlParameter("@ID", id));

        using (LiLanzDALForXLM wxDal = new LiLanzDALForXLM(ConnWX))
        {
            errInfo = wxDal.ExecuteQuerySecurity(strSql, para, out dt_zb);
            
            if (errInfo == "" )
            {

                strSql = @"select  b.parentID,c.* 
                            from wx_t_OpinionFeedback a 
                            inner join wx_t_ResRelate b 
                            on a.id=b.parentid 
                            inner join  wx_t_uploadfile c 
                            on b.ResID=c.id and b.ParentID=@ParentID";
                para.Clear();
                para.Add(new SqlParameter("@ParentID", id));
                errInfo = wxDal.ExecuteQuerySecurity(strSql, para, out dt_img);
                             
            }
            else
            {
                flag = false;
                errInfo = "查询主表出错" + errInfo;
            }

            if (flag == true)
            {
                strSql = @"SELECT  b.* FROM dbo.wx_t_OpinionFeedback a 
                        INNER JOIN dbo.wx_t_OFBComment b 
                        ON a.id=b.ParentID where b.ParentID=@ParentID;";
                para.Clear();
                para.Add(new SqlParameter("@ParentID", id));
                errInfo = wxDal.ExecuteQuerySecurity(strSql, para, out dt_com);
                if (errInfo != "")
                {
                    flag = false;
                }
            }

            if (flag == true)
            {
                strSql = @"SELECT b.* FROM dbo.wx_t_OpinionFeedback a 
                            INNER JOIN dbo.wx_t_OFBLikesRecord b 
                            ON a.id=b.ParentID where b.ParentID=@ParentID;";
                para.Clear();
                para.Add(new SqlParameter("@ParentID", id));
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
          

            clsJsonHelper OFBJson = new clsJsonHelper();
            clsJsonHelper DetailJson = new clsJsonHelper();
            DataRow[] rows;
            string DetailStr, OFJStr = "";
            for (int i = 0; i < dt_zb.Rows.Count; i++)
            {
                
                OFBJson.AddJsonVar("headImg", Convert.ToString(dt_zb.Rows[i]["headImg"]));
                OFBJson.AddJsonVar("name", Convert.ToString(dt_zb.Rows[i]["CreateName"]));
                OFBJson.AddJsonVar("time", Convert.ToString(dt_zb.Rows[i]["CreateTime"]));
                OFBJson.AddJsonVar("OFBContent", Convert.ToString(dt_zb.Rows[i]["OFBContent"]));
                OFBJson.AddJsonVar("ID", Convert.ToString(dt_zb.Rows[i]["ID"]));
                
                
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
