<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data"%>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    public string userid = "";
    public string username = "";
    protected void Page_Load(object sender, EventArgs e) {
        string clientIP = Request.ServerVariables.Get("Remote_Addr").ToString();        
        
        if (clientIP.IndexOf("192.168") == -1) {
            Response.Write("Error：来访受限！");
            Response.End();
        }
        //此处取的是协同的SESSION
        userid = Convert.ToString(Request.Params["userid"]);
        username = Convert.ToString(Request.Params["username"]);
        username = HttpUtility.UrlDecode(username);
        
        if (userid == "" || userid == "0" || userid == null ||username == "" || username == null)
        {
            Response.Write("Error：系统超时，请重新访问！");
            Response.End();
        }
    }
</script>
<html lang="zh-cn" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="gb2312" />
    <title>图文消息编辑 V2.0 Beta</title>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <link rel="Stylesheet" href="../../res/css/WXArticles/winpop.css" />
    <link rel="stylesheet" href="../../res/css/WXArticles/mystyle.css" />
    <!--引入wangEditor.css-->
    <link rel="stylesheet" type="text/css" href="../../res/css/WXArticles/wangEditor-1.3.13.2.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/WXArticles/animate.min.css" />
    <!--[if IE]>
       <link href="../../res/css/font-awesome-ie7.min.css" rel="stylesheet" />
    <![endif]-->
