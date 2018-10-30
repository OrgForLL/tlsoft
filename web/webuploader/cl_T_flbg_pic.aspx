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
        //string OAConnStr = clsConfig.GetConfigValue("OAConnStr");

        //string SystemKey = "";
        //string ctrl = Convert.ToString(Request.Params["ctrl"]);
        //if (ctrl == "" || ctrl == null)
        //{

        //    if (clsWXHelper.CheckQYUserAuth(true))
        //    {
        //        //鉴权成功之后，获取 系统身份SystemKey
        //        string SystemID = "1";
        //        SystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
        //    }

        //    WxHelper cs = new WxHelper();

        //    List<string> config = clsWXHelper.GetJsApiConfig("1");
        //    appIdVal.Value = config[0];
        //    timestampVal.Value = config[1];
        //    nonceStrVal.Value = config[2];
        //    signatureVal.Value = config[3];
        //    useridVal.Value = SystemKey;
        //}
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <title></title>
    
    
    <script src="../Scripts/webuploader/jquery.js"></script>
    <script src="../Scripts/webuploader/webuploader.js"></script>
    <script src="../Scripts/webuploader/jquery.mobile-1.4.5.js"></script>
   
    <link href="../mycss/webuploader/webuploader.css" rel="stylesheet" />
    <link href="../mycss/webuploader/bootstrap.css" rel="stylesheet" />
   
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
    </style>
    <script type="text/javascript">
        var appIdVal, timestampVal, nonceStrVal, signatureVal;
        $(document).ready(function () {
            //WeiXin JSSDK
            //appIdVal = document.getElementById("appIdVal").value;
            //timestampVal = document.getElementById("timestampVal").value;
            //nonceStrVal = document.getElementById("nonceStrVal").value;
            //signatureVal = document.getElementById("signatureVal").value;
            ////alert(appIdVal);   

            //if (document.getElementById("useridVal").value == "" || document.getElementById("useridVal").value == "0") {
            //    //用户不可用
            //    alert("鉴权不成功");
            //    document.getElementById("ctrlScan").style.display = "none";
            //} else {
            //    llApp.init();
            //    jsConfig();
            //}



            /***************WEBUPLOADER*******************/
            $list = $(".filelist");
            var uploader = WebUploader.create({
                // 选完文件后，是否自动上传。
                auto: false,

                // swf文件路径
                swf: window.location.host + '../mycss/webuploader/Uploader.swf',

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
                            '<p class="progress"><span></span></p>'+
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
            // 文件上传过程中创建进度条实时显示。
            uploader.on('uploadProgress', function (file, percentage) {
                var $li = $('#' + file.id),
                    $percent = $li.find('.progress span');

                // 避免重复创建
                if (!$percent.length) {
                    $percent = $('<p class="progress"><span></span></p>')
                            .appendTo($li)
                            .find('span');
                }

                $percent.css('width', percentage * 100 + '%');
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
            uploader.on('uploadError', function (file,reason,tr) {
                var $li = $('#' + file.id),
                    $error = $li.find('p.error');

                // 避免重复创建
                if (!$error.length) {
                    $error = $('<p class="error"></p>').appendTo($li);
                }
                $error.text(tr.errorMsg);
                alert(tr.errorMsg);
            });

            // 完成上传完了，成功或者失败，先删除进度条。
            uploader.on('uploadComplete', function (file) {
                $('#' + file.id).find('.progress').remove();
            });
            //当所有文件上传结束时触发。
            uploader.on('uploadFinished', function (file) {
                if (uploader.getFiles('error').length == 0) {
                    uploader.reset();
                    $(".uploader-list").children().remove();
                    alert("上传成功");
                }
            });
            $("#save").click(function () {
                var djh = $("#djh").val()
                if (djh != "" && uploader.getFiles().length>0) {
                    uploader.options.formData = { "djh": djh.toString() };
                    uploader.upload();
                    if (uploader.getFiles('error').length>0) {
                        uploader.retry();
                    }
                } else if (djh == "") {
                    alert("单据号为空,不能上传图片");
                } else if (uploader.getFiles().length == 0){
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
        window.onload = function () {
            var str = "  <img src=\"cl_cx_mlbjinfo_image.aspx?src=http://192.168.35.104:8080/file/download/downloadFile.do?filePath=fabric/1050390/fabric54301/canvas_COL_P500.jpg\" onclick=\"test()\" />";
            $("#test").html(str);
        }
        function test() {
            alert(1)
        }


    </script>
    <style type="text/css">
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
    </style>
</head>
<body>
    <div class="container">
        <div class="row" hidden>
            <div class="col-xs-12 ">
                <button class="btn btn-primary btn-block" onclick="scan()">扫描</button>
                
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
              <div id="test"></div>
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
    </div>
    <input type="hidden" runat="server" id="appIdVal" />
    <input type="hidden" runat="server" id="timestampVal" />
    <input type="hidden" runat="server" id="nonceStrVal" />
    <input type="hidden" runat="server" id="signatureVal" />
    <input type="hidden" runat="server" id="useridVal" />
</body>
</html>
