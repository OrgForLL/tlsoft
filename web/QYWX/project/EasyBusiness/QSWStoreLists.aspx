<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>

<!DOCTYPE html>
<script runat="server"> 

     private static String ConfigKey = clsConfig.GetConfigValue("CurrentConfigKey");   //APPID  
    public System.Collections.Generic.List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数

    string dbConn = clsConfig.GetConfigValue("OAConnStr");   
    public string storeinfo = "";
     
    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        //SetIsDebugMode();
        
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(dbConn))
        { 
            string strSQL = string.Concat(@"SELECT D.id,B.mdmc,D.addressInfo,C.zmdPhone,D.Lat,D.Lng 
                                             FROM yx_t_khb A
                                            INNER JOIN t_mdb B ON A.khid = B.khid
                                            INNER JOIN (SELECT MAX(id) id,mdid FROM yx_t_jmspb GROUP BY mdid) jm ON b.mdid=jm.mdid
                                            INNER JOIN yx_t_jmspb C ON jm.id = C.id
                                            INNER JOIN wx_t_StorePointLocation D ON D.mapType = 'jm' AND D.mapID = C.ID
                                            WHERE A.khfl IN ('xm','xn','xk','xx') AND A.ty = 0 AND B.ty = 0
                                            ORDER BY B.mdmc");
            DataTable dt;
            string strInfo = dal.ExecuteQuery(strSQL, out dt);
            if (strInfo != "")
            {
                clsLocalLoger.WriteError(string.Concat("[轻商务]读取加盟审批门店位置时失败！错误：" , strInfo));
                clsWXHelper.ShowError("系统维护中...");
                return;
            }  
            
            storeinfo = dal.DataTableToJson(dt);

            clsSharedHelper.DisponseDataTable(ref dt);
        } //end using            


        //获取微信JS_API config相关配置 
        wxConfig = clsWXHelper.GetJsApiConfig(ConfigKey); 
    }

    private void SetIsDebugMode()
    {
        dbConn = "server='192.168.35.10';database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";
    }

</script>
<html lang="zh-cn">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />    
    <title>最近的门店信息</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <style type="text/css">
        .page {
            background-color: #f8f8f8;
            font-family: "Helvetica Neue", "Microsoft Yahei","微软雅黑",sans-serif;
            font-weight: 400;
            bottom: 30px;
            padding: 0;
        }

        .footer {
            height: 30px;
            line-height: 30px;
            background-color: #f8f8f8;
            color: #888;
            font-size: 12px;
        }
        .header
        {
            line-height: 50px;
        }
        
        .item {
            background-color: #fff;
            padding: 10px;
            margin-top: 10px;
            position:relative;
        }
            .item .right {
                position:absolute;
                top:50%;
                right:0;
                width:60px;
                transform:translate(0,-50%);
                border-left:1px solid #ccc;
                height:50px;
                line-height:50px;                
                text-align:center;
            }
        .name {
            font-size:16px;
            color:#323232;
            font-weight:600;
        }
        .address {
            margin-top: 5px;
            color: #909090;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            padding-right: 60px;
        }
        .phone>a {
            color:#63b359;            
        }
        .location_icon {
            width:30px;
            margin-top:10px;            
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="header"> 
            <span><img class="location_icon" style="width:18px;margin-bottom: -4px;" src="../../res/img/easybusiness/location_icon.png" />最近门店：</span>
            <span id="myStore" style="text-decoration: underline;">XXX</span>
        </div>
        <div class="page page-not-footer" id="main"> 
        </div>
    </div>
    <div class="footer">
        &copy;2017 利郎信息技术部提供技术支持
    </div>

    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>  
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript">
        var storeinfo = '<%= storeinfo %>';

        window.onload = function () {
            LeeJSUtils.stopOutOfPage("#main",true);
            LeeJSUtils.stopOutOfPage(".footer", false);
        }

        function goMap(StoreIndex) {
            var url = "EasyBusinessMapV2.aspx?id=" + StoreIndex;
            window.location.href = url;
        }

        $(document).ready(function () {
            var jsonObj = JSON.parse(storeinfo); 

            var uhtml = template("storeinfo", jsonObj);
            $("#main").html(uhtml);
        });


        //以下是微信开发的JS
        wx.config({
            debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
            appId: '<%= wxConfig[0] %>', // 必填，公众号的唯一标识
            timestamp: '<%= wxConfig[1] %>', // 必填，生成签名的时间戳
            nonceStr: '<%= wxConfig[2] %>', // 必填，生成签名的随机串
            signature: '<%= wxConfig[3] %>', // 必填，签名，见附录1
            jsApiList: [
		'hideMenuItems',
		'getLocation'
		] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
        });

        wx.ready(function () {
            wx.hideMenuItems({
                menuList: ['menuItem:openWithSafari', 'menuItem:openWithQQBrowser', 'menuItem:share:qq', 'menuItem:copyUrl', 'menuItem:favorite'] // 要隐藏的菜单项，所有menu项见附录3
            });

            wx.getLocation({
                type: 'wgs84', // 默认为wgs84的gps坐标，如果要返回直接给openLocation用的火星坐标，可传入'gcj02'
                success: function (res) {
                    var latitude = res.latitude; // 纬度，浮点数，范围为90 ~ -90
                    var longitude = res.longitude; // 经度，浮点数，范围为180 ~ -180。
                    //                    var speed = res.speed; // 速度，以米/每秒计
                    //                    var accuracy = res.accuracy; // 位置精度

                    //计算得到最近的门店
                    CalMyStoreInfo(latitude, longitude);
                }
            });
        });

        function CalMyStoreInfo(myLat, myLng) {
            var minDistance = -1;
            var jsonObj = JSON.parse(storeinfo);
            var j = jsonObj.list.length;
            var i;
            var nowDistance;
            var minObj;
            for (i = 0; i < j; i++) {
                nowDistance = getDistance(myLat,myLng,parseFloat(jsonObj.list[i].Lat),parseFloat(jsonObj.list[i].Lng));

                if (minDistance < 0 || minDistance > nowDistance){
                    minDistance = nowDistance;
                    minObj = jsonObj.list[i];

                    //console.log(jsonObj.list[i].mdmc);
                }
            }

            if (minDistance > 0) {
                setTimeout(ShowMyStore(minObj), 50);
            }
        }

        function ShowMyStore(minObj) { 
            $("#main").removeClass("page-not-footer");
            $("#main").addClass("page-not-header-footer");

            var mymdmc = minObj.mdmc + "(点击定位)";
            $("#myStore").html(mymdmc);
            $("#myStore").on("click", function () {
                goMap(minObj.id);
            });
        }

        function getDistance(goLat, goLng, toLat, toLng) {
            var d1 = Math.abs(goLat - toLat);
            var d2 = Math.abs(goLng - toLng);

            return Math.sqrt(Math.pow(d1, 2) + Math.pow(d2, 2));
        }

    </script>
</body>
</html>

<!--模板-->
<script id="storeinfo" type="text/html">
{{each list as value i}}
    <div class="item" onclick="goMap({{value.id}})">
        <div class="left">
            <p class="name">{{value.mdmc}}</p>
            <p class="address">{{value.addressInfo}}</p>
            <p class="phone"><a href="tel:{{value.zmdPhone}}">{{value.zmdPhone}}</a></p>
        </div>
        <div class="right">
            <img class="location_icon" src="../../res/img/easybusiness/location_icon.png" />
        </div>
    </div> 
{{/each}}
</script>