<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html>
<script runat="server">
    private const string ConfigKeyValue = "1";	//微信配置信息索引值
    public List<string> wxConfig;       //微信OPEN_JS 动态生成的调用参数
    
    //验证文章是否需要身份判断
    public bool isValidate(string aid) {
        bool rt = true;
        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("FormalModeConnStr")))
        {
            string sql = "select needvalidate from t_MultiArticles where id=@id;";
            List<SqlParameter> paras = new List<SqlParameter>();
            paras.Add(new SqlParameter("@id", aid));
            DataTable dt = null;
            string errinfo = dal.ExecuteQuerySecurity(sql,paras,out dt);
            if (errinfo == "" && dt.Rows.Count > 0) {
                if (dt.Rows[0][0].ToString() != "True")
                    rt = false;
            }                
        }
        
        return rt;        
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {               
        string userid = Convert.ToString(Session["qy_customersid"]);
        string aid = Convert.ToString(Request.Params["id"]);         
        if ((userid == "" || userid == null || userid == "0") && isValidate(aid))
        {
            //获取用户鉴权的方法:该方法要求用户必须已成功关注企业号，主要是用于获取Session["qy_customersid"] 和其他登录信息
            if (!clsWXHelper.CheckQYUserAuth(true))
            {
                Response.Redirect("../../WebBLL/Error.aspx?msg=请先关注利郎企业号！");
                Response.End();
            }
        } 
        else
        {
            wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
            
            //文章阅读量统计
            if (!(aid == null || aid == "" || aid == "0"))
            {
                string sql = "";
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("FormalModeConnStr")))
                {
                    sql = "select sourcelink from t_multiarticles where id='" + aid + "'";
                    DataTable dt = null;
                    string errInfo = dal.ExecuteQuery(sql, out dt);
                    if (errInfo == "")
                    {
                        if (dt.Rows.Count > 0)
                        {
                            if (dt.Rows[0][0].ToString() != "")
                            {
                                Response.Redirect(dt.Rows[0][0].ToString());
                                Response.End();
                            }
                        }
                        else
                        {
                            if (Request.Cookies["article_" + aid] == null)
                            {
                                //更新阅读量
                                sql = @"update t_multiarticles set viewtimes=viewtimes+1 where id=@id;";
                                List<SqlParameter> paras = new List<SqlParameter>();
                                paras.Add(new SqlParameter("@id", aid));
                                errInfo = dal.ExecuteNonQuerySecurity(sql, paras);
                                if (errInfo == "")
                                {
                                    //写入cookie
                                    HttpCookie cookie = new HttpCookie("article_" + aid);
                                    cookie.Value = "1";
                                    cookie.Expires = DateTime.Now.AddDays(1);
                                    Response.Cookies.Add(cookie);
                                }
                            }
                        }
                    }
                    else
                        clsSharedHelper.WriteErrorInfo(errInfo);
                }
            }
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <!--[if IE]>
       <link href="../../res/css/font-awesome-ie7.min.css" rel="stylesheet" />
    <![endif]-->
    <link type="text/css" rel="stylesheet" href="../../res/css/animate.min.css" />
    <style type="text/css">
        * {
            padding: 0px;
            margin: 0px;
        }

        body {
            font-family: "微软雅黑";
            color: #333;
            padding: 20px 0px;
            background-color: #f2f2f2;
        }

        #info {
            width: 96%;
            margin: 0px auto 15px auto;
            text-align: center;
            color: #d43f3a;
            display: none;
        }
        #info2 {
            text-align:center;
            color:#d43f3a;
            margin-bottom:15px;
            font-weight:bold;  
            display:none;
        }
        #container {
            width: 96%;
            min-height: 300px;
            margin: 0px auto;
            border: 1px solid #ccc;
            box-shadow: 3px 3px 10px #ccc;
            box-sizing: border-box;
            overflow: hidden;
            border-radius: 4px;
            background-color: #fff;
        }

        .ahead {
            width: 100%;
            height: 220px;
            position: relative;
            overflow: hidden;
        }

        .layer {
            position: absolute;
            left: 0px;
            top: 0px;
            width: 100%;
            height: auto;
        }

        .cover {
            position: absolute;
            left: 0px;
            right: 0px;
            bottom: 0px;
            width: 100%;
            height: 100%;
        }

        .blur {
            position: absolute;
            width: 100%;            
            height: 100%;
            left: 0px;
            -webkit-filter: blur(3px);
            filter: progid:DXImageTransform.Microsoft.Blur(PixelRadius=5, MakeShadow=false);
        }

        .mask {
            position: absolute;
            left: 0px;
            bottom: 0px;
            height: 40px;
            line-height: 40px;
            vertical-align: middle;
            padding: 0px 20px;
            filter: progid:DXImageTransform.Microsoft.Gradient(startColorStr=#34000000,endColorStr=#34000000);
            background-color: rgba(0,0,0,.4);
            width: 100%;
            color: #fff;
            font-size: 1em;
            font-weight: 600;
            overflow: hidden;
            box-sizing: border-box;
            text-align: right;
        }

        #articleinfo li {
            list-style: none;
            float: left;
        }

        .mf {
            margin-left: 1em;
            white-space: nowrap;
            max-width: 100px;
            text-overflow: ellipsis;
            overflow: hidden;
        }

        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }

        #atitle {
            position: relative;
            width: 90%;
            height: 140px;
            text-align: center;
            margin: 20px auto;
            z-index: 100;
            font-size: 2em;
            overflow: hidden;
            text-shadow: 2px 2px 1px #fff;
        }

        .copyright {
            width: 96%;
            text-align: center;
            margin: 10px auto 0px auto;
            font-size: 14px;
            font-weight: bold;
            color: #555;
        }

        .mbody {
            padding: 20px 15px;
            line-height: 25px;
            text-shadow: 0px 0px 1px #ccc;                      
        }

        .aimgs {
            margin: 15px auto;
            text-align: center;
        }

            .aimgs img {
                width: 90%;
                max-width: 600px;
                height: auto;
                border: 1px solid #ccc;
                padding: 10px;
                box-shadow: 3px 3px 5px #ccc;
            }

        .aclose {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 32px;
            height: 32px;
            text-align: center;
            border: 1px solid #000;
            color: #000;
            background-color: #fff;
            cursor: pointer;
        }

            .aclose:hover {
                color: #fff;
                background-color: #000;
            }

        /**PC端样式**/
        @media screen and (min-width: 1000px) {
            #container, #info {
                width: 900px;
            }

            .mbody {
                padding: 20px 20px;
            }
        }
    </style>
