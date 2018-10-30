<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html>

<script runat="server"> 
    String splbid = "";
    String ksrq = "";
    String jsrq = "";
    String approve = "";
    String xjkhid = "";
    String sst = "";
    public string AppSystemKey = "", ccid = "", khid = "", khmc = "", mdid = "", mdmc = "",khfl="";
    private string DBConstr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";   
    
    protected void Page_Load(object sender, EventArgs e)
    {
        //kfbh = Convert.ToString(Request.Params["kfbh"]);        //订货季
        splbid = Convert.ToString(Request.Params["splbid"]);        //商品类别ID 
        ksrq = Convert.ToString(Request.Params["ksrq"]);        //开始日期 
        jsrq = Convert.ToString(Request.Params["jsrq"]);        //结束日期 
        xjkhid = Convert.ToString(Request.Params["xjkhid"]);      //下级客户id
        sst = Convert.ToString(Request.Params["sst"]);           //所属厅信息
        approve = Convert.ToString(Request.Params["approve"]);
        khfl = Convert.ToString(Request.Params["khfl"]);//客户分类
        //if (kfbh == null || kfbh == "")
        //{
        //    kfbh = "201511";
        //}     
        if (khfl == null || khfl == "")
            khfl = "";   
        if (approve == null || approve == "")
        {
            approve = "";
        }
        if (splbid == null)
        {
            splbid = "";
        }
        if (xjkhid == null)
        {
            xjkhid = "";
        }
        if (sst == null)
        {
            sst = "";
        }        
        if (ksrq == null || ksrq == "")
        {
            ksrq = DateTime.Now.ToString("yyyy-MM-01");
        }
        if (jsrq == null || jsrq == "")
        {
            jsrq = DateTime.Now.ToString("yyyy-MM-dd");
        }

        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string SystemID = "6";
            AppSystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
            string userid = Convert.ToString(Session["qy_customersid"]);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通订货会会务系统权限！");                
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
    <title>按货号汇总分析</title>
    <script type="text/javascript" src="../../res/js/Chart.min.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <link rel="stylesheet" href="../../res/css/meeting/chartstyle.css?ver=20150205" type="text/css" />
    <style type="text/css">
        .infos {
            color: #f00;
            margin: 10px 0px -12px 0px;
        }

        #lite {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            white-space: nowrap;
        }
    </style>
    <!---------------------------------------Script----------------------------------------->
    <script type="text/javascript">
        var ccid = "<%=ccid%>";
        $(document).ready(function () {
            $("#approve").val(<%=approve %>)
            var splbid = "<%=splbid %>";
            var xjkhid = "<%=xjkhid %>";
            var sst = "<%=sst %>";

            if (splbid != "" || xjkhid != "" || sst != "") {
                research();
            } else {
                $("#load").fadeOut(100);
            }
            //设置筛选条件的偏移位置
            var litepf = ($(window).width() - 840) / 2 + "px";
            $("#lite").css("padding-left", litepf);
        });

        //函数名：CheckDateTime  
        //功能介绍：检查是否为日期时间 
        function CheckDateTime(str) {
            var reg = /^(\d+)-(\d{1,2})-(\d{1,2})$/;
            var r = str.match(reg);
            if (r == null) return false;
            r[2] = r[2] - 1;
            var d = new Date(r[1], r[2], r[3]);
            if (d.getFullYear() != r[1]) return false;
            if (d.getMonth() != r[2]) return false;
            if (d.getDate() != r[3]) return false;
            return true;
        }

        var orderFiled = "金额";
        var orderMode = "DESC";
        var orderName = "th金额";

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

            research();
        }

        function research() {
            var ksrq = $("#ksrq").val();
            var jsrq = $("#jsrq").val();

            if (CheckDateTime(ksrq) == false) {
                alert("开始日期不是一个日期！");
                return;
            } else if (CheckDateTime(jsrq) == false) {
                alert("结束日期不是一个日期！");
                return;
            }
            $("#load").fadeIn(500);
            var myorderInfo = escape(orderFiled + " " + orderMode);
            $.getJSON("HhRepData.aspx", { sst: "<%=sst %>", xjkhid: "<%=xjkhid %>", splbid: "<%= splbid %>", "ccid": ccid, dataBegin: ksrq, dataEnd: jsrq, orderInfo: myorderInfo, approve: $("#approve").val(), khfl:"<%=khfl%>" }, function (data) {

                if (data.err == "") {
                    drawTabChart(data);
                } else {
                    alert(data.err);
                    $("#mytable").empty();
                    $("#mytable").append(data.err);
                }
                $("#load").fadeOut(500);
            });

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

        function drawTabChart(JSONObj) {
            var sSl = JSONObj.SumSL;     //获取Json中的合计数值
            var sJe = JSONObj.SumJE;

            var tableHTML = "<table class='bordered'><thead><tr>";
            //构造表格的表头，循环对象数组中一个元素即可
            for (var p in JSONObj.rows[0]) {
                tableHTML += "<th id='th" + p + "' onclick=\"SetOrder(this,'" + p + "');\" >" + p + "</th>";
            }

            tableHTML += "<th id='thslzb' onclick=\"SetOrder(this,'数量');\" >数量占比</th><th id='thjezb' onclick=\"SetOrder(this,'金额');\">金额占比</th></thead></tr>";
            for (var l = 0; l < JSONObj.rows.length; l++) {
                tableHTML += "<tr>";
                for (var p in JSONObj.rows[l]) {
                    if (p == "金额") {
                        tableHTML += "<td>" + fmoney(JSONObj.rows[l][p], 2) + "</td>";
                    }
                    else {
                        tableHTML += "<td>" + JSONObj.rows[l][p] + "</td>";
                    }
                }
                tableHTML += "<td>" + (parseInt(JSONObj.rows[l].数量) * 100 / sSl).toFixed(2)
                     + "%</td><td>" + (parseInt(JSONObj.rows[l].金额) * 100 / sJe).toFixed(2) + "%</td></tr>";
            }
            tableHTML += "<tr><td>合  计</td><td></td><td>" + sSl + "</td><td>" + fmoney(sJe) + "</td><td>100.00%</td><td>100.00%</td></tr>";
            tableHTML += "</table>";
            $("#mytable").empty();
            $("#mytable").append(tableHTML);

            //设置标记
            var flag;
            if (orderMode == "ASC") flag = "↑";
            else flag = "↓";
            $("#" + orderName).html($("#" + orderName).html() + flag);
            //设置标记结束            
        }
        function jump() {
            window.location.href = "SplbRep.aspx?ksrq=" + $("#ksrq").val() + "&jsrq=" + $("#jsrq").val() + "&approve=" + $("#approve").val();
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

    <!--<div id="backbtn"><a href="javascript:history.go(-1)">返回</a></div>-->
    <div id="lite">
        <label>开始日期 从：</label><input id="ksrq" type="date" value="<%= ksrq %>" />
        &nbsp;
        <label>至：</label><input id="jsrq" type="date" value="<%= jsrq %>" />
        <label>单据状态: </label>
        <select id="approve">
            <option value="">全部</option>
            <option value="1">已审</option>
            <option value="0">未审</option>
        </select>
        <a id="research" onclick="research();">查 询</a>
    </div>
    <div class="infos">提示：1、点击表格列名（第一行）可对其进行排序！</div>
    <div id="mytable"></div>
    <div class="copyright">
        <br />
        Copyright &copy;2016 All rights reserved.<br>
        利郎信息技术部
    </div>
</body>
</html>
