<%@ Page Language="C#" ResponseEncoding="gb2312" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    private string DBConStr_weChat = "";
    private string DBConStr_tlsoft = "";
    string rtmsg;
    private const string GotoVIPListUrl = @"<a href='http://tm.lilanz.com/oa/project/StoreSaler/NewVipList.aspx'>马上去看看》》</a>";
    protected void Page_Load(object sender, EventArgs e)
    {

        Request.ContentEncoding = Encoding.GetEncoding("gb2312");
        Response.ContentEncoding = Request.ContentEncoding;
        DBConStr_weChat = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
        DBConStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");
        rtmsg = @"{{""code"":""{0}"",""info"":""{1}"",""errmsg"":""{2}""}}";

        string ctrl=Convert.ToString(Request.Params["ctrl"]);
        string wxopenid = Convert.ToString(Session["openid"]);

        if (string.IsNullOrEmpty(wxopenid))
        {
            clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", "太久没刷新，已经超时了，请刷新后再访问"));
            return;
        }
        
        string rt = "",phoneNumber;
        
        switch (ctrl)
        {
            case "sendSMS":
                phoneNumber = Convert.ToString(Request.Params["phone"]);
                string code = Convert.ToString(Request.Params["code"]);
                rt = sendMeg(phoneNumber, code);
                break;
            case "registervip":
                phoneNumber = Convert.ToString(Request.Params["phone"]);
                rt = registerVIP(phoneNumber, wxopenid);
                break;
            default: rt = string.Format(rtmsg, "500", "", "ctrl无效请求!");
                break;
        }
        if(!string.IsNullOrEmpty(rt)){
              clsSharedHelper.WriteInfo(rt);
        }
    }

    private string registerVIP(string phoneNumber,string openid)
    {
        string rtmsg = @"{{""code"":""{0}"",""info"":""{1}"",""errmsg"":""{2}""}}";
        string errInfo, mysql;
        mysql = @"SELECT TOP 1 ID FROM dbo.YX_T_Vipkh WHERE kh=@phone 
                   UNION ALL
                   SELECT TOP 1 ID FROM wx_t_vipBinging WHERE wxOpenid=@openid AND VipID>0 ";//验证手机号码、微信 是否已注册
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@phone", phoneNumber));
        paras.Add(new SqlParameter("@openid", openid));
        DataTable dt;

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                return string.Format(rtmsg, "500", "", errInfo);
            }
            if (dt.Rows.Count > 0)
            {
                clsSharedHelper.DisponseDataTable(ref dt);
                return string.Format(rtmsg, "500", "", "该手机号或微信已经注册会员了");
            }
            mysql = @" DECLARE @VIPID INT;
                       INSERT INTO YX_T_Vipkh(khid,mdid,shbs,kh,xm,xb,yddh,jdrq,tbrq,klb,isjf) 
                       VALUES (@khid,@mdid,1,@phone,@cname,@sex,@phone,GetDate(),GetDate(),@wxVIPType,0);
                       SET @VIPID = @@identity;
                       UPDATE wx_t_vipBinging SET VIPID = @VIPID WHERE wxOpenid=@openid and objectid=1 ;";
            paras.Clear();
            paras.Add(new SqlParameter("@khid", "0"));
            paras.Add(new SqlParameter("@mdid", "0"));
            paras.Add(new SqlParameter("@phone", phoneNumber));
            paras.Add(new SqlParameter("@cname", ""));
            paras.Add(new SqlParameter("@sex", 1));
            paras.Add(new SqlParameter("@wxVIPType", "20"));
            paras.Add(new SqlParameter("@openid", openid));
            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo != "")
            {
                return string.Format(rtmsg, "500", "", errInfo);
            }
            Session["vipid"] = null;
            Session["openid"] = null;
            return string.Format(rtmsg,"200","注册成功","");
        }
    }
    
    /// <summary>
    /// 发送验证码
    /// </summary>
    /// <param name="phoneNumber">手机号码</param>
    /// <param name="code">验证码</param>
    private string sendMeg(string phoneNumber,string code)
    {
        string errInfo,mysql;
        mysql = "SELECT TOP 1 id FROM dbo.YX_T_Vipkh WHERE kh=@phone";//验证手机号码是否已注册
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@phone",phoneNumber));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                return string.Format(rtmsg,"500","",errInfo);
            }
            if (dt.Rows.Count > 0)
            {
                clsSharedHelper.DisponseDataTable(ref dt);
                return string.Format(rtmsg, "500", "", "该手机号已经注册会员了");
            }
        }
        
        //"您正在使用微信注册LILANZ会员,验证码:" +
        code = HttpUtility.UrlEncode("您正在使用微信注册利郎会员。验证码：" + code, clsNetExecute.myEncoding);
        string sendUrl = "http://192.168.35.33/tl_zmd/MSGSendBase.ashx?msgtype=yd&sysid=0&userssid=1&userid=0&username=vipReg&phone={0}&msg={1}";
     
        sendUrl = string.Format(sendUrl, phoneNumber, code); 
        string strInfo = clsNetExecute.HttpRequest(sendUrl, "", "get", "gb2312", 3000); 
        if (strInfo.Contains("成功") == false)
        {
            clsLocalLoger.Log("[vip注册]短信发送："+strInfo);
            return string.Format(rtmsg, "500", "", "发送出错了");
        }
        return string.Format(rtmsg,"200","短信已发送","");
    }

    
    
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
</body>
</html>
