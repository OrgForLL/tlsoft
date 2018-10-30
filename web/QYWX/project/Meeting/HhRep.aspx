<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html>

<script runat="server"> 
    public string splbid = "", ksrq = "", jsrq = "", approve = "", xjkhid = "", sst = "";
    public string AppSystemKey = "", ccid = "", mdid = "", khfl = "";
    private string DBConstr = "server='192.168.35.10';uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    public string AuthOptionCollect = "";
    private string optionBase = "<option value=\"{0}\" {2}>{1}</option>";

    protected void Page_Load(object sender, EventArgs e)
    {
        splbid = Convert.ToString(Request.Params["splbid"]);        //商品类别ID 
        ksrq = Convert.ToString(Request.Params["ksrq"]);        //开始日期 
        jsrq = Convert.ToString(Request.Params["jsrq"]);        //结束日期 
        xjkhid = Convert.ToString(Request.Params["xjkhid"]);      //下级客户id
        sst = Convert.ToString(Request.Params["sst"]);           //所属厅信息
        approve = Convert.ToString(Request.Params["approve"]);
        khfl = Convert.ToString(Request.Params["khfl"]);//客户分类

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
                if (AppSystemKey == "" || AppSystemKey == "0") {
                    clsWXHelper.ShowError("对不起，您还未开通订货会系统！");
                    return;
                }
                else
                {
                    //Session["ManagerStore"]表示用户的伪身份即是否有选择了某家管理门店
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
                                clsWXHelper.WriteLog(string.Format("AppSystemKey:{0},访问功能页[{1}]", AppSystemKey, "订货会会务管理-按货号分析"));

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
                            //dt.PrimaryKey = new DataColumn[] { dt.Columns["khid"] };   //在客户重复时会出错
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
                                str_sql = string.Format(@"select TOP 1 a.khid,a.mdid,md.mdmc,kh.ccid,kh.khmc
                                                          from yx_t_dhryxx a
                                                          inner join yx_t_khb kh on kh.khid=a.khid
                                                          inner join t_mdb md on md.mdid=a.mdid
                                                          where id={0}", AppSystemKey);
                                DataTable _dt;
                                errinfo = dal.ExecuteQuery(str_sql, out _dt);
                                if (errinfo == "" && _dt.Rows.Count > 0){
                                    if (dt.Select("khid=" + Convert.ToString(_dt.Rows[0]["khid"])).Length==0)
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

        AddsbCompany(ref sbCompany);

        AuthOptionCollect = sbCompany.ToString();
        sbCompany.Length = 0;
    }

    private void AddsbCompany(ref StringBuilder sbCompany)
    {
        string paraccid = Request.Params["paraccid"];
        if (string.IsNullOrEmpty(paraccid)) return;

        using (LiLanzDALForXLM dal = new LiLanzDALForXLM(DBConstr))
        {
            string str_sql = @"SELECT TOP 1 ccid,khmc FROM yx_t_khb WHERE ccid=@ccid AND ty=0";
            DataTable DT;
            System.Collections.Generic.List<SqlParameter> paras = new System.Collections.Generic.List<SqlParameter>();
            paras.Add(new SqlParameter("@ccid", paraccid));
            string errinfo = dal.ExecuteQuerySecurity(str_sql, paras, out DT);
            if (errinfo != "" || DT.Rows.Count == 0)
            {
                clsLocalLoger.WriteError("无法获取ccid 2,错误：" + errinfo);
                clsSharedHelper.WriteErrorInfo("系统错误！请联系IT");
            }

            sbCompany.AppendFormat(optionBase, DT.Rows[0]["ccid"], DT.Rows[0]["khmc"], "selected");
            clsSharedHelper.DisponseDataTable(ref DT);
        }
    }


    //打印DATATABLE内容
    public void printDataTable(DataTable dt)
    {
        string printStr = "";

        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    if (dt.Rows[i][j] == null)
                        printStr += "null&nbsp;";
                    else
                        printStr += dt.Rows[i][j].ToString() + "&nbsp;";
                }
                printStr += "<br />";
            }
            Response.Write(printStr);
            Response.End();
        }
    }
