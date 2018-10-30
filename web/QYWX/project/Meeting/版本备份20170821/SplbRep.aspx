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
    public string AuthOptionCollect = "";
      
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ksrq = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1).ToString("yyy-MM-dd");
            jsrq = DateTime.Now.ToString("yyyy-MM-dd");
        }

        if (clsWXHelper.CheckQYUserAuth(true))
        {
            //如果没有开通全渠道系统的则按原来逻辑走，只能查自己的本店数据，如果有开通的且管理多家的则可以进行选择查看对应的数据            
            //订货系统(6) 开通了全渠道系统(3)的才能获得到相应的ROLEID                        
            AppSystemKey = clsWXHelper.GetAuthorizedKey(6);            
            string QQDSystemKey = clsWXHelper.GetAuthorizedKey(3);            
            string userid = Convert.ToString(Session["qy_customersid"]);
                        
            if (QQDSystemKey != "" && QQDSystemKey != "0")
            {                
                GetAuthMenu();
            }//end 有开通全渠道系统          
            
            if (AuthOptionCollect == "")
            {
                if (AppSystemKey == "" || AppSystemKey == "0")
                {
                    clsWXHelper.ShowError("对不起，您还未开通订货会系统！");
                    return;
                }
                else {
                    string ManagerStore = Convert.ToString(Session["ManagerStore"]);
                    //20170425 liqf 添加为了在APP中使用
                    if (!string.IsNullOrEmpty(ManagerStore) && ManagerStore != "APPMODE_6")
                    {
                        Response.Redirect("http://tm.lilanz.com/oa/project/storesaler/managerNav.aspx?SetManager=1&gourl=" + Request.Url.ToString());
                        Response.End();
                    }
                    
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConstr))
                    {
                        string str_sql = string.Format(@"select a.khid,a.mdid,md.mdmc,kh.ccid,kh.khmc
                                        from yx_t_dhryxx a
                                        inner join yx_t_khb kh on kh.khid=a.khid
                                        left join t_mdb md on md.mdid=a.mdid
                                        where id={0}", AppSystemKey);
                        DataTable dt;
                        string errinfo = dal.ExecuteQuery(str_sql, out dt);
                        if (errinfo == "")
                        {
                            if (dt.Rows.Count > 0)
                            {
                                clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "订货会会务管理-按品类分析"));
                                
                                ccid = Convert.ToString(dt.Rows[0]["ccid"]);
                                mdid = Convert.ToString(dt.Rows[0]["mdid"]);
                                string mdmc = Convert.ToString(dt.Rows[0]["mdmc"]);
                                //若是改了门店的，将其认证信息删掉让其重新扫码认证
                                if (Convert.ToInt32(mdid) < 0)
                                {
                                    str_sql = "delete from wx_t_AppAuthorized where systemid=6 and userid='" + userid + "'";
                                    errinfo = dal.ExecuteNonQuery(str_sql);
                                    if (errinfo == "")
                                    {
                                        Session.Clear();
                                        clsSharedHelper.WriteInfo("对不起，您的信息已变更请点击右边【重新认证】！<a href='http://tm.lilanz.com/oa/project/bandtosystem/systemband.aspx?systemid=6'>重新认证</a>");
                                        return;
                                    }
                                    else
                                        clsSharedHelper.WriteErrorInfo(errinfo);
                                }//end 调整人员所属门店情况

                                AuthOptionCollect = "<option value=\"" + ccid + "\" selected>" + mdmc + "</option>";
                            }
                            else
                                clsSharedHelper.WriteErrorInfo("对不起，关联不到您的身份信息！");
                        }
                        else
                            clsSharedHelper.WriteErrorInfo(errinfo);
                    }//end using
                }
            }//走原来流程 店长也是走原来的流程
        }
        else
            clsWXHelper.ShowError("对不起，鉴权失败！");        
    }

    //获取用户的管理对象
    public void GetAuthMenu()
    {
        //1-店员 2-店长 3-总部管理角色 4-贸易公司角色 99-开发人员
        //导购员dg 店长dz 总部管理角色zb 贸易公司角色my 开发者kf
        string RoleName = Convert.ToString(Session["RoleName"]);
        string optionBase = "<option value=\"{0}\" {2}>{1}</option>";
        StringBuilder sbCompany = new StringBuilder();
        if (RoleName == "my")
        {
            using (DataTable dt = clsWXHelper.GetQQDAuth())
            {
                if (dt.Rows.Count == 0)
                    sbCompany.AppendFormat(optionBase, "", "您还没有授权，请联系总部IT", "selected");
                else
                {
                    string khidStr = "";
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        khidStr += Convert.ToString(dt.Rows[i]["khid"]) + ",";
                    }//end for
                    khidStr = khidStr.Substring(0, khidStr.Length - 1);
                    using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConstr))
                    {
                        string str_sql = string.Format(@"select khid,ccid from yx_t_khb where khid in ({0});", khidStr);
                        DataTable khdt;
                        string errinfo = dal.ExecuteQuery(str_sql, out khdt);
                        if (errinfo == "")
                        {
                            dt.Columns.Add("ccid", typeof(string), "");
                            khdt.PrimaryKey = new DataColumn[] { khdt.Columns["khid"] };

                            //循环赋值，取得ccid 
                            DataRow drFind;
                            foreach (DataRow drF in dt.Rows)
                            {
                                drFind = khdt.Rows.Find(drF["khid"]);   //找到对应的层次ID行
                                if (drFind != null) drF["ccid"] = drFind["ccid"];
                            }
                            clsSharedHelper.DisponseDataTable(ref khdt);
                            
                            //拼接两个DATATABLE 为DT增加CCID字段值
                            //dt.PrimaryKey = new DataColumn[] { dt.Columns["khid"] };
                            //khdt.PrimaryKey = new DataColumn[] { khdt.Columns["khid"] };
                            //dt.Merge(khdt);                            
                            DataRow dr;
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                dr = dt.Rows[i];
                                sbCompany.AppendFormat(optionBase, dr["ccid"], dr["mdmc"], "");
                            }//end for

                            //把原来的管理对象也加进去
                            if (AppSystemKey != "" && AppSystemKey != "0")
                            {
                                str_sql = string.Format(@"select a.khid,a.mdid,md.mdmc,kh.ccid,kh.khmc
                                                          from yx_t_dhryxx a
                                                          inner join yx_t_khb kh on kh.khid=a.khid
                                                          inner join t_mdb md on md.mdid=a.mdid
                                                          where id={0}", AppSystemKey);
                                DataTable _dt;
                                errinfo = dal.ExecuteQuery(str_sql, out _dt);
                                if (errinfo == "" && _dt.Rows.Count > 0)
                                {
                                    if (dt.Select("khid=" + Convert.ToString(_dt.Rows[0]["khid"])).Length == 0)
                                        sbCompany.AppendFormat(optionBase, _dt.Rows[0]["ccid"], _dt.Rows[0]["mdmc"], "");
                                }//如果用户所属门店（贸易公司已被授权则不再添加否则会有两条记录）
                            }

                            dt.Clear(); dt.Dispose();                            
                        }
                    }//end using
                }
            }//end using
        }//end 贸易公司角色
        else if (RoleName == "zb" || RoleName == "kf")
            sbCompany.AppendFormat(optionBase, "-1", "完整权限", "selected");

        AuthOptionCollect = sbCompany.ToString();
        sbCompany.Length = 0;
    }
