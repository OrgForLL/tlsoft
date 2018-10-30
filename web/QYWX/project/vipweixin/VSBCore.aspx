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
    private const string GotoVIPListUrl = @"<a href='http://tm.lilanz.com/oa/project/StoreSaler/NewVipList.aspx'>马上去看看》》</a>";
    protected void Page_Load(object sender, EventArgs e)
    {
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        string vipid = Convert.ToString(Session["vipid"]);
        string vsbid = Convert.ToString(Request.Params["vsbid"]);
        string mdid = Convert.ToString(Request.Params["mdid"]);
        string openid = Convert.ToString(Request.Params["openid"]);
        if (vipid == null || vipid == "0")
        {
            clsSharedHelper.WriteErrorInfo("操作登录超时，请重新扫描导购二维码！");
        }

        switch (ctrl)
        {
            case "SaveVSB":
                string sid = Convert.ToString(Request.Params["sid"]);
                SaveVSB(sid, vipid, vsbid, mdid, openid);
                break;
            case "SaveOpinion":
                int Opinion = Convert.ToInt32(Request.Params["Opinion"]);
                SaveOpinion(vsbid, Opinion, openid);
                break;
            default:
                clsSharedHelper.WriteErrorInfo("接口参数ctrl异常");
                break;
        }
    }

    private void SaveVSB(string sid, string vipid, string vsbid, string mdid, string openid)
    { 
        List<SqlParameter> lstParams = new List<SqlParameter>();

        string strInfo = "";
        string strSQL = @"SELECT TOP 1 (CASE WHEN xm = '' THEN kh ELSE xm END) 'xm' FROM yx_t_vipkh WHERE id = @vipid";
        lstParams.Add(new SqlParameter("@vipid", vipid));

        object objTemp = null;
        string vipxm = "姓名保密";

        string ConOA = clsConfig.GetConfigValue("OAConnStr");
        using (LiLanzDALForXLM zdal = new LiLanzDALForXLM(ConOA))
        {
            strInfo = zdal.ExecuteQueryFastSecurity(strSQL, lstParams, out objTemp);
            if (strInfo != "" || objTemp == null)
            {
                clsLocalLoger.WriteError("[吸收会员]获取客户姓名时出错！错误：" + strInfo);
                clsSharedHelper.WriteInfo("无法获取客户信息！");
            }
            vipxm = Convert.ToString(objTemp);
        }
         
        strSQL = @"
                DECLARE @NewVSBID INT, 
                        @oldSendName varchar(50)
 
                DELETE FROM wx_t_VipSalerBind WHERE Openid = @openid
                INSERT INTO wx_t_VipSalerBind (VipID,SalerID,CreateID,CreateName,openid) VALUES (@vipid,@sid,@sid,@CreateName,@openid)
                set @NewVSBID = @@IDENTITY
                INSERT INTO wx_t_VipSalerHistory([BindID],[VipID],[SalerID],[OpenID],[CreateID],[CreateName],[BeginType])
                     VALUES (@NewVSBID,@vipid,@sid,@openid,@sid,@CreateName,0) ;

                IF (@vsbid <> 0)  UPDATE wx_t_VipSalerHistory SET EndType = 0 ,EndTime = GetDate() WHERE BindID = @vsbid

                SELECT @NewVSBID";

        lstParams.Clear();
        lstParams.Add(new SqlParameter("@sid", sid));
        lstParams.Add(new SqlParameter("@vipid", vipid));
        lstParams.Add(new SqlParameter("@vsbid", vsbid));
        lstParams.Add(new SqlParameter("@openid", openid));
        lstParams.Add(new SqlParameter("@CreateName", string.Concat("顾客[", vipxm,"]自助")));
        string ConWX = clsWXHelper.GetWxConn();
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConWX))
        {
            strInfo = dal.ExecuteQueryFastSecurity(strSQL, lstParams, out objTemp);

            if (strInfo != "")
            {
                clsSharedHelper.WriteInfo(strInfo);
                return;
            }
            int newvsbid = Convert.ToInt32(objTemp);
            string newsendname = getCustomers_name(dal, newvsbid);
            if (vsbid != "0")
            {
                string oldsendname = getCustomers_name(dal, Convert.ToInt32(vsbid));
                if (oldsendname != "") SendInfoWX(oldsendname.Trim(), string.Concat("很遗憾的告诉您，会员【", vipxm, "】已经指定了新的专属导购"));
            }

            SendInfoWX(newsendname.Trim(), string.Concat("恭喜您，会员【", vipxm, "】指定您作为Ta的专属导购！", GotoVIPListUrl));            
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
    }

    private string getCustomers_name(LiLanzDALForXLM dal,int vsbid)
    {
        string strSQL = string.Concat(@"SELECT TOP 1 C.name from wx_t_AppAuthorized A
                    INNER JOIN wx_t_OmniChannelUser B ON A.SystemKey = B.ID AND A.SystemID = 3
                    INNER JOIN wx_t_customers C ON A.UserID = C.ID
                    INNER JOIN wx_t_VipSalerHistory D on B.ID=D.SalerID 
                    WHERE D.BindID = " ,vsbid);
        object objTemp = null;
        string cusname = "";
        string strInfo = dal.ExecuteQueryFast(strSQL, out objTemp);
        if (strInfo != "" || objTemp == null)
        {
            clsLocalLoger.WriteError("[吸收会员]获取导购name出错！错误：" + strInfo);
            cusname = "";
        }else  cusname = Convert.ToString(objTemp);

        return cusname;
    }


    private void SaveOpinion(string vsbid, int Opinion, string openid)
    {
        DataTable dt;
        string strSQL = @" 
	            UPDATE wx_t_VipSalerHistory SET VipOpinion = @Opinion WHERE BindID = @vsbid 
                select distinct C.name,kh.xm,case @Opinion when 1 then '服务态度不满意' when 2 then '搭配水平不满意' 
                when 3 then '沟通不顺利' when 4 then '导购形象不专业' when 5 then '说不出感觉'  when 6 then '其它' end  as opinion 
                from wx_t_AppAuthorized A
                INNER JOIN wx_t_OmniChannelUser B ON A.SystemKey = B.ID AND A.SystemID = 3
                INNER JOIN wx_t_customers C ON A.UserID = C.ID
                inner join wx_t_VipSalerHistory D on B.ID=D.SalerID
                --inner join wx_t_vipBinging F on D.OpenID=F.wxopenid
                inner join YX_T_Vipkh kh on d.VipID=kh.id
                WHERE   D.BindID in(@vsbid)";

        List<SqlParameter> lstParams = new List<SqlParameter>();
        lstParams.Add(new SqlParameter("@Opinion", Opinion));
        lstParams.Add(new SqlParameter("@vsbid", vsbid));

        string strInfo = "";
        string ConWX = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ConWX))
        {
            strInfo = dal.ExecuteQuerySecurity(strSQL, lstParams,out dt);
            if (strInfo == "")
            {
                SendInfoWX(Convert.ToString(dt.Rows[0]["name"]).Trim(), string.Concat("会员【" , dt.Rows[0]["xm"].ToString() , "】更换专属导购的原因是：【" , dt.Rows[0]["opinion"].ToString() , "】。"));
                clsSharedHelper.WriteSuccessedInfo("");
            }
            else
            {
                clsSharedHelper.WriteInfo(strInfo);
            }
        }
    }
    public string SendInfoWX(string user, string content)
    {
        nrWebClass.MsgClient msgclient = new nrWebClass.MsgClient("192.168.35.63", 21000);
        System.Collections.Generic.Dictionary<string, string> items = new System.Collections.Generic.Dictionary<string, string>();
        items.Add("touser", user);
        items.Add("toparty", "");
        items.Add("totag", "");
        items.Add("msgtype", "text");
        items.Add("agentid", "26");
        items.Add("content", content);
        items.Add("safe", "0");
        return msgclient.EntMsgSend(items);
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
