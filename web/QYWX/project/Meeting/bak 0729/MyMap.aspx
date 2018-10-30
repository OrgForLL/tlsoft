<%@ Page Language="C#" %>
<%@ Import Namespace="WebBLL.Core" %>  

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    public string Lat;
    public string Lng;
    public double LilanzLat = 0.0;  //利郎公司的地理位置
    public double LilanzLng = 0.0;

    private const string appID = "wxe46359cef7410a06";	//APPID
    private const string appSecret = "wCwNUgMb4LDbaH0m0XZJV7Hb9hma2FGOX4MDtSqd3SggbUem4tV4QV2M15762qoK";	//appSecret	
    public string[] wxConfig;       //微信OPEN_JS 动态生成的调用参数
    protected void Page_Load(object sender, EventArgs e)
    {
        double wgLat = 0.0, wgLng = 0.0;//,mgLat = 0.0,mgLon = 0.0;

        wgLat = Convert.ToDouble(Request.Params["Lat"]);
        wgLng = Convert.ToDouble(Request.Params["Lng"]);

        Lat = Convert.ToString(wgLat);
        Lng = Convert.ToString(wgLng);

        LilanzLat = 24.79580;
        LilanzLng = 118.57105;


        ////解码
        // transform(wgLat, wgLng, out mgLat, out mgLon);        //后经过测试，发现无须解码        

        //获取微信JS_API config相关配置
        using (WxHelper wh = new WxHelper())
        {
            wxConfig = wh.GetWXQYJsApiConfig(appID, appSecret);
        }

    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>您准备去哪儿？</title>
    <meta charset="UTF-8">
<meta name="viewport" content="width=device-width,height=device-height, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0"/>
    <link rel="stylesheet" href="/css/weui.css"/> 
    <script type="text/javascript" src="/js/jquery.js"></script> 
    <script type="text/javascript" charset="utf-8" src="/js/Meeting/map.js"></script>
    <script type="text/javascript" src="/js/jweixin-1.0.0.js"></script>
<style>
    
.page_title {
  text-align: center;
  font-size: 34px;
  color: #3CC51F;
  font-weight: 400;
  margin: 0 15%;
}

.page_desc {
  text-align: center;
  color: #888;
  font-size: 14px;
}
</style>

</head>
<body ontouchstart >
    <form id="form1" runat="server">
    <div class="container js_container">
        <div class="page">
            <div class="hd">
                <h1 class="page_title">地图导航</h1>
                <p class="page_desc">再也不用担心迷路</p>
            </div>
            <div class="bd">  
                <div class="weui_cells_title">总部位置</div>
                <div class="weui_cells weui_cells_access"> 
                    <a class="weui_cell" href="javascript:;" data-id="map">
                        <div class="weui_cell_hd"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAC4AAAAuCAMAAABgZ9sFAAAAVFBMVEXx8fHMzMzr6+vn5+fv7+/t7e3d3d2+vr7W1tbHx8eysrKdnZ3p6enk5OTR0dG7u7u3t7ejo6PY2Njh4eHf39/T09PExMSvr6+goKCqqqqnp6e4uLgcLY/OAAAAnklEQVRIx+3RSRLDIAxE0QYhAbGZPNu5/z0zrXHiqiz5W72FqhqtVuuXAl3iOV7iPV/iSsAqZa9BS7YOmMXnNNX4TWGxRMn3R6SxRNgy0bzXOW8EBO8SAClsPdB3psqlvG+Lw7ONXg/pTld52BjgSSkA3PV2OOemjIDcZQWgVvONw60q7sIpR38EnHPSMDQ4MjDjLPozhAkGrVbr/z0ANjAF4AcbXmYAAAAASUVORK5CYII=" alt="" style="width:20px;margin-right:5px;display:block"></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>订货宣导会</p>
                        </div>
                        <div class="weui_cell_ft">
                            查看地图
                        </div>
                    </a>
                    <a class="weui_cell" href="javascript:;">
                        <div class="weui_cell_hd"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAC4AAAAuCAMAAABgZ9sFAAAAVFBMVEXx8fHMzMzr6+vn5+fv7+/t7e3d3d2+vr7W1tbHx8eysrKdnZ3p6enk5OTR0dG7u7u3t7ejo6PY2Njh4eHf39/T09PExMSvr6+goKCqqqqnp6e4uLgcLY/OAAAAnklEQVRIx+3RSRLDIAxE0QYhAbGZPNu5/z0zrXHiqiz5W72FqhqtVuuXAl3iOV7iPV/iSsAqZa9BS7YOmMXnNNX4TWGxRMn3R6SxRNgy0bzXOW8EBO8SAClsPdB3psqlvG+Lw7ONXg/pTld52BjgSSkA3PV2OOemjIDcZQWgVvONw60q7sIpR38EnHPSMDQ4MjDjLPozhAkGrVbr/z0ANjAF4AcbXmYAAAAASUVORK5CYII=" alt="" style="width:20px;margin-right:5px;display:block"></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>订货大厅</p>
                        </div>
                        <div class="weui_cell_ft">
                            查看地图
                        </div>
                    </a>
                </div> 

                <div class="weui_cells_title">酒店位置</div>
                <div class="weui_cells weui_cells_access"> 
                    <a class="weui_cell" href="javascript:;">
                        <div class="weui_cell_hd"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAC4AAAAuCAMAAABgZ9sFAAAAVFBMVEXx8fHMzMzr6+vn5+fv7+/t7e3d3d2+vr7W1tbHx8eysrKdnZ3p6enk5OTR0dG7u7u3t7ejo6PY2Njh4eHf39/T09PExMSvr6+goKCqqqqnp6e4uLgcLY/OAAAAnklEQVRIx+3RSRLDIAxE0QYhAbGZPNu5/z0zrXHiqiz5W72FqhqtVuuXAl3iOV7iPV/iSsAqZa9BS7YOmMXnNNX4TWGxRMn3R6SxRNgy0bzXOW8EBO8SAClsPdB3psqlvG+Lw7ONXg/pTld52BjgSSkA3PV2OOemjIDcZQWgVvONw60q7sIpR38EnHPSMDQ4MjDjLPozhAkGrVbr/z0ANjAF4AcbXmYAAAAASUVORK5CYII=" alt="" style="width:20px;margin-right:5px;display:block"></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>万达酒店</p>
                        </div>
                        <div class="weui_cell_ft">
                            查看地图
                        </div>
                    </a>
                    <a class="weui_cell" href="javascript:;">
                        <div class="weui_cell_hd"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAC4AAAAuCAMAAABgZ9sFAAAAVFBMVEXx8fHMzMzr6+vn5+fv7+/t7e3d3d2+vr7W1tbHx8eysrKdnZ3p6enk5OTR0dG7u7u3t7ejo6PY2Njh4eHf39/T09PExMSvr6+goKCqqqqnp6e4uLgcLY/OAAAAnklEQVRIx+3RSRLDIAxE0QYhAbGZPNu5/z0zrXHiqiz5W72FqhqtVuuXAl3iOV7iPV/iSsAqZa9BS7YOmMXnNNX4TWGxRMn3R6SxRNgy0bzXOW8EBO8SAClsPdB3psqlvG+Lw7ONXg/pTld52BjgSSkA3PV2OOemjIDcZQWgVvONw60q7sIpR38EnHPSMDQ4MjDjLPozhAkGrVbr/z0ANjAF4AcbXmYAAAAASUVORK5CYII=" alt="" style="width:20px;margin-right:5px;display:block"></div>
                        <div class="weui_cell_bd weui_cell_primary">
                            <p>金马酒店</p>
                        </div>
                        <div class="weui_cell_ft">
                            查看地图
                        </div>
                    </a>
                </div> 
            </div>
        </div>
    </div>
    </form>

    <script type="text/html" id="tpl_map">
        <div class="page">
            <div style=" position:relative; width:100%; z-index:20" id="container"></div> 
            <div style=" position:relative; width:100%; z-index:20" id="routes"></div>
        </div>
    </script>

    <script>
    


    var center;
    var icon, marker;
    //寻找路径的代码：开始

    var map,
        directionsService = new qq.maps.DrivingService({
            complete: function (response) {
                var start = response.detail.start,
                    end = response.detail.end;

                var anchor = new qq.maps.Point(12, 36),
                    size = new qq.maps.Size(24, 36),
                    start_icon = new qq.maps.MarkerImage(
                        'mapsrc/me.png',
                        size,
                        new qq.maps.Point(0, 0),
                        anchor
                    );
                //                start_marker && start_marker.setMap(null);
                //                marker && marker.setMap(null);
                //clearOverlay(route_lines);

                start_marker = new qq.maps.Marker({
                    icon: start_icon,
                    position: start.latLng,
                    map: map,
                    zIndex: 1
                });
                directions_routes = response.detail.routes;
                var routes_desc = [];
                //所有可选路线方案
                for (var i = 0; i < directions_routes.length; i++) {
                    var route = directions_routes[i],
                        legs = route;
                    //调整地图窗口显示所有路线    
                    map.fitBounds(response.detail.bounds);
                    //所有路程信息            
                    //for(var j = 0 ; j < legs.length; j++){
                    var steps = legs.steps;
                    route_steps = steps;
                    polyline = new qq.maps.Polyline(
                            {
                                path: route.path,
                                strokeColor: '#3893F9',
                                strokeWeight: 6,
                                map: map
                            }
                        )
                    route_lines.push(polyline);
                    //所有路段信息
                    for (var k = 0; k < steps.length; k++) {
                        var step = steps[k];
                        //路段途经地标
                        directions_placemarks.push(step.placemarks);
                        //转向
                        var turning = step.turning,
                                img_position; ;
                        switch (turning.text) {
                            case '左转':
                                img_position = '0px 0px'
                                break;
                            case '右转':
                                img_position = '-19px 0px'
                                break;
                            case '直行':
                                img_position = '-38px 0px'
                                break;
                            case '偏左转':
                            case '靠左':
                                img_position = '-57px 0px'
                                break;
                            case '偏右转':
                            case '靠右':
                                img_position = '-76px 0px'
                                break;
                            case '左转调头':
                                img_position = '-95px 0px'
                                break;
                            default:
                                mg_position = ''
                                break;
                        }
                        var turning_img = '&nbsp;&nbsp;<span' +
                                ' style="margin-bottom: -4px;' +
                                'display:inline-block;background:' +
                                'url(mapsrc/turning.png) no-repeat ' +
                                img_position + ';width:19px;height:' +
                                '19px"></span>&nbsp;';
                        var p_attributes = [
                                'onclick="renderStep(' + k + ')"',
                                'onmouseover=this.style.background="#eee"',
                                'onmouseout=this.style.background="#fff"',
                                'style="margin:5px 0px;cursor:pointer"'
                            ].join(' ');
                        routes_desc.push('<p ' + p_attributes + ' ><b>' + (k + 1) +
                            '.</b>' + turning_img + step.instructions);
                    }
                    //}
                }
                //方案文本描述
                var routes = document.getElementById('routes');
                routes.innerHTML = routes_desc.join('<br>');

                map.zoomTo(15);
            }
        }),
        directions_routes,
        directions_placemarks = [],
        directions_labels = [],
        start_marker,
        marker,
        route_lines = [],
        step_line,
        route_steps = [];

    function calcRoute() {
        route_steps = [];

        var mylocation = new qq.maps.LatLng(<%= Lat %>, <%= Lng %>);       //在这里输入当前的地理位置

        //directionsService.setLocation("北京");          //设置地图位置

        //提供5种寻径策略
        //          LEAST_TIME：最少时间
        //          LEAST_DISTANCE：最短距离
        //          AVOID_HIGHWAYS：避开高速
        //          REAL_TRAFFIC：实时路况
        //          PREDICT_TRAFFIC：预测路况
        directionsService.setPolicy(qq.maps.DrivingPolicy["LEAST_TIME"]);
        directionsService.search(mylocation, center);
    }
    function renderStep(index) {
        var step = route_steps[index];
        //clear overlays;
        step_line && step_line.setMap(null);
        //draw setp line      
        step_line = new qq.maps.Polyline(
            {
                path: step.path,
                strokeColor: '#ff0000',
                strokeWeight: 6,
                map: map
            }
        )
    }

    //寻找路径的代码结束

    var init = function () {
        center = new qq.maps.LatLng(<%= LilanzLat %>, <%= LilanzLng %>);

        map = new qq.maps.Map(document.getElementById('container'), {
            center: center,
            zoom: 11, 
            zoomControl: false,
            mapTypeControl:false
        });

        var anchor = new qq.maps.Point(12, 12),
        size = new qq.maps.Size(24, 24),
        origin = new qq.maps.Point(0, 0);
        icon = new qq.maps.MarkerImage('mapsrc/hot.gif', size, origin, anchor);
        marker = new qq.maps.Marker({
            icon: icon,
            map: map,
            position: map.getCenter()
        });
        qq.maps.event.addListener(marker, "click", function () {
            sAlert("利郎温馨提示：", "这里是利郎岁末福利会的会场地址！");
        });

        //停车场的位置
         var center2 = new qq.maps.LatLng(24.797410,118.571877);
         var anchor2 = new qq.maps.Point(8, 22);
         var size2 = new qq.maps.Size(60, 22);
         var icon2 = new qq.maps.MarkerImage('mapsrc/carstop.png', size2, origin, anchor2);
         var marker2 = new qq.maps.Marker({
             icon: icon2,
             position: center2,
             map: map
         });
         qq.maps.event.addListener(marker2, "click", function () {
            sAlert("利郎温馨提示：", "这里是利郎福利会专用的停车场位置！");
//            OpenMap(24.797410, 118.571877,'利郎公司停车场','利郎公司福利会专用停车场','http://tm.lilanz.com/2015flh/flhstart.aspx');            
         });


        calcRoute(); //寻找路径
    }

    //自定义弹窗功能
    function sAlert(strTitle, strContent) {
        var msgw, msgh, bordercolor;
        msgw = 300; //Width
        msgh = 100; //Height 
        titleheight = 25 //title Height
        bordercolor = "#336699"; //boder color
        titlecolor = "#99CCFF"; //title color

        var sWidth, sHeight;
        sWidth = document.body.offsetWidth;
        sHeight = screen.height;
        var bgObj = document.createElement("div");
        bgObj.setAttribute('id', 'bgDiv');
        bgObj.style.position = "absolute";
        bgObj.style.top = "0";
        bgObj.style.background = "#777";
        bgObj.style.filter = "progid:DXImageTransform.Microsoft.Alpha(style=3,opacity=25,finishOpacity=75";
        bgObj.style.opacity = "0.6";
        bgObj.style.left = "0";
        bgObj.style.width = sWidth + "px";
        bgObj.style.height = sHeight + "px";
        bgObj.style.zIndex = "10000";
        document.body.appendChild(bgObj);

        var msgObj = document.createElement("div")
        msgObj.setAttribute("id", "msgDiv");
        msgObj.setAttribute("align", "center");
        msgObj.style.background = "white";
        msgObj.style.border = "1px solid " + bordercolor;
        msgObj.style.position = "fixed";
        msgObj.style.left = "50%";
        msgObj.style.top = "50%";
        msgObj.style.font = "12px/1.6em Verdana, Geneva, Arial, Helvetica, sans-serif";
        msgObj.style.marginLeft = "-150px";
        msgObj.style.marginTop = -75 + document.documentElement.scrollTop + "px";
        msgObj.style.width = msgw + "px";
        msgObj.style.height = msgh + "px";
        msgObj.style.textAlign = "center";
        msgObj.style.lineHeight = "25px";
        msgObj.style.zIndex = "10001";

        var title = document.createElement("h4");
        title.setAttribute("id", "msgTitle");
        title.setAttribute("align", "right");
        title.style.margin = "0";
        title.style.padding = "3px";
        title.style.background = bordercolor;
        title.style.filter = "progid:DXImageTransform.Microsoft.Alpha(startX=20, startY=20, finishX=100, finishY=100,style=1,opacity=75,finishOpacity=100);";
        title.style.opacity = "0.75";
        title.style.border = "1px solid " + bordercolor;
        title.style.height = "18px";
        title.style.font = "12px Verdana, Geneva, Arial, Helvetica, sans-serif";
        title.style.color = "white";
        title.style.cursor = "pointer";
        title.innerHTML = "<table border='0' width='100%'>"
                    + "<tr><td align='left'><b>" + strTitle + "</b></td><td>关闭</td></tr></table></div>";
        title.onclick = function () {
            document.body.removeChild(bgObj);
            document.getElementById("msgDiv").removeChild(title);
            document.body.removeChild(msgObj);
        }
        document.body.appendChild(msgObj);
        document.getElementById("msgDiv").appendChild(title);
        var txt = document.createElement("p");
        txt.style.margin = "1em 0"
        txt.setAttribute("id", "msgTxt");
        txt.innerHTML = strContent;
        document.getElementById("msgDiv").appendChild(txt);
    }
	
	
    //以下是微信开发的JS
	wx.config({
		debug: true, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
		appId: '<%= wxConfig[0] %>', // 必填，公众号的唯一标识
		timestamp: '<%= wxConfig[1] %>' , // 必填，生成签名的时间戳
		nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
		signature: '<%= wxConfig[3] %>',// 必填，签名，见附录1
		jsApiList: [  
		'onMenuShareTimeline',
        'onMenuShareAppMessage',
		'hideOptionMenu',
		'showOptionMenu',
		'openLocation'
		] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
	});

    wx.ready(function(){ 
    // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。
        var btnopenmap = document.getElementById("openmap");
        var btnopenmap2 = document.getElementById("openmap2");
        btnopenmap.style.display = "block"; 
        btnopenmap2.style.display = "block"; 
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
	
    var divcontainer = document.getElementById("container");
    var divroutes = document.getElementById("routes");
    divcontainer.style.height = String(parseInt(document.documentElement.clientHeight * 0.5)) + "px";
    divroutes.style.height = divcontainer.style.height;


    
$(function () {
    // 页面栈
    var stack = [];
    var $container = $('.js_container');
    $container.on('click', '.js_cell[data-id]', function () {
        var id = $(this).data('id');
        var $tpl = $($('#tpl_' + id).html()).addClass('slideIn').addClass(id);
        $container.append($tpl);
        stack.push($tpl);
        history.pushState({id: id}, '', '#' + id);

        $($tpl).on('webkitAnimationEnd', function (){
            $(this).removeClass('slideIn');
        }).on('animationend', function (){
            $(this).removeClass('slideIn');
        });
        // tooltips
        if (id == 'cell') {
            $('.js_tooltips').show();
            setTimeout(function (){
                $('.js_tooltips').hide();
            }, 3000);
        }

    });

    // webkit will fired popstate on page loaded
    $(window).on('popstate', function () {
        var $top = stack.pop();
        if (!$top) {
            return;
        }
        $top.addClass('slideOut').on('animationend', function () {
            $top.remove();
        }).on('webkitAnimationEnd', function () {
            $top.remove();
        });
    });

    // toast
    $container.on('click', '#showToast', function () {
        $('#toast').show();
        setTimeout(function () {
            $('#toast').hide();
        }, 5000);
    });
    $container.on('click', '#showLoadingToast', function () {
        $('#loadingToast').show();
        setTimeout(function () {
            $('#loadingToast').hide();
        }, 5000);
    });

    $container.on('click', '#showDialog1', function () {
        $('#dialog1').show();
        $('#dialog1').find('.weui_btn_dialog').on('click', function () {
            $('#dialog1').hide();
        });
    });
    $container.on('click', '#showDialog2', function () {
        $('#dialog2').show();
        $('#dialog2').find('.weui_btn_dialog').on('click', function () {
            $('#dialog2').hide();
        });
    })
});
</script>
</body>
</html>
