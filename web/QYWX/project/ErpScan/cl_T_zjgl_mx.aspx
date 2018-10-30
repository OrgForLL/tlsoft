<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>
<!DOCTYPE html>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string OAConnStr = clsConfig.GetConfigValue("OAConnStr");
        string url = Request.Url.ToString().ToLower();//转为小写,indexOf 和Replace 对大小写都是敏感的   
        string SystemKey = "";
        string ctrl = Convert.ToString(Request.Params["ctrl"]);
        if (ctrl == "" || ctrl == null)
        {

            if (Request.Url.AbsoluteUri.IndexOf("192.168.35.231") == -1)
            {
                if (clsWXHelper.CheckQYUserAuth(true))
                {
                    //鉴权成功之后，获取 系统身份SystemKey
                    string SystemID = "1";
                    SystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
                }
            }
            WxHelper cs = new WxHelper();
            List<string> config = clsWXHelper.GetJsApiConfig("1");
            appIdVal.Value = config[0];
            timestampVal.Value = config[1];
            nonceStrVal.Value = config[2];
            signatureVal.Value = config[3];
            useridVal.Value = SystemKey;
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=yes" />
    <title></title>

    <script type="text/javascript" src="../../res/js/jquery-3.2.1.min.js"></script>
    <script type="text/javascript" src="../../res/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../res/js/bootstrap-table.min.js"></script>
    <script type="text/javascript" src="../../res/js/bootstrap-table-locale-all.js" charset="utf-8"></script>
    <script type="text/javascript" src="../../res/js/mobiscroll_date.js"></script>
    <script type="text/javascript" src="../../res/js/mobiscroll.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link rel="Stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="Stylesheet" href="../../res/css/ErpScan/bootstrap.css" />
    <link rel="Stylesheet" href="../../res/css/font-awesome.min.css" />
    <link rel="Stylesheet" href="../../res/css/bootstrap-table.min.css" />
    <link rel="Stylesheet" href="../../res/css/mobiscroll.css" />
    <link rel="Stylesheet" href="../../res/css/mobiscroll_date.css" />
    <link href="../../res/css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .fixed-table-pagination .pagination-info {
            display: none;
        }

        .row {
            margin: 2px;
        }

            .row span {
                font-weight: 800;
            }

        p {
            margin: 0 0 0px;
        }

        .table {
            table-layout: fixed;
        }

        tr td:nth-child(1) {
            color: skyblue;
        }

        tr td:nth-child(12) {
            word-break: keep-all; /* 不换行 */
            white-space: nowrap; /* 不换行 */
            overflow: hidden; /* 内容超出宽度时隐藏超出部分的内容 */
            text-overflow: ellipsis; /* 当对象内文本溢出时显示省略标记(...) ；需与overflow:hidden;一起使用。*/
        }

        .spinner {
            margin: auto;
            width: 20%;
            height: 11%;
            position: absolute;
            z-index: 100000;
            top: 50%;
            left: 50%;
            transform: translate(-50%,-50%);
        }

            .spinner > div {
                margin: auto;
                background-color: deepskyblue;
                height: 100%;
                width: 9px;
                display: inline-block;
                -webkit-animation: stretchdelay 1.2s infinite ease-in-out;
                animation: stretchdelay 1.2s infinite ease-in-out;
            }

            .spinner .rect2 {
                margin: auto;
                -webkit-animation-delay: -1.1s;
                animation-delay: -1.1s;
            }

            .spinner .rect3 {
                margin: auto;
                -webkit-animation-delay: -1.0s;
                animation-delay: -1.0s;
            }

            .spinner .rect4 {
                margin: auto;
                -webkit-animation-delay: -0.9s;
                animation-delay: -0.9s;
            }

            .spinner .rect5 {
                margin: auto;
                -webkit-animation-delay: -0.8s;
                animation-delay: -0.8s;
            }

        #bg {
            width: 100%;
            height: 100%;
            top: 0%;
            right: 0%;
            position: absolute;
            background-color: black;
            opacity: 0.2;
            z-index: 1000000;
        }

        @-webkit-keyframes stretchdelay {
            0%, 40%, 100% {
                -webkit-transform: scaleY(0.4);
            }

            20% {
                -webkit-transform: scaleY(1.0);
            }
        }

        @keyframes stretchdelay {
            0%, 40%, 100% {
                transform: scaleY(0.4);
                -webkit-transform: scaleY(0.4);
            }

            20% {
                transform: scaleY(1.0);
                -webkit-transform: scaleY(1.0);
            }
        }
    </style>
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        var appIdVal, timestampVal, nonceStrVal, signatureVal;
        $(function () {
            appIdVal = document.getElementById("appIdVal").value;
            timestampVal = document.getElementById("timestampVal").value;
            nonceStrVal = document.getElementById("nonceStrVal").value;
            signatureVal = document.getElementById("signatureVal").value;
            if (document.getElementById("useridVal").value == "" || document.getElementById("useridVal").value == "0") {
                //用户不可用                
                if (window.document.URL.indexOf("192.168.35.231") < 0) {
                    alert("鉴权不成功");
                    document.getElementById("ctrlScan1").style.display = "none";
                    document.getElementById("ctrlScan2").style.display = "none";
                    document.getElementById("uploader").style.display = "none";
                    document.getElementById("save").style.display = "none";
                }

            } else {
                llApp.init();
                jsConfig();
            }
            var id = getUrlParam("id");

            search(id);
            var u = window.navigator.userAgent;
            var i = 0;
            if (u.indexOf('Android') > -1 || u.indexOf('Linux') > -1) {
                var i = 0;
                $("body").click(function () {
                    i++;
                    setTimeout(function () {
                        i = 0;
                    }, 200);
                    if (i > 1) {
                        window.parent.close();
                        i = 0;
                    }
                });
            }
            $.each($("textarea"), function (i, n) {
                $(n).css("height", n.scrollHeight + "px");
            })
            if ($(window).height() < $(document.body).outerHeight()) {
                $("#bg").css("height", $(document.body).outerHeight() + 5);
            } else {
                $("#bg").css("height", $(window).height() + 5);
            }
            $("#sh").click(function () {
                $("#spinner").show();
                $("#bg").show();
                if (confirm("确定要审核吗")) {
                    $.ajax({
                        type: "POST",
                        timeout: 1000,
                        async: false,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        url: "cl_T_zjgl.ashx",
                        data: { action: "sh", id: id, userid: $("#useridVal").val() },
                        success: function (msg) {
                            if (msg.type == "SUCCESS") {
                                $("#bg").hide();
                                $("#spinner").hide();
                                alert("审核成功！");
                                if (u.indexOf('Android') > -1 || u.indexOf('Linux') > -1) {
                                    window.parent.close();
                                } else {
                                    window.close();
                                }
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            $("#bg").hide();
                            $("#spinner").hide();
                            alert("result: 'netError', textStatus: " + textStatus + ", status: " + XMLHttpRequest.status);
                        }
                    });
                }
            });
            $("#save").click(function () {
                if ($("#zdrid").val() != $("#useridVal").val()) { alert("非对账人不能修改"); return; }
                var a = IsDate($("#jsrq").val());
                var b = IsDate($("#ksrq").val());
                var c = IsDate($("#rq").val());
                if (!a || !b || !c) {
                    alert("日期格式有误");
                    return;
                }
                var data = {
                    action: "upd",
                    id: id,
                    userid: $("#useridVal").val(),
                    ksrq: $("#ksrq").val(),
                    jsrq: $("#jsrq").val(),
                    skje: $("#skje").val(),
                    fkje: $("#fkje").val(),
                    khid: $("#khid").val(),
                    bz: $("#bz").val(),
                    nbbz: $("#nbbz").val(),
                    rq: $("#rq").val(),
                    yfye: $("#yfye").val(),
                    email: $("#email").val(),
                    dh: $("#dh").val(),
                    cz: $("#cz").val(),
                    tmje: $("#tmje").val(),
                }
                if (confirm("确定要修改吗")) {
                    $.ajax({
                        type: "POST",
                        timeout: 1000,
                        async: false,
                        contentType: "application/x-www-form-urlencoded; charset=utf-8",
                        url: "cl_T_zjgl.ashx",
                        data: data,
                        success: function (msg) {
                            console.log(msg);
                            if (msg.type == "SUCCESS") {
                                alert("修改成功！");
                                $("#ce").val($("#fkje").val() - $("#skje").val());
                            } else {
                                alert(msg.msg);
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            alert("result: 'netError', textStatus: " + textStatus + ", status: " + XMLHttpRequest.status);
                        }
                    });
                }
            });
        });
        function search(id) {
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "cl_T_zjgl.ashx",
                data: { action: "mx", id: id, userid: $("#useridVal").val() },
                success: function (msg) {
                    $("#bz").val(msg[0].bz);
                    $("#ce").val(msg[0].ce);
                    $("#cz").val(msg[0].cz);
                    $("#dh").val(msg[0].dh);
                    $("#djh").val(msg[0].djh);
                    $("#dzdsc").val(msg[0].dzdsc);
                    $("#email").val(msg[0].email);
                    $("#fkje").val(msg[0].fkje);
                    $("#jsrq").val(msg[0].jsrq);
                    $("#k3ye").val(msg[0].k3ye);
                    $("#khmc").val(msg[0].khmc);
                    $("#ksrq").val(msg[0].ksrq);
                    $("#nbbz").val(msg[0].nbbz);
                    $("#rq").val(msg[0].rq);
                    $("#shbs").val(msg[0].shbs);
                    $("#showI").val(msg[0].showI);
                    $("#shr").val(msg[0].shr);
                    $("#skje").val(msg[0].skje);
                    $("#tmje").val(msg[0].tmje);
                    $("#xgbs").val(msg[0].xgbs);
                    $("#yfye").val(msg[0].yfye);
                    $("#zdr").val(msg[0].zdr);
                    $("#zdrid").val(msg[0].zdrid);
                    $("#khid").val(msg[0].khid);
                    if (msg[0].shbs == "已审") {
                        $("#sh").attr('disabled', true)
                        $("#save").attr('disabled', true)
                        $("#khmc").attr("readonly", "readonly");
                        $("#email").attr("readonly", "readonly");
                        $("#fkje").attr("readonly", "readonly");
                        $("#dh").attr("readonly", "readonly");
                        $("#skje").attr("readonly", "readonly");
                        $("#cz").attr("readonly", "readonly");
                        $("#ksrq").attr("readonly", "readonly");
                        $("#jsrq").attr("readonly", "readonly");
                        $("#rq").attr("readonly", "readonly");
                        $("#bz").attr("readonly", "readonly");
                        $("#nbbz").attr("readonly", "readonly");
                        $("#sh").html("已审");
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $("#bg").hide();
                    $("#spinner").hide();
                    alert("result: 'netError', textStatus: " + textStatus + ", status: " + XMLHttpRequest.status);
                }
            });
        }
        /********************签名**********************/
        function jsConfig() {
            wx.config({
                debug: false,
                appId: appIdVal, // 必填，公众号的唯一标识
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ['scanQRCode'] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                //alert("ready");
                //scan();
            });
            wx.error(function (res) {
                alert(allPrpos(res));
                alert("JS注入失败！");
            });
        }
        function getUrlParam(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
            var r = window.location.search.substr(1).match(reg);  //匹配目标参数
            if (r != null) return unescape(r[2]); return null; //返回参数值
        }
        function IsDate(dateValue) {
            var regex = new RegExp("^(?:(?:([0-9]{4}(-|\/)(?:(?:0?[1,3-9]|1[0-2])(-|\/)(?:29|30)|((?:0?[13578]|1[02])(-|\/)31)))|([0-9]{4}(-|\/)(?:0?[1-9]|1[0-2])(-|\/)(?:0?[1-9]|1\\d|2[0-8]))|(((?:(\\d\\d(?:0[48]|[2468][048]|[13579][26]))|(?:0[48]00|[2468][048]00|[13579][26]00))(-|\/)0?2(-|\/)29))))$");
            if (!regex.test(dateValue)) {
                return false;
            } else {
                return true;
            }
        }
    </script>
</head>
<body>
    <div class="row">
        <div class="col-xs-7" style="margin-top: 4px;">
            <span>收款公司:</span>
            <input class="form-control" type="text" id="khmc" value="" />
        </div>
        <div class="col-xs-5" style="margin-top: 4px;">
            <span>帐面余额:</span>
            <input class="form-control" type="text" id="yfye" value="" readonly="readonly" />
        </div>
    </div>
    <div class="row">
        <div class="col-xs-7" style="margin-top: 4px;">
            <span>Email:</span>
            <input class="form-control" type="text" id="email" value="" />
        </div>
        <div class="col-xs-5" style="margin-top: 4px;">
            <span>对帐金额:</span>
            <input class="form-control" type="text" id="fkje" value="" />
        </div>
    </div>
    <div class="row">
        <div class="col-xs-7" style="margin-top: 4px;">
            <span>电话:</span>
            <input class="form-control" type="text" id="dh" value="" />
        </div>
        <div class="col-xs-5" style="margin-top: 4px;">
            <span>供方应收:</span>
            <input class="form-control" type="text" id="skje" value="" />
        </div>
    </div>
    <div class="row">
        <div class="col-xs-8" style="margin-top: 4px;">
            <span>传真:</span>
            <input class="form-control" type="text" id="cz" value="" />
        </div>
        <div class="col-xs-4" style="margin-top: 4px;">
            <span>对帐差额:</span>
            <input class="form-control" type="text" id="ce" value="" readonly="readonly" />
        </div>

    </div>
    <div class="row">
        <div class="col-xs-6" style="margin-top: 4px;">
            <span>开始日期:</span>
            <input class="form-control" type="text" id="ksrq" value="" />
        </div>
        <div class="col-xs-6" style="margin-top: 4px;">
            <span>结束日期:</span>
            <input class="form-control" type="text" id="jsrq" value="" />
        </div>
    </div>
    <div class="row">
        <div class="col-xs-6" style="margin-top: 4px;">
            <span>对帐日期:</span>
            <input class="form-control" type="text" id="rq" value="" />
        </div>
        <div class="col-xs-4" style="margin-top: 4px;">
            <span>审核状态:</span>
            <input class="form-control" type="text" id="shbs" value="" readonly="readonly" />
        </div>
    </div>

    <div class="row">
        <div class="col-xs-12" style="margin-top: 4px;">
            <span>对帐说明:</span>
            <textarea class="form-control" id="bz" style="min-height: 100%"></textarea>
        </div>
    </div>
    <div class="row">
        <div class="col-xs-12" style="margin-top: 4px;">
            <span>内部说明:</span>
            <textarea class="form-control" id="nbbz" style=""></textarea>
        </div>
    </div>
    <div class="row">
        <div class="col-xs-4" style="margin-top: 4px;">
            <span>对帐人:</span>
            <input class="form-control" type="text" id="zdr" value="" readonly="readonly" />
        </div>
        <div class="col-xs-3" style="margin-top: 4px; float: right">
            <p>&nbsp</p>
            <button class="btn btn-primary" id="save" style="margin: 0 auto">修改</button>
        </div>
        <div class="col-xs-3" style="margin-top: 4px; float: right">
            <p>&nbsp</p>
            <button class="btn btn-primary" id="sh" style="margin: 0 auto">审核</button>
        </div>
    </div>
    <div id="bg" style="display: none"></div>
    <div class="spinner" id="spinner" style="display: none">
        <div class="rect1"></div>
        <div class="rect2"></div>
        <div class="rect3"></div>
        <div class="rect4"></div>
        <div class="rect5"></div>
    </div>
    <input type="hidden" id="tmje" />
    <input type="hidden" id="khid" />
    <input type="hidden" id="zdrid" />

    <input type="hidden" runat="server" id="appIdVal" />
    <input type="hidden" runat="server" id="timestampVal" />
    <input type="hidden" runat="server" id="nonceStrVal" />
    <input type="hidden" runat="server" id="signatureVal" />
    <input type="hidden" runat="server" id="useridVal" />
</body>
</html>

