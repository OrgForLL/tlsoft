<%@ Page Language="C#" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html>
<script runat="server">
    String ksrq = "", jsrq = "";
    private const string ConfigKeyValue = "1";	//微信配置信息索引值 1为企业号    
    public string ccid = "-1-%", khid = "", khmc = "", mdid = "", mdmc = "";
    private string DBConstr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ksrq = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).ToString("yyy-MM-dd");
            jsrq = DateTime.Now.ToString("yyyy-MM-dd");
        }

        if (clsWXHelper.CheckQYUserAuth(true))
        {        
            string userid = Convert.ToString(Session["qy_customersid"]);
            //潘总-2578
            //罗小兰-2
            //官部-138
            //小姚-34
            //小薛-587
            //李清峰-354
            //林文印-352 
            //陈宏胜-52
            //周润芝-113
            //梁超-480
            //包妹-1023
            if (userid != "2578" && userid != "2" && userid != "138" && userid != "34" && userid != "587" && userid != "354" && userid != "352" && userid != "52" && userid != "113" && userid != "480" && userid != "1023")
            {
                clsWXHelper.ShowError("对不起您无权限使用此模块！");
                return;
            }
        }
        else
        {
            clsWXHelper.ShowError("鉴权失败！");
        }
    }
</script>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="format-detection" content="telephone=yes" />
    <title>按客户汇总</title>
    <script type="text/javascript" src="../../../res/js/Chart.min.js"></script>
    <script type="text/javascript" src="../../../res/js/jquery.js"></script>
    <link rel="stylesheet" href="../../../res/css/meeting/chartstyle.css" type="text/css" />
    <style type="text/css">
        #mytable a {
            color: Red;
        }

        #lite {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            white-space: nowrap;
            height: 50px;
            box-sizing: border-box;
        }

        #mytable a {
            color:blue;
            text-decoration:underline;
        }
    </style>
    <script type="text/javascript">
        var limitPer = 0.007; //阀值
        var sumSl = 0, sumJe = 0, sumSKU = 0;
        var lSKU = 0, lSl = 0, lJe = 0;
        var skuPie, slPie, jePie;

        //字段排序用
        var orderFiled = "khdm";
        var orderMode = "ASC";
        var orderName = "khdm";
        var myorderInfo = "";
        var ccidval = "<%=ccid%>";

        $(document).ready(function (e) {
            // $("#load").css("display", "none");            
            if (ccidval == "" || ccidval == "underfine") {
                alert("读取用户身份信息失败！请重新登录。");
                return;
            }
            var ksrq = new Date();
            var jsrq = new Date();
            ksrq.setDate(1);
            $("#ksrq").val(ksrq.format("yyyy-MM-dd"));
            $("#jsrq").val(jsrq.format("yyyy-MM-dd"));
            var litepf = ($(window).width() - 840) / 2 + "px";
            $("#lite").css("padding-left", litepf);
            
            $.ajax({
                url: "KhReportData.aspx",
                type: "POST",
                data: { orderInfo: "khdm ASC", ksrq: $("#ksrq").val(), jsrq: $("#jsrq").val(), ccid: ccidval, approve: $("#approve").val() },
                dataType: "text",
                contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                timeout: 60000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("您的网络好像出了点问题,请稍后重试...");
                },
                success: function (datas) {
                    var data = JSON.parse(datas);
                    if (data.err != "") {
                        $("#mycontent").css("display", "none");
                        $("#mytable").empty();
                        $("#mytable").append(data.err);                        
                    } else {
                        //判断数据
                        $("#mycontent").css("display", "");
                        CountNum(data);
                        drawTabChart(data, 1);
                    }
                    $("#load").fadeOut("slow");
                }//end success
            });

        });

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
        function CountNum(data) {
            sumSl = parseInt(data.sSl);
            sumJe = parseInt(data.sJe);
            sumSKU = parseInt(data.sSKU);
            lSKU = limitPer * sumSKU;
            lSl = limitPer * sumSl;
            lJe = limitPer * sumJe;
        }
        //金额格式化函数
        function fmoney(s, n) {
            n = n > 0 && n <= 20 ? n : 2;
            s = parseFloat((s + "").replace(/[^\d\.-]/g, "")).toFixed(n) + "";
            var l = s.split(".")[0].split("").reverse(),
                r = s.split(".")[1];
            t = "";
            for (i = 0; i < l.length; i++) {
                t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length ? "," : "");
            }
            return t.split("").reverse().join("") + "." + r;
        }
        function drawTabChart(data, isdrawpie) {            
            var tableHtml = "<table class='bordered'><thead><tr>"
            + "<th id='thdm'   onclick=\"SetOrder(this,'khdm')\">客户代码</th>"
            + "<th id='thmc'   onclick=\"SetOrder(this,'khmc')\">客户名称</th>"
            + "<th id='thsku'  onclick=\"SetOrder(this,'sku')\">SKU</th>"
            + "<th id='thsl'   onclick=\"SetOrder(this,'sl')\">数量</th>"
            + "<th id='thje'   onclick=\"SetOrder(this,'je')\">金额</th>"
            + "<th id='thjezb' onclick=\"SetOrder(this,'je')\">金额占比</th></tr></thead><tbody>";
            var slArry = new Array(), jeArray = new Array(), skuArray = new Array();
            var tSl, tJe, tSKU, tJeScale, color;
            var otherSl = 0, otherJe = 0, otherSKU = 0;
            for (var i = 0; i < data.rows.length; i++) {
                tSl = data.rows[i].sl;
                tJe = data.rows[i].je;
                tSKU = data.rows[i].sku;
                //随机取颜色
                color = '#' + ('00000' + (Math.random() * 0x1000000 << 0).toString(16)).slice(-6);
                //金额占比
                tJeScale = (parseFloat(data.rows[i].je) / parseFloat(sumJe) * 100).toFixed(2).toString();
                //构造表格  <a href='#' onclick='khmx(" + JSONObj.rows[i].khid + ");'>
                tableHtml += "<tr><td>" + data.rows[i].khdm + "</td><td><a hre='#' onclick='khmx(" + data.rows[i].khid + ")'>" + data.rows[i].khmc + "</a></td><td>" + tSKU + "</td><td>" + tSl + "</td><td>" + fmoney(tJe, 2) + "</td><td>" + tJeScale + "%" + "</td></tr>";
                //构造图标参数
                if (tSKU > lSKU) {
                    skuArray.push({ "label": data.rows[i].khmc, "value": parseFloat((data.rows[i].sku * 100 / sumSKU).toFixed(2)), "color": color });
                } else {
                    otherSKU += parseFloat(data.rows[i].sku);
                }
                if (tSl > lSl) {
                    slArry.push({ "label": data.rows[i].khmc, "value": parseFloat((data.rows[i].sl * 100 / sumSl).toFixed(2)), "color": color });
                } else {
                    otherSl += parseFloat(data.rows[i].sl);
                }
                if (tJe > lJe) {
                    jeArray.push({ "label": data.rows[i].khmc, "value": parseFloat((data.rows[i].je * 100 / sumJe).toFixed(2)), "color": color });
                } else {
                    otherJe += parseFloat(data.rows[i].je);
                }
            }
            color = '#' + ('00000' + (Math.random() * 0x1000000 << 0).toString(16)).slice(-6);
            skuArray.push({ "name": "其它", "value": parseFloat((otherSKU * 100 / sumSKU).toFixed(2)), "label": "其它", "color": color });
            slArry.push({ "name": "其它", "value": parseFloat((otherSl * 100 / sumSl).toFixed(2)), "label": "其它", "color": color });
            jeArray.push({ "name": "其它", "value": parseFloat((otherJe * 100 / sumJe).toFixed(2)), "label": "其它", "color": color });
            tableHtml += "<tr><td>合  计</td><td></td><td>" + sumSKU + "</td><td>" + sumSl + "</td><td>" + fmoney(sumJe) + "</td><td>100.00%</td></tr>";
            tableHtml += "</tbody> </table>";
            $("#mytable").empty();
            $("#mytable").append(tableHtml);

            //设置标记
            var flag;
            if (orderMode == "ASC") flag = "↑";
            else flag = "↓";
            $("#" + orderName).html($("#" + orderName).html() + flag);
            //设置标记结束

            if (isdrawpie == 1) {
                isExistsChart(skuPie);
                skuPie = new Chart(document.getElementById("SKUPie").getContext("2d")).Pie(skuArray);
                isExistsChart(slPie);
                slPie = new Chart(document.getElementById("SLPie").getContext("2d")).Pie(slArry);
                isExistsChart(jePie);
                jePie = new Chart(document.getElementById("JePie").getContext("2d")).Pie(jeArray);

            }
        }

        function SetOrder(s, filed) {
            if (orderName == s.id) {
                if (orderMode == "DESC") {
                    orderMode = "ASC";
                } else {
                    orderMode = "DESC";
                }
            } else {
                orderName = s.id;
                orderFiled = filed;
                orderMode = "DESC";
            }
            research(0);
        }
        function research(isredrawpie) {
            $("#load").show();            
            if (ccidval == "" || ccidval == "underfine") {
                alert("读取用户身份信息失败！请重新登录。");
                return;
            }
            myorderInfo = escape(orderFiled + " " + orderMode);
            //$.getJSON("KhReportData.aspx", { orderInfo: myorderInfo, ksrq: $("#ksrq").val(), jsrq: $("#jsrq").val(), ccid: ccidval, approve: $("#approve").val() }, function (data) {
            //    if (data.err == "") {
            //        $("#mycontent").css("display", "");
            //        CountNum(data);
            //        drawTabChart(data, isredrawpie);
            //        $("#load").fadeOut(1500);
            //    } else {
            //        $("#mycontent").css("display", "none");
            //        $("#mytable").empty();
            //        $("#mytable").append(data.err);
            //        $("#load").fadeOut(1500);
            //    }
            //});

            $.ajax({
                url: "KhReportData.aspx",
                type: "POST",
                data: { orderInfo: myorderInfo, ksrq: $("#ksrq").val(), jsrq: $("#jsrq").val(), ccid: ccidval, approve: $("#approve").val() },
                dataType: "text",
                contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                timeout: 60000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("您的网络好像出了点问题,请稍后重试...");
                },
                success: function (datas) {
                    var data = JSON.parse(datas);
                    if (data.err == "") {
                        $("#mycontent").css("display", "");
                        CountNum(data);
                        drawTabChart(data, isredrawpie);
                        $("#load").fadeOut(1500);
                    } else {
                        $("#mycontent").css("display", "none");
                        $("#mytable").empty();
                        $("#mytable").append(data.err);
                        $("#load").fadeOut(1500);
                    }
                }//end success
            });
        }

        function isExistsChart(oChart) {
            if (oChart != undefined)
                oChart.destroy();
        }
        function khmx(xjkhid) {
            //$("td",$(that).parent().parent()).eq(5)
            //var ksrq = $("#ksrq").val();
            //var jsrq = $("#jsrq").val();
            //window.location.href = "HhRep.aspx?xjkhid=" + xjkhid + "&ksrq=" + ksrq + "&jsrq=" + jsrq + "&approve=" + $("#approve").val();
            alert("正在开发中...");
        }
    </script>
