<%@ Page Language="C#" Title="周转量查询" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private const int SystemID3 = 3; //表示全渠道系统
    private const int SystemID1 = 1; //表示ERP系统 
    private const string ConfigKeyValue = "1";	//微信配置信息索引值 1为企业号
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数

    private string AppSystemKey1 = "";  //t_user的ID
    private string khList = "";     //客户信息列表。 |khid1,khmc1|khid2,khmc2|khid3,khmc3
     
    protected void Page_Load(object sender, EventArgs e)
    {
        string AppSystemKey3 = "";
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            AppSystemKey3 = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID3));

            //生成访问日志
            clsWXHelper.WriteLog(string.Format("AppSystemKey：{0} ，访问功能页[{1}]", AppSystemKey3, this.Page.Title));
        }
        
        string strErr = "";
        //鉴权及 系统身份判断结果
        if (AppSystemKey3 == "")
        {
            strErr = "您还未开通全渠道系统权限,请联系IT解决！";
        }
        
        if (strErr == ""){
            AppSystemKey1 = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID1)); 
            if (AppSystemKey1 == "")
            {
                strErr = "您还未开通协同系统权限，请联系IT解决！";
            } 
        }
         
        
        if (strErr == ""){ 
            string zCon = "Data Source=192.168.35.10;Initial Catalog=tlsoft;User ID=ABEASD14AD;password=+AuDkDew";
            //string zCon = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM zDal = new LiLanzDALForXLM(zCon))
            {
                string id_menu = "11450"; //菜单[订购申请单处理] 的id_menu
                string strSql = string.Concat(@"SELECT '|' + CONVERT(VARCHAR(10),B.khid) + ',' + B.khmc  FROM t_user_qx A
                    INNER JOIN yx_t_khb B ON A.id_ssid = B.khid 
                    WHERE id_user = ", AppSystemKey1, " AND id_menu = ", id_menu , 
                        " FOR XML PATH('')   ");

                object objKhList = null;
                string strInfo = zDal.ExecuteQuery(strSql, out objKhList);
                if (strInfo != "")
                {
                    clsLocalLoger.WriteError(string.Concat("查询权限系统出错！错误：", strInfo));
                    strErr = "执行错误！请稍后重试！";
                }
                else
                {
                    if (objKhList == null) strErr = "您必须先开通ERP上的 营销管理 - 补货管理 - 订购申请单处理 功能的访问权限！";
                    else
                    {
                        //取用户信息
                        khList = Convert.ToString(objKhList);

                        if (khList.IndexOf("|", 1) == -1)    //包含一个以上的公司
                        {
                            khList = khList.Remove(0, 1);
                        }
                        else
                        {
                            khList = string.Concat("0,请选择", khList);                            
                        }                        
                        
                        //clsSharedHelper.WriteInfo(khList); return;
                    }                       
                }
            }                
        }
               
        if (strErr == "")  wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
        else         clsWXHelper.ShowError(strErr);
    }
</script>
<html>
<head runat="server">
	<meta charset="utf-8">
	<meta content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" name="viewport">
	<meta content="telephone=no" name="format-detection">
	<meta content="yes" name="apple-mobile-web-app-capable">
	<meta content="black" name="apple-mobile-web-app-status-bar-style">
	<link rel="stylesheet" type="text/css" href="../../res/css/swiper-3.3.1.min.css"> 
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
	<script type="text/javascript" src="../../res/js/StoreSaler/jquery-2.1.4.min.js"></script>
	<script type="text/javascript" src="../../res/js/swiper-3.3.1.jquery.min.js"></script>
    <script type="text/javascript" src="../../res/js/jweixin-1.0.0.js"></script>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
	<link rel="stylesheet" type="text/css" href="../../res/css/StoreSaler/Turnovers.css?ver=20160629">
    <%--<script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>--%>
	<title>周转量查询</title>     
    
    <style>
    
        /*提示层样式*/
        .mymask {
            color: #fff;
            position:fixed;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 5000;
            font-size: 1em;
            text-align: center;
            display: none;
            background-color: rgba(0,0,0,0.3);
        }

        .loader {
            position: absolute;
            top: 50%;
            left: 50%;
            transform:translate(-50%,-50%);
            -webkit-transform:translate(-50%,-50%);
            background-color: #272b2e;
            padding:15px;
            border-radius: 5px;
            box-sizing: border-box;
            box-shadow: 0px 0px 1px #555;
        }

        #loadtext {
            margin-top: 5px;
            font-weight: bold;
        }
                
        .clothImg
        { 
            width: 60px;
            height: 60px;
            border: 2px solid #ebebeb;
            border-radius: 10%;
            -webkit-border-radius: 10%;
            background-size: cover;
            background-position: 50% 50%;
            background-repeat: no-repeat;
        }
    </style>  
