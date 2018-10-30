<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    private string OAConnStr = "";
    private string wxDBConStr = ""; 
    private List<SqlParameter> para = new List<SqlParameter>();
    private const string GotoVIPListUrl = @"<a href='http://tm.lilanz.com/oa/project/StoreSaler/NewVipList.aspx'>马上去看看》》</a>";
    protected void Page_Load(object sender, EventArgs e)
    {
        wxDBConStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        OAConnStr = clsConfig.GetConfigValue("OAConnStr");

        string ctrl, rt;
        try
        {
            ctrl = Convert.ToString(Request.Params["ctrl"]);
        }
        catch (Exception ex)
        {
            ctrl = "";
            Response.Write("非法访问" + ex.ToString());
            Response.End();
        }
        //clsSharedHelper.WriteInfo("123");
        switch (ctrl)
        {
            case "IsBind"://关联
                LeaveInfo l = new LeaveInfo();
                l.yddh = Convert.ToString(Request.Params["yddh"]);
                l.openid = Convert.ToString(Request.Params["openid"]);
                rt = saveInfo(l);
                break;
            case "IsRegister"://注册
                LeaveInfo leave = new LeaveInfo();
                leave.yddh = Convert.ToString(Request.Params["yddh"]);
                leave.openid = Convert.ToString(Request.Params["openid"]);
                leave.birthday = Convert.ToDateTime(Request.Params["birthday"]);
                leave.sex = Convert.ToInt32(Request.Params["sex"]);
                leave.cname = Convert.ToString(Request.Params["cname"]);
                rt = resInfo(leave);
                break;
            default: rt = "无效参数";
                break;
        }
        clsSharedHelper.WriteInfo(rt);
    }


    //msg = "0";//"-您已经注册过了-";
    //msg ="1";// "电话号码已被使用,试试直接关联吧！"window.location.href = 'vipBinging_v2.aspx?cid=3&phone=" + phone + "';
    //msg = "2";// "未知错误！";
    //msg = "3";//"个人中心。"; 
    
    
    /// <summary>
    /// 注册
    /// </summary>
    /// <param name="leave"></param>
    /// <returns></returns>
    public string resInfo(LeaveInfo leave)
    {
        //SendInfoWX("linwy", "切糕你好帅啊！");
        //clsSharedHelper.WriteInfo("123");
        string msg = "";
        string strSQL = @"  SELECT TOP 1 VipID FROM wx_t_vipBinging WHERE wxOpenid=@openid AND ObjectID = 1  ";
        para.Clear();
        string wxVIPType = "20";
        para.Add(new SqlParameter("@openid", leave.openid));

        object objVipid = "0";
        int Bindvipid;
        using (LiLanzDALForXLM oadal = new LiLanzDALForXLM(OAConnStr), wxdal = new LiLanzDALForXLM(wxDBConStr))
        {
            string strInfo = wxdal.ExecuteQueryFastSecurity(strSQL, para, out objVipid);
            para.Clear();

            if (strInfo == "")
            {
                if (objVipid == null || Convert.ToInt32(objVipid) == 0)
                {
                    Bindvipid = 0;
                }
                else
                {
                    Bindvipid = Convert.ToInt32(objVipid);
                }

                para.Clear();
                if (Bindvipid > 0)
                {
                    msg = "0";  //您已经注册过了！ 
                    return msg;
                }
            }
            else return "2";

            //还未注册的时候，就注册，若电话号码重复了就 返回 -1
            strSQL = @"DECLARE @ID INT          SET @ID = -1
                        SELECT TOP 1 @ID=ID from yx_t_vipkh WHERE kh=@phone 
                        
                        IF (@ID < 0)
                        BEGIN
                            INSERT INTO YX_T_Vipkh(khid,kh,xm,xb,csrq,yddh,tbrq,klb,isjf) 
	                                    VALUES (-1,@phone,@cname,@sex,@mybirthday,@phone,GetDate(),@wxVIPType,0)

                            SELECT 0 'IsExists',@@identity 'ID'
                        END SELECT 1 'IsExists',@ID 'ID'";
            para.Add(new SqlParameter("@wxVIPType", wxVIPType));
            para.Add(new SqlParameter("@mybirthday", leave.birthday));
            para.Add(new SqlParameter("@phone", leave.yddh));
            para.Add(new SqlParameter("@sex", leave.sex));
            para.Add(new SqlParameter("@cname", leave.cname));

            DataTable dt;
            bool IsExists;
            strInfo = oadal.ExecuteQuerySecurity(strSQL, para, out dt);

            para.Clear();
            if (strInfo == "")
            {
                IsExists = Convert.ToBoolean(dt.Rows[0]["IsExists"]);
                Bindvipid = Convert.ToInt32(dt.Rows[0]["ID"]);

                if (IsExists)   //如果已经存在，则不让注册
                {
                    msg = "1";//表明电话号码不存在！window.location.href = 'vipBinging_v2.aspx?cid=3&phone=" + phone + "';   
                    return msg;
                }

                dt.Clear(); dt.Dispose();
            }
            else return "2";

            //执行注册 
            strSQL = @"UPDATE wx_t_vipBinging SET VIPID = @VIPID WHERE wxOpenid=@openid and ObjectID=1";

            para.Add(new SqlParameter("@VIPID", Bindvipid));
            para.Add(new SqlParameter("@openid", leave.openid));
            strInfo = wxdal.ExecuteNonQuerySecurity(strSQL, para);
            if (strInfo == "")
            {
                Session["openid"] = "";
                Session["vipid"] = "";
                msg = "3";//注册成功
                return msg;
            }
            else return "2";
        } 
    }

    //msg = "0";//"该VIP会员已关联到其他微信号！";
    //msg ="1";// "VIP号输入错误！";
    //msg = "2";// "未知错误！";
    //msg = "3";//strtext = "点击确定前往个人中心。";
    //msg = "4";//网络错误,请稍候重试...

    /// <summary>
    /// 绑定现有
    /// </summary>
    /// <param name="l"></param>
    /// <returns></returns>
    public string saveInfo(LeaveInfo l)
    {

        string msg = "";

        string sql = @"SELECT TOP 1 ID FROM YX_T_Vipkh WHERE kh = @yddh";
        para.Add(new SqlParameter("@yddh", l.yddh));

        object objVipid = "0";
        int Bindvipid = 0;
        using (LiLanzDALForXLM oadal = new LiLanzDALForXLM(OAConnStr), wxdal = new LiLanzDALForXLM(wxDBConStr))
        {
            string strInfo = oadal.ExecuteQueryFastSecurity(sql, para, out objVipid);
            para.Clear();
            if (strInfo == "")
            {
                if (objVipid == null || Convert.ToInt32(objVipid) == 0)
                {
                    Bindvipid = 0;
                    msg = "1";// "VIP号输入错误！";
                    return msg;
                }
                else
                {
                    Bindvipid = Convert.ToInt32(objVipid);
                }
            }
            else return "2";

            sql = @"DECLARE @wxID INT
                    SELECT @wxID = 0

                    SELECT TOP 1 @wxID=ID FROM wx_t_vipBinging WHERE VIPID = @vipid AND ObjectID=1 

                    IF (@wxID > 0) SELECT -1
                    ELSE 
                    BEGIN
                        update wx_t_vipBinging set vipid=@vipid where wxOpenid=@openid and ObjectID=1
                        SELECT 1
                    END";
            para.Add(new SqlParameter("@vipid", Bindvipid));
            para.Add(new SqlParameter("@openid", l.openid));
            objVipid = "-1";
            strInfo = wxdal.ExecuteQueryFastSecurity(sql, para, out objVipid);
            para.Clear();
            if (strInfo == "")
            {
                if (Convert.ToInt32(objVipid) > 0)
                {
                    Session["openid"] = "";
                    Session["vipid"] = "";
                    msg = "3";// "注册正确！"; 
                }
                else
                {
                    msg = "0";// "该VIP会员已关联到其他微信号！";
                }
                return msg;
            }
            else return "2";
        }
    }
    
    public class LeaveInfo
    {
        private string _yddh;
        private string _openid;
        private DateTime _birthday;
        private Int32 _sex;
        private string _cname;

        public string yddh
        {
            get { return _yddh; }
            set { _yddh = value; }
        }
        public string openid
        {
            get { return _openid; }
            set { _openid = value; }
        }
        public DateTime birthday
        {
            get { return _birthday; }
            set { _birthday = value; }
        }
        public Int32 sex
        {
            get { return _sex; }
            set { _sex = value; }
        }
        public string cname
        {
            get { return _cname; }
            set { _cname = value; }
        }


    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
</body>
</html>
