<%@ Page Language="C#" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="WebBLL.Core" %>

<!DOCTYPE html>
<script runat="server">
    public List<string> wxConfig; //微信OPEN_JS 动态生成的调用参数
    private const string ConfigKeyValue = "1";
    protected void Page_Load(object sender, EventArgs e)
    {
        string url = Request.Url.ToString().ToLower();//转为小写,indexOf 和Replace 对大小写都是敏感的     
  
        if (clsWXHelper.CheckQYUserAuth(true))
        {
            wxConfig = clsWXHelper.GetJsApiConfig(ConfigKeyValue);
            //clsSharedHelper.WriteInfo(Session["qy_cname"].ToString());
        }
    }
</script>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
        var appIdVal = "<%=wxConfig[0]%>", timestampVal = "<%=wxConfig[1]%>", nonceStrVal = "<%=wxConfig[2]%>", signatureVal = "<%=wxConfig[3]%>";
        var username = '<%=Session["qy_cname"] %>';
        $(document).ready(function () {
           
            wxConfig();
          
            llApp.init();
           
        });

        /********************签名**********************/
        //微信JSAPI
        function wxConfig() {//微信js 注入
            wx.config({
                debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
                appId: appIdVal, // 必填，企业号的唯一标识，此处填写企业号corpid
                timestamp: timestampVal, // 必填，生成签名的时间戳
                nonceStr: nonceStrVal, // 必填，生成签名的随机串
                signature: signatureVal, // 必填，签名，见附录1
                jsApiList: ["scanQRCode"] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
            });
            wx.ready(function () {
                //alert("注入成功");
            });
            wx.error(function (res) {
                //alert("JS注入失败！");
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
                        goScan(res.resultStr); // 当needResult 为 1 时，扫码返回的结果 
                    }
                });
            }
        };
        function goScan(resultStr) {
            document.getElementById("serinfo").value = resultStr;
            //                    var result = res.resultStr.split("=")[1]; // 当 needResult 为 1 时，扫码返回的结果
            //                    var checkInfo = getSphh(result, "getwym");       
            //                    if (checkInfo.result == "Successed") {
            //                        document.getElementById("serinfo").value = checkInfo.jsonsObject;           
            //                    } else if (checkInfo.result == "Error") {
            //                        swal({
            //                            title: "提示信息",
            //                            text: "二维码信息查询错误",
            //                            type: "error",
            //                        }, function () {
            //                            scan();
            //                        });
            //                    }
        }

        //获取条码对应货号信息
        function getSphh(result, mytype) {
            var obj = null;
            $.ajax({
                type: "GET",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "yf_T_UniqueCode.aspx",
                data: { sphh: encodeURI(result), mytype: mytype }, //GB2312,utf-8 
                success: function (msg) {
                    if (msg == "") {
                        obj = eval("(" + "{\"result\":\"NoRows\",state:\"查无记录!\"}" + ")");
                    } else {
                        obj = { result: 'Successed', jsonsObject: null };
                        obj.jsonsObject = msg;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    obj = { result: '查无记录!!' + textStatus.tostring() };
                }
            });
            return obj;
        }

        //获取条码对应信息
        function tjxx(result, userid) {
            var obj = null;
            $.ajax({
                type: "GET",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "yf_T_ScanSPLManage_Code.aspx",
                data: { sphh: encodeURI(result), username: username }, //GB2312,utf-8 
                success: function (msg) {
                    if (msg == "") {
                        obj = eval("(" + "{\"result\":\"NoRows\",state:\"处理失败!\"}" + ")");
                    } else {
                        obj = { result: 'Successed', jsonsObject: null };
                        obj.jsonsObject = msg;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    obj = { result: '处理失败!!' + textStatus.tostring() };
                }
            });
            return obj;
        }

        function mysave() {
            var serinfo = document.getElementById("serinfo").value;
            var sphh = serinfo;
            if (serinfo.length > 0 && serinfo.length > 9) {  //serinfo:唯一码
                var checkInfo = tjxx(sphh, username);
                if (checkInfo.result == "Successed") {
                    alert(checkInfo.jsonsObject);
                    document.getElementById("serinfo").value = "";
                    scan();
                } else if (checkInfo.result == "Error") {
                    swal({
                        title: "提示信息",
                        text: "二维码信息查询错误",
                        type: "error",
                    }, function () {

                    });
                }
            }
        }

    </script>
    <style type="text/css">
        .header {
            background-color: #272b2e;
            border-bottom: 1px solid #161A1C;
            text-align: center;
            padding: 0 10px;
        }

        .logo {
            height: 20px;
            margin: 0 auto;
            margin-top: 15px;
            color: #fff;
            z-index: 110;
        }

        .backbtn {
            position: absolute;
            top: 0;
            bottom: 0;
            line-height: 50px;
            font-size: 1.4em;
            color: #b1afaf;
            left: 0;
            padding: 0 20px;
            border-right: 1px solid #161A1C;
        }

        .logo img {
            height: 100%;
            width: auto;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header class="header" id="header">
			<div class="logo">
				<div class="backbtn"><i id="fhBtn" class="fa fa-chevron-left" onclick="showScan()"></i></div>
				<img src="../../res/img/StoreSaler/lllogo6.png" alt="" />
			</div>
		</header>
        <div class="wrap-page">
            <div id="pagescan" class="page">
                <div class="input-group input-group-lg" style="margin-bottom: 5px;">
                    <span class="input-group-addon">营销样衣出库/归还管理</span>
                </div>

                <div class="input-group input-group-lg" style="margin-bottom: 5px;">
                    <span class="input-group-addon">货号:</span>
                    <input type="text" class="form-control" id="serinfo" readonly value="">
                </div>

                <input type="button" id="ctrlScan" style="margin-top: 10px" class="btn btn-default btn-lg btn-block" onclick="scan()" value="扫描" />
                <input type="button" style="margin-top: 10px" class="btn btn-default btn-lg btn-block" onclick="mysave()" value="提交" />

            </div>
        </div>
        <input type="hidden" runat="server" id="isInWeiXin" />
    </form>
</body>
</html>
