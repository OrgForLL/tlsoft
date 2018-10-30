<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server"> 
    private string DBConnStr = clsConfig.GetConfigValue("OAConnStr");
    public string AppSystemKey = "", CustomerID = "", CustomerName = "", RoleName = "", SystemID = "3", StoreID = "";
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数
    private const string ConfigKeyValue = "1";
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            CustomerID = Convert.ToString(Session["qy_customersid"]);
            CustomerName = Convert.ToString(Session["qy_cname"]);
            RoleName = Convert.ToString(Session["RoleName"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通订货会系统权限！");
            else if (RoleName != "kf" && RoleName != "zb" && RoleName != "my" && RoleName != "dz")
                clsWXHelper.ShowError("对不起，您无权限使用本功能模块！");
            else
            {
                clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "利郎形象管理上传、查看页[imaginalMana.aspx]"));
                if (RoleName == "dz")
                    StoreID = Convert.ToString(Session["mdid"]);

                wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
            }
        }
    }    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Cache-Control" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <title>陈列定位</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        html {
            box-sizing: border-box;
            -moz-box-sizing: border-box; /* Firefox */
            -webkit-box-sizing: border-box; /* Safari */
        }

        *, *:before, *:after {
            box-sizing: inherit;
            -moz-box-sizing: inherit;
            -webkit-box-sizing: inherit;
        }

        .map {
            width: 100%;
            position: absolute;
            white-space: nowrap;
            overflow: scroll;
            -webkit-overflow-scrolling: touch; /*liqf*/
        }

        #mainpic {
            z-index: 0;
            position: absolute;
            transition: all 1s;
            -moz-transition: all 1s; /* Firefox 4 */
            -webkit-transition: all 1s; /* Safari 和 Chrome */
            -o-transition: all 1s; /* Opera */
        }

        .ctrlPanel {
            width: 100%;
            height: 240px;
            position: absolute;
            bottom: 0;
            left: 0;
        }

            .ctrlPanel .leftPanel {
                position: absolute;
                width: 100%;
                height: 100%;
                border: 0px solid rgba(255,255,255,0);
                float: right;
                border-right-width: 210px;
            }

                .ctrlPanel .leftPanel > div {
                    position: absolute;
                    height: 70px;
                    line-height: 70px;
                    border: 1px solid #333;
                    left: 0;
                    text-align: center;
                    font-size: 14px;
                    vertical-align: middle;
                    white-space: nowrap;
                    overflow: hidden;
                    background-color: rgba(10,10,10,1.0);
                    color: #eee;
                }

                    .ctrlPanel .leftPanel > div:active {
                        font-weight: 700;
                        text-decoration: underline;
                    }

        .selected {
            font-weight: 700;
            text-decoration: underline;
        }

        .ctrlPanel .leftPanel > div:nth-child(2) {
            width: 100%;
            top: 30px;
            left: 0;
        }

        .ctrlPanel .leftPanel > div:nth-child(3) {
            width: 50%;
            top: 100px;
            left: 0;
        }

        .ctrlPanel .leftPanel > div:nth-child(4) {
            width: 50%;
            top: 100px;
            left: 50%;
        }

        .ctrlPanel .leftPanel > div:nth-child(5) {
            width: 100%;
            top: 170px;
            left: 0;
        }

        .ctrlPanel .rightPanel {
            width: 210px;
            height: 100%;
            position: absolute;
            right: 0;
            border-left: 1px solid #999;
            float: right;
        }

        .ctrlPanelTitle {
            height: 31px;
            line-height: 30px;
            vertical-align: middle;
            font-size: 14px;
            border-bottom: 1px solid #d0d0d0;
            background-color: #fafafa;
            padding: 0 5px;
            position: absolute;
            width: 100%;
            left: 0;
            background-color: rgba(10,10,10,1.0);
            color: #eee;
        }

        .ctrlPanel .rightPanel > img {
            top: 31px;
            width: 100%;
            position: absolute;
        }

        .camera {
            background-image: url('../../res/img/StoreSaler/camera2.png');
            background-repeat: no-repeat;
            background-position: center;
            position: absolute;
            width: 42px;
            height: 42px;
            z-index: 10;
            transition: all 1s;
            transform: rotate(0deg);
        }

        .flash {
            -webkit-animation-name: flash;
            animation-name: flash;
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }

        @-webkit-keyframes flash {
            0%,100%,50% {
                opacity: 0.5;
            }

            25%,75% {
                opacity: 1;
            }
        }

        @keyframes flash {
            0%,100%,50% {
                opacity: 0.5;
            }

            20%,80% {
                opacity: 1;
            }
        }

        #save {
            width: 76px;
            height: 76px;
            background-color: rgba(233,233,233,0.8);
            vertical-align: middle;
            text-align: center;
            line-height: 76px;
            border-radius: 50%;
            font-size: 14px;
            position: absolute;
            margin: 97px 67px;
            display: none;
            /*
        使用多层阴影实现按钮立体效果
        第一层：Y轴偏移1像素、不透明度为0.25的白色外阴影效果
        第二层：Y轴偏移1像素、不透明度为0.25的白色内阴影效果
        第三层：偏移位0、不透明度为0.25的黑色外阴影效果
        第四层：Y轴偏移20像素、不透明度为0.03的白色内阴影效果
        第五层：X轴偏移-20像素、Y轴偏移20像素、不透明度为0.15的黑色内阴影效果
        第六层：X轴偏移20像素、Y轴偏移20像素、不透明度为0.05的白色内阴影效果
        */
            box-shadow: rgba(255,255,255,0.25) 0px 1px 0px, inset rgba(255,255,255,0.25) 0px 1px 0px, inset rgba(0,0,0,0.25) 0px 0px 0px, inset rgba(255,255,255,0.03) 0px 20px 0px, inset rgba(0,0,0,0.15) 0px -20px 20px, inset rgba(255,255,255,0.05) 0px 20px 20px;
            transition: all 0.1s linear;
            border: 1px solid #242424;
        }

            #save:hover {
                /*
        鼠标悬停时的按钮多层阴影效果，和按钮默认时相比只是第一层有变化：
        第一层：X轴偏移2像素、Y轴偏移5像素、不透明度为0.5的黑色外阴影效果
        */
                box-shadow: rgba(0,0,0,0.5) 0px 2px 5px, inset rgba(255,255,255,0.25) 0px 1px 0px, inset rgba(0,0,0,0.25) 0px 0px 0px, inset rgba(255,255,255,0.03) 0px 20px 0px, inset rgba(0,0,0,0.15) 0px -20px 20px, inset rgba(255,255,255,0.05) 0px 20px 20px;
            }

        .gray {
            -webkit-filter: grayscale(100%);
            -moz-filter: grayscale(100%);
            -ms-filter: grayscale(100%);
            -o-filter: grayscale(100%);
            filter: grayscale(100%);
            filter: gray;
        }
    </style>

    <style type="text/css">
        #infomation {
            position: fixed;
            background-color: rgba(0,0,0,0.9);
            color: #fff;
            z-index: 100;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .manage_info {
            right: 0; 
            bottom: 0;
            height: 240px;            
            width: 210px;            
        }
        .store_info  {
            top:0;
            bottom:240px;
            right:0;
            width:50vw;
        }

        #closePanel {
            position: fixed;
            top: 10px;
            right: 50vw;
            width: 45px;
            height: 40px;
            text-align: center;
            font-size: 20px;
            background-color: rgba(0,0,0,0.9);
            color: #fff;
            z-index: 100;
            border-top-left-radius: 15px;
            border-bottom-left-radius: 15px;
        }

        .hideInfo {
            transform: translate3d(50vw,0,0);
            -webkit-transform: translate3d(50vw,0,0);
        }      
        .hideInfo > i {
            transform: rotate(180deg);
            -webkit-transform: rotate(180deg);
        }

        .animation {
            -webkit-transition: -webkit-transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            transition: transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            -webkit-transform-style: preserve-3d;
            -webkit-backface-visibility: hidden;
        }

        .store_info.hideInfo {
            transform: translate3d(50vw,0,0);
            -webkit-transform: translate3d(50vw,0,0);
        }
        .manage_info.hideInfo {
            transform: translate3d(210px,0,0);
            -webkit-transform: translate3d(210px,0,0);
        }

        .manage_info #closePanel {
            display:none;
        }
        .img_wrap {
            position:relative;
            width:100%;
            overflow-y:auto;
            margin-bottom:5px;
        }
            .img_wrap > img {
                width:100%;
            }
            .img_wrap .status {
                position:absolute;
                top:5px;
                right:5px;
                padding:5px 8px;
                font-size:12px;
                font-weight:bold;
                line-height:1;
            }
        .status.s0 {
            background-color: #fff;
            color: #000;
        }
        .status.s1 {
            background-color: #5b9031;
            color: #fff;
        }
        .status.s-1 {
            background-color:#d9534f;
            color: #fff;
        }
        .info_item {
            padding:0 5px;
            margin-bottom:10px;
            overflow-y:auto;
        }
            .info_item .label {
                font-size:14px;
                padding:8px 0 5px 0;
                border-bottom:1px solid #555;
                font-weight:bold;
                line-height:1;
            }
            .info_item .content {
                font-size:12px;
                padding:5px;
                overflow-y:auto;
            }
        .img_wrap .switch_icon {
            width: 0;
            height: 0;
            border-top: 34px solid rgba(0,0,0,.7);
            border-right: 34px solid transparent;
            position: absolute;
            top: 0;
        }
        .si {
            position:absolute;
            top:2px;                          
            left:2px;
            z-index:100;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div id="map" class="map">
            <img id="mainpic" alt="门店平面图" />
        </div>
        <div id="ctrl" class="ctrlPanel">
            <div class="leftPanel">
                <span class="ctrlPanelTitle">浏览尺寸：</span>
                <div id="setHalf">缩小一半</div>
                <div id="setMaxWidth">全宽浏览</div>
                <div id="setMaxHeight">全高浏览</div>
                <div id="setDouble">放大一倍</div>
            </div>
            <div class="rightPanel">
                <span class="ctrlPanelTitle">相机方向：<span id="location"></span><span id="rotate"></span></span>
                <img alt="点击设定方向" src="../../res/img/StoreSaler/setcamera2.png" />
                <span id="save" onclick="javascript:SaveCameraInfo();">保存设置</span>
            </div>
        </div>

        <!--信息页-->
        <div id="closePanel" class="animation hideInfo">
            <i class="fa fa-angle-double-right animation" style="line-height: 40px;"></i>
        </div>        
        <div id="infomation" class="animation hideInfo store_info">
            <!--status=-1未通过 0待审核 1已通过-->
            <div class="img_wrap">
                <img alt="" src="../../res/img/storesaler/imaginal_thumb.jpg" />
                <span class="status s0">--</span>
                <div style="position:absolute;top:0;color: #fff;" onclick="switchInfoImg();">
                    <a href="javascript:;" class="switch_icon"></a>
                    <i class="fa fa-rotate-left (alias) si"></i>
                </div>                
            </div>
            <div class="info_item" id="failmsg">
                <p class="label">审核不通过原因</p>
                <p class="content">--</p>
            </div>
            <div class="info_item" id="remark">
                <p class="label">备注</p>
                <p class="content">--</p>
            </div>
        </div>
    </form>
</body>

<script type="text/javascript" src="../../res/js/jquery.js"></script>
<script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
<script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
<script type="text/javascript">
    var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

    const CameraCenter = 21;    //相机中点像素值  
    const RotateCenter = 105;    //方向罗盘的中心像素值  
    const CameraDefaultRotate = 90;    //相机的默认旋转角度
    const AjaxTimeout = 5000;  //超时时间

    var mapW,mapH;  //平面底图的尺寸

    var scalePercent = 1.0; //长宽比率  //这个值由后台取小图片的时候自动算出
    var SetXPec = 0, SetYPec = 0,SetRotate = -1;

    var mapBorderWidth = 0,mapBorderHeight = 0;//地图选择框的尺寸

    var mapID = "";
    var MdImgID = "";
    var MdMXImgID = ""; 
    var cameraDatas;

    var roleName="<%=RoleName%>";
    //1初始化各个栏目的尺寸
    function InitPageSize() {
        var h = window.innerHeight;
        var divMap = document.getElementById("map");
        var divCtrl = document.getElementById("ctrl");

        mapBorderWidth = divMap.offsetWidth;
        mapBorderHeight = h - divCtrl.offsetHeight;

        divMap.style.height = mapBorderHeight.toString() + "px"; 
    }

    //微信JSAPI
    function wxConfig() {//微信js 注入
        wx.config({
            debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
            appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
            timestamp: timestampVal, // 必填，生成签名的时间戳
            nonceStr: nonceStrVal, // 必填，生成签名的随机串
            signature: signatureVal, // 必填，签名，见附录1
            jsApiList: ["previewImage"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
        });
        wx.ready(function () {
            //alert("注入成功");
        });
        wx.error(function (res) {
            //alert("JS注入失败！");
        });
    }

    //2 然后是加载平面底图
    function InitPageData(){ 
        MdImgID = LeeJSUtils.GetQueryParams("MdImgID");
        MdMXImgID = LeeJSUtils.GetQueryParams("MdMXImgID");

        if(roleName == "kf" || roleName == "my" || roleName == "zb"){
            //管理者不显示罗盘
            $(".rightPanel").hide();
            $("#infomation").removeClass("store_info").addClass("manage_info");
            $("#closePanel").hide();            
        }

        //加载平面底图的信息
        $.ajax({
            url: "SetImgMapCore.ashx?ctrl=GetMapInfo",
            type: "POST",
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            data: { MdImgID: MdImgID },
            dataType: "text",
            timeout: AjaxTimeout * 2,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
            },
            success: function (msg) {
                if (msg.indexOf("Error:") > -1) {        
                    msg = msg.substring(6);            
                    LeeJSUtils.showMessage("error", msg);       
                    return;              
                } 
                
                var jsonData = JSON.parse(msg);
                var mapInfo = jsonData.MapInfo[0];

                mapID = mapInfo.mapID;
                $("#mainpic").attr("src",mapInfo.MapImageFileSrc);
                mapW = mapInfo.MapImageWidth;
                mapH = mapInfo.MapImageHeight; 

                //3根据加载的图片尺寸初始化地图尺寸
                InitMap();
            }
        }); 
    }    
    //3根据加载的图片尺寸初始化地图尺寸
    function InitMap() {
        //        var mainpic = document.getElementById("mainpic");
        //        mapW = mainpic.offsetWidth;
        //        mapH = mainpic.offsetHeight;
        scalePercent = mapW / mapH; //计算得到长宽比率
        //$("#setMaxWidth").click(); //强制设置全宽

        if (scalePercent < 1) $("#setMaxWidth").click();
        else $("#setMaxHeight").click();
    }
    //4 如果有指定MdMXImgID，则尝试初始化其位置和方向    
    function InitCurrentCameraInfo(){
        if (MdMXImgID == "") return;

        //加载平面底图的信息
        $.ajax({
            url: "SetImgMapCore.ashx?ctrl=LoadCameraInfos",
            type: "POST",
            contentType: "application/x-www-form-urlencoded; charset=utf-8",
            data: { MdImgID: MdImgID, MdMXImgID: MdMXImgID },
            dataType: "text",
            timeout: AjaxTimeout,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
            },
            success: function (msg) {
                if (msg.indexOf("Error:") > -1) {        
                    msg = msg.substring(6);            
                    LeeJSUtils.showMessage("error", msg);       
                    return;              
                } 
                
                var jsonData = JSON.parse(msg);
                cameraDatas=null;
                cameraDatas=jsonData.CameraInfos;//保存为全局
                setTimeout(function(){
                    InitCameraInfos(jsonData.CameraInfos);
                },50);
            }
        }); 
    }

    function InitCameraInfos(cameraInfos){
        var j = cameraInfos.length;   
        var addDom;     
        //清空所有的 $(".camera")
        $(".camera").remove();
        for(var i = 0;i < j;i++){
            if (cameraInfos[i].ID == ""){
                continue;
            }

            if (cameraInfos[i].MdMXImgID == MdMXImgID){ 
                SetXPec = cameraInfos[i].XPec;
                SetYPec = cameraInfos[i].YPec;
                SetRotate = cameraInfos[i].Rotate;
                
                addDom = $("<div class='camera' id='setCamera' xpec='" + cameraInfos[i].XPec + "' ypec='" + cameraInfos[i].YPec + "' rotate='" + cameraInfos[i].Rotate + "' alt=''></div>");                
            }else{
                addDom = $("<div class='camera gray' id='Camera" + cameraInfos[i].MdMXImgID + "' xpec='" + cameraInfos[i].XPec + "' ypec='" + cameraInfos[i].YPec + "' rotate='" + cameraInfos[i].Rotate + "' alt=''></div>");                
            }
            $("#map").append(addDom);
        }
        if(roleName == "kf" || roleName == "my" || roleName == "zb"){
            LoadImgInfos(MdMXImgID);
        }
        ReLoadCameraLocation();
    }

    $(document).ready(function () {        
        LeeJSUtils.LoadMaskInit();
        LeeJSUtils.stopOutOfPage("#map",true);//liqf
        LeeJSUtils.stopOutOfPage("#ctrl",false);//liqf
        //wxConfig();
        //1初始化各个栏目的尺寸
        InitPageSize();
        //2 然后是加载平面底图
        InitPageData();        
        //3 初始化长宽参数:在第2不的ajax请求完毕后自动调用
        //InitMap();
        //4 如果有指定MdMXImgID，则尝试初始化其位置和方向
        InitCurrentCameraInfo();
                
        //用于测试
        //ReLoadCameraLocation();
    });

    $(".img_wrap>img").click(function () {
        var src = "http://tm.lilanz.com/qywx/" + $(this).attr("src").replace("../../", "");
        wx.previewImage({
            current: src, // 当前显示图片的http链接
            urls: [src] // 需要预览的图片http链接列表
        });
    });

    $(".leftPanel").on("click", "#setMaxWidth,#setMaxHeight", function (e) {
        $(".leftPanel>div").removeClass("selected");
        $(e.target).addClass("selected");
         
        if (e.target.id == "setMaxWidth") {
            mapW = mapBorderWidth;
            mapH = parseInt(mapBorderWidth / scalePercent);
        }
        else if (e.target.id == "setMaxHeight") {
            mapH = mapBorderHeight;
            mapW = parseInt(mapBorderHeight * scalePercent); 
        }
        $("#mainpic").css("width", mapW + "px");
        $("#mainpic").css("height", mapH + "px");

        //设置完毕后，重新初始化所有相机的位置
        ReLoadCameraLocation();
    });

    $("#setHalf").on("click", function () {
        setScale(0.5);
    });
    $("#setDouble").on("click", function () {
        setScale(2);
    });
        
    $("#mainpic").on("mousedown", function (e) {
        //如果是管理模式则点击摄像头位置不变
        if(roleName == "kf" || roleName == "my" || roleName == "zb")
            return;
        var SetX = e.offsetX;
        var SetY = e.offsetY;
        
        calSetXY(SetX,SetY);
    });

    function calSetXY(setX,setY){
        //计算得到相对于图片的百分比率，并存放到属性中
        SetXPec = setX * 100 / mapW;
        SetYPec = setY * 100 / mapH;
        
        SetXPec = SetXPec.toFixed(3);
        SetYPec = SetYPec.toFixed(3);

        //console.log(e); 
        //$("#location").html("x:" + SetX + " y:" + SetY);        //输出位置信息
        //$("#location").html("x:" + SetXPec + " y:" + SetYPec);        //输出位置信息
        setCameraObjXY(SetXPec, SetYPec); 
    }

    $(".rightPanel").on("mousedown","img",function(e){
        var mx = e.offsetX;
        var my = e.offsetY;

        var obj = $("#setCamera");
        if (obj.length > 0) {  //表明对象已被添加
            SetRotate = getAngle(RotateCenter,RotateCenter,mx,my);
            setCameraObjRotate(SetRotate);
        }
    });
    
    $("#map").on("mousedown",".camera",function(e){
        var id=$(this).attr("id");
        if(id=="setCamera")
            LoadImgInfos(MdMXImgID);
        else
            LoadImgInfos(id.replace("Camera",""));
        e.preventDefault();
    })

    //重新加载所有相机的位置
    function ReLoadCameraLocation(){
        //$(".camera").off("mousedown");    
        $(".camera").each(function(index,e){
            LoadCameraXY($(this));
            setCameraRotate($(this));
        }); 
         
        //单击摄像头
        //$(".camera").on("mousedown",function(e){ 
        //    //var SetX = e.offsetX;
        //    //var SetY = e.offsetY;
        //    //SetX += parseInt(this.style.left.toString().replace("px",""));
        //    //SetY += parseInt(this.style.top.toString().replace("px",""));
        //    //console.log("SetX=" + SetX +  "  SetY=" + SetY);
        //    //calSetXY(SetX,SetY);
        //});    
    }

    //    $("#map").on("mousedown",function(e){ 
    //        var SetX = e.offsetX;
    //        var SetY = e.offsetY;
    //        calSetXY(SetX,SetY);
    //    });
    
    function setScale(pValue) {
        mapW *= pValue;
        mapH *= pValue;

        //限制最小的尺寸：开始
        var divCtrl = document.getElementById("ctrl");
        var minw = divCtrl.offsetWidth;
        var minh = divCtrl.offsetHeight; 
        //限制最小的尺寸：结束
         
        mainpic.style.width = mapW.toString() + "px";
        mainpic.style.height = mapH.toString() + "px";

        //重新处理所有Camera的位置 
        ReLoadCameraLocation(); 
    }

    function LoadCameraXY($cameraObj){
        var xpec = $cameraObj.attr("xpec");
        var ypec = $cameraObj.attr("ypec");
        
        var xPx = parseInt(xpec * 0.01 * mapW);
        var yPx = parseInt(ypec * 0.01 * mapH);
                
        xPx -= CameraCenter;    //找中点
        yPx -= CameraCenter;
        
        $cameraObj.css("left", xPx + "px");
        $cameraObj.css("top", yPx + "px");
    } 
    function setCameraRotate($cameraObj){ 
        var r = $cameraObj.attr("rotate");
        r -= CameraDefaultRotate; //减去默认的已旋转角度

        $cameraObj.css("transform","rotate(" + r.toString() + "deg)"); 
    }

    function setCameraObjXY(xPec, yPec) {  
        var xPx = parseInt(xPec * 0.01 * mapW);
        var yPx = parseInt(yPec * 0.01 * mapH);
                
        xPx -= CameraCenter;    //找中点
        yPx -= CameraCenter;

        var obj = $("#setCamera");
        if (obj.length == 0) {  //表明对象尚未被添加
            obj = $("<div class='camera' id='setCamera' style='left:" + xPx + "px;top:" + yPx + "px' xpec='" + xPec + "' ypec='" + yPec + "' alt=''></div>");
            $("#map").append(obj);                       
        }else{
            obj.css("left", xPx + "px");
            obj.css("top", yPx + "px");
            obj.attr("xpec",xPec);
            obj.attr("ypec",yPec);
        }
        
        $(".rightPanel>img").addClass("flash");  

        if (SetRotate > -1){
            setCameraObjRotate(SetRotate);
        }
    }  

    function setCameraObjRotate(r){
        $("#setCamera").attr("rotate",r);
        //        $("#rotate").html(" r:" + r);      

        r -= CameraDefaultRotate; //减去默认的已旋转角度

        $("#setCamera").css("transform","rotate(" + r.toString() + "deg)");

        $("#save").css("display","inline-block");
    }

    $(".rightPanel>img").on("webkitAnimationEnd", function () {
        $(".rightPanel>img").removeClass("flash");
    })

    //计算角度
    function getAngle(px,py,mx,my){//获得中心p和目标m坐标连线，与y轴正半轴之间的夹角
        var x = Math.abs(px-mx);
        var y = Math.abs(py-my);
        var z = Math.sqrt(Math.pow(x,2)+Math.pow(y,2));
        var cos = y/z;
        var radina = Math.acos(cos);//用反三角函数求弧度
        var angle = Math.floor(180/(Math.PI/radina));//将弧度转换成角度

        if(mx>px&&my>py){//鼠标在第四象限
            angle = 180 - angle;
        }

        if(mx==px&&my>py){//鼠标在y轴负方向上
            angle = 180;
        }

        if(mx>px&&my==py){//鼠标在x轴正方向上
            angle = 90;
        }

        if(mx<px&&my>py){//鼠标在第三象限
            angle = 180+angle;
        }

        if(mx<px&&my==py){//鼠标在x轴负方向
            angle = 270;
        }

        if(mx<px&&my<py){//鼠标在第二象限
            angle = 360 - angle;
        } 
          
        return angle;
    }


    //保存拍摄点信息
    function SaveCameraInfo() { 
        //构造拍摄点信息JSON
        var obj = $("#setCamera");
        if (obj.length == 0) {  //表明对象尚未被添加 
            LeeJSUtils.showMessage("error", "请先点击平面图设置摄像点位置！");
            return;
        }
        var CameraInfo = {"mapID":mapID,"MdImgID":MdImgID,"MdMXImgID":MdMXImgID,"XPec": SetXPec,"YPec": SetYPec,"Rotate": SetRotate};
        
        LeeJSUtils.showMessage("loading", "正在保存拍摄点信息...");
        setTimeout(function () {
            $.ajax({
                url: "SetImgMapCore.ashx?ctrl=SaveCameraInfo",
                type: "POST",
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                data: { CameraInfo: JSON.stringify(CameraInfo) },
                dataType: "text",
                timeout: AjaxTimeout,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                },
                success: function (msg) {
                    if (msg.indexOf("Successed") > -1) {
                        console.log(msg);
                        LeeJSUtils.showMessage("successed", "保存成功！");   
                    } else
                        LeeJSUtils.showMessage("error", "操作失败 " + msg.replace("Error:", ""));
                }
            });
        }, 50);
    }
