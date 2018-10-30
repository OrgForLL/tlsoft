<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>

<!DOCTYPE html>
<script runat="server">  
    string tzid;
    protected void Page_Load(object sender, EventArgs e)
    {
        tzid = "1";
        getWxConfig();
    }
    //配置参数
    public void getWxConfig()
    {
        List<string> config = clsWXHelper.GetJsApiConfig("1");
        appIdVal.Value = config[0];
        timestampVal.Value = config[1];
        nonceStrVal.Value = config[2];
        signatureVal.Value = config[3];
        useridVal.Value = clsWXHelper.GetAuthorizedKey(2);
        ScanCtrl.Value = Request.Params["ScanCtrl"];
        GetBasData(useridVal.Value);

    }
    public void GetBasData(string userid)
    {
        try
        {
            DataTable User = null;
            string userErroInfo = "";
            string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
            using (LiLanzDALForXLM data = new LiLanzDALForXLM(OAConnStr))
            {
                string sql = @"select a.xm as username from rs_t_ryxxb a where a.id=@userid ";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@userid", userid));
                userErroInfo = data.ExecuteQuerySecurity(sql, para, out User);
            }
            if (userErroInfo == "")
            {
                username.Value = User.Rows[0]["username"].ToString();
            }
            else
            {
                username.Value = "Net Fail";
            }
        }
        catch (Exception e)
        {
            username.Value = "无数据";
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/aui-scroll.js"></script>
    <script type="text/javascript" src="../../res/js/template.js"></script>
    <link rel="stylesheet" href="../../res/css/weui.min.css" />

    <script type="text/javascript">
        var userid, scanCtrl, username;
        $(document).ready(function () {
            
            userid = document.getElementById("useridVal").value;
            username = document.getElementById("username").value;
            scanCtrl = "jhjhcx";//document.getElementById("ScanCtrl").value;
            // if (userid == "" || userid == "0") {
            //alert("用户未登陆,不可用");
            //history.go(-1);
            //} else 
            if (scanCtrl == "jhjhcx") {
                $("#gzcx").css("visibility", "visible");
                $(document).attr("title", "交货计划查询");//修改title值"交货计划查询";
                $("#user").text("用户:" + username);
                var myDate = new Date();
                var yf = myDate.getMonth() + 1;         //获取当前月份
                var nf = myDate.getFullYear();      //获取完整的年份(4位,1970-????)
                var day = myDate.getDate(); //获取当前日期
                getny(nf, yf);
                getday(nf, yf, day);
                $(".ny p").text(nf + "年" + yf + "月" + day + '号');
                $("#ny").attr("value", nf.toString() + yf.toString());
                GetWageData(nf.toString() + '-' + yf.toString() + '-' + day.toString(), "1");
            }
            //设置年月页面样式
            function getny(nf, yf) {
                $(".nfsj a").remove();
                $(".nfsj ").append(nymb(nf - 2, "3", "datali_3", "年"));
                $(".yfsj a").remove();
                $(".yfsj ").append(nymb(1, "12", "datali_2", "月"));

                $(".nfsj a").each(function () {             //当前年份被选中
                    if ($(this).children().text().split("年")[0] == nf) {
                        $(this).addClass("datecolor");
                    }
                });
                $(".yf").eq(yf - 1).addClass("datecolor");//当前月份被选中

            }
            function getday(nf, yf, ts) {
                
                document.getElementById("mynyday").innerHTML = nf + "年" + yf + "月：";
                $(".daysj span").remove();
                $(".daysj ").append(nymb(1, "31", "datali_4", "号"));
                $(".day").eq(ts - 1).addClass("datecolor");
            }
            //控制显示月天数不一致
            function getdaynone(nf, yf, day) {
                var weekDay = ["星期天", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"];
                for (var m = 0 ; m <= 31; m++) {
                    var dt = new Date(nf, yf - 1, m+1);
                    $(".day a").eq(m).text(weekDay[dt.getDay()]);
                    if (m >= day) {
                        $(".day").eq(m).removeClass("dayblock")
                        $(".day").eq(m).addClass("daynone");
                    } else {
                        $(".day").eq(m).removeClass("daynone")
                        $(".day").eq(m).addClass("dayblock");
                    }
                }
            }
            //年月模板 参数：起始数据；循环次数；模板id；数据单位
            function nymb(begin, length, temp, unit) {
                var html = "";
                var a = begin - 1;
                if (begin == "") {
                    a = 0;
                }
                for (var i = 1; i <= length; i++) {
                    var data = { list: a + i + unit };
                    html += template(temp, data);
                }
                return html;
            }

            //筛选事件
            $(".filterdiv").click(function () {

                $(".mymask").show();
                $("#fiterpage").removeClass("page-right");
            });
            //蒙层事件
            $(".mymask").click(function () {

                $(".mymask").hide();
                $("#fiterpage").addClass("page-right");
            });
            $(".myday").click(function () {
                $(".myday").hide();
                $("#afiterpage1").addClass("page-right");
            });
            //年月的点击事件
            $(".filtercontainer1 a").click(function () {
                var djyf = $(this).attr("class").indexOf("yf");
                var djnf = $(this).attr("class").indexOf("nf");
                if (djyf > -1) {

                    setColor("yf", "datecolor", this);
                    $("#fiterpage").addClass("page-right");
                    $("#afiterpage1").removeClass("page-right");
                    $(".mymask").hide();
                    var nf = getEle("nf", "datecolor", "年");            //获取当前被选中的年份
                    var yf = $(this).children().text().split("月")[0];   //获取当前点击的月份
                    document.getElementById("mynyday").innerHTML = nf + "年" + yf + "月：";
                    var day = new Date(nf, yf, 0);
                    var daycount = day.getDate();
                    //alert(day);
                    getdaynone(nf,yf,daycount);
                    $(".myday").show();
                    
                }
                if (djnf > -1) {
                    setColor("nf", "datecolor", this);
                }
            });
            $(".afiltercontainer span").click(function () {
                var djday = $(this).attr("class").indexOf("day");
                if (djday > -1) {
                    setColor("day", "datecolor", this);
                    $("#afiterpage1").addClass("page-right");
                    $(".myday").hide();
                    var nf = getEle("nf", "datecolor", "年");            //获取当前被选中的年份
                    var yf = getEle("yf", "datecolor", "月");   //获取当前点击的月份
                    var day = $(this).children().text().split("号")[0];
                    //getday(nf, yf);
                    $(".ny p").text(nf + "年" + yf + "月" + day + "号");              // 设置标题上的年月
                    $("#ny").attr("value", nf.toString() + yf.toString() + day.toString()); //alert(nf + '-' + yf + '-' + day);
                    GetWageData(nf + '-' + yf + '-' + day, "1");
                }
            });
            //点击的元素填充颜色 
            function setColor(type, color, ele) {
                $("." + type).each(function () {
                    if ($(this).attr("class").indexOf(color) > -1) {
                        $(this).removeClass(color);
                    }
                })
                $(ele).addClass(color);
            }

            //获取指定的一类元素中包含某一属性的元素text
            function getEle(type, cs, val) {
                var a = "";
                $("." + type).each(function () {
                    if ($(this).attr("class").indexOf(cs) > -1) {
                        a = $(this).children().text().split(val)[0];
                    }
                });
                return a;
            }

            var scroll = new auiScroll({
                listen: true, //是否监听滚动高度，开启后将实时返回滚动高度
                distance: 2 //判断到达底部的距离，isToBottom为true
            }, function (ret) {
                console.log(ret)
                //alert(ret.scrollTop);
            });


        });
        //获取数据
        function GetWageData(result, id) {
            //alert(result);
            ShowLoading("数据查询中...");
            var subData = { userid: document.getElementById("useridVal").value }
            subData.ctrl = "GetWageData";
            subData.ny = result;
            subData.lastid = id;
            url = "sc_cl_jhjh_core.aspx";
            setTimeout(function () { openAjax(url, subData, setWage, setFail); }, 50);
        }

        //获取数据成功处理
        function setWage(msg) {
            //alert(msg);
            if (msg.indexOf("Error") == -1 && msg != "") {
                var datas = JSON.parse(msg);
                var len = datas.rows.length;
                var html = "";

                for (var i = 0; i < len; i++) {
                    var row = datas.rows[i];
                    html += template("datali_1", row);
                }//end for

                //$("#jhjh .data-ul li:not(:first-child)").remove();
                $("#jhjh .data-container .u-more-btn").remove();
                $("#jhjh .data-ul li").eq(0).nextAll().remove();
                $("#jhjh .data-ul").append(html);
                $("#jhjh").removeClass("page-right");
                //StaticCount("jhjh");
                HideLoading();
                if (len >= 50) {
                    var lastid = datas.rows[len - 1]["id"];
                    var dqny = $("#ny").val();
                    var tmp = " <div class='u-more-btn'><a href='javascript:GetWageData(&apos;$dqny$&apos;,&apos;$lastid$&apos;);' id='u-more-btn'>-- 查看更多 --</a></div>";
                    var htmlstr = tmp.replace("$dqny$", dqny).replace("$lastid$", lastid);
                    $("#jhjh .data-container").append(htmlstr);
                }
            }
            else if (msg == "") {
                $("#jhjh .data-ul li:not(:first-child)").remove();
                ShowLoading("查询无结果！");
                ClearStatics("jhjh");
            } else
                HideLoading();
        }


        function setFail() {
            //RollBack("clear");
            ShowLoading("数据连接失败...");
        }

        //打开Ajax
        function openAjax(url, subData, sfun, ffun) {
            $.ajax({
                type: "POST",
                timeout: 2000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: url,
                data: subData,
                success: sfun,
                error: ffun
            });//end AJAX
        }

        //显示加载栏目
        function ShowLoading(Info, ShowTime) {
            if (ShowTime == undefined || ShowTime == "undefined") {
                ShowTime = 15;      //默认弹出15s
            };
            $("#LoadingInfo").html(Info);
            var $loadingToast = $('#loadingToast');
            if ($loadingToast.css('display') != 'none') {
                return;
            }

            $loadingToast.show();
            setTimeout(function () {
                $loadingToast.hide();
            }, ShowTime * 1000);
        }

        //隐藏加载栏目
        function HideLoading() {
            $('#loadingToast').hide();
        }

        //汇总数据
        function StaticCount(id) {
            var s_sl = 0, s_je = 0;
            var ulobj = $("#" + id + " .data-ul li");
            for (var i = 1; i < ulobj.length; i++) {
                var row = ulobj.eq(i);
                var je = ($("p[col='je']", row).text());
                var sl = ($("p[col='sl']", row).text());
                if (je == "")
                    je = "0";
                if (sl == "")
                    sl = "0";
                s_sl += parseInt(sl);
                s_je += parseInt(je);
            }//end for

            $("#" + id + " [col='s-sl']").text(GetJeText(s_sl));
            $("#" + id + " [col='s-je']").text(GetJeText(s_je));
        }

        //对汇总的数据格式化
        function GetJeText(xsje) {
            if (xsje == "") return "--";
            else {
                var intxsje = parseInt(xsje);

                if (intxsje < 100000) return intxsje;
                else return parseInt(intxsje * 0.0001).toString() + "万+";
            }
        }

    </script>
    <style type="text/css">
        html, body {
            width: 100%;
            height: 100%;
            display: block;
        }

        .page {
            display: block;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            width: 100%;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;
            background-color: #fff;
            z-index: 1000;
            padding: 10px;
            -webkit-transform: translate3d(0, 0, 0);
            transform: translate3d(0, 0, 0);
            -webkit-transition: -webkit-transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            -ms-transition: transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            transition: transform 300ms cubic-bezier(0.42, 0, 0.58, 1);
            -webkit-transform-style: preserve-3d;
            -webkit-backface-visibility: hidden;
        }

        .page-not-header {
            top: 50px;
            bottom: 0;
        }

        .page-right {
            -webkit-transform: translate3d(100%, 0, 0);
            transform: translate3d(100%, 0, 0);
            top: 100%;
        }

        .data-container {
            position: absolute;
            top: 0;
            bottom: 40px;
            left: 0;
            width: 100%;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            overflow-scrolling: touch;
        }

        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }

        p.data-item[hidden] {
            display: none;
        }

        .static_count .col4 {
            text-align: center;
            font-weight: bold !important;
            font-size: 14px;
        }

        .col15 {
            width: 15%;
            text-align: right;
        }

        .data-item {
            float: left;
            width: 10%;
            text-align: center;
            border-bottom: 1px solid #e5e5e5;
            padding: 0 3px;
            margin-bottom: -1000px;
            padding-bottom: 1000px;
            margin-top: -1000px;
            padding-top: 1000px;
        }

            .data-item.sorted {
                color: #00bec5;
            }

        .data-ul li:first-child .data-item {
            text-align: center;
        }

        .item-head {
            font-weight: bold;
            height: 32px;
            line-height: 32px;
            font-size: 12px;
            padding: 0 !important;
            list-style-type: none;
        }

            .item-head .col4 {
                text-align: center;
            }

        .static_count {
            position: absolute;
            left: 0;
            width: 100%;
            bottom: 0;
            height: 40px;
            background-color: #1cc1c7;
            background-color: #f9f9f9;
            border-top: 1px solid #dedede;
            line-height: 40px;
            overflow: hidden;
        }

            .static_count li {
                float: left;
            }

        .data-ul li {
            color: #0f0f0f;
            overflow: hidden;
            padding: 8px 0;
        }

            .data-ul li:not(:last-child) {
                border-bottom: 1px solid #e5e5e5;
            }

            .data-ul li:first-child .data-item {
                text-align: center;
            }

        .floatfix li {
            list-style-type: none;
        }

        .header .fa-filter {
            font-size: 15px;
        }

        .header {
            height: 50px;
            background-color: #ccc;
            width: 100%;
            top: 0;
            left: 0;
            position: fixed;
        }

            .header .fa-angle-left {
                color: #fff;
                position: absolute;
                top: 0;
                left: 0;
                height: 44px;
                padding: 0 15px;
                line-height: 44px;
                text-align: center;
                z-index: 100;
            }

        .container {
            width: 1000px;
            overflow-y: auto;
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
        }

        .user {
            float: left;
            width: 30%;
            height: 40px;
            line-height: 40px;
            padding: 5px;
            font-size: 16px;
        }

            .user p {
                height: 100%;
                margin-left: 5px;
            }

        .filterdiv {
            position: absolute;
            height: 40px;
            width: 20%;
            top: 0;
            right: 0;
            padding: 5px;
            line-height: 40px;
            font-size: 16px;
            color: #000;
        }

            .filterdiv p {
                margin-right: 20px;
                float: right;
            }

        .afiltercontainer {
            background-color: #efefef;
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0px;
            overflow-y: auto;
            width: 288px;
        }

        .filtercontainer1 {
            background-color: #efefef;
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0px;
            overflow-y: auto;
            width: 288px;
        }

        .mymask {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0,0,0,0.4);
            z-index: 2000;
            display: none;
        }

        .myday {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0,0,0,0.4);
            z-index: 2000;
            display: none;
        }

        #fiterpage {
            position: fixed;
            width: 288px;
            right: 0;
            left: initial;
            z-index: 2001;
            background-color: transparent;
        }

        #afiterpage1 {
            position: fixed;
            width: 288px;
            right: 0;
            left: initial;
            z-index: 2001;
            background-color: transparent;
        }

        .fbtns {
            height: 42px;
            line-height: 42px;
            background-color: #cffbfc;
            position: fixed;
            left: 0;
            width: 100%;
            bottom: 0;
            font-size: 0;
            z-index: 3000;
        }

            .fbtns a {
                color: #16bbbf;
                width: 50%;
                display: inline-block;
                font-size: 16px;
                font-weight: bold;
                text-align: center;
                letter-spacing: 2px;
            }

        .farea .date {
            width: 270px;
            margin: 0 auto;
            height: 48px;
            background-color: #dedfe3;
            text-align: center;
        }

        .nopadding {
            padding: 0px;
        }

        .farea .title {
            height: 40px;
            line-height: 40px;
            color: #a4a4a6;
            font-weight: bold;
            padding: 0 15px;
        }

        .farea .fitem {
            width: 76px;
            padding: 8px 5px;
            float: left;
            background-color: #dedfe3;
            text-align: center;
            margin-left: 15px;
            margin-bottom: 15px;
            border-radius: 2px;
            color: #4d4e52;
            font-weight: bold;
        }

        .farea .date {
            width: 258px;
            margin: 0 auto;
            height: 48px;
            background-color: #dedfe3;
            text-align: center;
        }

        .date input {
            -webkit-appearance: none;
            border: none;
            border-radius: 0;
            height: 32px;
            width: 105px;
            margin: 8px 4px;
            font-size: 12px;
            padding-left: 5px;
            width: 110px;
            margin: 8px 0px;
        }

        .date .line {
            border: 1px solid #98989a;
            height: 1px;
            width: 20px;
            display: inline-block;
        }

        .date input {
            width: 110px;
            margin: 8px 0px;
            height: 60%;
        }

        .ny {
            text-align: center;
            width: 40%;
        }

        .datecolor {
            background-color: #16bbbf;
        }
        .daynone {
            display:none;
        }
        .dayblock {
            display:block;
        }
        .u-more-btn {
            text-align: left;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <input type="hidden" runat="server" id="appIdVal" />
    <input type="hidden" runat="server" id="timestampVal" />
    <input type="hidden" runat="server" id="nonceStrVal" />
    <input type="hidden" runat="server" id="signatureVal" />
    <input type="hidden" runat="server" id="useridVal" />
    <input type="hidden" runat="server" id="ScanCtrl" />
    <input type="hidden" runat="server" id="username" />
    <input type="hidden" runat="server" id="ny" />
    <!-- 数据显示 -->
    <div id="gzcx" class="container" style="visibility: hidden;">
        <div id="header" class="header">
            <div class="user">
                <p id="user"></p>
            </div>
            <div class="user ny">
                <p></p>
            </div>
            <div class="filterdiv">
                <p onclick="">筛选</p>
                <i class="fa fa-filter">
                    <br />
                </i>
            </div>
        </div>
        <div class="page page-not-header page-right" id="jhjh">
            <div class="data-container">
                <ul class="data-ul floatfix">

                    <li class="item-head fixed">
                        <p class="data-item col4" col="mc">生产线</p>
                        <p class="data-item col15" col="spkh">商品款号</p>
                        <p class="data-item col15" col="sl">目标产量</p>
                        <p class="data-item col15" col="dqmb">实际产量</p>
                        <p class="data-item col15" col="dcl">日目标达成率(%)</p>
                        <p class="data-item col15" col="lpl">良品率(%)</p>
                        <p class="data-item col15" col="rjcl">人均产量</p>
                        <p class="data-item col15" col="kqrs">考勤人数</p>
                    </li>

                </ul>

            </div>

        </div>
    </div>
    <!--右侧筛选页-->
    <div class="page page-right nopadding" id="fiterpage">
        <div class="filtercontainer1">
            <!--九宫格日期-->
            <div class="page grid js_show nopadding">
                <div class="farea">
                    <p class="title">年份:</p>
                </div>
                <div class="weui_grids nfsj">
                </div>
                <div class="farea">
                    <p class="title">月份:</p>
                </div>
                <div class="weui_grids yfsj">
                </div>
            </div>
        </div>

    </div>
    <div class="page page-right nopadding" id="afiterpage1">
        <div class="afiltercontainer">
            <div class="page grid js_show nopadding">
                <div class="farea">
                    <p id="mynyday" class="title"></p>
                </div>
                <div class="weui_grids daysj">
                </div>
            </div>
        </div>
    </div>
    <div class="mymask"></div>
    <div class="myday"></div>
    <!-- 模板 -->
    <!-- 内容页模板 -->
    <script id="datali_1" type="text/html">
        <li>
            <p class="data-item col4  underline" col="mc">{{mc}}</p>
            <p class="data-item col15  " col="spkh">{{spkh}}</p>
            <p class="data-item col15 underline"  col="sl">{{sl}}</p>
            <p class="data-item col15" col="dqmb">{{dqmb}}</p>
            <p class="data-item col15" col="dcl">{{dcl}}</p>
            <p class="data-item col15" col="lpl">{{lpl}}</p>
            <p class="data-item col15" col="rjcl">{{rjcl}}</p>
            <p class="data-item col15" col="kqrs">{{kqrs}}</p>
        </li>
    </script>
    <!-- 月份模板 -->
    <script id="datali_2" type="text/html">
        <a class="weui_grid yf">
            <p class="weui_grid_label" col="list">{{list}}</p>
        </a>
    </script>
    <!-- 天数模板 -->
    <script id="datali_4" type="text/html">
        <span class="weui_grid day">
            <p class="weui_grid_label" col="list">{{list}}</p>
            <a class="weui_grid_label" col="list"></a>
        </span>
    </script>
    <!-- 年份模板 -->
    <script id="datali_3" type="text/html">
        <a class="weui_grid nf">
            <p class="weui_grid_label" col="list">{{list}}</p>
        </a>
    </script>

    <!-- 加载提示框 -->
    <div id="loadingToast" class="weui_loading_toast" style="display: none; position: fixed; z-index: 99999">
        <div class="weui_mask_transparent"></div>
        <div class="weui_toast">
            <div class="weui_loading">
                <div class="weui_loading_leaf weui_loading_leaf_0"></div>
                <div class="weui_loading_leaf weui_loading_leaf_1"></div>

            </div>
            <p class="weui_toast_content" id="LoadingInfo">数据加载中</p>
        </div>
    </div>
</body>
</html>
