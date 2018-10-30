<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    public string AppSystemKey = "", ccid = "", khid = "", khmc = "", mdid = "", mdmc = "";
    private string DBConstr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    //  private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";//授权表只能操作10上的数据库，62上的是10上同步过去的
    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string SystemID = "6";
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            string userid = Convert.ToString(Session["qy_customersid"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通订货会会务系统权限！");
                //Response.Redirect("http://tm.lilanz.com/oa/project/bandtosystem/systemband.aspx?systemid=6");
            else
            {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConstr))
                {
                    string str_sql = string.Format(@"select a.khid,a.mdid,md.mdmc,kh.ccid+'-%' ccid,kh.khmc
                                        from yx_t_dhryxx a
                                        inner join yx_t_khb kh on kh.khid=a.khid
                                        left join t_mdb md on md.mdid=a.mdid
                                        where id={0}", AppSystemKey);
                    DataTable dt = null;
                    string errinfo = dal.ExecuteQuery(str_sql, out dt);
                    if (errinfo == "")
                    {
                        if (dt.Rows.Count > 0)
                        {
                            khid = Convert.ToString(dt.Rows[0]["khid"]);
                            khmc = Convert.ToString(dt.Rows[0]["khmc"]);
                            mdid = Convert.ToString(dt.Rows[0]["mdid"]);
                            mdmc = Convert.ToString(dt.Rows[0]["mdmc"]);
                            ccid = Convert.ToString(dt.Rows[0]["ccid"]);
                            //若是改了门店的，将其认证信息删掉让其重新扫码认证
                            if (AppSystemKey != "" && AppSystemKey != "0" && Convert.ToInt32(mdid) < 0)
                            {
                                using (LiLanzDALForXLM dal62 = new LiLanzDALForXLM(DBConstr))
                                {
                                    str_sql = "delete from wx_t_AppAuthorized where systemid=6 and userid='" + userid + "'";
                                    errinfo = dal62.ExecuteNonQuery(str_sql);
                                    if (errinfo == "")
                                    {
                                        //清掉该用户的SESSION
                                        Session.Clear();
                                        clsSharedHelper.WriteInfo("对不起，您的信息已变更请点击右边【重新认证】！<a href='http://tm.lilanz.com/oa/project/bandtosystem/systemband.aspx?systemid=6'>重新认证</a>");
                                        return;
                                    }
                                    else
                                        clsSharedHelper.WriteErrorInfo(errinfo);
                                }
                            }
                        }
                        else
                            clsSharedHelper.WriteErrorInfo("对不起，关联不到您的身份信息！");
                    }
                    else
                        clsSharedHelper.WriteErrorInfo(errinfo);
                }
            }
        }
        else
        {
            clsWXHelper.ShowError("鉴权失败！");
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />    
    <meta name="format-detection" content="telephone=yes" />
    <title>按门店汇总</title>
    <script type="text/javascript" src="../../res/js/Chart.min.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <link rel="stylesheet" href="../../res/css/meeting/chartstyle.css" type="text/css" />
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
        }
        #khfl {            
            height: 25px;
            color: #000;
            font-size: 15px;
        }
    </style>
    <script type="text/javascript">
        var limitPer = 0.005; //阀值
        var sumSl = 0, sumJe = 0, sumSKU = 0;
        var lSKU = 0, lSl = 0, lJe = 0;
        var skuPie, slPie, jePie;

        //字段排序用
        var orderFiled = "mdid";
        var orderMode = "DESC";
        var orderName = "mddm";
        var myorderInfo = "";
        var ccidval = "<%=ccid%>";
        $(document).ready(function (e) {
            var ksrq = new Date();
            var jsrq = new Date();
            ksrq.setDate(1);
            $("#ksrq").val(ksrq.format("yyyy-MM-dd"));
            $("#jsrq").val(jsrq.format("yyyy-MM-dd"));
            var litepf = ($(window).width() - 840) / 2 + "px";
            $("#lite").css("padding-left", litepf);            
            if (ccidval == "" || ccidval == "underfine") {
                alert("读取用户身份信息失败！请重新登录。");
                return;
            }

            LoadKhflList();

            $.getJSON("StoresReportData.aspx", { orderInfo: myorderInfo, ksrq: $("#ksrq").val(), jsrq: $("#jsrq").val(), ccid: ccidval, approve: $("#approve").val(), khfl:"" }, function (data) {
                if (data.err != "") {
                    $("#mycontent").css("display", "none");
                    $("#mytable").empty();
                    $("#mytable").append(data.err);
                    //  return;
                } else {
                    //判断数据
                    $("#mycontent").css("display", "");
                    CountNum(data);
                    drawTabChart(data, 1);
                }
                $("#load").fadeOut("slow");
            });
        });
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
            var tableHtml = "<table class='bordered'><thead> <tr>"
            + "<th  id='thdm'   onclick=\"SetOrder(this,'mddm')\">门店代码</th>"
            + "<th  id='thmc'   onclick=\"SetOrder(this,'mdmc')\">门店名称</th>"
            + "<th  id='thsku'  onclick=\"SetOrder(this,'sku')\">SKU</th>"
            + "<th  id='thsl'   onclick=\"SetOrder(this,'sl')\">数量</th>"
            + "<th  id='thje'   onclick=\"SetOrder(this,'je')\">金额</th>"
            + "<th  id='thjezb' onclick=\"SetOrder(this,'je')\">金额占比</th></tr></thead><tbody>";
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
                //构造表格
                tableHtml += "<tr><td>" + data.rows[i].mddm + "</td><td><a hre='#' onclick='khmx(" + data.rows[i].khid + ")'>" + data.rows[i].mdmc + "</a></td><td>" + tSKU + "</td><td>" + tSl + "</td><td>" + fmoney(tJe, 2) + "</td><td>" + tJeScale + "%" + "</td></tr>";
                //构造图标参数
                if (tSl > lSl) {
                    slArry.push({ "label": data.rows[i].mdmc, "value": parseFloat((data.rows[i].sl * 100 / sumSl).toFixed(2)), "color": color });
                } else {
                    otherSl += parseFloat(data.rows[i].sl);
                }
                if (tJe > lJe) {
                    jeArray.push({ "label": data.rows[i].mdmc, "value": parseFloat((data.rows[i].je * 100 / sumJe).toFixed(2)), "color": color });
                } else {
                    otherJe += parseFloat(data.rows[i].je);
                }
                if (tSKU > lSKU) {
                    skuArray.push({ "label": data.rows[i].mdmc, "value": parseFloat((data.rows[i].sku * 100 / sumSKU).toFixed(2)), "color": color });
                } else {
                    otherSKU += parseFloat(data.rows[i].sku);
                }
            }
            color = '#' + ('00000' + (Math.random() * 0x1000000 << 0).toString(16)).slice(-6);
            slArry.push({ "name": "其它", "value": parseFloat((otherSl * 100 / sumSl).toFixed(2)), "label": "其它", "color": color });
            jeArray.push({ "name": "其它", "value": parseFloat((otherJe * 100 / sumJe).toFixed(2)), "label": "其它", "color": color });
            skuArray.push({ "name": "其它", "value": parseFloat((otherSKU * 100 / sumSKU).toFixed(2)), "label": "其它", "color": color });
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
                isExistsChart(slPie);
                slPie = new Chart(document.getElementById("SLPie").getContext("2d")).Pie(slArry);
                isExistsChart(jePie);
                jePie = new Chart(document.getElementById("JePie").getContext("2d")).Pie(jeArray);
                isExistsChart(skuPie);
                skuPie = new Chart(document.getElementById("SKUPie").getContext("2d")).Pie(skuArray);
            }
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
            $.getJSON("StoresReportData.aspx", { orderInfo: myorderInfo, ksrq: $("#ksrq").val(), jsrq: $("#jsrq").val(), ccid: ccidval, approve: $("#approve").val(), khfl:$("#khfl").val() }, function (data) {
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
            });
        }

        function isExistsChart(oChart) {
            if (oChart != undefined)
                oChart.destroy();
        }

        function khmx(xjkhid) {
            var ksrq = $("#ksrq").val();
            var jsrq = $("#jsrq").val();
            window.location.href = "HhRep.aspx?xjkhid=" + xjkhid + "&ksrq=" + ksrq + "&jsrq=" + jsrq + "&approve=" + $("#approve").val() + "&khfl=" + $("#khfl").val();
        }


        function LoadKhflList() {
            var _temp = "<option value='#cs#'>#mc#</option>";
            var html = "";
            $.ajax({
                url: "SplbReportData.aspx?lx=khfl",
                type: "POST",
                dataType: "text",
                contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                timeout: 3000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("您的网络好像出了点问题,请稍后重试...");
                },
                success: function (data) {
                    if (data.indexOf("Error:") > -1)
                        alert(data);
                    else if (data != "") {
                        var datas = JSON.parse(data);
                        var len = datas.rows.length;
                        for (var i = 0; i < len; i++) {
                            var row = datas.rows[i];
                            html += _temp.replace("#cs#", row.cs).replace("#mc#", row.mc);
                        }//end for
                        $("#khfl").append(html);
                    }
                }//end success
            });
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
        <div class="loadtext">正在计算</div>
    </div>
    <!--<div id="backbtn"><a href="index.aspx">返回</a></div>-->
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
        <!--20160515 liqf增加客户分类筛选条件-->    
        <label>客户分类: </label> 
        <select id="khfl">
            <option value="">全部</option>            
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
