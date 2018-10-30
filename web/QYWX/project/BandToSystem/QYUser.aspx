﻿<%@ Page Language="C#" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>
<script runat="server">
    public string uName = "", uPhone = "", uHeadImg = "";
    public string DBConnStr = "server='192.168.35.62';database=weChatPromotion;uid=sa;pwd=ll=8727";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            uName = Convert.ToString(Session["qy_cname"]);
            string uid = Convert.ToString(Session["qy_customersid"]);
            using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(DBConnStr)) {
                string str_sql = @"select top 1 cname,mobile,avatar from wx_t_customers where id=@cid";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@cid", uid));
                DataTable dt;
                string errinfo = dal62.ExecuteQuerySecurity(str_sql,para,out dt);
                if (errinfo == "")
                    if (dt.Rows.Count > 0)
                    {
                        uPhone = Convert.ToString(dt.Rows[0]["mobile"]);
                        uHeadImg = Convert.ToString(dt.Rows[0]["avatar"]);
                        uHeadImg = "http://tm.lilanz.com/oa/" + uHeadImg;
                    }
                    else
                        clsSharedHelper.WriteInfo("找不到您在企业号中的登记信息！");
                else
                    clsSharedHelper.WriteErrorInfo(errinfo);
            }//end using
        }
    }
