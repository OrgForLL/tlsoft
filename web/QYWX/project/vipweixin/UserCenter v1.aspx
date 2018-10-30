<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html>
<script runat="server">
    private String ConfigKeyValue = "5"; //利郎男装
    //private string ChatProConnStr = System.Configuration.ConfigurationManager.ConnectionStrings["Conn"].ConnectionString;
    private string ChatProConnStr = "server='192.168.35.23';uid=lllogin;pwd=rw1894tla;database=tlsoft";    
    public Hashtable VI = new Hashtable();
    
    protected void Page_Load(object sender, EventArgs e)
    {
        Session["openid"] = "oarMEt8bqjmZIAhImSXBAg0G7F0I";
        if (clsWXHelper.CheckUserAuth(ConfigKeyValue, "openid"))
        {                 
            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(ChatProConnStr))
            {
                string str_sql = @"select top 1 a.wxnick,case when a.wxsex=1 then '男' else '女' end xb,a.wxcity,a.wxprovince,a.wxheadimgurl,138978 vipid,
                                    isnull(vi.userpoints,0) userpoints,isnull(vi.charmvalue,0) charmvalue,isnull(vt.titlename,'') titlename,vl.mc viplb
                                    from wx_t_vipbinging a 
                                    left join yx_t_vipkh vip on a.vipid=vip.id
                                    left join yx_t_viplb vl on vip.klb=vl.dm
                                    left join wx_t_vipinfo vi on vi.vipid=a.vipid
                                    left join wx_t_viptitle vt on vt.id=vi.viptitle
                                    where a.wxopenid=@openid";
                List<SqlParameter> paras = new List<SqlParameter>();
                paras.Add(new SqlParameter("@openid", Session["openid"].ToString()));
                DataTable dt = null;
                string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out dt);
                if (errinfo == "")
                {
                    if (dt.Rows.Count == 0)
                        clsWXHelper.ShowError("对不起，您还未关注利郎男装公众号。");
                    else {
                        if (dt.Rows[0]["vipid"].ToString() == "0" || dt.Rows[0]["vipid"].ToString() == "")
                            clsWXHelper.ShowError("对不起，您还不是利郎会员。");
                        else
                        {                            
                            AddHT(VI, "wxnick", dt.Rows[0]["wxnick"].ToString());
                            AddHT(VI, "xb", dt.Rows[0]["xb"].ToString());
                            AddHT(VI, "wxcity", dt.Rows[0]["wxcity"].ToString());
                            AddHT(VI, "wxpro", dt.Rows[0]["wxprovince"].ToString());
                            string headimg = dt.Rows[0]["wxheadimgurl"].ToString().Replace("\\","");
                            if (clsWXHelper.IsWxFaceImg(headimg))
                            {
                                //是微信头像
                                headimg = clsWXHelper.GetMiniFace(headimg);
                                AddHT(VI, "headimg_bg", headimg);
                            }
                            else {
                                headimg = clsConfig.GetConfigValue("VIP_WebPath") + "VIPWEIXIN/" + headimg;
                                AddHT(VI, "headimg_bg", headimg.Replace("my/", ""));
                            }        
                                               
                            AddHT(VI, "headimg", headimg);
                            AddHT(VI, "userpoints", dt.Rows[0]["userpoints"].ToString());
                            AddHT(VI, "charmvalue", dt.Rows[0]["charmvalue"].ToString());
                            AddHT(VI, "titlename", dt.Rows[0]["titlename"].ToString() == "" ? "头衔" : dt.Rows[0]["titlename"].ToString());
                            AddHT(VI, "viplb", dt.Rows[0]["viplb"].ToString());                                                  
                        }
                    }
                }
                else
                    clsWXHelper.ShowError("查询微信用户信息时出错！ " + errinfo);
            }
        }
        else
            clsWXHelper.ShowError("微信鉴权失败！");            
    }

    public void AddHT(Hashtable ht,string key,string value) {
        if (ht.ContainsKey(key))
            ht.Remove(key);
        ht.Add(key, value);
    }
        
</script>

