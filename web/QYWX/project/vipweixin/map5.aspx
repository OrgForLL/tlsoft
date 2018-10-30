<%@ Page Language="C#" %> 
<%@ Import Namespace="WebBLL.Core" %>  
<%@ Import Namespace = "nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    public string Lat;//当前地理位置
    public string Lng;
    public double zmdLat = 0.0;  //专卖店的地理位置
    public double zmdLng = 0.0;
    public String zmdmc = "123";
    public String addressInfo = "123";
    private const string ConfigKeyValue = "5";	//微信配置信息索引值 
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
   // public string[] wxConfig;       //微信OPEN_JS 动态生成的调用参数
    //private const string appID = "wxc368c7744f66a3d7";	//APPID
	//private const string appSecret = "74ebc70df1f964680bd3bdd2f15b4bed";	//appSecret	


    protected void Page_Load(object sender, EventArgs e)
    {
        double wgLat = 0.0,wgLng = 0.0;//,mgLat = 0.0,mgLon = 0.0;

        wgLat = Convert.ToDouble(Context.Request["Lat"]);
        wgLng = Convert.ToDouble(Context.Request["Lng"]); 

        Lat = Convert.ToString(wgLat);
        Lng = Convert.ToString(wgLng);

        zmdLat = Convert.ToDouble(Context.Request["zmdLat"]);
        zmdLng = Convert.ToDouble(Context.Request["zmdLng"]);
       // zmdmc  = Convert.ToString(Context.Request["zmdmc"]);
        //addressInfo = Convert.ToString(Context.Request["addressInfo"]);
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);

       // using (WxHelper wh = new WxHelper())
       // {
       //     wxConfig = wh.GetWXJsApiConfig(appID, appSecret);
       // }
       //// Response.Write(wxConfig[0]);
       // //Response.End();
       // //return;       
    }


   
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<input id="zmdmc" type="hidden" value=<%=zmdmc %>>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width,height=device-height, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=yes"/>
<title><%= zmdmc %>位置</title>
<style type="text/css">
*{
    margin:0px;
    padding:0px;
}
body, button, input, select, textarea {
    font: 12px/16px Verdana, Helvetica, Arial, sans-serif;
}
</style>
<script type="text/javascript" charset="utf-8" src="mapsrc/map.js"></script>
<script type="text/javascript" src="js/jweixin-1.0.0.js"></script>
<script type="text/javascript" src="js/jquery.js"></script>
<script>

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
                    start_icon = new qq.maps.MarkerImage('me.png', size),
                    end_icon = new qq.maps.MarkerImage('me.png', size, new qq.maps.Point(24, 0), anchor);

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

    function init() {
        map = new qq.maps.Map(document.getElementById("container"), {
            // 地图的中心地理坐标。
            center: new qq.maps.LatLng(39.916527, 116.397128)
        });
        calcPlan();
    }
    //调用calcPlan用来判断出行方式
    function calcPlan() {
        var start_name = document.getElementById("start").value.split(",");
        var end_name = document.getElementById("end").value.split(",");
        var policy = document.getElementById("policy").value;

        transferService.search(new qq.maps.LatLng(start_name[1], start_name[0]), new qq.maps.LatLng(end_name[1], end_name[0]));

        switch (policy) {
            case "较快捷":
                transferService.setPolicy(qq.maps.TransferActionType.LEAST_TIME);
                break;
            case "少换乘":
                transferService.setPolicy(qq.maps.TransferActionType.LEAST_TRANSFER);
                break;
            case "少步行":
                transferService.setPolicy(qq.maps.TransferActionType.LEAST_WALKING);
                console.log(1);
                break;
            case "不坐地铁":
                transferService.setPolicy(qq.maps.TransferActionType.NO_SUBWAY);
                break;
        }
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
                bus_icon = new qq.maps.MarkerImage('me.png', size, new qq.maps.Point(48, 0), anchor),
                subway_icon = new qq.maps.MarkerImage('me.png', size, new qq.maps.Point(72, 0), anchor);
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
    }
    //以下是微信开发的JS
//    wx.config({
//        debug: true, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
//        appId: '<%= wxConfig[0] %>', // 必填，公众号的唯一标识
//        timestamp: '<%= wxConfig[1] %>', // 必填，生成签名的时间戳
//        nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
//        signature: '<%= wxConfig[3] %>', // 必填，签名，见附录1
//        jsApiList: [
//		'onMenuShareTimeline', //分享到朋友圈
//        'onMenuShareAppMessage', //分享给朋友
//		'hideOptionMenu', //隐藏右上角菜单接口
//		'showOptionMenu', //显示右上角菜单接口
//		'openLocation',   //使用微信内置地图查看位置接口
//        'getLocation'    //使用微信内置地图查看当前位置接口
//		] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
//    });

//   
//    wx.ready(function () {
//        // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。
//        //var btnopenmap = document.getElementById("openmap");

//       // btnopenmap.style.display = "block";

//    });

//    wx.error(function (res) {

//        // config信息验证失败会执行error函数，如签名过期导致验证失败，具体错误信息可以打开config的debug模式查看，也可以在返回的res参数中查看，对于SPA可以在这里更新签名。

//    });


//    //打开地图以便导航
//    function OpenMap(xLat, xLng, AdrrName, Address, InfoUrl) {

//////alert(xLat + "|" + xLng + "|" + AdrrName + "|" + Address + "|" + InfoUrl);
////        wx.openLocation({
////            latitude: xLat, // 纬度，浮点数，范围为90 ~ -90
////            longitude: xLng, // 经度，浮点数，范围为180 ~ -180。
////            name: AdrrName, // 位置名
////            address: Address, // 地址详情说明
////            scale: 15, // 地图缩放级别,整形值,范围从1~28。默认为最大
////            infoUrl: InfoUrl // 在查看位置界面底部显示的"更多信息"超链接,可点击跳转
////        });

////        event.stopPropagation();
//    }
//   
	
</script>

</head>
    <body onload="init();">
        <div style='margin:5px 0px'>
            <b>
                起点:
            </b>
            <select id="start" onchange="calcPlan();">
                <option value="24.811570,118.585975">
                    24.811570,118.585975
                </option>
            </select>
            <b>
                终点:
            </b>
            <select id="end" onchange="calcPlan();">
                <option value="24.797717,118.573141">
                    24.797717,118.573141
                </option>
            </select>
            <b>
                换乘策略：
            </b>
            <select id="policy" onchange="calcPlan();">
                <option value="LEAST_TIME">
                    较快捷
                </option>
                <option value="LEAST_TRANSFER">
                    少换乘
                </option>
                <option value="LEAST_WALKING">
                    少步行
                </option>
                <option value="NO_SUBWAY">
                    不坐地铁
                </option>
            </select>
        </div>
        <div style="width:603px;height:300px" id="container">
        </div>
        <div style="width:603px;padding-top:10px;" id="plans">
        </div>
    </body>
</body>

</html>
