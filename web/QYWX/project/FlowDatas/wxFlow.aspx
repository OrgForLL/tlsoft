﻿<%@ Page Language="C#" Debug="true"%>
<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    string OAConnStr = "server=192.168.35.10;uid=ABEASD14AD;pwd=+AuDkDew;database=tlsoft";
    string wxid;
    protected void Page_Load(object sender, EventArgs e)
    {
        string khid = Convert.ToString(Request.Params["tzid"]);
        wxid = Convert.ToString(Request.Params["wxid"]);
        if (string.IsNullOrEmpty(wxid))
        {
            if (khid == "1")
            {
                wxid = "3";
            }
            else if (string.IsNullOrEmpty(khid))
            {
                wxid = "0";
                clsSharedHelper.WriteErrorInfo("访问有误！");
            }
            else
            {
                string sql = "select * from wx_t_Deptment where id=@khid";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@khid", khid));
                string errInfo;
                DataTable dt;
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
                {
                    errInfo = dal.ExecuteQuerySecurity(sql, para, out dt);
                }
                if (errInfo != "")
                {
                    wxid = "0";
                    clsSharedHelper.WriteErrorInfo(errInfo);
                }
                else if (dt.Rows.Count < 1)
                {
                    wxid = "0";
                    clsSharedHelper.WriteErrorInfo("未找到贸易公司数据！");
                }
                else
                {
                    wxid = Convert.ToString(dt.Rows[0]["wxid"]);
                }
            }
        }
    }
</script>