</head>
<body>
    <div id="info">提示信息：</div>
    <div id="container">
        <div class="ahead">
            <img src="../../img/WXArticles/dtop.jpg" class="layer" />
            <div class="cover">
                <img src="img/dtop.jpg" class="blur" />
                <div class="mask">
                    <ul id="articleinfo" class="">
                        <li><i class="fa fa-calendar"></i>&nbsp;<span id="atime"></span></li>
                        <li class="mf"><i class="fa fa-user"></i>&nbsp;<span id="aauthor"></span></li>
                        <li class="mf"><i class="fa fa-eye fa"></i>&nbsp;<span id="aviewtimes">--次</span></li>
                    </ul>
                </div>
            </div>
            <div id="atitle" class=""></div>
        </div>
        <div class="mbody" id="xx">
            <div id="info2">单击文中的图片可以进行预览！</div>
        </div>
    </div>
    <div class="copyright">&copy;CopyRight 2015 利郎信息技术部</div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/json2.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>    
    <script type="text/javascript">
        var imgURLs = new Array();
        window.onload = function () {
            //alert(navigator.userAgent);
            var id = GetQueryString("id");
            if (id == "" || id == "0" || id == null) {
                $("#info").text("提示信息：请传入文章ID！");
                $("#info").show();
                return;
            } else {
                $("#info").hide();
                //AJAX请求数据
                $.ajax({
                    type: "POST",
                    timeout: 2000,
                    async: false,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "../../WebBLL/AjaxuploadHandler.aspx?ctrl=loadArticle",
                    data: { id: id },
                    success: function (msg) {
                        if (msg.indexOf("Successed") > -1) {
                            var jsondata = JSON.parse(msg.substring(9));
                            //处理返回的JSON数据                        
                            var bn = jsondata.rows.length;
                            $("#atitle").text(jsondata.rows[0].title);
                            document.title = jsondata.rows[0].title;
                            $("#atime").text(jsondata.rows[0].createtime);
                            $("#aviewtimes").text(jsondata.rows[0].viewtimes + "次");
                            var author = jsondata.rows[0].author == "" ? "--" : jsondata.rows[0].author;
                            $("#aauthor").text(author);
                            var ahtml = "<div id='acontent'>";
                            for (var i = 0; i < bn; i++) {
                                var row = jsondata.rows[i];
                                var type = row.blocktype;

                                if (type == "text") {
                                    var con = unescape(decodeURI(row.blockcontent));
                                    ahtml += con.replace(/\+/g, " ");
                                } else if (type == "img") {
                                    var _img = "http://tm.lilanz.com/QYWX/" + row.imgfile;
                                    ahtml += "<div class='aimgs' onclick=\"previewImage('" + _img + "')\"><img src='" + row.imgfile + "' /></div>";
                                    imgURLs.push(_img);
                                }
                            }
                            ahtml += "</div>";
                            $(".mbody").append(ahtml);
                            $("#atitle").addClass("zoomInDown animated");
                            $("#articleinfo").addClass("bounceInUp animated");
                            //WeiXin JSSDK
                            jsConfig();
                        } else if (msg.indexOf("Error") > -1) {

                        } else if (msg.indexOf("Warn") > -1) {

                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        //alert("服务器错误：" + XMLHttpRequest.status + "|" + XMLHttpRequest.readyState + "|" + textStatus);
                        alert("您的网络好像有点问题，请刷新重试！");
                    }
                });
            }
            $("#info2").show().delay(4000).fadeOut();
        }

        //获取URL参数
        function GetQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }

        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        /********************签名**********************/
        function jsConfig() {
            wx.config({
                debug: true,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['onMenuShareAppMessage', 'hideMenuItems', 'previewImage'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                //alert("JS注入成功！");
                //分享给朋友    
                //图标取第一张图片没有则使用封面图
                var shareIconSrc = "http://tm.lilanz.com/retail/wxarticles/" + $(".layer").attr("src");
                if ($(".aimgs").children().length > 0) {
                    shareIconSrc = "http://tm.lilanz.com/retail/wxarticles/" + $(".aimgs").children().eq(0).attr("src");
                }
                
                var sharelink = "http://tm.lilanz.com/retail/wxarticles/showarticle.aspx?id=" + GetQueryString("id");
                wx.onMenuShareAppMessage({
                    title: $("#atitle").text(), // 分享标题
                    desc: '来自'+$("#aauthor").text()+'的好文章，不妨看看吧！', // 分享描述
                    link: sharelink, // 分享链接                    
                    imgUrl: shareIconSrc, // 分享图标
                    type: '', // 分享类型,music、video或link，不填默认为link
                    dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
                    success: function () {
                        // 用户确认分享后执行的回调函数
                    },
                    cancel: function () {
                        // 用户取消分享后执行的回调函数
                    }
                });
                wx.hideMenuItems({
                    menuList: ['menuItem:share:qq', 'menuItem:share:timeline', 'menuItem:share:weiboApp', 'menuItem:share:QZone', 'menuItem:openWithSafari', 'menuItem:openWithQQBrowser', 'menuItem:share:email','menuItem:copyUrl'] // 要隐藏的菜单项，只能隐藏“传播类”和“保护类”按钮，所有menu项见附录3
                });
            });
            wx.error(function (res) {
                alert("JS注入失败！");
            });
        }

        //微信的预览图片接口
        function previewImage(currentImgURL) {
            wx.previewImage({
                current: currentImgURL, // 当前显示图片的http链接
                urls: imgURLs // 需要预览的图片http链接列表
            });
        }

        /************获取签名数据*************/
        //function Getsignature() {
        //    var MyUrl = escape(location.href);
        //    $.ajax({
        //        url: "../../WebBLL/AjaxuploadHandler.aspx?ctrl=JSConfig&myUrl=" + MyUrl,
        //        type: "POST",
        //        dataType: "HTML",
        //        cache: false,//不使用缓存
        //        timeout: 5000,
        //        error: function (XMLHttpRequest, textStatus, errorThrown) {
        //            alert("AJAX调用签名接口失败！");
        //        },
        //        success: function (result) {
        //            var strArr = new Array();
        //            strArr = result.split('|');
        //            if (strArr.length < 1) {
        //                alert("您的网络不给力~，请尝试重新打开！");
        //            } else {
        //                appIdVal = strArr[0];
        //                timestampVal = strArr[1];
        //                nonceStrVal = strArr[2];
        //                signatureVal = strArr[3];
        //                jsConfig();
        //            }
        //        }
        //    });
        //}
    </script>
</body>
</html>
