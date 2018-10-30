<%@ Page Language="C#" %>
<%@ Import Namespace = "System" %>
<%@ Import Namespace = "System.Collections.Generic" %> 
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Text" %>
<%@ Import Namespace = "nrWebClass" %>  
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%--
页面说明：这个页面为VIP绑定导购的页面提供接口
开发人员：薛灵敏   开发时间：20160127
接口说明：页面将会调用 VSBCore.aspx 页面
部署说明：页面只会部署到VIP使用的公众号 【利郎男装】 WEB应用程序根目录下。
特别说明：页面的全名为：VipSalerBind.aspx 。由于页面地址最终将会以二维码的形式被访问，
          页面URL越短，页面越容易被扫描成功；反之则难以被扫描，因此页面名称应该尽可能取短。
--%>
<script runat="server">  
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string vipid = Convert.ToString(Session["vipid"]);
        string vsbid = Convert.ToString(Request.Params["vsbid"]);
        string mdid = Convert.ToString(Request.Params["mdid"]);

        if (vipid == null || vipid == "0")
        {
            clsSharedHelper.WriteErrorInfo("操作登录超时，请重新扫描导购二维码！");
        }
        
        switch (ctrl)
        {
            case "SaveVSB":
                string sid = Convert.ToString(Request.Params["sid"]);
                SaveVSB(sid, vipid, vsbid, mdid);
                break;
            case "SaveOpinion":
                int Opinion = Convert.ToInt32(Request.Params["Opinion"]);
                SaveOpinion(vsbid, Opinion);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("接口参数ctrl异常");
                break;
        } 
    }

    private void SaveVSB(string sid, string vipid, string vsbid,string mdid)
    {
        string strSQL = @"
                DECLARE @NewVSBID INT,
				                @CreateName VARCHAR(50)
                IF (@vsbid <> 0)
                BEGIN
	                UPDATE wx_t_VipSalerHistory SET EndType = 0 ,EndTime = GetDate() WHERE BindID = @vsbid
                END

                SELECT @CreateName = '顾客' + CONVERT(VARCHAR(20),@vipid) + '自助'

                DELETE FROM wx_t_VipSalerBind WHERE VipID = @vipid
                INSERT INTO wx_t_VipSalerBind (VipID,SalerID,CreateID,CreateName) VALUES (@vipid,@sid,@sid,@CreateName)
                SELECT @NewVSBID = @@IDENTITY
                INSERT INTO wx_t_VipSalerHistory([BindID],[VipID],[SalerID],[CreateID],[CreateName],[BeginType])
                     VALUES (@NewVSBID,@vipid,@sid,@sid,@CreateName,0) ";
                
        List<SqlParameter> lstParams = new List<SqlParameter>();
        lstParams.Add(new SqlParameter("@sid",sid));
        lstParams.Add(new SqlParameter("@vipid",vipid));
        lstParams.Add(new SqlParameter("@vsbid",vsbid));
        
        string strInfo = "";
        string ConWX = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConWX))
        {
            strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);
            if (strInfo == "")
            {
                //如果该VIP的门店还未确认，则更新它
                string Con10 = clsConfig.GetConfigValue("OAConnStr");
                using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(Con10))
                {
                    strSQL = @" DECLARE @mdid INT  SET @mdid = 0
                                DECLARE @khid INT  SET @khid = -1

                    SELECT TOP 1 @mdid = ISNULL(mdid,0) FROM YX_T_Vipkh WHERE id = @vipid
                    IF (@mdid = 0)	
                    BEGIN
                        SELECT TOP 1 @khid = khid FROM t_mdb WHERE mdid = @newMdid
                        UPDATE YX_T_Vipkh SET khid=@khid,mdid = @newMdid WHERE id = @vipid 
                    END";

                    lstParams.Clear();
                    lstParams.Add(new SqlParameter("@vipid", vipid));
                    lstParams.Add(new SqlParameter("@newMdid", mdid));
                    strInfo = dal10.ExecuteNonQuerySecurity(strSQL, lstParams); 
                    if (strInfo == "")
                    {
                        clsSharedHelper.WriteSuccessedInfo("");
                    }
                    else
                    { 
                        clsSharedHelper.WriteInfo(strInfo);
                    }
                } 
            }
            else
            {
                clsSharedHelper.WriteInfo(strInfo);
            }
        }         
    }


    private void SaveOpinion(string vsbid, int Opinion)
    {
        string strSQL = @" 
	            UPDATE wx_t_VipSalerHistory SET VipOpinion = @Opinion WHERE BindID = @vsbid  ";

        List<SqlParameter> lstParams = new List<SqlParameter>();
        lstParams.Add(new SqlParameter("@Opinion", Opinion));
        lstParams.Add(new SqlParameter("@vsbid", vsbid));

        string strInfo = "";
        string ConWX = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConWX))
        {
            strInfo = dal.ExecuteNonQuerySecurity(strSQL, lstParams);
            if (strInfo == "")
            {
                clsSharedHelper.WriteSuccessedInfo("");
            }
            else
            {
                clsSharedHelper.WriteInfo(strInfo);
            }
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">

<head>     
<META NAME="ROBOTS" CONTENT="NONE">
</head>
<body>     
<form id="form1" runat="server">
   
 </form>
</body>
</html>
