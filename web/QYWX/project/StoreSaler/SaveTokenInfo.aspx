<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<script runat="server">
    public string AppSystemKey = "", CustomerID = "", CustomerName = "", mdid = "", mdmc = "", tzid = "";
    public int SystemID = 3;
    private string DBConstr = clsConfig.GetConfigValue("OAConnStr");

    protected void Page_Load(object sender, EventArgs e)
    {
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            AppSystemKey = clsWXHelper.GetAuthorizedKey(SystemID);
            if (AppSystemKey == "")
                clsWXHelper.ShowError("对不起，您还未开通全渠道系统权限！");
            else
            {
                CustomerID = Convert.ToString(Session["qy_customersid"]);
                CustomerName = Convert.ToString(Session["qy_cname"]);
                mdid = Convert.ToString(Session["mdid"]);

                using (LiLanzDALForXLM dal10 = new LiLanzDALForXLM(DBConstr))
                {
                    string sql = "select top 1 khid,mdmc from t_mdb where mdid=" + mdid;
                    DataTable dt;
                    string errinfo = dal10.ExecuteQuery(sql, out dt);
                    if (errinfo == "" && dt.Rows.Count > 0)
                    {
                        mdmc = dt.Rows[0]["mdmc"].ToString();
                        tzid = dt.Rows[0]["khid"].ToString();

                        dt.Clear(); dt.Dispose();
                    }
                }//end using           
            }
        }
    }
</script>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <style type="text/css">
        body {
            color: #363c44;
        }

        input {
            border: 1px solid #eee;
            width: 100%;
            height: 38px;
            line-height: 36px;
            padding: 0 10px;
            border-radius: 0;
            font-size: 14px;
            -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
            background-color: transparent;
        }

        .page {
            background-color: #f2f2f2;
        }

        #index {
            transition: all 0.5s;
            padding-top: 60px;
        }

        .tokenform {
            width: 100%;
            background-color: #fff;
            border-right: 1px solid #eee;
            border-bottom: 1px solid #eee;
            position: relative;
            border-radius: 4px;
            padding: 20px 15px 10px 15px;
        }

        .icon {
            width: 68px;
            height: 68px;
            background-color: #ccc;
            color: #fff;
            border-radius: 50%;
            text-align: center;
            position: absolute;
            right: 10px;
            top: -34px;
            transition: all 0.5s;
            display: flex;
            justify-content: center;
            align-items: center;
            border: 3px solid #fff;
        }

            .icon[data-status='success'] {
                background-color: #63b359;
            }

            .icon[data-status='error'] {
                background-color: #cc463d;
            }

        .item {
            margin-bottom: 15px;
        }

            .item > .label {
                margin-bottom: 3px;
                font-weight: bold;
            }

        .fitem {
            position: relative;
            display: -webkit-box;
            display: -webkit-flex;
            display: flex;
            -webkit-box-align: center;
            -webkit-align-items: center;
            align-items: center;
            border-bottom: 1px solid #efefef;
            height: 39px;
            line-height: 39px;
        }

            .fitem .label {
                width: 110px;
            }

        .bd > input {
            border: none;
            text-align: right;
        }

        .fitem .bd {
            -webkit-box-flex: 1;
            -webkit-flex: 1;
            flex: 1;
        }

        input[type='date'] {
            background-color: transparent;
            text-align: right;
            padding: 0;
        }

            input[type='date']::-webkit-calendar-picker-indicator {
                display: none;
            }

        .btn_wrap {
            margin-top: 15px;
            border-radius: 4px;
            font-size: 0;
            background-color: #ddd;
            border-radius: 4px;
        }

            .btn_wrap > a {
                display: inline-block;
                width: 100%;
                text-align: center;
                color: #fff;
                font-size: 16px;
                font-weight: 600;
                padding: 8px 0;
            }

        #confirm {
            background-color: #63b359;
            border-radius: 4px;
        }

        /*radio style*/
        #isactive {
            display: none;
        }

        .switch {
            box-shadow: rgb(255, 255, 255) 0px 0px 0px 0px inset;
            border: 1px solid rgb(223, 223, 223);
            transition: border 0.4s, box-shadow 0.4s;
            background-color: rgb(255, 255, 255);
            width: 50px;
            height: 30px;
            border-radius: 20px;
            line-height: 30px;
            display: inline-block;
            vertical-align: middle;
            cursor: pointer;
            box-sizing: content-box;
            outline: none;
        }

            .switch small {
                width: 30px;
                height: 30px;
                top: 0;
                border-radius: 100%;
                text-align: center;
                display: block;
                background: #fff;
                box-shadow: 0 1px 3px rgba(0,0,0,.4);
                -webkit-transition: all .2s;
                transition: all .2s;
                overflow: hidden;
                color: #000;
                font-size: 12px;
                position: relative;
                -webkit-user-select: none;
                user-select: none;
                -webkit-tap-highlight-color: transparent;
            }

            .switch.open small {
                left: 20px;
                background-color: rgb(255, 255, 255);
            }

            .switch.open {
                box-shadow: rgb(100, 189, 99) 0px 0px 0px 16.6667px inset;
                border: 1px solid rgb(100, 189, 99);
                transition: border 0.4s, box-shadow 0.4s, background-color 1.4s;
                background-color: rgb(100, 189, 99);
            }

        .ticket_color {
            vertical-align: middle;
        }

            .ticket_color .title {
                text-align: center;
                line-height: 36px;
                font-weight: 600;
            }

            .ticket_color ul {
                text-align: center;
            }

                .ticket_color ul li {
                    display: inline-block;
                    width: 36px;
                    height: 36px;
                    background-color: #ccc;
                    margin-right: 5px;
                    position: relative;
                }

        .tc.c1 {
            background-color: #cb6358;
        }

        .tc.c2 {
            background-color: #4883c5;
        }

        .tc.c3 {
            background-color: #4b6d92;
        }

        .tc.c4 {
            background-color: #347d76;
        }

        .tc.c5 {
            background-color: #917a4e;
        }

        .tc.c6 {
            background-color: #d31322;
        }

        .tc .fa {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            line-height: 36px;
            color: #fff;
            font-size: 20px;
            display: none;
        }

        .tc.selected .fa {
            display: block;
        }

        .topbtn {
            display: flex;
            justify-content: center;
            align-items: center;
            position: fixed;
            top: 5px;
            left: 10px;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: rgba(0,0,0,.6);
            font-size: 26px;
            color: #fff;
            z-index: 2000;
        }

        #returnBtn {
            margin-left: -2px;
            margin-top: -2px;
        }
    </style>
