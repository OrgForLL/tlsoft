<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>

<!DOCTYPE html>
<script runat="server">
    private string DBConnStr = clsConfig.GetConfigValue("OAConnStr");
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数
    public string AppSystemKey = "", CustomerID = "", CustomerName = "", RoleName = "", SystemID = "3";

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
                wxConfig = clsWXHelper.GetJsApiConfig("1");
                clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "利郎形象管理编辑页[imaginalAdd.aspx]"));
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
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <title>利郎形象管理创建</title>
    <style type="text/css">
        .page {
            padding: 20px 15px 10px 15px;
            color: #fff;
        }

        input[type='text'] {
            -webkit-appearance: none;
            border-radius: 0;
        }

        #index {
            background-color: #222;
            bottom: 40px;
        }

        .title {
            font-size: 16px;
            font-weight: bold;
        }

        #name {
            width: 100%;
            height: 40px;
            line-height: 40px;
            border-radius: 1px;
            font-size: 16px;
            padding: 0 10px;
            margin-top: 5px;
            border: none;
        }

        .photo_list {
            padding: 20px 0;
        }

            .photo_list ul li {
                width: 47%;
                height: 152px;
                text-align: center;
                border: 1px solid #111;
                float: left;
                border-radius: 2px;
                background-color: #333;
                position: relative;
                margin-top: 15px;
            }

                .photo_list ul li .pic {
                    width: 100%;
                    height: 120px;
                    position: relative;
                    border-radius: 2px 2px 0 0 !important;
                }

        .pic .ismust {
            height: 28px;
            background-color: rgba(0,0,0,.6);
            position: absolute;
            left: 0;
            bottom: 0;
            width: 100%;
            color: #fff;
            font-weight: bold;
            line-height: 28px;
            text-align: left;
            padding: 0 5px 0 10px;
        }

        .photo_list ul {
            margin-top: 5px;
        }

            .photo_list ul li:nth-child(2n) {
                margin-left: 6%;
            }

        .back-img {
            background-position: center center;
            background-repeat: no-repeat;
            background-size: cover;
        }

        .photo_list ul li.add {
            background-color: transparent;
            display: flex;
            justify-content: center;
            align-items: center;
        }

            .photo_list ul li.add > img {
                width: 60px;
                height: 60px;
            }

        .icon_wrap {
            width: 40px;
            height: 40px;
            text-align: right;
            padding: 1px 4px 0 0;
            position: absolute;
            top: 0;
            right: 0;
            font-size: 18px;
        }

        .photo_list ul li .del {
            color: #fff;
            position: absolute;
            top: 0;
            right: 0;
            width: 0;
            height: 0;
            border-top: 40px solid rgba(0,0,0,.6);
            border-left: 40px solid transparent;
        }

        .footer {
            text-align: center;
            height: 40px;
            line-height: 40px;
            font-size: 16px;
            font-weight: bold;
        }

        .desc {
            width: 100%;
            height: 32px;
            line-height: 32px;
            font-size: 14px;
            padding: 0 5px;
            border: none;
            border-radius: 0 0 2px 2px !important;
        }

        /*radio style*/
        .switch {
            box-shadow: rgb(255, 255, 255) 0px 0px 0px 0px inset;
            border: 1px solid rgb(223, 223, 223);
            transition: border 0.4s, box-shadow 0.4s;
            background-color: rgb(255, 255, 255);
            width: 36px;
            height: 20px;
            border-radius: 20px;
            line-height: 28px;
            display: inline-block;
            vertical-align: middle;
            cursor: pointer;
            box-sizing: content-box;
            outline: none;
        }

            .switch small {
                width: 20px;
                height: 20px;
                top: 0;
                border-radius: 100%;
                text-align: center;
                display: block;
                background: #fff;
                box-shadow: 0 1px 3px rgba(0,0,0,.4);
                -webkit-transition: all .2s;
                transition: all .2s;
                overflow: hidden;
                color: #000;
                font-size: 12px;
                position: relative;
                -webkit-user-select: none;
                user-select: none;
                -webkit-tap-highlight-color: transparent;
            }

            .switch.open small {
                left: 16px;
                background-color: rgb(255, 255, 255);
            }

            .switch.open {
                box-shadow: rgb(100, 189, 99) 0px 0px 0px 16.6667px inset;
                border: 1px solid rgb(100, 189, 99);
                transition: border 0.4s, box-shadow 0.4s, background-color 1.4s;
                background-color: rgb(100, 189, 99);
            }
    </style>
