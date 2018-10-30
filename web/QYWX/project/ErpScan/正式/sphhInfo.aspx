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
            //SystemKey = "12742";
            WxHelper cs = new WxHelper();
            List<string> config = clsWXHelper.GetJsApiConfig("1");
            appIdVal.Value = config[0];
            timestampVal.Value = config[1];
            nonceStrVal.Value = config[2];
            signatureVal.Value = config[3];
            useridVal.Value = SystemKey;//系统管理->系统设置-微信部门人员管理(系统名称=协同系统,系统key就是t_user.id)
            //Response.Write(SystemKey);
            //Response.End();

            DataTable dt = null;
            string errInfo = "";

            using (LiLanzDALForXLM dal = new LiLanzDALForXLM(OAConnStr))
            {
                string str_sql = @" select * from yf_V_wx_mobile where id=@user_in";
                List<SqlParameter> para = new List<SqlParameter>();
                para.Add(new SqlParameter("@user_in", useridVal.Value));
                errInfo = dal.ExecuteQuerySecurity(str_sql, para, out dt);
            }
            if (dt.Rows.Count == 0)
            {
                isPass.Value = "0";
            }
            else
            {
                isPass.Value = "1";
            }
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
        var appIdVal, timestampVal, nonceStrVal, signatureVal;
        //var showhgzSrc, showxsbSrc, showbgjSrc;
        $(document).ready(function () {
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
            } else {
                //var arr = [10, 365, 677, 6551, 11665, 12742, 13902, 15976, 17557, 18732, 1036, 119, 332, 116, 11062];
                if (Number(document.getElementById("isPass").value) == 1) {
                    llApp.init();
                    jsConfig();
                } else {
                    alert("无权限");
                    document.getElementById("ctrlScan").style.display = "none";
                }

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
                            //alert(res.resultStr.split(",")[1]);
                            goScan(res.resultStr.split(",")[1]); // 当needResult 为 1 时，扫码返回的结果 
                        } else {
                            goScan(res.resultStr); // 当needResult 为 1 时，扫码返回的结果 
                        }

                    }
                });
            }
        };

        function goScan(result) {
            var checkInfo = getBQInfo(result);
            if (checkInfo.result == "Successed") {
                addLog(result);//增加扫描记录
                createChdmListHtml(checkInfo);//构造材料列表
                showChdmList();//显示材料列表                     
            } else if (checkInfo.result == "Error") {

                swal({
                    title: "提示信息",
                    text: "二维码信息查询错误",
                    type: "error"
                }, function () {
                    scan();
                });
            } else if (checkInfo.result == "netError") {
                swal({
                    title: "提示信息",
                    text: "网络错误",
                    type: "error"
                }, function () {
                    scan();
                });
            } else if (checkInfo.result == "NoRows") {
                swal({
                    title: "提示信息",
                    text: "查无数据,请检查当前用户是否有权限",
                    type: "error"
                }, function () {
                    scan();
                });
            }

        };

        function search() {
            if (document.getElementById("serinfo").value.length > 0) {
                var result = document.getElementById("serinfo").value;
                var checkInfo = getBQInfo(result);
                //var checkInfo = {}; checkInfo.result = "Successed";
                if (checkInfo.result == "Successed") {
                    addLog(result);//增加扫描记录
                    //var sphh = "Q73JK0081";
                    //var myid = 1278262
                    //showhgzSrc = "http://webt.lilang.com:9030/tl_yf/yf_T_showhgz.aspx?sphh=" + sphh + "&myid=" + myid + "";
                    //showxsbSrc = "http://webt.lilang.com:9030/tl_yf/yf_cl_sphh_xsb.aspx?sphh=" + sphh + "&myid=" + myid;
                    //showbgjSrc = "http://webt.lilang.com:9030/tl_yf/yf_T_showbgj.aspx?sphh=" + sphh + "&myid=" + myid;
                    //document.getElementById("showhgz").src = showhgzSrc;
                    //document.getElementById("showxsb").src = showxsbSrc;
                    //document.getElementById("showbgj").src = showbgjSrc;

                    createChdmListHtml(checkInfo);//构造材料列表
                    showChdmList();//显示材料列表                     
                } else if (checkInfo.result == "Error") {

                    swal({
                        title: "提示信息",
                        text: "二维码信息查询错误",
                        type: "error"
                    }, function () {

                    });
                } else if (checkInfo.result == "netError") {
                    swal({
                        title: "提示信息",
                        text: "网络错误",
                        type: "error"
                    }, function () {

                    });
                } else if (checkInfo.result == "NoRows") {
                    swal({
                        title: "提示信息",
                        text: "查无数据,请检查当前用户是否有权限",
                        type: "error"
                    }, function () {

                    });
                }
            }
        }

        //获取条码对应信息
        function getBQInfo(result) {
            var obj = null;
            $.ajax({
                type: "GET",
                timeout: 1000,
                async: false,
                contentType: "application/x-www-form-urlencoded; charset=utf-8",
                url: "yf_cl_sphh_xsb.aspx",
                data: { sphh: result },
                success: function (msg) {
                    if (msg == "") {
                        obj = eval("(" + "{\"result\":\"NoRows\",state:\"have no rows\"}" + ")");
                    } else {
                        obj = { result: 'Successed', jsonsObject: null };
                        var jsons = msg.split("&&&&");
                        for (var i = 0; i < jsons.length; i++) {
                            if (jsons[i] != "") {
                                jsons[i] = eval("(" + jsons[i] + ")");
                            }
                        }
                        obj.jsonsObject = jsons;
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    obj = { result: 'netError' };
                }
            });
            return obj;
        }

        //构造材料代码列表
        function createChdmListHtml(obj) {
            $("#chxx").empty();
            var trBgClass;
            var rows = "";
            var row = "<a href='#' class='list-group-item'><p class='list-group-item-text'><sapn style='display:inline-block; width:30%; text-align:left;'>@mc</sapn><sapn style='display:inline-block; width:70%; text-align:right;'>@value</sapn></p></a>";
            var row1 = "<a href='#' class='list-group-item'><p class='list-group-item-text'><sapn style='display:inline-block; width:30%; text-align:right;'>@mc</sapn><sapn style='display:inline-block; width:70%; text-align:right;'>@value</sapn></p></a>";

            var checkInfos = obj.jsonsObject;

            var 材料与供货商信息 = checkInfos[0].材料与供货商信息;

            //var htmlcreator = new htmlCreator();

            for (var k = 0; k < checkInfos.length; k++) {
                var checkInfo = checkInfos[k];
                if (checkInfo == "") continue;
                var 水洗名称, 纤维含量, 充绒量, 号型, 品名, 版型, 样号, 洗涤方法, 图标, 简化图标, 警告语, 规格, 执行标准, 货号;
                水洗名称 = checkInfo.水洗名称;
                纤维含量 = checkInfo.纤维含量;
                充绒量 = checkInfo.充绒量;
                号型 = checkInfo.号型;
                品名 = checkInfo.品名;
                版型 = checkInfo.版型;
                样号 = checkInfo.样号;
                洗涤方法 = checkInfo.洗涤方法1;
                图标 = checkInfo.洗涤方法;
                简化图标 = checkInfo.洗涤方法;
                警告语 = checkInfo.警告语;
                规格 = checkInfo.规格;
                执行标准 = checkInfo.执行标准;
                货号 = document.getElementById("serinfo").value;
                if (水洗名称 == "水洗牛仔裤" || 水洗名称 == "水洗牛仔裤v2") {

                    rows += row.replace("@mc", "品名").replace("@value", 品名);

                    if (水洗名称 == "水洗牛仔裤") {
                        rows += row.replace("@mc", "样号").replace("@value", 样号);
                    } else {
                        if (样号 == 货号) {
                            rows += row.replace("@mc", "样号").replace("@value", 样号);
                        } else {
                            rows += row.replace("@mc", "货号 - 样号").replace("@value", 货号 + " - " + 样号);
                        }
                    }
                    rows += row.replace("@mc", "号型").replace("@value", 号型);
                    rows += row.replace("@mc", "版型").replace("@value", 版型);
                    rows += row.replace("@mc", "纤维含量").replace("@value", "");
                    //rows += htmlcreator.add(row, { "mc": '号型', "value": 号型 })
                    //        .addCode(row, { "mc": '版型', "value": 版型 })
                    //        .addCode(row, { "mc": '纤维含量', "value": "" })
                    //        .getCode();       
                    rows += getCFHtml(纤维含量, row1);
                    rows += row.replace("@mc", "洗涤方法").replace("@value", 洗涤方法);
                    if (图标 != "") {
                        var xdtb = 图标.split("|");
                        for (var i = 0; i < xdtb.length; i++) {
                            if (xdtb[i] != "") {
                                var str = xdtb[i].split("&");
                                rows += row1.replace("@mc", "<img style='width:13mm'    src='" + str[0].replace("../tl_yf", "../../res/img/ErpScan") + "' />").replace("@value", str[1]);
                            }
                        }
                    }
                    rows += row.replace("@mc", "警告语").replace("@value", 警告语.replace("警告语", ""));

                } else if (水洗名称 == "休闲裤" || 水洗名称 == "休闲裤v2") {
                    rows += row.replace("@mc", "品名").replace("@value", 品名);
                    if (水洗名称 == "休闲裤") {
                        rows += row.replace("@mc", "样号").replace("@value", 样号);
                    } else {
                        if (样号 == 货号) {
                            rows += row.replace("@mc", "样号").replace("@value", 样号);
                        } else {
                            rows += row.replace("@mc", "货号 - 样号").replace("@value", 货号 + " - " + 样号);
                        }
                    }
                    rows += row.replace("@mc", "号型").replace("@value", 号型);
                    rows += row.replace("@mc", "版型").replace("@value", 版型);
                    rows += row.replace("@mc", "纤维含量").replace("@value", "");
                    rows += getCFHtml(纤维含量, row1);
                    rows += row.replace("@mc", "洗涤方法").replace("@value", 洗涤方法);
                    if (图标 != "") {
                        var xdtb = 图标.split("|");
                        for (var i = 0; i < xdtb.length; i++) {
                            if (xdtb[i] != "") {
                                var str = xdtb[i].split("&");
                                rows += row1.replace("@mc", "<img style='width:3mm' src='" + str[0].replace("../tl_yf", "../../res/img/ErpScan") + "' />").replace("@value", str[1]);
                            }
                        }
                    }

                } else if (水洗名称 == "男西裤" || 水洗名称 == "男西裤v2") {
                    rows += row.replace("@mc", "品名").replace("@value", 品名);
                    if (水洗名称 == "男西裤") {
                        rows += row.replace("@mc", "样号").replace("@value", 样号);
                    } else {
                        if (样号 == 货号) {
                            rows += row.replace("@mc", "样号").replace("@value", 样号);
                        } else {
                            rows += row.replace("@mc", "货号 - 样号").replace("@value", 货号 + " - " + 样号);
                        }
                    }
                    rows += row.replace("@mc", "号型").replace("@value", 号型);
                    rows += row.replace("@mc", "纤维含量").replace("@value", "");
                    rows += getCFHtml(纤维含量, row1);

                    rows += row.replace("@mc", "洗涤方法").replace("@value", 洗涤方法);
                    if (图标 != "") {
                        var xdtb = 图标.split("|");
                        for (var i = 0; i < xdtb.length; i++) {
                            if (xdtb[i] != "") {
                                var str = xdtb[i].split("&");
                                rows += row1.replace("@mc", "<img style='width:3mm' src='" + str[0].replace("../tl_yf", "../../res/img/ErpScan") + "' />").replace("@value", str[1]);
                            }
                        }
                    }

                } else if (水洗名称 == "休闲衬衫" || 水洗名称 == "休闲衬衫v2") {
                    rows += row.replace("@mc", "品名").replace("@value", 品名);
                    if (水洗名称 == "休闲衬衫") {
                        rows += row.replace("@mc", "样号").replace("@value", 样号);
                    } else {
                        if (样号 == 货号) {
                            rows += row.replace("@mc", "样号").replace("@value", 样号);
                        } else {
                            rows += row.replace("@mc", "货号 - 样号").replace("@value", 货号 + " - " + 样号);
                        }
                    }
                    rows += row.replace("@mc", "纤维含量").replace("@value", "");
                    rows += getCFHtml(纤维含量, row1);

                    rows += row.replace("@mc", "洗涤方法").replace("@value", 洗涤方法);
                    if (图标 != "") {
                        var xdtb = 图标.split("|");
                        for (var i = 0; i < xdtb.length; i++) {
                            if (xdtb[i] != "") {
                                var str = xdtb[i].split("&");
                                rows += row1.replace("@mc", "<img style='width:3mm' src='" + str[0].replace("../tl_yf", "../../res/img/ErpScan") + "' />").replace("@value", str[1]);
                            }
                        }
                    }

                } else if (水洗名称 == "短裤内裤" || 水洗名称 == "短裤内裤v2") {
                    rows += row.replace("@mc", "品名").replace("@value", 品名);
                    if (水洗名称 == "短裤内裤") {
                        rows += row.replace("@mc", "货号").replace("@value", 货号);
                        rows += row.replace("@mc", "执行标准").replace("@value", 执行标准);
                    } else {
                        if (样号 == 货号) {
                            rows += row.replace("@mc", "样号").replace("@value", 样号);
                        } else {
                            rows += row.replace("@mc", "货号 - 样号").replace("@value", 货号 + " - " + 样号);
                        }
                    }
                    rows += row.replace("@mc", "号型").replace("@value", 号型);
                    rows += row.replace("@mc", "规格").replace("@value", 规格);
                    rows += row.replace("@mc", "纤维含量").replace("@value", "");
                    rows += getCFHtml(纤维含量, row1);

                    rows += row.replace("@mc", "洗涤方法").replace("@value", 洗涤方法);
                    if (图标 != "") {
                        var xdtb = 图标.split("|");
                        for (var i = 0; i < xdtb.length; i++) {
                            if (xdtb[i] != "") {
                                var str = xdtb[i].split("&");
                                rows += row1.replace("@mc", "<img style='width:3mm' src='" + str[0].replace("../tl_yf", "../../res/img/ErpScan") + "' />").replace("@value", str[1]);
                            }
                        }
                    }
                    rows += row.replace("@mc", "批号").replace("@value", "");

                } else if (水洗名称 == "休闲服时尚羽绒服" || 水洗名称 == "休闲服时尚羽绒服v2") {
                    rows += row.replace("@mc", "品名").replace("@value", 品名);
                    if (水洗名称 == "休闲服时尚羽绒服") {
                        rows += row.replace("@mc", "样号").replace("@value", 样号);
                    } else {
                        if (样号 == 货号) {
                            rows += row.replace("@mc", "样号").replace("@value", 样号);
                        } else {
                            rows += row.replace("@mc", "货号 - 样号").replace("@value", 货号 + " - " + 样号);
                        }
                    }
                    rows += row.replace("@mc", "纤维含量").replace("@value", "");
                    rows += getCFHtml(纤维含量, row1);
                    rows += row.replace("@mc", "充绒量").replace("@value", "");
                    var 充绒量_规格 = 充绒量.规格;
                    var 充绒量_重量 = 充绒量.重量;
                    for (var i = 0; i < 充绒量_规格.length; i++) {
                        rows += row1.replace("@mc", 充绒量_规格[i].value1).replace("@value", 充绒量_重量[i].value1);
                        rows += row1.replace("@mc", 充绒量_规格[i].value2).replace("@value", 充绒量_重量[i].value2);
                        rows += row1.replace("@mc", 充绒量_规格[i].value3).replace("@value", 充绒量_重量[i].value3);
                    }
                    rows += row.replace("@mc", "洗涤方法").replace("@value", 洗涤方法);
                    if (图标 != "") {
                        var xdtb = 图标.split("|");
                        for (var i = 0; i < xdtb.length; i++) {
                            if (xdtb[i] != "") {
                                var str = xdtb[i].split("&");
                                rows += row1.replace("@mc", "<img style='width:3mm' src='" + str[0].replace("../tl_yf", "../../res/img/ErpScan") + "' />").replace("@value", str[1]);
                            }
                        }
                    }

                } else if (水洗名称 == "羽绒单衣") {
                    rows += row.replace("@mc", "品名").replace("@value", 品名);
                    rows += row.replace("@mc", "样号").replace("@value", 样号);
                    rows += row.replace("@mc", "号型").replace("@value", 号型);
                    rows += row.replace("@mc", "纤维含量").replace("@value", "");
                    rows += getCFHtml(纤维含量, row1);
                    rows += row.replace("@mc", "充绒量").replace("@value", "");
                    var 充绒量_规格 = 充绒量.规格;
                    var 充绒量_重量 = 充绒量.重量;
                    for (var i = 0; i < 充绒量_规格.length; i++) {
                        rows += row1.replace("@mc", 充绒量_规格[i].value1).replace("@value", 充绒量_重量[i].value1);
                        rows += row1.replace("@mc", 充绒量_规格[i].value2).replace("@value", 充绒量_重量[i].value2);
                        rows += row1.replace("@mc", 充绒量_规格[i].value3).replace("@value", 充绒量_重量[i].value3);
                    }
                    rows += row.replace("@mc", "洗涤方法").replace("@value", 洗涤方法);
                    if (图标 != "") {
                        var xdtb = 图标.split("|");
                        for (var i = 0; i < xdtb.length; i++) {
                            if (xdtb[i] != "") {
                                var str = xdtb[i].split("&");
                                rows += row1.replace("@mc", "<img style='width:3mm' src='" + str[0].replace("../tl_yf", "../../res/img/ErpScan") + "' />").replace("@value", str[1]);
                            }
                        }
                    }

                } else if (水洗名称 == "茄克衫" || 水洗名称 == "茄克衫v2") {
                    rows += row.replace("@mc", "品名").replace("@value", 品名);
                    if (水洗名称 == "茄克衫") {
                        rows += row.replace("@mc", "样号").replace("@value", 样号);
                    } else {
                        if (样号 == 货号) {
                            rows += row.replace("@mc", "样号").replace("@value", 样号);
                        } else {
                            rows += row.replace("@mc", "货号 - 样号").replace("@value", 货号 + " - " + 样号);
                        }
                    }
                    rows += row.replace("@mc", "纤维含量").replace("@value", "");
                    rows += getCFHtml(纤维含量, row1);
                    rows += row.replace("@mc", "洗涤方法").replace("@value", 洗涤方法);
                    if (图标 != "") {
                        var xdtb = 图标.split("|");
                        for (var i = 0; i < xdtb.length; i++) {
                            if (xdtb[i] != "") {
                                var str = xdtb[i].split("&");

                                rows += row1.replace("@mc", "<img style='width:3mm' src='" + str[0].replace("../tl_yf", "../../res/img/ErpScan") + "' />").replace("@value", str[1]);
                            }
                        }
                    }

                } else if (水洗名称 == "西服套装" || 水洗名称 == "西服套装v2") {
                    rows += row.replace("@mc", "品名").replace("@value", 品名);
                    if (水洗名称 == "西服套装") {
                        rows += row.replace("@mc", "样号").replace("@value", 样号);
                    } else {
                        if (样号 == 货号) {
                            rows += row.replace("@mc", "样号").replace("@value", 样号);
                        } else {
                            rows += row.replace("@mc", "货号 - 样号").replace("@value", 货号 + " - " + 样号);
                        }
                    }
                    rows += row.replace("@mc", "号型").replace("@value", 号型);
                    rows += row.replace("@mc", "纤维含量").replace("@value", "");
                    rows += getCFHtml(纤维含量, row1);
                    rows += row.replace("@mc", "洗涤方法").replace("@value", 洗涤方法);
                    if (图标 != "") {
                        var xdtb = 图标.split("|");
                        for (var i = 0; i < xdtb.length; i++) {
                            if (xdtb[i] != "") {
                                var str = xdtb[i].split("&");
                                rows += row1.replace("@mc", "<img style='width:3mm' src='" + str[0].replace("../tl_yf", "../../res/img/ErpScan") + "' />").replace("@value", str[1]);
                            }
                        }
                    }

                } else if (水洗名称 == "内衣内裤热转移印标") {
                    rows += row.replace("@mc", "品名").replace("@value", 品名);
                    rows += row.replace("@mc", "样号").replace("@value", 样号);
                    rows += row.replace("@mc", "号型").replace("@value", 号型);
                    rows += row.replace("@mc", "规格").replace("@value", 规格);
                    rows += row.replace("@mc", "纤维含量").replace("@value", "");
                    rows += getCFHtml(纤维含量, row1);
                    rows += row.replace("@mc", "洗涤方法").replace("@value", 洗涤方法);
                    if (简化图标 != "") {
                        var xdtb = 简化图标.split("|");
                        for (var i = 0; i < xdtb.length; i++) {
                            if (xdtb[i] != "") {
                                rows += row1.replace("@mc", "<img style='width:3mm' src='" + str[0].replace("../tl_yf", "../../res/img/ErpScan") + "' />").replace("@value", "");
                            }
                        }
                    }

                }
            }
            if (材料与供货商信息 != "") {
                for (var i = 0; i < 材料与供货商信息.length; i++) {
                    rows += row.replace("@mc", 材料与供货商信息[i].khmc + "<br/>" + 材料与供货商信息[i].chdm).replace("@value", "<br/>" + 材料与供货商信息[i].chmc);
                }
            }
            $("#chxx").append(rows);
        }

        //链接获取HTML
        function htmlCreator() {
            var o = {};
            o.html = '';
            o.add = function (htmlModal, obj) {
                this.html += htmlModal.replace("@mc", obj.mc).replace("@value", obj.value);
                return this;
            }
            /* 返回成员变量html */
            o.get = function () {
                return this.html;
            }
            return o;
        }

        //处理成份
        function getCFHtml(纤维含量, htmlModal) {
            var html = "";
            for (var i = 0; i < 纤维含量.split("|").length; i++) {
                var tmpIgn = 纤维含量.split("|")[i];
                if (tmpIgn != "") {
                    if (tmpIgn.split(":").length == 1) {//成份前面没有帽号和说明
                        var str = tmpIgn.split(":")[0].split(" ");
                    } else {
                        var str = tmpIgn.split(":")[1].split(" ");
                        html += htmlModal.replace("@mc", tmpIgn.split(":")[0]).replace("@value", "");
                    }
                    if (str.length >= 0) {
                        for (var j = 0; j < str.length; j++) {
                            if (str[j] != "") {
                                html += htmlModal.replace("@mc", "").replace("@value", str[j]);
                            }
                        }
                    }
                }
            }
            return html;
        }
        //增加一个扫描历史
        function addLog(bq) {
            //$("#mylog").append("<div class=\"row\"><div class=\"col-md-1\"><a href=\"#\" onclick=\"bqLogSearch(this)\" >" + bq + "</a></div></div>");
            $("#mylog").append("<a href='#' class='list-group-item' onclick='bqLogSearch(this)' style='color:#4f9fcf;'>" + bq + "</a>");
        }

        //查询历史扫描记录
        function bqLogSearch(obj) {
            var checkInfo = getBQInfo(obj.innerHTML);
            createChdmListHtml(checkInfo);//构造材料列表
            showChdmList();//显示材料列表
        }

        //显示扫描页
        function showScan() {
            $("#pagescan").attr("class", "page");
            $("#pagechdm").attr("class", "page page-not-header page-right");;
        }

        //显示信息页
        function showChdmList() {
            $("#fhBtn").attr("onclick", "showScan()");
            $("#pagescan").attr("class", "page page-right");
            $("#pagechdm").attr("class", "page page-not-header ");
        }

        //取小数位
        function ForDight(Dight, How) {
            Dight = Math.round(Dight * Math.pow(10, How)) / Math.pow(10, How);
            return Dight;
        }

        /*
          * 用来遍历指定对象所有的属性名称和值
          * obj 需要遍历的对象
          * author: Jet Mah
          * website: http://www.javatang.com/archives/2006/09/13/442864.html 
        */
        function allPrpos(obj) {
            // 用来保存所有的属性名称和值
            var props = "";
            // 开始遍历
            for (var p in obj) {
                // 方法
                if (typeof (obj[p]) == "function") {
                    obj[p]();
                } else {
                    // p 为属性名称，obj[p]为对应属性的值
                    props += p + "=" + obj[p] + "\t";
                }
            }
            // 最后显示所有的属性
            return props;

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
                    <span class="input-group-addon">合格证信息查询</span>
                </div>
                <div class="input-group input-group-lg" style="margin-bottom: 5px;">
                    <span class="input-group-addon">货号:</span>
                    <input type="text" class="form-control" id="serinfo">
                </div>
                <input type="button" style="margin-top: 20px" class="btn btn-default btn-lg btn-block" onclick="search()" value="查询" />

                <input type="button" id="ctrlScan" style="margin-top: 20px" class="btn btn-default btn-lg btn-block" onclick="scan()" value="扫描" />

                <div style="margin-top: 20px">                  
                    <div class="list-group" id="mylog">
                        <a href="#" class="list-group-item disabled">扫描记录</a>
                    </div>
                </div>
            </div>
            <div id="pagechdm" class="page page-not-header page-right ">
                <div class="list-group" id="chxx">
                    <%--<div>
                    <iframe id="showhgz"  style="width:100%;height:500px;" frameborder="no" border="0" marginwidth="0" marginheight="0" src="#" ></iframe></div>
                    <div>
                    <iframe id="showxsb"  style="width:100%;height:300px;"  frameborder="no" border="0" marginwidth="0" marginheight="0" src="#" ></iframe></div>
                    <div>
                    <iframe id="showbgj"  style="width:100%;height:500px;"  frameborder="no" border="0" marginwidth="0" marginheight="0" src="#" ></iframe></div>--%>
                </div>
            </div>
        </div>
        <input type="hidden" runat="server" id="appIdVal" />
        <input type="hidden" runat="server" id="timestampVal" />
        <input type="hidden" runat="server" id="nonceStrVal" />
        <input type="hidden" runat="server" id="signatureVal" />
        <input type="hidden" runat="server" id="useridVal" />
        <input type="hidden" runat="server" id="isPass" />

    </form>


</body>
</html>
