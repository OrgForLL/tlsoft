<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %> 
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">   

    public List<string> wxConfig;
    public string cid = ""; 
    public string sid = "";
    public string dgname = "";
    public string ServiceLevel = "";
    public string openid = "";
    private string ConfigKeyValue = clsConfig.GetConfigValue("VIPConfigValue"); //L2

    private string BrandName = clsConfig.GetConfigValue("BrandName"); //L2
    private string VIP_resPath = clsConfig.GetConfigValue("VIP_resPath"); //资源目录
    
    protected void Page_Load(object sender, EventArgs e)
    { 
        string wxDBConStr = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
        //DBConStr = clsConfig.GetConfigValue("OAConnStr");
        //DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid); 
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);

        }
        if (openid == "")
        {
            clsSharedHelper.WriteErrorInfo("鉴权出错，请重新进入");
            return;
        }

        //DataRow dr = FansSaleBind.GetFansSaleRowInfo(openid);
        //if (dr != null)
        //{
        //    sid = Convert.ToString(dr["sid"]);
        //    dgname = Convert.ToString(dr["cname"]);
        //    ServiceLevel = Convert.ToString(dr["ServiceLevel"]);
        //}
        
        if (!IsPostBack)
        {
            DataTable dt;
            if (openid == null || openid == "")
            {
                Response.Clear();
                Response.Write(string.Concat("非法访问或访问超时，请从" ,BrandName, "公众号重新访问！"));
                Response.End();
                return;
            }
            else
            {
                //判断是否已经注册过了
                string strSQLExists = @"  IF EXISTS (SELECT TOP 1 ID FROM wx_t_vipBinging WHERE wxOpenid=@openid AND VipID>0)
                                    BEGIN
	                                    SELECT -1 as bs		--您已经注册过了。不允许重复注册
                                    END
                                    ELSE
                                    BEGIN 
	                                    SELECT 1 as bs		--注册成功
                                    END";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@openid", openid));

                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(wxDBConStr))
                {
                    string eScalar = dal.ExecuteQuerySecurity(strSQLExists, para, out dt);

                    if (eScalar == "")
                    {
                        if (Convert.ToInt32(dt.Rows[0]["bs"]) == -1)
                        {
                            StringBuilder jsOutput = new StringBuilder();
                            lblInfo.Text = "您已经注册过了。不允许重复注册！";
                            jsOutput.Append(string.Concat(@"swal({ title: """ , BrandName , @"温馨提示"", text: ""-您已经注册过了-"", type: ""warning"", showCancelButton: false, confirmButtonColor: ""#59a714"", confirmButtonText: ""确定"", closeOnConfirm: true }, function () { WeixinJSBridge.invoke('closeWindow', {}, function (res) {}); });"));

                            ClientScript.RegisterClientScriptBlock(this.GetType(), "myAlert", jsOutput.ToString(), true);
                            return;
                        }
                    }
                    //判断是否已经注册过了，结束……    
                }
            }
        } 
    }  
    
    ///
    /// 写日志(用于跟踪)     
    ///
    private void WriteLog2(string strMemo)
    {
        clsLocalLoger.WriteInfo(strMemo);
    }
    
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>我要申请成为<%= BrandName %>VIP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" /> 
    <script type="text/javascript" src="<%= VIP_resPath %>/js/jquery.js"></script>
    <script type="text/javascript" src="<%= VIP_resPath %>/js/vipweixin/sAlert.js?ver=20150114_2"></script>
    <script type="text/javascript" src="<%= VIP_resPath %>/js/vipweixin/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="<%= VIP_resPath %>/js/sweet-alert.min.js"></script> 
    <style type="text/css">  
        @import url(<%= VIP_resPath %>/css/vipweixin/vip.css);
        @import url(<%= VIP_resPath %>/css/sweet-alert.css);  
    </style>  
    <script type="text/javascript">

        function showYear() {
            var op = document.getElementById("year").options;
            for (var i = 2000; i >= 1950; i--) {
                op.add(new Option(i.toString() + "年", i));
            }

            check();
        }

        function check() {
            var year = document.getElementById("year").value;
            var month = document.getElementById("month").value;
            var day_option = document.getElementById("day").options;
            day_option.length = 0;
            if (month == "1" || month == "3" || month == "5" || month == "7" || month == "8" || month == "10" || month == "12") {
                for (var i = 1; i <= 31; i++) {
                    day_option.add(new Option(i.toString() + "日", i));
                }
            }
            else if (month == "4" || month == "6" || month == "9" || month == "11") {
                for (var i = 1; i <= 30; i++) {
                    day_option.add(new Option(i.toString() + "日", i));
                }
            }
            else if (month == "2") {
                if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
                    for (var i = 1; i <= 29; i++) {
                        day_option.add(new Option(i.toString() + "日", i));
                    }
                }
                else {
                    for (var i = 1; i <= 28; i++) {
                        day_option.add(new Option(i.toString() + "日", i));
                    }
                }
            }

            CalBirthday();
        }

        function CalBirthday() {
            if ($("#year").val() != "" && $("#month").val() != "" && $("#day").val() != "") {
                $("#birthday").val($("#year").val() + "-" + $("#month").val() + "-" + $("#day").val());

                //                alert($("#birthday").val());
            } else {
                $("#birthday").val("");
            }
        }

        function setSex(strSex) {
            $("#sex").val(strSex);
            //alert(strSex);
        }

        function CalZMD() {
            if ($("#zmd").val() != "") {
                $("#zmdid").val($("#zmd").val());
                $("#zmdtxt").val($("#zmd option:selected").text());
            } else {
                $("#zmdid").val("0");
                $("#zmdtxt").val("其它门店");
            }
        }




                function mySubmit(e) {
                    if (e.keyCode == 13) { 
                        document.getElementById("form1").submit();
                    };
                }

    </script>
