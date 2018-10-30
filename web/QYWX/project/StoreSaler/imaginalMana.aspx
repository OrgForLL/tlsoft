<%@ Page Language="C#" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>

<!DOCTYPE html>
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
<html lang="zh-cn">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>利郎形象管理</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        .page {
            padding: 0;
        }

        #index {
            background: radial-gradient(circle, #555, #222);            
        }

        .top, .bot {
            width: 100vw;
            height: 50vh;
            position: relative;
            overflow: hidden;
        }

        .top {
            border-bottom: 2px solid #222;
        }
            .top .musttag {                
                position:absolute;
                top:10px;
                right:10px;
                background-color:rgba(217, 83, 79, 0.8);
                color:#fff;
                font-weight:bold;
                padding:0px 10px;
                height:22px;
                line-height:22px;
                display:none;
            }
        .img_wrapper {
            width: 100%;
            height: 100%;
            text-align: center;
            position: relative;
        }

            .img_wrapper .no_upload {
                text-align: center;
                line-height: 50vh;
                color: #fff;
                font-weight: bold;
            }

        .adaptimg {
            height: 100%;
        }

        .quick_bar {
            position: absolute;
            left: 0;
            bottom: 0;
            width: 100%;
            z-index:10;
        }

        .bar_icon {
            background-color: rgba(0,0,0,.8);
            color: #fff;
            height:40px;
            line-height:40px;                       
            text-align: center;
            border-radius: 2px 2px 0 0;
            transition: all 0.2s;
            position: absolute;
            left: 0;
            bottom: 0;
            z-index: 200;
            -webkit-transition: -webkit-transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            transition: transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            padding:0 10px;
        }

        .bar_thumb {
            height: 100px;
            width: 100%;
            background-color: rgba(0,0,0,0.8);
            padding: 10px;
            transform: translate(0,100px);
            -webkit-transition: -webkit-transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            transition: transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
        }

            .bar_thumb .thumb_item {
                display: inline-block;
                width: 80px;
                height: 80px;
                border-radius: 2px;
                vertical-align: top;
                position: relative;
                background-color: #fff;
                margin-right: 10px;
                text-align: center;
                overflow: hidden;
                border: 1px solid #333;
            }

        .thumb_ul {
            white-space: nowrap;
            overflow-x: auto;
            overflow-y: hidden;
            -webkit-overflow-scrolling: touch;
        }

            .thumb_ul::-webkit-scrollbar {
                display: none;
            }

        .moveUp100 {
            transform: translate(0,-100px);
            -webkit-transform: translate(0,-100px);
        }

        .moveUp0 {
            transform: translate(0,0);
            -webkit-transform: translate(0,0);
        }

        .top .btns {
            position: absolute;
            top: 50%;
            left: 0;
            background-color: rgba(0,0,0,0.8);
            color: #fff;
            width: 44px;
            padding: 10px 0;
            text-align: center;
            transform: translate(0,-50%);
        }

            .top .btns.next {
                left: initial;
                right: 0;
            }

        .bot .btns {
            position: absolute;
            top: 0;
            right: 0;
            z-index: 100;
        }

        .bot .btn_item {
            /*display: inline-block;*/
            width: 40px;
            height: 40px;
            margin-top: 10px;
            background-image: url(../../res/img/storesaler/imaginal_icons.png);
            background-repeat: no-repeat;
            background-size: cover;
            z-index: 100;
            display: none;
        }

        .upload {
            background-color: rgba(108, 204, 156, 0.5);
            position: absolute;
            top: 0;
            left: 10px;
            z-index: 1000;
        }
        .upremark {
            position: absolute;
            background-color: rgba(236,111,28,0.8);
            top:0;
            left:60px;
            z-index: 1000;            
            background-position: 0 -160px;            
        }
        .graph {
            position: absolute;
            top: 36%;
            left: 10px;
            transform: translate(0,-50%);
            background-position: 0 -120px;
            background-color: rgba(0, 0, 0, 0.8);
            display: initial !important;
        }

        .pass {
            background-position: 0 -40px;
            background-color: rgba(91, 144, 49, 0.8);
        }

        .not-pass {
            background-position: 0 -81px;
            background-color: rgba(217, 83, 79, 0.9);
            margin: 0 10px 0 5px;
        }

        .top .counts {
            position: absolute;
            right: 0;
            top: 0;
            text-align: center;
            width: 100%;
            padding: 10px 0;
        }

            .top .counts > span {
                background-color: rgba(0,0,0,.5);
                padding: 3px 14px;
                margin: 10px 0;
                font-size: 14px;
                color: #fff;
                letter-spacing: 1px;
                font-weight: bold;
                border-radius: 4px;
            }

        .top .remark {
            background-color: rgba(0,0,0,.6);
            color: #fff;
            position: absolute;
            left: 0;
            width: 100%;
            bottom: 0;
        }

            .top .remark > p {
                padding: 5px 10px;
            }

        .not_pass_mask,.upremark_mask {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.8);
            z-index: 1000;
            padding: 0 20px;
            display: none;
        }

        #txt_nopass,#txt_upremark {
            width: 100%;
            height: 34vh;
            padding: 10px;
            font-size: 16px;
            border-radius: 0;
            outline: none;
            border: none;
        }

        .pass_btns,.upremark_btns {
            height: 10vh;
            font-size: 0;
            padding: 2vh 0;
        }

            .pass_btns > a, .upremark_btns > a {
                color: #fff;
                font-size: 16px;
                font-weight: bold;
                width: 50%;
                text-align: center;
                display: inline-block;
                line-height: 6vh;
            }

        .bar_thumb .thumb_item.current {
            border: 2px solid #5b9031;
        }

        #auditStatus {
            position:absolute;
            top:0;
            left:0;
            width:100%;
            color:#fff;
            font-weight:600;
            text-align:center;
            display:none;
        }

            #auditStatus .pass {
                background-color: #5b9031;
                padding:2px 0;                
                display:none;                
            }

            #auditStatus .no-pass {
                background-color:#d9534f;
                padding:2px 0;                                
            }
                #auditStatus .no-pass > .fa {
                    font-size:18px;
                }
                #auditStatus .no-pass .nopass_info {
                    text-align: left;
                    padding: 0 20px;   
                    display:none;                 
                }
        .navNums {
            color:#fff;
            font-weight:600;
            height:40px;
            line-height:40px;
            padding:0 5px;
            display:inline-block;
        }
        
        #map_page {
            padding:0;
            height:100vh;
            overflow:hidden;
            background-color:#000;
        }
        iframe {
            width: 100%;
            height: 100%;
            border: none;
            outline: none;
        }
        #page_close_btn {
            background-color: rgba(66,66,66,0.8);
            padding: 8px;
            position: fixed;
            left: 15px;
            bottom: 15px;
            color: #fff;
            border-radius: 4px;
            font-size: 14px;
            line-height:1;
            z-index:1000;
        }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page" id="index">
            <div class="top">
                <div class="img_wrapper">
                    <img class="adaptimg" src="" />
                </div>
                <a class="btns prev" href="javascript:navImgs('prev')"><i class="fa fa-2x fa-angle-left"></i></a>
                <a class="btns next" href="javascript:navImgs('next')"><i class="fa fa-2x fa-angle-right"></i></a>
                <div class="counts"><span>--</span></div>
                <!--必传标识-->                
                <div class="musttag">必 传</div>
                <!--图片的说明文字-->
                <div class="remark">
                </div>
            </div>
            <div class="bot">
                <!--功能性按钮-->
                <a class="btn_item upload" href="javascript:$('#choosePhoto')[0].click();"></a>
                <!--门店上传时可以附带文字说明-->
                <a class="btn_item upremark" href="javascript:saveRemarkForMD();"></a>
                <a class="btn_item graph" href="javascript:TryOpenMap();"></a>
                <!--审核通过/不通过-->
                <div class="btns">
                    <a class="btn_item pass" href="javascript:subAudit(1,'');"></a>
                    <a class="btn_item not-pass" href="javascript:$('.bot .not_pass_mask').fadeIn(100);"></a>
                </div>
                <div class="img_wrapper">
                    <img class="adaptimg" src="" />
                    <p class="no_upload">还未上传..</p>
                </div>

                <!--不通过时输入原因-->
                <div class="not_pass_mask">
                    <p style="text-align: center; color: #fff; font-size: 16px; font-weight: bold; line-height: 6vh;">为什么不通过？</p>
                    <textarea id="txt_nopass" placeholder="输入原因.."></textarea>
                    <div class="pass_btns">
                        <a href="javascript:subAudit(-1,$('#txt_nopass').val().trim());" style="border-right: 1px solid #fff;">提 交</a>
                        <a href="javascript:$('.not_pass_mask').hide();">取 消</a>
                    </div>
                </div>

                <!--门店上传时的文字说明-->
                <div class="upremark_mask">
                    <p style="text-align: center; color: #fff; font-size: 16px; font-weight: bold; line-height: 6vh;">补充说明</p>
                    <textarea id="txt_upremark" placeholder="对于上传的图片需要补充说明什么.."></textarea>
                    <div class="upremark_btns">
                        <a href="javascript:saveUpRemark($('#txt_upremark').val().trim());" style="border-right: 1px solid #fff;">确 认</a>
                        <a href="javascript:$('.upremark_mask').hide();">取 消</a>
                    </div>
                </div>

                <!--底部的快速选择-->
                <div class="quick_bar" data-status="off">
                    <div class="bar_icon" onclick="showThumbList()">
                        <i class="fa fa-2x fa-angle-double-up" style="vertical-align:middle;"></i>
                        <!--图片数显示-->
                        <div class="navNums">
                            <span id="currentNos">--</span> / <span id="totalNos">--</span>
                        </div>
                    </div>
                    <div class="bar_thumb">
                        <ul class="thumb_ul">
                        </ul>
                    </div>
                </div>

                <!--审核状态-->
                <div id="auditStatus">
                    <p class="pass">审核通过</p>
                    <div class="no-pass" data-status="0" onclick="showAuditInfo(this)">
                        <p style="margin-bottom:2px;">审核不通过</p>
                        <p class="nopass_info">--</p>
                        <i class="fa fa-angle-double-down"></i>
                    </div>
                </div>
            </div>
        </div>
        <!--文件上传-->
        <div id="filebox" hidden="hidden">
            <input type="file" id="choosePhoto" />
        </div>

        <!--平面图上传-->
        <div id="imgMapFileBox" hidden="hidden">
            <input type="file" id="chooseImgMap" />
        </div>
                 
        <!--门店平面图页面-->
        <div class="page page-right" id="map_page"></div> 
    </div>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/resLoader.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/LocalResizeIMG.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/mobileBUGFix.mini.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/binaryajax.min.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/exif.min.js"></script>

    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        var choosePhotoWidth = 800, imgMapWidth = 1500;  //上传图片的宽度 liqf
        var currentIndex = -1, roleName = "<%=RoleName%>", albumDatas = [], albumDatasForMD = [], model = "common", mdid = "";
        var pid = 0, mdpid = 0;//pid 相册模板的ID mdpid 门店对应的相册ID
        var customerID = "<%=CustomerID%>", customerName = "<%=CustomerName%>";
        $(document).ready(function () {
            FastClick.attach(document.getElementById("index"));
            LeeJSUtils.LoadMaskInit();
            BindEvents();
            wxConfig();

            pid = LeeJSUtils.GetQueryParams("pid");
            if (pid == "")
                LeeJSUtils.showMessage("error", "请检查传入的参数！【pid】");
            else if ((roleName == "kf" || roleName == "my" || roleName == "zb") && LeeJSUtils.GetQueryParams("mdid") == "") {
                LeeJSUtils.showMessage("error", "请检查传入的参数！【mdid】");
            }
            else {
                DataInit();
            }

            //相关按钮屏蔽
            if (roleName == "kf" || roleName == "my" || roleName == "zb") {
                model = "admin";
                mdid = LeeJSUtils.GetQueryParams("mdid");
                $(".btns .btn_item").css("display", "inline-block");
                $(".btn_item.upload").hide();
                $(".btn_item.upremark").css("background-position", "0 -200px");
                $(".upremark_btns>a:first-child").hide();
                $(".upremark_btns>a:last-child").text("关 闭");
                $(".upremark_btns>a").css("width", "100%");
            } else if (roleName == "dz") {
                mdid = "<%=StoreID%>";
                model = "common";
                $(".btn_item.upload").show();
                $(".btn_item.upremark").show();
            }
        });

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

        //事件绑定统一写在这里
        function BindEvents() {
            //底部的快速切换
            $(".thumb_ul").on("click", ".thumb_item", function () {
                if (!$(this).hasClass("current")) {
                    var index = $(".thumb_ul .thumb_item").index($(this));
                    indexPhoto(index);
                }
            });

            //顶部图片预览
            $(".top .adaptimg").click(function () {
                previewImgWX($(this).attr("src"));
            });
            //底部图片预览
            $(".bot .adaptimg").click(function () {                
                previewImgWX($(this).attr("src"));
            });
        }

        function previewImgWX(_src) {
            var src = "http://tm.lilanz.com/oa/" + _src.replace("../../", "");
            wx.previewImage({
                current: src, // 当前显示图片的http链接
                urls: [src] // 需要预览的图片http链接列表
            });
        }

        //提交审核 status=1通过 status=-1未通过
        function subAudit(status, remark) {
            LeeJSUtils.showMessage("loading", "正在提交数据..");
            setTimeout(function () {
                $.ajax({
                    url: "ImageManageCore.aspx?ctrl=SaveImageResult",
                    type: "POST",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { cid: customerID, cname: customerName, infoid: albumDatas[currentIndex].infoid, Status: status, remark: encodeURIComponent(remark), MdImgID: mdpid },
                    dataType: "text",
                    timeout: 20 * 1000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                    },
                    success: function (msg) {
                        if (msg.indexOf("Successed") > -1) {
                            console.log(msg);
                            var _arr = msg.split("|");
                            if (_arr.length > 1)
                                LeeJSUtils.showMessage("successed", "操作成功！ " + _arr[1]);
                            else
                                LeeJSUtils.showMessage("successed", "操作成功！");

                            if (status == -1)
                                $(".not_pass_mask").hide();
                            albumDatasForMD[currentIndex].Status = status;
                            albumDatasForMD[currentIndex].FailMsg = remark;
                            var _index = currentIndex;
                            currentIndex = -1;//如果不变化则indexPhoto不执行
                            indexPhoto(_index);
                        } else
                            LeeJSUtils.showMessage("error", "操作失败 " + msg.replace("Error:", ""));
                    }
                });
            }, 50);
        }

        //数据初始化 分两次加载 先加载顶部的相册模板 再加载底部门店的上传数据
        function DataInit() {
            LeeJSUtils.showMessage("loading", "正在加载..");
            setTimeout(function () {
                $.ajax({
                    url: "ImageManageCore.aspx?ctrl=LoadStoreImgInfo",
                    type: "POST",
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { id: pid },
                    dataType: "text",
                    timeout: 10 * 1000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                    },
                    success: function (msg) {
                        //console.log(msg);
                        if (msg.indexOf("Error:") == -1) {
                            var rows = JSON.parse(msg).List, html = "", resArr = [];
                            var _tp = "<li class='thumb_item'><img class='adaptimg' src='#url#' /></li>";
                            for (var i = 0; i < rows.length; i++) {
                                var row = rows[i];
                                row.thumburl = "../../" + row.url;
                                row.url = row.thumburl.replace("/my/", "/");
                                resArr.push(row.url);
                                html += _tp.replace("#url#", row.thumburl);
                                albumDatasForMD.push({});//创建出相同个数的数组
                            }//end for
                            albumDatas = rows;
                            $("#totalNos").text(rows.length);
                            $("#currentNos").text("1");
                            document.title = JSON.parse(msg).Title;
                            imgLoader(resArr, function () {
                                $(".thumb_ul").html(html);
                                DataInitForMD();
                            });
                        } else
                            LeeJSUtils.showMessage("error", "加载失败 " + msg.replace("Error:", ""));
                    }
                });
            }, 50);
        }

        //加载门店上传的数据
        //status=-1未通过 0待审核 1已通过
        //infoid 相册模板明细ID
        function DataInitForMD() {            
            LeeJSUtils.showMessage("loading", "正在加载门店数据..");
            $.ajax({
                url: "ImageManageCore.aspx?ctrl=LoadStoreImgInfoForMD",
                type: "POST",
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                data: { id: pid, mdid: mdid },
                dataType: "text",
                timeout: 10 * 1000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                },
                success: function (msg) {
                    if (msg.indexOf("Error:") == -1) {
                        //console.log(msg);                        
                        var rows = JSON.parse(msg), resArr = [];
                        $(".top .counts>span").text(rows.mdmc);
                        mdpid = rows.id;
                        //如果还没有提交审核 管理员进入时不出现审核的相关按钮
                        if (rows.Submit == "0")
                            $(".btns .btn_item").css("display", "none");
                        for (var i = 0; i < rows.List.length; i++) {
                            var row = rows.List[i];
                            row.thumburl = "../../" + row.url;
                            if (row.url != "")
                                resArr.push("../../" + row.url.replace("/my/", "/"));
                            row.url = row.thumburl.replace("/my/", "/");
                            //依据infoid来匹配数据
                            for (var j = 0; j < albumDatas.length; j++) {
                                if (albumDatas[j].infoid == row.infoid) {
                                    albumDatasForMD[j] = row;
                                    break;
                                }
                            }//end for j
                        }//end for
                        if (resArr.length > 0) {
                            imgLoader(resArr, function () {
                                indexPhoto(0);//定位到第一张
                            });
                        } else {
                            indexPhoto(0);//定位到第一张
                            LeeJSUtils.showMessage("successed", "加载完成！");
                        }
                    } else
                        LeeJSUtils.showMessage("error", "加载失败 " + msg.replace("Error:", ""));
                }
            });
        }

        function showThumbList() {
            var status = $(".quick_bar").attr("data-status");
            if (status == "off") {
                $(".bar_icon").addClass("moveUp100");
                $(".bar_thumb").addClass("moveUp0");
                $(".bar_icon .fa-angle-double-up").removeClass("fa-angle-double-up").addClass("fa-angle-double-down");
                $(".quick_bar").attr("data-status", "on");
            } else {
                $(".bar_icon").removeClass("moveUp100");
                $(".bar_thumb").removeClass("moveUp0");
                $(".bar_icon .fa-angle-double-down").removeClass("fa-angle-double-down").addClass("fa-angle-double-up");
                $(".quick_bar").attr("data-status", "off");
            }
        }

        //顶部左右切换按钮
        function navImgs(direction) {
            if (albumDatas.length == 1)
                return;
            if (direction == "prev") {
                $(".thumb_ul .thumb_item.current").removeClass("current");
                if (currentIndex == 0)
                    indexPhoto(albumDatas.length - 1);
                else
                    indexPhoto(currentIndex - 1);
            } else if (direction == "next") {
                $(".thumb_ul .thumb_item.current").removeClass("current");
                if (currentIndex == albumDatas.length - 1)
                    indexPhoto(0);
                else
                    indexPhoto(currentIndex + 1);
            }
        }

        //定位到某张图片
        function indexPhoto(index) {
            if (index == currentIndex)
                return;
            $(".top .img_wrapper .adaptimg").attr("src", albumDatas[index].url);
            $('.upremark_mask').hide();
            if (typeof (albumDatasForMD[index].infoid) == "undefined") {
                $(".bot .img_wrapper .adaptimg").hide();
                $(".bot .img_wrapper .no_upload").show();
            } else {
                $(".bot .img_wrapper .adaptimg").attr("src", albumDatasForMD[index].url);
                $(".bot .img_wrapper .adaptimg").show();
                $(".bot .img_wrapper .no_upload").hide();
            }

            if (albumDatas[index].IsMust == "True")
                $(".top .musttag").show();
            else
                $(".top .musttag").hide();

            if (albumDatas[index].remark != "")
                $(".top .remark").html("<p>" + albumDatas[index].remark + "</p>");
            else
                $(".top .remark").empty(); //By:xlm 20170117 增加了该行

            $(".thumb_ul .thumb_item.current").removeClass("current");
            $(".thumb_ul .thumb_item").eq(index).addClass("current");

            //处理审核信息status=-1未通过 0待审核 1已通过
            if (albumDatasForMD[index].Status == "1") {
                //审核通过
                $("#auditStatus .pass").show();
                $("#auditStatus .no-pass").hide();
                if (model == "common") {
                    $(".btn_item.upload").hide();
                    $(".btn_item.upremark").hide();
                }
                $("#auditStatus").show();
            } else if (albumDatasForMD[index].Status == "-1") {
                //审核不通过
                $("#auditStatus .no-pass").show();
                if (model == "common") {
                    $(".btn_item.upload").show();
                    $(".btn_item.upremark").show();
                }
                $("#auditStatus .pass").hide();
                $("#auditStatus .no-pass .nopass_info").text(decodeURIComponent(albumDatasForMD[index].FailMsg));
                $("#auditStatus").show();
            } else {
                if (model == "common") {
                    $(".btn_item.upload").show();
                    $(".btn_item.upremark").show();
                }
                $("#auditStatus .no-pass").hide();
                $("#auditStatus .pass").hide();
                $("#auditStatus .no-pass .nopass_info").text("");
                $("#auditStatus").hide();
            }

            if (model == "admin") {
                if (albumDatasForMD[index].Status == "0")
                    $(".bot .btns").show();
                else
                    $(".bot .btns").hide();

                if (albumDatasForMD[index].Remark != "" && typeof (albumDatasForMD[index].Remark) != "undefined") {
                    $(".btn_item.upremark").show();
                    $(".btn_item.upremark").css("left", "10px");
                } else {
                    $(".btn_item.upremark").hide();
                    $(".btn_item.upremark").css("left", "60px");
                }
            }

            currentIndex = index;
            $("#currentNos").text(index + 1);
        }

        //图片预加载
        function imgLoader(resArr, cb) {
            var loader = new resLoader({
                resources: resArr,
                onStart: function (total) {
                    LeeJSUtils.showMessage("loading", "正在下载图片..");
                },
                onProgress: function (current, total) {
                },
                onComplete: function (total) {
                    console.log("加载完成！" + total);
                    LeeJSUtils.showMessage("successed", "- 加载完成 -");
                    if (typeof (cb) == "function")
                        cb();
                }
            });

            loader.start();
        }

        //门店上传图片
        var oRotate = 0, isUploading = false;        
        $("#choosePhoto").localResizeIMG({
            width: choosePhotoWidth,
            quality: 1,
            before: function (that, blob) {                
                LeeJSUtils.showMessage("loading", "正在处理图片..");
                var filePath = $("#choosePhoto").val();
                var extStart = filePath.lastIndexOf(".");
                var ext = filePath.substring(extStart, filePath.length).toUpperCase();

                if (ext != ".BMP" && ext != ".PNG" && ext != ".GIF" && ext != ".JPG" && ext != ".JPEG") {
                    LeeJSUtils.showMessage("warn", "对不起，只能上传图片！");
                    return false;
                }

                var imgfile = that.files[0];
                fr = new FileReader;
                fr.readAsBinaryString(imgfile);
                fr.onloadend = function () {
                    var exif = EXIF.readFromBinaryFile(new BinaryFile(this.result));
                    if (exif.Orientation == undefined)
                        oRotate = 0;
                    else
                        oRotate = exif.Orientation;
                };
                return true;
            },
            success: function (result) {
                if (isUploading) return;
                isUploading = true;
                LeeJSUtils.showMessage("loading", "正在上传图片..");
                setTimeout(function () {
                    $.ajax({
                        url: "ImageManageCore.aspx?ctrl=CreateImageForMD",
                        type: "POST",
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { infoid: albumDatas[currentIndex].infoid, MdIMgID: mdpid, cid: customerID, rotating: oRotate, ImageData: result.clearBase64 },
                        dataType: "text",
                        timeout: 20 * 1000,
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            isUploading = false;
                            LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                        },
                        success: function (msg) {
                            if (msg.indexOf("Error:") > -1)
                                LeeJSUtils.showMessage("error", "上传失败 " + msg.replace("Error:", ""));
                            else {
                                console.log(msg);
                                var data = JSON.parse(msg);
                                var _status = albumDatasForMD[currentIndex].Status;
                                albumDatasForMD[currentIndex] = null;//先释放变量
                                albumDatasForMD[currentIndex] = { infoid: data.infoid, Imgid: data.Imgid, url: "../../" + data.url.replace("/my/", "/"), Status: 0, FilsMsg: "", id: data.id, Remark: "" };
                                var _index = currentIndex;
                                currentIndex = "-1";
                                indexPhoto(_index);
                                if (_status == "-1")
                                    LeeJSUtils.showMessage("warn", "上传成功，等待重新审核！");
                                else
                                    LeeJSUtils.showMessage("successed", "上传成功");
                            }
                            isUploading = false;
                        }
                    });
                }, 50);
            }
        });

        //门店店长上传平面图 liqf
        var map_oRotate = 0, map_isUploading = false;
        $("#chooseImgMap").localResizeIMG({
            width: imgMapWidth,
            quality: 1,
            before: function (that, blob) {
                LeeJSUtils.showMessage("loading", "正在处理图片..");
                var filePath = $("#chooseImgMap").val();
                var extStart = filePath.lastIndexOf(".");
                var ext = filePath.substring(extStart, filePath.length).toUpperCase();

                if (ext != ".BMP" && ext != ".PNG" && ext != ".GIF" && ext != ".JPG" && ext != ".JPEG") {
                    LeeJSUtils.showMessage("warn", "对不起，只能上传图片！");
                    return false;
                }

                var imgfile = that.files[0];
                fr = new FileReader;
                fr.readAsBinaryString(imgfile);
                fr.onloadend = function () {
                    var exif = EXIF.readFromBinaryFile(new BinaryFile(this.result));
                    if (exif.Orientation == undefined)
                        map_oRotate = 0;
                    else
                        map_oRotate = exif.Orientation;
                };
                return true;
            },
            success: function (result) {
                if (map_isUploading) return;
                map_isUploading = true;
                LeeJSUtils.showMessage("loading", "正在上传图片..");
                setTimeout(function () {
                    $.ajax({
                        url: "ImageManageCore.aspx?ctrl=CreateImageForMD",
                        type: "POST",
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { MdIMgID: mdpid, rotating: map_oRotate, ImageData: result.clearBase64, isImgMap: 1 },
                        dataType: "text",
                        timeout: 20 * 1000,
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            map_isUploading = false;
                            LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                        },
                        success: function (msg) {
                            map_isUploading = false;
                            if (msg.indexOf("Error:") > -1)
                                LeeJSUtils.showMessage("error", "上传失败 " + msg.replace("Error:", ""));
                            else {
                                LeeJSUtils.showMessage("successed", "平面图上传成功");
                                setTimeout(TryOpenMap, 200);
                            }                            
                        }
                    });
                }, 50);
            }
        });

        function showAuditInfo(obj) {
            var status = $(obj).attr("data-status");
            if (status == "0") {
                $(obj).attr("data-status", "1");
                $(".fa", $(obj)).attr("class", "fa fa-angle-double-up");
                $("#auditStatus .nopass_info").show();
            } else {
                $(obj).attr("data-status", "0");
                $(".fa", $(obj)).attr("class", "fa fa-angle-double-down");
                $("#auditStatus .nopass_info").hide();
            }
        }

        //门店上传图片后添加备注文字
        function saveRemarkForMD() {
            if (typeof (albumDatasForMD[currentIndex].infoid) == "undefined") {
                LeeJSUtils.showMessage("warn", "对不起，请先上传图片，再添加说明文字！");
            } else {
                $("#txt_upremark").val(decodeURIComponent(albumDatasForMD[currentIndex].Remark));
                $('.upremark_mask').show();
            }
        }

        function saveUpRemark(txts) {
            LeeJSUtils.showMessage("loading", "正在提交数据..");
            if (txts.length > 200) {
                LeeJSUtils.showMessage("warn", "对不起，最多只能输入200个汉字！");
            } else {
                setTimeout(function () {
                    $.ajax({
                        url: "ImageManageCore.aspx?ctrl=SaveImgMDRemark",
                        type: "POST",
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { id: albumDatasForMD[currentIndex].id, remark: encodeURIComponent(txts) },
                        dataType: "text",
                        timeout: 10 * 1000,
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                        },
                        success: function (msg) {
                            if (msg.indexOf("Successed") > -1) {
                                albumDatasForMD[currentIndex].Remark = encodeURIComponent(txts);
                                LeeJSUtils.showMessage("successed", "保存成功");
                                $('.upremark_mask').fadeOut(200);
                            } else
                                LeeJSUtils.showMessage("error", "操作失败 " + msg.replace("Error:", ""));
                        }
                    });
                }, 50);
            }
        }


        //==========小薛的代码从此处开始==========
        //尝试打开店铺平面底图
        function TryOpenMap() {                      
            LeeJSUtils.showMessage("loading", "打开门店平面图...");
            setTimeout(function () {
                //加载平面底图的信息
                $.ajax({
                    url: "SetImgMapCore.ashx?ctrl=GetMapInfo",
                    type: "POST",
                    async: false,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { MdImgID: mdpid },
                    dataType: "text",
                    timeout: 15000,
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                    },
                    success: function (msg) {
                        if (msg == "Self") {
                            //if (typeof (albumDatasForMD[currentIndex].id) == "undefined") {
                            //    LeeJSUtils.showMessage("warn", "店铺没有平面图，你可以在这里先上传一个门店平面图！");
                            //    return;
                            //}                                      
                            if (model == "admin") {
                                LeeJSUtils.showMessage("warn","该门店没有平面图，请通知门店上传后才能使用此功能！");
                            } else {
                                if (confirm("未找到平面图，要马上上传一张平面图吗？")) {
                                    $("#leemask").hide();
                                    $("#chooseImgMap")[0].click();
                                }
                            }
                        } else if (msg.indexOf("Error:") > -1) {
                            msg = msg.substring(6);
                            LeeJSUtils.showMessage("error", msg);
                        } else if (typeof (albumDatasForMD[currentIndex].id) == "undefined") {
                            LeeJSUtils.showMessage("error", "店铺必须先上传拍摄图片，才能定位！");
                        } else
                            //打开地图锚定功能
                            OpenStoreMap();                        
                    }
                });
            }, 100);
        }

        function MapUseCurrentImage() { 
            LeeJSUtils.showMessage("loading", "打开门店平面图...");
            //加载平面底图的信息
            $.ajax({
                url: "SetImgMapCore.ashx?ctrl=MapUseCurrentImage",
                type: "POST",
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                data: { MdMXImgID: albumDatasForMD[currentIndex].id },
                dataType: "text",
                timeout: 15000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                },
                success: function (msg) {
                    if (msg.indexOf("Error:") > -1) {
                        msg = msg.substring(6);
                        LeeJSUtils.showMessage("error", msg);
                        return;
                    }

                    OpenStoreMap();
                }
            });
        }

        function OpenStoreMap() { 
            //打开地图锚定功能
            var frame, page;
            frame = document.createElement('iframe');
            frame.src = "SetImgMapv2.aspx?MdImgID=" + mdpid + "&MdMXImgID=" + albumDatasForMD[currentIndex].id;
            page = document.querySelector('#map_page');
            $("#map_page").empty().append("<a href='javascript:' id='page_close_btn' onclick='close_page()'>返 回</a>");
            page.appendChild(frame);
            frame.onload = function () {
                $("#map_page").removeClass("page-right");
                $("#leemask").hide();
            }
        }

        function close_page() {
            $("#map_page").addClass("page-right");
        }
    </script>
</body>
</html>