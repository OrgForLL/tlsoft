<%@ Page Title="个人业绩" Language="C#" MasterPageFile="../../WebBLL/frmQQDBase.Master" AutoEventWireup="true" %>

<%@ MasterType VirtualPath="../../WebBLL/frmQQDBase.Master" %>

<%@ Import Namespace="nrWebClass" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">

    public string ryid = "";

    protected void Page_PreRender(object sender, EventArgs e)
    {
        clsWXHelper.CheckQQDMenuAuth(14);    //检查菜单权限
        
        string SystemKey = this.Master.AppSystemKey;

        string strInfo = "";
        string ConWX = ConfigurationManager.ConnectionStrings["Conn"].ConnectionString; //连接62
        using (LiLanzDALForXLM dalWX = new LiLanzDALForXLM(ConWX))
        {
            string strSQL = string.Concat("SELECT TOP 1 RelateID FROM wx_t_OmniChannelUser WHERE ID=", SystemKey);

            object objRelateID = "";
            strInfo = dalWX.ExecuteQueryFast(strSQL, out objRelateID);
            if (strInfo == "")
            {
                ryid = Convert.ToString(objRelateID);
                //ryid = "34234";
            }
            else
            {
                clsLocalLoger.WriteError(string.Concat("读取当前用户信息失败！错误：", strInfo));
                clsWXHelper.ShowError("读取当前用户信息失败");
            }
        }

        if (ryid == "0") clsWXHelper.ShowError("该功能仅提供门店销售人员使用！"); 
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        //this.Master.IsTestMode = true;
        //this.Master.SystemID = "3";     //可设置SystemID,默认为3（全渠道系统）
        //this.Master.AppRootUrl = "../../../";     //可手动设置WEB程序的根目录,默认为 当前页面的向上两级

        //统一的后台错误输出方法
        //clsWXHelper.ShowError("错误提示内容121113456，自定义内容");
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0,maximum-scale=1" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <title>个人业绩总览</title>
    <link type="text/css" rel="stylesheet" href="../../res/css/LeePageSlider.css" />
    <link type="text/css" rel="stylesheet" href="../../res/css/font-awesome.min.css" />
    <link href="http://api.youziku.com/webfont/CSS/56d5c4fcf629d80420b28a91" rel="stylesheet" type="text/css" />
    <style type="text/css">
        body
        {
            background-color: #eee;
            color: #323232;
        }

        .header
        {
            background-color: #f9f9f9;
            border-bottom: 1px solid #e7e7e7;
            line-height: 50px;
            font-size: 1.3em;
        }

        .fa-angle-left
        {
            position: absolute;
            top: 0;
            left: 0;
            height: 100%;
            font-size: 1.6em;
            line-height: 50px;
            padding: 0 20px;
        }

            .fa-angle-left:hover
            {
                background-color: rgba(0,0,0,.1);
            }

        .page
        {
            background-color: #f0f0f0;
            padding: 0;
        }

        .chart-area
        {
            left: 0;
            width: 100%;
            text-align: center;
            position: relative;
        }

            .chart-area .errInfo
            {
                font-size: 1.1em;
                color: #666;
                font-family: 'HelveticaNeue1d832c0a34d3c';
                letter-spacing: 2px;
                /*margin:60px auto 0 auto;*/
                margin-left: auto;
                margin-right: auto;
            }

            .chart-area #canvas
            {
                margin-top: 35px;
                margin-left: auto;
                margin-right: auto;
                width: 100%;
            }

        .staticul
        {
            position: absolute;
            left: 0;
            width: 100%;
            bottom: 0;
            border-top: 1px solid #eee;
        }

            .staticul li
            {
                width: 50%;
                background-color: #fff;
                padding: 5px;
                float: left;
                height: 100px;
                border-right: 1px solid #eee;
                border-bottom: 1px solid #eee;
                color: #777;
                text-align: center;
                font-size: 1.1em;
                padding: 10px;
                font-family: 'HelveticaNeue1d832c0a34d3c';
                position: relative;
            }

                .staticul li:hover
                {
                    background-color: rgba(0,0,0,0.1);
                }

        .title
        {
            line-height: 30px;
        }

        .val
        {
            line-height: 50px;
            color: #ff7e00;
            font-size: 1.8em;
            opacity: 0;
        }

        .fa-angle-right
        {
            position: absolute;
            top: 0;
            right: 15px;
            height: 100px;
            line-height: 100px;
            font-size: 1.8em;
            color: #bbb;
        }
        /*animation css*/
        .animated
        {
            -webkit-animation-duration: 1s;
            animation-duration: 1s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }
     

        .goal div
        {
            float: left;
            width: 40%;
            line-height:10px;
            box-sizing: border-box;
        }
    </style>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="header">
        <i class="fa fa-angle-left" onclick="backbtn()"></i>
        个人业绩
    </div>
    <div class="wrap-page">
        <div id="main-page" class="page page-not-header">
            <div class="chart-area">
                <canvas id="canvas"></canvas>
            </div>
            <ul class="staticul floatfix">
                <li onclick="getTclist('today')">
                    <p class="title">今日销售业绩</p>
                    <p class="val" id="todaySale"></p>
                    <i class="fa fa-angle-right"></i>
                </li>
                <li>
                    <p class="title">今日完成单量</p>
                    <p class="val" id="todayCount"></p>
                </li>
                <li onclick="getTclist('all')">
                    <p class="title">本月实时业绩</p>
                    <p class="val" id="monthSale"></p>
                    <i class="fa fa-angle-right"></i>
                </li>
                <li>
                    <p class="title">本月完成单量</p>
                    <p class="val" id="monthCount"></p>
                </li>
                <li class="goal" onclick="setSaleTarget()">
                    <p class="title" style="width:80%;">销售目标</p>
                    <%--<p class="val" id="goal"></p>--%>
                    <div><p class="val" style="font-size:1.4em;line-height: 30px;" id="goal"></p><p>本月</p></div>
                    <div><p class="val" style="font-size:1.4em;line-height: 30px;" id="allGoal"></p><p>本年</p></div>
                    <i class="fa fa-angle-right"></i>
                </li>
                <li class="goal">
                    <p class="title">目标完成度</p>
                    <%--<p class="val" id="goalPace"></p>--%>
                    <div style="width:50%;"><p class="val" style="font-size:1.4em;line-height: 30px;" id="finishMonth"></p><p>本月</p></div>
                    <div style="width:50%;"><p class="val" style="font-size:1.4em;line-height: 30px;" id="finishYear"></p><p>本年</p></div>                    
                </li>
            </ul>
        </div>
    </div>
    <script type="text/javascript" src="../../res/js/jquery.js"></script>
    <script type="text/javascript" src="../../res/js/Chart.min.js"></script>
    <script type="text/javascript" src="../../res/js/StoreSaler/fastclick.min.js"></script>
    <script type="text/javascript">
        window.onload = function () {
            getNewInfo();
        }

        $(function () {
            FastClick.attach(document.body);                        
        });

        var minHeight = ($(window).height() - $(".staticul").height() - $(".header").height()) / 2;

        function getNewInfo() {
            ShowLoading("正在加载..");

            $.ajax({
                url: "RankCore.aspx",
                type: "post",
                data: { ctrl: "getNewInfo", "ryid": "<%= ryid%>" },
                cache: false,
                timeout: 15000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    //HideLoading();
                    if (errorThrown.toString() != "") {     //如果没有错误，则不输出（AJAX调用期间，页面被关掉，也会出此错误；但错误内容为空）
                        alert(errorThrown);
                    }
                },
                success: function (result) {
                    HideLoading();
                    var obj = JSON.parse(result);
                    if (obj.err != undefined) {
                        alert(obj.err);

                    } else {
                        //ShowInfo("加载成功！");
                        $("#todaySale").append(GetWan(parseInt(obj.rows[0].daySale)));
                        $("#todayCount").append(parseInt(obj.rows[0].dayCount));
                        $("#monthSale").append(GetWan(parseInt(obj.rows[0].monthSale)));
                        $("#monthCount").append(parseInt(obj.rows[0].monthCount));
                        $("#goal").append(GetWan(parseFloat(obj.rows[0].saleTarget).toFixed(1)) + "W");
                        $("#allGoal").append(GetWan(parseFloat(obj.rows[0].allTarget).toFixed(1)) + "W");
                        $("#finishMonth").append(obj.rows[0].pcent);
                        $("#finishYear").append(obj.rows[0].allPercent);
                        $(".val").fadeInWithDelay();
                        getSaleData();
                        if (parseFloat(obj.rows[0].saleTarget) < 0.01) {
                            alert("您尚未设置个人目标！");
                            $("#goal").html("设置");
                        }
                    }
                }
            });
        }

        $.fn.fadeInWithDelay = function () {
            var delay = 0;
            return this.each(function () {
                $(this).delay(delay).animate({ opacity: 1 }, 200);
                delay += 200;
            });
        };

        function GetWan(y) {
            var rt;
            if (isNaN(y)) {
                rt = y;
            } else {
                var vvv = parseInt(y) * 0.0001;
                if (vvv < 10) {
                    rt = y;
                } else {
                    vvv = parseInt(vvv);
                    rt = vvv.toString() + "W";
                }
            }

            return rt;
        }



        //图表
        function getSaleData() {
            ShowLoading("分析近半年的销售数据..");
            $.ajax({
                url: "RankCore.aspx",
                type: "post",
                data: { ctrl: "saleInfo", "ryid": "<%= ryid%>" },
                cache: false,
                timeout: 15000,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    HideLoading();
                    if (errorThrown.toString() != "") {     //如果没有错误，则不输出（AJAX调用期间，页面被关掉，也会出此错误；但错误内容为空）
                        alert(errorThrown);
                    }
                },
                success: function (result) {
                    HideLoading();
                    var obj = JSON.parse(result);
                    var lbls = new Array();
                    var datas = new Array();
                    if (obj.err != undefined) {
                        //alert(obj.err);
                        //getHeight();
                        $(".chart-area").children().hide();
                        $(".chart-area").html("<div class='errInfo' style='margin-top:" + minHeight + "px;'>" + obj.err + "</div>");
                    } else {
                        ShowInfo("分析完毕！");


                        for (var i = 0; i < obj.rows.length; i++) {
                            lbls[i] = obj.rows[i].ny + "月";
                            datas[i] = parseInt(obj.rows[i].je);
                        }



                        var barData = {
                            labels: lbls,
                            datasets: [
                            {
                                fillColor: "rgba(255,126,0,1)",
                                strokeColor: "rgba(255,126,0,1)",
                                data: datas
                            }]
                        }
                        var ctx = document.getElementById("canvas").getContext("2d");
                        new Chart(ctx).Bar(barData);
                    }
                }
            });
        }

        function getTclist(ctrl) {
            window.location.href = "../Retail/tclist.aspx?ctrl="+ctrl;
        }

        function setSaleTarget() {
            window.location.href = "frmSaleTarget.aspx";
        }

        function backbtn() {
            window.history.go(-1);
        }

    </script>
</asp:Content>
