<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>

<!DOCTYPE html>
<script runat="server">
    public string khSelectOptions = "", nowTime = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            string AppSystemKey = clsWXHelper.GetAuthorizedKey(3);
            string CustomerID = Convert.ToString(Session["qy_customersid"]);
            string CustomerName = Convert.ToString(Session["qy_cname"]);
            string RoleName = Convert.ToString(Session["RoleName"]);
            string mdid = Convert.ToString(Session["mdid"]);

            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统！");
            else if (string.IsNullOrEmpty(mdid))
                clsWXHelper.ShowError("该功能仅供门店使用！");
            else
            {
                using (LiLanzDALForXLM dal = new LiLanzDALForXLM(clsConfig.GetConfigValue("OAConnStr")))
                {
                    string optionStr = @"<option value=""{0}"">{1}</option>";
                    string str_sql = string.Format(@"select mdid,mdmc from t_mdb where mdid={0}", mdid);
                    DataTable dt;
                    string errinfo = dal.ExecuteQuery(str_sql, out dt);
                    if (errinfo == "")
                    {
                        StringBuilder sbOption = new StringBuilder();
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            sbOption.AppendFormat(optionStr, dt.Rows[i]["mdid"].ToString(), dt.Rows[i]["mdmc"].ToString());
                        }//end for                        
                        khSelectOptions = sbOption.ToString();
                        sbOption.Length = 0;

                        nowTime = DateTime.Now.ToString("yyyy-MM-dd");
                    }
                }//end using
            }
        }
    }
