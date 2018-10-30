<%@ Page Language="C#" %> 
<%@ Import Namespace="nrWebClass" %>  

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
 
    
	private const string ConfigKey = "7";	//APPID 
    public string SharedLogo = "http://tm.lilanz.com/qywx/res/img/EasyBusiness/lilanzlogo.jpg"; //分享图片
    
    public System.Collections.Generic.List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数

    public string StoreName = "";   //店铺名称
    public string StoreAddress = "";    //店铺地址
    public double LilanzLat = 0.0;  //利郎公司的地理位置
    public double LilanzLng = 0.0;

    string dbConn = clsConfig.GetConfigValue("OAConnStr");   
    protected void Page_Load(object sender, EventArgs e)
    {
        //SetIsDebugMode(); 

        string infoID = Convert.ToString(Request.Params["id"]);
        if (string.IsNullOrEmpty(infoID))
        {
            clsWXHelper.ShowError("访问错误！");
        } 

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        {
            string strSQL = string.Concat(@"SELECT TOP 1 B.mdmc,D.addressInfo,D.Lat,D.Lng FROM t_mdb B 
                                            INNER JOIN yx_t_jmspb C ON B.mdid = C.mdid
                                            INNER JOIN wx_t_StorePointLocation D ON D.mapType = 'jm' AND D.mapID = C.ID
                                            WHERE D.id = ",infoID);
            System.Data.DataTable dt;
            string strInfo = dal.ExecuteQuery(strSQL, out dt);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("[轻商务]读取单个加盟审批门店位置时失败！错误：", strInfo));
                clsWXHelper.ShowError("系统维护中...");
                return;
            }

            if (dt.Rows.Count == 0)
            {
                clsWXHelper.ShowError("系统正在维护中...");
                return;                
            }

            System.Data.DataRow dr = dt.Rows[0];
            StoreName = Convert.ToString(dr["mdmc"]);
            StoreAddress = Convert.ToString(dr["addressInfo"]);
            LilanzLat = Convert.ToDouble(dr["Lat"]); 
            LilanzLng = Convert.ToDouble(dr["Lng"]);

            clsSharedHelper.DisponseDataTable(ref dt);
        } //end using 
         
        if (Request.Url.AbsoluteUri.ToLower().Contains("/qywx/") == false)
        {
            SharedLogo = SharedLogo.Replace("/qywx/", "/");
        }
        
       ////解码
       // transform(wgLat, wgLng, out mgLat, out mgLon);        //后经过测试，发现无须解码        
	   	              
		//获取微信JS_API config相关配置 
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKey); 
         
        string myIP = Request.UserHostName;
        clsWXHelper.WriteLog("0", "利郎轻商务_访客", Request.Url.AbsoluteUri, myIP, "访问周边位置_门店地图");
    }
        
    private void SetIsDebugMode()
    {
        dbConn = "server='192.168.35.10';database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
    }

    //const double pi = 3.14159265358979324;

    //const double a = 6378245.0;
    //const double ee = 0.00669342162296594323;

    //// World Geodetic System ==> Mars Geodetic System
    //public void transform(double wgLat, double wgLon, out double mgLat, out double mgLon)
    //{
    //    if (outOfChina(wgLat, wgLon))
    //    {
    //        mgLat = wgLat;
    //        mgLon = wgLon;
    //        return;
    //    }
    //    double dLat = transformLat(wgLon - 105.0, wgLat - 35.0);
    //    double dLon = transformLon(wgLon - 105.0, wgLat - 35.0);
    //    double radLat = wgLat / 180.0 * pi;
    //    double magic = Math.Sin(radLat);
    //    magic = 1 - ee * magic * magic;
    //    double sqrtMagic = Math.Sqrt(magic);
    //    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    //    dLon = (dLon * 180.0) / (a / sqrtMagic * Math.Cos(radLat) * pi);
    //    mgLat = wgLat + dLat;
    //    mgLon = wgLon + dLon;
    //}

    //private bool outOfChina(double lat, double lon)
    //{
    //    if (lon < 72.004 || lon > 137.8347)
    //        return true;
    //    if (lat < 0.8293 || lat > 55.8271)
    //        return true;
    //    return false;
    //}

    //private double transformLat(double x, double y)
    //{
    //    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * Math.Sqrt(Math.Abs(x));
    //    ret += (20.0 * Math.Sin(6.0 * x * pi) + 20.0 * Math.Sin(2.0 * x * pi)) * 2.0 / 3.0;
    //    ret += (20.0 * Math.Sin(y * pi) + 40.0 * Math.Sin(y / 3.0 * pi)) * 2.0 / 3.0;
    //    ret += (160.0 * Math.Sin(y / 12.0 * pi) + 320 * Math.Sin(y * pi / 30.0)) * 2.0 / 3.0;
    //    return ret;
    //}

    //private double transformLon(double x, double y)
    //{
    //    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * Math.Sqrt(Math.Abs(x));
    //    ret += (20.0 * Math.Sin(6.0 * x * pi) + 20.0 * Math.Sin(2.0 * x * pi)) * 2.0 / 3.0;
    //    ret += (20.0 * Math.Sin(x * pi) + 40.0 * Math.Sin(x / 3.0 * pi)) * 2.0 / 3.0;
    //    ret += (150.0 * Math.Sin(x / 12.0 * pi) + 300.0 * Math.Sin(x / 30.0 * pi)) * 2.0 / 3.0;
    //    return ret;
    //} 
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width,height=device-height, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=yes"/>
<title>利郎门店位置</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
<style type="text/css">
*{
    margin:0px;
    padding:0px;
}
body, button, input, select, textarea {
    font: 12px/16px Verdana, Helvetica, Arial, sans-serif;
}

