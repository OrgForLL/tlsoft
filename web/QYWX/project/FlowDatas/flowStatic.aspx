<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<!DOCTYPE html>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        //默认鉴权，传入参数oauth=0不鉴权
        string oauth = Convert.ToString(Request.Params["oauth"]);
        if (oauth != "0") {
            if (clsWXHelper.CheckQYUserAuth(true)) {
                string AppSystemKey = clsWXHelper.GetAuthorizedKey(3);
                string RoleName = Convert.ToString(Session["RoleName"]);
                if (RoleName != "zb" && RoleName != "kf")
                    clsWXHelper.ShowError("对不起，您没有使用权限！");
            }        
        }
    }
</script>
<html>
<head>
    <meta charset="utf-8" />
    <title>流量统计</title>
    <style type="text/css">
        * {
            margin: 0;
            padding: 0;
        }

        ul {
            list-style: none;
        }

        a {
            text-decoration: none;
        }

        input {
            -webkit-appearance: none;
        }

        body {
            font-family: "Microsoft Yahei","微软雅黑",Helvetica,Arial,STHeiTi,"Hiragino Sans GB",STHeiti,"华文细黑",sans-serif;
            font-size: 14px;
            color: #303030;
            background-color: #f2f2f2;
            min-width: 600px;
            overflow: auto;
        }

        .top_title {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 50px;
            border-bottom: 4px solid #0ea588;
            background-color: #f2f2f2;
            z-index: 100;
        }

            .top_title .title {
                font-size: 16px;
                font-weight: bold;
                line-height: 50px;
                letter-spacing: 2px;
                padding-left: 20px;
                color: #303030;
            }

        .charts {
            width: 880px;
            height: 600px;
            background-color: transparent;
            margin: 15px auto;
            clear: both;
        }

            .charts canvas {
                position: relative;
                z-index: 100;
            }

            .charts > div {
                border: 1px solid #ddd;
            }

        .datetime {
            position: absolute;
            right: 20px;
            bottom: 10px;
        }

        .content {
            position: absolute;
            top: 50px;
            bottom: 0;
            left: 0;
            width: 100%;
            overflow: auto;
            min-width: 600px;
        }

        .filter_wrap {
            display: table;
            clear: both;
            padding: 0 10px;
            position: relative;
        }

        .filter_item {
            float: left;
            margin: 15px 0 0 0;
            width: 120px;
        }

            .filter_item > .label {
                color: #fff;
                font-weight: bold;
                vertical-align: middle;
                background-color: #0ea588;
                text-align: center;
                padding: 4px 7px;
                width: 100%;
            }

            .filter_item input {
                width: 100%;
                outline: none;
                border: 1px solid #ccc;
                padding: 4px 6px;
                text-align: center;
            }

            .filter_item select option {
                padding: 5px;
            }

        .submit_btn {
            padding: 4px 16px;
            background-color: #2f4554;
            color: #fff;
            height: 100%;
            display: block;
            float: left;
            height: 44px;
            line-height: 44px;
            font-weight: bold;
            margin: 15px 0 0 0;
        }

        .models {
            position: absolute;
            top: 70px;
            left: 10px;
            width: 240px;
            max-height: 500px;
            overflow: auto;
            display: none;
            z-index: 2000;
            background-color: #fff;
        }

            .models li {
                text-align: center;
                width: 220px;
                height: 32px;
                line-height: 32px;
                border-bottom: 1px solid #ddd;
                cursor: pointer;
            }

                .models li:hover {
                    background-color: #0ea588;
                    color: #fff;
                }

        #func_input {
            cursor: pointer;
        }

        .my_mask {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgb(0,0,0);
            opacity: 0.6;
            filter: alpha(opacity=60);
            z-index: 9998;
            display: none;
        }

        .my_toast {
            position: fixed;
            z-index: 9999;
            width: 320px;
            height: 80px;
            line-height: 80px;
            color: #303030;
            background-color: #f7f7f7;
            text-align: center;
            position: absolute;
            top: 50%;
            left: 50%;
            margin-top: -40px;
            margin-left: -160px;
            display: none;
        }
    </style>
