<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>
<!DOCTYPE html>
<script runat="server">  	   
    string OAConnStr ;
    protected void Page_Load(object sender, EventArgs e)
    {
        OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        string ctrl, rt = "",mxid;
        ctrl = Convert.ToString(Request.Params["ctrl"]);
        
        switch (ctrl)
        {
            case "GetFabricCode":
                 mxid = Convert.ToString(Request.Params["mxid"]);
                rt = GetFabricCode(mxid);
                break;
            case "SaveImgs":
                string formFile = Request.Params["formFile"];
                string rotate = Request.Params["rotate"];
                mxid = Convert.ToString(Request.Params["mxid"]);
                rt = saveMyImgs(formFile, rotate, mxid);
                break;
            default: rt = "参数有误"; break;
        }
        clsSharedHelper.WriteInfo(rt);
    }

    private string saveMyImgs(String PicBase, String rotate, string mxid)
    {
        string rt = "";
        string fabricID = getFabricID(mxid);

        if (fabricID.IndexOf(clsNetExecute.Error) > -1)
        {
            return fabricID;
        }
        
        PicBase = PicBase.Replace("+", "|");
        rt = post(clsConfig.GetConfigValue("ERP_WebPath") + "tl_yf/MyFabricScanMobileImg.aspx?rotate=" + rotate + "&fabricID=" + fabricID, PicBase);

        if (rt.IndexOf(clsNetExecute.Error) >= 0)
        {
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                dal.ExecuteNonQuery(string.Format("UPDATE yf_t_MyfabricScan SET isDel=1 WHERE id={0}",fabricID));
            }
            
            rt =string.Concat(clsNetExecute.Error,"上传图片出错");
            clsLocalLoger.Log("图片上传出错：" + mxid);
        }
        return rt;
    }
    
    public string GetFabricCode(string mxid)
    {
        string rt = "",errInfo;
        string mySql =string.Format("SELECT yphh FROM cl_v_dddjmx WHERE mxid={0} ",mxid);
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuery(mySql, out dt);
        }
        if (errInfo != "")
        {
            rt = clsNetExecute.Error + errInfo;
        }
        else if (dt.Rows.Count < 1)
        {
            rt = clsNetExecute.Error + "未查到面料信息";
        }
        else
        {
            rt = Convert.ToString(dt.Rows[0][0]);
            dt.Dispose();
        }
        return rt;
    }
    private string getFabricID(string mxid)
    {
        string rt = "", errInfo;
        string mysql = @"DECLARE @id INT;
                        DECLARE @fabricCode VARCHAR(100);
                        SELECT TOP 1 @fabricCode=yphh FROM cl_v_dddjmx WHERE mxid=@mxid;
                        IF NOT EXISTS (SELECT 1 FROM yf_t_MyfabricScan WHERE fabricCode=@fabricCode and scanType=1)
                        BEGIN 
                        INSERT INTO yf_t_MyfabricScan(fabricCode,fabricName,scanType) VALUES(@fabricCode,@fabricCode,1)
                        SET @id=@@IDENTITY
                        END
                        ELSE SELECT @id=id FROM yf_t_MyfabricScan WHERE fabricCode=@fabricCode and scanType=1
                        SELECT @id";
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@mxid", mxid));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
        }
        if (errInfo != "")
        {
            rt = string.Concat(clsNetExecute.Error, errInfo);
        }
        else
        {
            rt = Convert.ToString(dt.Rows[0][0]);
            dt.Dispose();
        }
        return rt;
    }

    public string post(string url, string content)
    {
        byte[] postData = Encoding.UTF8.GetBytes(content);//编码，尤其是汉字，事先要看下抓取网页的编码方式  
        WebClient webClient = new WebClient();
        webClient.Headers.Add("Content-Type", "application/x-www-form-urlencoded");//采取POST方式必须加的header，如果改为GET方式的话就去掉这句话即可  
        byte[] responseData = webClient.UploadData(url, "POST", postData);//得到返回字符流  
        string srcString = Encoding.UTF8.GetString(responseData);//解码  
        return srcString;
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