</script>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <title></title>
    <style type="text/css">
        .header {
            border-bottom: 1px solid #eaeaea;
        }

            .header .title {
                line-height: 50px;
                font-size: 17px;
                text-align: left;
                padding-left: 50px;
                color: #f3454f;
            }

            .header .back_btn {
                font-size: 22px;
                position: absolute;
                top: 0;
                left: 0;
                line-height: 50px;
                padding: 0 20px;
                color: #f3454f;
                -webkit-tap-highlight-color: transparent;
            }

                .header .back_btn:active {
                    background-color: #f46f5c;
                    color: #fff;
                }

        .page {
            background-color: #f2f2f2;
            padding: 0;
        }

        .page-not-footer, .page-not-header-footer {
            bottom: 40px;
        }

        .data_wrap {
            position: absolute;
            top: 80px;
            left: 0;
            width: 100%;
            bottom: 0;
            overflow-x: hidden;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            background-color: #fff;
            /*border-top:1px solid #eaeaea;*/
        }

            .data_wrap .no-result {
                letter-spacing: 1px;
                color: #aaa;
            }

        .data_head.vip_item {
            background-color: #f46f5c;
            color: #fff;
            font-weight: bold;
            font-size: 16px;
            border-bottom: none;
            font-size: 0;
        }

        .vip_item {
            font-size: 0;
            box-sizing: border-box;
            white-space: nowrap;
            border-bottom: 1px solid #eaeaea;
        }

            .vip_item .data_item {
                display: inline-block;
                width: 30%;
                font-size: 14px;
                line-height: 42px;
                padding-left: 5px;
            }

                .vip_item .data_item.name {
                    width: 20%;
                }

                .vip_item .data_item.vipss {
                    width: 20%;
                    text-align: center;
                }

        .footer {
            height: 40px;
            line-height: 40px;
            font-size: 14px;
            background-color: #eff3f5;
            /*border-top:1px solid #f7f7f7;*/
        }

            .footer > .static {
                text-align: center;
                color: #f3454f;
                font-weight: bold;
                font-size: 16px;
            }

        .filter_item {
            height: 40px;
            line-height: 40px;
            display: flex;
            display: -webkit-box;
            position: relative;
        }

            .filter_item > .label {
                width: 28%;
                text-align: center;
                font-size: 15px;
                background-color: #fff;
            }

            .filter_item .store_list, .filter_item .date_time {
                width: 72%;
                height: 100%;
                background-color: #f7f7f7;
            }

            .filter_item select, .filter_item input {
                -webkit-appearance: none;
                border: none;
                height: 100%;
                line-height: 40px;
                width: 100%;
                font-size: 14px;
                vertical-align: top;
                padding: 0 10px;
                border-radius: 0;
                background-color: transparent;
                position: relative;
                z-index: 200;
            }

            .filter_item .fa-angle-down {
                position: absolute;
                top: 0;
                right: 0;
                padding: 0 15px;
                line-height: 40px;
                font-size: 22px;
                z-index: 100;
            }

        .data_body .data_item.birthday, .data_body .data_item.mobile {
            font-weight: 200;
        }

            .data_body .data_item.mobile > a {
                color: #3aba6f !important;
            }

        .btn.search {
            text-align: center;
            background-color: #f46f5c;
            font-weight: bold;
            color: #fff;
            width: 100%;
            position: absolute;
            top: 0;
            right: 0;
            z-index: 200;
            width: 100px;
            text-align: center;
            background: linear-gradient(to right,#f9533f,#f46f5c);
        }
            .btn.search > img {
                width: 24px;
                vertical-align: middle;
            }
        .btn.subscribe {
            position: absolute;
            right: 10px;
            bottom: 10px;
            background-color: #f3454f;
            width: 60px;
            border-radius: 6px;
            border: 2px solid #eee;
            background: linear-gradient(120deg,#f3444e,#f57c61);
            text-align: center;
        }

            .btn.subscribe > img {
                width: 28px;
                margin-top: 5px;
            }

            .btn.subscribe > p {
                line-height: 1;
                color: #fff;
                font-weight: bold;
                margin-bottom: 5px;
            }

        /*table_infos style*/
        .table_datas {
            position: relative;
        }

        .table_infos {
            background-color: #fff;
            width: 100%;
            overflow: auto;
            position: absolute;
            z-index: 100;
            top: 80px;
            left: 0;
            width: 100%;
            bottom: 0;
        }

            .table_infos table {
                border-collapse: collapse;
                color: rgba(0,0,0,.65);
                margin: 0 auto;
                border: none;
            }

            .table_infos tbody > tr > td, .table_infos thead > tr > th {
                padding: 10px 8px;
                min-width: 50px;
                /*word-break: keep-all;*/
            }

            .table_infos thead > tr > th, .table_head_colne > div {
                font-weight: 700;
                background-color: #f46f5c;
                text-align: left;
                color: #fff;
            }

        .table_head_colne {
            font-size: 0;
            position: absolute;
            top: 80px;
            left: 0;
            width: 100%;
            z-index:200;
            display:none;            
        }

            .table_head_colne > div {
                font-size: 14px;
                display: inline-block;
                padding: 10px 8px;
                height: 40px;
                vertical-align: top;                
                background-color: rgba(244,111,92,0.9);
            }

        .table_title {
            font-weight: 700;
            background-color: #f46f5c;
            text-align: left;
            color: #fff;
            padding: 10px 8px;
        }

        .table_infos tbody td {
            border-bottom: 1px solid #e9e9e9;
        }

        .table_infos .center {
            text-align: center;
        }

        .table_infos .remove {
            color: #f3454f;
            text-decoration: underline;
        }

        .data_item.vipss .logo {
            width: 24px;
            vertical-align: middle;
        }
    </style>
</head>
<body>
    <div class="header">
        <span class="back_btn"><i class="fa fa-angle-left"></i></span>
        <p class="title">利郎VIP生日订阅</p>
    </div>
    <div class="wrap-page">
        <div class="page page-not-header-footer" id="index">
            <div class="filter_wrap">
                <div class="filter_item">
                    <div class="label">门店</div>
                    <div class="store_list">
                        <select>
                            <%=khSelectOptions %>
                        </select>
                        <i class="fa fa-angle-down"></i>
                    </div>
                </div>
                <div class="filter_item">
                    <div class="label">日期</div>
                    <div class="date_time">
                        <input type="date" value="<%=nowTime %>" />
                    </div>
                    <div class="btn search" onclick="javascript:loadList();">查 询</div>
                </div>
            </div>
            <div class="data_wrap">
                <div class="data_head vip_item">
                    <div class="data_item name">姓名</div>
                    <div class="data_item birthday">生日</div>
                    <div class="data_item mobile">电话</div>
                    <div class="data_item vipss">所属</div>
                </div>
                <div class="data_body">
                    <!--<div class="vip_item">
                        <div class="data_item name">张三</div>
                        <div class="data_item birthday">2015-05-02</div>
                        <div class="data_item mobile"><a href="tel:15260825002">15260825002</a></div>
                        <div class="data_item vipss">
                            <img class="logo" src="../../res/img/storesaler/lilanzlogo2.jpg" />
                            <img class="logo" src="../../res/img/storesaler/qswlogo.jpg" />
                        </div>
                    </div>-->
                </div>
                <p class="no-result center-translate">暂时还没有订阅数据..</p>
            </div>

            <div class="btn subscribe">
                <img src="../../res/img/storesaler/subs_icon.png" />
                <p>订 阅</p>
            </div>
        </div>

        <div class="page page-not-header page-bot" id="subscribed">
            <div class="filter_wrap">
                <div class="filter_item">
                    <div class="label">当前门店</div>
                    <div class="store_list">
                        <select><%=khSelectOptions %></select>
                    </div>
                </div>
                <div class="filter_item">
                    <div class="label">订阅天数</div>
                    <div class="date_time">
                        <input type="number" placeholder="输入订阅天数.." id="subDays" />
                    </div>
                    <div class="btn search" onclick="javascript:subBirthNotice();"><img src="../../res/img/storesaler/subs_icon.png" />添加订阅</div>
                </div>
            </div>

            <!--数据-->
            <div class="table_infos" id="subs_table">
                <!--<p class="table_title">已订阅信息</p>-->
                <table style="table-layout: fixed; width: 100%;">
                    <thead>
                        <tr>
                            <th width="50%">已订阅信息</th>
                            <th width="30%" style="text-align: center;"></th>
                            <th width="20%" style="text-align: center;"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <!--<tr>
                            <td>福建晋江第一分公司</td>
                            <td class="center">2天</td>
                            <td><a href="javascript:;" class="remove">移除</a></td>
                        </tr>-->
                    </tbody>
                </table>
            </div>
            <div class="table_head_colne">
                <div style="width: 50%">已订阅信息</div>
                <div style="width: 30%;"></div>
                <div style="width: 20%;"></div>
            </div>
        </div>
    </div>
    <div class="footer">
        <div class="static">统计：<span>--</span>人</div>
    </div>

    <script type="text/html" id="tmp_vip_item">
        <div class="vip_item">
            <div class="data_item name">{{xm}}</div>
            <div class="data_item birthday">{{csrq}}</div>
            <div class="data_item mobile"><a href="tel:{{yddh}}">{{yddh}}</a></div>
            <div class="data_item vipss">
                <img class="logo" {{if wx_1 != '1'}} style="display:none;" {{/if}} src="../../res/img/storesaler/lilanzlogo2.jpg" />
                <img class="logo" {{if wx_4 != '1'}} style="display:none;" {{/if}} src="../../res/img/storesaler/qswlogo.jpg" />
            </div>
        </div>
    </script>
    <!--订阅记录-->
    <script type="text/html" id="tmp_subscribed">
        <tr data-khid="{{khid}}" data-id="{{ID}}">
            <td>{{khmc}}</td>
            <td class="center">{{days}}天</td>
            <td><a href="javascript:;" class="remove">移除</a></td>
        </tr>
    </script>

    <script type="text/javascript" src="../../res/js/template.js"></script>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>
    <script type="text/javascript">
        var pageRoute = [], currentPage = "index";
        $(document).ready(function () {
            pageRoute.push(currentPage);
            BindEvents();
            LeeJSUtils.LoadMaskInit();            
        });

        window.onload = function () {
            var khid = LeeJSUtils.GetQueryParams("khid");
            var day = LeeJSUtils.GetQueryParams("day");
            if (khid != "") {
                $("#index .store_list select").val(khid);
                $("#subscribed .store_list select").val(khid);
            }
            
            if (!isNaN(day))
                $("#index .date_time input").val(AddDays(day));

            loadList();
        }

        function BindEvents() {
            document.body.addEventListener('touchstart', function () { });

            $(".btn.subscribe").click(function () {
                $("#subscribed").removeClass("page-bot");
                currentPage = "subscribed";
                pageRoute.push(currentPage);
                loadSubsRecords();
            });

            $(".header .back_btn").click(function () {
                if (pageRoute.length > 1) {
                    $("#" + currentPage).addClass("page-bot");
                    pageRoute.pop();
                }
            });

            $(".table_infos").scroll(function () {
                var st = $(".table_infos").scrollTop();
                if (parseInt(st) > 40) {
                    $(".table_head_colne").fadeIn(500);
                } else
                    $(".table_head_colne").fadeOut(50);
            });

            $("#subs_table").on("click", ".remove", function () {
                var id = $(this).parent().parent().attr("data-id");
                if (confirm("确定移除该条订阅记录？")) {
                    removeSubscribe(id);
                }
            })
        }

        function subBirthNotice() {
            var days = $("#subDays").val().trim();
            if (days == "" || isNaN(days))
                LeeJSUtils.showMessage("error", "订阅天数，请输入数字！");
            else if (parseInt(days) < 1 || parseInt(days) > 31) {
                LeeJSUtils.showMessage("error", "订阅天数不合法！");
            }else {
                LeeJSUtils.showMessage("loading", "正在查询订阅记录..");
                setTimeout(function () {
                    $.ajax({
                        type: "POST",
                        timeout: 15 * 1000,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        data: { days: days },
                        url: "vipBirthday.aspx?ctrl=birthdaysubscribe"
                    }).done(function (msg) {
                        console.log(msg);
                        var data = JSON.parse(msg);
                        if (data.code == "200") {
                            LeeJSUtils.showMessage("successed", "订阅成功");
                            setTimeout(loadSubsRecords, 200);
                        } else
                            LeeJSUtils.showMessage("error", data.errmsg);
                    }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                        console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                        LeeJSUtils.showMessage("error", XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    });
                }, 50);
            }
        }

        //查询订阅记录
        function loadSubsRecords() {
            LeeJSUtils.showMessage("loading", "正在查询订阅记录..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 15 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "vipBirthday.aspx?ctrl=subscriptionrecord"
                }).done(function (msg) {
                    console.log(msg);
                    var data = JSON.parse(msg);
                    if (data.code == "200") {
                        var html = ""
                        for (var i = 0; i < data.info.length; i++) {
                            html += template("tmp_subscribed", data.info[i]);
                        }
                        $("#subscribed .table_infos tbody").empty().html(html);
                        $("#leemask").hide();
                    } else
                        LeeJSUtils.showMessage("error", data.errmsg);
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    LeeJSUtils.showMessage("error", XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                });
            }, 50);
        }

        function loadList() {
            LeeJSUtils.showMessage("loading", "正在加载..");
            var khid = $("#index .store_list select").val();
            var rq = $("#index .date_time input").val();
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 15 * 1000,
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    data: { khid: khid, rq: rq },
                    url: "vipBirthday.aspx?ctrl=getbirthdaylist"
                }).done(function (msg) {
                    //console.log(msg);
                    var data = JSON.parse(msg);
                    if (data.code == "200") {
                        var rows = data.info;
                        var html = "";
                        for (var i = 0; i < rows.length; i++) {
                            html += template("tmp_vip_item", rows[i]);
                        }//end for
                        if (html != "") {
                            $("#index .data_body").empty().html(html);
                            $("#index .data_wrap .no-result").hide();
                            $(".footer > .static > span").text(rows.length);
                        } else {
                            $("#index .data_body").empty();
                            $("#index .data_wrap .no-result").show();
                            $(".footer > .static > span").text("-- ");
                        }

                        $("#leemask").hide();
                    } else
                        LeeJSUtils.showMessage("error", data.errmsg);
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    LeeJSUtils.showMessage("error", XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                });
            }, 50);
        }

        //移除订阅接口
        function removeSubscribe(id) {
            LeeJSUtils.showMessage("loading", "正在查询订阅记录..");
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    timeout: 15 * 1000,
                    data:{id:id},
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "vipBirthday.aspx?ctrl=delsubscribe"
                }).done(function (msg) {
                    console.log(msg);
                    var data = JSON.parse(msg);
                    if (data.code == "200") {
                        LeeJSUtils.showMessage("successed", "取消成功！");
                        setTimeout(loadSubsRecords, 500);
                    } else
                        LeeJSUtils.showMessage("error", data.errmsg);
                }).fail(function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log(XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                    LeeJSUtils.showMessage("error", XMLHttpRequest.status + "|" + XMLHttpRequest.statusText);
                });
            }, 100);
        }

        Date.prototype.Format = function (fmt) { //author: meizz 
            var o = {
                "M+": this.getMonth() + 1, //月份 
                "d+": this.getDate(), //日 
                "h+": this.getHours(), //小时 
                "m+": this.getMinutes(), //分 
                "s+": this.getSeconds(), //秒 
                "q+": Math.floor((this.getMonth() + 3) / 3), //季度 
                "S": this.getMilliseconds() //毫秒 
            };
            if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
            for (var k in o)
                if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
            return fmt;
        }

        function GetDateStr(AddDayCount) {
            var dd = new Date();
            dd.setDate(dd.getDate() + AddDayCount);//获取AddDayCount天后的日期  
            var y = dd.getFullYear();
            var m = (dd.getMonth() + 1) < 10 ? "0" + (dd.getMonth() + 1) : (dd.getMonth() + 1);//获取当前月份的日期，不足10补0  
            var d = dd.getDate() < 10 ? "0" + dd.getDate() : dd.getDate();//获取当前几号，不足10补0  
            return y + "-" + m + "-" + d;
        }

        function AddDays(days) {            
            var now = new Date();
            var newdate = new Date();
            var newtimems = newdate.getTime() + (days * 24 * 60 * 60 * 1000);
            newdate.setTime(newtimems);
            return newdate.Format("yyyy-MM-dd");
        }
    </script>
</body>
</html>
