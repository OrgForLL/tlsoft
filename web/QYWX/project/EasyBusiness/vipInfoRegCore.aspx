<%@ Page Language="C#" ResponseEncoding="gb2312" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    // private string DBConStr_weChat = "";
    private string DBConStr_tlsoft = "";
    private string DBConStr_weChat;
    string rtmsg;
    private const string GotoVIPListUrl = @"<a href='http://tm.lilanz.com/oa/project/StoreSaler/NewVipList.aspx'>马上去看看》》</a>";
    private static string configkey = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (configkey == null) configkey = clsConfig.GetConfigValue("CurrentConfigKey");//必须先配置configkey

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

        string rt = "", phoneNumber, code,kh;

        switch (ctrl)
        {
            case "sendSMS":
                phoneNumber = Convert.ToString(Request.Params["phone"]);
                code = Convert.ToString(Request.Params["code"]);
                rt = sendMeg(phoneNumber, code);
                break;
            case "registervip":
                phoneNumber = Convert.ToString(Request.Params["phone"]);
                rt = registerVIP(phoneNumber, wxopenid);
                break;
            case "senbindcode":
                kh = Convert.ToString(Request.Params["kh"]);
                code = Convert.ToString(Request.Params["code"]);
                sendVipSMS(kh, code);
                break;
            case "bindvip":
                kh = Convert.ToString(Request.Params["kh"]);
                bindVipkh(kh, wxopenid);
                break;
            default: rt = string.Format(rtmsg, "500", "", "ctrl无效请求!");
                break;
        }
        if(!string.IsNullOrEmpty(rt)){
            clsSharedHelper.WriteInfo(rt);
        }
    }

    /// <summary>
    /// 绑定已有vip卡号
    /// </summary>
    public void bindVipkh(string phone,string wxopenid)
    {
        if (string.IsNullOrEmpty(phone))
        {
            clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", "vip卡号不正确"));
            return;
        }
        string errInfo, mysql, vipid = "0", khid = "0", mdid = "0",objectid="",khfl="",kh;
        if (configkey == "7")//利郎轻商务
        {
            khfl = "'xm','xn','xk'";
        }
        else if (configkey == "5")//利郎男装
        {
            khfl = "'xd','xf','xg','xz','xq'";
        }

        int recodetype = 0;
        DateTime createtime;
        mysql = string.Format(@"SELECT TOP 1 a.kh, a.id,a.yddh,ISNULL(a.khid,0) khid,ISNULL(a.mdid,0) mdid FROM dbo.YX_T_Vipkh a  
                               LEFT JOIN yx_T_khb b ON a.khid=b.khid WHERE a.yddh=@phone and (khfl in({0}) OR a.khid=-1)",khfl);
        List<SqlParameter> paras = new List<SqlParameter>();

        paras.Add(new SqlParameter("@phone", phone));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", errInfo));
                return;
            }
            if (dt.Rows.Count == 0)
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", "未找到会员信息,请核对手机号码"));
                return;
            }
            vipid = Convert.ToString(dt.Rows[0]["id"]);
            kh = Convert.ToString(dt.Rows[0]["kh"]);
            //   khid  = Convert.ToString(dt.Rows[0]["khid"]);
            //   mdid  = Convert.ToString(dt.Rows[0]["mdid"]);




            /*   mysql = "SELECT * FROM dbo.wx_t_vipBinging WHERE vipid=@vipid";
               paras.Clear();
               paras.Add(new SqlParameter("@vipid", vipid));
               errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
               if(errInfo !="" ){
                   clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", "查询出错了"));
                   return;
               }else  if ( dt.Rows.Count > 0)            {
                   clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", "该卡号已关联其他微信号,请联系门店处理"));
                   return;
               }
               */
            clsWXHelper.FansBindCard(wxopenid, kh);//绑定并更新客户

            /* mysql = "UPDATE wx_t_vipBinging SET vipid=@vipid,khid=@khid,mdid=@mdid WHERE wxopenid=@openid ";
             paras.Clear();
             paras.Add(new SqlParameter("@vipid", vipid));
             paras.Add(new SqlParameter("@khid", khid));
             paras.Add(new SqlParameter("@mdid", mdid));
             paras.Add(new SqlParameter("@openid", wxopenid));
             errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
             if (errInfo != "")
             {
                 clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", errInfo));
                 return;
             }*/
            mysql = "SELECT * FROM dbo.wx_t_vipBinging WHERE vipid=@vipid";
            paras.Clear();
            paras.Add(new SqlParameter("@vipid", vipid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", errInfo));
                return;
            }else if (dt.Rows.Count < 1)
            {
                 clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", "绑定失败了,清核对信息后再绑定或填写技术人员。"));
                return;
            }

            khid = Convert.ToString(dt.Rows[0]["khid"]);
            mdid  = Convert.ToString(dt.Rows[0]["mdid"]);

            objectid  = Convert.ToString(dt.Rows[0]["ObjectID"]);
            recodetype = 2;
            createtime =   DateTime.Now;
            tjbvip(wxopenid,createtime,kh,vipid,recodetype,khid,mdid,objectid);



            Session["vipid"] = null;
            Session["openid"] = null;            
            Session.Clear();
            clsSharedHelper.WriteInfo(string.Format(rtmsg, "200", "绑定成功", ""));
        }//end using
    }
    /// <summary>
    /// 发送已有vip短信验证
    /// </summary>
    public void sendVipSMS(string kh, string code)
    {
        string errInfo, mysql, phoneNumber="",khid,khfl="";
        if (configkey == "7")//利郎轻商务
        {
            khfl = "'xm','xn','xk'";
        }
        else if (configkey == "5")//利郎男装
        {
            khfl = "'xd','xf','xg','xz','xq','xj'";
        }
        //验证手机号码是否已注册
        mysql = string.Format("SELECT TOP 1 a.id,a.yddh,ISNULL(a.khid,0) khid FROM dbo.YX_T_Vipkh a  LEFT JOIN yx_T_khb b ON a.khid=b.khid WHERE a.yddh=@phone and (khfl in({0}) OR a.khid=-1)",khfl);
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@phone", kh));
        DataTable dt;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
        {
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", errInfo));
                return;
            }
            if (dt.Rows.Count == 0)
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", "未找到该会员信息"));
                return;
            }

            phoneNumber = Convert.ToString(dt.Rows[0]["yddh"]);
            khid = Convert.ToString(dt.Rows[0]["khid"]);
            if (Convert.ToInt32(khid) <= 0) khid = "1";
            clsSharedHelper.DisponseDataTable(ref dt);
            if (string.IsNullOrEmpty(phoneNumber))
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", "未维护电话号码,请维护后再绑定"));
                return;
            }
            errInfo = sendSMS("您正在使用微信绑定利郎轻商务会员。验证码：" + code, phoneNumber,khid);
            if (errInfo.Contains("成功") == false)
            {
                clsLocalLoger.Log("[vip注册]短信发送：" + errInfo + ";phoneNumber:" + phoneNumber);
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", "发送出错了"));
            }
            else
            {
                mysql = "INSERT INTO wx_t_vipSMSCode(code,phoneNumber,wxopenid,sendTime,khid) VALUES(@code,@phoneNumber,@wxopenid,GETDATE(),@khid)";
                paras.Clear();
                paras.Add(new SqlParameter("@code", code));
                paras.Add(new SqlParameter("@phoneNumber", phoneNumber));
                paras.Add(new SqlParameter("@khid", khid));
                paras.Add(new SqlParameter("@wxopenid", Convert.ToString(Session["openid"])));
                dal.ConnectionString = DBConStr_weChat;
                dal.ExecuteNonQuerySecurity(mysql,paras);
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "200",phoneNumber, ""));
            }
        }
    }

    public void updateVipid()
    {
        /* 两个vip分开
         *  //用微信openid 换取wxunionid 与相关联vipid
          string mysql = @"SELECT MAX(isnull(a.wxUnionid,'')) wxUnionid,MAX(isnull(b.vipID,0)) vipID
                              FROM wx_t_vipBinging a INNER JOIN wx_t_vipBinging b ON a.wxUnionid=b.wxUnionid  
                              WHERE a.wxOpenid=@wxopenid AND a.wxUnionid IS NOT NULL AND a.ObjectID IN(1,4) AND b.ObjectID IN(1,4) ";
          string errInfo;
          List<SqlParameter> paras = new List<SqlParameter>();
          paras.Add(new SqlParameter("@wxopenid", Session["openid"]));
          DataTable dt;
          using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
          {
              errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
              if (errInfo != "") clsLocalLoger.WriteError("打通VIP失败！错误：" + errInfo);
              if (dt.Rows.Count == 0 || Convert.ToString(dt.Rows[0]["wxUnionid"]) == "" || Convert.ToString(dt.Rows[0]["vipID"]) == "0")
              {
                  clsLocalLoger.WriteError("打通VIP失败,无相关数据");
                  return;
              }

            string wxUnionID = Convert.ToString(dt.Rows[0]["wxUnionid"]);
            string vipid = Convert.ToString(dt.Rows[0]["vipid"]);
            clsSharedHelper.DisponseDataTable(ref dt);

              mysql = @" UPDATE wx_t_vipBinging SET vipid=@vipid WHERE wxUnionid=@wxUnionid AND ObjectID IN(1,4) and  vipid=0";
              paras.Clear();
              paras.Add(new SqlParameter("@wxUnionid", wxUnionID));
              paras.Add(new SqlParameter("@vipid", vipid));
              errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
              if (errInfo != "") clsLocalLoger.WriteError("打通VIP失败！错误：" + errInfo);
              Session["vipid"] = vipid;
          }*/
    }

    private string registerVIP(string phoneNumber,string openid)
    {

        string rtmsg = @"{{""code"":""{0}"",""info"":""{1}"",""errmsg"":""{2}""}}";
        string errInfo, mysql,khfl="",head="";
        if(configkey == "7")//利郎轻商务
        {
            khfl = "'xm','xn','xk'";
            head = "Q";
        }else  if(configkey == "5")//利郎男装
        {
            khfl = "'xd','xf','xg','xz','xq'";
            head = "Z";
        }

        if (string.IsNullOrEmpty(phoneNumber) || phoneNumber.Length !=11)
            return string.Format(rtmsg, "500", "", "手机号码不合法或为空,请核对后再提交");

        mysql =string.Format( @"SELECT TOP 1 ID FROM wx_t_vipBinging WHERE wxOpenid=@openid AND VipID>0
                  UNION ALL
                  SELECT TOP 1 id FROM dbo.YX_T_Vipkh a  LEFT JOIN yx_T_khb b ON a.khid=b.khid WHERE a.yddh=@phone and (khfl in({0}) OR a.khid=-1)",khfl);//验证微信、电话 是否已注册
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@openid", openid));
        paras.Add(new SqlParameter("@phone", phoneNumber));
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

            string vipcode = phoneNumber;
            do
            {
                errInfo = dal.ExecuteQuery(string.Format("select * from YX_T_Vipkh where kh='{0}' ", vipcode), out dt);
                if (errInfo == "" && dt.Rows.Count > 0)
                {
                    vipcode = Convert.ToString(dt.Rows[0]["kh"]);
                    vipcode =head+vipcode;
                }

            } while (dt.Rows.Count>0);

            mysql = @" INSERT INTO YX_T_Vipkh(khid,mdid,shbs,kh,xm,xb,yddh,jdrq,tbrq,klb,isjf) 
                       VALUES (-1,0,1,@kh,@cname,@sex,@phone,GetDate(),GetDate(),@wxVIPType,0);";
            paras.Clear();
            paras.Add(new SqlParameter("@phone", phoneNumber));
            paras.Add(new SqlParameter("@kh", vipcode));
            paras.Add(new SqlParameter("@cname", ""));
            paras.Add(new SqlParameter("@sex", 1));
            paras.Add(new SqlParameter("@wxVIPType", "20"));
            paras.Add(new SqlParameter("@openid", openid));

            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            if (errInfo != "")
            {
                return string.Format(rtmsg, "500", "", errInfo);
            }
            clsWXHelper.FansBindCard(openid, vipcode);
            mysql = "SELECT a.*,b.kh as kh FROM dbo.wx_t_vipBinging as a left join YX_T_Vipkh as b on a.VipID = b.id  WHERE wxopenid=@openid";
            paras.Clear();
            //clsSharedHelper.WriteInfo(dal.ConnectionString);
            paras.Add(new SqlParameter("@openid", openid));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                clsSharedHelper.WriteInfo(string.Format(rtmsg, "500", "", errInfo));
                return "";
            }
            String objectid  = Convert.ToString(dt.Rows[0]["ObjectID"]);
            String khid  =     Convert.ToString(dt.Rows[0]["khid"]);
            String mdid  =     Convert.ToString(dt.Rows[0]["mdid"]);
            String kh  =       Convert.ToString(dt.Rows[0]["kh"]);

            String vipid  = Convert.ToString(dt.Rows[0]["vipid"]);
            DateTime createtime =   DateTime.Now;
            tjbvip(openid,createtime,kh,vipid,1,khid,mdid,objectid);

            Session["vipid"] = null;
            Session["openid"] = null;
            Session.Clear();
            return string.Format(rtmsg,"200","注册成功","");
        }
    }

    /// <summary>
    /// 发送注册验证码
    /// </summary>
    /// <param name="phoneNumber">手机号码</param>
    /// <param name="code">验证码</param>
    private string sendMeg(string phoneNumber, string code)
    {
        string khfl="",configName="";

        if(configkey == "7")//利郎轻商务
        {
            khfl = "'xm','xn','xk'";
            configName = "轻商务会员";
        }else  if(configkey == "5")//利郎男装
        {
            khfl = "'xd','xf','xg','xz','xq'";
            configName = "利郎会员";
        }


        string errInfo, mysql,khid;
        mysql = string.Format("	SELECT TOP 1 id FROM dbo.YX_T_Vipkh a  LEFT JOIN yx_T_khb b ON a.khid=b.khid WHERE a.yddh=@phone and (khfl in({0}) OR a.khid=-1)",khfl);//验证手机号码是否已注册
        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Add(new SqlParameter("@phone", phoneNumber));
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
                return string.Format(rtmsg, "500", "", "该手机号已经注册会员了");
            }

            mysql = "SELECT isnull(khid,0) khid FROM dbo.wx_t_vipBinging WHERE wxOpenid=@wxopenid";
            paras.Clear();
            paras.Add(new SqlParameter("@wxopenid", Convert.ToString(Session["openid"])));
            errInfo = dal.ExecuteQuerySecurity(mysql, paras, out dt);
            if (errInfo != "")
            {
                return string.Format(rtmsg, "500", "", errInfo);
            }
            khid = Convert.ToString(dt.Rows[0]["khid"]);
            if (Convert.ToInt32(khid) <= 0) khid = "1";
            clsSharedHelper.DisponseDataTable(ref dt);
        }


        string strInfo = sendSMS(string.Format("您正在使用微信注册{0}。验证码：{1}",configName, code) , phoneNumber,khid);
        if (strInfo.Contains("成功") == false)
        {
            clsLocalLoger.Log("[vip注册]短信发送：" + strInfo);
            return string.Format(rtmsg, "500", "", "发送出错了");
        }
        else
        {
            mysql = "INSERT INTO wx_t_vipSMSCode(code,phoneNumber,wxopenid,sendTime,khid) VALUES(@code,@phoneNumber,@wxopenid,GETDATE(),@khid)";
            paras.Clear();
            paras.Add(new SqlParameter("@code", code));
            paras.Add(new SqlParameter("@phoneNumber", phoneNumber));
            paras.Add(new SqlParameter("@wxopenid", Convert.ToString(Session["openid"])));
            paras.Add(new SqlParameter("@khid", khid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_weChat))
            {
                dal.ExecuteNonQuerySecurity(mysql, paras);
            }
        }
        return string.Format(rtmsg, "200", "短信已发送", "");
    }

    public string sendSMS(string msg, string phoneNumber,string khid)
    {
        msg = HttpUtility.UrlEncode(msg,System.Text.Encoding.UTF8);
        string sendUrl = "http://10.0.0.15:9001/tl_zmd/MSGSendBase.ashx?msgtype=gd&sysid=0&userssid={2}&userid=0&username=vipReg&phone={0}&msg={1}";
        sendUrl = string.Format(sendUrl, phoneNumber, msg,khid);
        string rt = clsNetExecute.HttpRequest(sendUrl, "", "get", "utf-8", 3000);
        return rt;
    }
    //统计绑定和注册会员的人数 王成加
    public string tjbvip(String wxopenid,DateTime createtime,String kh, String vipid, int recodetype, String khid,String mdid,String objectid)
    {
        String mysql = "",errInfo="";
        mysql = "INSERT INTO wx_t_VipBingRecode(OpenID,CreateTime,VipCode,VipID,RecodeType,khid,mdid,ObjectID) VALUES(@wxopenid,@createtime,@kh,@vipid,@recodetype,@khid,@mdid,@objectid)";

        List<SqlParameter> paras = new List<SqlParameter>();
        paras.Clear();
        paras.Add(new SqlParameter("@wxopenid", wxopenid));
        paras.Add(new SqlParameter("@createtime", createtime));
        paras.Add(new SqlParameter("@kh", kh));
        paras.Add(new SqlParameter("@vipid", vipid));
        paras.Add(new SqlParameter("@recodetype", recodetype));
        paras.Add(new SqlParameter("@khid",  khid));
        paras.Add(new SqlParameter("@mdid",mdid));
        paras.Add(new SqlParameter("@objectid", objectid));

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_weChat))
        {
            errInfo = dal.ExecuteNonQuerySecurity(mysql, paras);
            // clsSharedHelper.WriteInfo( errInfo+"nihao ");
        }
        return "";
    }


</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
</body>
</html>
