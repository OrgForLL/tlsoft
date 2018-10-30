<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" Debug="true" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">

    String appid = "wxc368c7744f66a3d7";
    String secret = "74ebc70df1f964680bd3bdd2f15b4bed";
  	public string cid = "";
    public string openid = "";
    private const string ConfigKeyValue = "5";
    string DBConStr_tlsoft = "";
    string DBConStr = "";
    public string sid = "0";
    public string cname = "";
    public string ServiceLevel = "";
    public string phone = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        string sql = "";
        DataTable dt;
        //sid = "5";
        string strtext = "";
        List<SqlParameter> para = new List<SqlParameter>();
        cid = Request.QueryString["cid"].ToString();
        DBConStr_tlsoft = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
        DBConStr = clsConfig.GetConfigValue("OAConnStr");
        //DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
        /*鉴权*/
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);

        }
        if (openid == "")
        {
            clsSharedHelper.WriteErrorInfo("鉴权出错，请重新进入");
            return;
        }
        /*取值由扫码之后传入的导购信息*/
        DataRow dr = FansSaleBind.GetFansSaleRowInfo(openid);
        if (dr != null)
        {
            sid = Convert.ToString(dr["sid"]);
            cname = Convert.ToString(dr["cname"]);
            ServiceLevel = Convert.ToString(dr["ServiceLevel"]);
        }
        /*判断是否注册、绑定过*/
        string sqlcomm = @"SELECT TOP 1 ISNULL(VipID,0) FROM wx_t_vipBinging WHERE wxOpenid=@openid";
        para.Add(new SqlParameter("@openid", openid));
        using (LiLanzDALForXLM dalxlm = new LiLanzDALForXLM(DBConStr))
        {
            string eScal = dalxlm.ExecuteQuerySecurity(sqlcomm, para, out dt);
            para.Clear();
            if (eScal == "" )
            {
                if (dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0)  
                {
                    Response.Redirect("usercenter.aspx");
                }
                dt.Clear(); dt.Dispose();
            }
        }


        //clsSharedHelper.WriteInfo(cname); 

        
        /*注册*/
        if (Convert.ToString(openid) != "")
        {
            sql = @"select wxNick from wx_t_vipBinging  where wxopenid=@openid ";
            //sql = string.Format(sql, openid);
            para.Add(new SqlParameter("@openid", openid));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {
                string eScal = dal.ExecuteQuerySecurity(sql, para, out dt);
                para.Clear();
                if (eScal == "")
                {
                    wx.Value =Convert.ToString(dt.Rows[0]["wxNick"]);

                    dt.Clear(); dt.Dispose();
                }
            }
        }
        if (IsPostBack)
        {
            if (MobileNumber.Value == "")
            {
                string script3 = @"swal({
	                                title : '利郎温馨提示 ',
	                                text : '请输入VIP号码！',
	                                type :  'warning',
	                                showCancelButton : false,
	                                confirmButtonColor : '#59a714',
	                                confirmButtonText : '确定',
	                                closeOnConfirm : true
                                });";
                ClientScript.RegisterClientScriptBlock(this.GetType(), "msg", script3, true);
            }
            sql = @"DECLARE @bID INT ,
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
                    END
  ";
            para.Add(new SqlParameter("@yddh", MobileNumber.Value));
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr))
            {

                string eScal = dal.ExecuteQuerySecurity(sql, para, out dt); 
                if (eScal == "")
                {
                    //clsSharedHelper.WriteInfo(eScal);   
                    para.Clear(); 
                    int Bindvipid = Convert.ToInt32(dt.Rows[0][0]);

                    dt.Clear(); dt.Dispose();
                    
                    if (Bindvipid == -1) strtext = "该VIP会员已关联到其他微信号！";
                    else if (Bindvipid == 0) strtext = "VIP号输入错误！";
                    else
                    {
                        sql = @"update wx_t_vipBinging set vipid=@vipid where wxopenid=@openid ";

                        para.Add(new SqlParameter("@vipid", Bindvipid));
                        para.Add(new SqlParameter("@openid", openid));
                        string eScal1 = dal.ExecuteNonQuerySecurity(sql, para);
                        if (eScal1 == "")
                        {
                            para.Clear(); 
                            string gourl = "";
                            string title = "";
                            if (sid != "" && cname != "")
                            {
                                strtext = "马上去指定您的专属顾问：【" + cname + "】";
                                //Session["vipid"] = Convert.ToString(Bindvipid);
                                gourl = "VSB.aspx?sid=" + sid;
                                gourl = HttpUtility.UrlEncode(gourl, System.Text.Encoding.UTF8);

                                title = "专属顾问";
                            }
                            else
                            {
                                //Session["vipid"] = Convert.ToString(Bindvipid);
                                strtext = "点击确定前往个人中心。";
                                gourl = "UserCenter.aspx";

                                title = "个人中心";
                            }
                             
                            string script = string.Concat(@"swal({
	                            title : '认证成功 ',
	                            text : """, strtext, @""",
	                            type :  'warning',
                                showCancelButton : false,
	                            confirmButtonColor : '#59a714',
	                            confirmButtonText : '确定',
	                            closeOnConfirm : true
                            },function(){ 
	                            window.location.href = 'vipWaiting.aspx?gourl=", gourl, @"&title=", title, @"';
                            }); ");
                            ClientScript.RegisterClientScriptBlock(this.GetType(), "msg", script, true);

                            Session["openid"] = "";
                            Session["vipid"] = "";

                            return;
                        }
                        else
                        {
                            clsLocalLoger.WriteInfo("执行VIP关联更新时失败！错误：" + eScal1);
                            strtext = "未知错误！";
                        } 
                    }
                    
                    //输出前两个判断的提示信息
                    string script0 = string.Concat(@"swal({
	                                title : '关联失败',
	                                text : '", strtext, @"',
	                                type :  'warning',
	                                showCancelButton : false,
	                                confirmButtonColor : '#59a714',
	                                confirmButtonText : '确定',
	                                closeOnConfirm : true
                                });");
                    ClientScript.RegisterClientScriptBlock(this.GetType(), "msg", script0, true);  
                }
                else
                {
                    clsLocalLoger.WriteError(string.Concat("提交会员绑定操作失败！错误：", eScal));
                    string script = @"swal({
	                                title : '网络错误',
	                                text : '请稍候重试...',
	                                type :  'warning',
	                                showCancelButton : false,
	                                confirmButtonColor : '#59a714',
	                                confirmButtonText : '确定',
	                                closeOnConfirm : true
                                });";
                    ClientScript.RegisterClientScriptBlock(this.GetType(), "msg", script, true);
                }
            }
        }
        else
        {
            phone = Convert.ToString(Request.Params["phone"]);
        } 
    }
    ///
    /// 写日志(用于跟踪)
    ///
    private void WriteLog(string strMemo)
    {
        string filename = Server.MapPath(@"./logs/log.txt");
        if (!Directory.Exists(Server.MapPath(@"/logs/")))
            Directory.CreateDirectory(@"/logs/");
        StreamWriter sr = null;
        try
        {
            if (!File.Exists(filename))
            {
                sr = File.CreateText(filename);
            }
            else
            {
                sr = File.AppendText(filename);
            }
            sr.WriteLine(DateTime.Now.ToString("[yyyy-MM-dd HH-mm-ss] "));
            sr.WriteLine(strMemo);
        }
        catch
        {
        }
        finally
        {
            if (sr != null)
                sr.Close();
        }

    }
    private string HttpRequest(string url)
    {
        HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
        request.ContentType = "application/x-www-form-urlencoded";

        HttpWebResponse myResponse = (HttpWebResponse)request.GetResponse();
        StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8);
        return reader.ReadToEnd();//得到结果
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>利郎会员身份认证</title>
<%--<link href="../../res/css/vipweixin/vip.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../../res/js/jquery.js"></script> 
<script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
<link rel="stylesheet" href="../../res/css/sweet-alert.css" />--%>
<link href="../../css/vip.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../../js/jquery.js"></script> 
<script type="text/javascript" src="../../js/sweet-alert.min.js"></script>
<link rel="stylesheet" href="../../css/sweet-alert.css" />
<script type="text/javascript">
function fsubmit(){
	document.getElementById("form1").submit();
}
</script>
</head>