</head>
<body>
    <!--遮罩层-->
    <div class="my_mask"></div>
    <div class="my_toast">正在统计，请稍候..</div>

    <div class="top_title">
        <span class="title">利郎【销售神器】流量统计 Beta0.1</span>
        <span class="datetime" id="nowtime">--</span>
    </div>
    <div class="content">
        <div class="filter_wrap">
            <div class="filter_item" id="func_input">
                <p class="label">-功能模块-</p>
                <input type="text" value="单击选择" data-lx="" onclick="switchList()" data-name="functions" />
                <ul class="models" data-status="close">
                    <!--<li data-lx="1">邀请会员1</li>-->
                </ul>
            </div>
            <div class="filter_item">
                <p class="label">-开始日期-</p>
                <input type="text" data-name="startDate" id="startDate" onclick="JTC.setday()" />
            </div>
            <div class="filter_item" style="margin-right: 30px;">
                <p class="label">-结束日期-</p>
                <input type="text" data-name="endDate" id="endDate" onclick="JTC.setday()" />
            </div>
            <a href="javascript:staticNow();" class="submit_btn">统 计</a>
        </div>
        <div id="chart_line_bar" class="charts"></div>
    </div>
    <script type="text/javascript" src="../../res/js/echarts.min.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/FlowDatas/JTimer_1.3.js"></script>
    <script type="text/javascript">
        function showLocale(objD) {
            var str, colorhead, colorfoot;
            var yy = objD.getYear();
            if (yy < 1900) yy = yy + 1900;
            var MM = objD.getMonth() + 1;
            if (MM < 10) MM = '0' + MM;
            var dd = objD.getDate();
            if (dd < 10) dd = '0' + dd;
            var hh = objD.getHours();
            if (hh < 10) hh = '0' + hh;
            var mm = objD.getMinutes();
            if (mm < 10) mm = '0' + mm;
            var ss = objD.getSeconds();
            if (ss < 10) ss = '0' + ss;
            var ww = objD.getDay();
            if (ww == 0) colorhead = "<font color=\"#FF0000\">";
            if (ww > 0 && ww < 6) colorhead = "<font color=\"#373737\">";
            if (ww == 6) colorhead = "<font color=\"#008000\">";
            if (ww == 0) ww = "星期日";
            if (ww == 1) ww = "星期一";
            if (ww == 2) ww = "星期二";
            if (ww == 3) ww = "星期三";
            if (ww == 4) ww = "星期四";
            if (ww == 5) ww = "星期五";
            if (ww == 6) ww = "星期六";
            colorfoot = "</font>"
            str = colorhead + yy + "年" + MM + "月" + dd + "日 " + hh + ":" + mm + ":" + ss + " " + ww + colorfoot;
            return (str);
        }

        function timeTsick() {
            var today;
            today = new Date();
            document.getElementById("nowtime").innerHTML = showLocale(today);
            window.setTimeout("timeTsick()", 1000);
        }

        window.onload = function () {
            timeTsick();
            var now = new Date();
            var nowStr = now.format("yyyy-MM-dd");
            //允许跨月，但最多不许超过31天。默认是15天前到当天
            $("#startDate").val(getBeforeDate(30));
            $("#endDate").val(nowStr);
            loadFuncs();
        }

        function switchList() {
            var status = $("#func_input .models").attr("data-status");
            if (status == "open")
                $("#func_input .models").attr("data-status", "close").hide();
            else
                $("#func_input .models").attr("data-status", "open").show();
        }

        function GetDateDiff(startDate, endDate) {
            var startTime = new Date(Date.parse(startDate.replace(/-/g, "/"))).getTime();
            var endTime = new Date(Date.parse(endDate.replace(/-/g, "/"))).getTime();
            var dates = Math.abs((startTime - endTime)) / (1000 * 60 * 60 * 24);
            return dates;
        }

        Date.prototype.format = function (format) {
            var o = {
                "M+": this.getMonth() + 1, //month 
                "d+": this.getDate(), //day 
                "h+": this.getHours(), //hour 
                "m+": this.getMinutes(), //minute 
                "s+": this.getSeconds(), //second 
                "q+": Math.floor((this.getMonth() + 3) / 3), //quarter 
                "S": this.getMilliseconds() //millisecond 
            }

            if (/(y+)/.test(format)) {
                format = format.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
            }

            for (var k in o) {
                if (new RegExp("(" + k + ")").test(format)) {
                    format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k] : ("00" + o[k]).substr(("" + o[k]).length));
                }
            }
            return format;
        }

        function getBeforeDate(n) {
            var n = n;
            var d = new Date();
            var year = d.getFullYear();
            var mon = d.getMonth() + 1;
            var day = d.getDate();
            if (day <= n) {
                if (mon > 1) {
                    mon = mon - 1;
                }
                else {
                    year = year - 1;
                    mon = 12;
                }
            }
            d.setDate(d.getDate() - n);
            year = d.getFullYear();
            mon = d.getMonth() + 1;
            day = d.getDate();
            s = year + "-" + (mon < 10 ? ('0' + mon) : mon) + "-" + (day < 10 ? ('0' + day) : day);
            return s;
        }

        function showMessage(type, text) {
            $(".my_mask").show();
            $(".my_toast").text(text).show();
            if (type == "error" || type == "warn") {
                setTimeout(function () {
                    $(".my_mask").hide();
                    $(".my_toast").hide();
                }, 2000);
            }
        }

        // 基于准备好的dom，初始化echarts实例
        var lbchart = echarts.init(document.getElementById('chart_line_bar'));
        // 指定图表的配置项和数据
        var option = {
            tooltip: {
                trigger: 'axis'
            },
            color: ["#0ea588", "#f29343"],
            legend: {
                bottom: "bottom",
                data: ['浏览次数', '访问人数']
            },
            xAxis: [
                {
                    type: 'category',
                    data: []
                }
            ],
            yAxis: [
                {
                    type: 'value',
                    name: '浏览次数',
                    min: 0,
                    axisLabel: {
                        formatter: '{value} 次'
                    }
                },
                {
                    type: 'value',
                    name: '访问人数',
                    min: 0,
                    axisLabel: {
                        formatter: '{value} 人'
                    }
                }
            ],
            series: [
                {
                    name: '浏览次数',
                    type: 'line',
                    data: []
                },
                {
                    name: '访问人数',
                    type: 'bar',
                    yAxisIndex: 1,
                    data: []
                }
            ]
        };

        function formCheck() {
            var pageid = $("input[data-name='functions']").attr("data-lx");
            var ksrq = $("#startDate").val();
            var jsrq = $("#endDate").val();
            if (pageid == "" || typeof (pageid) == "undefined") {
                showMessage("error", "请选择要统计的功能模块...");
                return false;
            }
            else if (ksrq == "") {
                showMessage("error", "开始日期不能为空！");
                return false;
            }
            else if (jsrq == "") {
                showMessage("error", "结束日期不能为空！");
                return false;
            } else
                return true;
        }

        //绘制图表函数
        function drawChart() {
            showMessage("loading", "正在统计数据，请稍候...");
            if (formCheck()) {
                $.ajax({
                    type: "POST",
                    timeout: 15 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "flowDataCore.aspx",
                    data: { ctrl: "staticFlow", pageid: $("input[data-name='functions']").attr("data-lx"), ksrq: $("#startDate").val(), jsrq: $("#endDate").val() },
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1)
                            showMessage("error", msg.replace("Error:", ""));
                        else {
                            var rows = eval("[" + msg + "]")[0];
                            if (rows.rows.length == 0)
                                showMessage("warn", "对不起，暂无数据..");
                            else {
                                option.xAxis[0].data = [];
                                option.series[0].data = [];
                                option.series[1].data = [];
                                for (var i = 0; i < rows.rows.length; i++) {
                                    var row = rows.rows[i];
                                    option.xAxis[0].data.push(row.rq);
                                    option.series[0].data.push(row.pv);
                                    option.series[1].data.push(row.users);
                                }//end for

                                //设置坐标轴的值
                                var maxY = Math.max.apply(null, option.series[0].data);
                                maxY = parseInt(maxY * 1.15);
                                option.yAxis[0].max = maxY;
                                option.yAxis[1].max = maxY;
                                // 使用刚指定的配置项和数据显示图表。
                                lbchart.setOption(option);
                                $(".my_mask").hide();
                                $(".my_toast").hide();
                            }
                        }//end else
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        showMessage("error", "网络出错，请稍候再试..");
                    }
                });//end AJAX
            }
        }

        //统计按钮
        function staticNow() {
            var ksrq = $("#startDate").val();
            var jsrq = $("#endDate").val();
            if (parseInt(GetDateDiff(ksrq, jsrq)) > 31) {
                showMessage("warn", "对不起，日期查询范围不能超过一个月！");
                return;
            } else {
                drawChart();
            }
        }

        //加载功能模块列表
        function loadFuncs() {
            showMessage("loading", "正在初始化..");
            $.ajax({
                type: "POST",
                timeout: 5 * 1000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "flowDataCore.aspx",
                data: { ctrl: "loadFuncs" },
                success: function (msg) {
                    if (msg.indexOf("Error:") > -1)
                        showMessage("error", msg.replace("Error:", ""));
                    else {
                        if (msg.indexOf("Error:") > -1)
                            showMessage("error", msg.replace("Error:", ""));
                        else {
                            var html = "";
                            var liTemp = "<li data-lx='#pageId#'>#pageName#</li>";
                            var rows = eval("[" + msg + "]")[0];
                            if (rows.rows.length == 0)
                                showMessage("warn", "对不起，暂无数据..");
                            else {
                                for (var i = 0; i < rows.rows.length; i++) {
                                    var row = rows.rows[i];
                                    html += liTemp.replace("#pageId#", row.pageid).replace("#pageName#", row.pagename);
                                }//end for
                                $(".models").html(html);
                                $("#func_input .models li").click(function () {
                                    $("input[data-name='functions']").val($(this).text());
                                    $("input[data-name='functions']").attr("data-lx", $(this).attr("data-lx"));
                                    $("#func_input .models").attr("data-status", "close").hide();
                                });
                            }
                        }

                        $(".my_mask").hide();
                        $(".my_toast").hide();
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    showMessage("error", "网络出错，请稍候再试..");
                }
            });//end AJAX
        }
    </script>
</body>
</html>
