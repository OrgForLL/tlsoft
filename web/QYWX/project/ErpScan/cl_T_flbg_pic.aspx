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

            if (clsWXHelper.CheckQYUserAuth(true))
            {
                //鉴权成功之后，获取 系统身份SystemKey
                string SystemID = "1";
                SystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
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
            width: 100%;
            height: 100%;
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
		  0%, 40%, 100% { -webkit-transform: scaleY(0.4) } 
		  20% { -webkit-transform: scaleY(1.0) }
		}
		 
		@keyframes stretchdelay {
		  0%, 40%, 100% {
		    transform: scaleY(0.4);
		    -webkit-transform: scaleY(0.4);
		  }  20% {
		    transform: scaleY(1.0);
		    -webkit-transform: scaleY(1.0);
		  }
		}
		#bg{
			    width: 100%;
			    height: 100%;
			    top: 0%;
                right:0%;
			    position: absolute;
			    background-color: black;
			    opacity: 0.2;
                z-index:1000;
		}
        .ui-loader-default{ display:none}
        .ui-mobile-viewport{ border:none;}
        .ui-page {padding: 0; margin: 0; outline: 0}
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
                alert("鉴权不成功");
                document.getElementById("ctrlScan").style.display = "none";
            } else {
                llApp.init();
                jsConfig();
            }



            /***************WEBUPLOADER*******************/
            $list = $(".filelist");
            var uploader = WebUploader.create({
                // 选完文件后，是否自动上传。
                auto: false,

                // swf文件路径
                swf: window.location.host + '../../res/js/Uploader.swf',

                // 文件接收服务端。
                server: 'cl_T_flbg_pic_tm.ashx',

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
                    
                    alert("上传成功");

                }
            });
            $("#save").click(function () {
                var djh = $("#djh").val()
                if (djh != "" && uploader.getFiles().length > 0) {
                    uploader.options.formData = { "djh": djh.toString() };
                    uploader.upload();
                    $("#bg").show();
                    $("#spinner").show();
                    if (uploader.getFiles('error').length > 0) {
                        uploader.retry();
                    }
                } else if (djh == "") {
                    alert("单据号为空,不能上传图片");
                } else if (uploader.getFiles().length == 0) {
                    alert("图片为空,不能进行上传");
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
</script>
</head>
<body>
    <div class="container">
        <div class="row" hidden>
            <div class="col-xs-12 ">
                <button id="ctrlScan" class="btn btn-primary btn-block" onclick="scan()">扫描</button>
            </div>
        </div>
        <div class="row" hidden>
            <div class="col-xs-3">
                <label>材料号</label>
            </div>
            <div class="col-xs-9">
                <input type="text" class="form-control" id="clh">
            </div>
        </div>
        <div class="row" style="padding-top: 5px;">
            <div class="col-xs-3">
                <label>单据号</label>
            </div>
            <div class="col-xs-9">
                <input type="text" class="form-control" id="djh" placeholder="请手动输入单据号">
            </div>
        </div>
        <!--dom结构部分-->

        <div id="uploader" style="padding-top: 5px;">
            <!--用来存放item-->
            <div class="filelist uploader-list"></div>
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

