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
    <script type="text/javascript" src="../../res/js/bootstrap-table.min.js" charset="utf-8"></script>
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
        html, body {
            margin: 0;
            padding: 0;
            border: 0;
        }

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

        tr td:nth-child(11) {
            word-break: keep-all; /* 不换行 */
            white-space: nowrap; /* 不换行 */
            overflow: hidden; /* 内容超出宽度时隐藏超出部分的内容 */
            text-overflow: ellipsis; /* 当对象内文本溢出时显示省略标记(...) ；需与overflow:hidden;一起使用。*/
        }

        iframe {
            margin: 0px 0px;
            width: 100%;
            height: 100%;
        }

        #dialog {
            width: 100%;
            text-align: center;
            border-radius: 5px;
            border-color: skyblue;
        }
    </style>
    <script type="text/javascript">
        var appIdVal, timestampVal, nonceStrVal, signatureVal;
        var isInit = true;
        $(function () {
            var u = window.navigator.userAgent;
            if (u.indexOf('Android') <= -1 || u.indexOf('Linux') <= -1) {
                $("#dialog").remove();
            } else {
                var modal = document.getElementById('dialog');
            }
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
            //计算顶部高度
            var tophegith = 0;
            $(".toparea").each(function () {
                tophegith += $(this).outerHeight(true);
            })
            //先销毁表格
            $("#table").bootstrapTable('destroy');
            //初始化表格,动态从服务器加载数据
            $("#table").bootstrapTable({
                method: "get",
                url: "cl_T_zjgl.ashx",
                pagination: true,
                pageSize: 20,
                pageList: [20, 40, 60, 100],
                queryParams: queryParams,//参数
                locale: 'zh-CN',
                height: $(window).height() - tophegith,
                onLoadSuccess: function () {
                    $('#dialog').css("height", $(window).height() - 2);
                },
                onClickCell: function (field, value, row, $element) {
                    if (field == 'djh') {
                        try {
                            if (u.indexOf('Android') > -1 || u.indexOf('Linux') > -1) {
                                modal.show();
                                var iframe = "<iframe src='cl_T_zjgl_mx.aspx?id=" + row.id + "' id='if' frameborder='0'></iframe>";
                                $('#if').remove()
                                $("#dialog").html(iframe);
                            } else {
                                oWebView("http://tm.lilanz.com/oa/project/ErpScan/cl_T_zjgl_mx.aspx?id=" + row.id);
                            }
                        } catch (e) {
                            alert(e.message);
                        }
                    }

                },
                columns: [
                     {
                         title: '单据号',
                         field: 'djh',
                         align: 'center',
                         valign: 'middle',
                         width: 100
                     },
                     {
                         title: '供应商名称',
                         field: 'khmc',
                         align: 'center',
                         valign: 'middle',
                         width: 250
                     },
                     {
                         title: '上传对账单个数',
                         field: 'dzdgs',
                         align: 'center',
                         valign: 'middle',
                         width: 120
                     },
                     {
                         title: '上传委托书个数',
                         field: 'wtssl',
                         align: 'center',
                         valign: 'middle',
                         width: 130
                     },
                     {
                         title: '对帐金额',
                         field: 'fkje',
                         align: 'center',
                         valign: 'middle',
                         width: 120
                     },
                     {
                         title: '供方应收',
                         field: 'skje',
                         align: 'center',
                         valign: 'middle',
                         width: 120
                     },
                     {
                         title: '对帐差额',
                         field: 'ce',
                         align: 'center',
                         valign: 'middle',
                         width: 120
                     },
                     {
                         title: '帐面余额',
                         field: 'yfye',
                         align: 'center',
                         valign: 'middle',
                         width: 120
                     },
                     {
                         title: 'K3余额',
                         field: 'k3ye',
                         align: 'center',
                         valign: 'middle',
                         width: 120
                     },
                     {
                         title: '差额',
                         field: 'k3ce',
                         align: 'center',
                         valign: 'middle',
                         width: 120
                     },
                     {
                         title: '对帐差额说明',
                         field: 'bz',
                         align: 'center',
                         valign: 'middle',
                         width: 250
                     },
                     {
                         title: '授权截止日期',
                         field: 'sqjsrq',
                         align: 'center',
                         valign: 'middle',
                         width: 120
                     },
                     {
                         title: '对帐人',
                         field: 'zdr',
                         align: 'center',
                         valign: 'middle',
                         width: 90
                     },
                     {
                         title: '对帐日期',
                         field: 'rq',
                         align: 'center',
                         valign: 'middle',
                         width: 100
                     },
                     {
                         title: 'k3日期',
                         field: 'k3zdrq',
                         align: 'center',
                         valign: 'middle',
                         width: 90
                     },
                     {
                         title: '审核人',
                         field: 'shr',
                         align: 'center',
                         valign: 'middle',
                         width: 90
                     },
                     {
                         title: '审核日期',
                         field: 'shrq',
                         align: 'center',
                         valign: 'middle',
                         width: 90
                     },
                     {
                         title: 'id',
                         field: 'id',
                         visible: false
                     },
                     {
                         title: 'wtsid',
                         field: 'wtsid',
                         visible: false
                     }
                ]
            });
            $("#refresh_button").click(function () {
                isInit = false;
                $("#table").bootstrapTable('refresh');
            });
            var currYear = (new Date()).getFullYear();
            var currMonth = (new Date()).getMonth() + 1;
            var currDay = (new Date()).getDate();
            var opt = {};
            opt.date = { preset: 'date' };
            opt.datetime = { preset: 'datetime' };
            opt.time = { preset: 'time' };
            opt.default = {
                theme: 'android-ics light', //皮肤样式
                display: 'modal', //显示方式 
                mode: 'scroller', //日期选择模式
                dateFormat: 'yy-mm-dd',
                lang: 'zh',
                showNow: true,
                nowText: "今天",
                startYear: currYear - 50, //开始年份
                endYear: currYear + 10 //结束年份
            };
            $("#ksrq").mobiscroll($.extend(opt['date'], opt['default']));
            $("#jsrq").mobiscroll($.extend(opt['date'], opt['default']));
            if (currMonth < 10) {
                currMonth = "0" + currMonth;
            }
            if (currDay < 10) {
                currDay = "0" + currDay;
            }
            $("#ksrq").val(currYear + "-" + currMonth + "-01");
            $("#jsrq").val(currYear + "-" + currMonth + "-" + currDay);
        });
        function queryParams(params) {
            var ksrq = $("#ksrq").val();
            var jsrq = $("#jsrq").val();
            var khmc = $("#khmc").val();
            var dzdfj = $("#dzdfj").val();
            var shbs = $("#shbs").val();
            var action = "search";
            return {
                "offset": params.offset,
                "limit": params.limit,
                "sort": params.sort,
                "search": params.search,
                "order": params.order,
                "ksrq": ksrq,
                "jsrq": jsrq,
                "khmc": khmc,
                "dzdfj": dzdfj,
                "shbs": shbs,
                "action": action,
                "isInit": isInit
            }
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

        //打开WebView
        function oWebView(url) {
            llApp.openWebView(url);
        }
        function close() {
            var modal = document.getElementById('dialog');
            modal.close();
        }
    </script>
</head>
<body>
    <dialog id="dialog" style="z-index: 111111111">
        <iframe src="about:blank" id="if" frameborder="0"></iframe>
    </dialog>
    <div class="row toparea">
        <div class="col-xs-4" style="margin-top: 4px; display: inline; width: 35.666667%">
            <span>开始日期:</span>
            <input class="form-control" type="text" id="ksrq" value="" />
        </div>
        <div class="col-xs-4" style="margin-top: 4px; display: inline; width: 35.666667%">
            <span>结束日期:</span>
            <input class="form-control" type="text" id="jsrq" value="" />
        </div>
        <div class="col-xs-4" style="margin-top: 4px; display: inline; width: 28.666667%">
            <span>审核:</span>
            <select class="form-control" id="shbs">
                <option value="">全部</option>
                <option value="1">已审</option>
                <option value="0">未审</option>
            </select>
        </div>
    </div>
    <div class="row toparea" style="margin-bottom: 10px">

        <div class="col-xs-4" style="margin-top: 4px; display: inline;">
            <span>对账单附件:</span>
            <select class="form-control" id="dzdfj">
                <option value="">全部</option>
                <option value="1">已上传</option>
                <option value="0">未上传</option>
            </select>
        </div>
        <div class="col-xs-5" style="margin-top: 4px; display: inline;">
            <span>供应商:</span>
            <input class="form-control" type="text" id="khmc" value="" />
        </div>
        <div class="col-xs-3" style="margin-top: 4px; display: inline;">
            <p>&nbsp</p>
            <button class="btn btn-primary" id="refresh_button">查询</button>
        </div>
    </div>
    <table id="table" class="table table-bordered" data-toggle="table"></table>
    <input type="hidden" runat="server" id="appIdVal" />
    <input type="hidden" runat="server" id="timestampVal" />
    <input type="hidden" runat="server" id="nonceStrVal" />
    <input type="hidden" runat="server" id="signatureVal" />
    <input type="hidden" runat="server" id="useridVal" />

</body>
</html>