</head>
<body>
    <div class="topbtn">
        <i class="fa fa-angle-left" id="returnBtn"></i>
    </div>
    <!--<div class="header">
        <i class="fa fa-angle-left"></i>
        <p class="title">活动礼券创建</p>
    </div>-->
    <div class="wrap-page">
        <div class="page" id="index">
            <div class="tokenform">
                <div class="icon" data-status="">
                    <i id="icreate" class="fa fa-3x fa-plus" style="display: none; padding: 5px 0 0 0;"></i>
                    <i id="iprocess" class="fa fa-3x fa-spinner fa-spin"></i>
                    <i id="ierror" class="fa fa-3x fa-times" style="display: none;"></i>
                    <i id="iedit" class="fa fa-3x fa-edit" style="display: none; padding: 5px 0 0 5px;"></i>
                </div>
                <div class="item">
                    <div class="label">活动名</div>
                    <input type="text" placeholder="输入活动名称" id="activename" />
                </div>
                <div class="item">
                    <div class="label">礼券名</div>
                    <input type="text" placeholder="输入礼券名称" id="tokenname" />
                </div>
                <div class="fitem">
                    <div class="label">限定领取人数</div>
                    <div class="bd">
                        <input type="text" placeholder="0代表不限制" id="mrcount" value="不限" />
                    </div>
                </div>
                <div class="fitem">
                    <div class="label paypointdesc">授权消费点数<i class="fa fa-question-circle" style="padding-left:4px;"></i></div>
                    <div class="bd">
                        <input type="number" value="1" id="getpaypoint" />
                    </div>
                </div>
                <div class="fitem">
                    <div class="label">有效期开始</div>
                    <div class="bd">
                        <input type="date" id="starttime" />
                    </div>
                </div>
                <div class="fitem">
                    <div class="label">有效期截止</div>
                    <div class="bd">
                        <input type="date" id="endtime" />
                    </div>
                </div>
                <div class="fitem">
                    <div class="label">限定有效天数</div>
                    <div class="bd">
                        <input type="text" placeholder="0表示不限制" id="validdaycount" value="不限" />
                    </div>
                </div>
                <div class="fitem">
                    <div class="label">备注说明</div>
                    <div class="bd">
                        <input type="text" placeholder="输入备注说明" id="remark" />
                    </div>
                </div>
                <div class="fitem">
                    <div class="label">当前状态</div>
                    <div class="bd" style="text-align: right;">
                        <input type="checkbox" class="checkbox-switch" id="isactive" />
                        <span class="switch open" data-open="1"><small></small></span>
                    </div>
                </div>

                <!--卡券颜色-->
                <div class="ticket_color">
                    <p class="title">礼券颜色</p>
                    <ul>
                        <li class="tc c1 selected" data-dm="#cb6358">
                            <i class="fa fa-check"></i>
                        </li>
                        <li class="tc c2" data-dm="#4883c5">
                            <i class="fa fa-check"></i>
                        </li>
                        <li class="tc c3" data-dm="#4b6d92">
                            <i class="fa fa-check"></i>
                        </li>
                        <li class="tc c4" data-dm="#347d76">
                            <i class="fa fa-check"></i>
                        </li>
                        <li class="tc c5" data-dm="#917a4e">
                            <i class="fa fa-check"></i>
                        </li>
                        <li class="tc c6" data-dm="#d31322">
                            <i class="fa fa-check"></i>
                        </li>
                    </ul>
                </div>

                <div class="btn_wrap">
                    <a href="javascript:;" id="confirm">保 存</a>
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript" src="../../res/js/LeeJSUtils.min.js"></script>

    <script type="text/javascript">
        var isProcess = false, tid = "";
        var userid = "<%=CustomerID%>", username = "<%=CustomerName%>", tzid = "<%=tzid%>", mdid = "<%=mdid%>";

        $(document).ready(function () {
            tid = LeeJSUtils.GetQueryParams("tid");
            if (tid == "" || tid == "0" || tid == null) {
                //新增模式
                tid = "0";
                $(".icon").attr("data-status", "success");
                $(".icon>i").hide();
                $("#icreate").show();
            } else
                //编辑模式
                loadTokenInfo();

            BindEvents();
            FastClick.attach(document.body);
        });

        //首次进入加载数据
        function loadTokenInfo() {
            var tid = LeeJSUtils.GetQueryParams("tid");
            isProcess = true;
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    cache: false,
                    timeout: 5 * 1000,
                    data: { mdid: mdid, id: tid },
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=LoadTokenInfo",
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {
                            var data = JSON.parse(msg);
                            //console.log(msg);
                            if (data.list.length == 0) {
                                LeeJSUtils.showMessage("error", "请检查参数！ tid");
                                $(".icon").attr("data-status", "error");
                                $(".icon>i").hide();
                                $("#ierror").show();
                            }
                            else {
                                data = data.list[0];
                                $("#activename").val(data.ActiveName);
                                $("#tokenname").val(data.TokenName);

                                if (parseInt(data.MaxReceiveCount) == 0)
                                    $("#mrcount").val("不限");
                                else
                                    $("#mrcount").val(data.MaxReceiveCount);
                                $("#getpaypoint").val(data.GetPayPoint);
                                $("#starttime").val(data.starttime);
                                $("#endtime").val(data.endtime);

                                if (parseInt(data.ValidDayCount) == 0)
                                    $("#validdaycount").val("不限");
                                else
                                    $("#validdaycount").val(data.ValidDayCount);
                                $("#remark").val(data.Remark);

                                if (data.IsActive == "0") {
                                    $(".switch")[0].click();
                                }

                                //颜色选中
                                $(".tc.selected").removeClass("selected");
                                $(".tc[data-dm='" + data.TicketColor + "']").addClass("selected");
                                $("#index").css("background-color", data.TicketColor);

                                $(".icon").attr("data-status", "success");
                                $(".icon>i").hide();
                                $("#iedit").show();
                                isProcess = false;
                            }
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        isProcess = false;
                        LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                    }
                });
            }, 50);
        }

        //提交检查
        function formCheck() {
            if (isProcess)
                return;
            var activename = $("#activename").val().trim();
            var tokenname = $("#tokenname").val().trim();
            var maxreceivecount = $("#mrcount").val().trim();
            maxreceivecount = maxreceivecount == "不限" ? "0" : maxreceivecount;
            var getpaypoint = $("#getpaypoint").val().trim();
            var starttime = $("#starttime").val();
            var endtime = $("#endtime").val();
            var validdaycount = $("#validdaycount").val().trim();
            validdaycount = validdaycount == "不限" ? "0" : validdaycount;
            var remark = $("#remark").val().trim();
            var isactive = $(".switch").attr("data-open");
            if (activename == "") {
                LeeJSUtils.showMessage("error", "活动名不能为空！");
                return false;
            } else if (tokenname == "") {
                LeeJSUtils.showMessage("error", "礼券名不能为空！");
                return false;
            } else if (maxreceivecount == "") {
                LeeJSUtils.showMessage("error", "限定领取人数不能为空！");
                return false;
            } else if (isNaN(maxreceivecount)) {
                LeeJSUtils.showMessage("error", "限定领取人数只能输入数字，0代表不限！");
                return false;
            } else if (getpaypoint == "") {
                LeeJSUtils.showMessage("error", "授权消费点数不能为空且只能为数字！");
                return false;
            } else if (isNaN(getpaypoint)) {
                LeeJSUtils.showMessage("error", "授权消费点数只能输入数字！");
                return false;
            } else if (starttime == "") {
                LeeJSUtils.showMessage("error", "开始有效期不能为空！");
                return false;
            } else if (endtime == "") {
                LeeJSUtils.showMessage("error", "结束有效期不能为空！");
                return false;
            } else if (new Date(endtime) < new Date(starttime)) {
                LeeJSUtils.showMessage("error", "结束日期不能早于开始日期！");
                return false;
            } else if (validdaycount == "") {
                LeeJSUtils.showMessage("error", "有效天数不能为空！");
                return false;
            } else if (isNaN(validdaycount)) {
                LeeJSUtils.showMessage("error", "有效天数只能输入数字,0代表不限！");
                return false;
            } else
                return true;
        }

        //保存数据
        /*{
            "ID": "125",
            "tzid": "1900",
            "mdid": "1900",
            "ActiveName": "圣诞活动",
            "TokenName": "圣诞礼券",
            "MaxReceiveCount": "2000",
            "GetPayPoint": "1",
            "ValidTimeBegin": "2016-12-01",
            "ValidTimeEnd": "2016-12-31",
            "ValidDayCount": "1",
            "Remark": "扫码可免费获赠蛋糕 或 爆米花之一",
            "CreateCustomersID": "587",
            "CreateName": "薛灵敏"
        }*/
        function saveData() {
            if (isProcess)
                return;
            isProcess = true;
            LeeJSUtils.showMessage("loading", "正在保存..");

            var activename = $("#activename").val().trim();
            var tokenname = $("#tokenname").val().trim();
            var maxreceivecount = $("#mrcount").val().trim();
            maxreceivecount = maxreceivecount == "不限" ? "0" : maxreceivecount;
            var getpaypoint = $("#getpaypoint").val().trim();
            var starttime = $("#starttime").val();
            var endtime = $("#endtime").val();
            var validdaycount = $("#validdaycount").val().trim();
            validdaycount = validdaycount == "不限" ? "0" : validdaycount;
            var remark = $("#remark").val().trim();
            var isactive = $(".switch").attr("data-open");
            var ticketcolor = $(".tc.selected").attr("data-dm");
            if (ticketcolor == "")
                ticketcolor = "#cb6358";

            var info = { ID: tid, tzid: tzid, mdid: mdid, ActiveName: activename, TokenName: tokenname, MaxReceiveCount: maxreceivecount, GetPayPoint: getpaypoint, ValidTimeBegin: starttime, ValidTimeEnd: endtime, ValidDayCount: validdaycount, Remark: remark, CreateCustomersID: userid, CreateName: username, IsActive: isactive, GetPayPoint: getpaypoint, TicketColor: ticketcolor };
            console.log(JSON.stringify(info));
            setTimeout(function () {
                $.ajax({
                    type: "POST",
                    cache: false,
                    timeout: 10 * 1000,
                    data: { info: JSON.stringify(info) },
                    contentType: "application/x-www-form-urlencoded; charset=utf-8",
                    url: "/OA/project/storesaler/wxActiveTokenCore.ashx?ctrl=SaveTokenInfo",
                    success: function (msg) {
                        if (msg.indexOf("Error:") > -1)
                            LeeJSUtils.showMessage("error", msg.replace("Error:", ""));
                        else {
                            tid = msg.split('|')[1];
                            LeeJSUtils.showMessage("successed", "保存成功！");
                            setTimeout(function () {
                                isProcess = false;
                                window.history.go(-1);
                            }, 1500)
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        isProcess = false;
                        LeeJSUtils.showMessage("error", "您的网络出问题啦..");
                    }
                });
            }, 50);
        }

        function BindEvents() {
            $(".switch").click(function () {
                var status = $(this).attr("data-open");
                if (status == "1") {
                    $(this).attr("data-open", "0");
                    $(this).removeClass("open");
                } else {
                    $(this).attr("data-open", "1");
                    $(this).addClass("open");
                }
            });

            //保存提交
            $("#confirm").click(function () {
                if (formCheck()) {
                    saveData();
                }
            });

            $("#returnBtn").click(function () {
                window.history.go(-1);
            });

            //颜色选择
            $(".tc").click(function () {
                if ($(this).hasClass("selected"))
                    return;
                else {
                    $(".tc").removeClass("selected");
                    $(this).addClass("selected");
                    $("#index").css("background-color", $(".tc.selected").attr("data-dm"));
                }
            });

            $(".label.paypointdesc").click(function () {
                alert("什么是授权消费点数？\r\n授权消费点数用于控制每次活动最多允许兑换的礼品总数。顾客领取活动礼券时，自动获得该授权点数；\r\n每次兑换礼品都会消耗持有的点数，消费点数不够时，客人将无法领取礼品！");
            });
        }
    </script>
</body>
</html>
