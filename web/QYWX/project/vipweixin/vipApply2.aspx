<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %> 

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">  
    string selectZMD = "";  //专卖店构造字段
    protected void Page_Load(object sender, EventArgs e)
    {
        //Session["wxopenid"] = "oarMEt3YWz0gndx1RmWolC423swM";       //调试使用:xuelm
        Session["wxopenid"] = "oyLvDjg2l7ohUG5FcgZ07hNMyWKU";       //调试使用

        if (IsPostBack)     //提交
        {
            //WriteLog2("提交");

            string cname = this.txtcname.Text;
            string sex = this.sex.Value;
            string mybirthday = this.birthday.Value;
            string phone = this.txtmobi.Value;
            string province = txtprovince.Text; //省份：福建省
            string city = txtcity.Text ;       //城市：泉州市
            string district = txtdistrict.Text;   //区域：晋江市
            string street = txtstreet.Text;     //路段：洪山路
            
            string khid = ddlZMD.SelectedValue.ToString();
            string zmdmc = ddlZMD.SelectedItem.Text;            

            if (Session["wxOpenid"] == null || Session["wxOpenid"] == "")
            {
                lblInfo.Text = "访问超时，请重新从微信访问！";
                return;                
            }
            else if (cname == "")
            {
                lblInfo.Text = "请输入姓名！";
                txtcname.Focus();
            }
            else if (mybirthday == "")
            {
                lblInfo.Text = "请选择出生日期！";
            }
            else if (phone == "")
            {
                lblInfo.Text = "请输入手机号码！";
                txtmobi.Focus();
            }
            else if (phone.Length != 11 || phone.IndexOf('1') != 0)                
            {
                lblInfo.Text = "您输入的手机号码不合法！"; 
                txtmobi.Focus();
            }
            else
            {                                
                //lblInfo.Text = "所有输入均正确！";
                string cid = Request.QueryString["cid"].ToString();
                DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
                dbHelper.ConnectionString = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;        //调试使用

                string strSQL = @"  IF EXISTS (SELECT TOP 1 ID FROM wx_t_VipApply WHERE wxOpenid='{0}')
                                    BEGIN
	                                    SELECT -1		--您已经注册过了。不允许重复注册
                                    END
                                    ELSE
                                    BEGIN
	                                    INSERT INTO wx_t_VipApply(wxOpenid,vipName,sex,birthday,Phone,khid,zmdmc,province,city,district,street) 
	                                        VALUES ('{0}','{1}','{2}','{3}','{4}',{5},'{6}','{7}','{8}','{9}','{10}')
	                                    SELECT 1		--注册成功
                                    END";

                strSQL = string.Format(strSQL, Session["wxOpenid"], cname, sex, mybirthday, phone, khid, zmdmc, province, city, district, street);
                
                WriteLog2(strSQL);
                
                int eScalar = Convert.ToInt32(dbHelper.ExecuteScalar(strSQL));
                StringBuilder jsOutput = new StringBuilder(@"<script type=""text//javascript"">");
                if (eScalar == -1)
                {
                    //lblInfo.Text = "您已经注册过了。不允许重复注册！";
                    //jsOutput.Append(@"sAlert(""利郎温馨提示："", ""您已经注册过了。不允许重复注册！"");");
                    jsOutput.Append(@"alert(""您已经注册过了。不允许重复注册！"");");
                }
                else if (eScalar == 1)
                {
                    //lblInfo.Text = "注册成功！";
                    //jsOutput.Append(@"sAlert(""利郎温馨提示："", ""注册成功！"");");

                    jsOutput.Append(@"alert(""注册成功！"");");
                }
                jsOutput.Append("<//script>");
                
                lblInfo.Text = jsOutput.ToString();
                
                //Response.Write(jsOutput.ToString());                
            }
            
            
            //string testput = string.Concat("姓名为：", myname
            //                , "生日为：", this.birthday.Value
            //                , "选择性别为：", sex
            //                , "电话号码为：", phone);
            //Response.Write(testput);
            //lblInfo.Text = testput;
            //string chkCode = txtCheck.Text;
            //if (Convert.ToString(Session["CheckResult"]) == chkCode)
            //{
            //    lblInfo.Text = "验证正确！";
            //}
            //else
            //{
            //    lblInfo.Text = "验证错误！源：" + Convert.ToString(Session["CheckResult"]) ;
            //}
        }
        else
        {
            //WriteLog2("初始化");
            
            string cid = Request.QueryString["cid"].ToString();
            DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
            if (Session["wxopenid"] == null || Session["wxopenid"] == "")
            {
                Response.Clear();
                Response.Write("非法访问或访问超时，请从微信公众号[利郎男装]重新访问！");
                Response.End();
                return;
            }
            else
            {
                //获取地理位置           
                string sqlcomm = string.Format(@"select top 1 Lat,Lon from [wx_userPosition] 
    where wxOpenid = '{0}'
    order by CREATEtime desc", Session["wxopenid"]);
                using (IDataReader reader = dbHelper.ExecuteReader(sqlcomm))
                {
                    DataTable dt = new DataTable();
                    dt.Columns.Add("khid", typeof(int), "");
                    dt.Columns.Add("zmdmc", typeof(string), "");

                    if (reader.Read())
                    {
                        string province = ""; //省份：福建省
                        string city = "";       //城市：泉州市
                        string district = "";   //区域：晋江市
                        string street = "";     //路段：洪山路
                        string posturl = string.Format(common.baidumap, reader[0], reader[1]);
                        JObject jo = ((JObject)JsonConvert.DeserializeObject(common.HttpRequest(posturl)));
                        string status = jo["status"].ToString();
                        if (status == "0")
                        {
                            //正常返回
                            province = jo["result"]["addressComponent"]["province"].ToString();
                            city = jo["result"]["addressComponent"]["city"].ToString();
                            district = jo["result"]["addressComponent"]["district"].ToString();
                            street = jo["result"]["addressComponent"]["street"].ToString();

                            txtprovince.Text = province;
                            txtcity.Text = city;
                            txtdistrict.Text = district;
                            txtstreet.Text = street;

                            province = province.Replace("省", "");
                            city = city.Replace("市", "");
                            district = district.Replace("市", "").Replace("县", "").Replace("区", "");

                            string AISqlFind = string.Concat(province, city, district, street);


                            //逐渐缩小范围                                               
                            //string provinceSql = " AND '" + province + "' like '%' + jmPro + '%' ";
                            //string citySql = " AND jmCity LIKE '%" + city + "%' ";
                            //string districtSql = " AND jmArea LIKE '%" + district + "%' ";
                            //string streetSql = " AND jmStreet LIKE '%" + street + "%' ";

                            //DataTable dt = GetStoreInfo(dbHelper, string.Concat(provinceSql, citySql, districtSql, streetSql));                       
                            //if (dt.Rows.Count == 0) dt = GetStoreInfo(dbHelper, string.Concat(provinceSql, citySql, districtSql));
                            //if (dt.Rows.Count == 0) dt = GetStoreInfo(dbHelper, string.Concat(provinceSql, citySql));
                            //if (dt.Rows.Count == 0) dt = GetStoreInfo(dbHelper, string.Concat(provinceSql));

                            string AISql1 = string.Concat(" AND '", AISqlFind, "' LIKE (replace(jmPro,'省','') + replace(jmCity,'市','') + replace(replace(replace(jmArea,'市',''),'县',''),'区','')  + '%') ");
                            string AISql2 = string.Concat(" AND '", AISqlFind, "' LIKE (replace(jmPro,'省','') + replace(jmCity,'市','') + '%') ");
                            string AISql3 = string.Concat(" AND '", AISqlFind, "' LIKE (replace(jmPro,'省','') + '%') ");

                            dt = GetStoreInfo(dbHelper, AISql1);
                            if (dt.Rows.Count == 0) dt = GetStoreInfo(dbHelper, AISql2);
                            if (dt.Rows.Count == 0) dt = GetStoreInfo(dbHelper, AISql3);
                        }
                    }

                    dt.Rows.Add(0, "其它门店");
                    ddlZMD.DataSource = dt.DefaultView;
                    ddlZMD.DataTextField = "zmdmc";
                    ddlZMD.DataValueField = "khid";
                    ddlZMD.DataBind();

                    //                else
                    //                {
                    //                    msg.Text = @"发送你的位置，寻找离你最近的专卖店：<br/>
                    //                        1、点击左下方的“小键盘”<br/>
                    //                        2、点击“+”键<br/>
                    //                        3、点击“位置”<br/>
                    //                        4、成功定位后点击“发送”";
                    //                }
                }

            }
        }
    }

    private DataTable GetStoreInfo(DAL.SqlDbHelper dbHelper,string FindSql)
    {
        DataTable dt = new DataTable();
        string exeSql = @"SELECT DISTINCT TOP 100 khid,zmdmc
                    FROM yx_t_jmspb WHERE 1=1 {0} 
                ORDER BY zmdmc";
        exeSql = string.Format(exeSql, FindSql);

        WriteLog2(exeSql);

        dt = dbHelper.ExecuteDataTable(exeSql);
                 
        return dt;        
    }

    ///
    /// 写日志(用于跟踪)       -- By:薛灵敏 2014-12-11
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
    <title>VIP申请</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link href="css/vip.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="js/jquery.js"></script>
    <script type="text/javascript" src="js/sAlert.js"></script>
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

         
</script>
</head>
<body>
    <div class="mod_color_weak qb_fs_s qb_gap qb_pt10">
		注册成为利郎VIP
	</div>
    <form id="form1" runat="server">  
    <div class="mod_input qb_mb10">
        <label for="txtcname">姓&nbsp;&nbsp;名*</label>
        <asp:TextBox ID="txtcname"  class="flex_box" runat="server"></asp:TextBox> 
    </div>
    <div class="mod_input qb_mb10">
        <div style="display: block;" >
        <input type="text" class="" value="" name="sex" id="sex" runat="server"  style="display:none"/>
        </div>
	  性&nbsp;&nbsp;别：<label> <i class="icon_checkbox checked"  id="gradenameboy"  onclick="setSex('男');"></i>男 
	         <i class="icon_checkbox" id="gradenamegirl" onclick="setSex('女');"></i>女 </label>
	 </div>
    <div  class="mod_input qb_flex qb_mb10">
        <div style="display: block;" >生&nbsp;&nbsp;日* 
        <input type="text" class="" value="" name="birthday" id="birthday" runat="server"  style="display:none"/>
        </div>
        
         <select class="mod_input qb_mb10 qb_flex" id="year" name="year" style="padding:0px;margin:2px 2px 0 0;float:left;height: 31px;line-height:31px;font-size: 14px;outline: none;" onchange="check();">
        </select>
        
        <select class="mod_input qb_mb10 qb_flex" id="month" name="month" style="padding:0px;margin:2px 2px 0 0;line-height:31px;float:left;height: 31px;font-size: 14px;outline: none;" onchange="check();">
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
        <select class="mod_input qb_mb10 qb_flex" id="day" style="padding:0px;margin:2px 2px 0 0;line-height:31px;float:left;height: 31px;font-size: 14px;outline: none;" onchange="CalBirthday();">
        </select>
    </div>   
    <div class="mod_input">
        <label for="txtmobi">手&nbsp;&nbsp;机*</label>
    	<input type="text" name="txtmobi" class="flex_box" id="txtmobi" runat="server" />
    </div>
    <div  class="mod_input qb_flex qb_mb10"> 
        <label for="ddlZMD">离您最近的利郎门店*</label> 
        <asp:DropDownList ID="ddlZMD" class="flex_box" runat="server">        
        </asp:DropDownList>
    </div>
 <%--   <div  class="mod_input qb_flex qb_mb10">     
        <asp:Image class="flex_box" ID="imgCheck" runat="server" ImageUrl="vipImageCode.aspx" Width="150px" />
        <label for="txtCheck">输入结果数字*</label> 
        <asp:TextBox ID="txtCheck" class="flex_box" runat="server" BackColor="#C0C0C0"></asp:TextBox>
    </div>--%>
    
    <div class="qb_fs_s qb_gap qb_pt10">
        <asp:Label ID="lblInfo" runat="server" Text="" ForeColor="Red"></asp:Label>
    </div>

    <div style="display:inline">
        <label for="txtmobi">地理信息</label>
        <asp:TextBox ID="txtprovince" runat="server"></asp:TextBox>
        <asp:TextBox ID="txtcity" runat="server"></asp:TextBox>
        <asp:TextBox ID="txtdistrict" runat="server"></asp:TextBox>
        <asp:TextBox ID="txtstreet" runat="server"></asp:TextBox> 
    </div>
    
    <div class="submitDiv">
    <a id="submitBtn" class="mod_btn" href="javascript:void(0)" onclick="javascript:form1.submit();" >提交</a>
    <asp:Button ID="Button1" class="mod_btn"
            runat="server" Text="提交" />
    </div>
    </form>
   <div id="bottom">
    	<h1>利郎信息技术部提供技术支持</h1>
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
