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
                 font-size:10px;
            }

        .form-control {
            font-size:10px;
            height:30px;
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

        iframe {
            margin: 0px 0px;
            width: 100%;
            height: 100%;
        }

        #dialog {
            padding: 0;
            width: 100%;
            padding: 5px;
            text-align: center;
            vertical-align: middle;
            border-radius: 5px;
            border-color: skyblue;
        }
    </style>
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        var appIdVal, timestampVal, nonceStrVal, signatureVal;
        var isInit = true;
        $(function () {
            var u = window.navigator.userAgent;
            var modal = document.getElementById('dialog');
            if (u.indexOf('Android') <= -1 || u.indexOf('Linux') <= -1) {
                //$("#dialog").remove();
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
                url: "cl_T_cbsh.ashx",
                pagination: true,
                pageSize: 20,
                pageList: [20, 40, 60, 100],
                queryParams: queryParams,//参数
                locale: 'zh-CN',
                height: $(window).height() - tophegith-15,
                onLoadSuccess: function () {
                    $('#dialog').css("height", $(window).height());
                },
                onClickCell: function (field, value, row, $element) {
                    if (field == 'sh') {
                        try {
                            modal.show();
                            var iframe = "<iframe src='cl_T_cbsh_mx.aspx?khid=" + row.khid + "&htid=" + row.htid + "&jsid=" + row.jsid + "&khmc=" + encodeURI(row.khmc) + "&ddbh=" + row.ddbh + "&ddsl=" + row.ddsl + "&rksl=" + row.rksl + "' id='if' frameborder='0'></iframe>";
                            $('#if').remove()
                            $("#dialog").html(iframe);
                            if (u.indexOf('Android') > -1 || u.indexOf('Linux') > -1) {
                                modal.show();
                                var iframe = "<iframe src='cl_T_cbsh_mx.aspx?khid=" + row.khid + "&htid=" + row.htid + "&jsid=" + row.jsid + "&khmc=" + encodeURI(row.khmc) + "&ddbh=" + row.ddbh + "&ddsl=" + row.ddsl + "&rksl=" + row.rksl + "' id='if' frameborder='0'></iframe>";
                                $('#if').remove()
                                $("#dialog").html(iframe);
                            } else {
                                oWebView("http://tm.lilanz.com/oa/project/ErpScan/cl_T_cbsh_mx.aspx?khid=" + row.khid + "&htid=" + row.htid + "&jsid=" + row.jsid + "&khmc=" + encodeURI(row.khmc) + "&ddbh=" + row.ddbh + "&ddsl=" + row.ddsl + "&rksl=" + row.rksl);
                            }
                        } catch (e) {
                            alert(e.message);
                        }
                    }
                },
                columns: [
                     {
                         title: '审核',
                         field: 'sh',
                         align: 'center',
                         valign: 'middle',
                         width: 60

                     },
                     {
                         title: '日期',
                         field: 'rq',
                         align: 'center',
                         valign: 'middle',
                         width: 100
                     },
                     {
                         title: '附件数',
                         field: 'fjs',
                         align: 'center',
                         valign: 'middle',
                         width: 60
                     },
                     {
                         title: '单据号',
                         field: 'djh',
                         align: 'center',
                         valign: 'middle',
                         width: 60
                     },
                     {
                         title: '合同订单',
                         field: 'ddbh',
                         align: 'center',
                         valign: 'middle',
                         width: 100
                     },
                     {
                         title: '供货商名称',
                         field: 'khmc',
                         align: 'center',
                         valign: 'middle',
                         width: 200
                     },
                     {
                         title: '订单数量',
                         field: 'ddsl',
                         align: 'center',
                         valign: 'middle',
                         width: 80
                     },
                     {
                         title: '入库数量',
                         field: 'rksl',
                         align: 'center',
                         valign: 'middle',
                         width: 80
                     },
                     {
                         title: '应扣金额',
                         field: 'kkje',
                         align: 'center',
                         valign: 'middle',
                         width: 80
                     },
                     {
                         title: '实扣金额',
                         field: 'skje',
                         align: 'center',
                         valign: 'middle',
                         width: 80
                     },
                     {
                         title: '节约金额',
                         field: 'jyje',
                         align: 'center',
                         valign: 'middle',
                         width: 80
                     },
                     {
                         title: '制单人',
                         field: 'zdr',
                         align: 'center',
                         valign: 'middle',
                         width: 70
                     },
                     {
                         title: '审核状态',
                         field: 'shzt',
                         align: 'center',
                         valign: 'middle',
                         width: 80
                     },
                     {
                         title: '审核日期',
                         field: 'shrq',
                         align: 'center',
                         valign: 'middle',
                         width: 90
                     },
                     {
                         title: '审核人',
                         field: 'shr',
                         align: 'center',
                         valign: 'middle',
                         width: 70
                     },
                     {
                         title: '应付款查询',
                         field: 'yfkcx',
                         align: 'center',
                         valign: 'middle',
                         width: 90
                     },
                     {
                         title: 'jsid',
                         field: 'jsid',
                         visible: false
                     }
                ]
            });
            $("#refresh_button").click(function () {
                isInit = false;
                $('#table').bootstrapTable('refresh');
            });
            $.ajax({
                type: "get",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "cl_T_cbsh.ashx?action=cpjj",
                success: function (msg) {
                    for (var i = 0; i < msg.length; i++) {
                        var option = document.createElement("option");
                        $(option).val(msg[i].dm);
                        $(option).text(msg[i].mc);
                        $('#cpjj').append(option);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("result: 'netError', textStatus: " + textStatus + ", status: " + XMLHttpRequest.status);
                }
            });
        });
        function queryParams(params) {
            var cpjj = $("#cpjj").val();
            var htlx = $("#htlx").val();
            var khmc = $("#khmc").val();
            var ddbh = $("#ddbh").val();
            var shbs = $("#shbs").val();
            var sphh = $("#sphh").val();
            var fjs = $("#fjs").val();
            var action = "search";
            console.info({
                "offset": params.offset,
                "limit": params.limit,
                "sort": params.sort,
                "search": params.search,
                "order": params.order,
                "cpjj": cpjj,
                "htlx": htlx,
                "khmc": khmc,
                "ddbh": ddbh,
                "shbs": shbs,
                "sphh": sphh,
                "fjs": fjs,
                "action": action
            });
            return {
                "offset": params.offset,
                "limit": params.limit,
                "sort": params.sort,
                "search": params.search,
                "order": params.order,
                "cpjj": cpjj,
                "htlx": htlx,
                "khmc": khmc,
                "ddbh": ddbh,
                "shbs": shbs,
                "sphh": sphh,
                "fjs": fjs,
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
        <div class="col-xs-6" style="margin-top: 4px; display: inline;">
            <span>产品季度:</span>
            <select class="form-control" id="cpjj">
            </select>
        </div>
        <div class="col-xs-6" style="margin-top: 4px; display: inline; float: right;">
            <span>合同类型:</span>
            <select class="form-control" id="htlx">
                <option value="">全部</option>
                <option value="981">加工合同</option>
                <option value="982">贴牌合同</option>
            </select>
        </div>

    </div>

    <div class="row toparea">
        <div class="col-xs-6" style=" display: inline; float: right;">
            <span>审核状态:</span>
            <select class="form-control" id="shbs">
                <option value="0">未审核</option>
                <option value="1">已审核</option>
            </select>
        </div>
        <div class="col-xs-6" style=" display: inline;">
            <span>附件数:</span>
            <select class="form-control" id="fjs">
                <option value="0">全部</option>
                <option value="1">有附件</option>
                <option value="2">无附件</option>
            </select>
        </div>
    </div>


    <div class="row toparea">
        <div class="col-xs-6" style=" display: inline;">
            <span>供货商名称:</span>
            <input class="form-control" type="text" id="khmc" value="" />
        </div>
        <div class="col-xs-6" style=" display: inline; float: right;">
            <span>合同订单:</span>
            <input class="form-control" type="text" id="ddbh" value="" />
        </div>
    </div>
    <div class="row toparea" style="margin-bottom: 10px">
        <div class="col-xs-6" style=" display: inline;">
            <span>商品货号:</span>
            <input class="form-control" type="text" id="sphh" value="" />
        </div>

        <div class="col-xs-6" style=" display: inline; float: right">
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