</script>


<script type="text/javascript">
    //===================我的代码===================
    $("#closePanel").click(function(){
        if($("#infomation").hasClass("hideInfo")){
            $("#infomation").removeClass("hideInfo");
            $(this).removeClass("hideInfo");
        }            
        else{
            $("#infomation").addClass("hideInfo");
            $(this).addClass("hideInfo");
        }        
    });
    
    //单击摄像头时显示对应的相关信息
    var curCameraIndex="-1";
    function LoadImgInfos(mdmx_id){
        $("#infomation .img_wrap>img").data("switch","1");
        if(mdmx_id==""||mdmx_id=="0"||typeof(mdmx_id)=="undefined")
            return;
        else{
            for(var i=0;i<cameraDatas.length;i++){
                if(cameraDatas[i].MdMXImgID==mdmx_id){
                    curCameraIndex=i;
                    break;
                }
            }

            $("#infomation .img_wrap>img").attr("src","../../"+cameraDatas[curCameraIndex].AddressURL.replace("/my/","/"));
            $("#infomation .img_wrap>img").data("switch","1");
            
            switch(cameraDatas[curCameraIndex].Status){
                case "0":
                    $(".img_wrap .status").text("待审核");
                    $("#failmsg").hide();
                    break;
                case "1":
                    $(".img_wrap .status").text("已通过");
                    $("#failmsg").hide();
                    break;
                case "-1":
                    $(".img_wrap .status").text("未通过");
                    $("#failmsg").show();
                    break;
                default:
                    break;
            }
            $(".img_wrap .status").attr("class","status s"+cameraDatas[curCameraIndex].Status);
            $("#failmsg .content").text(decodeURIComponent(cameraDatas[curCameraIndex].FailMsg));
            $("#remark .content").text(cameraDatas[curCameraIndex].Remark);   
            //展开面板
            $("#infomation").removeClass("hideInfo");
            $("#closePanel").removeClass("hideInfo");
        }
    }

    function switchInfoImg(){
        var _switch=$("#infomation .img_wrap>img").data("switch");
        if(curCameraIndex=="-1")
            return;
        else{
            if(_switch=="1"){
                $("#infomation .img_wrap>img").attr("src","../../"+cameraDatas[curCameraIndex].Photo.replace("/my/","/"));
                $("#infomation .img_wrap>img").data("switch","0");            
            }else{
                if(cameraDatas[curCameraIndex].AddressURL=="")
                    $("#infomation .img_wrap>img").attr("src","../../res/img/storesaler/imaginal_thumb.jpg");
                else
                    $("#infomation .img_wrap>img").attr("src","../../"+cameraDatas[curCameraIndex].AddressURL.replace("/my/","/"));

                $("#infomation .img_wrap>img").data("switch","1");
            }
        }
    }

    $("#infomation .img_wrap>img").click(function(){
        window.parent.previewImgWX($(this).attr("src"));
    })
</script>
</html>