</script>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="format-detection" content="telephone=no" />    
    <title>按品类分析</title>
    <script type="text/javascript" src="../../res/js/Chart.min.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <link rel="stylesheet" href="../../res/css/meeting/chartstyle.css" type="text/css" />
    <style type="text/css">
        body
        {
            padding-top:120px;
        }
        .bordered td:nth-child(6), .bordered th:nth-child(6) {
            display: none;
        }

        .bordered a {
            text-decoration: none;
        }

            .bordered a:link {
                color: #f00;
            }

            .bordered a:visited {
                color: #f00;
            }

        .infos {
            color: #f00;
            margin: 10px 0px -12px 0px;
        }

        .bordered th {
            cursor: pointer;
        }

        #khfl {
            height: 25px;
            color: #000;
            font-size: 15px;
        }

        #mycharts {
            margin-top: 15px;
        }

        .chart2 {
            margin: 0px 22px;
        }

        select {
            margin-right: 10px;
        }

        #lite 
        {
            width:100%;
            height:100px;
            overflow-y:hidden;
            overflow-x:auto; 
            -webkit-overflow-scrolling:touch;    
            line-height: 30px;        
        }
        .t1
        {
            padding:0;
            margin:0;
        }
    </style>
    <!---------------------------------------Script----------------------------------------->
    <script type="text/javascript">
        var limitPer = 0.005;//阀值
        var sSKU = 0, sSl = 0, sJe = 0;
        var lSKU = 0, lSl = 0, lJe = 0;
        var skuPie, slPie, jePie;
        var ccid = "";
        //字段排序用 初始值为默认排序
        var orderFiled = "je";
        var orderMode = "DESC";
        var orderName = "thje";

        $(document).ready(function () {
            //权限控制
            ccid = $("#clients").val();
            if (ccid == "" || typeof (ccid) == "undefined") {
                //alert("对不起,您没有相关权限！");
                $("#load").hide();
                $("#mybody").removeClass("blur");
                return;
            } else {
                ccid += "-%";
                $("#load").show();
                $("#mybody").addClass("blur");

                $.getJSON("SplbReportData.aspx", { ccid: ccid, lx: "splb", orderInfo: "je DESC", ksrq: $("#ksrq").val(), jsrq: $("#jsrq").val(), approve: $("#approve").val(), khfl: "" }, function (data) {
                    if (data.err == "") {
                        switchShow("show");
                        computeNums(data);
                        drawTabChart(data, "all");
                    } else {
                        switchShow("hide");
                        $("#mytable").empty();
                        $("#mytable").append(data.err);
                    }

                    $("#load").hide();
                    $("#mybody").removeClass("blur");
                });
                LoadKhflList();
            }
        });

        function LoadKhflList() {
            var _temp = "<option value='#cs#'>#mc#</option>";
            var html = "";
            $.ajax({
                url: "SplbReportData.aspx?lx=khfl",
                type: "POST",
                dataType: "text",
                contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                timeout: 10000,
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
            //权限控制
            ccid = $("#clients").val();
            if (ccid == "" || typeof (ccid) == "undefined") {
                alert("对不起,您没有相关权限！");
                $("#load").hide();
                $("#mybody").removeClass("blur");
                return;
            } else
                ccid += "-%";

            $("#load").show();
            $("#mybody").addClass("blur");

            setTimeout(function () {
                var ksrq = $("#ksrq").val();
                var jsrq = $("#jsrq").val();
                var myorderInfo = escape(orderFiled + " " + orderMode);
                $.getJSON("SplbReportData.aspx", { ccid: ccid, lx: "splb", orderInfo: myorderInfo, ksrq: ksrq, jsrq: jsrq, approve: $("#approve").val(), khfl: $("#khfl").val() }, function (data) {
                    if (data.err == "") {
                        switchShow("show");
                        computeNums(data);
                        drawTabChart(data, "all");
                    } else {
                        switchShow("hide");
                        $("#mytable").empty();
                        $("#mytable").append(data.err);
                    }
                    $("#load").hide();
                    $("#mybody").removeClass("blur");
                });
            }, 500);
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
                    else if (p == "dm")
                        tableHTML += "<td><a href='#' onclick=splbkh(" + JSONObj.rows[l].id + ",'" + JSONObj.rows[l]["dm"] + "." + JSONObj.rows[l]["mc"] + "');>" + JSONObj.rows[l][p] + "</a></td>";
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
            tableHTML += "<tr><td>合  计</td><td>" + JSONObj.rows.length.toString() + "（总品类数）</td><td>" + sSKU + "</td><td>" + sSl + "</td><td>" + fmoney(sJe) + "</td><td></td><td>100.00%</td></tr>";
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
                skuPie = new Chart(document.getElementById("canvas1").getContext("2d")).Pie(PieData1);
                slPie = new Chart(document.getElementById("canvas2").getContext("2d")).Pie(PieData2);
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
            var paraccid = $("#clients").val();
            window.location.href = "HhRep.aspx?splbid=" + splbid + "&ksrq=" + ksrq + "&jsrq=" + jsrq + "&approve=" + $("#approve").val() + "&khfl=" + $("#khfl").val() + "&paraccid=" + paraccid;
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
        function splbkh(splbid, splbmc) {
            var ksrq = $("#ksrq").val();
            var jsrq = $("#jsrq").val();
            var paraccid = $("#clients").val();
            window.location.href = "KhRep.aspx?splbid=" + splbid + "&paraJson={\"ksrq\":\"" + ksrq + "\",\"jsrq\":\"" + jsrq + "\",\"approve\":\"" + $("#approve").val() + "\",\"khfl\":\"" + $("#khfl").val() + "\",\"paraccid\":\"" + paraccid + "\",\"splbmc\":\""+splbmc+"\"}";
        }
    </script>

</head>
<body>
    <div id="load">
        <div class="load-container load8">
            <div class="loader"></div>
            <p id="loader-text">正在汇总,请稍候..</p>
        </div>
    </div>
    <div id="mybody">
        <div id="lite">
        <div class="t1">
            <label>开始日期 从：</label><input id="ksrq" type="date" value="<%=ksrq %>" />
            &nbsp;
         <label>至：</label><input id="jsrq" type="date" value="<%=jsrq %>" />
            <label>单据状态: </label>
            <select id="approve">
                <option value="">全部</option>
                <option value="1">已审</option>
                <option value="0">未审</option>
            </select>
            <!--20160729 改为新授权体系 支持一个人同时管理多家门店或者是贸易公司-->
          </div>
          <div class="t1">
            <label">管理对象: </label>
            <select id="clients">                
                <%=AuthOptionCollect %>
            </select>
            <label>客户分类: </label>
            <select id="khfl">
                <option value="">全部</option>
            </select>            
            <a id="research" onclick="research('all');">查 询</a>
            </div>
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
            利郎（中国）有限公司
        </div>
    </div>
</body>
</html>