</head>
<body>
    <div id="load">
        <div class="spinner">
            <div class="cube"></div>
            <div class="cube"></div>
            <div class="cube"></div>
            <div class="cube"></div>
            <div class="cube"></div>
            <div class="cube"></div>
            <div class="cube"></div>
            <div class="cube"></div>
            <div class="cube"></div>
        </div>
        <div class="loadtext">数据量较大，请耐心等待...</div>
    </div>    
    <div id="lite">
        <label>开始日期 从：</label><input id="ksrq" type="date" />
        &nbsp;
        <label>至：</label><input id="jsrq" type="date" />
        <label>单据状态: </label>
        <select id="approve">
            <option value="">全部</option>
            <option value="1">已审</option>
            <option value="0">未审</option>
        </select>
        <a id="research" onclick="research(1);">查 询</a>        
    </div>
    <div id="mycontent">
        <div class="chart3">
            <div class="charttit">SKU占比</div>
            <canvas id="SKUPie" width="250" height="250"></canvas>
        </div>
        <div class="chart1">
            <div class="charttit">数量占比</div>
            <canvas id="SLPie" width="250" height="250"></canvas>
        </div>
        <div class="chart2">
            <div class="charttit">金额占比</div>
            <canvas id="JePie" width="250" height="250"></canvas>
        </div>
    </div>
    <div style="clear: both"></div>
    <div id="mytable"></div>
    <div class="copyright">
        <br />
        Copyright &copy;2016 All rights reserved.<br>
        利郎信息技术部
    </div>
</body>
</html>
