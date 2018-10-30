<%@ Page Language="C#" %> 
<%@ Import Namespace="WebBLL.Core" %>  
<%@ Import Namespace = "nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace = "System" %>
<%@ Import Namespace = "System.Web" %>
<%@ Import Namespace = "System.Web.UI" %>
<%@ Import Namespace = "System.Web.UI.WebControls" %>
<%@ Import Namespace = "Newtonsoft.Json" %>
<%@ Import Namespace = "Newtonsoft.Json.Linq" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Text" %>
<%@ Import Namespace = "System.IO" %>
<%@ Import Namespace = "System.Text.RegularExpressions" %>
<%@ Import Namespace = "System.Net" %>
<%@ Import Namespace = "System.Collections.Generic" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    public double Lat = 0.0;//当前地理位置
    public double Lng = 0.0;
    public double zmdLat = 0.0;  //专卖店的地理位置
    public double zmdLng = 0.0;
    public String zmdmc = "";
    public String addressInfo = "";
    private const string ConfigKeyValue = "5";	//微信配置信息索引值 
    //public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    public string[] wxConfig;       //微信OPEN_JS 动态生成的调用参数
    private const string appID = "wx821a4ec0781c00ca";	//APPID
    private const string appSecret = "a68357539ec388f322787d6d518d6daf";	//appSecret	

    protected void Page_Load(object sender, EventArgs e)
    {
        //double wgLat = 0.0,wgLng = 0.0;//,mgLat = 0.0,mgLon = 0.0;

        //wgLat = Convert.ToDouble(Context.Request["Lat"]);
        //wgLng = Convert.ToDouble(Context.Request["Lng"]);
        int mapid = 0;
        string errInfo = "";
        string cid = "1";
        DAL.SqlDbHelper dbHelper = new DAL.SqlDbHelper(cid);
        Lat = Convert.ToDouble(Context.Request["Lat"]);
        Lng = Convert.ToDouble(Context.Request["Lng"]);
        mapid = Convert.ToInt16(Context.Request["mapid"]);
        zmdLat = Convert.ToDouble(Context.Request["zmdLat"]);
        zmdLng = Convert.ToDouble(Context.Request["zmdLng"]);

        string sqlcomm = string.Format(@"select distinct top 1 a.addressInfo,b.zmdmc from wx_t_storepointlocation a 
                         inner join yx_t_jmspb b on a.mapid=b.id 
                         iNNER JOIN yx_T_khb as c on b.khid=c.khid and c.ty=0                                 
                        where a.mapid =  '{0}' and a.maptype='jm' ",mapid);

        using (IDataReader reader = dbHelper.ExecuteReader(sqlcomm))
        {
            if (reader.Read())
            {
                zmdmc = Convert.ToString(reader[1]);
                addressInfo = Convert.ToString(reader[0]);
            }
            else { 
            
            }
        }


        //zmdmc = Convert.ToString(Context.Request["zmdmc"]);
        //addressInfo = Convert.ToString(Context.Request["addressInfo"]);
        //wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
        using (WxHelper wh = new WxHelper())
        {
            wxConfig = wh.GetWXJsApiConfig(appID, appSecret);
        }
  
                
    }


   
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width,height=device-height, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=yes"/>
<title>位置</title>
<style type="text/css">
*{
    margin:0px;
    padding:0px;
}
body, button, input, select, textarea {
    font: 12px/16px Verdana, Helvetica, Arial, sans-serif;
}
</style>
<%--<script type="text/javascript" charset="utf-8" src="map.js"></script>--%>
<script type="text/javascript" src="js/jweixin-1.0.0.js"></script>
<script type="text/javascript" src="js/jquery.js"></script>
<script charset="utf-8" src="http://map.qq.com/api/js?v=2.exp"></script>
<script>
    //24.811570&zmdLng=118.585975
    var center = new qq.maps.LatLng(<%= zmdLat %>, <%= zmdLng %>);
    //var center = new qq.maps.LatLng(39.910344,116.394095);
    // var zmdmc=<%= zmdmc %>;
    var icon, marker;
    //寻找路径的代码：开始
    var map, transfer_plans, start_marker, end_marker, station_markers = [],
            transfer_lines = [],
            walk_lines = [];

    var transferService = new qq.maps.TransferService({
        location: "北京",
        complete: function (result) {
            result = result.detail;
            var start = result.start,
                    end = result.end;
            var anchor = new qq.maps.Point(6, 6),
                    size = new qq.maps.Size(24, 36),
                    start_icon = new qq.maps.MarkerImage('mapsrc/me.png', size),
                    end_icon = new qq.maps.MarkerImage('mapsrc/hot.gif', size, new qq.maps.Point(24, 0), anchor);

            start_marker && start_marker.setMap(null);
            end_marker && end_marker.setMap(null);
            start_marker = new qq.maps.Marker({
                icon: start_icon,
                position: start.latLng,
                map: map,
                zIndex: 1
            });
            end_marker = new qq.maps.Marker({
                icon: end_icon,
                position: end.latLng,
                map: map,
                zIndex: 1
            });

            transfer_plans = result.plans;
            var plans_desc = [];
            for (var i = 0; i < transfer_plans.length; i++) {
                //plan desc.  
                var p_attributes = ['onclick="renderPlan(' + i + ')"', 'onmouseover=this.style.background="#eee"', 'onmouseout=this.style.background="#fff"', 'style="margin-top:-4px;cursor:pointer"'].join(' ');
                plans_desc.push('<p ' + p_attributes + '><b>方案' + (i + 1) + '.</b>');
                var actions = transfer_plans[i].actions;
                for (var j = 0; j < actions.length; j++) {
                    var action = actions[j],
                  img_position;
                    action.type == qq.maps.TransferActionType.BUS && (img_position = '-38px 0px');
                    action.type == qq.maps.TransferActionType.SUBWAY && (img_position = '-57px 0px');
                    action.type == qq.maps.TransferActionType.WALK && (img_position = '-76px 0px');

                    var action_img = '<span style="margin-bottom: -4px;' + 'display:inline-block;background:url(img/busicon.png) ' + 'no-repeat ' + img_position + ';width:19px;height:19px"></span>&nbsp;&nbsp;';
                    plans_desc.push(action_img + action.instructions);
                }
            }
            //方案文本描述
            document.getElementById('plans').innerHTML = plans_desc.join('<br><br>');

            //渲染到地图上
            renderPlan(0);
        }
    });

    function calcPlan() {
        route_steps = [];
        //zmdLat=24.811570&zmdLng=118.585975&lat=24.79771700&lng=118.57314100&mapid=622
        //var mylocation = new qq.maps.LatLng(24.79771700, 118.57314100);       //在这里输入当前的地理位置
        var mylocation = new qq.maps.LatLng(<%= Lat %>, <%= Lng %>);

        transferService.search(mylocation, center);
        transferService.setPolicy(qq.maps.TransferActionType.LEAST_TIME);

        //directionsService.search(new qq.maps.LatLng(<%= Lat %>, <%= Lng %>), new qq.maps.LatLng(<%= zmdLat %>, <%= zmdLng %>));              
    }

    //清除地图上的marker
    function clearOverlay(overlays) {
        var overlay;
        while (overlay = overlays.pop()) {
            overlay.setMap(null);
        }
    }

    function renderPlan(index) {
        var plan = transfer_plans[index],
                lines = plan.lines,
                walks = plan.walks,
                stations = plan.stations;
        map.fitBounds(plan.bounds);

        //clear overlays;
        clearOverlay(station_markers);
        clearOverlay(transfer_lines);
        clearOverlay(walk_lines);
        var anchor = new qq.maps.Point(6, 6),
                size = new qq.maps.Size(24, 36),
                bus_icon = new qq.maps.MarkerImage('img/busmarker.png', size, new qq.maps.Point(48, 0), anchor),
                subway_icon = new qq.maps.MarkerImage('img/busmarker.png', size, new qq.maps.Point(72, 0), anchor);
        //draw station marker
        for (var j = 0; j < stations.length; j++) {
            var station = stations[j];
            if (station.type == qq.maps.PoiType.SUBWAY_STATION) {
                var station_icon = subway_icon;
            } else {
                var station_icon = bus_icon;
            }
            var station_marker = new qq.maps.Marker({
                icon: station_icon,
                position: station.latLng,
                map: map,
                zIndex: 0
            });
            station_markers.push(station_marker);
        }

        //draw bus line
        for (var j = 0; j < lines.length; j++) {
            var line = lines[j];
            var polyline = new qq.maps.Polyline({
                path: line.path,
                strokeColor: '#3893F9',
                strokeWeight: 6,
                map: map
            });
            transfer_lines.push(polyline);
        }

        //draw walk line
        for (var j = 0; j < walks.length; j++) {
            var walk = walks[j];
            var polyline = new qq.maps.Polyline({
                path: walk.path,
                strokeColor: '#3FD2A3',
                strokeWeight: 6,
                map: map
            });
            walk_lines.push(polyline);
        }
        for (var j = 0; j < walks.length; j++) {
            var step = route_steps[index];
            var polyline = new qq.maps.Polyline({
                path: step.path,
                strokeColor: '#5FD2A3',
                strokeWeight: 6,
                map: map
            });
            walk_lines.push(polyline);
        }
    }
    //寻找路径的代码结束

    var init = function () {
        map = new qq.maps.Map(document.getElementById('container'), {
            center: center,
            zoom: 11,
            zoomControl: false,
            mapTypeControl: false
        });
        var anchor = new qq.maps.Point(12, 12),
        size = new qq.maps.Size(24, 24),
        origin = new qq.maps.Point(0, 0);
        icon = new qq.maps.MarkerImage('hot.gif', size, origin, anchor);
        marker = new qq.maps.Marker({
            icon: icon,
            map: map,
            position: map.getCenter()
        });

        calcPlan(); //寻找路径
    }



    //以下是微信开发的JS
    wx.config({
        debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
        appId: '<%= wxConfig[0] %>', // 必填，公众号的唯一标识
        timestamp: '<%= wxConfig[1] %>', // 必填，生成签名的时间戳
        nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
        signature: '<%= wxConfig[3] %>', // 必填，签名，见附录1
        jsApiList: [
		'onMenuShareTimeline', //分享到朋友圈
        'onMenuShareAppMessage', //分享给朋友
		'hideOptionMenu', //隐藏右上角菜单接口
		'showOptionMenu', //显示右上角菜单接口
		'openLocation',   //使用微信内置地图查看位置接口
        'getLocation'    //使用微信内置地图查看当前位置接口
		] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
    });


    wx.ready(function () {
        // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。

        $("#openmap").css("display", "block");

    });

    wx.error(function (res) {

        // config信息验证失败会执行error函数，如签名过期导致验证失败，具体错误信息可以打开config的debug模式查看，也可以在返回的res参数中查看，对于SPA可以在这里更新签名。

    });


    //打开地图以便导航
    function OpenMap(xLat, xLng, AdrrName, Address, InfoUrl) {
        //alert(xLat + "|" + xLng + "|" + AdrrName + "|" + Address + "|" + InfoUrl);
        wx.openLocation({
            latitude: xLat, // 纬度，浮点数，范围为90 ~ -90
            longitude: xLng, // 经度，浮点数，范围为180 ~ -180。
            name: AdrrName, // 位置名
            address: Address, // 地址详情说明
            scale: 18, // 地图缩放级别,整形值,范围从1~28。默认为最大
            infoUrl: InfoUrl // 在查看位置界面底部显示的"更多信息"超链接,可点击跳转
        });

        event.stopPropagation();
    }

    //<%= zmdmc %><%="addressInfo" %>
</script>

</head>
<body onload="init()" style="width:100%;">
    <input id="zmdmc" type="hidden" value=<%=zmdmc %>>
    <form id="form1" runat="server" style="width:100%;">
	    <span id="openmap" style="position:fixed; left:0.5em; top:1em; height:2em; width:7em; text-align:center; vertical-align:middle; line-height:2em;z-index:99; font-size:1.3em; 
	        border:1px solid #c0c0c0;border-radius:0.5em; background-color:#fcfcfc; color:#303030; box-shadow:0.2em 0.2em 0.3em #aaaaaa;   display:none" 
            onclick="OpenMap(<%= zmdLat %>,<%= zmdLng %>,'<%= zmdmc %>位置','<%="addressInfo" %>','');" >
            <img src="mapsrc/daohang.png" style=" width:1em" alt="" />&nbsp;去专卖店
        </span>        


        <div style="position:relative; width:100%; z-index:20" id="container">
        </div>
        <div style="position:relative; width:100%; z-index:20" id="plans">
        </div>
    </form>
</body>
<script type="text/javascript">
    var divcontainer = document.getElementById("container");
    var divroutes = document.getElementById("plans");
    divcontainer.style.height = String(parseInt(document.documentElement.clientHeight * 0.5)) + "px";
    divroutes.style.height = divcontainer.style.height;
</script>
</html>
