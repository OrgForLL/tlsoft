﻿<%@ Page Language="C#" %>

<%@ Import Namespace="WebBLL.Core" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server">
    public string userid = "";
    private const string appID = "wxc368c7744f66a3d7";	//APPID
    private const string appSecret = "74ebc70df1f964680bd3bdd2f15b4bed";	//appSecret	    

    protected void Page_Load(object sender, EventArgs e)
    {
        userid = Convert.ToString(Session["TM_WXUserID"]);

        if (userid == null || userid == "" || userid == "0")
        {
            string gourl = HttpUtility.UrlEncode("http://tm.lilanz.com/supersalegames/TMOauthAndRedirect.aspx");
            string curURL = HttpUtility.UrlEncode(Request.Url.ToString());
            string OauthURL = @"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxc368c7744f66a3d7&redirect_uri={0}&response_type=code&scope=snsapi_userinfo&state={1}#wechat_redirect";
            OauthURL = string.Format(OauthURL, gourl, curURL);
            Response.Redirect(OauthURL);
            Response.End();
        }
        else if (!(userid == "13798" || userid == "13804" || userid == "13799" || userid == "13446" || userid == "13498"))
        {
            clsSharedHelper.WriteErrorInfo("对不起，您没有查看此页面的权限！");
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <title>数据统计</title>
    <link type="text/css" rel="stylesheet" href="css/animate.min.css" />
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        body {
            color: #333;
            background: #55994c;
            font-family: "微软雅黑";
        }

        .container {
            width: 94%;
            margin: 80px auto 20px auto;
            background: #fff;
            border-radius: 5px;
            padding: 70px 10px 10px 10px;
            box-sizing: border-box;
            overflow: hidden;
        }

        .logo {
            width: 90px;
            height: 90px;
            margin: 0 auto;
            overflow: hidden;
            border: 5px solid #eee;
            box-shadow: 0 6px 20px 0 rgba(0,0,0,.19),0 8px 17px 0 rgba(0,0,0,.2);
            background: url(img/lilanzlogo.jpg) no-repeat;
            background-size: cover;
            border-radius: 50%;
            position: absolute;
            margin-top: -50px;
            left: 50%;
            margin-left: -50px;
            z-index: 200;
        }

        .anihb {
            animation: heartbeat 1s infinite;
            -webkit-animation: heartbeat 1s infinite;
        }

        .animated.infinite {
            -webkit-animation-iteration-count: infinite;
            animation-iteration-count: infinite;
        }

        .title h4 {
            text-align: center;
            color: #757575;
            font-weight: 600;
            letter-spacing: 1px;
        }

        .title h2 {
            text-align: center;
            margin-top: 10px;
            font-weight: 600;
            letter-spacing: 4px;
            text-shadow: 0 0 1px #808080;
        }

        .title {
            border-bottom: 1px dashed #e1e1e1;
            padding-bottom: 10px;
        }

        .btn {
            display: block;
            text-decoration: none;
            color: #fff;
            width: 100px;
            background: #63b35a;
            padding: 8px 25px;
            border-radius: 6px;
            letter-spacing: 2px;
            font-size: 1.1em;
            margin: 10px auto 0 auto;
            text-align: center;
        }

        .static {
            list-style: none;
            border-bottom: 1px dashed #e1e1e1;
        }

            .static li {
                font-size: 1em;
            }

                .static li:not(:last-child) {
                    border-bottom: 1px solid #e1e1e1;
                }

                .static li:after {
                    content: "";
                    display: table;
                    clear: both;
                }

            .static span {
                display: block;
                width: 50%;
                float: left;
                text-align: center;
                padding: 6px 0;
                overflow: hidden;
                white-space: nowrap;
                text-overflow: ellipsis;
                box-sizing: border-box;
            }

        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }

        .sname {
            font-weight: bold;
            border-right: 1px solid #e1e1e1;
        }

        .copyright {
            text-align: center;
            color: #fff;
            font-size: 1em;
            margin: 20px 0;
            text-shadow: 0 0 1px #fff;
        }

        .ultitle {
            margin-top: 10px;
            text-align: center;
            padding: 8px;
            border-bottom: 1px solid #e1e1e1;
            background-color: #63b35a;
            color: #fff;
            font-size: 1em;
            border-top-left-radius: 4px;
            border-top-right-radius: 4px;
        }

        @keyframes heartbeat {
            0% {
                transform: scale(1);
            }

            50% {
                transform: scale(1.05);
            }

            100% {
                transform: scale(1);
            }
        }

        @-webkit-keyframes heartbeat {
            0% {
                -webkit-transform: scale(1);
            }

            50% {
                -webkit-transform: scale(1.05);
            }

            100% {
                -webkit-transform: scale(1);
            }
            /*animated flip*/
        }

        .allsum {
            margin-top: 20px;
            background: #ccc;
            border-radius: 5px;
            border-bottom: none;
            padding: 6px 0;
        }
    </style>
</head>
<body>
    <div class="logo animated flip"></div>
    <div class="container">
        <div class="title">
            <h4>利郎2015福利会</h4>
            <h2>今日游戏数据统计</h2>
            <h4 id="today">--</h4>            
        </div>

        <div>
            <div>
                <div class="ultitle">总投放情况(包含游戏跟报纸)</div>
                <ul class="static">
                    <li>
                        <span class="sname">总投放量</span>
                        <span class="svals" id="allsums">--</span>
                    </li>
                    <li>
                        <span class="sname">一等奖投放量</span>
                        <span class="svals" id="alla1">--</span>
                    </li>
                    <li>
                        <span class="sname">二等奖投放量</span>
                        <span class="svals" id="alla2">--</span>
                    </li>
                    <li>
                        <span class="sname">三等奖投放量</span>
                        <span class="svals" id="alla3">--</span>
                    </li>
                    <li>
                        <span class="sname">纪念奖投放量</span>
                        <span class="svals" id="alla4">--</span>
                    </li>
                </ul>
            </div>
            <div>
                <div class="ultitle">今日刮刮卡游戏投放情况</div>
                <ul class="static">
                    <li>
                        <span class="sname">一等奖投放量</span>
                        <span class="svals" id="daya1">--</span>
                    </li>
                    <li>
                        <span class="sname">二等奖投放量</span>
                        <span class="svals" id="daya2">--</span>
                    </li>
                    <li>
                        <span class="sname">三等奖投放量</span>
                        <span class="svals" id="daya3">--</span>
                    </li>
                    <li>
                        <span class="sname">纪念奖投放量</span>
                        <span class="svals" id="daya4">--</span>
                    </li>
                </ul>
            </div>
            <div>
                <div class="ultitle">游戏统计(今日截止到目前)</div>
                <ul class="static">
                    <li>
                        <span class="sname">页面访问量</span>
                        <span class="svals" id="pageviews">--</span>
                    </li>
                    <li>
                        <span class="sname">参与游戏次数</span>
                        <span class="svals" id="gametimes">--</span>
                    </li>
                    <li>
                        <span class="sname">游戏人数</span>
                        <span class="svals" id="gamers">--</span>
                    </li>
                </ul>
            </div>
        </div>
        <div>
            <div class="ultitle">中奖情况(今日截止到目前)</div>
            <ul class="static">
                <li>
                    <span class="sname">一等奖人数</span>
                    <span class="svals" id="za1">--</span>
                </li>
                <li>
                    <span class="sname">二等奖人数</span>
                    <span class="svals" id="za2">--</span>
                </li>
                <li>
                    <span class="sname">三等奖人数</span>
                    <span class="svals" id="za3">--</span>
                </li>
                <li>
                    <span class="sname">纪念奖人数</span>
                    <span class="svals" id="za4">--</span>
                </li>
            </ul>
        </div>

        <div>
            <div class="ultitle">活动开始至目前领奖情况</div>
            <ul class="static">
                <li>
                    <span class="sname">一等奖领取数</span>
                    <span class="svals" id="get1">--</span>
                </li>
                <li>
                    <span class="sname">二等奖领取数</span>
                    <span class="svals" id="get2">--</span>
                </li>
                <li>
                    <span class="sname">三等奖领取数</span>
                    <span class="svals" id="get3">--</span>
                </li>
                <li>
                    <span class="sname">游戏领取数</span>
                    <span class="svals" id="gameallget">--</span>
                </li>
                <li>
                    <span class="sname">活动领取数</span>
                    <span class="svals" id="allget">--</span>
                </li>
            </ul>
        </div>

        <div>
            <div class="ultitle">奖池可用奖项明细(实时)</div>
            <ul class="static">
                <li>
                    <span class="sname">一等奖</span>
                    <span class="svals" id="free1">--</span>
                </li>
                <li>
                    <span class="sname">二等奖</span>
                    <span class="svals" id="free2">--</span>
                </li>
                <li>
                    <span class="sname">三等奖</span>
                    <span class="svals" id="free3">--</span>
                </li>
                <li>
                    <span class="sname">纪念奖</span>
                    <span class="svals" id="free4">--</span>
                </li>
            </ul>
        </div>
        
        <ul class="static allsum">
            <li>
                <span class="sname">当前奖池可用奖项数</span>
                <span class="svals" id="freesums">--</span>
            </li>
        </ul>

        <div><a class="btn" onclick="javascript:void(0);" id="refresh">立即刷新</a></div>
    </div>
    <div class="copyright">&copy;2015 利郎信息技术部</div>
    <script src="js/jquery.js" type="text/javascript"></script>
    <script type="text/javascript">
        window.onload = function () {
            getData();
            setTimeout(function () {
                $(".logo").removeClass("animated").removeClass("flip").addClass("anihb");
            }, 1500);
        }

        Date.prototype.Format = function (fmt) { //author: meizz 
            var o = {
                "M+": this.getMonth() + 1, //月份 
                "d+": this.getDate(), //日 
                "h+": this.getHours(), //小时 
                "m+": this.getMinutes(), //分 
                "s+": this.getSeconds(), //秒 
                "q+": Math.floor((this.getMonth() + 3) / 3), //季度 
                "S": this.getMilliseconds() //毫秒 
            };
            if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
            for (var k in o)
                if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
            return fmt;
        }

        function getData() {
            $(".btn").attr("disabled", "disabled");
            $(".btn").text("正在计算");
            var ctime = new Date().Format("yyyy-MM-dd");
            $("#today").text(ctime);
            $.ajax({
                type: "POST",
                timeout: 10000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "static.aspx",
                data: { rq: ctime },
                success: function (msg) {
                    if (msg.indexOf() > -1) {
                        alert(msg);
                    } else {
                        var arr = msg.split("|");
                        $("#allsums").text(arr[0]);
                        $("#alla1").text(arr[1]);
                        $("#alla2").text(arr[2]);
                        $("#alla3").text(arr[3]);
                        $("#alla4").text(arr[4]);
                        $("#pageviews").text(arr[5]);
                        $("#gametimes").text(arr[6]);
                        $("#gamers").text(arr[7]);
                        $("#za1").text(arr[8]);
                        $("#za2").text(arr[9]);
                        $("#za3").text(arr[10]);
                        $("#za4").text(arr[11]);
                        $("#freesums").text(arr[12]);
                        $("#get1").text(arr[13]);
                        $("#get2").text(arr[14]);
                        $("#get3").text(arr[15]);
                        $("#gameallget").text(arr[16]);
                        $("#allget").text(arr[17]);
                        $("#free1").text(arr[18]);
                        $("#free2").text(arr[19]);
                        $("#free3").text(arr[20]);
                        $("#free4").text(arr[21]);
                        $("#daya1").text(arr[22]);
                        $("#daya2").text(arr[23]);
                        $("#daya3").text(arr[24]);
                        $("#daya4").text(arr[25]);
                    }

                    $(".btn").text("立即刷新");
                    $(".btn").removeAttr("disabled");
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {

                }
            });
        }

        function clearInput() {
            $("#allsums").text("--");
            $("#alla1").text("--");
            $("#alla2").text("--");
            $("#alla3").text("--");
            $("#alla4").text("--");
            $("#pageviews").text("--");
            $("#gametimes").text("--");
            $("#gamers").text("--");
            $("#za1").text("--");
            $("#za2").text("--");
            $("#za3").text("--");
            $("#za4").text("--");
            $("#freesums").text("--");
            $("#get1").text("--");
            $("#get2").text("--");
            $("#get3").text("--");
            $("#gameallget").text("--");
            $("#allget").text("--");
            $("#free1").text("--");
            $("#free2").text("--");
            $("#free3").text("--");
            $("#free4").text("--");
        }

        $("#refresh").click(function () {
            clearInput();
            getData();
        });
    </script>
</body>
</html>