.btn 
{
     position:absolute; float:left; z-index:99999 ; left:0.5em; top:1em; height:2em; width:7em; text-align:center; vertical-align:middle; line-height:2em;z-index:99; font-size:1.3em; 
	        border:1px solid #c0c0c0;border-radius:0.5em; background-color:#fcfcfc; color:#303030; box-shadow:0.2em 0.2em 0.3em #aaaaaa;display:none
}

/*提示层样式*/
.mymask {
    color: #fff;
    position: absolute;
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
</style>
<script type="text/javascript" charset="utf-8" src="../../res/js/EasyBusiness/map.js"></script>
<script type="text/javascript" src="../../res/js/jweixin-1.0.0.js"></script>
<script type="text/javascript" src="../../res/js/jquery.js"></script> 
<script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
</head>
<body onload="init()" style="width:100%;">
    <form id="form1" runat="server" style="width:100%;">
	    <span id="openmap" class="btn" onclick="OpenMap(<%= LilanzLat %>,<%= LilanzLng %>,'<%= StoreName %>','<%= StoreAddress %>','http://tm.lilanz.com');" >
                <img src="../../res/img/EasyBusiness/daohang.png" style=" width:1em" alt="" />&nbsp;位置导航
        </span>         
       <div style="position:relative; width:100%; z-index:20" id="container"></div>  
              
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
    </form>
</body>
<script type="text/javascript">
    var divcontainer = document.getElementById("container"); 
    divcontainer.style.height = String(parseInt(document.documentElement.clientHeight)) + "px"; 

    var center = new qq.maps.LatLng(<%= LilanzLat %>, <%= LilanzLng %>);
    var icon, marker;
    //寻找路径的代码：开始

    var map;
    //寻找路径的代码结束

    var init = function () {
        map = new qq.maps.Map(document.getElementById('container'), {
            center: center,
            zoom: 14, 
            zoomControl: false,
            mapTypeControl:false
        });

        var anchor = new qq.maps.Point(12, 12),
        size = new qq.maps.Size(24, 24),
        origin = new qq.maps.Point(0, 0);
        icon = new qq.maps.MarkerImage('../../res/img/EasyBusiness/hot.gif', size, origin, anchor);
        marker = new qq.maps.Marker({
            icon: icon,
            map: map,
            position: map.getCenter()
        });
        qq.maps.event.addListener(marker, "click", function () {
            showLoader("warn","这里是<%= StoreName %>的位置！");
        }); 

        
        FastClick.attach(document.body);
    } 
	
    //以下是微信开发的JS
	wx.config({
		debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
		appId: '<%= wxConfig[0] %>', // 必填，公众号的唯一标识
		timestamp: '<%= wxConfig[1] %>' , // 必填，生成签名的时间戳
		nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
		signature: '<%= wxConfig[3] %>',// 必填，签名，见附录1
		jsApiList: [  
		'onMenuShareTimeline',
        'onMenuShareAppMessage',
		'hideMenuItems', 
		'openLocation' 
		] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
	});

    wx.ready(function(){  
    // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。
        $(".btn").css("display", "block");  
        
        wx.hideMenuItems({
            menuList: ['menuItem:openWithSafari','menuItem:openWithQQBrowser','menuItem:share:qq','menuItem:copyUrl','menuItem:favorite'] // 要隐藏的菜单项，所有menu项见附录3
        });
         
        wx.onMenuShareTimeline({
            title: '我在<%= StoreName %>掏货呢！这里的商品真是物美价廉！不要感谢我，叫我雷锋~', // 分享标题
            link: '<%= Request.Url.AbsoluteUri %>', // 分享链接
            imgUrl: '<%= SharedLogo %>', // 分享图标
            success: function () {
                // 用户确认分享后执行的回调函数
                showLoader("successed","感谢您的分享！");
            },
            cancel: function () {
                // 用户取消分享后执行的回调函数
            }
        });

        wx.onMenuShareAppMessage({
            title: '<%= StoreName %>', // 分享标题
            desc: '这里是<%= StoreName %>的位置！型男都知道来这里买衣服，你也过来看看呗！', // 分享描述
            link: '<%= Request.Url.AbsoluteUri %>', // 分享链接
            imgUrl: '<%= SharedLogo %>', // 分享图标
            type: 'link', // 分享类型,music、video或link，不填默认为link
            dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
            success: function () {
                // 用户确认分享后执行的回调函数
                showLoader("successed","感谢您的分享！");
            },
            cancel: function () {
                // 用户取消分享后执行的回调函数
            }
        });

//        wx.getLocation({
//            type: 'gcj02', // 默认为wgs84的gps坐标，如果要返回直接给openLocation用的火星坐标，可传入'gcj02'
//            success: function (res) {
//                var latitude = res.latitude; // 纬度，浮点数，范围为90 ~ -90
//                var longitude = res.longitude; // 经度，浮点数，范围为180 ~ -180。
//                var speed = res.speed; // 速度，以米/每秒计
//                var accuracy = res.accuracy; // 位置精度
//                
//                alert(latitude);
//                alert(longitude);
//                alert(accuracy); 
//            }
//        }); 
    });

    wx.error(function(res){ 
    // config信息验证失败会执行error函数，如签名过期导致验证失败，具体错误信息可以打开config的debug模式查看，也可以在返回的res参数中查看，对于SPA可以在这里更新签名。

    });
     
	//打开地图以便导航
	function OpenMap(xLat, xLng, AdrrName, Address, InfoUrl) {  
//		alert(xLat + "|" + xLng + "|" + AdrrName + "|" + Address + "|" + InfoUrl);
		wx.openLocation({
			latitude: xLat, // 纬度，浮点数，范围为90 ~ -90
			longitude: xLng, // 经度，浮点数，范围为180 ~ -180。
			name: AdrrName, // 位置名
			address: Address, // 地址详情说明
			scale: 20, // 地图缩放级别,整形值,范围从1~28。默认为最大
			infoUrl: InfoUrl // 在查看位置界面底部显示的"更多信息"超链接,可点击跳转
		});

		event.stopPropagation();
	}
	
    
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
                    }, 2000);
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
                    }, 2000);
                    break;
            }
        }
</script>
</html>