</script>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0" />
    <meta name="format-detection" content="telephone=no" />
    <title>利郎企业号</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }

        body {
            font-family: Helvetica,Arial,"Hiragino Sans GB","Microsoft Yahei","微软雅黑",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            color: #333;
            background-color: #fff;
        }

        .header {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 140px;
            z-index: 100;
            background: url(../../res/img/bandtosystem/qythumb.jpg);
            background-size: cover;
            overflow: hidden;
            border-bottom: 1px solid #cbcbcb;
        }

            .header .headimg {
                position: relative;
                width: 60px;
                height: 60px;
                margin:15px auto 5px auto;
                background: url('../../res/img/bandtosystem/lilanzlogo2.jpg');
                background-size: cover;
                background-position:50% 50%;
                background-repeat:no-repeat;
                border-radius: 50px;
                border: 3px solid #fff;
            }

        .editicon {
            position: absolute;
            top: 10px;
            color: #fff;
            font-size: 2em;
            padding: 0 10px;
        }

        .editicon {
            right: 5px;
        }

        .header p {
            font-size: 1.1em;
            color: #fff;
            text-align: center;
        }

        .header .uname {
            font-size: 1.4em;
            font-weight: bold;            
            line-height:30px;            
        }

        .container {
            position: fixed;
            top: 141px;
            bottom: 28px;
            width: 100%;
            z-index: 10;
            overflow-x: hidden;
            overflow-y: scroll;
            -webkit-overflow-scrolling: touch;
        }

        .mypage {
            position:absolute;
            top:32px;
            width:100%;         
            padding-top: 5px;
            transition: all 0.5s;
            -webkit-transition: all 0.5s;
            -webkit-transform: translate3d(0,0,0);
            -webkit-transform: translate(0,0,0);
            transform: translate3d(0,0,0);

        }

        .item {
            width: 80%;
            height: 100px;
            background: #71a43d;
            border-radius: 6px;
            box-shadow: 0px 0px 2px #aaa;
            box-sizing: border-box;
            margin: 0 auto;
            position: relative;
        }

            .item.no-open {
                background-color:#bbb !important;
            }

        .footer {
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 28px;
            line-height: 28px;
            text-align: center;
            z-index: 1;
            color: #808080;
            font-size:12px;
        }

        ul {
            list-style: none;
            text-align: center;
        }

        .menulist li {
            float: left;
            width: 33.33%;
            text-align: center;
            margin: 7px 0 10px 0;
        }

            .menulist li img {
                width: 40px;
                height: 40px;
                margin-top: 15px;
            }

        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }

        .itemtxt {
            height: 26px;
            line-height: 26px;
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            background-image: linear-gradient(360deg,#e7e7e7,#f8f8f8);
            background-image: -webkit-linear-gradient(90deg,#e7e7e7,#f8f8f8);
            border-bottom-left-radius: 6px;
            border-bottom-right-radius: 6px;
            border-top: 1px solid #f0f0f0;
        }

        .left {
            transform: translate3d(-100%,0,0);
            -webkit-transform: translate3d(-100%,0,0);
            -webkit-transform: translate(-100%,0,0);
        }

        .right {
            -webkit-transform: translate3d(100%,0,0);
            -webkit-transform: translate(100%,0,0);
            transform: translate3d(100%,0,0);
        }

        .menulist2 li {
            padding: 8px;
            height: 60px;
            background: #fff;
            text-align: left;
            overflow:hidden;

        }

            .menulist2 li:not(:last-child) {
                border-bottom: 1px solid #f0f0f0;
            }

        .fixicon {
            height: 36px;
            width: 36px;
            padding: 3px;
            margin: 0;
            box-shadow: none;
            float: left;
            top: 50%;
            margin-top: -19px;
        }

        .menulist2 img {
            width: 30px;
            height: auto;
        }

        .menuname {
            height: 30px;
            line-height: 30px;
            vertical-align: middle;
            font-size: 1.2em;
            font-weight: bold;
            padding-left: 50px;
            margin-top: -3px;
        }

        .menudesc {
            height: 30px;
            padding-left: 50px;
            line-height: 15px;
            overflow:hidden;
        }

        .menuul {
            list-style:none;
            border:1px solid #272b2e;
            width:96%;
            margin:5px auto; 
            border-radius:5px;
        }
            .menuul li {
                width:50%;
                text-align:center;                
                box-sizing:border-box;
                float:left;
                font-size:1em;
                height:26px;                
                line-height:26px;
                cursor:pointer;
            }
            .menuul li:first-child {
                border-right:1px solid #272b2e;
            }
        .mselected {
            background-color:#272b2e;
            color:#fff;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="headimg"></div>
        <p class="uname"><%=uName %></p>
        <p class="tel"><strong>Tel:</strong><%=uPhone %></p>        
    </div>
    <div class="container">
        <ul class="menuul floatfix">
            <li onclick="switchMode(1,this)" class="mselected">简单模式</li>
            <li onclick="switchMode(2,this)">说明模式</li>
        </ul>
        <div class="mypage" id="page1">
            <ul class="menulist floatfix">
                <li rel="wxsystem">
                    <div class="item">
                        <img src="../../res/img/bandtosystem/wxsys.png" />
                        <p class="itemtxt">企业应用开通</p>
                    </div>
                </li>
                <li>
                    <div class="item no-open" style="background: #e8960e;">
                        <img src="../../res/img/bandtosystem/bylicon.png" />
                        <p class="itemtxt">备忘录</p>
                    </div>
                </li>
                <!--<li>
                    <div class="item no-open" style="background: #d75847;">
                        <img src="../../res/img/bandtosystem/srdzicon.png" />
                        <p class="itemtxt">私人定制</p>
                    </div>
                </li>-->
                <li>
                    <div class="item no-open" style="background: #199aa7;">
                        <img src="../../res/img/bandtosystem/gzjhicon.png" />
                        <p class="itemtxt">工作报告</p>
                    </div>
                </li>
                <!--<li>
                    <div class="item no-open" style="background: #384a70;">
                        <img src="../../res/img/bandtosystem/kdcxicon.png" />
                        <p class="itemtxt">快递查询</p>
                    </div>
                </li>-->
            </ul>
        </div>
        <div class="mypage right" id="page2">
            <ul class="menulist2">
                <li rel="wxsystem">
                    <div class="item fixicon">
                        <img src="../../res/img/bandtosystem/wxsys.png" />
                    </div>
                    <p class="menuname">1.企业应用开通</p>
                    <p class="menudesc">用于自助开通利郎企业号中的各种应用系统，如订货会会务系统等。</p>
                </li>
                <li>
                    <div class="item fixicon" style="background: #e8960e;">
                        <img src="../../res/img/bandtosystem/bylicon.png" />
                    </div>
                    <p class="menuname">2.备忘录</p>
                    <p class="menudesc">用于记录您在工作中的一些提醒事项，并且可以利用企业号在指定时间提醒您。</p>
                </li>
                <!--<li>
                    <div class="item fixicon" style="background: #d75847;">
                        <img src="../../res/img/bandtosystem/srdzicon.png" />
                    </div>
                    <p class="menuname">3.私人定制</p>
                    <p class="menudesc">主要用于您在工作中的一些订阅服务。</p>
                </li>-->
                <li>
                    <div class="item fixicon" style="background: #199aa7;">
                        <img src="../../res/img/bandtosystem/gzjhicon.png" />
                    </div>
                    <p class="menuname">3.工作报告</p>
                    <p class="menudesc">方便您随时随地书写工作报告，后期还可以与ERP系统打通，实现数据的共享。</p>
                </li>
                <!--<li>
                    <div class="item fixicon" style="background: #384a70;">
                        <img src="../../res/img/bandtosystem/kdcxicon.png" />
                    </div>
                    <p class="menuname">5.快递查询</p>
                    <p class="menudesc">用于查询所有的快递信息记录。</p>
                </li>-->
            </ul>
        </div>
        <div class="mypage"></div>
    </div>
    <div class="footer">
        &copy;2017 利郎信息技术部
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type='text/javascript' src='../../res/js/StoreSaler/fastclick.min.js'></script>
    <script type='text/javascript' src='../../res/js/LeeJSUtils.min.js'></script>
    <script type="text/javascript">
        window.onload = function () {
            $(".header .headimg").css("background-image", "url(<%=uHeadImg%>)");
            FastClick.attach(document.body);
        }

        //var yy, YY, xx, XX;
        //var obj = document.getElementById("prevent-scroll");
        //if (obj != null) {
        //    obj.addEventListener('touchstart', function (event) {
        //        xx = event.targetTouches[0].screenX;
        //        yy = event.targetTouches[0].screenY;
        //    });

        //    obj.addEventListener('touchmove', function (event) {
        //        YY = event.targetTouches[0].screenY;

        //        if (YY < yy && obj.scrollTop + obj.clientHeight >= obj.scrollHeight) {
        //            event.preventDefault();
        //            event.stopPropagation();
        //            return;
        //        } else if (YY > yy && obj.scrollTop == 0) {
        //            event.preventDefault();
        //            event.stopPropagation();
        //            return;
        //        }
        //    });

        //    obj.addEventListener('touchend', function (event) {
        //        XX = event.changedTouches[0].screenX;
        //        YY = event.changedTouches[0].screenY;

        //        if (XX < xx && Math.abs(XX - xx) > 100) {
        //            $("#page1").addClass("left");
        //            $("#page2").removeClass("right");
        //        } else if (XX > xx && Math.abs(XX - xx) > 100) {
        //            $("#page1").removeClass("left");
        //            $("#page2").addClass("right");
        //        }
        //    });
        //}

        function switchMode(xh, obj) {
            if (xh == 2) {
                $("#page1").addClass("left");
                $("#page2").removeClass("right");
            } else if (xh == 1) {
                $("#page1").removeClass("left");
                $("#page2").addClass("right");
            }
            $(".menuul li").removeClass("mselected");
            $(obj).addClass("mselected");
        }

        function RedirectURL(name) {
            switch (name) {
                case "wxsystem":
                    window.location.href = "../bandtosystem/wxsystemguide.aspx";
                    break;
                default:
                    LeeJSUtils.showMessage("warn", "后期将推出更多功能，敬请期待...");
            }
        }

        $(".menulist li").click(function () {
            RedirectURL($(this).attr("rel"));
        });

        $(".menulist2 li").click(function () {
            RedirectURL($(this).attr("rel"));
        });
    </script>
</body>
</html>

