<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html>
<script runat="server">
    String ksrq = "", jsrq = "";
    private const string ConfigKeyValue = "1";	//微信配置信息索引值 1为企业号    
    public string AppSystemKey = "", ccid = "", khid = "", khmc = "", mdid = "", mdmc = "";
    private string DBConstr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
  //  private string WXDBConstr = "server='192.168.35.62';uid=sa;pwd=ll=8727;database=weChatPromotion";//授权表只能操作10上的数据库，62上的是10上同步过去的
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ksrq = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).ToString("yyy-MM-dd");
            jsrq = DateTime.Now.ToString("yyyy-MM-dd");
        }

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
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />    
    <meta name="format-detection" content="telephone=yes" />
    <title>按品类分析</title>
    <script type="text/javascript" src="../../res/js/Chart.min.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <link rel="stylesheet" href="../../res/css/meeting/chartstyle.css" type="text/css" />
    <style type="text/css">
        .bordered td:nth-child(6), .bordered th:nth-child(6)
        {
            display: none;
        }

        .bordered a
        {
            text-decoration: none;
        }

            .bordered a:link
            {
                color: #f00;
            }

            .bordered a:visited
            {
                color: #f00;
            }

        .infos
        {
            color: #f00;
            margin: 10px 0px -12px 0px;
        }

        .bordered th
        {
            cursor: pointer;
        }

        #lite {
            position:absolute;
            top:0;
            left:0;            
            width:100%;
            white-space:nowrap;
        }
        #khfl {            
            height: 25px;
            color: #000;
            font-size: 15px;
        }
  
    </style>
    <!---------------------------------------Script----------------------------------------->
    <script type="text/javascript">
        var limitPer = 0.005;//阀值
        var sSKU = 0, sSl = 0, sJe = 0;
        var lSKU = 0, lSl = 0, lJe = 0;
        var skuPie, slPie, jePie;
        var ccid = "<%=ccid%>";
        //字段排序用 初始值为默认排序
        var orderFiled = "je";
        var orderMode = "DESC";
        var orderName = "thje";

        $(document).ready(function () {            
            if (ccid == undefined || ccid == "") {
                document.writeln("CCID丢失，请重新进入!");
                return false;
            }
            $.getJSON("SplbReportData.aspx", { ccid: ccid, lx: "splb", orderInfo: "je DESC", ksrq: $("#ksrq").val(), jsrq: $("#jsrq").val(), approve: $("#approve").val(),khfl:"" }, function (data) {                
                if (data.err == "") {
                    switchShow("show");
                    computeNums(data);
                    drawTabChart(data, "all");
                } else {
                    switchShow("hide");
                    $("#mytable").empty();
                    $("#mytable").append(data.err);
                }
                $("#load").fadeOut("slow");
            });
            var litepf = ($(window).width() - 840) / 2 + "px";
            $("#lite").css("padding-left", litepf);
            LoadKhflList();
            console.log(window.location.href);
        });

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
                            var row=datas.rows[i];
                            html += _temp.replace("#cs#", row.cs).replace("#mc#", row.mc);
                        }//end for
                        $("#khfl").append(html);
                    }
                }//end success
            });
        }

        function switchShow(cs) {
            if (cs == "show") {
                $(".infos").css("display", "");
                $("#mycharts").css("display", "");
            } else {
                $(".infos").css("display", "none");
                $("#mycharts").css("display", "none");
            }
        }

        function research(type) {            
            if (ccid == undefined || ccid == "") {
                document.writeln("CCID丢失，请重新进入!");
                return false;
            }

            $("#load").css("display", "");
            var ksrq = $("#ksrq").val();
            var jsrq = $("#jsrq").val();
            var myorderInfo = escape(orderFiled + " " + orderMode);
            $.getJSON("SplbReportData.aspx", { ccid: ccid, lx: "splb", orderInfo: myorderInfo, ksrq: ksrq, jsrq: jsrq, approve: $("#approve").val(), khfl:$("#khfl").val() }, function (data) {                
                if (data.err == "") {
                    switchShow("show");
                    computeNums(data);
                    drawTabChart(data, "all");
                } else {
                    switchShow("hide");
                    $("#mytable").empty();
                    $("#mytable").append(data.err);
                }
                $("#load").fadeOut("slow");                
            });
        }

        function getRandomColor() {
            return '#' + ('00000' + (Math.random() * 0x1000000 << 0).toString(16)).slice(-6);
        }

        //计算SKU,SL,JE的总及各自的最小显示值
        function computeNums(data) {
            sSKU = data.sSKU;
            sSl = data.sSl;
            sJe = data.sJe;

            lSKU = limitPer * sSKU;
            lSl = limitPer * sSl;
            lJe = limitPer * sJe;
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

        function drawTabChart(JSONObj, type) {            
            var PieData1 = new Array(), PieData2 = new Array(), PieData3 = new Array();
            var others1 = 0, others2 = 0, others3 = 0, rcolor = "", tsku = 0, tsl = 0, tje = 0;
            //构造表头
            var tableHTML = "<table class='bordered'><thead><tr><th id='thdm' onclick=\"SetOrder(this,'dm')\">代码</th>"
                          + "<th id='thmc' onclick=\"SetOrder(this,'mc')\">名称</th><th id='thSKU' onclick=\"SetOrder(this,'SKU')\">SKU</th>"
                          + "<th id='thsl' onclick=\"SetOrder(this,'sl')\">数量</th><th id='thje' onclick=\"SetOrder(this,'je')\">金额</th>"
                          + "<th id='thID' style='display:none;'>ID</th><th id='thjezb' onclick=\"SetOrder(this,'je')\">金额占比</th>"
                          + "</thead></tr>";
            for (var l = 0; l < JSONObj.rows.length; l++) {
                tableHTML += "<tr>";
                for (var p in JSONObj.rows[l]) {
                    if (p == "je")
                        tableHTML += "<td>" + fmoney(JSONObj.rows[l][p], 2) + "</td>";
                    else if (p == "mc")
                        tableHTML += "<td><a href='#' onclick='splbmx(" + JSONObj.rows[l].id + ");'>" + JSONObj.rows[l][p] + "</a></td>";
                    else
                        tableHTML += "<td>" + JSONObj.rows[l][p] + "</td>";
                }
                tableHTML += "<td>" + (parseInt(JSONObj.rows[l].je) * 100 / sJe).toFixed(2) + "%" + "</td></tr>";
                rcolor = getRandomColor();
                tsku = parseInt(JSONObj.rows[l].SKU);
                tsl = parseInt(JSONObj.rows[l].sl);
                tje = parseInt(JSONObj.rows[l].je);

                if (tsku > lSKU) {//SKU
                    PieData1.push({ "name": JSONObj.rows[l].mc, "value": parseFloat((tsku * 100 / sSKU).toFixed(2)), "label": JSONObj.rows[l].mc, "color": rcolor });
                } else {
                    others1 += tsku;
                }

                if (tsl > lSl) {//数量
                    PieData2.push({ "name": JSONObj.rows[l].mc, "value": parseFloat((tsl * 100 / sSl).toFixed(2)), "label": JSONObj.rows[l].mc, "color": rcolor });
                } else {
                    others2 += tsl;
                }

                if (tje > lJe) {//金额
                    PieData3.push({ "name": JSONObj.rows[l].mc, "value": parseFloat((tje * 100 / sJe).toFixed(2)), "label": JSONObj.rows[l].mc, "color": rcolor });
                } else {
                    others3 += tje;
                }
            }
            //end for
            tableHTML += "<tr><td>合  计</td><td></td><td>" + sSKU + "</td><td>" + sSl + "</td><td>"+fmoney(sJe)+"</td><td></td><td>100.00%</td></tr>";
            tableHTML += "</table>";
            rcolor = getRandomColor();//重新分配一个颜色        
            PieData1.push({ "name": "其它", "value": parseFloat((others1 * 100 / sSKU).toFixed(2)), "label": "其它", "color": rcolor });
            PieData2.push({ "name": "其它", "value": parseFloat((others2 * 100 / sSl).toFixed(2)), "label": "其它", "color": rcolor });
            PieData3.push({ "name": "其它", "value": parseFloat((others3 * 100 / sJe).toFixed(2)), "label": "其它", "color": rcolor });

            $("#mytable").empty();
            $("#mytable").append(tableHTML);

            //设置标记
            var flag;
            if (orderMode == "ASC") flag = "↑";
            else flag = "↓";
            $("#" + orderName).html($("#" + orderName).html() + flag);
            //设置标记结束

            //重画图表时必须调用自带的方法destroy()清除一下，否则会好几个重叠在一起
            if (type == "all") {
                var Pies = new Array();
                Pies.push(skuPie); Pies.push(slPie); Pies.push(jePie);
                isExistsChart(Pies);
                skuPie=new Chart(document.getElementById("canvas1").getContext("2d")).Pie(PieData1);                
                slPie=new Chart(document.getElementById("canvas2").getContext("2d")).Pie(PieData2);                
                jePie = new Chart(document.getElementById("canvas3").getContext("2d")).Pie(PieData3);               
            }
        }
        //JS 日期格式化函数
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

        function splbmx(splbid) {            
            var ksrq = $("#ksrq").val();
            var jsrq = $("#jsrq").val();
            window.location.href = "HhRep.aspx?splbid=" + splbid + "&ksrq=" + ksrq + "&jsrq=" + jsrq + "&approve=" + $("#approve").val() + "&khfl=" + $("#khfl").val();
        }

        //排序
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
            research("table");
        }

        //获取URL参数
        function getUrlParam(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
            var r = window.location.search.substr(1).match(reg);  //匹配目标参数
            if (r != null) return unescape(r[2]); return null; //返回参数值
        }

        function isExistsChart(oChart) {
            for (var i = 0; i < oChart.length; i++) {
                if (oChart[i] != undefined)
                    oChart[i].destroy();
            }
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
        <label>开始日期 从：</label><input id="ksrq" type="date" value="<%=ksrq %>" />
        &nbsp;
        <label>至：</label><input id="jsrq" type="date" value="<%=jsrq %>" />  
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
        <a id="research" onclick="research('all');">查 询</a>
    </div>
        <div id="mycharts">
        <div class="chart1">
            <div class="charttit">SKU占比</div>
            <canvas id="canvas1" width="250" height="250"></canvas>
        </div>
        <div class="chart2">
            <div class="charttit">数量占比</div>
            <canvas id="canvas2" width="250" height="250"></canvas>
        </div>
        <div class="chart3">
            <div class="charttit">金额占比</div>
            <canvas id="canvas3" width="250" height="250"></canvas>
        </div>
    </div>
    <div style="clear: both"></div>
    <div class="infos">提示：1、点击表格列名（第一行）可对其进行排序！ 2、点击各品类名称可查看明细！</div>
    <div id="mytable"></div>
    <div class="copyright">        
        Copyright &copy;2016 All rights reserved.<br>
        利郎信息技术部
    </div>
    </body>
    </html>