<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server"> 

    public string khOptions = "";
    public string dhjOptions = "";
    protected void Page_Load(object sender, EventArgs e)
    { 
        //鉴权判断身份
        if (clsWXHelper.CheckQYUserAuth(true))
        { 
            string SystemID = "1"; 
            string AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            string CustomerID = Convert.ToString(Session["qy_customersid"]);
            string myName = Convert.ToString(Session["qy_name"]);
            string CustomerName = Convert.ToString(Session["qy_cname"]);
            if (myName != "xuelm")
                clsWXHelper.ShowError("对不起，本功能限定特殊管理员用户使用！");
            else
            {

                string strConn = clsConfig.GetConfigValue("OAConnStr");
                DataTable dt;
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(strConn))
                { 
                    //读取贸易公司
                    string strSQL = string.Concat(@"SELECT A.khid dm,A.khmc mc FROM yx_t_khb A WHERE A.ssid = 1 AND A.yxrs = 1 AND A.ty = 0
                                                                    AND ISNULL(A.sfdm,'') <> ''
                                            ORDER BY A.khmc");
                    string strInfo = dal.ExecuteQuery(strSQL, out dt);

                    if (strInfo == "")
                    {
                        CalList(ref dt, ref khOptions);
                    }
                    else
                    {
                        clsLocalLoger.WriteError("读取贸易公司出错！错误：" + strInfo);
                        clsWXHelper.ShowError("读取贸易公司出错！");
                    }


                    //读取订货编号
                    if (dt != null)
                    { 
                        dt.Clear(); dt.Dispose(); dt = null;
                    }
                    strSQL = string.Concat(@"SELECT DISTINCT TOP 10 A.dhbh dm,B.mc FROM t_customer A
                        INNER JOIN YX_T_Dhbh B ON A.dhbh = B.dm
                        ORDER BY A.dhbh DESC");
                    strInfo = dal.ExecuteQuery(strSQL, out dt);

                    if (strInfo == "")
                    {
                        CalList(ref dt, ref dhjOptions);
                    }
                    else
                    {
                        clsLocalLoger.WriteError("读取订货季出错！错误：" + strInfo);
                        clsWXHelper.ShowError("读取订货季出错！");
                    }
                    
                    
                } 
                          
            }
        }
        else
            clsWXHelper.ShowError("鉴权失败！");
    }

    private void CalList(ref DataTable dt,ref string Options)
    {
        if (dt != null)
        {
            string optionBase = @"<option value=""{0}"">{1}</option>";
            StringBuilder sbOption = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
            {
                sbOption.AppendFormat(optionBase, dr["dm"], dr["mc"]);
            }

            Options = sbOption.ToString();
            sbOption.Length = 0;

            dt.Clear(); dt.Dispose(); dt = null;
        }
    }
</script>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/Meeting/SendMessage.css" />
    <title>订货会文字消息推送</title>
</head>
<body>
    <div class="header">
		<div class="search-result">
			<p class="result-txt" id="info"></p>
		</div>
	</div>
	<div class="wrap-page">
		<div class="page page-not-header">
			<div class="inquireWrap">
				<ul class="inquireul">
					<li>
						<p class="title">订货季</p>
						<div class="inputwrap">
							<i class="arrow fa fa-caret-down fa-lg"></i>
							<select id="dhbh">
								<option value="">全部</option>
                                <%= dhjOptions %>
							</select>
						</div>
					</li>
					<li>
						<p class="title">订货批次</p>
						<div class="inputwrap">
							<i class="arrow fa fa-caret-down fa-lg"></i>
							<select id="bat">
								<option value="">全部</option>
								<option value="1">第一批</option>
								<option value="2">第二批</option>
								<option value="3">第三批</option>
							</select>
						</div>
					</li>
					<li>
						<p class="title">贸易公司</p>
						<div class="inputwrap">
							<i class="arrow fa fa-caret-down fa-lg"></i>
							<select id="khid">
								<option value="">全部</option>
                                <%=khOptions %>
							</select>
						</div>
					</li>
					<li>
						<p class="title">所在酒店</p>
						<div class="inputwrap">
							<div class="icon hotel"></div>
							<input class="inputbox" type="text" id="txthotel">
						</div>
					</li>
					<li>
						<p class="title">姓名</p>
						<div class="inputwrap">
							<div class="icon name"></div>
							<input class="inputbox" type="text" id="txtcname">
						</div>
					</li>
					<li>
						<p class="title">联系电话</p>
						<div class="inputwrap">
							<div class="icon phone"></div>
							<input class="inputbox" type="text" id="txtphone">
						</div>
					</li>
				</ul>
				<div class="btn" id="inquireBtn">查询发送对象</div>
			</div>
			<div class="sendCon">
				<p class="title">发送的起始索引和发送内容</p><input style="width:50px" type="text" id="beginIndex" value="0">
				    <textarea class="sendtxt" type="text" id="msg"></textarea>
				<div class="btn" id="sendBtn">推送微信消息</div>
			</div>
		</div>
	</div>
	<!-- 弹出面板 -->
	<div id="mask-layer">
        <div class="load loader-container load8">
            <div class="loader"></div>
            <p class="loader-text">正在执行..</p>
        </div>
        <div class="loader-container successbox">
			<p class="loader-text"></p>
		</div>
    </div>
	<script type="text/javascript" src="../../res/js/jquery.js"></script>
	<script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
	<script type="text/javascript">
	    $(document).ready(function () {
	        LeeJSUtils.stopOutOfPage(".page-not-header", true);

	        $("#inquireBtn").on("click", function () {
	            Send("Select");
	        });
	        $("#sendBtn").on("click", function () {
	            Send("SendSelect");
	        });
	    });
         
	    function Send(ctrl) {
	        var dhbh = $("#dhbh").val();
	        var bat = $("#bat").val();
	        var khid = $("#khid").val();
	        var hotel = $("#txthotel").val();
	        var cname = $("#txtcname").val();
	        var mobile = $("#txtphone").val();
	        var msg = $("#msg").val();
	        var beginIndex = $("#beginIndex").val();

	        if (ctrl == "SendSelect"){
	            if ($("#info").html() == "") {
	                alert("必须先查询一次，确认发送范围！");
	                return;
	            }else if (msg == "") {
	                alert("必须先输入发送内容！"); 
	                return;
	            }
	        } 

	        $("#mask-layer").show();

	        $.ajax({
	            url: "SendMessageCore.aspx",
	            type: "POST",
	            dataType: "text",
	            data: { ctrl: ctrl, dhbh: dhbh, bat: bat, khid: khid, hotel: hotel, cname: cname, mobile: mobile, msg: msg, beginIndex: beginIndex },
	            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
	            timeout: 600000,
	            error: function (XMLHttpRequest, textStatus, errorThrown) {
	                $("#mask-layer").hide();
	                alert("您的网络好像出了点问题,请稍后重试...");
	            },
	            success: function (data) {
	                $("#mask-layer").hide();

	                if (data == "") data = "执行成功！";
	                $("#info").html(data);
	                alert(data);
	            }  //end success 
	        });
	    }
	</script>
</body>
</html>
