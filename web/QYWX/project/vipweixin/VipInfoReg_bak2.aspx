<%@ Page Language="C#" Title="VIPע��" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">   
    public List<string> wxConfig;
    public string cid = "";
    string DBConStr_tlsoft = "";
    string DBConStr = "";
    public string sid = "";
    public string dgname = "";
    public string ServiceLevel = "";
    public string openid = "";
    private const string ConfigKeyValue = "5";

    protected void Page_Load(object sender, EventArgs e)
    {
        DBConStr = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
        DBConStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");

        /*��Ȩ*/
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);
            /*��������ռ�*/
            clsWXHelper.WriteLog(string.Format("openid��{0} ��vipid��{1} �����ʹ���ҳ[{2}]", Convert.ToString(Session["openid"]), Convert.ToString(Session["vipid"])
                    , "VIPע��"));

        }
        
        if (openid == "")
        {
            clsSharedHelper.WriteErrorInfo("��Ȩ���������½���");
            return;
        }

        if (!IsPostBack)
        {
            DataTable dt;
            if (openid == null || openid == "")
            {
                Response.Clear();
                Response.Write("�Ƿ����ʻ���ʳ�ʱ�����΢�Ź��ں�[������װ]���·��ʣ�");
                Response.End();
                return;
            }
            else
            {
                //�ж��Ƿ��Ѿ�ע�����
                string strSQLExists = @"  IF EXISTS (SELECT TOP 1 ID FROM wx_t_vipBinging WHERE wxOpenid=@openid AND VipID>0)
                                    BEGIN
	                                    SELECT -1 as bs		--���Ѿ�ע����ˡ��������ظ�ע��
                                    END
                                    ELSE
                                    BEGIN 
	                                    SELECT 1 as bs		--ע��ɹ�
                                    END";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@openid", openid));

                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
                {
                    string eScalar = dal.ExecuteQuerySecurity(strSQLExists, para, out dt);

                    if (eScalar == "")
                    {
                        if (Convert.ToInt32(dt.Rows[0]["bs"]) == -1)
                        {
                            StringBuilder jsOutput = new StringBuilder();
                            lblInfo.Text = "���Ѿ�ע����ˡ��������ظ�ע�ᣡ";
                            jsOutput.Append(@"swal({ title: ""������ܰ��ʾ"", text: ""-���Ѿ�ע�����-"", type: ""warning"", showCancelButton: false, confirmButtonColor: ""#59a714"", confirmButtonText: ""ȷ��"", closeOnConfirm: true }, function () { WeixinJSBridge.invoke('closeWindow', {}, function (res) {}); });");

                            ClientScript.RegisterClientScriptBlock(this.GetType(), "myAlert", jsOutput.ToString(), true);
                            return;
                        }
                    }
                    //�ж��Ƿ��Ѿ�ע����ˣ���������    
                }
            }
        }
    }
    ///
    /// д��־(���ڸ���)       -- By:Ѧ���� 2014-12-11
    ///
    private void WriteLog2(string strMemo)
    {
        string filename = Server.MapPath(@"./logs/vip{0}.log");
        filename = string.Format(filename, DateTime.Now.ToString("yyyyMMdd"));
        if (!System.IO.Directory.Exists(Server.MapPath(@"/logs/")))
            System.IO.Directory.CreateDirectory(@"/logs/");
        System.IO.StreamWriter sr = null;
        try
        {
            if (!System.IO.File.Exists(filename))
            {
                sr = System.IO.File.CreateText(filename);
            }
            else
            {
                sr = System.IO.File.AppendText(filename);
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
    
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>��Ҫ�����Ϊ����VIP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <link href="../../res/css/vipweixin/vip.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/sAlert.js?ver=20150114_2"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />
    <script type="text/javascript">

        function showYear() {
            var op = document.getElementById("year").options;
            var myDate = new Date();
            var maxYear = myDate.getFullYear();    //��ȡ���������(4λ,1970-????)

            maxYear = maxYear - 12;
            var minYear = maxYear - 60;

            op.add(new Option("��ѡ��", ""));
            for (var i = maxYear; i >= minYear; i--) {
                op.add(new Option(i.toString() + "��", i));
            }

            check();
        }

        function check() {
            var year = document.getElementById("year").value;
            var month = document.getElementById("month").value;
            var day_option = document.getElementById("day").options;
            day_option.length = 0;

            day_option.add(new Option("��ѡ��", ""));
            if (month == "1" || month == "3" || month == "5" || month == "7" || month == "8" || month == "10" || month == "12") {
                for (var i = 1; i <= 31; i++) {
                    day_option.add(new Option(i.toString() + "��", i));
                }
            }
            else if (month == "4" || month == "6" || month == "9" || month == "11") {
                for (var i = 1; i <= 30; i++) {
                    day_option.add(new Option(i.toString() + "��", i));
                }
            }
            else if (month == "2") {
                if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
                    for (var i = 1; i <= 29; i++) {
                        day_option.add(new Option(i.toString() + "��", i));
                    }
                }
                else {
                    for (var i = 1; i <= 28; i++) {
                        day_option.add(new Option(i.toString() + "��", i));
                    }
                }
            }

            CalBirthday();
        }

        function CalBirthday() {
            if ($("#year").val() != "" && $("#month").val() != "" && $("#day").val() != "") {
                $("#birthday").val($("#year").val() + "-" + $("#month").val() + "-" + $("#day").val());
            } else {
                $("#birthday").val("");
            }
        }

        function setSex(strSex) {
            $("#sex").val(strSex);
        }

        function CalZMD() {
            if ($("#zmd").val() != "") {
                $("#zmdid").val($("#zmd").val());
                $("#zmdtxt").val($("#zmd option:selected").text());
            } else {
                $("#zmdid").val("0");
                $("#zmdtxt").val("�����ŵ�");
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
        �����Ϊ����VIP
    </div>
    <form id="form1" runat="server">
        <div class="mod_input qb_mb10">
            <label for="txtcname">
                ��&nbsp;&nbsp;��*</label>
            <asp:TextBox ID="txtcname" class="flex_box" runat="server"></asp:TextBox>
        </div>
        <div class="mod_input qb_mb10">
            <div style="display: block;">
                <input type="text" class="" value="0" name="sex" id="sex" runat="server" style="display: none" />
            </div>
            ��&nbsp;&nbsp;��<label>
                <i class="icon_checkbox checked" id="gradenameboy" onclick="setSex('0');"></i>��
            <i class="icon_checkbox" id="gradenamegirl" onclick="setSex('1');"></i>Ů
            </label>
        </div>
        <div class="mod_input qb_flex qb_mb10">
            <div style="display: block;">
                ��&nbsp;&nbsp;��*
            <input type="text" class="" value="" name="birthday" id="birthday" runat="server"
                style="display: none" />
            </div>
            <select class="mod_input qb_mb10 qb_flex" id="year" name="year" style="padding: 0px; margin: 2px 2px 0 0; float: left; height: 31px; line-height: 31px; font-size: 14px; outline: none;"
                onchange="check();">
            </select>
            <select class="mod_input qb_mb10 qb_flex" id="month" name="month" style="padding: 0px; margin: 2px 2px 0 0; line-height: 31px; float: left; height: 31px; font-size: 14px; outline: none;"
                onchange="check();"> 
                <option value="0">��ѡ��</option>
                <option value="1">1��</option>
                <option value="2">2��</option>
                <option value="3">3��</option>
                <option value="4">4��</option>
                <option value="5">5��</option>
                <option value="6">6��</option>
                <option value="7">7��</option>
                <option value="8">8��</option>
                <option value="9">9��</option>
                <option value="10">10��</option>
                <option value="11">11��</option>
                <option value="12">12��</option>
            </select>
            <select class="mod_input qb_mb10 qb_flex" id="day" style="padding: 0px; margin: 2px 2px 0 0; line-height: 31px; float: left; height: 31px; font-size: 14px; outline: none;"
                onchange="CalBirthday();">
            </select>
        </div>
        <div class="mod_input qb_flex qb_mb10">
            <label for="txtmobi">
                ��&nbsp;&nbsp;��*</label>
            <input type="text" name="txtmobi" class="flex_box" id="txtmobi" runat="server" onkeydown="return mySubmit(event);" />
        </div>
        <div class="qb_fs_s qb_gap qb_pt10">
            <asp:Label ID="lblInfo" runat="server" Text="" ForeColor="Red"></asp:Label>
        </div>
        <div class="submitDiv">
            <a id="submitBtn" class="mod_btn" href="javascript:void(0)" onclick="javascript:;">�ύ����</a>
        </div>
    </form>
    <div id="bottom">
        <h1>������Ϣ�������ṩ����֧��</h1>
    </div>
    <script type="text/javascript">
        $(document).ready(function (e) {
            $("#gradenameboy,#gradenamegirl").click(function (e) {
                if (!$(this).hasClass("checked")) {
                    $(".checked").removeClass("checked");
                    $(this).addClass("checked");
                }
            });

            showYear();

            //�ύע�������
            $("#submitBtn").click(function (e) {
                var cname = $("#txtcname").val();
                var sex = $("#sex").val();
                var birthday = $("#birthday").val();
                var phone = $("#txtmobi").val().toString();
                var openid = "<%=openid %>";

                if (openid == null || openid == "") {
                    swal({
                        title: '������ܰ��ʾ ',
                        text: "���ʳ�ʱ�������´�΢�ŷ��ʣ�",
                        type: 'warning',
                        showCancelButton: false,
                        confirmButtonColor: '#59a714',
                        confirmButtonText: 'ȷ��',
                        closeOnConfirm: true
                    });
                    return false;
                }
                if (cname == "") {
                    swal({
                        title: '������ܰ��ʾ ',
                        text: "������������",
                        type: 'warning',
                        showCancelButton: false,
                        confirmButtonColor: '#59a714',
                        confirmButtonText: 'ȷ��',
                        closeOnConfirm: true
                    });
                    return false;
                } else if (birthday == "") {
                    swal({
                        title: '������ܰ��ʾ ',
                        text: "��ѡ��������ڣ�",
                        type: 'warning',
                        showCancelButton: false,
                        confirmButtonColor: '#59a714',
                        confirmButtonText: 'ȷ��',
                        closeOnConfirm: true
                    });
                    return false;
                } else if (phone == "") {
                    swal({
                        title: '������ܰ��ʾ ',
                        text: "�������ֻ����룡",
                        type: 'warning',
                        showCancelButton: false,
                        confirmButtonColor: '#59a714',
                        confirmButtonText: 'ȷ��',
                        closeOnConfirm: true
                    });
                    return false;
                } else if (phone.length != 11 || phone.indexOf("1") != 0) {
                    swal({
                        title: '������ܰ��ʾ ',
                        text: "��������ֻ����벻�Ϸ���",
                        type: 'warning',
                        showCancelButton: false,
                        confirmButtonColor: '#59a714',
                        confirmButtonText: 'ȷ��',
                        closeOnConfirm: true
                    });
                    return false;
                }
                $.ajax({
                    type: "POST",
                    url: "vipBingingcore.aspx",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { ctrl: "IsRegister", cname: cname, openid: openid, birthday: birthday, sex: sex, yddh: phone },
                    success: function (msg) {
                        msg = msg.replace(/Successed\|/g, "");
                        if (msg == "0") {
                            swal({
                                title: '������ܰ��ʾ ',
                                text: "���Ѿ�ע����ˣ��������ظ�ע�ᣡ",
                                type: 'warning',
                                showCancelButton: false,
                                confirmButtonColor: '#59a714',
                                confirmButtonText: 'ȷ��',
                                closeOnConfirm: true
                            }, function () {
                                window.location.href = 'vipWaiting.aspx';
                            });
                        } else if (msg == "1") {
                            swal({
                                title: '������ܰ��ʾ ',
                                text: "ע��ʧ�ܣ��õ绰�����ѱ�ʹ��,����ֱ�ӹ����ɣ�",
                                type: 'warning',
                                showCancelButton: false,
                                confirmButtonColor: '#59a714',
                                confirmButtonText: 'ȷ��',
                                closeOnConfirm: true
                            }, function () {
                                window.location.href = 'vipBinging_v2.aspx?cid=3&phone=' + phone;
                            });
                        } else if (msg == "2") {
                            //                            swal("δ֪����");
                            swal({
                                title: '������ܰ��ʾ ',
                                text: "ע��ʧ�ܣ�����δ֪����",
                                type: 'warning',
                                showCancelButton: false,
                                confirmButtonColor: '#59a714',
                                confirmButtonText: 'ȷ��',
                                closeOnConfirm: true
                            });
                        } else if (msg == "3") {
                            swal({
                                title: '������ܰ��ʾ ',
                                text: "����ɹ���",
                                type: 'warning',
                                showCancelButton: false,
                                confirmButtonColor: '#59a714',
                                confirmButtonText: 'ȷ��',
                                closeOnConfirm: true
                            }, function () {
                                window.location.href = 'vipWaiting.aspx?gourl=UserCenter.aspx&title=��������';
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
