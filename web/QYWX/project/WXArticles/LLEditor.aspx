﻿<%@ Page Language="C#" ValidateRequest="false" %>

<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server">
    public string UNAME = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        string UID = Convert.ToString(Session["AR_UID"]);
        UNAME = Convert.ToString(Session["AR_UNAME"]);
        if (UID == "" || UID == "0" || UID == null)
        {
            Response.Redirect("Login.html");
            Response.End();
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <title>利郎简约图文编辑器</title>
    <link rel="stylesheet" href="../../res/css/wangEditor.min.css" />
    <link rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link rel="icon" href="/favicon.ico" />
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        ul, ol {
            list-style: none;
        }

        a {
            text-decoration: none;
            color: #999;
        }

        input, textarea, select {
            font-size: 100%;
            color: #333;
            font-family: "Microsoft Yahei",Arial,Helvetica,sans-serif;
        }

        body {
            font: 14px/1.125;
            font-family: "Microsoft Yahei",Arial,Helvetica,sans-serif;
            background-color: #edecec;
            color: #5e5e5e;
        }

        .header {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 50px;
            box-shadow: 0 2px 5px 0 rgba(0, 0, 0, 0.16), 0 2px 10px 0 rgba(0, 0, 0, 0.12);
            padding: 0 20px;
            background-color: #322e2d;
            z-index: 100;
        }

        .header-inner {
            color: #fff;
            font-weight: bold;
            line-height: 50px;
            width: 100%;
        }

            .header-inner .title {
                float: left;
                font-size: 16px;
                letter-spacing: 1px;
            }

            .header-inner .infos {
                float: right;
                font-weight: 400;
                margin-right: 30px;
                font-size: 14px;
            }

        .floatfix {
            content: '';
            display: table;
            clear: both;
        }

        .edit-content {
            padding-top: 90px;
            padding-bottom: 36px;
            position: relative;
            z-index: 10;
        }

        .wangEditor-fullscreen {
            top: 55px;
        }

        .container {
            width: 1000px;
            box-sizing: border-box;
            background-color: #fff;
            box-shadow: 0 1px 1px rgba(0, 0, 0, 0.15);
            margin: 0 auto;
            padding: 10px;
            overflow: hidden;
        }

        .left-area {
            width: 760px;
            box-sizing: border-box;
            float: left;
            border-right: 1px solid #edecec;
            padding-right: 10px;
        }

        .right-area {
            width: 220px;
            box-sizing: border-box;
            float: left;
            padding: 0 10px;
        }

            .right-area p {
                line-height: 25px;
                font-size: 14px;
                color: #333;
            }

            .right-area .title {
                text-align: center;
                margin-bottom: 15px;
                /*color: #47a04b;*/
                color: #4a5d87;
                font-size: 16px;
                font-weight: bold;
                border-bottom: 2px solid #4a5d87;
                padding-bottom: 4px;
            }

        .frm_input {
            margin: 5px 0;
            width: 100%;
            background-color: transparent;
            border: 0;
            outline: 0;
            line-height: 1.4;
            padding: 0 10px;
            box-sizing: border-box;
        }

        .js_title {
            font-size: 20px;
        }

        .js_desc {
            margin: 15px 0 5px 0;
            color: #999;
            font-size: 15px;
        }

        .js_author {
            color: #999;
            font-size: 15px;
        }

        .js_link {
            margin-bottom: 10px;
            color: #44b549;
        }

        .wangEditor-container {
            border-color: #eddcdc;
        }

        #wangEditor-container p {
            line-height: 1.4;
        }

        .btns {
            text-align: right;
            margin: 15px 0 5px 0;
            position: relative;
        }

        .cache-save {
            position: absolute;
            height: 30px;
            line-height: 30px;
            top: 0;
            left: 0;
            font-size: 13px;
            color: #269d2b;
        }

        #btn-save, #btn-upthumb {
            background-color: #44b549;
            color: #fff;
            font-weight: bold;
            font-size: 14px;
            width: 80px;
            height: 30px;
            display: inline-block;
            text-align: center;
            line-height: 30px;
            border-radius: 2px;
        }

        #btn-upthumb {
            width: auto;
            padding: 0 10px;
            background-color: #f0ad4e;
            margin-right: 8px;
        }
        /*mask style*/
        .mask {
            color: #fff;
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1001;
            font-size: 1em;
            text-align: center;
            background-color: rgba(0,0,0,0.5);
            display: none;
        }

            .mask i {
                padding: 0;
            }

        .loader {
            background-color: rgba(39, 43, 46, 0.9);
            padding: 10px 15px;
            border-radius: 5px;
            max-height: 200px;
            overflow: hidden;
            min-width: 80px;
        }

        #loadtext {
            margin-top: 8px;
            font-weight: bold;
            font-size: 0.9em;
        }

        .center-translate {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%,-50%);
            -webkit-transform: translate(-50%,-50%);
        }

        i {
            padding-right: 8px;
        }

        .footer {
            position: fixed;
            left: 0;
            bottom: 0;
            width: 100%;
            height: 34px;
            text-align: center;
            color: #999;
            font-size: 12px;
            line-height: 34px;
            z-index: 5;
        }

        [data-loader='circle-side'] {
            position: relative;
            width: 28px;
            height: 28px;
            -webkit-animation: circle infinite .75s linear;
            animation: circle infinite .75s linear;
            border: 4px solid #fff;
            border-top-color: rgba(0, 0, 0, .2);
            border-right-color: rgba(0, 0, 0, .2);
            border-bottom-color: rgba(0, 0, 0, .2);
            border-radius: 100%;
            margin: 0 auto;
        }

        @-webkit-keyframes circle {
            0% {
                -webkit-transform: rotate(0);
                transform: rotate(0);
            }

            100% {
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        @keyframes circle {
            0% {
                -webkit-transform: rotate(0);
                transform: rotate(0);
            }

            100% {
                -webkit-transform: rotate(360deg);
                transform: rotate(360deg);
            }
        }

        .current-group {
            border-left:2px solid #cfd2d6;
            font-size:14px;
        }
        .current-group, .group-list {
            position:absolute;
            top:5px;
            right:5px;
            line-height:1.4;
            width:140px;            
            text-align:center;
            cursor: pointer;
            color:#757e91;
        }
        .group-list {
            top:30px;
            z-index:1000;
            max-height:280px;
            overflow-y: auto;  
            display:none;
            border:1px solid #eceef1;
            border-top:none;                      
        }
            .group-list li {
                height: 34px;
                line-height: 34px;
                background-color: #fff;
                color: #757e91;                           
                border-bottom: 1px solid #eceef1;                
            }
                .group-list li:hover {
                    background-color:#44b549;
                    color:#fff;
                }
    </style>
</head>
<body>
    <div class="header">
        <ul class="header-inner floatfix">
            <li class="title"><i class="fa fa-file-text"></i>利郎简约图文编辑器 V2.2</li>
            <li class="infos"><span id="username"><i class="fa fa-user"></i><%=UNAME %></span>，您好！<a href="javascript:;" onclick="logout();" style="color: #fff;"> 退出</a></li>
        </ul>
    </div>
    <div class="edit-content">
        <div class="container floatfix">
            <div class="left-area">
                <input id="title" type="text" placeholder="请在这里输入标题" class="frm_input js_title" name="title" max-length="64" />
                <input id="desc" type="text" placeholder="请输入文章摘要，主要用于列表上显示" class="frm_input js_desc" name="desc" max-length="100" />
                <div style="position:relative;">
                    <input id="author" type="text" placeholder="请输入作者" class="frm_input js_author" name="author" max-length="8" value="<%=UNAME %>" />
                    <div class="current-group" currentid="">-请选择分组-</div>
                    <ul class="group-list">                        
                    </ul>
                </div>
                <input id="link" type="text" placeholder="外链地址 如http://www.lilanz.com" class="frm_input js_link" name="link" max-length="120" />
                <div id="wangEditor-container" style="height: 400px;">
                </div>
                <div class="btns">
                    <!--<p class="cache-save">自动临时缓存于2016-5-7 12:00:30</p>-->
                    <a href="javascript:;" id="btn-upthumb"><i class="fa fa-file-photo-o"></i>上传封面</a>
                    <a href="javascript:;" id="btn-save"><i class="fa fa-send"></i>保 存</a>
                    <input type="file" accept="image/*" style="display: none;" id="picSrc" />
                </div>
                <!--<div class="wangEditor-container" style="border:none;">
                    <div id="preview-area" class="wangEditor-txt"></div>
                </div>-->
            </div>
            <div class="right-area">
                <div class="tips">
                    <p class="title">使用说明</p>
                    <p>1、请使用ERP系统账号登陆使用；</p>
                    <p>2、如果填写了外链地址，那么显示文章内容时将直接进行跳转，因此有填写外链时文章内容可以放空；</p>
                    <p>3、上传的图片大小不能超过5M！</p>
                    <p>4、后期将增加定时自动保存功能；</p>
                </div>
            </div>
        </div>
    </div>
    <div class="footer">&copy;2016 利郎信息技术部 提供技术支持</div>
    <!--MASK提示层-->
    <div class="mask">
        <div class="loader center-translate">
            <div style="font-size: 1.1em;">
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
                <div class="slice">
                    <div data-loader="circle-side"></div>
                </div>
            </div>
            <p id="loadtext">正在加载...</p>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/WXArticles/ajaxupload.js"></script>
    <script type="text/javascript" src="../../res/js/wangEditor.min.js" charset="utf-8"></script>
    <script type="text/javascript">
        var AID = "", thumbid = 0;
        var editor = new wangEditor('wangEditor-container');
        editor.config.menus = [
       'source',
        '|',
        'bold',
        'underline',
        'italic',
        'strikethrough',
        'eraser',
        'forecolor',
        'bgcolor',
        '|',
        'quote',
        'fontfamily',
        'fontsize',
        'head',
        'alignleft',
        'aligncenter',
        'alignright',
        '|',
        'link',
        'unlink',
        'table',
        'img',
        '|',
        'undo',
        'redo',
        'fullscreen'
        ];
        editor.config.uploadImgUrl = 'LLEditorCore.aspx';
        editor.config.uploadParams = {
            ctrl: "UploadImg"
        };
        editor.create();

        $(document).ready(function () {
            var button = $("#btn-upthumb");
            var filename = "";
            new AjaxUpload(button, {
                action: 'LLEditorCore.aspx?ctrl=UploadImg&uplx=thumb',
                name: 'myfile',
                onSubmit: function (file, ext) {
                    this.setData({ "filename": file });
                    if (!(ext && /^(jpg|jpeg|JPG|JPEG|png|PNG|bmp|BMP|)$/.test(ext))) {
                        alert("图片格式不正确！");
                        return false;
                    }
                    showMessage("loading", "正在上传封面");
                },
                onComplete: function (file, response) {
                    //file 本地文件名称，response 服务器端传回的信息                    
                    this.enable();

                    if (response == '-1') {
                        alert('您上传的文件太大啦!请不要超过5MB！');
                    } else if (response.indexOf("error|") > -1) {
                        showMessage("error", "上传失败 " + response);
                        button.html("<i class='fa fa-file-photo-o'></i>上传封面");
                    } else {
                        //alert(response);
                        thumbid = response;
                        button.html("<i class='fa fa-check'></i>已上传");
                        showMessage("successed", "上传成功 -" + response + "-");
                    }
                }
            });//end new AjaxUpload
        });

        window.onload = function () {
            LoadGroups();
            AID = getQueryString("aid");
            if (AID != "" && AID != "0")
                LoadArticle();
            $("#btn-save").click(function () {
                SaveModify();
            });
        }

        function logout() {
            $.ajax({
                type: "POST",
                timeout: 10000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "LLEditorCore.aspx",
                data: { ctrl: "logout" },
                success: function (msg) {
                    if (msg.indexOf("Successed") > -1) {
                        window.location.reload();
                    } else
                        showMessage("error", "操作失败 !" + msg.replace("Error:", ""));
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });
        }

        function LoadArticle() {
            showMessage("loading", "正在加载...");
            $.ajax({
                type: "POST",
                timeout: 10000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "LLEditorCore.aspx",
                data: { ctrl: "LoadArticle", aid: AID },
                success: function (msg) {
                    if (msg != "" && msg.indexOf("Error:") == -1) {
                        var data = JSON.parse(msg);
                        $("#title").val(data.title);
                        $("#author").val(data.author);
                        $("#link").val(data.sourcelink);
                        editor.$txt.html(data.bodyhtml);
                        showMessage("successed", "加载成功 !");
                    } else
                        showMessage("error", "操作失败 !" + msg.replace("Error:", ""));
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });
        }

        function getQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
            var r = window.location.search.substr(1).match(reg);
            if (r != null)
                return unescape(r[2]);
            else
                return "";
        }

        //保存操作
        function SaveModify() {
            if (!ValidData())
                return;
            var obj = {};
            obj.title = $("#title").val();
            obj.author = $("#author").val();
            obj.link = $("#link").val();
            obj.summary = $("#desc").val();
            obj.bodyhtml = editor.$txt.html();
            obj.thumbid = thumbid;
            obj.groupid = $(".current-group").attr("currentid");
            showMessage("loading", "正在保存...");
            $.ajax({
                type: "POST",
                timeout: 10000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "LLEditorCore.aspx",
                data: { ctrl: "Save", jsondata: JSON.stringify(obj), aid: AID },
                success: function (msg) {
                    console.log(obj.bodyhtml);
                    console.log(msg);
                    if (msg.indexOf("Successed") > -1) {
                        if (AID == "")
                            showMessage("successed", "保存成功 !");
                        else
                            showMessage("successed", "修改成功 !");
                        AID = msg.replace("Successed", "");
                    } else
                        showMessage("error", "操作失败 !" + msg.replace("Error:", ""));
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });
        }

        //提示层
        function showMessage(type, txt) {
            switch (type) {
                case "loading":
                    $(".mask .fa").hide();
                    $(".mask .slice").show();
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
                case "successed":
                    $(".mask .slice").hide();
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check").show();
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(500);
                    }, 1000);
                    break;
                case "error":
                    $(".mask .slice").hide();
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)").show();
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 2000);
                    break;
                case "warn":
                    $(".mask .slice").hide();
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)").show();
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(600);
                    }, 1500);
                    break;
            }
        }

        //提交判断
        function ValidData() {
            var title = $("#title").val();
            var link = $("#link").val();
            var summary = $("#desc").val();
            var bodyhtml = editor.$txt.html();
            var groupid = $(".current-group").attr("currentid");
            if (title == "" || title == undefined) {
                showMessage("warn", "标题不能为空 !");
                return false;
            } else if (link == "" && summary == "") {
                showMessage("warn", "文章的摘要不能为空，请直接从文中复制一段 !");
                return false;
            } else if (link == "" && (bodyhtml == "" || bodyhtml.trim() == "<p><br></p>")) {
                showMessage("warn", "内容不能为空 !");
                return false;
            } else if (groupid == "" || groupid == "0") {
                showMessage("warn", "请选择文章对应的分组 !");
                return false;
            } else
                return true;
        }

        //加载分组
        function LoadGroups() {            
            $.ajax({
                type: "POST",
                timeout: 5000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "LLEditorCore.aspx",
                data: { ctrl: "LoadGroups_PC", ssid: "10" },
                success: function (msg) {
                    if (msg.indexOf("Error:") > -1)
                        showMessage("error", msg.replace("Error:", ""));
                    else {
                        var data = JSON.parse(msg);
                        var len = data.rows.length;
                        var str_html = "";
                        for (var i = 0; i < len; i++) {
                            var row = data.rows[i];
                            str_html += "<li data-id='" + row.id + "'>" + row.groupname + "</li>";
                        }//end for                        
                        $(".group-list").empty().append(str_html);
                        $(".group-list li").on("click", function () {
                            var current_group = $(this).attr("data-id");
                            $(".current-group").text($(this).text());
                            $(".current-group").attr("currentid", current_group);
                            $(".group-list").hide();
                        });
                        var gid = getQueryString("gid");
                        if (gid != "" && gid != "0" && gid != undefined) {
                            $(".current-group").attr("currentid", gid);
                            $(".current-group").text($(".group-list li[data-id=" + gid + "]").text());
                        }
                    }//end else
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });//end AJAX
        }

        //单击分组选择
        $(".current-group").on("click", function () {
            var display = $(".group-list").css("display");
            if (display == "none")
                $(".group-list").show();
            else
                $(".group-list").hide();
        });
    </script>
</body>
</html>