</head>
<body>        
    <div style="width:900px;margin:20px auto 5px auto; font-size:17px;font-style:italic;">图 文 编 辑 器 V2.0(含富文本器) Beta</div>
    <div class="content floatfix"> 
        <div class="errinfo"></div>       
        <div class="preview_area bounceInUp animated">
            <div class="multiedit">
                <div id="js_appmsg">
                    <div id="msgitem1" class="msgitemz">
                        <div class="thumb_wrp">
                            <img alt="" src="../../res/img/WXArticles/banner.jpg" class="msg_thumb" />
                            <i class="appmsg_default">封面图片</i>
                        </div>
                        <h4 class="msgtitle">封面+标题</h4>
                    </div>
                </div>
                <div>
                    <a class="appmsg_add" onclick="addNewBlock('text')"><i class="linkicon">新增文本</i> </a>
                    <a class="appmsg_add" onclick="addNewBlock('img')"><i class="linkicon">新增图片</i> </a>                    
                </div>
                <div style="padding:0px 14px 8px 14px;font-size:14px;">
                    <span style="display:inline-block; border-left:20px solid #555; width:100px;">&nbsp;&nbsp;非编辑状态</span>                   
                    <span style="display:inline-block; border-left:20px solid #f0ad4e; width:100px;">&nbsp;&nbsp;编辑状态</span>
                </div>
            </div>
        </div>        
        <div class="edit_area" id="moveedit">
            <div class="inner main_area">
                <div class="msgedit_item">
                    <label for="" class="frm_label">标题</label>
                    <span class="frm_input_box">
                        <input type="text" maxlength="200" class="frm_input" id="article_title" onblur="previewtitle(value)" />
                    </span>
                </div>
                <div class="msgedit_item">
                    <label for="" class="frm_label">作者（选填）</label>
                    <span class="frm_input_box">
                        <input type="text" maxlength="64" class="frm_input" id="article_author" />
                    </span>
                </div>
                <div class="msgedit_item">
                    <label for="" class="frm_label">原文链接（选填，<font color="#f00">填上链接后将直接进行跳转！）</font></label>
                    <span class="frm_input_box">
                        <input type="text" maxlength="500" class="frm_input" id="article_sourcelink" />
                    </span>
                </div>
                <span style="margin-top:5px;display:block;font-size:15px;font-weight:bold;color:#333;">不公开:&nbsp;&nbsp;<i class="fa fa-check-square" id="needvalidate" onclick="selectCov(this)" style="cursor:pointer;" value="1"></i></span>
            </div>
        </div>
        <div class="blocktype">
            <ul class="type-select">
                <li class="type-pic" onclick="switchType('img')">图 片</li>
                <li class="selected type-txt" onclick="switchType('text')">文 本</li>
            </ul>
        </div>
        <div class="edit_area" id="picedit_area">
            <div class="inner">
                <div class="msgedit_item ">
                    <label for="" class="frm_label">图片上传（JPG/PNG/BMP,且图片大小不能超过2MB！）</label>
                    <div class="upload_wrap">
                        <span class="frm_input_box">
                            <input type="text" maxlength="64" class="frm_input" id="imgFile" />                            
                        </span>
                        <span style="margin-top:10px;display:block;font-size:15px;font-weight:bold;">设为封面:&nbsp;&nbsp;<i class="fa fa-square-o" id="sec_cover" onclick="selectCov(this)" style="cursor:pointer;" value="0"></i></span>
                        <div style="margin-top: 10px;">
                            <a id="submitpic" href="javascript:void(0);" onclick="return false;" class="btns submitbtn">浏 览</a>
                        </div>
                        <input type="file" accept="image/*" style="display: none;" id="picSrc" />
                    </div>
                </div>
            </div>
        </div>

        <div class="edit_area" id="txtedit_area">
            <div class="inner">
                <div class="msgedit_item">
                    <label for="" class="frm_label">正文</label>
                    <span class="frm_textarea_box">
                        <textarea id="txtArea" class="frm_textarea" style="height: 300px;width:100%;"></textarea>
                    </span>
                    <div style="margin-top: 10px; text-align: right;">
                        <a id="submittxt" href="javascript:void(0);" onclick="return false;" class="btns submitbtn">提 交</a>
                    </div>
                </div>
            </div>
        </div>        
        <div id="downbtn">
            <a class="btns submitbtn" href="javascript:void(0);" onclick="return false;" id="btnsave">保 存</a>
        </div>   
        <div class="errinfo"></div>     
    </div>
    <div class="copyright">&copy CopyRight 2015 利郎信息技术部<br />By:Elilee</div>

    <script type="text/javascript" src="../../res/js/WXArticles/winpop.js?ver=20151008"></script>
    <script type="text/javascript" src="../../res/js/WXArticles/ajaxupload.js"></script>
    <script type="text/javascript" src="../../res/js/json2.js"></script>
    <script type="text/javascript" src='../../res/js/WXArticles/wangEditor-1.3.13.2.min.js' charset="gb2312"></script>
    <script type="text/javascript">
        //块类型就两种 text img
        var blockNums = 2;//当前文章的分块数 块对应的序号
        var isCreateBlock = false;//是否新建了一个空块 
        var currentBlock = 0; //最后一个块的序号或者得当前正在编辑的块
        var currentBlockType = "text";
        var isEditing = false;
        var articleID = "0";//文章ID        
        var editor = null;
        var slipAnimate = false;

        $(document).ready(function () {
            $("#picedit_area").slideUp();

            var button = $('#submitpic'), interval;
            var filename = "";
            new AjaxUpload(button, {
                action: '../../WebBLL/AjaxuploadHandler.aspx?ctrl=UploadImage',
                name: 'myfile',
                onSubmit: function (file, ext) {
                    this.setData({ "filename": file });
                    if (!(ext && /^(jpg|jpeg|JPG|JPEG|png|PNG|bmp|BMP|)$/.test(ext))) {
                        alert("图片格式不正确！");
                        return false;
                    }

                    // change button text, when user selects file
                    button.text('正在上传');
                    this.disable();

                    // Uploding -> Uploading. -> Uploading...
                    interval = window.setInterval(function () {
                        var text = button.text();
                        if (text.length < 10) {
                            button.text(text + '.');
                        } else {
                            button.text('正在上传');
                        }
                    }, 200);
                },
                onComplete: function (file, response) {
                    //file 本地文件名称，response 服务器端传回的信息
                    window.clearInterval(interval);
                    this.enable();

                    if (response == '-1') {
                        alert('您上传的文件太大啦!请不要超过2MB！');
                    }
                    else {
                        if (response.indexOf("Succeed|") > -1) {
                            alert("上传成功！");
                            button.text('浏览');
                            var imgpath = response.split('|')[1];
                            var imgid = response.split('|')[2];
                            $("#imgFile").val(imgpath);

                            if (isEditing) {
                                $("#msgitem" + currentBlock + " .msg_thumb").attr("src", "../../" + imgpath);
                                $("#msgitem" + currentBlock).attr("imgid", imgid);
                            } else if (blockNums != 2) {
                                $("#msgitem" + (blockNums - 1) + " .msg_thumb").attr("src", "../../" + imgpath);
                                $("#msgitem" + (blockNums - 1)).attr("imgid", imgid);
                                isCreateBlock = false;
                            }
                        } else {
                            alert("上传失败！");
                            ShowInfo(response, 3000);
                            console.log(response);
                            button.text('浏览');
                        }
                    }
                }
            });//end new AjaxUpload

            editor = $('#txtArea').wangEditor({
                'menuConfig': [
                 ['viewSourceCode'],
                 ['bold', 'underline', 'italic', 'foreColor', 'backgroundColor', 'strikethrough'],
                 ['fontFamily', 'fontSize', 'setHead', 'justify'],
                 ['undo', 'redo'],
                 ['fullScreen']
                ]
            });
            //editor.html("");
            //加载已有数据
            var id = GetQueryString("id");
            if (id != null && id != "" && id != "0")
                loadArticle(id);
            editor.html("");
            slipAnimate = true;
            if (id == null || id == "" || id == "0")
                addNewBlock("text");
        });

        //传入ID时加载文章数据
        function loadArticle(id) {
            ShowInfo("正在加载数据，请稍候.", 0);
            var _stop = false;
            window.setInterval(function () {
                if (!_stop) {
                    var text = $(".errinfo").html(text);
                    if (text.length < 15) {
                        $(".errinfo").html(text + '.');
                    } else {
                        $(".errinfo").html('正在加载数据，请稍候.');
                    }
                }
            }, 200);

            //AJAX请求数据
            $.ajax({
                type: "POST",
                timeout: 2000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "../../WebBLL/AjaxuploadHandler.aspx?ctrl=loadArticle",
                data: { id: GetQueryString("id") },
                success: function (msg) {
                    if (msg.indexOf("Successed") > -1) {
                        var jsondata = JSON.parse(msg.substring(9));
                        //处理返回的JSON数据                        
                        var bn = jsondata.rows.length;
                        $("#article_title").val(jsondata.rows[0].title);
                        $("#msgitem1 .msgtitle").text(jsondata.rows[0].title);
                        $("#article_author").val(jsondata.rows[0].author);
                        var sourcelink = jsondata.rows[0].sourcelink;
                        $("#article_sourcelink").val(sourcelink);
                        if (jsondata.rows[0].needvalidate == "False") {
                            var obj = $("#needvalidate");
                            $(obj).removeClass("fa-check-square").addClass("fa-square-o");
                            $(obj).attr("value", "0");
                        }
                        articleID = jsondata.rows[0].id;
                        for (var i = 0; i < bn; i++) {
                            var row = jsondata.rows[i];
                            var type = row.blocktype;
                            if (type == "text") {
                                addNewBlock("text");
                                var con = unescape(decodeURI(row.blockcontent));
                                $("#msgitem" + currentBlock + " .txtarea").html(con.replace(/\+/g, " "));
                            } else if (type == "img") {
                                addNewBlock("img");
                                $("#msgitem" + currentBlock).attr("imgid", row.imgid);
                                $("#msgitem" + currentBlock + " .msg_thumb").attr("src", row.imgfile);
                            }
                        }
                        $("#moveedit").css("margin-top", "20px");
                        window.scrollTo(0, 0);//滚动条也跟着移动
                        $(".editstatus").removeClass("editstatus");
                        isCreateBlock = false;
                        _stop = true;
                        $("#btnsave").text("修 改");
                        ShowInfo("加载成功！", 1500);
                        isEditing = true;
                    } else if (msg.indexOf("Error") > -1) {
                        _stop = true;
                        ShowInfo("加载失败！" + msg, 5000);
                    } else if (msg.indexOf("Warn") > -1) {
                        _stop = true;
                        ShowInfo("请检查传入的文章ID是否正确！", 2000);
                        $("#btnsave").attr("disabled", "disabled");
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    //alert("服务器错误：" + XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                    alert("您的网络好像有点问题，请刷新重试！");
                }
            });
        }

        //增加新块
        function addNewBlock(type) {
            var tmp = blockNums;
            var str_html = "";
            currentBlockType = type;
            if (currentBlockType == "text") {
                str_html = "<div id='msgitem" + tmp + "' class='msgitemm floatfix' blocktype='text'>";
                str_html += "<div class='txtarea'></div>";
                str_html += "<h4 class='msgtitle editstatus'>文本块</h4>";
                str_html += "<div class='edit_layer' id='edit_" + tmp + "'><i class='icon_edit' onclick=editblock(" + tmp + ")>编 辑</i><i class='icon_del' onclick=delblock(" + tmp + ")>删 除</i></div></div>";
            } else if (currentBlockType == "img") {
                str_html = "<div id='msgitem" + tmp + "' class='picarea floatfix' blocktype='img' imgid='0'><img alt='' src='../../res/img/WXArticles/img_icon.jpg' class='msg_thumb' />";
                str_html += "<h4 class='msgtitle editstatus'>图片块</h4><div class='edit_layer' id='edit_" + tmp + "'><i class='icon_edit' onclick=editblock(" + tmp + ")>编 辑</i>";
                str_html += "<i class='icon_del' onclick=delblock(" + tmp + ")>删 除</i></div></div>";
            }

            $(".editstatus").removeClass("editstatus");
            $("#js_appmsg").append(str_html);
            isCreateBlock = true;
            switchType(type);
            $("#msgitem" + tmp).mouseover(function () {
                $("#msgitem" + tmp + " .edit_layer").show();
            });
            $("#msgitem" + tmp).mouseleave(function () {
                $("#msgitem" + tmp + " .edit_layer").hide();
            });

            currentBlock = blockNums;
            $("#txtArea").val("");
            editor.html("");
            $("#imgFile").val("");
            moveEditArea(currentBlock);
            blockNums++;
        }

        //移动右边的编辑区域
        function moveEditArea(dqBlock) {
            var index = $("#msgitem" + currentBlock).index();
            if (index <= 0) {
                $("#moveedit").css("margin-top", "20px");
                window.scrollTo(0, 0);//滚动条也跟着移动
            }
            else {
                $("#moveedit").css("margin-top", 160 + 108 * (index - 1) + "px");
                window.scrollTo(0, 200 + 108 * (index - 1));//滚动条也跟着移动
            }
        }

        //替换块类型函数
        function replaceBlock(xh, type) {
            var tmp = xh;
            var str_html = "";
            if (type == "text") {
                str_html = "<div id='msgitem" + tmp + "' class='msgitemm floatfix' blocktype='text'>";
                str_html += "<div class='txtarea'></div>";
                str_html += "<h4 class='msgtitle'>文本块</h4>";
                str_html += "<div class='edit_layer' id='edit_" + tmp + "'><i class='icon_edit' onclick=editblock(" + tmp + ")>编 辑</i><i class='icon_del' onclick=delblock(" + tmp + ")>删 除</i></div></div>";
            } else if (type == "img") {
                str_html = "<div id='msgitem" + tmp + "' class='picarea floatfix' blocktype='img' imgid='0'><img alt='' src='../../res/img/WXArticles/img_icon.jpg' class='msg_thumb' />";
                str_html += "<h4 class='msgtitle'>图片块</h4><div class='edit_layer' id='edit_" + tmp + "'><i class='icon_edit' onclick=editblock(" + tmp + ")>编 辑</i>";
                str_html += "<i class='icon_del' onclick=delblock(" + tmp + ")>删 除</i></div></div>";
            }

            var parentObj = $("#msgitem" + xh).prev();
            $("#msgitem" + xh).remove();
            parentObj.after(str_html);
            $("#msgitem" + xh + " .msgtitle").addClass("editstatus");

            $("#msgitem" + tmp).mouseover(function () {
                $("#msgitem" + tmp + " .edit_layer").show();
            });
            $("#msgitem" + tmp).mouseleave(function () {
                $("#msgitem" + tmp + " .edit_layer").hide();
            });

        }

        //切换块类型
        function switchType(type) {
            var blockNos = $("#js_appmsg").children().length;

            if (isCreateBlock) {
                if (blockNos > 1 && type != currentBlockType) {
                    //替换块
                    currentBlockType = type;
                    if (isEditing) {
                        replaceBlock(currentBlock, currentBlockType);
                    } else {
                        $("#msgitem" + currentBlock).remove();
                        addNewBlock(type);
                    }
                    $("#txtArea").val("");
                    editor.html("");
                    $("#imgFile").val("");
                }

                if (type == "img" && slipAnimate) {
                    currentBlockType = "img";
                    $(".type-txt").removeClass("selected");
                    $(".type-pic").addClass("selected");
                    //编辑时不显示切换动画
                    $("#txtedit_area").slideUp();
                    $("#picedit_area").slideDown();
                } else if (type == "text" && slipAnimate) {
                    currentBlockType = "text";
                    $(".type-pic").removeClass("selected");
                    $(".type-txt").addClass("selected");
                    $("#txtedit_area").slideDown();
                    $("#picedit_area").slideUp();
                }
            } else {
                alert("请先在左侧新增一个文章块，或是点击左边文章块进行编辑！");
                ShowInfo("请先在左侧新增一个文章块，或是点击左边文章块进行编辑！", 2000);
            }
        }

        //删除块
        function delblock(dqBlock) {
            confirm('确定删除当前块？', function (flag) {
                if (flag) {
                    var index = $("#msgitem" + dqBlock).index() - 1;
                    $("#msgitem" + dqBlock).remove();
                    var blockNos = $("#js_appmsg").children().length;
                    if (index <= 0) {
                        $("#moveedit").css("margin-top", "20px");
                        window.scrollTo(0, 0);
                    }
                    else {
                        $("#moveedit").css("margin-top", 160 + 108 * (index - 1) + "px");
                        window.scrollTo(0, 160 + 108 * (index - 1));
                    }

                    if (blockNos > 1) {
                        isCreateBlock = false;
                        $(".editstatus").removeClass("editstatus");
                    }
                }
            });
        }

        //编辑块
        function editblock(dqBlock) {
            isCreateBlock = true;
            //var _type = $("#msgitem" + dqBlock + " .msgtitle").text();
            var _type = $("#msgitem" + dqBlock).attr("blocktype");
            if (_type == "text") {
                currentBlockType = "text";
                switchType("text");
                editor.html($("#msgitem" + dqBlock + " .txtarea").html());
                //IE                
                //if (navigator.userAgent.indexOf("MSIE") > 0)
                //    editor.html($("#msgitem" + dqBlock + " .txtarea").html());
                //else
                //    editor.html($("#msgitem" + dqBlock + " .txtarea").text());
            } else if (_type == "img") {
                currentBlockType = "img";
                switchType("img");
                var imgpath = $("#msgitem" + dqBlock + " .msg_thumb").attr("src");
                if (imgpath.indexOf("img_icon") == -1)
                    $("#imgFile").val(imgpath);
                else
                    $("#imgFile").val("");
            }

            $(".editstatus").removeClass("editstatus");
            $("#msgitem" + dqBlock + " .msgtitle").addClass("editstatus");
            currentBlock = dqBlock;
            moveEditArea(currentBlock);
            isEditing = true;
        }

        //页面顶部显示相关提示信息
        function ShowInfo(text, delaytime) {
            if (delaytime != 0)
                $(".errinfo").html(text).show().delay(delaytime).fadeOut(1000);
            else
                $(".errinfo").html(text).show();
        }

        //保存操作
        $("#btnsave").click(function () {
            var title = $("#article_title").val();
            if (title == "") {
                alert("标题不能为空！");
                return;
            }
            $("#btnsave").text("正在保存");
            $(".alert-button").attr("disabled", "disabled");
            $("#btnsave").attr("disabled", "disabled");
            //构造JSON字符串
            var jsonObj = new Object();
            var author = $("#article_author").val();
            var sourcelink = $("#article_sourcelink").val();
            var validate = $("#needvalidate").attr("value");
            var articleDetail = new Array();//存储明细对象数组
            jsonObj.title = title;
            jsonObj.author = author;
            jsonObj.needvalidate = validate;
            jsonObj.sourcelink = encodeURI(sourcelink);
            var blockNos = $("#js_appmsg").children().length;
            var xh = 0;
            for (var i = 1; i < blockNos; i++) {
                var BA = $("#js_appmsg").children().eq(i);
                var blockType = BA.attr("blocktype");
                var blockContent = "";
                var imgid = "0";
                var isHide = 0;
                if (blockType == "text") {
                    blockContent = escape($(".txtarea", BA).html().replace(/'/g,""));
                    if (blockContent == "") continue;
                } else if (blockType == "img") {
                    imgid = BA.attr("imgid");
                    if (imgid == "0") continue;
                }
                xh++;
                articleDetail.push({ "xh": xh, "type": blockType, "content": blockContent, "imgid": imgid, "ishide": isHide });
            }
            if (blockNos == 0 || articleDetail.length == 0) {
                alert("文章内容不能为空！");
                $("#btnsave").text("保 存");
                $(".alert-button").removeAttr("disabled");
                $("#btnsave").removeAttr("disabled");
                return;
            }
            jsonObj.blockArray = articleDetail;
            //AJAX提交数据
            if (articleID == "0") {
                //新增
                $.ajax({
                    type: "POST",
                    timeout: 5000,
                    async: false,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "../../WebBLL/AjaxuploadHandler.aspx?ctrl=SaveArticle",
                    data: { jsonData: JSON.stringify(jsonObj),userid:"<%=userid%>", username:"<%=username%>" },
                    success: function (msg) {
                        if (msg.indexOf("Successed") > -1) {
                            alert("保存成功！", function () {
                                //window.location.href = "LLMessageEdit.aspx?id=" + msg.substring(9);                                
                                window.location.reload();
                            });
                        } else if (msg.indexOf("Error") > -1) {
                            alert("保存失败！详情参见页面底部！");
                            ShowInfo(msg, 10000);
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        //alert("服务器错误：" + XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                        alert("您的网络好像有点问题，请刷新重试！");
                    }
                });
                $("#btnsave").text("保 存");
            } else {
                //修改
                $.ajax({
                    type: "POST",
                    timeout: 5000,
                    async: true,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "../../WebBLL/AjaxuploadHandler.aspx?ctrl=ModifyArticle",
                    data: { jsonData: JSON.stringify(jsonObj), id: articleID, userid: "<%=userid%>", username: "<%=username%>" },
                    success: function (msg) {
                        if (msg.indexOf("Successed") > -1) {
                            alert("修改成功！", function (flag) {
                                window.location.href = "LLMessageEdit.aspx?userid=<%=userid%>&username=<%=username%>&id=" + msg.substring(9);
                            });
                        } else if (msg.indexOf("Error") > -1) {
                            alert("修改失败！详情参见页面底部！");
                            ShowInfo(msg, 10000);
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        //alert("服务器错误：" + XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                        alert("您的网络好像有点问题，请刷新重试！");
                    }
                });
                $("#btnsave").text("修 改");
            }

            $(".alert-button").removeAttr("disabled");
            $("#btnsave").removeAttr("disabled");
        });

        function previewtitle(text) {
            if (text != "") {
                $("#msgitem1 .msgtitle").text(text);
            }
        }

        //提交文字到文本块中
        $("#submittxt").click(function () {
            var blockNos = $("#js_appmsg").children().length;
            if (blockNos == 1) {
                alert("请先在左侧新增一个文章块！");
                return;
            }
            //获取编辑器的源码
            var text = $("#txtArea").val();
            if (text == "") {
                alert("请先输入内容后再提交左侧进行预览！");
                return;
            } else if (!isCreateBlock) {
                alert("请先在左侧新增一个文章块，或是点击左边文章块进行编辑！");
                return;
            } else {
                $("#msgitem" + currentBlock + " .txtarea").html(text);
                //isCreateBlock = false;
            }
        });

        //获取URL参数
        function GetQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }

        function selectCov(obj) {
            //var val = $("#sec_cover").attr("value");
            var val = $(obj).attr("value");            
            if (val == "0") {
                $(obj).removeClass("fa-square-o").addClass("fa-check-square");
                $(obj).attr("value", "1");
                //alert("后期新增功能..");
            } else if (val == "1") {
                $(obj).removeClass("fa-check-square").addClass("fa-square-o");
                $(obj).attr("value", "0");
            }            
        }
    </script>
</body>
</html>
