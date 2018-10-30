<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        string url = Request.Url.ToString().ToLower();//转为小写,indexOf 和Replace 对大小写都是敏感的   
        string SystemKey = "";
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        if (ctrl == "" || ctrl == null)
        {
            if (Request.Url.AbsoluteUri.IndexOf("192.168.35.231") ==-1)
            {
                if (clsWXHelper.CheckQYUserAuth(true))
                {
                    //鉴权成功之后，获取 系统身份SystemKey
                    string SystemID = "1";
                    SystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));    
                }
            }
            WxHelper cs = new WxHelper();
            List<string> config = clsWXHelper.GetJsApiConfig("1");
            appIdVal.Value = config[0];
            timestampVal.Value = config[1];
            nonceStrVal.Value = config[2];
            signatureVal.Value = config[3];
            useridVal.Value = SystemKey;
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <title></title>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="../../res/js/webuploader.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.mobile-1.4.5.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link rel="Stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="Stylesheet" href="../../res/css/ErpScan/bootstrap.css" />
    <link rel="Stylesheet" href="../../res/css/font-awesome.min.css" />
    <link rel="Stylesheet" href="../../res/css/ErpScan/webuploader.css" />
    <link href="../../res/css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>
    <style type="text/css">
        body {
            font-size: 14px;
            line-height: 20px;
        }

        .row {
            padding-top: 10px;
        }

            .row .col-xs-3 {
                padding-top: 6px;
            }

                .row .col-xs-3 label {
                    float: right;
                }

        .row {
            padding-top: 10px;
        }

        th {
            text-align: center;
            vertical-align: middle;
        }

        td {
            word-break: break-all;
            text-align: center;
            vertical-align: middle;
        }

        .checkbox {
            margin-top: -3px;
        }

        [type=checkbox] {
            width: 20px;
            height: 20px;
        }

        .checkbox label {
            margin-top: 7px;
            font-size: 18px;
        }

        .spinner {
            margin: auto;
            width: 20%;
            height: 11%;
            position: absolute;
            top: 10%;
            right: 35%;
            z-index: 100000;
        }

            .spinner > div {
                background-color: deepskyblue;
                height: 100%;
                width: 9px;
                display: inline-block;
                -webkit-animation: stretchdelay 1.2s infinite ease-in-out;
                animation: stretchdelay 1.2s infinite ease-in-out;
            }

            .spinner .rect2 {
                -webkit-animation-delay: -1.1s;
                animation-delay: -1.1s;
            }

            .spinner .rect3 {
                -webkit-animation-delay: -1.0s;
                animation-delay: -1.0s;
            }

            .spinner .rect4 {
                -webkit-animation-delay: -0.9s;
                animation-delay: -0.9s;
            }

            .spinner .rect5 {
                -webkit-animation-delay: -0.8s;
                animation-delay: -0.8s;
            }

        @-webkit-keyframes stretchdelay {
            0%, 40%, 100% {
                -webkit-transform: scaleY(0.4);
            }

            20% {
                -webkit-transform: scaleY(1.0);
            }
        }

        @keyframes stretchdelay {
            0%, 40%, 100% {
                transform: scaleY(0.4);
                -webkit-transform: scaleY(0.4);
            }

            20% {
                transform: scaleY(1.0);
                -webkit-transform: scaleY(1.0);
            }
        }

        #bg {
            width: 100%;
            height: 100%;
            top: 0%;
            right: 0%;
            position: absolute;
            background-color: black;
            opacity: 0.2;
            z-index: 1000;
        }

        input[type=checkbox] {
            -webkit-appearance: checkbox;
        }

        .list-group-item-text {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            padding-top: 3px;
        }

        .ui-loader-default {
            display: none;
        }

        .ui-mobile-viewport {
            border: none;
        }

        .ui-page {
            padding: 0;
            margin: 0;
            outline: 0;
        }

        #uploader .filelist li .success {
            display: block;
            position: absolute;
            left: 0;
            bottom: 0;
            height: 40px;
            width: 92%;
            z-index: 200;
        }
    </style>
    <script type="text/javascript">
        var appIdVal, timestampVal, nonceStrVal, signatureVal;
        var uploader;
        var urlPath = "http://webt.lilang.com:9001/";
        $(document).ready(function () {
            $("#bg").hide();
            $("#spinner").hide();

            //WeiXin JSSDK
            appIdVal = document.getElementById("appIdVal").value;
            timestampVal = document.getElementById("timestampVal").value;
            nonceStrVal = document.getElementById("nonceStrVal").value;
            signatureVal = document.getElementById("signatureVal").value;
            //alert(appIdVal);   

            if (document.getElementById("useridVal").value == "" || document.getElementById("useridVal").value == "0") {
                //用户不可用                
                if (window.document.URL.indexOf("192.168.35.231") < 0) {
                    alert("鉴权不成功");
                    document.getElementById("ctrlScan1").style.display = "none";
                    document.getElementById("ctrlScan2").style.display = "none";
                    document.getElementById("uploader").style.display = "none";
                    document.getElementById("save").style.display = "none";
                } else {
                    urlPath = "http://192.168.35.231/";
                }

            } else {
                llApp.init();
                jsConfig();
            }

            /***************WEBUPLOADER*******************/
            $list = $(".filelist");
            uploader = WebUploader.create({
                // 选完文件后，是否自动上传。
                auto: false,

                // swf文件路径
                swf: window.location.host + '../../res/js/Uploader.swf',

                // 文件接收服务端。
                server: 'cl_T_mlbg_pic_tm.ashx',

                // 选择文件的按钮。可选。
                // 内部根据当前运行是创建，可能是input元素，也可能是flash.
                pick: {
                    id: '#filePicker',// 指定选择文件的按钮容器
                    multiple: true//同时选择多个文件
                },
                // 只允许选择图片文件。
                accept: {
                    title: 'Images',
                    extensions: 'gif,jpg,jpeg,bmp,png',
                    mimeTypes: 'image/*'
                },
                thumb: {
                    width: 110,
                    height: 110,

                    // 图片质量，只有type为`image/jpeg`的时候才有效。
                    quality: 70,

                    // 是否允许放大，如果想要生成小图的时候不失真，此选项应该设置为false.
                    allowMagnify: true,

                    // 是否允许裁剪。
                    crop: true,
                },

            });

            // 当有文件添加进来的时候
            uploader.on('fileQueued', function (file) {

                var $li = $(
                        '<li id=' + file.id + '>' +
                            '<p class="title">' + file.name + '</p>' +
                            '<p class="imgWrap">' +
                                '<img>' +
                            '</p>' +
                            '<p class="progress"><span></span></p>' +
                        '</li>'
                        ),
                    $img = $li.find('img');

                $("#" + file.id).live("taphold", function () {
                    var file = uploader.getFile(this.id);
                    uploader.removeFile(file, true);
                    this.remove();
                });
                // $list为容器jQuery实例
                $list.append($li);

                // 创建缩略图
                // 如果为非图片文件，可以不用调用此方法。
                // thumbnailWidth x thumbnailHeight 为 100 x 100
                uploader.makeThumb(file, function (error, src) {
                    if (error) {
                        $img.replaceWith('<span>不能预览</span>');
                        return;
                    }
                    $img.attr('src', src);
                }, 100, 100);
            });
            uploader.on("uploadAccept", function (file, data) {
                if (data._raw == "success")
                    return true;
                file.errorMsg = data._raw;
                return false;
            });
            // 文件上传成功，给item添加成功class, 用样式标记上传成功。
            uploader.on('uploadSuccess', function (file) {
                var $li = $('#' + file.id),
                    $success = $li.find('div.success');
                // 避免重复创建
                if (!$success.length) {
                    $success = $('<div class="success"></div>').appendTo($li);
                }
                $error = $li.find('p.error');
                if ($error.length) {
                    $error.remove();
                }
            });

            // 文件上传失败，显示上传出错。
            uploader.on('uploadError', function (file, reason, tr) {
                var $li = $('#' + file.id),
                    $error = $li.find('p.error');

                // 避免重复创建
                if (!$error.length) {
                    $error = $('<p class="error"></p>').appendTo($li);
                }
                $error.text(tr.errorMsg);
            });

            // 完成上传完了，成功或者失败，先删除进度条。
            uploader.on('uploadComplete', function (file) {
                $('#' + file.id).find('.progress').remove();
            });
            //当所有文件上传结束时触发。
            uploader.on('uploadFinished', function (file) {
                $("#bg").hide();
                $("#spinner").hide();
                if (uploader.getFiles('error').length == 0) {
                    uploader.reset();
                    $(".uploader-list").children().remove();
                    $("#list").children().remove();
                    $("#hisfilelist").html('');
                    alert("上传成功");

                }
            });
            $("#save").click(function () {
                var idList = new Array();
                $.each($("#list>div"), function (i, n) {
                    if ($(".ck", n).eq(0).is(":checked")) {
                        idList.push(n.attributes["djid"].value);
                    }
                });
                if (idList.length == 0) {
                    alert("未进行扫描不能保存图片")
                } else {
                    if (uploader.getFiles().length > 0) {
                        uploader.options.formData = { "djhids": idList.join(","), "action": "picUpload", "tmid": $("#list").attr("tmid"), "tmlx": $("#list").attr("tmlx") };
                        uploader.upload();
                        $("#bg").show();
                        $("#spinner").show();
                        if (uploader.getFiles('error').length > 0) {
                            uploader.retry();
                        }
                    } else if (uploader.getFiles().length == 0) {
                        alert("图片为空,不能进行上传");
                    }
                }
            });

        });

        /********************签名**********************/
        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['scanQRCode'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                //alert("ready");
                //scan();
            });
            wx.error(function (res) {
                alert(allPrpos(res));
                alert("JS注入失败！");
            });
        }
        function scan(tag) {
            
            //isInApp = false;
            if (isInApp) {
               
                if (tag == 2) {
                    $("#uploader").css("display", "none");
                    $("#save").css("display", "none");
                } else {
                    $("#uploader").css("display", "block");
                    $("#save").css("display", "block");
                }
                
                llApp.scanQRCode(function (result) {                    
                    getBQInfo(result, tag);
                });
            } else {
                wx.scanQRCode({
                    desc: 'scanQRCode desc',
                    needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                    scanType: ["qrCode", "barCode"], // 可以指定扫二维码还是一维码，默认二者都有
                    success: function (res) {                        
                        if (res.resultStr.split(",").length > 1) {
                            getBQInfo(res.resultStr.split(",")[1], tag); // 当needResult 为 1 时，扫码返回的结果 
                        } else {
                            getBQInfo(res.resultStr, tag); // 当needResult 为 1 时，扫码返回的结果 
                        }
                    }
                });
            }
        };
        //条码获取的信息
        //var xx;
        //var tm;
        //var djhs = "";
        //获取条码对应信息
        function getBQInfo(result, tag) {
            $("#bg").show();
            $("#spinner").show();
            uploader.reset();
            $(".uploader-list").children().remove();
            $("#list").children().remove();
            $("#hisfilelist").html('');
            var tm = result;
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "cl_T_mlbg_pic_tm.ashx",
                data: { action: "getmsg", tm: result, tag: tag },
                success: function (msg) {
                    var o = JSON.parse(msg);
                    if (o.type != "SUCCESS") {
                        alert(o.msg);
                    } else {
                        var str = "";
                        var msg = JSON.parse(o.msg);
                        var xx = msg.bjd;
                        var bjd_img = msg.bjd_img;
                        var totalUrl = msg.totalURL;
                        if (totalUrl[0].totalURLAddress != undefined) {
                            var imgArr = totalUrl[0].totalURLAddress.split(",");
                            var imgtotal = "";
                            for (var i = 0; i < imgArr.length; i++) {
                                if (imgArr[i].length > 0) {
                                    imgtotal += "<li>" +
                                            "<p class='imgWrap'>" +
                                            " <img src='" + urlPath + imgArr[i] + "' onclick=\"oWebView('" + urlPath + imgArr[i] + "')\"/>" +
                                            "</p>" +
                                            "<div class='success'></div>" +
                                            "</li>";
                                }
                            }

                            $("#hisfilelist").html(imgtotal);
                        }
                        for (var i = 0; i < xx.length; i++) {
                            str += "<div  class='list-group-item' djid=" + xx[i].id2222 + ">" +
                                      "<input class='ck' type='checkbox' name='xz' />" +
                                      "<div class='list-group-item-text whide'  ><strong>单据号:</strong>" + xx[i].djh + "<strong>&nbsp数量:</strong>" + xx[i].sl;
                            if (xx[i].syid == '' || xx[i].djid == '') {
                                str += "<strong style='float:right'>报告编号:<i>" + xx[i].bgbh + "</i></strong></div>";
                            } else {
                                str += "<strong style='float:right'>报告编号:<a target='_blank' href=\"" + urlPath + "tl_sc/1/sc_ml_jy.aspx?djid=" + xx[i].DJID + "&syid=" + xx[i].syid + "&tzid=1&flowid=696&tag=mobile\">" + xx[i].bgbh + "</a></strong></div>";
                            }

                            str += "<div class='list-group-item-text whide'><strong>报告日期:</strong>" + xx[i].bgrq + "</div>" +
                                 "<div class='list-group-item-text whide'><strong>供应商:</strong>" + xx[i].khmc + "</div>" +
                                 "<div class='list-group-item-text whide'><strong>材料编号:</strong>" + xx[i].chdm + "</div>" +
                                 "<div class='list-group-item-text whide'><strong>材料名称:</strong>" + xx[i].chmc + "</div>" +
                                 "<div class='list-group-item-text whide'><strong>货号:</strong>" + xx[i].scddbh + "</div>" +
                                 "<div class='list-group-item-text whide'><strong>成衣工厂:</strong>" + xx[i].jgckhmc + "</div>" +
                                 "<div class='list-group-item-text whide'><strong>码单:</strong><span style='color:blue' onclick='openmd(\"" + xx[i].mykey + "\")'>" + xx[i].mdms + "</span></div>" +
                                 "<div class='list-group-item-text whide'><strong>图片:</strong>";
                            for (var z = 0; z < bjd_img.length; z++) {
                                if (bjd_img[z].djh == xx[i].djh) {
                                    str += "<a href=\"" + urlPath + bjd_img[z].urladdress + "\">" + (bjd_img[z].filename == null || bjd_img[z].filename == "" ? "[图片]&nbsp;" : "["+bjd_img[z].filename+"]&nbsp;") + "</a>"
                                }
                            }
                            str += "</div></div>";
                        }
                        $("#list").html(str);
                        $("#list").attr("tmid", tm.split("$")[0]);
                        $("#list").attr("tmlx", tm.split("$")[1]);
                    }
                    $("#bg").hide();
                    $("#spinner").hide();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $("#bg").hide();
                    $("#spinner").hide();
                    alert("result: 'netError', textStatus: " + textStatus + ", status: " + XMLHttpRequest.status);
                }
            });
        }

        function openmd(key) {
            oWebView("http://tm.lilanz.com/oa/project/ErpScan/cl_T_mlbg_pic_md.aspx?mykey=" + key);
        }
        //打开WebView
        function oWebView(url) {
            llApp.openWebView(url);
        }
    </script>