</head>
<body>
    <div class="wrap-page">
        <div class="page page-not-footer" id="index">
            <p class="title">相册标题</p>
            <input type="text" id="name" placeholder="输入相册标题.." />
            <div class="photo_list">
                <p class="title" style="margin-bottom: -15px;">上传照片</p>
                <ul class="floatfix">
                    <!--
                    <li>
                        <div class="back-img pic" style="background-image: url(../../res/img/storesaler/ccsj1.jpg)">
                            <p class="del"></p>
                            <div class="icon_wrap"><i class="fa fa-trash"></i></div>
                            <div class="ismust">
                                <span>必 传</span>
                                <div class="bd" style="text-align: right; float: right; line-height: 1; margin-top: 3px;">
                                    <input type="checkbox" class="checkbox-switch" id="isactive" style="display: none;" />
                                    <span class="switch" data-open="0"><small></small></span>
                                </div>
                            </div>
                        </div>
                        <input class="desc" type="text" placeholder="图片说明文字.." />
                    </li>
                    <li>
                        <div class="back-img pic" style="background-image: url(../../res/img/storesaler/ccsj5.jpg)">
                            <p class="del"></p>
                            <div class="icon_wrap"><i class="fa fa-trash"></i></div>
                            <div class="ismust">
                                <span>必 传</span>
                                <div class="bd" style="text-align: right; float: right; line-height: 1; margin-top: 3px;">
                                    <input type="checkbox" class="checkbox-switch" id="Checkbox1" style="display: none;" />
                                    <span class="switch" data-open="1"><small></small></span>
                                </div>
                            </div>
                        </div>
                        <input class="desc" type="text" placeholder="图片说明文字.." />
                    </li>
                    -->
                    <li class="add" onclick="chooseImageByWX()">
                        <img src="../../res/img/storesaler/add_icon.png" />
                    </li>
                </ul>
            </div>
        </div>
        <div id="filebox" hidden="hidden">
            <input type="file" id="choosePhoto" />
        </div>
    </div>
    <div class="footer" id="footer" onclick="SaveStoreImg()">保 存</div>

    <script type="text/html" id="item_temp">
        <li data-infoid="{{infoid}}" data-imgid="{{imgid}}">
            <div class="back-img pic" style="background-image: url({{upimg}})">
                <p class="del"></p>
                <div class="icon_wrap"><i class="fa fa-trash"></i></div>
                <div class="ismust">
                    <span>必 传</span>
                    <div class="bd" style="text-align: right; float: right; line-height: 1; margin-top: 3px;">
                        <input type="checkbox" class="checkbox-switch" id="Checkbox2" style="display: none;" />
                        <span class="switch {{if IsMust == "True"}}open{{/if}}" data-open="{{if IsMust == "True"}}1{{else}}0{{/if}}"><small></small></span>
                    </div>
                </div>
            </div>
            <input class="desc" type="text" placeholder="图片说明文字.." value="{{desc}}" />
        </li>
    </script>

    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="http://tm.lilanz.com/oa/api/lilanzAppWVJBridge-0.1.5.min.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/LocalResizeIMG.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/mobileBUGFix.mini.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/binaryajax.min.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/exif.min.js"></script>

    <script type="text/javascript">
        var isUploading = false, albumID = 0;
        var customerID = "<%=CustomerID%>", customerName = "<%=CustomerName%>";
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        $(document).ready(function () {
            wxConfig();
            FastClick.attach(document.getElementById("index"));
            FastClick.attach(document.getElementById("footer"));
            LeeJSUtils.LoadMaskInit();
            BindEvents();
            loadAlbumData();
            llApp.init();
        });


        //微信JSAPI
        function wxConfig() {//微信js 注入
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ["chooseImage", "uploadImage"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                //alert("注入成功");
            });
            wx.error(function (res) {
                //alert("JS注入失败！");
            });
        }

        var localIds = [];
        function chooseImageByWX() {
            if (llApp.isInApp) {
                document.getElementById("choosePhoto").click();
                return;
            }
            wx.chooseImage({
                count: 9, // 默认9
                sizeType: ['original', 'compressed'], // 可以指定是原图还是压缩图，默认二者都有
                sourceType: ['album', 'camera'], // 可以指定来源是相册还是相机，默认二者都有
                success: function (res) {
                    localIds = res.localIds; // 返回选定照片的本地ID列表，localId可以作为img标签的src属性显示图片                    
                    if (localIds.length > 0) {
                        uploadImgByWX(0);
                    }//用户有选择图片
                }
            });
        }

        function uploadImgByWX(xh) {
            LeeJSUtils.showMessage("loading", "正在上传（ " + (xh + 1) + " / " + localIds.length + " ）");
            setTimeout(function () {
                wx.uploadImage({
                    localId: localIds[xh], // 需要上传的图片的本地ID，由chooseImage接口获得
                    isShowProgressTips: 0, // 默认为1，显示进度提示
                    success: function (res) {
                        var serverId = res.serverId; // 返回图片的服务器端ID
                        $.ajax({
                            url: "ImageManageCore.aspx?ctrl=CreateImage",
                            type: "POST",
                            async: false,
                            contentType: "application/x-www-form-urlencoded; charset=utf-8",
                            data: { id: albumID, cid: customerID, mediaid: serverId },
                            dataType: "text",
                            timeout: 20 * 1000,
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                            },
                            success: function (msg) {
                                if (msg.indexOf("Error:") > -1)
                                    LeeJSUtils.showMessage("error", "上传失败 " + msg.replace("Error:", ""));
                                else {
                                    var data = JSON.parse(msg);
                                    var html = template("item_temp", { infoid: data.infoid, imgid: data.Imgid, upimg: "../../" + data.url, desc: "" });
                                    $(".add").before(html);
                                    albumID = data.id;

                                    if (!(xh == localIds.length - 1)) {
                                        uploadImgByWX(xh + 1);
                                    } else
                                        LeeJSUtils.showMessage("successed", "全部上传完成！");
                                }
                            }
                        });
                    }
                });
            }, 150);
        }

        var oRotate = 0;
        $("#choosePhoto").localResizeIMG({
            width: 800,
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
                        url: "ImageManageCore.aspx?ctrl=CreateImage",
                        type: "POST",
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { id: albumID, cid: customerID, rotating: oRotate, ImageData: result.clearBase64 },
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
                                //console.log(msg);                                
                                var data = JSON.parse(msg);
                                var html = template("item_temp", { infoid: data.infoid, imgid: data.Imgid, upimg: "../../" + data.url, desc: "" });
                                $(".add").before(html);
                                albumID = data.id;
                                LeeJSUtils.showMessage("successed", "上传成功");
                            }
                            isUploading = false;
                        }
                    });
                }, 50);
            }
        });

        function BindEvents() {
            $(".photo_list").on("click", ".switch", function () {
                if ($(this).attr("data-open") == "0") {
                    $(this).addClass("open");
                    $(this).attr("data-open", "1");
                } else {
                    $(this).removeClass("open");
                    $(this).attr("data-open", "0");
                }
            });

            //删除
            $(".photo_list").on("click", ".icon_wrap", function () {
                var $this = $(this).parent().parent();
                LeeJSUtils.showMessage("loading", "正在删除..");
                setTimeout(function () {
                    $.ajax({
                        url: "ImageManageCore.aspx?ctrl=DeleteImage",
                        type: "POST",
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { Imgid: $this.attr("data-imgid") },
                        dataType: "text",
                        timeout: 5 * 1000,
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                        },
                        success: function (msg) {
                            if (msg.indexOf("Successed") == 0) {
                                //删除最后一张时主表ID置为0
                                if ($(".photo_list ul li:not(:last-child)").length == 0) {
                                    albumID = 0;
                                    window.history.go(-1);//跳回首页
                                }
                                $("#leemask").hide();
                                $this.remove();
                            } else
                                LeeJSUtils.showMessage("error", "删除失败 " + msg.replace("Error:", ""));
                        }
                    });
                }, 50);
            });
        }

        //保存函数
        function SaveStoreImg() {
            var title = $("#name").val().trim();
            if (title == "") {
                LeeJSUtils.showMessage("warn", "形象册的标题不能为空！");
            } else if ($(".photo_list ul li:not(:last-child)").length == 0) {
                LeeJSUtils.showMessage("warn", "请至少上传一张图片！");
            } else {
                var items = $(".photo_list ul li");
                var list = new Array();
                for (var i = 0; i < items.length - 1; i++) {
                    list.push({ Infoid: items.eq(i).attr("data-infoid"), Imgid: items.eq(i).attr("data-imgid"), remark: $(".desc", items.eq(i)).val().trim(), ismust: $(".switch", items.eq(i)).attr("data-open") });
                }//end for
                var jsondata = { Title: title, List: list };
                LeeJSUtils.showMessage("loading", "正在保存，请稍等..");
                setTimeout(function () {
                    $.ajax({
                        url: "ImageManageCore.aspx?ctrl=SaveStoreImgInfo",
                        type: "POST",
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { id: albumID, cid: customerID, Info: JSON.stringify(jsondata) },
                        dataType: "text",
                        timeout: 20 * 1000,
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                        },
                        success: function (msg) {
                            if (msg.indexOf("Successed") > -1) {
                                LeeJSUtils.showMessage("successed", "保存成功！");
                                window.history.go(-1);
                            }
                            else
                                LeeJSUtils.showMessage("error", "保存失败 " + msg.replace("Error:", ""));
                        }
                    });
                }, 50);
            }
        }

        //加载形象册
        function loadAlbumData() {
            var id = LeeJSUtils.GetQueryParams("id");
            if (id != "" && id != "0" && id != null) {
                LeeJSUtils.showMessage("loading", "正在加载..");
                setTimeout(function () {
                    $.ajax({
                        url: "ImageManageCore.aspx?ctrl=LoadStoreImgInfo",
                        type: "POST",
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { id: id },
                        dataType: "text",
                        timeout: 20 * 1000,
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
                        },
                        success: function (msg) {
                            if (msg.indexOf("Error:") == -1) {
                                var rows = JSON.parse(msg), html = "";
                                albumID = rows.ID;
                                $("#name").val(rows.Title);
                                for (var i = 0; i < rows.List.length; i++) {
                                    var row = rows.List[i];
                                    html += template("item_temp", { infoid: row.infoid, imgid: row.imgid, upimg: "../../" + row.url, desc: row.remark, IsMust: row.IsMust });
                                }//end for
                                $(".add").before(html);
                                $("#leemask").hide();
                            } else
                                LeeJSUtils.showMessage("error", "加载失败 " + msg.replace("Error:", ""));
                        }
                    });
                }, 50);
            }
        }

        //$.ajax({
        //    url: "ImageManageCore.aspx?ctrl=DeleteImage",
        //    type: "POST",
        //    contentType: "application/x-www-form-urlencoded; charset=utf-8",
        //    data: {  },
        //    dataType: "text",
        //    timeout: 20 * 1000,
        //    error: function (XMLHttpRequest, textStatus, errorThrown) {
        //        LeeJSUtils.showMessage("error", "您的网络出问题啦..[" + XMLHttpRequest.statusText + "]");
        //    },
        //    success: function (msg) {

        //    }
        //});
    </script>
</body>
</html>
