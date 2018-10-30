<%@ Page Title="设定销售目标" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>
<script runat="server">
    public string ryid = "";
    public string mdid = "";
    protected void Page_PreRender(object sender, EventArgs e)
    {
        string SystemKey = this.Master.AppSystemKey;
        string ConWX = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString; //连接62
        using (LiLanzDALForXLM dalWX = new LiLanzDALForXLM(ConWX))
        {
            string strSQL = string.Format(@"SELECT TOP 1 RelateID,B.mdid FROM wx_t_OmniChannelUser A
                            INNER JOIN Rs_T_Rydwzl B ON A.RelateID = B.ID
                            WHERE A.ID = {0}", SystemKey);
            System.Data.DataTable dt;
            string strInfo = dalWX.ExecuteQuery(strSQL, out dt);
            if (strInfo == "")
            {
                if (dt.Rows.Count > 0)
                {
                    ryid = Convert.ToString(dt.Rows[0]["RelateID"]);
                    mdid = Convert.ToString(dt.Rows[0]["mdid"]);
                }
                dt.Rows.Clear(); dt.Dispose();
            }

        }
    }

    //必须在内容页的Load中对Master.SystemID 进行赋值；
    protected void Page_Load(object sender, EventArgs e)
    {
        //Session["qy_customersid"] = "354";
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="height=device-height,width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" />
    <meta name="format-detection" content="telephone=no" />
    <title></title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link href="http://api.youziku.com/webfont/CSS/56d5c4fcf629d80420b28a91" rel="stylesheet" type="text/css" />
    <style type="text/css">
        body {
            font-size: 14px;
            background-color: #f4f4f4;
            color: #575d6a;
            font-family: "San Francisco",Helvitica Neue,Helvitica,Arial,sans-serif;
        }

        .header {
            height: 50px;
            line-height: 50px;
            text-align: center;
            font-size: 1.2em;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
        }

        .page {
            background-color: transparent;
            padding: 0 0 60px 0;
        }

        .page-not-header-footer {
            top: 50px;
            bottom: 60px;
        }

        .header .fa-angle-left {
            position: absolute;
            top: 0;
            left: 0;
            height: 50px;
            line-height: 50px;
            padding: 0 20px;
            font-size: 1.4em;
            border-right: 1px solid #f5f5f5;
        }

            .header .fa-angle-left:hover {
                background-color: rgba(0,0,0,.1);
            }

        .item .item-title {
            font-size: 1.1em;
            font-style: italic;
            color: #888;
            padding: 15px 10px 2px 10px;
        }

        .item .item-content {
            height: 56px;
            background-color: #fff;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            position: relative;
            padding: 0 56px;
            text-align: center;
            line-height: 56px;
            font-family: 'HelveticaNeue1d832c0a34d3c';
        }

        .minus, .add {
            width: 56px;
            height: 56px;
            position: absolute;
            top: 0;
            left: 0;
            background-color: #faaa05;
            color: #fff;
            text-align: center;
            line-height: 56px;
            font-size: 1.4em;
        }

        .add {
            left: inherit;
            right: 0;
            background-color: #d9534f;
        }

        .target {
            height: 96px;
            background-color: #fff;
            box-shadow: 0 1px .5px #eceef1;
            -webkit-box-shadow: 0 1px .5px #eceef1;
            margin-top: 15px;
            font-size: 0;
        }

            .target > div {
                display: inline-block;
                width: 50%;
                font-size: 14px;
                text-align: center;
                border-top: 3px solid #faaa05;
                color: #faaa05;
            }

            .target .t-right {
                border-top: 3px solid #d9534f;
                border-left: 1px solid #f4f4f4;
                color: #d9534f;
            }

            .target .title {
                font-size: 1.2em;
                height: 43px;
                line-height: 43px;
            }

            .target .val {
                height: 40px;
                line-height: 40px;
                font-size: 2em;
                font-weight: bold;
                font-family: 'HelveticaNeue1d832c0a34d3c';
                color: #575d6a;
            }

        #saleTarget {
            -webkit-appearance: none;
            border: none;
            border-radius: 0;
            width: 100%;
            height: 100%;
            padding: 10px 15px;
            font-size: 1.4em;
            line-height: 36px;
            font-family: 'HelveticaNeue1d832c0a34d3c';
            color: #575d6a;
            font-weight: bold;
        }

        .footer {
            height: 50px;
        }

        .btns {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            background-color: #fff;
            height: 50px;
            margin-top: 15px;
            background-color: #d9534f;
            color: #fff;
            font-size: 0;
            line-height: 50px;
        }

            .btns a {
                font-weight: bold;
                font-size: 1.3em;
                text-align: center;
                display: inline-block;
                width: 50%;
                color: #fff;
                font-size: 18px;
            }

        #showToast {
            width: 60%;
        }

        #backBtn {
            background-color: #bababa;
            width: 40%;
        }

        .tips {
            padding: 15px;
        }
        /*mask style*/
        .mask {
            color: #fff;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            z-index: 1001;
            font-size: 1.1em;
            text-align: center;
            background-color: rgba(0,0,0,0.5);
            display: none;
        }

        .loader {
            background-color: rgba(39, 43, 46, 0.9);
            padding: 15px 20px;
            border-radius: 5px;
            max-height: 200px;
            overflow: hidden;
        }

        #loadtext {
            margin-top: 5px;
            font-weight: bold;
            font-size: 0.9em;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="header">个人业绩目标设置<i class="fa fa-angle-left" onclick="javascript:window.history.go(-1);"></i></div>
    <div class="wrap-page">
        <div class="page page-not-header-footer">
            <div class="item">
                <p class="item-title">月 份</p>
                <div class="item-content">
                    <div class="minus"><i class="fa fa-minus"></i></div>
                    <div class="add"><i class="fa fa-plus"></i></div>
                    <div style="font-size: 1.4em; font-weight: bold; letter-spacing: 1px;">
                        <span class="nYear" id="nYear">--</span>-<span class="nMonth" id="nMonth">--</span>
                    </div>
                </div>
            </div>
            <div class="target">
                <div class="t-left">
                    <p class="title">本店目标</p>
                    <p class="val" id="totalGoal">暂未设置</p>
                </div>
                <div class="t-right">
                    <p class="title">我的目标</p>
                    <p class="val" id="myGoal">暂未设置</p>
                </div>
            </div>
            <div class="item">
                <p class="item-title">设置目标(单位：万) 支持一位小数</p>
                <div class="item-content" style="padding: 0;">
                    <input type="number" id="saleTarget" placeholder="例：2.1" />
                </div>
            </div>
            <div class="tips">
                <p><strong>相关说明：</strong></p>
                <p>1、输入的业绩目标是以万为单位，且若输入超过一位小数将自动进行四舍五入！</p>
                <p>2、业绩目标按月来设置，对应的年业绩目标即为每个月的目标之和！</p>
            </div>

        </div>
    </div>
    <div class="footer">
        <div class="btns">
            <a href="javascript:" id="backBtn" onclick="javascript:window.history.go(-1);">返 回</a>
            <a href="javascript:" id="showToast" onclick="saveSaleTarget()">提 交</a>
        </div>
    </div>
    <!--MASK提示层-->
    <div class="mask">
        <div class="loader center-translate">
            <div style="font-size: 1.2em;">
                <i class="fa fa-2x fa-spinner fa-pulse"></i>
            </div>
            <p id="loadtext">正在加载...</p>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/storesaler/fastclick.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            FastClick.attach(document.body);
            //页面初始化成功，显示当前月
            var CurrentDate = new Date().Format("yyyyMM");
            $("#nYear").text(CurrentDate.substr(0, 4));
            $("#nMonth").text(CurrentDate.substr(4, 2));
            var tYear = new Date().getFullYear();
            var tMonth = new Date().getMonth() + 1;
            getSaleTarget(tYear, tMonth);
        });
        //日期格式化函数
        Date.prototype.Format = function (fmt) {
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
        
        //日期加减操作
        Date.prototype.add = function (part, value) {
            value *= 1;
            if (isNaN(value)) {
                value = 0;
            }
            switch (part) {
                case "y":
                    this.setFullYear(this.getFullYear() + value);
                    break;
                case "m":
                    this.setMonth(this.getMonth() + value);
                    break;
                case "d":
                    this.setDate(this.getDate() + value);
                    break;
                case "h":
                    this.setHours(this.getHours() + value);
                    break;
                case "n":
                    this.setMinutes(this.getMinutes() + value);
                    break;
                case "s":
                    this.setSeconds(this.getSeconds() + value);
                    break;
                default:

            }
        }

        //日期加一月
        $(".add").click(function () {
            var aDate = new Date($("#nYear").text() + "-" + $("#nMonth").text() + "-01");
            aDate.add('m', 1);
            var _year = aDate.Format("yyyyMM").substr(0, 4);
            var _month = aDate.Format("yyyyMM").substr(4, 2)
            $("#nYear").text(_year);
            $("#nMonth").text(_month);
            getSaleTarget(_year, _month);
        });

        //日期减一月
        $(".minus").click(function () {
            var aDate = new Date($("#nYear").text() + "-" + $("#nMonth").text() + "-01");
            aDate.add('m', -1);
            var _year = aDate.Format("yyyyMM").substr(0, 4);
            var _month = aDate.Format("yyyyMM").substr(4, 2)
            $("#nYear").text(_year);
            $("#nMonth").text(_month);
            getSaleTarget(_year, _month);
        });

        function getSaleTarget(nYear, nMonth) {
            showLoader("loading", "正在加载...");
            var ny = new Date(nYear, nMonth - 1).Format("yyyyMM");
            $.ajax({
                url: "saleTargetCore.aspx?ctrl=getSaleTarget",
                type: "POST",
                data: { "mdid": "<%= mdid%>", "ryid": "<%= ryid%>", "nYear": nYear, "nMonth": nMonth, "ny": ny },
                dataType: "HTML",
                timeout: 15000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(errorThrown);
                },
                success: function (result) {
                    var obj = JSON.parse(result);
                    if (obj.rows[0].je == 0) {
                        $("#totalGoal").text("暂未设置");
                    }
                    else {
                        $("#totalGoal").text(parseFloat(obj.rows[0].je / 10000).toFixed(1) + "万");
                    }

                    if (obj.rows[0].SaleTarget == 0) {
                        $("#myGoal").text("暂未设置");                        
                    } else {
                        $("#myGoal").text(obj.rows[0].SaleTarget + "万");
                    }

                    $(".mask").hide();
                }
            });
        }

        function saveSaleTarget() {
            var saleTarget = $("#saleTarget").val();
            if (saleTarget == "") {
                showLoader("warn","请填写业绩目标！");
                return;
            }
            if (parseFloat(saleTarget).toFixed(1) <= 0) {
                showLoader("warn", "填写的业绩目标有误！");
                return;
            }
            nYear = $("#nYear").text();
            nMonth = $("#nMonth").text();

            $.ajax({
                url: "saleTargetCore.aspx?ctrl=saveSaleTarget",
                type: "POST",
                data: { "mdid": "<%= mdid%>", "ryid": "<%= ryid%>", "nYear": nYear, "nMonth": nMonth, "saleTarget": saleTarget },
                dataType: "HTML",
                timeout: 15000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert(errorThrown)
                },
                success: function (result) {
                    showLoader("successed", "设置成功！");
                    $("#saleTarget").val("");
                    setTimeout(function () {
                        getSaleTarget(nYear, nMonth);
                    }, 500);
                }
            });
        }


        //提示层
        function showLoader(type, txt) {
            switch (type) {
                case "loading":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-spinner fa-pulse");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    break;
                case "successed":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-check");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 800);
                    break;
                case "error":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-close (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 2000);
                    break;
                case "warn":
                    $(".mask .fa").removeAttr("class").addClass("fa fa-2x fa-warning (alias)");
                    $("#loadtext").text(txt);
                    $(".mask").show();
                    setTimeout(function () {
                        $(".mask").fadeOut(400);
                    }, 800);
                    break;
            }
        }
    </script>

</asp:Content>
