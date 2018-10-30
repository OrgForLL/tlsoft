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
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link rel="Stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="Stylesheet" href="../../res/css/ErpScan/bootstrap.css" />
    <link rel="Stylesheet" href="../../res/css/font-awesome.min.css" />
    <link rel="Stylesheet" href="../../res/css/bootstrap-table.min.css" />
    <link href="../../res/css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .fixed-table-pagination .pagination-info {
            display: none;
        }

        .row {
            margin: 2px;
        }

            .row span:nth-child(1) {
                font-weight: 800;
            }

        p {
            margin: 0 0 0px;
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

            var khid = getUrlParam("khid");
            var htid = getUrlParam("htid");
            var jsid = getUrlParam("jsid");
            var khmc = getUrlParam("khmc");
            var ddbh = getUrlParam("ddbh");
            var ddsl = getUrlParam("ddsl");
            var rksl = getUrlParam("rksl");
            var currYear = (new Date()).getFullYear();
            var currMonth = (new Date()).getMonth() + 1;
            var currDay = (new Date()).getDate();
            if (currMonth < 10) {
                currMonth = "0" + currMonth;
            }
            if (currDay < 10) {
                currDay = "0" + currDay;
            }
            $("#jsrq").html(currYear + "-" + currMonth + "-" + currDay);

            if (khmc != null) {
                $("#khmc").html(decodeURI(khmc));
            }
            if (ddbh != null) {
                $("#ddbh").html(ddbh);
            }
            if (ddsl != null) {
                $("#ddsl").html(ddsl);
            }
            if (rksl != null) {
                $("#rksl").html(rksl);
            }
            //计算顶部高度
            var tophegith = 0;
            $(".toparea").each(function () {
                tophegith += $(this).outerHeight(true);
            })
            if (khid != null && htid != null) {
                //先销毁表格
                $('#table').bootstrapTable('destroy');
                //初始化表格,动态从服务器加载数据
                $("#table").bootstrapTable({
                    method: "get",
                    url: "cl_T_cbsh.ashx",
                    queryParams: queryParams,//参数
                    locale: 'zh-CN',
                    showFooter: true,
                    height: $(window).height() - tophegith - 15,
                    responseHandler: function (res) {
                        $("#skje").html(res.zb[0].skje);
                        $("#bz").html(res.zb[0].bz);
                        if (res.zb[0].shbs == 1) {
                            $("#sh").attr('disabled', true)
                            $("#sh").val("已审");
                        }
                        return res.mx;
                    },
                    columns: [
                        [
                         {
                             title: '材料编码<br>配料单耗',
                             field: 'chdm',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                             falign: "center"

                         },
                         {
                             title: '材料名称<br>合同订单',
                             field: 'chmc',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                         },
                         {
                             title: '入库数<br>A',
                             field: 'rksl',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                         },
                         {
                             title: '计划用量<br>B',
                             field: 'dhsl',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                             footerFormatter: function (value) {
                                 var count = 0;
                                 for (var i in value) {
                                     count += value[i].dhsl;
                                 }
                                 return count.toFixed(3);
                             }
                         },
                         {
                             title: '补耗量<br>C',
                             field: 'bhsl',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                             footerFormatter: function (value) {
                                 var count = 0;
                                 for (var i in value) {
                                     count += value[i].bhsl;
                                 }
                                 return count;
                             }
                         },
                         {
                             title: '损耗率<br>D',
                             field: 'shbl',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                             footerFormatter: function (value) {
                                 var count = 0;
                                 for (var i in value) {
                                     count += value[i].shbl;
                                 }
                                 return count;
                             }
                         },
                         {
                             title: '计划合计量<br>E=(B+C)*D',
                             field: 'dhzsl',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                             footerFormatter: function (value) {
                                 var count = 0;
                                 for (var i in value) {
                                     count += value[i].dhzsl;
                                 }
                                 return count;
                             }
                         },
                         {
                             title: '合计<br>H=G-F',
                             field: 'hj',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                             footerFormatter: function (value) {
                                 var count = 0;
                                 for (var i in value) {
                                     count += value[i].hj;
                                 }
                                 return count;
                             }
                         },
                         {
                             title: '超耗料量<br>I=G-E-F',
                             field: 'chsl',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                             footerFormatter: function (value) {
                                 var count = 0;
                                 for (var i in value) {
                                     count += value[i].chsl;
                                 }
                                 return count;
                             }
                         },
                         {
                             title: '单价<br>J',
                             field: 'dj',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                         },
                         {
                             title: '采购费<br>K',
                             field: 'cgje',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                         },
                         {
                             title: '财务单价<br>L',
                             field: 'cwdj',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                         },
                         {
                             title: '扣款金额<br>M=L*I',
                             field: 'kkje',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                             footerFormatter: function (value) {
                                 var count = 0;
                                 for (var i in value) {
                                     count += value[i].kkje;
                                 }
                                 return count;
                             }
                         },
                         {
                             title: '节约金额<br>N=(B-G)*J',
                             field: 'jyje',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                         },
                         {
                             title: '备注',
                             field: 'bz',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                         },
                         {
                             title: '来源',
                             field: 'sjlxmc',
                             align: 'center',
                             valign: 'middle',
                             rowspan: "2",
                         },
                         {
                             title: '实发料量',
                             field: 'sfll',
                             align: 'center',
                             valign: 'middle',
                             colspan: "3",
                         },
                        ], [
                         {
                             title: '产前样<br>F',
                             field: 'cqsl',
                             align: 'center',
                             valign: 'middle',
                         },
                         {
                             title: '大货领用<br>G',
                             field: 'lysl',
                             align: 'center',
                             valign: 'middle',
                             footerFormatter: function (value) {
                                 var count = 0;
                                 for (var i in value) {
                                     count += value[i].lysl;
                                 }
                                 return count;
                             }
                         },
                         {
                             title: '报废量<br>BF',
                             field: 'bfsl',
                             align: 'center',
                             valign: 'middle',
                             footerFormatter: function (value) {
                                 var count = 0;
                                 for (var i in value) {
                                     count += value[i].bfsl;
                                 }
                                 return count;
                             }
                         }
                        ]
                    ]
                });
                var u = window.navigator.userAgent;
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
                $("#sh").click(function () {
                    $("#spinner").show();
                    $("#bg").show();
                    if (confirm("确定要审核吗")) {
                        $.ajax({
                            type: "POST",
                            timeout: 1000,
                            async: false,
                            contentType: "application/x-www-form-urlencoded; charset=utf-8",
                            url: "cl_T_cbsh.ashx",
                            data: { action: "sh", jsid: jsid, userid: $("#useridVal").val() },
                            success: function (msg) {
                                if (msg.type == "SUCCESS") {
                                    $("#bg").hide();
                                    $("#spinner").hide();
                                    alert("审核成功");
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
            }
        });
        function queryParams(params) {
            var action = "mx";
            var khid = getUrlParam("khid");
            var htid = getUrlParam("htid");
            var jsid = getUrlParam("jsid");
            console.info({
                "offset": params.offset,
                "limit": params.limit,
                "sort": params.sort,
                "search": params.search,
                "order": params.order,
                "khid": khid,
                "htid": htid,
                "jsid": jsid,
                "action": action
            });
            return {
                "offset": params.offset,
                "limit": params.limit,
                "sort": params.sort,
                "search": params.search,
                "order": params.order,
                "khid": khid,
                "htid": htid,
                "jsid": jsid,
                "action": action
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
        function getUrlParam(name) {
            try {
                var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
                var r = window.location.search.substr(1).match(reg);  //匹配目标参数
                if (r != null) return decodeURI(r[2]); return null; //返回参数值
            } catch (e) {
                alert(e.message)
            }
        }
    </script>
</head>
<body>
    <div class="row toparea">
        <div class="col-xs-8" style="margin-top: 4px; display: inline;">
            <span>加工厂:</span>
            <span id="khmc"></span>
        </div>
        <div class="col-xs-4" style="display: inline; float: right">
            <button class="btn btn-primary" id="sh">审核</button>
        </div>
    </div>
    <div class="row toparea">
        <div class="col-xs-6" style="margin-top: 4px;">
            <span>合同订单:</span><br />
            <span id="ddbh"></span>
        </div>
        <div class="col-xs-6" style="margin-top: 4px;">
            <span>结算日期:</span><br />
            <span id="jsrq"></span>
        </div>
    </div>
    <div class="row toparea">
        <div class="col-xs-4" style="margin-top: 4px; display: inline;">
            <span>实扣金额:</span>
            <span id="skje"></span>
        </div>
        <div class="col-xs-4" style="margin-top: 4px; display: inline; float: right;">
            <span>下单数量:</span>
            <span id="ddsl"></span>
        </div>
        <div class="col-xs-4" style="margin-top: 4px; display: inline; float: right;">
            <span>入库数量:</span>
            <span id="rksl"></span>
        </div>
    </div>
    <div class="row toparea" style="margin-bottom: 10px">
        <div class="col-xs-12" style="margin-top: 4px; display: inline;">
            <span>备注:</span>
            <span id="bz"></span>
        </div>
    </div>
    <table id="table" class="table table-bordered" data-toggle="table"></table>
    <div id="bg" style="display: none"></div>
    <div class="spinner" id="spinner" style="display: none">
        <div class="rect1"></div>
        <div class="rect2"></div>
        <div class="rect3"></div>
        <div class="rect4"></div>
        <div class="rect5"></div>
    </div>
    <input type="hidden" runat="server" id="appIdVal" />
    <input type="hidden" runat="server" id="timestampVal" />
    <input type="hidden" runat="server" id="nonceStrVal" />
    <input type="hidden" runat="server" id="signatureVal" />
    <input type="hidden" runat="server" id="useridVal" />
</body>
</html>

