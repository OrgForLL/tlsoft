<%@ Page Language="C#" %>
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
    string DBConStr="";
    public string sid = "";
    public string dgname = "";
    public string ServiceLevel = "";
    public string openid = "";
    private const string ConfigKeyValue = "5"; 
    protected void Page_Load(object sender, EventArgs e)
    {

        //sid = Request.QueryString["sid"].ToString();
        //cid = Request.QueryString["cid"].ToString();
        DBConStr = ConfigurationManager.ConnectionStrings["Conn_4"].ConnectionString;
        //DBConStr = clsConfig.GetConfigValue("OAConnStr");
        //DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
        DBConStr_tlsoft = clsConfig.GetConfigValue("OAConnStr");
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {
            openid = Convert.ToString(Session["openid"]);

        } 
        if (openid == "")
        {
            clsSharedHelper.WriteErrorInfo("��Ȩ���������½���");
            return;
        }
        
        DataRow dr = FansSaleBind.GetFansSaleRowInfo(openid);
        if (dr != null)
        {
            sid = Convert.ToString(dr["sid"]);
            dgname = Convert.ToString(dr["cname"]);
            ServiceLevel = Convert.ToString(dr["ServiceLevel"]);
        }

        
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
        
        if (IsPostBack)     //�ύ
        { 
            DataTable dt;
            string cname = this.txtcname.Text;
            string sex = this.sex.Value;
            string mybirthday = this.birthday.Value;
            string phone = this.txtmobi.Value;

 
            if (openid == null || openid == "")
            {
                lblInfo.Text = "���ʳ�ʱ�������´�΢�ŷ��ʣ�";
                return;                
            }
            else if (cname == "")
            {
                lblInfo.Text = "������������";
                txtcname.Focus();
            }
            else if (mybirthday == "")
            {
                lblInfo.Text = "��ѡ��������ڣ�";
            }
            else if (phone == "")
            {
                lblInfo.Text = "�������ֻ����룡";
                txtmobi.Focus();
            }
            else if (phone.Length != 11 || phone.IndexOf('1') != 0)                
            {
                lblInfo.Text = "��������ֻ����벻�Ϸ���"; 
                txtmobi.Focus();
            }
            else
            {

                string strSQL = @"  IF EXISTS (SELECT TOP 1 ID FROM wx_t_vipBinging WHERE wxOpenid=@openid AND VipID>0)
                                    BEGIN
	                                    SELECT -1	 as bs	--���Ѿ�ע����ˡ��������ظ�ע��
                                    END
                                    ELSE
                                    BEGIN
                                        DECLARE @errID INT  SET @errID = 0
                                        SELECT TOP 1 @errID=ID from yx_t_vipkh WHERE kh=@phone 
                                        IF (@errID <> 0)     SELECT -2	 as bs  --VIP���ѱ�ʹ��
                                        ELSE
                                        BEGIN 
                                            DECLARE @VIPID INT  
	                                        INSERT INTO YX_T_Vipkh(khid,kh,xm,xb,csrq,yddh,tbrq,klb,isjf) 
	                                            VALUES (-1,@phone,@cname,@sex,@mybirthday,@phone,GetDate(),@wxVIPType,0)

                                            SELECT @VIPID = @@identity 

                                            UPDATE wx_t_vipBinging SET VIPID = @VIPID WHERE wxOpenid=@openid
	                                        SELECT @VIPID as bs	--ע��ɹ�
                                        END
                                    END";

                string wxVIPType = "20";
                List<SqlParameter> para = new List<SqlParameter>();

                para.Add(new SqlParameter("@openid", openid));
                para.Add(new SqlParameter("@wxVIPType", wxVIPType));
                para.Add(new SqlParameter("@mybirthday", mybirthday));
                para.Add(new SqlParameter("@phone", phone));
                para.Add(new SqlParameter("@sex", sex));
                para.Add(new SqlParameter("@cname", cname)); 
                
                //strSQL = string.Format(strSQL, openid, cname, sex, mybirthday, phone, wxVIPType);//20��΢�Ż�Ա�Ĵ���
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
                {
                    string eScal = dal.ExecuteQuerySecurity(strSQL, para, out dt);
                    para.Clear();

                    if (eScal == "")
                    {
                        StringBuilder jsOutput = new StringBuilder();
                        if (Convert.ToInt32(dt.Rows[0]["bs"]) == -1)
                        {
                            dt.Clear(); dt.Dispose();


                            lblInfo.Text = "���Ѿ�ע����ˡ��������ظ�ע�ᣡ";
                            jsOutput.Append(@"swal({ title: ""������ܰ��ʾ"", text: ""-���Ѿ�ע�����-"", type: ""warning"", showCancelButton: false, confirmButtonColor: ""#59a714"", confirmButtonText: ""ȷ��"", closeOnConfirm: true }, 
                                function () { window.location.href = 'vipWaiting.aspx'; });");

                            ClientScript.RegisterClientScriptBlock(this.GetType(), "myAlert", jsOutput.ToString(), true);

                        }
                        else if (Convert.ToInt32(dt.Rows[0]["bs"]) == -2)
                        {
                            dt.Clear(); dt.Dispose();

                            lblInfo.Text = "�绰�����ѱ�ʹ�ã�";
                            jsOutput.Append(@"swal({ title: ""�绰�����ظ�"", text: ""����ֱ�ӹ����ɣ�"", type: ""warning"", showCancelButton: false, confirmButtonColor: ""#59a714"", confirmButtonText: ""ȷ��"", closeOnConfirm: true }, 
                            function () { window.location.href = 'vipBinging_v2.aspx?cid=3&phone=" + phone + "'; });");

                            ClientScript.RegisterClientScriptBlock(this.GetType(), "myAlert", jsOutput.ToString(), true);
                        }
                        else
                        {
                            dt.Clear(); dt.Dispose();

                            string gourl = "";
                            string title = "";
                            string strtext = "";

                            lblInfo.Text = "ע��ɹ���";
                            if (sid != "" && dgname != "")
                            {
                                strtext = "����ȥָ������ר�����ʣ���" + dgname + "��";
                                //Session["vipid"] = Convert.ToString(Bindvipid);
                                gourl = "VSB.aspx?sid=" + sid;
                                gourl = HttpUtility.UrlEncode(gourl, System.Text.Encoding.UTF8);

                                title = "ר������";
                            }
                            else
                            {
                                //Session["vipid"] = Convert.ToString(Bindvipid);
                                strtext = "���ȷ��ǰ���������ġ�";
                                gourl = "UserCenter.aspx";
                                title = "��������";
                            }

                            string script = string.Concat(@"swal({
	                            title : 'ע��ɹ� ',
	                            text : """, strtext, @""",
	                            type :  'warning',
                                showCancelButton : false,
	                            confirmButtonColor : '#59a714',
	                            confirmButtonText : 'ȷ��',
	                            closeOnConfirm : true
                            },function(){ 
	                            window.location.href = 'vipWaiting.aspx?gourl=", gourl, @"&title=", title, @"';
                            }); ");
                            ClientScript.RegisterClientScriptBlock(this.GetType(), "msg", script, true);

                            Session["openid"] = "";
                            Session["vipid"] = "";

                            return;
                        }
                    }
                    else
                    {
                        lblInfo.Text = "����" + eScal;                        
                    }
                }

            } 
        }
        else
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
                //strSQLExists = string.Format(strSQLExists, Session["wxopenid"]);
                para.Add(new SqlParameter("@openid", openid));
                //strSQLExists = string.Format(strSQLExists, openid);
                //clsSharedHelper.WriteInfo(strSQLExists);

                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConStr_tlsoft))
                {
                    string eScalar = dal.ExecuteQuerySecurity(strSQLExists,para,out dt);

                    if (eScalar == "")
                    {
                        //clsSharedHelper.WriteInfo(Convert.ToString(dt.Rows[0]["bs"]));
                        if(Convert.ToInt32(dt.Rows[0]["bs"])==-1)
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
<%--    <link href="../../res/css/vipweixin/vip.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script> 
    <script type="text/javascript" src="../../res/js/vipweixin/sAlert.js?ver=20150114_2"></script> 
    <script type="text/javascript" src="../../res/js/vipweixin/jweixin-1.0.0.js"></script> 
    <script type="text/javascript" src="../../res/js/sweet-alert.min.js"></script>
    <link rel="stylesheet" href="../../res/css/sweet-alert.css" />--%>
        <link href="../../css/vip.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/jquery.js"></script> 
    <script type="text/javascript" src="../../js/sAlert.js?ver=20150114_2"></script> 
    <script type="text/javascript" src="../../js/jweixin-1.0.0.js"></script> 
    <script src="../../js/sweet-alert.min.js"></script>
    <link rel="stylesheet" href="../../css/sweet-alert.css" />
    <script type="text/javascript">

        function showYear() {
            var op = document.getElementById("year").options;
            for (var i = 2000; i >= 1950; i--) {
                op.add(new Option(i.toString() + "��", i));
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
            if ($("#zmd").val() != ""){
                $("#zmdid").val($("#zmd").val());                 
                $("#zmdtxt").val($("#zmd option:selected").text());
            } else {
                $("#zmdid").val("0");
                $("#zmdtxt").val("�����ŵ�");
            }
        }


        wx.config({
            debug: false, // ��������ģʽ,���õ�����api�ķ���ֵ���ڿͻ���alert��������Ҫ�鿴����Ĳ�����������pc�˴򿪣�������Ϣ��ͨ��log���������pc��ʱ�Ż��ӡ��
            appId: '<%= wxConfig[0] %>', // ������ںŵ�Ψһ��ʶ
            timestamp: '<%= wxConfig[1] %>' , // �������ǩ����ʱ���
            nonceStr: '<%= wxConfig[2] %>', // �������ǩ���������
            signature: '<%= wxConfig[3] %>',// ���ǩ��������¼1
            jsApiList: ['checkJsApi','hideOptionMenu','onMenuShareTimeline','onMenuShareAppMessage','getLocation'] // �����Ҫʹ�õ�JS�ӿ��б�����JS�ӿ��б����¼2
        });

        wx.ready(function () {
            wx.hideOptionMenu();//���ز˵�
            

//            getLocation();
        });

        function mySubmit(e) {
            if (e.keyCode == 13) { 
                document.getElementById("form1").submit();
            };
        }

</script>
</head>
<body style=" padding:0px; margin:0px;">
    <div class="mod_color_weak qb_fs_s qb_gap qb_pt10">
		�����Ϊ����VIP
	</div>
    <form id="form1" runat="server">      
    <div class="mod_input qb_mb10">
        <label for="txtcname">��&nbsp;&nbsp;��*</label>
        <asp:TextBox ID="txtcname"  class="flex_box" runat="server"></asp:TextBox> 
    </div>
    <div class="mod_input qb_mb10">
        <div style="display: block;" >
        <input type="text" class="" value="0" name="sex" id="sex" runat="server"  style="display:none"/>
        </div>
	  ��&nbsp;&nbsp;��<label> <i class="icon_checkbox checked"  id="gradenameboy"  onclick="setSex('0');"></i>�� 
	         <i class="icon_checkbox" id="gradenamegirl" onclick="setSex('1');"></i>Ů </label>
	 </div>
    <div  class="mod_input qb_flex qb_mb10">
        <div style="display: block;" >��&nbsp;&nbsp;��* 
        <input type="text" class="" value="" name="birthday" id="birthday" runat="server"  style="display:none"/>
        </div>
        
         <select class="mod_input qb_mb10 qb_flex" id="year" name="year" style="padding:0px;margin:2px 2px 0 0;float:left;height: 31px;line-height:31px;font-size: 14px;outline: none;" onchange="check();">
         </select>
        
        <select class="mod_input qb_mb10 qb_flex" id="month" name="month" style="padding:0px;margin:2px 2px 0 0;line-height:31px;float:left;height: 31px;font-size: 14px;outline: none;" onchange="check();">
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
        <select class="mod_input qb_mb10 qb_flex" id="day" style="padding:0px;margin:2px 2px 0 0;line-height:31px;float:left;height: 31px;font-size: 14px;outline: none;" onchange="CalBirthday();">
        </select>
    </div>   
    <div class="mod_input qb_flex qb_mb10">
        <label for="txtmobi">��&nbsp;&nbsp;��*</label>
    	<input type="text" name="txtmobi" class="flex_box" id="txtmobi" runat="server" onkeydown="return mySubmit(event);" />
    </div>

    
<%--    <div  class="mod_input qb_flex qb_mb10"> 
        <label for="zmd">��������������ŵ�*</label>        
         <select class="mod_input qb_mb10 qb_flex" id="zmd" name="zmd" style="padding:0px;margin:2px 2px 0 0;height: 31px;line-height:31px;font-size: 14px;outline: none;" onchange="CalZMD();">
            <option value="0">�����ŵ�</option>
         </select> 

        <input type="text" class="" value="0" name="zmdid" id="zmdid" runat="server"  style="display:none"/>        
        <input type="text" class="" value="�����ŵ�" name="zmdtxt" id="zmdtxt" runat="server"  style="display:none"/>
    </div>--%>

 <%--   <div  class="mod_input qb_flex qb_mb10">     
        <asp:Image class="flex_box" ID="imgCheck" runat="server" ImageUrl="vipImageCode.aspx" Width="150px" />
        <label for="txtCheck">����������*</label> 
        <asp:TextBox ID="txtCheck" class="flex_box" runat="server" BackColor="#C0C0C0"></asp:TextBox>
    </div>--%>
    
    <div class="qb_fs_s qb_gap qb_pt10">
        <asp:Label ID="lblInfo" runat="server" Text="" ForeColor="Red"></asp:Label>
    </div>

<%--    <div style="display:none">
        <label for="txtmobi">������Ϣ</label>
        <asp:TextBox ID="txtprovince" runat="server"></asp:TextBox>
        <asp:TextBox ID="txtcity" runat="server"></asp:TextBox>
        <asp:TextBox ID="txtdistrict" runat="server"></asp:TextBox>
        <asp:TextBox ID="txtstreet" runat="server"></asp:TextBox> 
    </div>--%>
    
    <div class="submitDiv">
    <a id="submitBtn" class="mod_btn" href="javascript:void(0)" onclick="javascript:form1.submit();" >�ύ����</a> 
    <%--<asp:Button ID="Button1" class="mod_btn"
            runat="server" Text="�ύ" />--%>
    </div>

          
   <%--   <a href="#" id="checkJsApi">��֤�ӿ�֧��</a> 
      <a href="#" id="onMenuShareTimeline">��������Ȧ</a> 
      <a href="#" id="onMenuShareAppMessage">���������</a> --%>      

    </form>
   <div id="bottom">
    	<h1>������Ϣ�������ṩ����֧��</h1>
    </div>
    <script  type="text/javascript">
        $(document).ready(function (e) {
            $("#gradenameboy,#gradenamegirl").click(function (e) {
                if (!$(this).hasClass("checked")) {
                    $(".checked").removeClass("checked");
                    $(this).addClass("checked");
                }
            });

            showYear();
        });

	</script> 
</body>
</html>
