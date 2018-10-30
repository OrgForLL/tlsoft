<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html>
<script runat="server">
    private List<string> wxConfig = new List<string>();
    private string DBConnStr = "server=192.168.35.10;database=tlsoft;uid=ABEASD14AD;pwd=+AuDkDew";

    protected void Page_Load(object sender, EventArgs e)
    {
        //WriteLog("ArticleShow.aspx " + Request.Url.ToString());
        wxConfig = clsWXHelper.GetJsApiConfig("1");
        if (!IsPostBack) {
            string aid = Convert.ToString(Request.Params["aid"]);
            if (aid != "" && aid != "0" && aid != null)
            {
                //阅读次数+1
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConnStr))
                {
                    string str_sql = "update t_MultiArticles set viewtimes=viewtimes+1 where id=@aid";
                    List<SqlParameter> para = new List<SqlParameter>();
                    para.Add(new SqlParameter("@aid", aid));
                    string errinfo = dal.ExecuteNonQuerySecurity(str_sql, para);
                }//end using
            }
        }
    }

    //写日志方法
    private void WriteLog(string text)
    {
        //AppDomain.CurrentDomain.BaseDirectory + "logs\\"
        String path = HttpContext.Current.Server.MapPath("logs/");
        if (!System.IO.Directory.Exists(System.IO.Path.GetDirectoryName(path)))
        {
            System.IO.Directory.CreateDirectory(path);
        }
        System.IO.StreamWriter writer = new System.IO.StreamWriter(path + DateTime.Now.ToString("yyyyMMdd") + ".log", true);
        string str;
        str = "[" + DateTime.Now.ToString() + "]\r\n" + text;
        writer.WriteLine(str);
        writer.Close();
    }
</script>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <title></title>
    <link rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link rel="stylesheet" href="../../res/css/wangEditor.min.css" />
    <style type="text/css">
        body {
            background-color: #ebeff2;
        }

        .page {
            background-color: #fff;
            padding: 0;
        }

        .page-not-footer {
            bottom: 24px;
        }

        .footer {
            height: 24px;
            line-height: 24px;
            color: #999;
            font-size: 12px;            
        }

        .frm-top {
            height: 180px;
            background-color: #31343d;
            position: relative;
        }

            .frm-top .title {
                position: absolute;
                width: 100%;
                max-height: 80px;
                overflow: hidden;
                left: 0;
                bottom: 48px;
                color: #fff;
                font-size: 20px;
                letter-spacing: 2px;
                padding: 0 10px;
            }

        .views {
            position: absolute;
            left: 0;
            bottom: 0;
            height: 48px;
            line-height: 48px;
            color: #fff;
            padding-left: 15px;
        }

        .fa-eye {
            padding-right: 5px;
        }

        .ainfos {
            height: 34px;
            border-bottom: 1px dashed #bcbcbc;
            line-height: 34px;
            color: #888;
            font-size: 14px;
        }

        #time {
            display: block;
            float: right;
        }

        .backimg {
            background-position: 50% 50%;
            background-size: cover;
            background-repeat: no-repeat;
        }

        .wangEditor-txt p {
            word-wrap: break-word;            
        }

        .wangEditor-container .wangEditor-txt {
            padding: 0;
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
            margin:0 auto;
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
        /*mask style*/
        .mask {
            color: #fff;
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1001;
            font-size: 1.1em;
            text-align: center;
            background-color: rgba(0,0,0,0.5);
            display: none;
        }
        
        .loader {
            background-color: rgba(39, 43, 46, 0.9);
            padding: 10px 20px;
            border-radius: 5px;
            max-height: 200px;
            overflow: hidden;
            min-width: 80px;
        }

        #loadtext {
            margin-top: 8px;            
            font-size: 1em;
        }
    </style>
</head>
<body>    
    <div class="wrap-page">
        <div class="page page-not-footer">
            <div class="frm-top">
                <div class="title" id="title">
                    --
                </div>
                <div class="views"><i class="fa fa-eye"></i></div>
            </div>
            <div style="padding: 0 8px">
                <div class="ainfos">
                    <span id="author">作者：</span>
                    <span id="time">时间：</span>
                </div>
                <div class="wangEditor-container" style="border: none;">
                    <div id="preview-area" class="wangEditor-txt">--</div>
                </div>
            </div>
        </div>
    </div>
    <div class="footer">&copy2016 利郎信息技术部 提供技术支持</div>
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
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript">
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";

        function LoadArticle(AID) {
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
                        var link = data.sourcelink;
                        if (link != "" && (link.indexOf("http://") > -1 || link.indexOf("https://") > -1)) {
                            showMessage("loading", "正在跳转...");
                            setTimeout(function () {
                                window.location.href = link;
                            }, 1000);
                            return;
                        }
                        $("#title").text(data.title);
                        $("#author").text(data.author);
                        $("#time").text(data.createtime);
                        $("#preview-area").html(data.bodyhtml);
                        showMessage("successed", "加载成功 !");                        
                    } else
                        showMessage("error", "操作失败 !" + msg.replace("Error:", ""));
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                }
            });
        }

        function WXAPIConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['hideOptionMenu'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                wx.hideOptionMenu();
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

        window.onload = function () {
            WXAPIConfig();
            var aid = getQueryString("aid");            
            if (aid != "" && aid != "0" && aid != undefined) {
                LoadArticle(aid);
            } else {
                showMessage("error","未知错误 !");
            }

            LeeJSUtils.stopOutOfPage(".page", true);            
            LeeJSUtils.stopOutOfPage(".footer", false);
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
                        $(".mask").fadeOut(200);
                    }, 500);
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
                        $(".mask").fadeOut(400);
                    }, 1000);
                    break;
            }
        }
    </script>
</body>
</html>

