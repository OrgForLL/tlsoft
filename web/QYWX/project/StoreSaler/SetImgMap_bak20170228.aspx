<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 
<script runat="server"> 

    protected void Page_Load(object sender, EventArgs e)
    {   
     
    }
     

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<meta name="viewport" content="width=device-width,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no,minimal-ui">
<meta name="apple-mobile-web-app-capable" content="yes">
<META HTTP-EQUIV="Pragma"CONTENT="no-cache">
<META HTTP-EQUIV="Cache-Control"CONTENT="no-cache">
<META HTTP-EQUIV="Expires"CONTENT="0" >
<head runat="server">
    <title>陈列定位</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style>
    *
    {
        margin:0;
        padding:0; 
    }
    html {
        box-sizing:border-box;
        -moz-box-sizing:border-box; /* Firefox */
        -webkit-box-sizing:border-box; /* Safari */
    }
    *, *:before, *:after {
      box-sizing: inherit;
      -moz-box-sizing: inherit;
      -webkit-box-sizing: inherit;
    }
        
    .map
    {
        width: 100%; 
        border: 1px solid #00f;
        position: absolute;
        white-space: nowrap;
        overflow: scroll;
    }
    #mainpic
    { 
        z-index:0;  
        position: absolute;
        transition: all 1s;
        -moz-transition: all 1s; /* Firefox 4 */
        -webkit-transition: all 1s; /* Safari 和 Chrome */
        -o-transition: all 1s; /* Opera */
    }
    
    .ctrlPanel
    {
        width:100%;
        height:240px; 
        position:absolute;
        bottom:0;
        left:0;        
        border:1px solid #f00;        
    }
    .ctrlPanel .leftPanel
    {    
        position:absolute;
        width: 100%;
        height: 100%;  
        border: 0px solid #fff;
        float: right;
        border-right-width: 210px;
    }
    
    .ctrlPanel .leftPanel>div
    {    
        position:absolute;
        height: 70px; 
        line-height:70px;
        border: 1px solid #eee; 
        left:0;
        text-align:center;  
        font-size:14px;  
        vertical-align:middle;
        white-space:nowrap;
        overflow:hidden;
    }
    
    .ctrlPanel .leftPanel>div:active
    {     
        font-weight:700;
        color:#ff0000;  
    }
    .selected
    {
        font-weight:700;
        color:#de2c2c;    
        text-decoration: underline;
    }
    .ctrlPanel .leftPanel>div:nth-child(2)
    {     
        width: 100%;
        top: 30px;
        left:0;
    }
    .ctrlPanel .leftPanel>div:nth-child(3)
    {     
        width: 50%;
        top: 100px;
        left:0;
    }
    .ctrlPanel .leftPanel>div:nth-child(4)
    {     
        width: 50%;
        top: 100px;
        left:50%;
    }
    .ctrlPanel .leftPanel>div:nth-child(5)
    {     
        width: 100%;
        top: 170px;
        left:0;
    }
    
    .ctrlPanel .rightPanel
    {
        width: 210px;
        height: 100%;
        position: absolute;
        right: 0;
        border-left:1px solid #999;
        float: right;
    }
    .ctrlPanelTitle
    {
        height:30px;
        line-height:30px;
        vertical-align:middle;
        font-size:14px;    
        border-bottom:1px solid #d0d0d0;    
        background-color:#fafafa;     
        padding:0 5px;
        position:absolute;
        width:100%;
        left:0;
    }
    
    .ctrlPanel .rightPanel>img
    {
        top:30px;
        width:100%;  
        position:absolute;
        border-bottom:1px solid #cfc;         
    }
    
    .camera
    {
       background-image:url('../../res/img/StoreSaler/camera2.png');
       background-repeat:no-repeat;
       background-position:center;       
       position: absolute;
       width:42px;
       height:42px;
       z-index:10;        
       transition: all 1s;  
       transform:rotate(0deg);   
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
     
    #save
    {
        width:96px;
        height:24px; 
        border:1px solid #a0a0a0;
        background-color:rgba(233,233,233,0.8);
        vertical-align:middle;
        text-align:center;
        line-height:24px;
        border-radius: 10px;
        margin: 3px;
        font-size:14px;    
        position: absolute;
        margin: 122px 60px;
        display:none;
    }
    #save:active
    { 
        border:0;
        background-color:rgba(200,200,200,1); 
    }
    </style>
</head>
<body>
    <form id="form1" runat="server"> 
    <div id="map" class="map">
        <img id="mainpic" alt="门店平面图" />
<%--        <div class='camera' id='Camera1' style='left:50px;top:120px' xpec='10' ypec='20' alt=''></div>
        <div class='camera' id='Camera2' style='left:150px;top:220px' xpec='30' ypec='50'  alt=''></div>--%>
    </div>
    <div id="ctrl" class="ctrlPanel">
        <div class="leftPanel">
            <span class="ctrlPanelTitle">浏览尺寸：</span>
            <div id="setHalf">缩小一半</div>
            <div id="setMaxWidth">全宽填充</div><div id="setMaxHeight">全高填充</div>
            <div id="setDouble">放大一倍</div>
        </div>
        <div class="rightPanel">
            <span class="ctrlPanelTitle">相机方向：<span id="location"></span><span id="rotate"></span></span>
            <img alt="点击设定方向" src="../../res/img/StoreSaler/setcamera.png" />
            <span id="save" onclick="avascript:SaveCameraInfo();">保存设置</span>
        </div>
    </div>
    </form>
</body>

<script src="../../res/js/jquery.js"></script>
<script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
<script>
    const CameraCenter = 21;    //相机中点像素值  
    const RotateCenter = 105;    //方向罗盘的中心像素值  
    const CameraDefaultRotate = 90;    //相机的默认旋转角度
    const AjaxTimeout = 5000;  //超时时间

    var mapW,mapH;  //平面底图的尺寸

    var scalePercent = 1.0; //长宽比率  //这个值由后台取小图片的时候自动算出
    var SetX = 0, SetY = 0, SetRotate = 0;
    var SetXPec = 0, SetYPec = 0;

    var mapBorderWidth = 0,mapBorderHeight = 0;//地图选择框的尺寸

    var mapID = "";
    var MdImgID = "";
    var MdMXImgID = ""; 

    //1初始化各个栏目的尺寸
    function InitPageSize() {
        var h = window.innerHeight;
        var divMap = document.getElementById("map");
        var divCtrl = document.getElementById("ctrl");

        mapBorderWidth = divMap.offsetWidth;
        mapBorderHeight = h - divCtrl.offsetHeight;

        divMap.style.height = mapBorderHeight.toString() + "px"; 
    }
    //2 然后是加载平面底图
    function InitPageData(){ 
       MdImgID = LeeJSUtils.GetQueryParams("MdImgID");
       MdMXImgID = LeeJSUtils.GetQueryParams("MdMXImgID");

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

                if (jsonData.CameraInfos.length > 0){
                    var cameraInfo = jsonData.CameraInfos[0];

                    SetXPec = cameraInfo.XPec;
                    SetYPec = cameraInfo.YPec;
                    SetRotate = cameraInfo.Rotate;
                
                    setCameraObjXY(SetXPec,SetYPec);
                    setCameraObjRotate(SetRotate);
                }
            }
        }); 
    }

    $(document).ready(function () {        
        LeeJSUtils.LoadMaskInit();

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
        SetX = e.offsetX;
        SetY = e.offsetY;        
                
        //计算得到相对于图片的百分比率，并存放到属性中
        SetXPec = SetX * 100 / mapW;
        SetYPec = SetY * 100 / mapH;
        
        SetXPec = SetXPec.toFixed(3);
        SetYPec = SetYPec.toFixed(3);

        //console.log(e); 
        //$("#location").html("x:" + SetX + " y:" + SetY);        //输出位置信息
        //$("#location").html("x:" + SetXPec + " y:" + SetYPec);        //输出位置信息
        setCameraObjXY(SetXPec, SetYPec); 
    });

    $(".rightPanel").on("mousedown","img",function(e){
        var mx = e.offsetX;
        var my = e.offsetY;

        var obj = $("#setCamera");
        if (obj.length > 0) {  //表明对象已被添加
            SetRotate = getAngle(RotateCenter,RotateCenter,mx,my);
            setCameraObjRotate(SetRotate);
        }
    });

    //重新加载所有相机的位置
    function ReLoadCameraLocation(){
        $(".camera").each(function(index,e){
            LoadCameraXY($(this));
        }); 
    }
    
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

    function setCameraObjXY(xPec, yPec) {  
        var xPx = parseInt(xPec * 0.01 * mapW);
        var yPx = parseInt(yPec * 0.01 * mapH);
                
        xPx -= CameraCenter;    //找中点
        yPx -= CameraCenter;

        var obj = $("#setCamera");
        if (obj.length == 0) {  //表明对象尚未被添加
            obj = $("<div class='camera' id='setCamera' style='left:" + xPx + "px;top:" + yPx + "px' xpec='" + xPec + "' ypec='" + yPec + "' alt=''></div>");
            $("#map").append(obj);
        }
        obj.css("left", xPx + "px");
        obj.css("top", yPx + "px");
        obj.attr("xpec",xPec);
        obj.attr("ypec",yPec);

        $(".rightPanel>img").addClass("flash");  
    } 


    function setCameraObjRotate(r){
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
</html>