</head>
<body>
    <div class="container">
        <div class="row">
            <div class="col-xs-12 ">
                <button id="ctrlScan1" class="btn btn-primary btn-block" onclick="scan(1)">扫描(上传图片无报告)</button>
            </div>
        </div>
        <div class="row">
            <div class="col-xs-12 ">
                <button id="ctrlScan2" class="btn btn-primary btn-block" onclick="scan(2)">扫描(有报告)</button>
                
            </div>
        </div>
        <div class="row" style="padding-top: 5px;">
            <div class="col-xs-12 ">
                <div class="list-group" id="list">
                </div>
            </div>
        </div>
        <div class="row" style="padding-top: 5px;">
            <div class="col-xs-12 ">
                <div id="hisfilelist">
                </div>
            </div>
        </div>
        <div id="uploader" style="padding-top: 5px;">
            <!--用来存放item-->
            <div class="filelist uploader-list">
            </div>
            <div id="filePicker">选择图片</div>
        </div>

        <div class="row">
            <div class="col-xs-12">
                <button class="btn btn-primary btn-block" id="save">保存图片</button>
            </div>
        </div>
        <div id="bg"></div>
        <div class="spinner" id="spinner">
            <div class="rect1"></div>
            <div class="rect2"></div>
            <div class="rect3"></div>
            <div class="rect4"></div>
            <div class="rect5"></div>
        </div>
    </div>
    <input type="hidden" runat="server" id="appIdVal" />
    <input type="hidden" runat="server" id="timestampVal" />
    <input type="hidden" runat="server" id="nonceStrVal" />
    <input type="hidden" runat="server" id="signatureVal" />
    <input type="hidden" runat="server" id="useridVal" />
</body>
</html>