</script>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="format-detection" content="telephone=no" />
    <title>按货号汇总分析</title>
    <script type="text/javascript" src="../../res/js/Chart.min.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <link rel="stylesheet" href="../../res/css/meeting/chartstyle.css?ver=20180817" type="text/css" />
    <style type="text/css">
        .infos {
            color: #f00;
            margin: 70px 0px -12px 0px;
        }
    </style>
    <!---------------------------------------Script----------------------------------------->
    <script type="text/javascript">
        var ccid = "";
        $(document).ready(function () {            
            $("#approve").val(<%=approve %>)
            var splbid = "<%=splbid %>";
            var xjkhid = "<%=xjkhid %>";
            var sst = "<%=sst %>";            
            var paraccid = getUrlParam("paraccid");
            if (paraccid != "" && paraccid != undefined) {
                $("#clients").val(paraccid);
            }

            if (splbid != "" || xjkhid != "" || sst != "") {
                research();
            } else {
                $("#load").hide();
                $("#mybody").removeClass("blur");
            }
            LoadKfbhList();
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
            //权限控制
            ccid = $("#clients").val();
            if (ccid == "") {
                alert("对不起,您没有相关权限！");
                $("#load").hide();
                $("#mybody").removeClass("blur");
                return;
            } else
                ccid += "-%";

            setTimeout(function () {
                var ksrq = $("#ksrq").val();
                var jsrq = $("#jsrq").val();

                if (CheckDateTime(ksrq) == false) {
                    alert("开始日期不是一个日期！");
                    return;
                } else if (CheckDateTime(jsrq) == false) {
                    alert("结束日期不是一个日期！");
                    return;
                }
                $("#load").show();
                $("#mybody").addClass("blur");
                var myorderInfo = escape(orderFiled + " " + orderMode);
                $.getJSON("HhRepData.aspx", { sst: "<%=sst %>", xjkhid: "<%=xjkhid %>", splbid: "<%= splbid %>", "ccid": ccid, dataBegin: ksrq, dataEnd: jsrq, orderInfo: myorderInfo, approve: $("#approve").val(), khfl: "<%=khfl%>", kfbh: $("#kfbh").val(), yphh: $("#yphh").val(), ypmc: encodeURI($("#ypmc").val()) }, function (data) {
                    if (data.err == "") {
                        drawTabChart(data);
                    } else {
                        alert(data.err);
                        $("#mytable").empty();
                        $("#mytable").append(data.err);
                    }
                    $("#load").hide();
                    $("#mybody").removeClass("blur");
                });
            }, 500);
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
            tableHTML += "<tr><td>合  计</td><td>" + JSONObj.rows.length.toString() + "（总货号数）</td><td>" + sSl + "</td><td>" + fmoney(sJe) + "</td><td>100.00%</td><td>100.00%</td></tr>";
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

        //获取URL参数
        function getUrlParam(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
            var r = window.location.search.substr(1).match(reg);  //匹配目标参数
            if (r != null) return unescape(r[2]); return null; //返回参数值
        }

        function jump() {
            window.location.href = "SplbRep.aspx?ksrq=" + $("#ksrq").val() + "&jsrq=" + $("#jsrq").val() + "&approve=" + $("#approve").val();
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
            
            <label>开始日期 从：</label><input id="ksrq" type="date" value="<%= ksrq %>" />
            &nbsp;
        <label>至：</label><input id="jsrq" type="date" value="<%= jsrq %>" />
            <label style="margin-left: 10px;">单据状态: </label>
            <select id="approve">
                <option value="">全部</option>
                <option value="1">已审</option>
                <option value="0">未审</option>
            </select>

            <label style="margin-left: 10px;">管理对象: </label>
            <select id="clients">
                <%=AuthOptionCollect %>
            </select>
            <label>开发编号: </label>
            <select id="kfbh">
                <option value="">全部</option>
            </select>      
        </div>

        <div id="lite_line1">
            <label>样品货号: </label><input type="text" id="yphh" />
            <label>样品名称: </label><input type="text" id="ypmc" />   
             <a id="research" onclick="research();">查 询</a> 
        </div>
        
        <div class="infos">提示：1、点击表格列名（第一行）可对其进行排序！</div>
        <div id="mytable"></div>
        <div class="copyright">
            <br />
            Copyright &copy;2016 All rights reserved.<br>
            利郎（中国）有限公司
        </div>
    </div>
</body>
</html>