<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link href='http://api.youziku.com/webfont/CSS/56d5c4fcf629d80420b28a91' rel='stylesheet' type='text/css' />
    <style type="text/css">
        #page-index {
            max-width: 600px;
            position: relative;
            margin: 0 auto;
            height: 100%;
        }

        .page {
            padding: 0;
        }

        .page-head {
            height: 210px;
            background: linear-gradient(90deg,#272b2e 0%,#555 100%);
            background: -webkit-linear-gradient(90deg,#272b2e 0%,#555 100%);
            border-bottom: 1px solid #444;
            box-sizing: border-box;
            position: relative;
            background-color: rgba(0,0,0,0.2);
            overflow: hidden;
        }

        .blurbg {
            /*position: absolute;
            top: -10px;
            left: -10px;
            width: 120%;
            height: 120%;
            background: url(../../res/img/storesaler/headimg.jpg) no-repeat left bottom scroll;
            background-size: cover;
            -webkit-filter: blur(10px); 
            filter: blur(10px);
            box-sizing: border-box;*/
        }

        .navs {
            position: absolute;
            top: 210px;
            left: 0;
            right: 0;
            bottom: 26px;
            background: #272b2e;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;
            z-index: 200;
        }

        .headimg {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            overflow: hidden;
            border: 2px solid #fff;
            margin: 0 auto;
        }

            .headimg img {
                width: 100%;
                height: 100%;
            }

        .username {
            font-size: 1.4em;
            color: #fff;
            font-weight: bold;
            text-align: center;
            margin: 8px 0 2px 0;
            text-shadow: 0 0 1px #ccc;
            letter-spacing:1px;
        }

        .area {
            color: #fff;
            text-align: center;
            text-shadow: 0 0 1px #ccc;
            font-size:1.1em;
        }

        .iconcircle {
            width: 34px;
            height: 34px;
            padding: 7px;
            border-radius: 50px;
            background: rgba(0,0,0,0.2);
            position: absolute;
            top: 50%;
            left: 66%;
            margin-top: -40px;
        }

            .iconcircle img {
                width: 20px;
                height: 20px;
            }

        .left {
            left: initial;
            right: 66%;
        }

        .iconcircle:hover {
            background: rgba(0,0,0,0.8);
        }

        .top-navs {
            position: absolute;
            left: 0;
            width: 100%;
            bottom: 0;
            height: 50px;
            background-color: rgba(0,0,0,0.2);
        }

        .tnavul {
            list-style: none;
            color: #f0f0f0;
        }

            .tnavul li {
                float: left;
                width: 33.33%;
                box-sizing: border-box;
                text-align: center;
                padding: 5px 0;
                line-height: 20px;
            }

                .tnavul li > p {                    
                    border-right: 1px solid rgba(255,255,255,.2);
                }

        .vipval {
            font-size:1.1em;
            font-family: 'HelveticaNeue1d832c0a34d3c';
        }
                                
                .tnavul li:last-child p {
                    border-right: none;
                }

        .navul {
            list-style: none;
            color: #ccc;
        }

            .navul li {
                width: 50%;
                float: left;
                position: relative;
                height: 80px;
                text-align: center;
                border-right: 1px solid #333;
                border-bottom: 1px solid #333;
                box-sizing: border-box;
                background-color: #272b2e;
            }

                .navul li:nth-child(2n) {
                    border-right: none;
                }

                .navul li:hover {
                    background-color: rgba(0,0,0,0.4);
                }

        .icon {
            width: 40px;
            height: 40px;
            float: left;
        }

        .icontext {
            height: 40px;
            line-height: 40px;
            float: left;
            padding: 0 5px;
            font-size: 1.1em;
        }

        .item {
            position: relative;
            top: 20px;
            display: inline-block;
        }

        .copy {
            color: #aaa;
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            text-align: center;
            font-size: 0.9em;
            height: 27px;
            line-height: 30px;
            z-index: 100;
            background-color: #272b2e;
        }
        /*loader style*/
        .mask {
            color: #fff;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1001;
            font-size: 1.1em;
            text-align: center;
            background-color: rgba(0,0,0,0.5);
            display:none;
        }

        .loader {
            background-color: rgba(39, 43, 46, 0.9);
            padding: 15px;
            border-radius: 5px;
            max-height: 200px;
            overflow: hidden;
        }

        #loadtext {
            margin-top: 10px;
            font-weight: bold;
            letter-spacing:1px;
        }
    </style>
</head>
<body>
    <div id="main" class="wrap-page">
        <!--主页-->
        <section id="page-index" class="page">
            <div class="page-head">
                <div style="position: absolute; top: 0; left: 0; height: 100%; width: 100%; padding-top: 15px; z-index: 205;">
                    <div class="headimg">
                        <img src="<%=VI["headimg"].ToString() %>" alt="" />
                    </div>
                    <p class="username"><%=VI["wxnick"].ToString() %></p>
                    <p class="area"><i class="fa fa-map-marker"></i> <%=VI["wxpro"].ToString()+" "+VI["wxcity"].ToString() %></p>
                    <div class="top-navs">
                        <ul class="tnavul">
                            <li>
                                <p class="vipval"><%=VI["userpoints"].ToString() %></p>
                                <p>用户积分</p>
                            </li>
                            <li>
                                <p class="vipval"><%=VI["charmvalue"].ToString() %></p>
                                <p><%=VI["titlename"].ToString() %></p>
                            </li>
                            <li>
                                <p class="vipval"><%=VI["viplb"].ToString() %></p>
                                <p>等级</p>
                            </li>
                        </ul>
                    </div>
                    <div class="iconcircle left" onclick="javascript:showLoader('sign-success','今日签到成功!')">
                        <img class="edit" src="../../res/img/storesaler/signicon.png" alt="" />
                    </div>
                    <div class="iconcircle" onclick="javascript:window.location.href='myinfos.html'">
                        <img class="sign" src="../../res/img/storesaler/editicon.png" alt="" />
                    </div>
                </div>
                <div class="blurbg" id="bg_container">
                    <img src="" alt="" id="blurbg" style="display:none;"/>
                </div>
                <canvas id="canvas" style="position:relative;"></canvas>
            </div>
            <div class="navs floatfix">
                <ul class="navul">
                    <li onclick="gourl('wdzs')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/storesaler/f-my.png" alt="" />
                            <span class="icontext">我的专属</span>
                        </div>
                    </li>
                    <li onclick="gourl('tsjy')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/storesaler/f-support.png" alt="" />
                            <span class="icontext">投诉建议</span>
                        </div>
                    </li>
                    <li onclick="gourl('jfcx')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/storesaler/f-points.png" alt="" />
                            <span class="icontext">积分查询</span>
                        </div>
                    </li>
                    <li onclick="gourl('wdsc')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/storesaler/f-star.png" alt="" />
                            <span class="icontext">我的收藏</span>
                        </div>
                    </li>
                    <li onclick="gourl('xxzx')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/storesaler/f-message.png" alt="" />
                            <span class="icontext">消息中心</span>
                        </div>
                    </li>
                    <li onclick="gourl('wdkq')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/storesaler/f-myvip.png" alt="" />
                            <span class="icontext">我的卡券</span>
                        </div>
                    </li>
                    <li onclick="gourl('rwxt')">
                        <div class="item floatfix">
                            <img class="icon" src="../../res/img/storesaler/f-task.png" alt="" />
                            <span class="icontext">任务系统</span>
                        </div>
                    </li>
                </ul>
            </div>
            <div class="copy">&copy; 2016 利郎信息技术部</div>
        </section>
    </div>
    <!--加载提示层-->
    <section class="mask">
        <div class="loader center-translate">
            <div style="font-size: 1.2em;">
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext">正在加载...</p>
        </div>
    </section>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/vipweixin/StackBlur.min.js"></script>
    <script type="text/javascript">
        $(function () {
            FastClick.attach(document.body);
            //var UA = navigator.userAgent;
            
            $("#blurbg").attr("src", "<%=VI["headimg_bg"].ToString()%>");
            IMGIsLoaded(blurbg);
        });

        function IMGIsLoaded(img) {
            var timer = setInterval(function () {
                if (img.complete) {
                    stackBlurImage('blurbg', 'canvas', 0, false);
                    locateIMG();
                    clearInterval(timer);
                }
            }, 100)
        }
        function locateIMG() {
            var imgObj = new Image();
            imgObj.src = $("#blurbg").attr("src");
            var imgWidth = imgObj.width;
            var imgHeight = imgObj.height;
            var containerWidth = parseInt($(".page-head").css("width").replace("px", ""));
            var containerHeight = 210;
            $("#canvas").css("width", "100%");
            $("#canvas").css("height", "auto");
            if (parseInt($("#canvas").css("height").replace("px", "")) >= 210) {
                imgHeight = parseInt($("#canvas").css("height").replace("px", ""));
                var topSite = (imgHeight / 2 - 105) * -1 + "px";
                $("#canvas").css("top", topSite);
            } else {
                $("#canvas").css("height", "100%");
                $("#canvas").css("width", "auto");
                containerWidth = parseInt($(".page-head").css("width").replace("px", ""));
                imgWidth = parseInt($("#canvas").css("width").replace("px", ""));
                var leftSite = (imgWidth / 2 - containerWidth / 2) * -1 + "px";
                $("#canvas").css("left", leftSite);
            }
        }

        function gourl(type) {
            if (type == "wdzs")
                window.location.href = "myinfos.html";
            else if (type == "jfcx")
                window.location.href = "pointrecords.html";
            switch (type) {
                case "wdzs":
                    window.location.href = "myguider.html";
                    break;
                case "tsjy":

                    break;
                case "jfcx":
                    window.location.href = "pointrecords.html";
                    break;
                default:
                    showLoader("thunder", "即将推出,敬请期待!");

            }
        }

        //提示层
        function showLoader(type, txt) {
            switch (type) {
                case "loading":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
                case "successed":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(200);
                    }, 500);
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 2000);
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 800);
                    break;
                case "thunder":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-bolt");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 1000);
                    break;
                case "sign-success":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check-circle");
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