<html>
<head>
    <meta charset="utf-8">
    <title>贸易公司微信访问量统计</title>
    <style type="text/css">
        *{
            margin: 0;
            padding: 0;
            font-family: 'Microsoft YaHei',San Francisco,Helvitica Neue,Helvitica,Arial,sans-serif;
            font-weight: normal;
            font-size: 15px;
            list-style: none;
            box-sizing: border-box;
        }
        a{
            text-decoration: none;
        }
        .header{
            width: 100%;
            position: fixed;
            z-index: 999;
            top: 0;
            height: 80px;
            background-color: #fff;
        }
        .title{
            width: 100%;
            height: 40px;
            line-height: 40px;
            background-color: #444;
            text-align: center;
            color: #fff;
        }
        .choose-wrap{
            width:100%; 
            background-color: #eee;
        }
        .chooseul{
            width: 100%;
            height: 50px;
            background-color: #eee;
            padding: 10px 15px 0 15px;
        }
        .choose-col{
            float: left;
            margin-right: 20px;
            text-align: right;
        }
        .choose-item{
            margin-bottom: 10px;
        }
        select ,input{
            font-size: 13px;
            height: 24px;
            width: 140px;
            color: #555;
        }
        .searchbtn{
            width: 80px;
            height: 24px;
            background-color: #444;
            color: #fff;
            text-align: center;
            border-radius: 4px;
            display: inline-block;
            cursor: default; ;
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
        /*数据列表*/
        .content{
            width: 100%;
            overflow-y: auto;
            position: absolute;
            top: 90px;
            bottom: 40px;
            z-index: 10;
            display: table;
        }
        .table-header{
            width: 100%;
            position: fixed;
            display: table;
            height: 32px;
            z-index: 999;
        }
        .table-row{
            display: table-row;
            width: 100%; 
        }
        .table-row:hover{
            background-color: #fcf9f9;
        }
        .table-item{
            display: table-cell;
            vertical-align:middle;
            text-align:center;
            border-bottom: 1px solid #d7d7d7;
            border-left: 1px solid #d7d7d7;
            width:14.2%;
            padding: 4px 0;
            font-size: 13px;
        }
        .header-item{
            padding: 5px 0;
            background-color: #eee;
            font-size: 15px;
            border-top: 1px solid #d7d7d7;
        }
        .table-con{
            margin-top: 32px;
            margin-bottom: 66px;
            width: 100%;
            display: table;
        }
        .imglink{
            text-decoration: none;
            color: #0fa061;
        }
        .imglink:hover{
            text-decoration: underline;
            color: #cd6106;
        }
        .total{
            background-color: #eee;
            position: fixed;
            bottom: 40px;
            display: table;
            width: 100%;
            height: 26px;
            border-top: 1px solid #d7d7d7;
        }
        .footer{
            position: fixed;
            bottom: 0;
            width: 100%;
            padding: 0 30px 15px 15px;
            height: 40px;
            background-color: #fff;
            z-index: 200;
        }
        .footer span, .pagebtn{
            font-size: 13px;
            color: #000;
        }
        .footer-left{
            float: left;
        }
        .footer-right{
            float: right;
        }
        .pagenum{
            width: 35px;
            height: 18px;
        }
        .floatfix:after {
            content: "";
            display: table;
            clear: both;
        }
       .countbtn
       {
           position:fixed;
            width: 100px;
            height: 24px;
            background-color: #444;
            color: #fff;
            text-align: center;
            border-radius: 4px;
            display: inline-block;
            cursor: default; 
       }
       .searchbtn:hover 
       {
           background:#E0FFFF; 
           color:#000;
       }  
       .choose-right
       {
           float:right;
           padding-right:120px;
       }
        .khmc
        {
           color:Blue;
           text-decoration: underline;  
        }
    </style>
</head>
<body>
    <div class="my_mask">
    </div>
    <div class="my_toast">
        正在统计，请稍候..</div>
    <div class="header">
        <div class="title">
            <p>贸易公司微信访问量统计</p>
        </div>
        <!-- 查询条件列表 -->
        <div class="choose-wrap">
            <ul class="chooseul floatfix">
                <li class="choose-col">
                    <div class="choose-item">
                        <span>日期:</span>
                        <input id="ksrq" type="text" value="" onclick="jeDate({dateCell:'#ksrq',isTime:true,format:'YYYY-MM-DD '})" />
                        <span>至</span>
                        <input id="jsrq" type="text" value="" onclick="jeDate({dateCell:'#jsrq',isTime:true,format:'YYYY-MM-DD '})" />
                    </div>
                </li>
                <li class="choose-col">
                    <div class="choose-item">
                        <span>客户名称:</span>
                        <input type="text" id="khmc" value="" />
                    </div>
                </li>
                <li class="choose-col">
                    <div class="choose-item">
                        <div class="searchbtn">
                            查询</div>
                    </div>
                </li>
                <li class="choose-col choose-right">
                    <div class="choose-item">
                        <div class="countbtn">
                            具体流量统计</div>
                    </div>
                </li>
            </ul>
        </div>
    </div>
    <!-- 数据列表 -->
    <div class="content">
        <!-- 表头 -->
         <table class="table-header">
            <tr class="table-row">
                <th  class="table-item header-item" onclick="sortSeach('khid')">客户名称</th>
                <th  class="table-item header-item" onclick="sortSeach('mdsl')">门店数</th>
                <th  class="table-item header-item" onclick="sortSeach('zrs')">总人数</th>
                <th  class="table-item header-item" onclick="sortSeach('sxrs')">上线人数</th>
                <th  class="table-item header-item" onclick="sortSeach('syrs')">使用人数</th>
                <th  class="table-item header-item" onclick="sortSeach('syl')">使用率</th>
            </tr>
        </table>
        <!-- 表格内容 -->
          <table class="table-con">
            <tr class="table-row">
                <td class="table-item">晋江第一分公司</td>
                <td class="table-item">1</td>
                <td class="table-item">2</td>
                <td class="table-item">3</td>
                <td class="table-item">4</td>
                <td class="table-item">5</td>
            </tr>
        </table>

        <!-- 合计 -->
        <table class="total">
            <tr class="table-row">
                <td class="table-item">合计</td>
                <td class="table-item" id="sum_mds"></td>
                <td class="table-item" id="sum_zrs"></td>
                <td class="table-item" id="sum_sxrs"></td>
                <td class="table-item" id="sum_syrs"></td>
                <td class="table-item"></td>
            </tr>
        </table>
    </div>
    <!-- 底部分页 -->
    <div class="footer floatfix">
        <div class="footer-left">
            <span>[记录数：<span class="totalCount">0</span>条]</span> <span>[共<span class="pageCount">1</span>页
                第<span class="currentPage">1</span>页]</span>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/jedate/jedate.min.js"></script>
    <script type="text/javascript">
        var sort = "", parentid = "<%=wxid %>";
        function getQuerying(name) {
            var value;
            var url = location.search.replace("?", "");
            var paras = url.split('&');
            for (var i = 0; i < paras.length; i++) {
                if (paras[i].indexOf(name + "=") > -1) {
                    value = paras[i].replace(name + "=", "")
                    return value;
                    break;
                }
            }
            return null;
        }
        $(document).ready(function () {
            //            var wxid = getQuerying("wxid");
            //            if (wxid != null && !isNaN(parentid)) {
            //                parentid = wxid;
            //            }
            var myDate = new Date();
            $("#ksrq").val(myDate.getFullYear() + "-" + (myDate.getMonth() + 1) + "-" + myDate.getDate());
            $("#jsrq").val(myDate.getFullYear() + "-" + (myDate.getMonth() + 1) + "-" + myDate.getDate());
            $(".searchbtn").bind("click", function () { loadData(); });
            loadData();
            $(".countbtn").bind("click", function () { window.open("http://tm.lilanz.com/oa/project/flowDatas/flowstatic.aspx?oauth=0"); })
        });

        function MyLink(wxid) {
            if (parentid == "3") {
                window.location.href = "http://tm.lilanz.com/qywx/project/flowDatas/wxFlow.aspx?wxid=" + wxid;
            } else {
                $(".my_toast").html("已无下级数据");
                $(".my_mask").show();
                $(".my_toast").show();
                $(".my_mask").fadeOut(1300);
                $(".my_toast").fadeOut(1300);
            }
        }
        function loadData() {
            $(".table-con").empty();
            $(".my_toast").html("正在统计，请稍候..");
            $(".my_mask").show();
            $(".my_toast").show();
            $.ajax({
                type: "POST",
                timeout: 15000,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "wxFlowCore.aspx",
                data: { ksrq: $("#ksrq").val(), jsrq: $("#jsrq").val(), khmc: $("#khmc").val(), orderSort: sort, parentid: parentid },
                success: function (msg) {
                    // console.log(msg);
                    if (msg.indexOf("Error") > -1) {
                        alert("出错了" + msg);
                    } else {
                        addRecode(msg);
                    }
                    $(".my_mask").hide();
                    $(".my_toast").hide();
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("数据较多,已超时！请重新查找");
                    $(".my_mask").hide();
                    $(".my_toast").hide();
                }
            });
        }

        /* <table class='table-con'>
            <tr class='table-row'>
                <td class='table-item'>晋江第一分公司</td>
                <td class='table-item'>1</td>
                <td class='table-item'>2</td>
                <td class='table-item'>3</td>
                <td class='table-item'>4</td>
                <td class='table-item'>5</td>
            </tr>
        </table>*/
        function addRecode(rtjson) {
            var table = JSON.parse(rtjson);
            var rows = table.mydata;
            var sum_mds = 0, sum_zrs = 0, sum_sxrs = 0, sum_syrs = 0;
            var rowhtml = "<div class='table-row'><div class='table-item'><a class='khmc' onclick=MyLink('#wxid#')>#khmc#</a></div><div class='table-item'>#mdsl#</div><div class='table-item'>#zrs#</div>";
            rowhtml += "<div class='table-item'>#sxrs#</div><div class='table-item'>#syrs#</div><div class='table-item'>#syl#%</div></div>";
            rowhtml = "<tr class='table-row'><td class='table-item'><a class='khmc' onclick=MyLink('#wxid#')>#khmc#</a></td><td class='table-item'>#mdsl#</td><td class='table-item'>#zrs#</td>";
            rowhtml += "<td class='table-item'>#sxrs#</td><td class='table-item'>#syrs#</td><td class='table-item'>#syl#%</td></tr>";
            $(".totalCount").html(rows.length);
            var dataRow = "";
            for (var i = 0; i < rows.length; i++) {
                sum_mds += Number(rows[i].mdsl);
                sum_zrs += Number(rows[i].zrs);
                sum_sxrs += Number(rows[i].sxrs)
                sum_syrs += Number(rows[i].syrs);
                dataRow += rowhtml.replace("#khmc#", rows[i].khmc).replace("#wxid#", rows[i].wxid).replace("#mdsl#", rows[i].mdsl).replace("#zrs#", rows[i].zrs).replace("#sxrs#", rows[i].sxrs).replace("#syrs#", rows[i].syrs).replace("#syl#", rows[i].syl);
                if (i == 0) {
                    console.log(dataRow);
                }
            }
         //   console.log(dataRow);
            $(".table-con").append(dataRow);
            $("#sum_mds").html(sum_mds);
            $("#sum_zrs").html(sum_zrs);
            $("#sum_sxrs").html(sum_sxrs);
            $("#sum_syrs").html(sum_syrs);
        }
        function sortSeach(field) {
            var Arrow = $("#s" + field).html();
            $("#skhmc").html("");
            $("#smdsl").html("");
            $("#szrs").html("");
            $("#ssxrs").html("");
            $("#ssyrs").html("");
            $("#ssyl").html("");
            if (Arrow == "↑" || Arrow == "") {
                sort = field + " desc";
                $("#s" + field).html("↓");
            } else {
                sort = field + " asc";
                $("#s" + field).html("↑");
            }
            loadData();
        }
        
    </script>
</body>
</html>