</head>
<body style="overflow: hidden;">
     <div class="searchBg">
		<input class="searchBar" id="searchBar" type="text" name="" placeholder="搜索"  onkeydown="searchFunc()">
	</div>
	<div class="content">
	<ul class="content-ul" id="contentUl"> 
	</ul>
	<div class="btn-more">
		<a class="more" href="javascript:searchList();">显示更多</a>
	</div>
	</div>
     
     
    <!--提示层-->
    <div class="mymask">
        <div class="loader">
            <div>
                <i class="fa fa-2x fa-warning (alias)"></i>
            </div>
            <p id="loadtext">
                正在处理...
            </p>
        </div>
    </div>


	<!-- 列表显示与隐藏切换 -->
	<script type="text/javascript">
	    //以下是实现微信的JSAPI
	    wx.config({
	        debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
	        appId: '<%= wxConfig[0] %>', // 必填，企业号的唯一标识，此处填写企业号corpid
	        timestamp: '<%= wxConfig[1] %>', // 必填，生成签名的时间戳
	        nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
	        signature: '<%= wxConfig[3] %>', // 必填，签名，见附录1
	        jsApiList: ['uploadImage'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
	    });
	    var boardSwiper;
	    $(document).ready(function () {
	        // 尺码面板横向滑动
	        var boardSwiper = new Swiper('.swiper-container', {
	            direction: 'horizontal',
	            slidesPerView: 5,
	            paginationClickable: true
	        });

	        searchList();

	        SaveDJ();  //保存
	        //DeleteBhDj(954061); //测试删除
	    });

	    function ShowCmPanel() {
            //调整图标风格
            var myclass = $(this).find(".arrow>i").attr("class");
            if (myclass.indexOf("down") > -1) {
                myclass = myclass.replace("down", "up");
                $(this).find('.mask').slideDown();
            } else {
                myclass = myclass.replace("up", "down");
                $(this).find('.mask').slideUp();
            }

            $(this).find(".arrow>i").attr("class", myclass);

            //$(this).find('.mask').slideToggle();
        }

        function uploadImage() {            
            var picurl = $(this).attr("src");
            wx.previewImage({
                current: picurl, // 当前显示图片的http链接
                urls: [picurl] // 需要预览的图片http链接列表
            });
        }

//        function showLoader(icon, msg) {
////            LeeJSUtils.showMessage(icon, msg);
        //        }

        //提示层
        function showLoader(type, txt) {
            switch (type) {
                case "loading":
                    $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                    $("[id$=loadtext]").text(txt);
                    $(".mymask").show();
                    setTimeout(function () {
                        $(".mymask").fadeOut(500);
                    }, 15000);
                    break;
                case "successed":
                    $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                    $("[id$=loadtext]").text(txt);
                    $(".mymask").show();
                    setTimeout(function () {
                        $(".mymask").fadeOut(500);
                    }, 500);
                    break;
                case "error":
                    $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("[id$=loadtext]").text(txt);
                    $(".mymask").show();
                    setTimeout(function () {
                        $(".mymask").fadeOut(500);
                    }, 2000);
                    break;
                case "warn":
                    $(".mymask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("[id$=loadtext]").text(txt);
                    $(".mymask").show();
                    setTimeout(function () {
                        $(".mymask").fadeOut(500);
                    }, 1000);
                    break;
            }
        }

        var myFind = "";
        var pageIndex = 0;
        function searchList(){        
            var timestamp = Date.parse(new Date());
	        showLoader("loading", "正在加载数据...");

	        $.ajax({
	            type: "POST",
	            timeout: 15000,
	            datatype: "html",
	            url: "TurnoversCore.aspx",
	            data: { "ctrl": "getTurnovers", "sphh": myFind, "pageIndex": pageIndex, "ref": timestamp },
	            cache: false,
	            contentType: "application/x-www-form-urlencoded; charset=utf-8",
	            success: function (data) {
	                data = JSON.parse(data);

	                if (data.err != "") {
	                    showLoader("error", data.err);
	                } else {
	                    showLoader("successed", "查询成功");

	                    if (pageIndex == 0) $("#contentUl").html("");

	                    pageIndex = data.nextPage;
	                    SetNextButtonVis();

	                    var len = data.list.length;
	                    if (len > 0) {
	                        var listInfo = "";

	                        var infoBase0 = "<li class=\"clear\">"
		                                   + " <div class=\"clothImg\" src=\"{0}\" style=\"background-image:url({1})\"></div>"
			                               + " <a class=\"clothName\">{2}</a>"
			                               + " <a class=\"clothNumber\">{3}</a>"
			                               + " <a class=\"arrow\" href=\"javascript:void(0)\">"
	                        //				                               + "  <img class=\"arrow-icon\" src=\"../../res/img/StoreSaler/arrow_down.png\">"
                                           + " <i class=\"arrow-icon fa fa-angle-down fa-lg\"></i>"
			                               + " </a>	"
			                               + " <ul class=\"mask floatfix\" id=\"mask\" >"
				                           + "    <div class=\"swiper-container\">"
				                           + "      <div class=\"swiper-wrapper\">";

	                        var infoBase1 = "<li class=\"swiper-slide\">"
									      + "    <div class=\"size\">{0}</div>"
									      + "    <p>{1}</p>"
								          + "</li> ";

	                        var infoBase2 = "           </div>" 
					                + "             <div class=\"swiper-pagination\"></div>"
				                    + "         </div>"
			                        + "     </ul> "
		                            + " </li> ";

	                        var clothNumber;
	                        var spinfo;
	                        var cmLen;
	                        var cmname;
	                        var Addinfo1;
	                        var cmsl;
	                        var Addinfo;
	                        for (var i = 0; i < len; i++) {
	                            spinfo = data.list[i];

	                            clothNumber = 0;

	                            cmname = spinfo.cmname.split(",");
	                            cmLen = cmname.length;

	                            clothNumber = 0;
	                            Addinfo1 = "";
	                            for (var j = 0; j < cmLen; j++) {
	                                cmsl = parseInt(eval("spinfo.kc._" + cmname[j]));
 
	                                clothNumber += cmsl;

	                                cmsl = getSLText(cmsl); 

	                                Addinfo1 = Addinfo1 + infoBase1.format(cmname[j], cmsl);
	                            }

	                            Addinfo = infoBase0.format(spinfo.pic, spinfo.minipic, spinfo.sphh, getSLText(clothNumber)) + Addinfo1 + infoBase2;

	                            listInfo = listInfo + Addinfo + "\n";
	                        }

	                        $("#contentUl").append(listInfo);

	                        listInfo = "";
	                        data = "";

	                        $("#contentUl").find(".clear").on("click", ShowCmPanel);
	                        $("#contentUl").find(".clothImg").on("click", uploadImage);

                            if(boardSwiper!=null){
                                boardSwiper=null;
                            }
	                        var boardSwiper = new Swiper('.swiper-container', {
	                            direction: 'horizontal',
	                            slidesPerView: 5,	                            
	                            paginationClickable: true
	                        });
                            $('.mask').css('display','none'); 
                            
	                    } else {
	                        $("#contentUl").html("没有找到数据!");
	                    }
	                }
	            },
	            error: function (XMLHttpRequest, textStatus, errorThrown) {
	                showLoader("error", "加载错误！");
	                if (errorThrown.toString() != "") {     //如果没有错误，则不输出（AJAX调用期间，页面被关掉，也会出此错误；但错误内容为空）
	                    alert(errorThrown);
	                }
	            }
	        });
        }

        function getSLText(sl) {            
//            if (sl > 9) return "<span style='color:#2211CC'>有</span>";
//            else if (sl > 0) return "<span style='color:#C02222'>少量</span>";
//            else return "<span style='color:#C0C0C0'>无</span>";

            if (sl > 9) return "<span class='sizeBlue'>" + sl.toString() + "</span>";
            else if (sl > 0) return "<span class='sizeRed'>" + sl.toString() + "</span>";
            else return "<span class='sizeGray'>无</span>";
        }

        ///保存单据，测试代码暂时存在这里。
        function SaveDJ() {
            var timestamp = Date.parse(new Date());
            showLoader("loading", "正在提交订单...");

            var khid = "249";
            var bz = "本单是由手机销售神器自动下单创建！";
            var jehj = "12340";
            var SpmxJson = "{"
   + " \"list\": ["
   + "     {"
   + "         \"yphh\": \"Q1110081S\","
   + "         \"sphh\": \"1XCK1181S\","
   + "         \"sl\": \"4\","
   + "         \"dj\": \"599\","
   + "         \"je\": \"2196\","
   + "         \"cmmx\": ["
   + "             {"
   + "                 \"cmName\": \"cm12\","
   + "                 \"sl\": \"1\""
   + "             },"
   + "             {"
   + "                 \"cmName\": \"cm15\","
   + "                 \"sl\": \"2\""
   + "             },"
   + "             {"
   + "                 \"cmName\": \"cm18\","
   + "                 \"sl\": \"1\""
   + "             }"
   + "         ]"
   + "     },"
   + "     {"
   + "         \"yphh\": \"B12012891\","
   + "         \"sphh\": \"1XBL00102\","
   + "         \"sl\": \"6\","
   + "         \"dj\": \"1500\","
   + "         \"je\": \"9000\","
   + "         \"cmmx\": ["
   + "             {"
   + "                 \"cmName\": \"cm12\","
   + "                 \"sl\": \"1\""
   + "             },"
   + "             {"
   + "                 \"cmName\": \"cm15\","
   + "                 \"sl\": \"4\""
   + "             },"
   + "             {"
   + "                 \"cmName\": \"cm18\","
   + "                 \"sl\": \"1\""
   + "             }"
   + "         ]"
   + "     }"
   + " ]"
+ " }";

            $.ajax({
                type: "POST",
                timeout: 15000,
                datatype: "html",
                url: "TurnoversCore.aspx",
                data: { "ctrl": "SaveBhDj", "khid": khid, "bz": bz, "jehj": jehj, "SpmxJson": SpmxJson, "ref": timestamp },
                cache: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                success: function (data) {
                    alert(data);
//                    if (data == "Successed") showLoader("successed", "保存成功！");
//                    else {
//                        alert(data);
//                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "保存错误！");
                    if (errorThrown.toString() != "") {     //如果没有错误，则不输出（AJAX调用期间，页面被关掉，也会出此错误；但错误内容为空）
                        alert(errorThrown);
                    }
                }
            });
        }


        ///删除单据，测试代码暂时存在这里。
        function DeleteBhDj(delID) {
            var timestamp = Date.parse(new Date());
            showLoader("loading", "正在提交订单...");


            $.ajax({
                type: "POST",
                timeout: 15000,
                datatype: "html",
                url: "TurnoversCore.aspx",
                data: { "ctrl": "DeleteBhDj", "id": delID, "ref": timestamp },
                cache: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                success: function (data) {
                    alert(data);
                    //                    if (data == "Successed") showLoader("successed", "保存成功！");
                    //                    else {
                    //                        alert(data);
                    //                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showLoader("error", "执行失败！");
                    if (errorThrown.toString() != "") {     //如果没有错误，则不输出（AJAX调用期间，页面被关掉，也会出此错误；但错误内容为空）
                        alert(errorThrown);
                    }
                }
            });
        }



	    // 搜索功能
	    function searchFunc() {
	        if (event.keyCode == 13) {
	            var txt = $("#searchBar").val();
                 
                myFind = txt;
                pageIndex = 0;
                searchList(); 
	        } 
	    }

        function SetNextButtonVis(){
            if (pageIndex < 0)  $(".btn-more").hide();
            else $(".btn-more").show();
        }

        
    String.prototype.format = function (args) {
        var result = this;
        if (arguments.length > 0) {
            if (arguments.length == 1 && typeof (args) == "object") {
                for (var key in args) {
                    if (args[key] != undefined) {
                        var reg = new RegExp("({" + key + "})", "g");
                        result = result.replace(reg, args[key]);
                    }
                }
            }
            else {
                for (var i = 0; i < arguments.length; i++) {
                    if (arguments[i] != undefined) {
                        //var reg = new RegExp("({[" + i + "]})", "g");//这个在索引大于9时会有问题 

                        var reg = new RegExp("({)" + i + "(})", "g");
                        result = result.replace(reg, arguments[i]);
                    }
                }
            }
        }
        return result;
    }
	</script>

</body>
</html>