<body>

<div class="divContent">
    <div class="mod_color_weak qb_fs_s qb_gap qb_pt10">
		利郎会员身份认证
	</div>
    <form id="form1" runat="server">
    <!--请输入注册的VIP手机号-->
    <div class="mod_input qb_mb10">
            <label for="_tmp_4">
                微&nbsp;&nbsp;&nbsp;信&nbsp;&nbsp;&nbsp;号：</label>
            <input type="text" name="" class="flex_box" id="wx" runat="server" disabled="disabled" />
        </div>
        <div class="mod_input ">
            <label for="_tmp_4">
                V&nbsp;&nbsp;I&nbsp;&nbsp;P&nbsp;&nbsp;&nbsp;号：</label>
            <input type="text" name="MobileNumber" class="flex_box" id="MobileNumber" runat="server" onkeydown="return mySubmit(event);" />
        </div>
        <div>
            <asp:Label ID="Info" runat="server" Text=""></asp:Label>
        </div>
        <div class="mod_color_weak qb_fs_s qb_gap qb_pt10">
            <p>
                *温馨提示：</p>
            <p style="color: red">
                <b>1:您的手机号有可能就是您的VIP号；</b></p>
            <p>
                2:关联线下会员卡可以使您线上线下的积分同步；</p>
            <p>
                3:积分可用于换购利郎线上商城的几分商品；</p>
            <p>
                4:如需更多帮助，请咨询利郎门店的导购人员！</p>
        </div>
        <div class="submitDiv">
            <a href="javascript:fsubmit()" class="mod_btn">关联线下会员卡</a> &nbsp;&nbsp;&nbsp;&nbsp;
        </div>
        <div>
            <a href="vipInfoReg.aspx?cid=<%=cid%>&sid=<%=sid %>>" class="btn">VIP会员申请</a>
        </div>
    <div id="bottom">
    	<h1>利郎信息技术部提供技术支持</h1>
    </div>
    </form>
</div>
</body>

<script>

    var phone = "<%= phone %>";
    if (phone != "") {
        $("#MobileNumber").val(phone);
    }


    function mySubmit(e) {
        if (e.keyCode == 13) {
            document.getElementById("form1").submit();
        };
    }
</script>

</html>