</head>
<body style="padding: 0px; margin: 0px;">
    <div class="mod_color_weak qb_fs_s qb_gap qb_pt10">
        申请成为<%= BrandName %>VIP
    </div>
    <form id="form1" runat="server">
    <div class="mod_input qb_mb10">
        <label for="txtcname">
            姓&nbsp;&nbsp;名*</label>
        <asp:TextBox ID="txtcname" class="flex_box" runat="server"></asp:TextBox>
    </div>
    <div class="mod_input qb_mb10">
        <div style="display: block;">
            <input type="text" class="" value="0" name="sex" id="sex" runat="server" style="display: none" />
        </div>
        性&nbsp;&nbsp;别：<label>
            <i class="icon_checkbox checked" id="gradenameboy" onclick="setSex('0');"></i>男
            <i class="icon_checkbox" id="gradenamegirl" onclick="setSex('1');"></i>女
        </label>
    </div>
    <div class="mod_input qb_flex qb_mb10">
        <div style="display: block;">
            生&nbsp;&nbsp;日*
            <input type="text" class="" value="" name="birthday" id="birthday" runat="server"
                style="display: none" />
        </div>
        <select class="mod_input qb_mb10 qb_flex" id="year" name="year" style="padding: 0px;
            margin: 2px 2px 0 0; float: left; height: 31px; line-height: 31px; font-size: 14px;
            outline: none;" onchange="check();">
        </select>
        <select class="mod_input qb_mb10 qb_flex" id="month" name="month" style="padding: 0px;
            margin: 2px 2px 0 0; line-height: 31px; float: left; height: 31px; font-size: 14px;
            outline: none;" onchange="check();">
            <option value="1">1月</option>
            <option value="2">2月</option>
            <option value="3">3月</option>
            <option value="4">4月</option>
            <option value="5">5月</option>
            <option value="6">6月</option>
            <option value="7">7月</option>
            <option value="8">8月</option>
            <option value="9">9月</option>
            <option value="10">10月</option>
            <option value="11">11月</option>
            <option value="12">12月</option>
        </select>
        <select class="mod_input qb_mb10 qb_flex" id="day" style="padding: 0px; margin: 2px 2px 0 0;
            line-height: 31px; float: left; height: 31px; font-size: 14px; outline: none;"
            onchange="CalBirthday();">
        </select>
    </div>
    <div class="mod_input qb_flex qb_mb10">
        <label for="txtmobi">
            手&nbsp;&nbsp;机*</label>
        <input type="text" name="txtmobi" class="flex_box" id="txtmobi" runat="server" onkeydown="return mySubmit(event);" />
    </div>
    <div class="qb_fs_s qb_gap qb_pt10">
        <asp:Label ID="lblInfo" runat="server" Text="" ForeColor="Red"></asp:Label>
    </div>
    <div class="submitDiv">
        <a id="submitBtn" class="mod_btn" href="javascript:void(0)" onclick="javascript:;">提交申请</a>
    </div>
    </form>
    <div id="bottom">
        <h1>
            利郎信息技术部提供技术支持</h1>
    </div>
    <script type="text/javascript">
        var jsAlertTitle = "<%= BrandName%>温馨提示";

        $(document).ready(function (e) {
            $("#gradenameboy,#gradenamegirl").click(function (e) {
                if (!$(this).hasClass("checked")) {
                    $(".checked").removeClass("checked");
                    $(this).addClass("checked");
                }
            });

            showYear();

            $("#submitBtn").click(function (e) {

                var cname = $("#txtcname").val();
                var sex = $("#sex").val();
                var birthday = $("#birthday").val();
                var phone = $("#txtmobi").val().toString();
                //alert(phone.indexOf("1"));
                var openid = "<%=openid %>";

                if (openid == null || openid == "") {
                    //swal("访问超时，请重新从微信访问！");
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
                if (cname == "") {
                    //swal("请输入姓名!");
                    swal({
                        title: jsAlertTitle,
                        text: "请输入姓名！",
                        type: 'warning',
                        showCancelButton: false,
                        confirmButtonColor: '#59a714',
                        confirmButtonText: '确定',
                        closeOnConfirm: true
                    });
                    return false;
                } else if (birthday == "") {
                    //swal("请选择出生日期！");
                    swal({
                        title: jsAlertTitle,
                        text: "请选择出生日期！",
                        type: 'warning',
                        showCancelButton: false,
                        confirmButtonColor: '#59a714',
                        confirmButtonText: '确定',
                        closeOnConfirm: true
                    });
                    return false;
                } else if (phone == "") {
                    //swal("请输入手机号码!");
                    swal({
                        title: jsAlertTitle,
                        text: "请输入手机号码！",
                        type: 'warning',
                        showCancelButton: false,
                        confirmButtonColor: '#59a714',
                        confirmButtonText: '确定',
                        closeOnConfirm: true
                    });
                    return false;
                } else if (phone.length != 11 || phone.indexOf("1") != 0) {
                    //swal("您输入的手机号码不合法！");
                    swal({
                        title: jsAlertTitle,
                        text: "您输入的手机号码不合法！",
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
                    url: "VipBingingCore.aspx",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { ctrl: "IsRegister", cname: cname, openid: openid, birthday: birthday, sex: sex, yddh: phone },
                    success: function (msg) {
                        msg = msg.replace(/Successed\|/g, "");
                        if (msg == "0") { 
                            swal({
                                title: jsAlertTitle,
	                            text : "您已经注册过了，不允许重复注册！",
	                            type :  'warning',
                                showCancelButton : false,
	                            confirmButtonColor : '#59a714',
	                            confirmButtonText : '确定',
	                            closeOnConfirm : true
                            },function(){ 
	                            window.location.href = 'vipWaiting.aspx';
                            }); 
	                    } else if (msg == "1") {
	                        swal({
	                            title: jsAlertTitle,
	                            text: "注册失败，该电话号码已被使用,试试直接关联吧！",
	                            type: 'warning',
	                            showCancelButton: false,
	                            confirmButtonColor: '#59a714',
	                            confirmButtonText: '确定',
	                            closeOnConfirm: true
	                        }, function () {
	                            window.location.href = 'vipBinging_v2.aspx?cid=3&phone=' + phone;
	                        });
//                            swal("电话号码已被使用,试试直接关联吧！");
//                            setTimeout(function () {
//                                window.location.href = 'vipBinging_v2.aspx?cid=3&phone=' + phone;
//                            }, 2000);
                        } else if (msg == "2") {
	                        //                            swal("未知错误！");
	                        swal({
	                            title: jsAlertTitle,
	                            text: "注册失败，出现未知错误！",
	                            type: 'warning',
	                            showCancelButton: false,
	                            confirmButtonColor: '#59a714',
	                            confirmButtonText: '确定',
	                            closeOnConfirm: true
	                        });
                        } else if (msg == "3") { 
	                        swal({
	                            title: jsAlertTitle,
	                            text: "申请成功！",
	                            type: 'warning',
	                            showCancelButton: false,
	                            confirmButtonColor: '#59a714',
	                            confirmButtonText: '确定',
	                            closeOnConfirm: true
	                        }, function () {
	                            window.location.href = 'vipWaiting.aspx?gourl=UserCenter.aspx&title=个人中心';
	                        });       

                        }
                        //swal(msg);
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        swal(errorThrown);
                    }
                });

            });
        })

    </script>
</body>
</html>
