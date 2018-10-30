<%@ Page Language="C#" Title="周转量查询" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private const int SystemID = 3; //表示全渠道系统
    public string AppSystemKey = "",RoleID="";
    private const string ConfigKeyValue = "1";	//微信配置信息索引值 1为企业号
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
     
    protected void Page_Load(object sender, EventArgs e)
    {
        //if (clsWXHelper.CheckQYUserAuth(true))
        //{
        //    AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));

        //    //生成访问日志
        //    clsWXHelper.WriteLog(string.Format("AppSystemKey：{0} ，访问功能页[{1}]", AppSystemKey, this.Page.Title));
        //}
 
        ////鉴权及 系统身份判断结果
        //if (AppSystemKey == "")
        //{
        //    clsWXHelper.ShowError("您还未开通全渠道系统权限,请联系IT解决！");
        //}
        //else
        //{
        //    RoleID = Convert.ToString(Session["RoleID"]);
        //    if (RoleID == null || Convert.ToInt32(RoleID) < 2)
        //    {
        //        clsWXHelper.ShowError("必须拥有店长以上权限才可以访问此功能！");
        //    }
        //    else
        //    {
        //        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
        //    }
        //}
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
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
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
	<link rel="stylesheet" type="text/css" href="../../res/css/StoreSaler/Turnovers.css?ver=20160627_1">
    <%--<script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>--%>
    <script type="text/javascript" src="../../res/js/StoreSaler/jquery-2.1.4.min.js"></script>
    <script type="text/javascript" src="../../res/js/swiper-3.3.1.jquery.min.js"></script>
    <script type="text/javascript" src="../../res/js/jweixin-1.0.0.js"></script>
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
		 loading...
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
	        boardSwiper = new Swiper('.swiper-container', {
	            direction: 'horizontal',
	            slidesPerView: 5,
                paginationClickable: true
	        });

	        searchList();
            
	    });
        
        function ShowCmPanel()
        {
		    $(this).children('.mask').slideToggle().parents('.clear').siblings('.clear').children('.mask').hide();
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
				                               + "  <img class=\"arrow-icon\" src=\"../../res/img/StoreSaler/arrow_down.png\">"
			                               + " </a>	"
			                               + " <ul class=\"mask floatfix\" id=\"mask\" >"
				                           + "    <div class=\"swiper-container\">"
				                           + "      <div class=\"swiper-wrapper\">";

	                        var infoBase1 = "<li class=\"swiper-slide\">"
									      + "    <div class=\"size\">{0}</div>"
									      + "    <p>{1}</p>"
								          + "</li> ";

	                        var infoBase2 = "           </div>" 
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

	                                if (cmsl > 0) {
	                                    clothNumber += cmsl;

	                                    cmsl = getSLText(cmsl);
	                                }

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
                             // 尺码面板横向滑动
                            var boardSwiper = new Swiper('.swiper-container', {
                                direction: 'horizontal',
                                slidesPerView: 5,
                                paginationClickable: true,
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

        function getSLText(sl){
            if (sl > 9) return "<span style='color:#2211CC'>有</span>";
            else if (sl>0) return "<span style='color:#C02222'>少量</span>";
            else return "<span style='color:#C0C0C0'>无</span>";
        }

	    // 搜索功能
	    function searchFunc() {
	        if (event.keyCode == 13) {
	            var txt = $("#searchBar").val();

	            if (txt != "") { 
                    myFind = txt;
                    pageIndex = 0;
                    searchList();
	            }  
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
