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

            if (clsWXHelper.CheckQYUserAuth(true))
            {
                //鉴权成功之后，获取 系统身份SystemKey
                string SystemID = "1";
                SystemKey = clsWXHelper.GetAuthorizedKey(Convert.ToInt32(SystemID));
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
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../api/lilanzAppWVJBridge.js"></script>
    <script type="text/javascript" src="http://res.wx.qq.com/open/js/jweixin-1.0.0.js"></script>
    <link rel="Stylesheet" href="../../res/css/LeePageSlider.css" />
    <link rel="Stylesheet" href="../../res/css/ErpScan/bootstrap.css" />
    <link rel="Stylesheet" href="../../res/css/font-awesome.min.css" />
    <link href="../../res/css/sweet-alert.css" rel="stylesheet" type="text/css" />
    <script src="../../res/js/sweet-alert.min.js" type="text/javascript"></script>
    <style type="text/css">
        body {
            font-size: 14px;
            line-height: 20px;
        }
    </style>
    <script type="text/javascript">
        var appIdVal, timestampVal, nonceStrVal, signatureVal;
        $(document).ready(function () {
            $("#bg").hide();
            $("#spinner").hide();
            //WeiXin JSSDK
            appIdVal = document.getElementById("appIdVal").value;
            timestampVal = document.getElementById("timestampVal").value;
            nonceStrVal = document.getElementById("nonceStrVal").value;
            signatureVal = document.getElementById("signatureVal").value;
            //alert(appIdVal);   

            if (document.getElementById("useridVal").value == "" || document.getElementById("useridVal").value == "0") {
                //用户不可用
                alert("鉴权不成功");
                document.getElementById("ctrlScan").style.display = "none";
                document.getElementById("search").style.display = "none";                
            } else {                  
                llApp.init();
                jsConfig();
            }  
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

        function scan() {
            //isInApp = false;
            if (isInApp) {
                llApp.scanQRCode(function (result) {
                    goScan(result);
                });
            } else {
                wx.scanQRCode({
                    desc: 'scanQRCode desc',
                    needResult: 1, // 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
                    scanType: ["qrCode", "barCode"], // 可以指定扫二维码还是一维码，默认二者都有
                    success: function (res) {
                        if (res.resultStr.split(",").length > 1) {
                            goScan(res.resultStr.split(",")[1]); // 当needResult 为 1 时，扫码返回的结果 
                        } else {
                            goScan(res.resultStr); // 当needResult 为 1 时，扫码返回的结果 
                        }
                    }
                });
            }
        };

        function search() {
            if ($("#msg").val() == "") {
                swal({
                    title: "提示信息",
                    text: "没有输入任何标签",
                    type: "error",
                }, function () {

                });
            } else {
                goScan($("#msg").val())
            }
        }

        function goScan(result) {
            
            var checkInfo = getBQInfo(result);
            if (checkInfo.result == "Successed") {
                var data = JSON.parse(checkInfo.data);
                getInfoList(data);
                addLog(data, checkInfo.data, result);
                $("#msg").val('');
            } else if (checkInfo.result == "Error") {
                swal({
                    title: "提示信息",
                    text: "信息查询错误",
                    type: "error",
                }, function () {
                    scan();
                });
            } else if (checkInfo.result == "netError") {
                swal({
                    title: "提示信息",
                    text: "网络错误" + checkInfo.textStatus + ",status:" + checkInfo.status,
                    type: "error",
                }, function () {
                    scan();
                });
            } else if (checkInfo.result == "NoRows") {
                swal({
                    title: "提示信息",
                    text: "查无数据,请检查当前用户是否有权限",
                    type: "error",
                }, function () {
                    scan();
                });
            }
        }


        //获取条码对应信息
        function getBQInfo(msg) {
            $("#bg").show();
            $("#spinner").show();
            var chdm = msg;
            var data = null;
            $.ajax({
                type: "POST",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "cl_cx_mlbjinfo.ashx",
                data: { from: "BID.18393", tm: chdm },
                success: function (msg) {
                    $("#bg").hide();
                    $("#spinner").hide();
                    data = eval("(" + msg + ")");
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    data = { result: 'netError', textStatus: textStatus, status: XMLHttpRequest.status };
                }
            });
            return data;

        }
        //获取信息列表
        function getInfoList(data) {
            var list = data.Table;
            var str = "";
            for (var i = 0; i < list.length; i++) {
                if (list[i].zpdjg == null)
                    list[i].zpdjg = "";
                if (list[i].ys == null)
                    list[i].ys = "";
                if (list[i].bgid == null)
                    list[i].bgid = '#';
                str += "<tr>";
                str += " <td >" + list[i].mlbh + "</td>";
                str += " <td >" + list[i].ys + "</td>";
                if (list[i].pic == null || list[i].pic == '')
                    str += " <td >无图片</td>";
                else if (list[i].pic.indexOf("http") < 0) {
                    var src = "http://webt.lilang.com:9001/" + list[i].pic;
                    if (isShow.checked) {
                        str += " <td><img style='width:80px;'  src='" + src + "'/></br><a href='" + src + "'>查看原图</a></td>";
                    } else {
                        str += " <td><a href='" + src + "'>查看图片</a></td>";
                    }
                }
                else {
                    var src = "cl_cx_mlbjinfo_image.aspx?src=" + decodeURI(list[i].pic);
                    if (isShow.checked) {
                        str += " <td><img style='width:80px;'   src='" + src + "'/></br><a href='" + src + "'>查看原图</a></td>";
                    } else {
                        str += " <td><a href='" + src + "'>查看图片</a></td>";
                    }
                }
                str += " <td ><a href='http://webt.lilang.com:9001/tl_yf/pkjc_new_p_new.aspx?id=" + list[i].bgid + "&mrdw='>" + list[i].zpdjg + "</a></td>";
                str += "</tr>";

            }
            $("#list tbody").html(str);
            
        }

        //function waht(src) {
        //    llApp.openWebView("cl_cx_mlbjinfo_image.aspx?src=" + src);
        //}
        //存放查询历史的数组
        var history = {};
        //扫描历史
        function addLog(data,msg, result) {
            if (history[result] != undefined) return;
            history[result] = data;
            
            $("#mylog").append("<a href='#' class='list-group-item' myData='" + escape(msg) + "' onclick='bqLogSearch(\"" + result + "\")' style='color:#4f9fcf;'>" + result + "</a>");
        }
        //查询历史扫描记录
        function bqLogSearch(result) {
            var ev = event || window.event;            
            getInfoList(JSON.parse(unescape($(ev.srcElement).attr("myData"))));
            //if (history[result] == undefined) {
            //    swal({
            //        title: "提示信息",
            //        text: "查无数据",
            //        type: "error",
            //    }, function () {
            //        scan();
            //    });
            //}
            //getInfoList(history[result]);
        }
    </script>
    <style type="text/css">
        .row {
            padding-top: 10px;
        }

        th {
            text-align: center;
            vertical-align: middle;
        }

        td {
            word-break: break-all;
            text-align: center;
            vertical-align: middle;
        }

        .checkbox {
            margin-top: -3px;
        }

        [type=checkbox] {
            width: 100%;
            height: 100%;
        }

        .checkbox label {
            margin-top: 7px;
            font-size: 18px;
        }

        .spinner {
            margin: auto;
            width: 20%;
            height: 11%;
            position: absolute;
            top: 10%;
            right: 39%;
            z-index: 100000;
        }

            .spinner > div {
                background-color: deepskyblue;
                height: 100%;
                width: 9px;
                display: inline-block;
                -webkit-animation: stretchdelay 1.2s infinite ease-in-out;
                animation: stretchdelay 1.2s infinite ease-in-out;
            }

            .spinner .rect2 {
                -webkit-animation-delay: -1.1s;
                animation-delay: -1.1s;
            }

            .spinner .rect3 {
                -webkit-animation-delay: -1.0s;
                animation-delay: -1.0s;
            }

            .spinner .rect4 {
                -webkit-animation-delay: -0.9s;
                animation-delay: -0.9s;
            }

            .spinner .rect5 {
                -webkit-animation-delay: -0.8s;
                animation-delay: -0.8s;
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

        #bg {
            width: 100%;
            height: 100%;
            top: 0%;
            right: 0%;
            position: absolute;
            background-color: black;
            opacity: 0.2;
            z-index: 1000;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row" id="tag">
            <div class="col-xs-10 ">
                <div class="input-group">
                    <span class="input-group-addon">标签</span>
                    <input type="text" class="form-control" id="msg" />
                </div>
            </div>
            <div class="col-xs-2">
                <div class="checkbox">
                    <input type="checkbox" id="isShow" />
                    <label>图</label>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-xs-12 ">
                <button class="btn btn-primary btn-block" id="search" onclick="search()">查询</button>
            </div>
        </div>
        <div class="row">
            <div class="col-xs-12 ">
                <button id="ctrlScan" class="btn btn-primary btn-block" onclick="scan()">扫描</button>
            </div>
        </div>
        <div class="row" style="padding-top: 20px;">
            <div class="col-xs-12 ">
                <table class="table table-bordered" id="list">
                    <thead>
                        <tr>
                            <th style="width: 77px">面料编号</th>
                            <th style="width: 51px">颜    色</th>
                            <th style="width: 77px">扫描图片</th>
                            <th style="width: 77px">测试结果</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div style="margin-top: 20px">
        <div class="list-group" id="mylog">
            <a href="#" class="list-group-item disabled">扫描记录</a>
        </div>
    </div>
    <div id="bg"></div>
    <div class="spinner" id="spinner">
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
    <input type="hidden" id="myData" />
</body>    
</html>
<script type="text/javascript">
    window.onload = function () {
       
    }
</script>
