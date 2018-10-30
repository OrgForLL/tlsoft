<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" Debug="true" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Net" %> 
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    public string cid = "";
    public string openid = "";
    private string ConfigKeyValue = clsConfig.GetConfigValue("VIPConfigValue"); //L2 
    public string sid = "0";
    public string cname = "";
    public string ServiceLevel = "";
    public string phone = "";

    private string BrandName = clsConfig.GetConfigValue("BrandName"); //L2
    private string VIP_resPath = clsConfig.GetConfigValue("VIP_resPath"); //资源目录
    protected void Page_Load(object sender, EventArgs e)
    { 
        string sql = "";
        DataTable dt;

        List<SqlParameter> para = new List<SqlParameter>();
        //cid = Request.QueryString["cid"].ToString();  
        string DBConStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        //DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
        //clsSharedHelper.WriteInfo("123");
        /*鉴权*/
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);

            //clsSharedHelper.WriteInfo(openid);
            /*判断是否注册、绑定过*/
            　
            if (Convert.ToString(Session["vipid"]) != "" && Convert.ToString(Session["vipid"]) != "0")
            {
                Response.Redirect("usercenter.aspx");
                return;
            } 

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
                        wx.Value = Convert.ToString(dt.Rows[0]["wxNick"]);

                        dt.Clear(); dt.Dispose();
                    }
                }
            }
        }

        if (!IsPostBack)
        {
            phone = Convert.ToString(Request.Params["phone"]);
        }
    }
    ///
    /// 写日志(用于跟踪)
    ///
    private void WriteLog(string strMemo)
    { 
        clsLocalLoger.WriteInfo(strMemo);
    } 
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title><%=BrandName %>会员身份认证</title> 
    <script type="text/javascript" src="<%= VIP_resPath %>/js/jquery.js"></script>
    <script type="text/javascript" src="<%= VIP_resPath %>/js/sweet-alert.min.js"></script> 
    <style type="text/css">  
        @import url(<%= VIP_resPath %>/css/vipweixin/vip.css);
        @import url(<%= VIP_resPath %>/css/sweet-alert.css);  
    </style>  
    <script type="text/javascript">
        function fsubmit() {
            document.getElementById("form1").submit();
        }
    </script>
</head>
<body>
    <div class="divContent">
        <div class="mod_color_weak qb_fs_s qb_gap qb_pt10">
            <%=BrandName %>会员身份认证
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
            <input type="text" name="MobileNumber" class="flex_box" id="MobileNumber" runat="server"
                onkeydown="return mySubmit(event);" />
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
                3:积分可用于换购<%=BrandName %>线上商城的几分商品；</p>
            <p>
                4:如需更多帮助，请咨询<%=BrandName %>门店的导购人员！</p>
        </div>
        <div class="submitDiv">
            <a href="javascript:" id="Bind" class="mod_btn">关联线下会员卡</a> &nbsp;&nbsp;&nbsp;&nbsp;
        </div>
        <div>
            <a href="vipInfoReg.aspx?cid=3&sid=5>" class="btn">VIP会员申请</a>
        </div>
        <div id="bottom">
            <h1>
                利郎信息技术部提供技术支持</h1>
        </div>
        </form>
    </div>
</body>
<script type="text/javascript">
    var jsAlertTitle = "<%= BrandName%>温馨提示";

    $(document).ready(function (e) {
        //注册

        $("#Bind").click(function (e) {
            //swal("1");
            var yddh = $("#MobileNumber").val();
            if (yddh == "") {
//                swal("请输入VIP号码！");
                swal({
                    title: jsAlertTitle,
                    text: "请输入VIP号码！",
                    type: 'warning',
                    showCancelButton: false,
                    confirmButtonColor: '#59a714',
                    confirmButtonText: '确定',
                    closeOnConfirm: true
                });
                return false;
            }
            var openid = "<%=openid %>";
            if (openid == null || openid == "") {
//                swal("访问超时，请重新从微信访问！");
                swal({
                    title: jsAlertTitle,
                    text: "访问超时，请重新从微信访问！",
                    type: 'warning',
                    showCancelButton: false,
                    confirmButtonColor: '#59a714',
                    confirmButtonText: '确定',
                    closeOnConfirm: true
                });
                return false;
            }

            $.ajax({
                type: "POST",
                url: "vipBingingcore.aspx",
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                data: { ctrl: "IsBind", yddh: yddh, openid: openid },
                success: function (msg) {
                    msg = msg.replace(/Successed\|/g, "");
                    if (msg == "0") {
//                        swal("该VIP会员已关联到其他微信号！");
                        swal({
                            title: jsAlertTitle,
                            text: "关联失败，该VIP会员已关联到其他微信号！",
                            type: 'warning',
                            showCancelButton: false,
                            confirmButtonColor: '#59a714',
                            confirmButtonText: '确定',
                            closeOnConfirm: true
                        });
                    } else if (msg == "1") {
//                        swal("电话号码已被使用,试试直接关联吧！");
//                        setTimeout(function () {
//                            window.location.href = 'vipBinging_v2.aspx?cid=3&phone=' + phone;
//                        }, 2000);
                        swal({
                            title: jsAlertTitle,
                            text: "关联失败，VIP号输入错误！",
                            type: 'warning',
                            showCancelButton: false,
                            confirmButtonColor: '#59a714',
                            confirmButtonText: '确定',
                            closeOnConfirm: true
                        }, function () {
                            //window.location.href = 'vipWaiting.aspx';
                        });
                    } else if (msg == "2") {
//                        swal("未知错误！");
                        swal({
                            title: jsAlertTitle,
                            text: "关联失败，出现未知错误！",
                            type: 'warning',
                            showCancelButton: false,
                            confirmButtonColor: '#59a714',
                            confirmButtonText: '确定',
                            closeOnConfirm: true
                        });
                    } else if (msg == "3") {
//                        swal("申请成功！");
//                        setTimeout(function () {
//                            window.location.href = 'vipWaiting.aspx?gourl=UserCenter.aspx&title=个人中心';
//                        }, 2000);
                        swal({
                            title: jsAlertTitle,
                            text: "关联成功！",
                            type: 'success',
                            showCancelButton: false,
                            confirmButtonColor: '#59a714',
                            confirmButtonText: '确定',
                            closeOnConfirm: true
                        }, function () {
                            window.location.href = 'vipWaiting.aspx?gourl=UserCenter.aspx&title=个人中心';
                        });
                    } else if (msg == "4") {
                        swal({
                            title: jsAlertTitle,
                            text: "网络错误,请稍候重试...",
                            type: 'warning',
                            showCancelButton: false,
                            confirmButtonColor: '#59a714',
                            confirmButtonText: '确定',
                            closeOnConfirm: true
                        });
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    swal(errorThrown);
                }
            });

        });
    })

    var phone = "<%= phone %>";
    if (phone != "") {
        $("#MobileNumber").val(phone);
    }


    function mySubmit(e) {
        if (e.keyCode == 13) { 
            $("#Bind").click();
        }
    }
</script>
</html>
