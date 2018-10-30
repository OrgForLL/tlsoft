<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    public string ksrq = "", jsrq = "";
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
            if(AppSystemKey == "" || AppSystemKey == "0")
            {
                clsWXHelper.ShowError("对不起，您还未开通订货会系统！");
                return;
            }
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
                else
                {
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
                                        inner join t_mdb md on md.mdid=a.mdid
                                        where id={0}", AppSystemKey);
                        DataTable dt;
                        string errinfo = dal.ExecuteQuery(str_sql, out dt);
                        if (errinfo == "")
                        {
                            if (dt.Rows.Count > 0)
                            {
                                clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "订货会会务管理-按门店分析"));
                                
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
                }//走原来流程 店长也是走原来的流程
            }           
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
                                if (errinfo == "" && _dt.Rows.Count > 0) {
                                    if (dt.Select("khid=" + Convert.ToString(_dt.Rows[0]["khid"])).Length == 0)
                                        sbCompany.AppendFormat(optionBase, _dt.Rows[0]["ccid"], _dt.Rows[0]["mdmc"], "");
                                } //如果用户所属门店（贸易公司已被授权则不再添加否则会有两条记录）                                   
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
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="format-detection" content="telephone=no" />
    <title>按门店汇总</title>
    <script type="text/javascript" src="../../res/js/Chart.min.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <link rel="stylesheet" href="../../res/css/meeting/chartstyle.css" type="text/css" />
    <style type="text/css">
        #mytable a {
            color: Red;
        }

        #khfl {
            height: 25px;
            color: #000;
            font-size: 15px;
        }

        .chart1 {
            margin: 0px 22px;
        }

        .chart2 {
            margin: 0;
        }

        #mycontent {
            margin-top: 15px;
        }

        #lite {
            overflow-y:hidden;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
             height:100px;
             line-height: 30px;     
        }

        select {
            margin-right: 10px;
        }
          .t1
        {
            padding:0;
            margin:0;
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
        var ccidval = "";
        $(document).ready(function (e) {
            //var ksrq = new Date();
            //var jsrq = new Date();
            //ksrq.setDate(1);
            //$("#ksrq").val(ksrq.format("yyyy-MM-dd"));
            //$("#jsrq").val(jsrq.format("yyyy-MM-dd"));

            ccidval = $("#clients").val();
            if (ccidval == "" || typeof (ccidval) == "undefined") {
                //alert("对不起,您没有相关权限！");
                $("#load").hide();
                $("#mybody").removeClass("blur");
                return;
            } else {
                LoadKhflList();

                $("#load").show();
                $("#mybody").addClass("blur");
                ccidval += "-%";
                $.getJSON("StoresReportData.aspx", { orderInfo: myorderInfo, ksrq: $("#ksrq").val(), jsrq: $("#jsrq").val(), ccid: ccidval, approve: $("#approve").val(), khfl: $("#khfl").val(), kfbh: $("#kfbh").val() }, function (data) {
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

                    $("#load").hide();
                    $("#mybody").removeClass("blur");
                });
            }            
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
            tableHtml += "<tr><td>合  计</td><td>" + data.rows.length.toString() + "（总门店数）</td><td>" + sumSKU + "</td><td>" + sumSl + "</td><td>" + fmoney(sumJe) + "</td><td>100.00%</td></tr>";
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
            //权限控制
            ccidval = $("#clients").val();
            if (ccidval == "" || typeof (ccidval) == "undefined") {
                alert("对不起,您没有相关权限！");
                $("#load").hide();
                $("#mybody").removeClass("blur");
                return;
            } else
                ccidval += "-%";

            $("#load").show();
            $("#mybody").addClass("blur");

            myorderInfo = escape(orderFiled + " " + orderMode);
            $.getJSON("StoresReportData.aspx", { orderInfo: myorderInfo, ksrq: $("#ksrq").val(), jsrq: $("#jsrq").val(), ccid: ccidval, approve: $("#approve").val(), khfl: $("#khfl").val(), kfbh: $("#kfbh").val(), mddm: $("#mddm").val(), mdmc: encodeURI($("#mdmc").val()) }, function (data) {
                if (data.err == "") {
                    $("#mycontent").css("display", "");
                    CountNum(data);
                    drawTabChart(data, isredrawpie);                    
                } else {
                    $("#mycontent").css("display", "none");
                    $("#mytable").empty();
                    $("#mytable").append(data.err);                    
                }
                $("#load").hide();
                $("#mybody").removeClass("blur");
            });
        }

        function isExistsChart(oChart) {
            if (oChart != undefined)
                oChart.destroy();
        }

        function khmx(xjkhid) {
            var ksrq = $("#ksrq").val();
            var jsrq = $("#jsrq").val();
            var paraccid = $("#clients").val();
            window.location.href = "HhRep.aspx?xjkhid=" + xjkhid + "&ksrq=" + ksrq + "&jsrq=" + jsrq + "&approve=" + $("#approve").val() + "&khfl=" + $("#khfl").val() + "&paraccid=" + paraccid;
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
                    LoadKfbhList();
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
        function LoadKfbhList() {
            var _temp = "<option value='#cs#'>#mc#</option>";
            var html = "";
            $.ajax({
                url: "SplbReportData.aspx?lx=kfbh",
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
                            html += _temp.replace("#cs#", row.dm).replace("#mc#", row.mc);
                        }//end for
                        $("#kfbh").append(html);
                    }
                }//end success

            });
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
            <label>开始日期 从：</label><input id="ksrq" type="date" value="<%=ksrq %>"/>
            &nbsp;
        <label>至：</label><input id="jsrq" type="date" value="<%=jsrq %>" />
            <label>单据状态: </label>
            <select id="approve">
                <option value="">全部</option>
                <option value="1">已审</option>
                <option value="0">未审</option>
            </select>
              <label">管理对象: </label>
                <select id="clients">                
                    <%=AuthOptionCollect %>
                </select>
                <!--20160515 liqf增加客户分类筛选条件-->
                <label>客户分类: </label>
                <select id="khfl">
                    <option value="">全部</option>
                </select>
            </div>
            <!--20160729 改为新授权体系 支持一个人同时管理多家门店或者是贸易公司-->
            <div class="t1">
                
                      <label>开发编号: </label>
                <select id="kfbh">
                    <option value="">全部</option>
                </select>      
                 <label>门店代码: </label><input type="text" id="mddm" />
                 <label>门店名称: </label><input type="text" id="mdmc" />   
                <a id="research" onclick="research(1);">查 询</a>
            </div>
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
            利郎（中国）有限公司
        </div>
    </div>
</body>
</html>
