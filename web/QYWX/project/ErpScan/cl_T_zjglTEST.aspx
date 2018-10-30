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
            height:100%;
        }

        #dialog {
            padding: 0;
            width:100%;
            padding:5px;
            text-align: center;
            vertical-align: middle;
            border-radius: 5px;
            border-color:skyblue;
        }
    </style>
    <script type="text/javascript">
        var appIdVal, timestampVal, nonceStrVal, signatureVal;
        var isInit = true;
        var height = 0;
        $(function () {
            var modal = document.getElementById('dialog');
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
            //先销毁表格
            $("#table").bootstrapTable('destroy');
            //初始化表格,动态从服务器加载数据
          
          
        });
   

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
            scroll(0, height);
        }
    </script>
</head>
<body>
    <dialog id="dialog" style="z-index: 111111111">
        <iframe src="about:blank" id="if" frameborder="0"></iframe>
    </dialog>
    <div class="row">
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
    <div class="row" style="margin-bottom: 10px">

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

