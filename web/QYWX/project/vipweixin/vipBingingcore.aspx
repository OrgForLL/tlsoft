<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    private string DBConStr_tlsoft = "";
    private string DBConStr = "";
    private DataTable dt;
    private List<SqlParameter> para = new List<SqlParameter>();
    private const string GotoVIPListUrl = @"<a href='http://tm.lilanz.com/oa/project/StoreSaler/NewVipList.aspx'>马上去看看》》</a>";
    protected void Page_Load(object sender, EventArgs e)
    {
        DBConStr_tlsoft = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
        DBConStr = clsConfig.GetConfigValue("OAConnStr");

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
                leave.yddh = Convert.ToString(Request.Params["yddh"]);//手机
                leave.openid = Convert.ToString(Request.Params["openid"]);//OPENID
                leave.birthday = Convert.ToDateTime(Request.Params["birthday"]);//生日
                leave.sex = Convert.ToInt32(Request.Params["sex"]);//性别
                leave.cname = Convert.ToString(Request.Params["cname"]);//姓名
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
    //注册

    public string resInfo(LeaveInfo leave)
    {
        string msg = "";
        string strSQL = @"  IF EXISTS (SELECT TOP 1 ID FROM wx_t_vipBinging WHERE wxOpenid=@openid AND VipID>0)
                              BEGIN
	                            SELECT -1 as bs	--您已经注册过了。不允许重复注册
                              END
                              ELSE
                               BEGIN
                                 DECLARE @errID INT;SET @errID = 0
                                 SELECT TOP 1 @errID=ID from yx_t_vipkh WHERE kh=@phone 
                                 IF (@errID <> 0)     SELECT -2	 as bs  --VIP号已被使用
                               ELSE
                                 BEGIN 
                                   DECLARE @VIPID INT,
                                            @khid int,
                                            @mdid int
                                   
                                   SELECT @khid = 0,@mdid = 0                                                       

                                   select top 1 @khid=isnull(khid,0),@mdid=isnull(mdid,0) from wx_t_vipbinging where wxopenid=@openid and objectid=1;
                                   if (@khid=0)  SET @khid = -1    

	                               INSERT INTO YX_T_Vipkh(khid,mdid,shbs,kh,xm,xb,csrq,yddh,jdrq,tbrq,klb,isjf) 
	                               VALUES (@khid,@mdid,1,@phone,@cname,@sex,@mybirthday,@phone,GetDate(),GetDate(),@wxVIPType,0)
                                   set @VIPID = @@identity 

                                   UPDATE wx_t_vipBinging SET VIPID = @VIPID WHERE wxOpenid=@openid and objectid=1
                                   SELECT @VIPID as bs	--注册成功
                                 END
                               END";
        para.Clear();
        string wxVIPType = "20";
        para.Add(new SqlParameter("@openid", leave.openid));
        para.Add(new SqlParameter("@wxVIPType", wxVIPType));
        para.Add(new SqlParameter("@mybirthday", leave.birthday));
        para.Add(new SqlParameter("@phone", leave.yddh));
        para.Add(new SqlParameter("@sex", leave.sex));
        para.Add(new SqlParameter("@cname", leave.cname));

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {
            string eScal = dal.ExecuteQuerySecurity(strSQL, para, out dt);
            para.Clear();

            if (eScal == "")
            {
                int Bindvipid = Convert.ToInt32(dt.Rows[0]["bs"]);
                dt.Clear(); dt.Dispose(); dt = null;
                para.Clear();
                StringBuilder jsOutput = new StringBuilder();
                if (Bindvipid == -1)
                {
                    msg = "0";//window.location.href = 'vipWaiting.aspx';-您已经注册过了-
                }
                else if (Bindvipid == -2)
                { 
                    msg = "1";//电话号码已被使用,试试直接关联吧！window.location.href = 'vipBinging_v2.aspx?cid=3&phone=" + phone + "'; 
                }
                else
                { 
                    Session["openid"] = "";
                    Session["vipid"] = "";
                    Session["wxid"] = "";
                    Session.Clear();
                    
                    string sql = @" delete wx_t_VipSalerBind where vipid=@vipid and openid='';
                                    update wx_t_VipSalerBind set vipid=@vipid where openid=@openid  ;
                                    update b set b.vipid=@vipid  from wx_t_VipSalerBind a 
                                    inner join wx_t_VipSalerHistory b on a.id=b.BindID where a.openid=@openid 

                                    select  C.name,F.wxNick from wx_t_AppAuthorized A
                                    INNER JOIN wx_t_OmniChannelUser B ON A.SystemKey = B.ID AND A.SystemID = 3
                                    INNER JOIN wx_t_customers C ON A.UserID = C.ID
                                    inner join wx_t_VipSalerBind D on B.ID=D.SalerID
                                    inner join wx_t_vipBinging F on D.OpenID=F.wxopenid
                                    --inner join YX_T_Vipkh kh on d.VipID=kh.id
                                    WHERE  D.OpenID=@openid ";
                    para.Add(new SqlParameter("@vipid", Bindvipid));
                    para.Add(new SqlParameter("@openid", leave.openid));
                    string eScal2 = new LiLanzDALForXLM(DBConStr_tlsoft).ExecuteQuerySecurity(sql, para, out dt);
                    if (eScal2 == "" && dt.Rows.Count > 0)
                    {
                        SendInfoWX(Convert.ToString(dt.Rows[0]["name"]).Trim(), string.Concat("您的粉丝【" , dt.Rows[0]["wxNick"] , "】已经注册了新会员【" , leave.cname , "】！", GotoVIPListUrl));
                        //SendInfoWX("linwy", "您的粉丝【" + dt.Rows[0]["wxNick"] + "】已经注册了新会员【" + dt.Rows[0]["xm"] + "】！");
               
                    } 
                    msg = "3";
                    if (dt != null) { dt.Clear(); dt.Dispose(); dt = null; }
                    para.Clear();
                }
            }
            else
            {
                clsLocalLoger.WriteError("注册会员出错：" + eScal);
                msg = "2";//未知错误;
                //lblInfo.Text = "错误：" + eScal;
            }
        }
        
        return msg;
    }

    //msg = "0";//"该VIP会员已关联到其他微信号！";
    //msg ="1";// "VIP号输入错误！";
    //msg = "2";// "未知错误！";
    //msg = "3";//strtext = "点击确定前往个人中心。";
    //msg = "4";//网络错误,请稍候重试...

    //绑定
    public string saveInfo(LeaveInfo l)
    {

        string msg = "";

        string sql = @"DECLARE @bID INT ,
				                    @vipID INT
                    SELECT @bID = 0,@vipID = 0

                    SELECT TOP 1 @bID=B.ID FROM YX_T_Vipkh A 
                     INNER JOIN wx_t_vipBinging B ON A.id = B.vipID 
                     WHERE A.kh = @yddh

                    IF (@bID > 0)	SELECT -1
                    ELSE 
                    BEGIN
	                    SELECT TOP 1 @vipID=ID from yx_t_vipkh WHERE kh=@yddh 
	                    SELECT @vipID
                    END";
        para.Add(new SqlParameter("@yddh", l.yddh));
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
        {

            string eScal = dal.ExecuteQuerySecurity(sql, para, out dt);
            if (eScal == "")
            {
                //clsSharedHelper.WriteInfo(eScal);   
                para.Clear();
                int Bindvipid = Convert.ToInt32(dt.Rows[0][0]);

                dt.Clear(); dt.Dispose(); dt = null;

                if (Bindvipid == -1) msg = "0";//"该VIP会员已关联到其他微信号！";
                else if (Bindvipid == 0) msg = "1";// "VIP号输入错误！";
                else
                {
                    Session["openid"] = "";
                    Session["vipid"] = "";
                    Session["wxid"] = "";
                    Session.Clear(); 
                    
                    sql = @"update wx_t_vipBinging set vipid=@vipid where wxopenid=@openid and objectid=1 ";

                    para.Add(new SqlParameter("@vipid", Bindvipid));
                    para.Add(new SqlParameter("@openid", l.openid));
                    string eScal1 = dal.ExecuteNonQuerySecurity(sql, para);
                    if (eScal1 == "")
                    {
                        para.Clear();
                        sql = @"    delete wx_t_VipSalerBind where vipid=@vipid and openid='';
                                    update wx_t_VipSalerBind set vipid=@vipid where openid=@openid ;
                                    update b set b.vipid=@vipid  from wx_t_VipSalerBind a 
                                    inner join wx_t_VipSalerHistory b on a.id=b.BindID where a.openid=@openid 
                                    select  C.name,kh.xm,F.wxNick from wx_t_AppAuthorized A
                                    INNER JOIN wx_t_OmniChannelUser B ON A.SystemKey = B.ID AND A.SystemID = 3
                                    INNER JOIN wx_t_customers C ON A.UserID = C.ID
                                    inner join wx_t_VipSalerBind D on B.ID=D.SalerID
                                    inner join wx_t_vipBinging F on D.OpenID=F.wxopenid
                                    inner join YX_T_Vipkh kh on d.VipID=kh.id
                                    WHERE  D.OpenID=@openid";
                        para.Add(new SqlParameter("@vipid", Bindvipid));
                        para.Add(new SqlParameter("@openid", l.openid));
                        string eScal2 = new LiLanzDALForXLM(DBConStr_tlsoft).ExecuteQuerySecurity(sql, para, out dt);
                     
                        if (eScal2 == "" && dt.Rows.Count > 0)
                        {                            
                            SendInfoWX(Convert.ToString(dt.Rows[0]["name"]).Trim(), string.Concat("您的粉丝【", dt.Rows[0]["wxNick"], "】已经关联了会员【", dt.Rows[0]["xm"], "】！", GotoVIPListUrl));
                        }
                        msg = "3";
                        if (dt != null) { dt.Clear(); dt.Dispose(); dt = null; }
                        para.Clear();                      
                        
                    }
                    else
                    {
                        clsLocalLoger.WriteError("绑定会员出错2：" + eScal1);
                        msg = "2";// "未知错误！";
                    }
                }

            }
            else
            {
                clsLocalLoger.WriteError("绑定会员出错1：" + eScal);
                msg = "4";//网络错误,请稍候重试...
            }
        }


        return msg;
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
